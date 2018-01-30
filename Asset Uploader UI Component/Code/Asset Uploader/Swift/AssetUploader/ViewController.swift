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
    
    // Implemented the required properties that the AdobeLibraryDelegate protocol specifies. Since
    // class extensions are not allowed to add properties, we need to define these properties here.
    var assetDownloadLibraryFilter: [AnyObject]!
    var autoSyncDownloadedAssets = false
    var libraryQueue: NSOperationQueue!
    var syncOnCommit = false
    
    private let userSpecifiedPathKey = "userSpecifiedPathKey"
    
    var rootLibDir: String = ""
    
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
        
        // Listen for the logout notification so we can perform some cleanup for the Library 
        // Manager.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(authDidLogout), name: AdobeAuthManagerLoggedOutNotification, object: nil)
    }
    
    @IBAction func showAssetUploaderButtonTouchUpInside()
    {
        // Create an Asset Uploader configuration object and set the datasource filter object
        let assetUploaderConfiguration = AdobeUXAssetUploaderConfiguration()
        var assetsToUpload = [AdobeUXAssetBrowserConfigurationProxyAsset]()
        
        // For the purpose of this demo we randomly pick the number of images we want to upload.
        for i in 1...self.randomValue(2, max: 8)
        {
            let assetToUpload = AdobeUXAssetBrowserConfigurationProxyAsset()
            
            // Assign a unique ID
            assetToUpload.assetId = "Image\(i)"
            
            // Image name could be anything, in this case it is Image1, Image2, etc
            assetToUpload.name = "Image (\(i))"
            
            // Provide the thumbnails to image that is being uploaded. (Randomly pick a image to 
            // upload for this demo from the images folder within project.)
            let thumbnailName = "Image\(self.randomValue(1, max: 8))"
            assetToUpload.thumbnail = UIImage(named: thumbnailName)
            
            assetsToUpload += [assetToUpload]
        }
        
        assetUploaderConfiguration.assetsToUpload = assetsToUpload
        
        // Create an instance of the Asset Uploader view controller.
        let assetUploaderViewController = AdobeUXAssetUploaderViewController(configuration:assetUploaderConfiguration, delegate:self)
        
        // Now present the Asset Uploader view controller.
        self.presentViewController(assetUploaderViewController!, animated: true, completion: nil)
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AdobeAuthManagerLoggedOutNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notification Handlers
    func authDidLogout(notification: NSNotification)
    {
        if rootLibDir.characters.count > 0
        {
            AdobeLibraryManager.removeLocalLibraryFilesInRootFolder(rootLibDir, withError: nil)
            
            rootLibDir = ""
            
            NSUserDefaults.standardUserDefaults().removeObjectForKey(userSpecifiedPathKey)
        }
    }
    
    // MARK: - Private Methods
    func setupAdobeLibraryManager(downloadPolicy: AdobeLibraryDownloadPolicyType)
    {
        // Below is the setup for configure & start AdobeLibraryManager.
        // For more info regarding libraries please refer: 
        // https://creativesdk.adobe.com/docs/ios/#/articles/libraries/index.html.
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
        libMgr.syncAllowedByNetworkStatusMask = UInt(AdobeNetworkStatus.ReachableViaWiFi.rawValue) |
            UInt(AdobeNetworkStatus.ReachableViaWWAN.rawValue)
        
        var rootLibDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        var url = NSURL(fileURLWithPath: rootLibDir)
        url = url.URLByAppendingPathComponent("libraries")
        
        // User-specific path to sync Libraries from the cloud.
        url = url.URLByAppendingPathComponent(UUIDForUserSpecificPath())
        
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
    
    func randomValue(min: UInt32, max: UInt32) -> UInt32
    {
        return (min + arc4random_uniform(max - min + 1))
    }
    
    func UUIDForUserSpecificPath() -> String
    {
        // If we have a UUID then use it.
        var userSpecificID = NSUserDefaults.standardUserDefaults().stringForKey(userSpecifiedPathKey)
        
        if (userSpecificID?.characters.count > 0)
        {
            return userSpecificID!
        }
        
        // Generate a new UUID
        userSpecificID = NSUUID().UUIDString
        
        NSUserDefaults.standardUserDefaults().setObject(userSpecificID, forKey: userSpecifiedPathKey)
        
        return userSpecificID!
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
        for assetName in assetsToUpload.keys
        {
            message += "\(assetsToUpload[assetName])\n"
            let assetURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(assetName, ofType: "png")!)
            
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
                    }
                )
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
                    }
                )
            }
            else if let selectedPhotoCatalog = destination.selectedItem as? AdobePhotoCatalog
            {
                // Upload assets to selected photo catalog.
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
                    }
                )
            }
        }
        
        // Uploading to libraries, then perform sync.
        if ((destination.selectedItem as? AdobeLibraryComposite) != nil)
        {
            // Perform sync so that the added assets are uploaded & a delegate callback is 
            // received on sync complete.
            let libMgr = AdobeLibraryManager.sharedInstance()
            libMgr.sync()
        }
        
        message += "\n Your assets are being uploaded asynchronously to destination. Please refer" +
            " the console log for upload success or error for each asset."
        
        let alertController = UIAlertController(title:"Uploading Assets", message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func assetUploaderViewController(assetUploader: AdobeUXAssetUploaderViewController, didEncounterError error: NSError)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        print("Asset Uploader failed with error: %@", error)
        
        let message = "Error: \(error)"
        let alertController = UIAlertController(title:"Upload Error", message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func assetUploaderViewControllerDidClose(assetUploader: AdobeUXAssetUploaderViewController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        print("Asset Uploader was dismissed without selecting a destination folder.");
    }
}

// MARK: - AdobeLibraryDelegate
extension ViewController: AdobeLibraryDelegate
{
    func syncFinished()
    {
        // AdobeLibraryManager completed sync, hence deregister as delegate so that AdobeLibraryManager shuts down.
        AdobeLibraryManager.sharedInstance().deregisterDelegate(self)
    }
}
