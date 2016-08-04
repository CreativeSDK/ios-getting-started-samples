<a name="asset_uploader"></a>
## Integrating the Asset Uploader

*You can find the complete `AssetUploader` project for this guide in <a href="https://github.com/CreativeSDK/ios-getting-started-samples" target="_blank">GitHub</a>.*

Frameworks required to integrate for this feature: AdobeCreativeSDKAssetUX, AdobeCreativeSDKAssetModel, AdobeCreativeSDKCommonUX and AdobeCreativeSDKCore.

The `AdobeUXAssetUploaderViewController` class provides a simple user interface for selecting destination for uploading assets to creative cloud files, libraries and lightroom collections/catalogs. In the sample app, we randomly select images from set of 8 images in the resources and launch the upload component.

### User Interface
The sample app consists of a single view controller with a button titled "Launch Uploader".

<img style="border: 1px solid #ccc;" src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetuploader/launch.png" />

On selecting the button, the asset uploader component is launched and user will be asked to sign-in.

<img style="border: 1px solid #ccc;" src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetuploader/login.png" />

Once the user logs in, the default "files" selected in the top drop down. Others options libraries or photos can be selected. You can also see that the current list of assets to upload are shown at the top in a table view.
The table shows 3 items and then has a collapsible option to display more items. 

<img style="border: 1px solid #ccc;" src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetuploader/files.png" />

<img style="border: 1px solid #ccc;" src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetuploader/selector.png" />

Users can select existing folder or create new folders to upload selected assets.

### Code

The single view controller of the application handles most of the work. The action handler `showAssetUploaderButtonTouchUpInside` method is responsible for initialising and presenting the uploader component as below:

    - (IBAction)showAssetBrowserButtonTouchUpInside
    {
        AdobeUXAssetUploaderConfiguration *browserConfig = [AdobeUXAssetUploaderConfiguration new];

        // For the purpose of this demo we randomly pick the number of images we want to upload.
        NSUInteger numberOfAssets = [self randomValueBetween:2 and:8];
        NSMutableArray *assetsToUpload = [NSMutableArray new];

        for (NSUInteger i = 1; i <= numberOfAssets; i++)
        {
            AdobeUXAssetBrowserConfigurationProxyAsset *assetToUpload = [AdobeUXAssetBrowserConfigurationProxyAsset new];

            // Assign a unique ID
            assetToUpload.assetId = [NSString stringWithFormat:@"id%lu", (unsigned long)i - 1];

            // Image name could be anything, in this case it is Image1, Image2, etc
            assetToUpload.name = [NSString stringWithFormat:@"Image%lu", (unsigned long)i];

            // Provide the thumbnails to image that is being uploaded. (Randomly pick a image to upload for this demo from the images folder within project.)
            NSString *thumbnailName = [NSString stringWithFormat:@"Image%d", [self randomValueBetween:1 and:8]];
            assetToUpload.thumbnail = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:thumbnailName ofType:@"png"]];

            [assetsToUpload addObject:assetToUpload];
        }

        browserConfig.assetsToUpload = assetsToUpload;
        AdobeUXAssetUploaderViewController *vc = [AdobeUXAssetUploaderViewController assetUploaderViewControllerWithConfiguration:browserConfig
        delegate:self];

        [self presentViewController:vc animated:YES completion:nil];
    }

Create a uploader configuration. For each asset you want to upload create a AdobeUXAssetBrowserConfigurationProxyAsset and set the properties as shown in the above code.
Once you have a list of proxy assets, set the list to uploader configuration. Create a AdobeUXAssetUploaderViewController using the configuration object create in previous step and
present the view controller.

Implement the methods the delegate AdobeUXAssetUploaderViewControllerDelegate. When user selects a destination, the delegate is called back with the selected destination.
Dismiss the asset uploader controller in the delegate callback. The selected destination can be an AdobeAssetFolder, AdobeLibraryComposite, AdobePhotoCollection or a AdobePhotoCatalog. 
The delegate also provides a list of items to upload. In the delegate use the appropriate headless api's to perform the actual upload. Note that uploading to libraries requires an additional handling.
In order to perform the actual upload to libraries, AdodeLibraryManager is requried to be running. Hence in the delegate callback, set up the AdobeLibraryManager, peform the upload, call sync and then 
when the AdobeLibraryManager sync finishes deregister as AdobeLibraryManager delegate so that it shuts down.
