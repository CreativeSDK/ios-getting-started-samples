# Using the Library Datasource of the Asset Browser Component

_Note: You can find the complete `Library Browser` project for this guide in the [Creative SDK Samples GitHub Repository][1]._

[1]: https://github.com/CreativeSDK/ios-getting-started-samples/tree/master/Creative%20Cloud%20Libraries%20Overview

The `AdobeUXAssetBrowserViewController` class provides a simple UI for browsing assets stored on the Creative Cloud. You can easily restrict the types of assets or datasources that are displayed. This could be helpful to end-users to avoid confusion. For this sample project we only want to display the Creative Cloud Libraries datasource. Also, although all asset types _within_ a Library are displayed, the code only attempts to process the selected image/graphics assets. This is only a restriction of the sample project for demonstration purposes. In shipping code, each asset type can be selected and handled appropriately.

##UI
The provided interface for this sample is quite straightforward. There is a single button that instantiates the Asset Browser view controller, configures and presents it. The user is presented with an authentication screen to enter their Creative Cloud credentials. Once authenticated, the Libraries datasource of the full Asset Browser is displayed where all Libraries that the user has created or has access to are present. Each Library can be browsed and individual asset types can be selected. This UI is quite similar to the other datasources presented by the Asset Browser.

<a name="prerequisites"></a>
## Prerequisites

This guide will assume that you have installed all software and completed all of the steps in the following guides:

*   [Getting Started](https://creativesdk.adobe.com/docs/ios/#/articles/gettingstarted/index.html)
*   [Framework Dependencies](https://creativesdk.adobe.com/docs/ios/#/articles/dependencies/index.html) guide.

_**Note:**_

*   _This component requires that the user is **logged in with their Adobe ID**._
*   _Your Client ID must be [approved for **Production Mode** by Adobe](https://creativesdk.zendesk.com/hc/en-us/articles/204601215-How-to-complete-the-Production-Client-ID-Request) before you release your app._

## Code
There are two main tasks that are performed:

1. Instantiating and configuring the Asset Browser view controller instance.
2. Handling the selected assets

The first task is rather simple. We simply acquire an instance of the `AdobeUXAssetBrowserViewController` using the provided convenience method. We create the needed configuration object instance to restrict the displayed datasources to Libraries. Then we provide the configuration object and present it like a regular `UIViewController`:

Objective-C

    // Only show the Library datasource in the Asset Browser. This helps keep this test app focused.
    AdobeAssetDataSourceFilter *datasourceFilter =
        [[AdobeAssetDataSourceFilter alloc] initWithDataSources:@[AdobeAssetDataSourceLibrary]
                                                     filterType:AdobeAssetDataSourceFilterInclusive];
 
    // Create an Asset Browser configuration object that can be used to filter the datasources and
    // to specify the supported Library item types.
    AdobeUXAssetBrowserConfiguration *configuration = [AdobeUXAssetBrowserConfiguration new];
    configuration.dataSourceFilter = datasourceFilter;

     // Create a new instance of the Asset Browser view controller, set it's configuration and
     // delegate and present it.
    AdobeUXAssetBrowserViewController *assetBrowser =
        [AdobeUXAssetBrowserViewController assetBrowserViewControllerWithConfiguration:configuration
                                                                              delegate:self];

    [self presentViewController:assetBrowser animated:YES completion:nil];

Swift 2

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

The second task is the actual handling of the selected asset. For this task we first need to instantiate and start the Library Manager. Since Libraries are "living" things, meaning that they can change at any time by any of the Adobe apps that use them, we need to start the Library Manager so it can get the latest state of all the Libraries and their content. Once the Library Manger has been kicked off, we can determine whether the selected asset serves out purpose so we need to check its type. Note that since the Asset Browser presents many datasources and assets type, it's a good idea to perform this check. Although in the case of the demo we've restricted the Asset Browser to the Libraries datasource, this check is only for demonstration purposes.

Once we've determined that the selected asset type is suitable for our needs (an image or graphic), we request a rendition (i.e. thumbnail) form the server. The Creative Cloud server will then generate a suitable thumbnail image based on the specified attributes and will return that thumbnail in the success block of the call. Finally, we use the returned data to display the image:

    // Configure the AdobeLibraryManager and start it before we do anything. We're required to do
    // this to make sure the latest revision of the Libraries and the contained assets are present.
    AdobeLibraryDelegateStartupOptions *libraryManagerStartupOptions = [AdobeLibraryDelegateStartupOptions new];
    libraryManagerStartupOptions.autoDownloadPolicy = AdobeLibraryDownloadPolicyTypeManifestOnly;
    libraryManagerStartupOptions.autoDownloadContentTypes = @[kAdobeMimeTypePNG, kAdobeMimeTypeJPEG];
    libraryManagerStartupOptions.elementTypesFilter = @[AdobeDesignLibraryImageElementType];
    
    NSString *rootLibraryDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    rootLibraryDirectory = [rootLibraryDirectory stringByAppendingPathComponent:[NSBundle mainBundle].bundleIdentifier];
    rootLibraryDirectory = [rootLibraryDirectory stringByAppendingPathComponent:@"libraries"];
    
    NSError *error = nil;
    AdobeLibraryManager *libraryManager = [AdobeLibraryManager sharedInstance];
    libraryManager.syncAllowedByNetworkStatusMask = AdobeNetworkReachableViaWiFi | AdobeNetworkReachableViaWWAN;
    [libraryManager startWithFolder:rootLibraryDirectory andError:&error];
    [libraryManager registerDelegate:self options:libraryManagerStartupOptions];
    
    // Grab the first selected item. This item is the a selection object that has information about
    // the selected item(s). We can use this object to pinpoint the selected Library item and
    // perform interesting tasks, like downloading a thumbnail.
    AdobeSelectionLibraryAsset *librarySelection = itemSelections.firstObject;
    
    // Make sure we're dealing with a Library selection object.
    if (IsAdobeSelectionLibraryAsset(librarySelection))
    {
        // Grab the Library object.
        AdobeAssetLibrary *library = (AdobeAssetLibrary *)librarySelection.selectedItem;
    
        // Get the first selected item ID.
        NSString *selectedImageId = librarySelection.selectedImageIDs.firstObject;
        
        // Now get the selected item, in this case an image, from the Library. Note that, for this
        // demo, we only handle images, however all other supported Library item types can be
        // retrieved and processed.
        AdobeAssetLibraryItemImage *libraryImage = library.images[selectedImageId];
        
        // Get the rendition file reference. This reference can be used to download the rendition
        // from the server.
        AdobeAssetFile *thumbnailFile = libraryImage.rendition;
        
        // If the Library item doesn't have a rendition, fall back to the actual image data.
        if (thumbnailFile == nil)
        {
            thumbnailFile = libraryImage.image;
        }
        
        [thumbnailFile downloadRenditionWithType:AdobeAssetFileRenditionTypePNG
                                      dimensions:CGSizeMake(1024, 1024)
                                 requestPriority:NSOperationQueuePriorityNormal
                                   progressBlock:NULL
                                    successBlock:^(NSData *data, BOOL fromCache)
         {
             // Try to parse the data.
             UIImage *thumbnailImage = [UIImage imageWithData:data];
             
             // Everything is good, display the image and stop the activity indicator.
             self.selectionThumbnailImageView.image = thumbnailImage;
             
             [self.activityIndicator stopAnimating];
         }
                               cancellationBlock:NULL
                                      errorBlock:NULL];
    }

Swift 2

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
    // demo, we only handle images, however all other supported Library item types can be
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
        },
        cancellationBlock:nil,
        errorBlock: nil
    )
