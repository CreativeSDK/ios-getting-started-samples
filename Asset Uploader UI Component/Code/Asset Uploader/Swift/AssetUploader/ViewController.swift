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
    // Note: Please update the ClientId and Secret to the values provided by  creativesdk.com or
    // from Adobe
    private let kCreativeSDKClientId = "Change me"
    private let kCreativeSDKClientSecret = "Change me"
    
    // Implemented the required properties that the AdobeLibraryDelegate protocol specifies. Since
    // class extensions are not allowed to add properties, we need to define these properties here.
    var assetDownloadLibraryFilter: [AnyObject]!
    var autoSyncDownloadedAssets = false
    var libraryQueue: NSOperationQueue!
    var syncOnCommit = false

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        AdobeUXAuthManager.sharedManager().setAuthenticationParametersWithClientID(kCreativeSDKClientId, withClientSecret: kCreativeSDKClientSecret)
    }
    
    @IBAction func showAssetUploaderButtonTouchUpInside()
    {
        // Create an Asset Uploader configuration object and set the datasource filter object
        let assetUploaderConfiguration = AdobeUXAssetUploaderConfiguration()
        var assetsToUpload = [AdobeUXAssetBrowserConfigurationProxyAsset]()
        
        for i in 1...3
        {
            let assetToUpload = AdobeUXAssetBrowserConfigurationProxyAsset()
            
            // Assign a unique ID
            assetToUpload.assetId = "id\(i-1))"
            
            // Asset name could be anything, in this case it is Asset1, Asset 2, etc
            let assetName = "Asset\(i)"
            assetToUpload.name = assetName
            
            // Provide the thumbnails to asset that is being uploaded.
            assetToUpload.thumbnail = UIImage(named: assetName)
            
            assetsToUpload += [assetToUpload]
        }
        
        assetUploaderConfiguration.assetsToUpload = assetsToUpload
        
        // Create an instance of the Asset Uploader view controller.
        let assetUploaderViewController = AdobeUXAssetUploaderViewController(configuration:assetUploaderConfiguration, delegate:self)
        
        // Now present the Asset Uploader view controller.
        self.presentViewController(assetUploaderViewController!, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAdobeLibraryManager(downloadPolicy: AdobeLibraryDownloadPolicyType)
    {
        // Below is the setup for configure & start AdobeLibraryManager.
        // For more info regarding libraries please refer: https://creativesdk.adobe.com/docs/ios/#/articles/libraries/index.html.
        let startupOptions = AdobeLibraryDelegateStartupOptions()
        
        startupOptions.autoDownloadPolicy = downloadPolicy
        startupOptions.autoDownloadContentTypes = [kAdobeMimeTypeJPEG, kAdobeMimeTypePNG]
        startupOptions.elementTypesFilter = [AdobeDesignLibraryColorElementType,
                                             AdobeDesignLibraryColorThemeElementType,
                                             AdobeDesignLibraryCharacterStyleElementType,
                                             AdobeDesignLibraryBrushElementType,
                                             AdobeDesignLibraryImageElementType,
                                             AdobeDesignLibraryLayerStyleElementType]
        
        syncOnCommit = true;
        libraryQueue = NSOperationQueue.mainQueue()
        autoSyncDownloadedAssets = false;
        
        let libMgr = AdobeLibraryManager.sharedInstance()
        libMgr.syncAllowedByNetworkStatusMask = 1 << 1 | 1 << 2
        
        var rootLibDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        var url = NSURL.init(fileURLWithPath: rootLibDir)
        url = url.URLByAppendingPathComponent(NSBundle.mainBundle().bundleIdentifier!)
        url = url.URLByAppendingPathComponent("libraries")
        rootLibDir = url.absoluteString
        
        do
        {
            // Start the AdobeLibraryManager.
            try libMgr.startWithFolder(rootLibDir)
        }
        catch
        {
            print("AdobeLibraryManager failed to start")
        }
        
        // Register as delegate to get callbacks.
        libMgr.registerDelegate(self, options: startupOptions)
    }
}

// MARK: - AdobeUXAssetUploaderViewControllerDelegate
extension ViewController : AdobeUXAssetUploaderViewControllerDelegate
{
    func assetUploaderViewController(assetUploader: AdobeUXAssetUploaderViewController, didSelectDestination destination: AdobeSelection, assetsToUpload: [String : String])
    {
        self.dismissViewControllerAnimated(true, completion: nil)

        var message = ""
        
        if let selectedFolder = destination.selectedItem as? AdobeAssetFolder
        {
            message = message.stringByAppendingFormat("Folder - %@", selectedFolder.href)
        }
        else if let selectedLibrary = destination.selectedItem as? AdobeLibraryComposite
        {
            // Start the AdobeLibraryManager so that assets can be added to libraries & synced.
            self.setupAdobeLibraryManager(.ManifestOnly)
            message = message.stringByAppendingFormat("Library - %@", selectedLibrary.name)
        }
        else if let selectedPhotoCollection = destination.selectedItem as? AdobePhotoCollection
        {
            message = message.stringByAppendingFormat("Photo Collection - %@", selectedPhotoCollection.name)
        }
        else if let selectedPhotoCatalog = destination.selectedItem as? AdobePhotoCatalog
        {
            message = message.stringByAppendingFormat("Photo Catalog - %@", selectedPhotoCatalog.name)
        }
      
        message += "\n\nAsset Names:\n"
        
        // Perform the upload.
        for assetName in assetsToUpload.values
        {
            message += "\(assetName)\n"
            let assetURL = NSURL.init(fileURLWithPath: NSBundle.mainBundle().pathForResource(assetName, ofType: "png")!)
            
            if let selectedFolder = destination.selectedItem as? AdobeAssetFolder
            {
                // Upload assets to selected folder.
                AdobeAssetFile.create(assetName,
                                      folder: selectedFolder,
                                      dataPath: assetURL,
                                      contentType: kAdobeMimeTypePNG,
                                      progressBlock: nil,
                                      successBlock:
                    {
                        (file: AdobeAssetFile!) in
                        print("Upload success: %@", assetName)
                        
                    },
                                      cancellationBlock: nil,
                                      errorBlock:
                    {
                        (error: NSError!) in
                        print("Upload failed: %@", error)
                })
            }
            else if let selectedLibrary = destination.selectedItem as? AdobeLibraryComposite
            {
                do
                {
                    // Add assets to selected library and perform sync.
                    try AdobeDesignLibraryUtils.addImage(assetURL, name: assetName, library: selectedLibrary)
                    print("Added to library: %@", assetName)
                }
                catch
                {
                    print("Add to library failed: %@", error)
                }
            }
            else if let selectedPhotoCollection = destination.selectedItem as? AdobePhotoCollection
            {
                // Upload assets to selected photo collection.
                AdobePhotoAsset.create(assetName,
                                       collection: selectedPhotoCollection,
                                       dataPath: assetURL,
                                       contentType: kAdobeMimeTypePNG,
                                       progressBlock: nil,
                                       successBlock:
                    {
                        (asset: AdobePhotoAsset!) in
                        print("Upload success: %@", assetName)
                    },
                                       cancellationBlock: nil,
                                       errorBlock:
                    {
                        (error: NSError!) in
                        print("Upload failed: %@", error)
                })
            }
            else if let selectedPhotoCatalog = destination.selectedItem as? AdobePhotoCatalog
            {
                // Upload assets to selelcted photo catalog.
                AdobePhotoAsset.create(assetName,
                                       catalog: selectedPhotoCatalog,
                                       dataPath: assetURL,
                                       contentType: kAdobeMimeTypePNG,
                                       progressBlock: nil,
                                       successBlock:
                    {
                        (asset: AdobePhotoAsset!) in
                        print("Upload success: %@", assetName)
                    },
                                       cancellationBlock: nil,
                                       errorBlock:
                    {
                        (error: NSError!) in
                        print("Upload failed: %@", error)
                })
            }
        }
        
        // Uploading to libraries, then perform sync.
        if ((destination.selectedItem as? AdobeLibraryComposite) != nil)
        {
            // Perform sync so that the added assets are uploaded & a delegate callback is received on sync complete.
            let libMgr = AdobeLibraryManager.sharedInstance()
            libMgr.sync()
        }
        message += "\n Your assets are being uploaded asynchronously to destination. Please refer the console log for upload success or error for each asset."
        
        let alertController = UIAlertController.init(title:"Uploading Assets", message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func assetUploaderViewController(assetUploader: AdobeUXAssetUploaderViewController, didEncounterError error: NSError)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        print("Asset Uploader failed with error: %@", error)
        let message = "Error: \(error)"
        let alertController = UIAlertController.init(title:"Upload Error", message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func assetUploaderViewControllerDidClose(assetUploader: AdobeUXAssetUploaderViewController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        print("Asset Uploader was dismissed without selectiong a destination folder.");
    }
}

// MARK: - AdobeLibraryDelegate
extension ViewController: AdobeLibraryDelegate
{
    func syncFinished()
    {
        // AdobeLibraryManager completed sync, hence deregister as delegate so that AdobeLibraryManager shutsdown.
        AdobeLibraryManager.sharedInstance().deregisterDelegate(self)
    }
}
