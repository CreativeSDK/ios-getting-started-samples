# Asset Browser UI

The Creative SDK provides a convenient UI for accessing all of a user’s creative assets stored in the Creative Cloud, including files, photos, libraries, and mobile creations. This guide demonstrates how to use the Creative SDK to:

+ Let users access existing files in the Creative Cloud.
+ Start working with PSD (Adobe PhotoShop) files. The Creative SDK lets you break a PSD into its component layers and perform different analysis and operations on them.

To integrate the Creative Cloud with your own file picker (instead of using the Asset Browser UI), see our headless APIs:

+ <a href="/articles/files/index.html">Creative Cloud Files API</a>
+ <a href="/articles/photos/index.html">Lightroom Photos API</a>
+ <a href="/articles/libraries/index.html">Creative Cloud Libraries</a>

## Contents

- Prerequisites
- [Integrating the Asset Browser](#asset_browser)
- [PSD Extraction](#psd_extraction)
- [Class Reference](#reference)

<a name="prerequisites"></a>

## Prerequisites

This guide will assume that you have installed all software and completed all of the steps in the following guides:

*   Getting Started
*   Framework Dependencies

_**Note:**_

*   _This component requires that the user is **logged in with their Adobe ID**._
*   _Your Client ID must be [approved for **Production Mode** by Adobe](https://creativesdk.zendesk.com/hc/en-us/articles/204601215-How-to-complete-the-Production-Client-ID-Request) before you release your app._

<a name="asset_browser"></a>
## Integrating the Asset Browser

*You can find the complete `AssetBrowser` project for this guide in <a href="https://github.com/CreativeSDK/ios-getting-started-samples" target="_blank">GitHub</a>.*

The `AdobeUXAssetBrowser` class provides a simple UI for browsing files and selecting them for download. You can easily restrict the types of files displayed; for example, you may want to display only image files. Once the user selects a file, use the `AdobeAssetFile` class to transfer the data from the cloud to the device.

In our application (found in the TestFiles folder in the ZIP archive referenced above), we add a simple Asset Browser, for the user to select a file. If the user selects a JPG or PNG file, we display that image directly within the application.

### UI

Once the user logs in, the Show File Chooser button prompts him to select a file:

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/browser1.jpg)

After that button is selected, AdobeUXAssetBrowser runs. All the UI you see here is driven by the SDK:

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/browser2.jpg)

Newer files are on top. Two controls at the top bring up a selection of options (selected here) and let you search for files:

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/browser3.jpg)

Selecting a file may bring up a preview, as shown here. The SDK can create previews for most common file types. (If the SDK can't provide a preview, no error occurs.)

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/browser4.jpg)

Click Open, and in the final part of our application, basic metadata about the file is displayed, and if the file is an image, it is downloaded and displayed in the application:

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/browser5.jpg)

### Code

The main view controller of the application sets up the "Select a File" button and creates a place for the metadata to be displayed. Most of the work happens in the controller. Here, we focus on the `showAssetBrowserButtonTouchUpInside` method, driven by the corresponding UI button:

    - (IBAction)showAssetBrowserButtonTouchUpInside
    {
        // Create a datasource filter object that excludes the Libraries and Photos datasources. For
        // the purposes of this demo, we'll only deal with non-complex datasources like the Files
        // datasource.
        AdobeAssetDataSourceFilter *dataSourceFilter =
            [[AdobeAssetDataSourceFilter alloc] initWithDataSources:@[AdobeAssetDataSourceLibrary, AdobeAssetDataSourcePhotos]
                                                         filterType:AdobeAssetDataSourceFilterExclusive];

        // Create an Asset Browser configuration object and set the datasource filter object.
        AdobeUXAssetBrowserConfiguration *assetBrowserConfiguration = [AdobeUXAssetBrowserConfiguration new];
        assetBrowserConfiguration.dataSourceFilter = dataSourceFilter;

        // Create an instance of the Asset Browser view controller
        AdobeUXAssetBrowserViewController *assetBrowserViewController =
            [AdobeUXAssetBrowserViewController assetBrowserViewControllerWithConfiguration:assetBrowserConfiguration
                                                                                  delegate:self];

        // Present the Asset Browser view controller
        [self presentViewController:assetBrowserViewController animated:YES completion:nil];
    }

To start, create a new instance of the `AdobeUXAssetBrowserViewController` class with the appropriate configuration and delegate objects. As mentioned above, you can configure the Asset Browser with filtering options, and for this demo we've excluded the Library and Photos datasources.

The `AdobeUXAssetBrowserViewControllerDelegate` protocol has three callback methods that could be implemented in order to know which assets were selected, whether there was an error or whether the user closed the Asset Browser view controller without selecting an Asset. Let's have a look at the body of the callback method for when the user has successfully selected one or more assets:

    [self dismissViewControllerAnimated:YES completion:nil];

        if (itemSelections.count == 0)
        {
            // Nothing selected so there is nothing to do.
            return;
        }

        // Get the first asset-selection object.
        AdobeSelectionAsset *assetSelection = itemSelections.firstObject;

        // Grab the generic AdobeAsset object from the selection object.
        AdobeAsset *selectedAsset = assetSelection.selectedItem;

        self.nameLabel.text = selectedAsset.name;

        // We should have a static instance of the date formatter here to avoid a performance hit,
        // but we'll go ahead and create one every time to the purposes of this demo.
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        dateFormatter.locale = [NSLocale currentLocale];

        self.modificationDateLabel.text = [dateFormatter stringFromDate:selectedAsset.modificationDate];

        // Make sure it's an AdobeAssetFile object.
        if (!IsAdobeAssetFile(selectedAsset))
        {
            return;
        }

        AdobeAssetFile *selectedAssetFile = (AdobeAssetFile *)selectedAsset;

        // Nicely format the file size
        if (selectedAssetFile.fileSize > 0)
        {
            self.sizeLabel.text = [NSByteCountFormatter stringFromByteCount:selectedAssetFile.fileSize
                                                                 countStyle:NSByteCountFormatterCountStyleFile];
        }

        // Download a thumbnail for common image formats
        if ([selectedAssetFile.type isEqualToString:kAdobeMimeTypeJPEG] ||
            [selectedAssetFile.type isEqualToString:kAdobeMimeTypePNG] ||
            [selectedAssetFile.type isEqualToString:kAdobeMimeTypeGIF] ||
            [selectedAssetFile.type isEqualToString:kAdobeMimeTypeBMP])
        {
            [self.loadingActivityIndicator startAnimating];

            // Round the width and the height up to avoid any half-pixel values.
            CGSize thumbnailSize = CGSizeMake(ceilf(self.thumbnailImageView.frame.size.width),
                                              ceilf(self.thumbnailImageView.frame.size.height));

            [selectedAssetFile downloadRenditionWithType:AdobeAssetFileRenditionTypePNG
                                              dimensions:thumbnailSize
                                         requestPriority:NSOperationQueuePriorityNormal
                                           progressBlock:nil
                                            successBlock:^(NSData *data, BOOL fromCache)
            {
                UIImage *rendition = [UIImage imageWithData:data];

                self.thumbnailImageView.image = rendition;

                [self.loadingActivityIndicator stopAnimating];

                NSLog(@"Successfully downloaded a thumbnail.");

            } cancellationBlock:^{

                NSLog(@"The rendition request was cancelled.");

                [self.loadingActivityIndicator stopAnimating];

            } errorBlock:^(NSError *error) {

                NSLog(@"There was a problem downloading the file rendition: %@", error);

                [self.loadingActivityIndicator stopAnimating];
            }];
        }
        else
        {
            NSString *message = @"The selected file type isn't a common image format so no "
            "thumbnail will be fetched from the server.\n\nTry selecting a JPEG, PNG or BMP file.";

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Demo Project"
                                                                                     message:message
                                                                              preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:NULL];

            [alertController addAction:okAction];

            [self presentViewController:alertController animated:YES completion:nil];
        }

The `itemSelections` argument to this callback method is an array (specifically an `AdobeSelectionAssetArray`) of items selected by the user from the Asset Browser. By default, the user can select only one option, so our code in the callback could be simpler.)

For the selected file, we can get metadata and display it to the user. While you may not do this often, it can be helpful; for example, you could use the `fileSize` property to determine whether to download the file. In our application, we use the file size and modification date. To get these properties, we have to cast the `AdobeAsset` object to `AdobeAssetFile`.

Next, we check the type of the selected file. If the file type is a common image format (i.e. image/jpeg, image/png, image/gif or image/bmp), we use the `AdobeAssetFile` `downloadRenditionWithType:dimensions:requestPriority:progressBlock:successBlock:cancellationBlock:errorBlock:]` method to grab a thumbnail of the file from the cloud. There are progress, cancellation, error, and completion callbacks, as well, so we control the thumbnail download process.

When the thumbnail has been downloaded, it is easy to create an `UIImage` and set it as the image for the `UIImageView` that is present in the app's storyboard.

<a name="psd_extraction"></a>
## PSD Extraction

In addition to simple file browsing, the Asset Browser provides a powerful tool for extracting and working with individual layers within a PSD file. You can find the complete `PSD Extraction` project for this guide in <a href="https://github.com/CreativeSDK/ios-getting-started-samples" target="_blank">GitHub</a>.

In the previous section, “Integrating the Asset Browser”, we demonstrated how to work with files. We used the `AdobeUXAssetBrowser` class to provide a UI that let the user select a particular file. Here, we use similar code, slightly modified. The `AdobeUXAssetBrowserConfiguration` class acts as a wrapper to provide powerful and complex filtering and configuration options for the Asset Browser:

    // Exclude all other data sources. Only allow the "Files" datasource
    AdobeAssetDataSourceFilter *dataSourceFilter = [[AdobeAssetDataSourceFilter alloc] initWithDataSources:@AdobeAssetDataSourceFiles
    filterType:AdobeAssetDataSourceFilterInclusive];

    // Exclude all other file types, other than PSD files.
    AdobeAssetMIMETypeFilter *mimeTypeFilter = [[AdobeAssetMIMETypeFilter alloc] initWithMIMETypes:@kAdobeMimeTypePhotoshop
    filterType:AdobeAssetMIMETypeFilterTypeInclusion];

Once we have an instance of this class, we can perform different operations on it to change how the Asset Browser behaves. The first thing we'll do is specify a PSD mime filter:

    AdobeUXAssetBrowserConfiguration *configuration = [AdobeUXAssetBrowserConfiguration new];

    configuration.dataSourceFilter = dataSourceFilter;
    configuration.mimeTypeFilter = mimeTypeFilter;

The next set of options is required to enabled PSD extraction and let the user select multiple PSD layers. (Enabling multiple-layer selection is optional. Use this setting if it makes sense for your application.)

    configuration.options = EnablePSDLayerExtraction | EnableMultiplePSDLayerSelection;

This can then be passed to the Asset Browser utility method that creates an instance for us:

    // Create an instance of the Asset Browser view controller
    AdobeUXAssetBrowserViewController *assetBrowserViewController =
        [AdobeUXAssetBrowserViewController assetBrowserViewControllerWithConfiguration:configuration
                                                                              delegate:self];

Here is the Asset Browser with the options applied:

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/psd1.jpg)

Non-PSDs are grayed out and not selectable by the user. This is an example of the filter being applied (which has uses outside the PSD extraction feature being demonstrated here).

After selecting an image, you get a preview as usual, but when you click **Open**, something new happens:

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/psd2.jpg)

Now the user can either open the PSD image or extract layers.

If **Extract Layers** is selected, some basic information about how this feature works is displayed:

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/psd3.jpg)

The NEVER SHOW AGAIN button enables users to skip this dialog in the future.

When this dialog is dismissed, the user can click and drag around the PSD, to select a region of the PSD:

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/psd4.jpg)

Once an area is selected, the Creative SDK analyzes the PSD and determines which layers are covered by the user’s selection:

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/psd5.jpg)

Notice how layers are named and previews are provided. The user can scroll up to redraw his selection or search for a layer by name.

Finally, the user selects the layers with which he wants to work:

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/psd6.jpg)

Clicking OPEN SELECTION causes the selected layer(s) to open.

Keep in mind that once the user selects an asset and makes a request to either open it or extract layers, the subsequent UI is driven by the Creative SDK. We only have to ask the `AdobeUXAssetBrowserViewController` to provide the feature.

    // Call the Asset Browser and pass the configuration options
    [[AdobeUXAssetBrowser sharedBrowser] popupFileBrowserWithParent:self configuration:configuration onSuccess:^(NSArray *itemSelections) {

    // Grab the last item that was selected.
    AdobeSelectionAsset *itemSelection = itemSelections.lastObject;

The rest is up to the developer. The `assetBrowserDidSelectAssets` method of the `AdobeUXAssetBrowserViewControllerDelegate` protocol is passed pointers to the selected file and any selected layers. Here is that block of code:

    // Grab the first selection object.
    AdobeSelectionAsset *itemSelection = itemSelections.firstObject;

    if (IsAdobeSelectionAssetPSDFile(itemSelection))
    {
        // We know the selected item is a PSD file so we can safely cast it to the specific type.
        AdobeSelectionAssetPSDFile *psdSelection = (AdobeSelectionAssetPSDFile *)itemSelection;

        // Grab the actual Asset file instance.
        AdobeAssetPSDFile *psdFile = (AdobeAssetPSDFile *)psdSelection.selectedItem;

        self.psdFileNameLabel.text = [NSString stringWithFormat:@"PSD File: %@", psdFile.name];
        self.psdFile = psdFile;

        // Also grab all the selected layers
        AdobePSDLayerSelectionArray *layerSelections = psdSelection.layerSelections;

        NSMutableArray *selectedLayers = [NSMutableArray arrayWithCapacity:psdSelection.layerSelections.count];

        for (AdobeSelectionPSDLayer *psdLayerSelection in layerSelections)
        {
            [selectedLayers addObject:psdLayerSelection.layer];
        }

        self.selectedLayers = selectedLayers;

        [self.tableView reloadData];
        self.tableView.hidden = NO;
    }

The code begins by getting the selected file: that is the main thing passed to the success handler. From that we can use a Creative SDK method, `IsAdobeSelectionAssetPSDFile`, to see if the file is a PSD. (We double check this even though we used a filter previously.) Once the file is cast down to an `AdobeAssetPSDFile`, you can request the layer selections.

In our example project, we get the array and loop over it. We are given a set of properties for each layer, and appends these properties to a string that it is output to the application along with the image of the layer. (You could do more than just enumerate and list these layers; for instance, you could create image previews of them and rebuild an image with just the selected layers.)

You can do almost anything with the layers. Since the Creative SDK handles user prompts and break-up and analysis of the PSD file, your code is free to handle the result as desired. To experiment with this, try the sample application.

<a name="reference"></a>
## Class Reference

+ AdobeAsset
+ AdobeAssetFile
+ AdobeAssetMIMETypeFilter
+ AdobeAssetPSDFile
+ AdobePSDLayerNode
+ AdobeSelectionAsset
+ AdobeSelectionAssetPSDFile
+ AdobeSelectionPSDLayer
+ AdobeUXAssetBrowser
+ AdobeUXAssetBrowserConfiguration
