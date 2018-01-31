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
    
    private let kLibraryRootFolderPathPreferencesKey = "kLibraryRootFolderPath"
    
    // Implement the required properties that the AdobeLibraryDelegate protocol specifies. Since
    // class extensions are not allowed to add properties, we need to define these properties here.
    var assetDownloadLibraryFilter: [AnyObject]!
    var autoSyncDownloadedAssets = false
    var libraryQueue: NSOperationQueue!
    var syncOnCommit = false
    
    var localLibraryRootFolder: String?
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var selectionThumbnailImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: -
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
        
        // Register for the logout notification so we can perform the necessary Library Manager
        // cleanup tasks.
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(userDidLogOutNotificationHandler),
                                                         name: AdobeAuthManagerLoggedOutNotification,
                                                         object: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        logoutButton.hidden = !AdobeUXAuthManager.sharedManager().authenticated
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit
    {
        // Although we don't need to do this starting in iOS 9[1], it's probably good practice to 
        // do it anyway.
        //
        // [1]: https://developer.apple.com/library/content/releasenotes/Foundation/RN-Foundation/#10_11NotificationCenter
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AdobeAuthManagerLoggedOutNotification, object: nil)
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
        
        // Create a new instance of the Asset Browser view controller, set it's configuration and
        // delegate and present it.
        let assetBrowser = AdobeUXAssetBrowserViewController(configuration: configuration, delegate: self)
        
        self.presentViewController(assetBrowser, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonTouchUpInside()
    {
        AdobeUXAuthManager.sharedManager().logout(
            {
                print("Successfully logged out.")
            },
            onError:
            {
                (error: NSError!) in
                
                print("There was a problem logging out: \(error)")
            }
        )
    }
    
    // Mark: - Notification Handlers
    func userDidLogOutNotificationHandler(notification: NSNotification)
    {
        if AdobeLibraryManager.sharedInstance().isStarted()
        {
            AdobeLibraryManager.sharedInstance().deregisterDelegate(self)
            
            if localLibraryRootFolder?.characters.count > 0
            {
                var error: NSError? = nil
                
                AdobeLibraryManager.removeLocalLibraryFilesInRootFolder(localLibraryRootFolder, withError: &error)
                
                if error != nil
                {
                    print("Could not remove local library file ('\(localLibraryRootFolder)') due to: \(error)")
                }
            }
        }
        
        logoutButton.hidden = !AdobeUXAuthManager.sharedManager().authenticated
        
        // Reset the Library root folder path variable
        localLibraryRootFolder = nil
        
        // Also remove the Library root folder path from the preferences since we're logging out
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kLibraryRootFolderPathPreferencesKey)
    }
    
    // Mark: - Private/Utility Methods
    func displayUnsupportedSelectionAlert()
    {
        let message = "For the purposes of this demo, please select an image/graphic Library item type."
        
        print(message)
        
        let alertController = UIAlertController(title: "Demo", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

// MARK: - AdobeUXAssetBrowserViewControllerDelegate
extension ViewController: AdobeUXAssetBrowserViewControllerDelegate
{
    func assetBrowserDidSelectAssets(itemSelections: [AdobeSelectionAsset])
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
        
        localLibraryRootFolder = NSUserDefaults.standardUserDefaults().stringForKey(kLibraryRootFolderPathPreferencesKey)
        
        if localLibraryRootFolder == nil || localLibraryRootFolder?.characters.count == 0
        {
            // Create a temporary path for the locally synced files to be stored.
            var rootLibraryFolder: NSString = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
            rootLibraryFolder = rootLibraryFolder.stringByAppendingPathComponent("libraries")
            rootLibraryFolder = rootLibraryFolder.stringByAppendingPathComponent(NSUUID().UUIDString)
            
            // Remember the path so we can clean it up on logout.
            localLibraryRootFolder = rootLibraryFolder as String
            
            // Store the user-specific Library root folder path in the preferences so it could be
            // retrieved on subsequent calls to the Asset Browser.
            NSUserDefaults.standardUserDefaults().setObject(rootLibraryFolder, forKey: kLibraryRootFolderPathPreferencesKey)
        }
        
        let libraryManager = AdobeLibraryManager.sharedInstance()
        libraryManager.syncAllowedByNetworkStatusMask = UInt(AdobeNetworkStatus.ReachableViaWiFi.rawValue) |
            UInt(AdobeNetworkStatus.ReachableViaWWAN.rawValue)
        
        do
        {
            // Start the Library manager
            try libraryManager.startWithFolder(localLibraryRootFolder)
            
            libraryManager.registerDelegate(self, options: libraryManagerStartupOptions)
        }
        catch let e
        {
            print("Could not start the Library Manager. An error occurred: \(e)")
        }
        
        // AdobeSelection is the superclass for both AdobeSelectionAsset and 
        // AdobeSelectionLibraryAsset. We cannot cross-cast from one sibling type to another, so we 
        // need to retrieve the first selected item as the more generic AdobeSelection, which will 
        // then be casted down to AdobeSelectionLibraryAssets.
        let selection: AdobeSelection? = itemSelections.first
        
        // Now make sure we're dealing with a Library selection object.
        guard let librarySelection = selection as? AdobeSelectionLibraryAsset else
        {
            print("The selected item isn't a Library selection.")
            
            return
        }
        
        // Grab the Library ID.
        let selectedLibraryId = librarySelection.selectedLibraryID
        
        // Grab the Library object.
        let library = AdobeLibraryManager.sharedInstance().libraryWithId(selectedLibraryId)
        
        // Get the first selected item ID.
        guard let selectedImageId = librarySelection.selectedElementIDs?.first else
        {
            self.displayUnsupportedSelectionAlert()
            
            return
        }
        
        // Now get the selected item, in this case an image, from the Library. Note that, for this
        // demo, we only handle images, however all other supported Library item types can be
        // retrieved and processed.
        let libraryElement = library.elementWithId(selectedImageId)
        
        print("Selected Library Element:\n\tID: \(libraryElement.elementId)\n\tName: \(libraryElement.name)\n" +
            "\tCreated: \(NSDate(timeIntervalSinceReferenceDate: libraryElement.created))\n" +
            "\tModified: \(NSDate(timeIntervalSinceReferenceDate: libraryElement.modified))\n" +
            "\tType: \(libraryElement.type)\n\tTags: \(libraryElement.tags)")
        
        // Clear out any existing thumbnails from already-selected images.
        selectionThumbnailImageView.image = nil
        
        // Start the activity indicator to get the user feedback.
        activityIndicator.startAnimating()
        
        library.getRenditionPath(selectedImageId,
                                 withSize: 0,
                                 isFullSize: true,
                                 handlerQueue: NSOperationQueue.mainQueue(),
                                 onCompletion:
            {
                [weak self] (path: String!) in
                
                // Try to create a UIImage object from the rendition and display it.
                let thumbnailImage = UIImage(contentsOfFile: path)
                
                if thumbnailImage == nil
                {
                    print("The returned rendition path cannot be converted into an image.")
                }
                else
                {
                    // We have everything we need. Now we display the image.
                    self?.selectionThumbnailImageView.image = thumbnailImage
                }
                
                self?.activityIndicator.stopAnimating()
            },
                                 onError:
            {
                [weak self] (error: NSError!) in
                
                print("An error occurred when attempting to retrieve the path to the rendition representation: \(error)")
                
                if error.domain == AdobeLibraryErrorDomain
                {
                    if error.code == AdobeLibraryErrorCode.RepresentationHasNoFile.rawValue ||
                       error.code == AdobeLibraryErrorCode.NoRenditionCandidate.rawValue
                    {
                        self?.displayUnsupportedSelectionAlert()
                    }
                }
                
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
