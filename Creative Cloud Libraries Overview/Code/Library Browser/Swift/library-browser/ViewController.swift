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
    // TODO: Please update the ClientId and Secret to the values provided by creativesdk.com or from Adobe
    private let kCreativeSDKClientId = "Change Me"
    private let kCreativeSDKClientSecret = "Change Me"
    
    // Implemented the required properties that the AdobeLibraryDelegate protocol specifies. Since 
    // class extensions are not allowed to add properties, we need to define these properties here.
    var assetDownloadLibraryFilter: [AnyObject]!
    var autoSyncDownloadedAssets = false
    var libraryQueue: NSOperationQueue!
    var syncOnCommit = false
    
    @IBOutlet weak var selectionThumbnailImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: -
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the client ID and secret values so the SDK can identify the calling app.
        AdobeUXAuthManager.sharedManager().setAuthenticationParametersWithClientID(kCreativeSDKClientId,
                                                                                   withClientSecret: kCreativeSDKClientSecret)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Actions
    @IBAction func showLibraryBrowserButtonTouchUpInside()
    {
        // Only show the Library datasource in the Asset Browser. This helps keep this test app focused.
        let dataSourceFilter = AdobeAssetDataSourceFilter(dataSources: [AdobeAssetDataSourceLibrary], filterType: .Inclusive)
        
        // Create an Asset Browser configuration object that can be used to filter the datasources and
        // to specify the supported Library item types.
        let configuration = AdobeUXAssetBrowserConfiguration()
        configuration.dataSourceFilter = dataSourceFilter
        
        // Create a new instance of the Asset Brwoser view contrller, set it's configuration and
        // delegate and present it.
        let assetBrowser = AdobeUXAssetBrowserViewController(configuration: configuration, delegate: self)
        
        self.presentViewController(assetBrowser, animated: true, completion: nil)
    }
}

// MARK: - AdobeUXAssetBrowserViewControllerDelegate
extension ViewController: AdobeUXAssetBrowserViewControllerDelegate
{
    func assetBrowserDidSelectAssets(itemSelections: [AnyObject])
    {
        // Dismiss the Asset Browser view controller.
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // Configure the AdobeLibraryManager and start it before we do anything. We're required to 
        // do this to make sure the latest revision of the Libraries and the contained assets are 
        // present.
        let libraryManagerStartupOptions = AdobeLibraryDelegateStartupOptions()
        libraryManagerStartupOptions.autoDownloadPolicy = .ManifestOnly
        libraryManagerStartupOptions.autoDownloadContentTypes = [kAdobeMimeTypePNG, kAdobeMimeTypeJPEG]
        libraryManagerStartupOptions.elementTypesFilter = [AdobeDesignLibraryImageElementType]
        
        var rootLibraryDirectory: NSString = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        rootLibraryDirectory = rootLibraryDirectory.stringByAppendingPathComponent(NSBundle.mainBundle().bundleIdentifier!)
        rootLibraryDirectory = rootLibraryDirectory.stringByAppendingPathComponent("libraries")
        
        let libraryManager = AdobeLibraryManager.sharedInstance()
        libraryManager.syncAllowedByNetworkStatusMask = UInt(AdobeNetworkStatus.ReachableViaWiFi.rawValue) |
            UInt(AdobeNetworkStatus.ReachableViaWWAN.rawValue)
        
        do
        {
            // Start the Library manager
            try libraryManager.startWithFolder(rootLibraryDirectory as String)
            libraryManager.registerDelegate(self, options: libraryManagerStartupOptions)
        }
        catch let e
        {
            print("Could not start the Library Manager. An error occurred: \(e)")
        }
        
        // Grab the first selected item and make sure we're dealing with a Library selection object.
        // This item is the selection object that has information about the selected item(s). We 
        // can use this object to pinpoint the selected Library item and perform interesting tasks, 
        // like downloading a thumbnail.
        guard let librarySelection = itemSelections.first as? AdobeSelectionLibraryAsset else
        {
            print("The selected item isn't a Library selection.")
            
            return
        }
        
        // Grab the Library object.
        guard let library = librarySelection.selectedItem as? AdobeAssetLibrary else
        {
            print("No selected item found.")
            
            return
        }
        
        // Get the first selected image ID.
        guard let selectedImageId = librarySelection.selectedImageIDs?.first else
        {
            let message = "For the purposes of this demo, please select an image/graphic Library item type."
            
            print(message)
            
            let alertController = UIAlertController(title: "Demo", message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Now get the selected item, in this case an image, from the Library. Note that, for this
        // demo, we only handline images, however all other supported Library item types can be
        // retrieved and processed.
        guard let libraryImage = library.images[selectedImageId] as? AdobeAssetLibraryItemImage else
        {
            print("Although an image was selected, its ID could not be retrieved.")
            
            return
        }
        
        // Get the rendition file reference. This reference can be used to download the rendition
        // from the server.
        var thumbnailFile: AdobeAssetFile? = libraryImage.rendition
        
        // If the Library item doesn't have a rendition, fall back to the actual image data.
        if thumbnailFile == nil
        {
            thumbnailFile = libraryImage.image;
        }
        
        guard thumbnailFile != nil else
        {
            print("No rendition or image is present for this Library image: \(libraryImage). Existing.")
            
            return
        }
        
        // Start the activity indicator to get the user feedback.
        activityIndicator.startAnimating()
        
        // Kick off the download action. Here we're requesting a PNG rendition with dimensions of
        // 1024×1024 points. The network request priority is set to normal. We've opted to not
        // specify a progress handler, however, we've chosen to listen for when the thumbnail is
        // downloaded successfully, so we can display it, when the request has been canceled and
        // for when there is an error with the request.
        thumbnailFile?.downloadRenditionWithType(.PNG,
            dimensions: CGSizeMake(1024, 2014),
            requestPriority: .Normal,
            progressBlock: nil,
            successBlock:
            {
                [weak self] (data: NSData!, fromCache: Bool) in
                
                // Try to parse the data.
                let thumbnailImage = UIImage(data: data)
                
                if (thumbnailImage != nil)
                {
                    // Everything is good, display the image and stop the activity indicator.
                    self?.selectionThumbnailImageView.image = thumbnailImage;
                    
                    self?.activityIndicator.stopAnimating();
                }
                else
                {
                    print("The returned data cannot be converted into an image.")
                }
            },
            cancellationBlock:
            {
                [weak self] in
                
                print("Rendition request canceled.")
                
                self?.activityIndicator.stopAnimating()
            },
            errorBlock:
            {
                [weak self](error: NSError!) in
                
                print("An error occurred when attempting to download a rendition: \(error)")
                
                self?.activityIndicator.stopAnimating()
            }
        )
    }
    
    func assetBrowserDidEncounterError(error: NSError)
    {
        // Dismiss the Asset Browser
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // Handle the error. Here we only print out a log of the error.
        print("An error occurred: \(error)")
    }
}

// MARK: - AdobeLibraryDelegate
extension ViewController: AdobeLibraryDelegate
{
    func syncFinished()
    {
        AdobeLibraryManager.sharedInstance().deregisterDelegate(self)
    }
}
