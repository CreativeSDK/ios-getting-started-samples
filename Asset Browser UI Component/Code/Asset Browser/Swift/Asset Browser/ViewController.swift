/*
 * Copyright (c) 2016 Adobe Systems Incorporated. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

import UIKit

class ViewController: UIViewController
{
    // TODO: Please update the ClientId and Secret to the values provided by creativesdk.com
    private let kCreativeSDKClientId = "Change me"
    private let kCreativeSDKClientSecret = "Change me"
    private let kCreativeSDKRedirectURLString = "Change me"
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var modificationDateLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the client ID and secret values so the CSDK can identify the calling app. The three
        // specified scopes are required at a minimum.
        AdobeUXAuthManager.sharedManager().setAuthenticationParametersWithClientID(kCreativeSDKClientId,
                                                                                   clientSecret: kCreativeSDKClientSecret,
                                                                                   additionalScopeList: [
                                                                                    AdobeAuthManagerUserProfileScope,
                                                                                    AdobeAuthManagerEmailScope,
                                                                                    AdobeAuthManagerAddressScope])
        
        // Also set the redirect URL, which is required by the CSDK authentication mechanism.
        AdobeUXAuthManager.sharedManager().redirectURL = NSURL(string: kCreativeSDKRedirectURLString)
    }
    
    @IBAction func showAssetBrowserButtonTouchUpInside()
    {
        // Create a datasource filter object that excludes the Libraries and Photos datasources. 
        // For the purposes of this demo, we'll only deal with non-complex datasources like the 
        // Files datasource.
        let dataSourceFilter = AdobeAssetDataSourceFilter(dataSources: [AdobeAssetDataSourceLibrary, AdobeAssetDataSourcePhotos], filterType: .Exclusive)
        
        // Create an Asset Browser configuration object and set the datasource filter object
        let assetBrowserConfiguration = AdobeUXAssetBrowserConfiguration()
        assetBrowserConfiguration.dataSourceFilter = dataSourceFilter
        
        // Create an instance of the Asset Browser view controller.
        let assetBrowserViewController = AdobeUXAssetBrowserViewController(configuration: assetBrowserConfiguration, delegate: self)
        
        // Now present the Asset Browser view controller.
        self.presentViewController(assetBrowserViewController, animated: true, completion: nil)
    }
}

// MARK: - AdobeUXAssetBrowserViewControllerDelegate
extension ViewController : AdobeUXAssetBrowserViewControllerDelegate
{
    func assetBrowserDidSelectAssets(itemSelections: [AdobeSelectionAsset])
    {
        // Dismiss the Asset Browser view controller
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // Get the first asset-selection object. An AssetSelection object encompasses an AdobeAsset
        // (sub)class and provides some extra information about the selection itself.
        let assetSelection = itemSelections.first
        
        // Grab the generic AdobeAsset object from the selection object, if one is present. 
        // Otherwise bail out.
        guard let selectedAsset: AdobeAsset = assetSelection?.selectedItem else
        {
            return;
        }
        
        self.nameLabel.text = selectedAsset.name
        
        // Make sure the file modification date is usable
        if let modificationDate = selectedAsset.modificationDate
        {
            // We should have a static instance of the date formatter here to avoid a performance 
            // hit, but we'll go ahead and create one every time for the purposes of keeping this 
            // demo brief.
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.timeStyle = .MediumStyle
            dateFormatter.locale = NSLocale.currentLocale()
            
            self.modificationDateLabel.text = dateFormatter.stringFromDate(modificationDate)
        }
        
        // Make sure the selected asset is an AdobeAssetFile instance.
        guard let selectedAssetFile = selectedAsset as? AdobeAssetFile else
        {
            return
        }
        
        // Nicely format the file size
        if (selectedAssetFile.fileSize > 0)
        {
            self.sizeLabel.text = NSByteCountFormatter.stringFromByteCount(selectedAssetFile.fileSize, countStyle: .File)
        }
        
        // Only attempt to download a thumbnail for common image formats
        if selectedAssetFile.type == kAdobeMimeTypeJPEG ||
            selectedAssetFile.type == kAdobeMimeTypePNG ||
            selectedAssetFile.type == kAdobeMimeTypeGIF ||
            selectedAssetFile.type == kAdobeMimeTypeBMP
        {
            self.loadingActivityIndicator.startAnimating()
            
            // Round the width and the height up to avoid any half-pixel values.
            let thumbnailSize = CGSize(width: ceil(self.thumbnailImageView.frame.size.width), height: ceil(self.thumbnailImageView.frame.size.height))
            
            selectedAssetFile.downloadRenditionWithType(.PNG,
                dimensions: thumbnailSize,
                requestPriority: .Normal,
                progressBlock: nil,
                successBlock:
                {
                    (data: NSData!, fromCache: Bool) -> Void in
                    
                    // Make sure the returned data is usable
                    guard let imageData = data else
                    {
                        print("No image data was returned.")
                        
                        return
                    }
                    
                    let rendition = UIImage(data: imageData)
                    
                    self.thumbnailImageView.image = rendition
                    
                    self.loadingActivityIndicator.stopAnimating()
                    
                    print("Successfully downloaded a thumbnail.")
                },
                cancellationBlock:
                {
                    print("The rendition request was cancelled.")
                    
                    self.loadingActivityIndicator.stopAnimating()
                },
                errorBlock:
                {
                    (error: NSError!) -> Void in
                    
                    print("There was a problem downloading the file rendition: \(error)")
                    
                    self.loadingActivityIndicator.stopAnimating()
                }
            )
        }
        else
        {
            let message = "The selected file type isn't a common image format so no thumbnail " +
                "will be fetched from the server.\n\nTry selecting a JPEG, PNG, or BMP file."
            
            let alertController = UIAlertController(title: "Demo Project", message: message, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func assetBrowserDidEncounterError(error: NSError)
    {
        // Dismiss the Asset Browser view controller
        self.dismissViewControllerAnimated(true, completion: nil)
        
        print("An error occurred: \(error)")
    }
    
    func assetBrowserDidClose()
    {
        print("The user closed the Asset Browser view controller.")
    }
}
