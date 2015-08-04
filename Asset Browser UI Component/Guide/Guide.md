# Asset Browser UI

The Creative SDK provides a convenient UI for accessing all of a user’s creative assets stored in the Creative Cloud, including files, photos, libraries, and mobile creations. This guide demonstrates how to use the Creative SDK to:

+ Let users access existing files in the Creative Cloud.
+ Start working with PSD (Adobe PhotoShop) files. The Creative SDK lets you break a PSD into its component layers and perform different analysis and operations on them.

To integrate the Creative Cloud with your own file picker (instead of using the Asset Browser UI), see our headless APIs:

+ <a href="/articles/files/index.html">Creative Cloud Files API</a>
+ <a href="/articles/photos/index.html">Lightroom Photos API</a>
+ <a href="/articles/libraries/index.html">Creative Cloud Libraries</a>

## Contents

- [Prerequisites](#prerequisites)
- [Integrating the Asset Browser](#asset_browser)
- [PSD Extraction](#psd_extraction)
- [Class Reference](#reference)

<a name="prerequisites"></a>
## Prerequisites

+ This guide assumes that you've already read the <a href="/articles/gettingstarted/index.html">Getting Started</a> guide and have implemented Auth.
+ For a complete list of framework dependencies, see the <a href="/articles/dependencies/index.html">Framework Dependencies</a> guide.

<a name="asset_browser"></a>
## Integrating the Asset Browser

*You can find the complete `AssetBrowser` project for this guide in <a href="https://github.com/CreativeSDK/ios-getting-started-samples" target="_blank">GitHub</a>.*

The `AdobeUXAssetBrowser` class provides a simple UI for browsing files and selecting them for download. You can easily restrict the types of files displayed; for example, you may want to display only image files. Once the user selects a file, use the `AdobeAssetFile` class to transfer the data from the cloud to the device.

In our application (found in the TestFiles folder in the ZIP archive referenced above), we add a simple file browser, for the user to select a file. If the user selects a JPG or PNG file, we display that image directly within the application.

### UI

Once the user logs in, the Show File Chooser button prompts him to select a file:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/browser1.jpg" />

After that button is selected, AdobeUXAssetBrowser runs. All the UI you see here is driven by the SDK:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/browser2.jpg" />

Newer files are on top. Two controls at the top bring up a selection of options (selected here) and let you search for files:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/browser3.jpg" />

Selecting a file may bring up a preview, as shown here. The SDK can create previews for most common file types. (If the SDK can't provide a preview, no error occurs.)

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/browser4.jpg" />

Click Open, and in the final part of our application, basic metadata about the file is displayed, and if the file is an image, it is downloaded and displayed in the application:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/browser5.jpg" />

### Code

The main view of the application sets up the Show File Chooser button and creates a place for the metadata to be displayed:

    //
    //  RKCView.m
    //  TestFiles
    //

    #import "RKCView.h"
    #import "RKCViewController.h"

    @implementation RKCView


    + (id)initWithFrame:(CGRect)frame
    {
       self = [super initWithFrame:frame];
       if (self) {

          _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
          [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
          _loginButton.frame = CGRectMake(0, 0, frame.size.width, 100);
          [_loginButton addTarget:(RKCViewController *)self.superview
            action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
          [self addSubview:_loginButton];

          _showFileChooseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
          [_showFileChooseButton setTitle:@"Show File Chooser" forState:UIControlStateNormal];
          _showFileChooseButton.frame = CGRectMake(0, 80, frame.size.width, 100);
          [_showFileChooseButton addTarget:(RKCViewController *)self.superview
            action:@selector(showFileChooser) forControlEvents:UIControlEventTouchUpInside];
          [self addSubview:_showFileChooseButton];

          //hidden by default
          _showFileChooseButton.hidden = YES;

          _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130,
            frame.size.width, 140)];
          _statusLabel.numberOfLines = 0;
          [self addSubview:_statusLabel];

       }
       return self;
    }


    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    + (void)drawRect:(CGRect)rect
    {
       // Drawing code
    }
    */

    @end

Most of the work happens in the controller. Here, we skip past the part of the controller which contains login/logout logic from the example in “Getting Started with the iOS Creative SDK“and focus on the showFileChooser method, driven by the corresponding UI button:

    + (void)showFileChooser {

       [[AdobeUXAssetBrowser sharedBrowser] popupFileBrowser:^(AdobeSelectionAssetArray
         *itemSelections) {
          NSLog(@"Selected a file");
          for(id item in itemSelections) {

             AdobeAsset *it = ((AdobeSelectionAsset *)item).selectedItem;

             NSLog(@"File name %@", it.name);
             //display info about it
             NSString *fileDesc =  [[NSString alloc]
                initWithFormat:@"File Details\nFile Name: %@\nFile Created: %@\nFile
                  Modified: %@\nFile Size: %lld", it.name, it.creationDate,
                  it.modificationDate, ((AdobeAssetFile *)it).fileSize];

             [((RKCView *)self.view).statusLabel setText:fileDesc];

             //If an image, let's draw it locally
             NSString *fileType = ((AdobeAssetFile *)it).type;
             if([fileType isEqualToString:@"image/jpeg" ] || [fileType
               isEqualToString:@"image/png" ]) {
                NSLog(@"Going to download the image");
                [((AdobeAssetFile *)it) getData:NSOperationQueuePriorityHigh
                   onProgress:^(double fractionCompleted) {
                   }
                   onCompletion:^(NSData *data, BOOL fromcache) {
                      NSLog(@"Done downloaded");
                      UIImage *preview = [UIImage imageWithData:data];
                      UIImageView *uiImage = [[UIImageView alloc]
                        initWithImage:preview];
                      uiImage.frame = CGRectMake(0, 275, 150, 150);
                      [self.view addSubview:uiImage];
                   }

                   onCancellation:^(void){
                   }
                   onError:^(NSError *error) {
                   }
                ];

             }

          }
       } onError:^(NSError *error)
       {
          //do nothing
          NSLog(@"Error");
       }];

    }

To start, the method uses the `sharedBrowser` property of the `AdobeUXAssetBrowser` class. This shared instance is how you interact with the browser; it can be used across your application. As mentioned above, you can start the file browser with filtering options, but for this application, we use the defaults. The `popupFileBrowser` argument is an array (specifically an `AdobeSelectionAssetArray`) of items selected by the user from the file browser. By default, the user can select only one option, so our code in the callback could be simpler, but for now we treat it as an array and iterate over it. (Only the final selection is displayed in the UI.)

For the selected file, we can get metadata and display it to the user. While you may not do this often, it can be helpful; for example, you could use file size to determine whether to download the file. In our application, we get file size and file creation and modification dates. To get these properties, we have to cast the `AdobeAsset` object as an `AdobeAssetFile`.

Next, we check the type of the selected file. If the file type is image/jpeg or image/png, we use the `AdobeAssetFile` `getData` method to grab the binary data from the cloud. There are progress, cancellation, error, and completion callbacks. In this application, we use only the completion handler.

When the bits have been downloaded, it is easy to create a `UIImage`, add it to a `UIImageView`, then add it to our main view. Normally, you would store this on the device, so you can use it after the application restarts.

<a name="psd_extraction"></a>
## PSD Extraction

In addition to simple file browsing, the Asset Browser provides a powerful tool for extracting and working with individual layers within a PSD file.  You can find the complete `PSD Extraction` project for this guide in <a href="https://github.com/CreativeSDK/ios-getting-started-samples" target="_blank">GitHub</a>.

In the previous section, “Integrating the Asset Browser”, we demonstrated how to work with files. We used the `AdobeUXAssetBrowser` class to provide a UI that let the user select a particular file. Here, we use similar code, slightly modified. The `AdobeUXAssetBrowserConfiguration` class acts as a wrapper to provide powerful and complex filtering and configuration options for the file browser:

    // Exclude all other data sources. Only allow the "Files" datasource
    AdobeAssetDataSourceFilter *dataSourceFilter = [[AdobeAssetDataSourceFilter alloc] initWithDataSources:@[AdobeAssetDataSourceFiles]
    filterType:AdobeAssetDataSourceFilterInclusive];

    // Exclude all other file types, other than PSD files.
    AdobeAssetMIMETypeFilter *mimeTypeFilter = [[AdobeAssetMIMETypeFilter alloc] initWithMIMETypes:@[kAdobeMimeTypePhotoshop]
    filterType:AdobeAssetMIMETypeFilterTypeInclusion];

Once we have an instance of this class, we can perform different operations on it to change how the file browser behaves. The first thing we'll do is specify a PSD mime filter:

    AdobeUXAssetBrowserConfiguration *configuration = [AdobeUXAssetBrowserConfiguration new];

    configuration.dataSourceFilter = dataSourceFilter;
    configuration.mimeTypeFilter = mimeTypeFilter;

The next set of options is required to enabled PSD extraction and let the user select multiple PSD layers. (Enabling multiple-layer selection is optional. Use this setting if it makes sense for your application.)

    configuration.options = EnablePSDLayerExtraction | EnableMultiplePSDLayerSelection;

This can then be passed to the file browser:

// Call the Asset Browser and pass the configuration options
[[AdobeUXAssetBrowser sharedBrowser] popupFileBrowserWithParent:self configuration:configuration onSuccess:^(NSArray *itemSelections)

Here is the file browser with the options applied:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/psd1.jpg" />

Non-PSDs are grayed out and not selectable by the user. This is an example of the filter being applied (which has uses outside the PSD extraction feature being demonstrated here).

After selecting an image, you get a preview as usual, but when you click **Open**, something new happens:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/psd2.jpg" />

Now the user can either open the PSD image or extract layers.

If **Extract Layers** is selected, some basic information about how this feature works is displayed:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/psd3.jpg" />

The NEVER SHOW AGAIN button enables users to skip this dialog in the future.

When this dialog is dismissed, the user can click and drag around the PSD, to select a region of the PSD:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/psd4.jpg" />

Once an area is selected, the Creative SDK analyzes the PSD and determines which layers are covered by the user’s selection:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/psd5.jpg" />

Notice how layers are named and previews are provided. The user can scroll up to redraw his selection or search for a layer by name.

Finally, the user selects the layers with which he wants to work:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/assetbrowser/psd6.jpg" />

Clicking OPEN SELECTION causes the selected layer(s) to open.

Keep in mind that once the user selects a file and makes a request to either open it or extract layers, the subsequent UI is driven by the Creative SDK. We only have to ask the `AdobeUXAssetBrowser` to provide the feature.

    // Call the Asset Browser and pass the configuration options
    [[AdobeUXAssetBrowser sharedBrowser] popupFileBrowserWithParent:self configuration:configuration onSuccess:^(NSArray *itemSelections) {

    // Grab the last item that was selected.
    AdobeSelectionAsset *itemSelection = itemSelections.lastObject;

The rest is up to the developer. The onSuccess block of the file-browser API is passed pointers to the selected file and any selected layers. Here is that block of code:

    // Make sure it's a PSD file.
    if (IsAdobeSelectionAssetPSDFile(itemSelection))
    {
    // We know the selected item is a PSD file so we can safely cast it to the specific type.
    AdobeSelectionAssetPSDFile *psdSelection = (AdobeSelectionAssetPSDFile *)itemSelection;

    // Grab the actual Asset file instance.
    AdobeAssetPSDFile *psdFile = (AdobeAssetPSDFile *)psdSelection.selectedItem;

    // Also grab all the selected layers
    AdobePSDLayerSelectionArray *layerSelections = psdSelection.layerSelections;

    // Create a temporary location for the result string.
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"PSD File: %@\n\n", psdFile.name];

    // Keep a count of the selected layers.
    NSInteger selectedLayerCount = 1;

    // Iterate over all the selected layers and collection some useful data from each one.
    for (AdobeSelectionPSDLayer *selectedLayer in layerSelections)
    {
    AdobePSDLayerNode *layer = selectedLayer.layer;

    NSString *type = @"";

    switch (layer.type)
    {
    case AdobePSDLayerNodeTypeRGBPixels:
    {
    type = @"RGP";
    break;
    }
    case AdobePSDLayerNodeTypeSolidColor:
    {
    type = @"Solid color";
    break;
    }
    case AdobePSDLayerNodeTypeGroup:
    {
    type = @"Layer Group";
    break;
    }
    case AdobePSDLayerNodeTypeAdjustment:
    {
    type = @"Adjustment";
    break;
    }
    case AdobePSDLayerNodeTypeUnknown:
    {
    type = @"Unknown";
    break;
    }
    }

    [result appendFormat:@"Selected Layer: %li\nLayer name: %@\nType: %@\nLayer ID: %@\nLayer Index: %li\nVisible: %@\n\n", (long)selectedLayerCount, layer.name, type, layer.layerId, (long)layer.layerIndex, layer.visible ? @"Yes" : @"No"];

    selectedLayerCount++;
    }

    // Now display the result.
    self.resultTextView.text = result;
    }
    else
    {
    self.resultTextView.text = [NSString stringWithFormat:@"The select file '%@' is not a PSD file.", itemSelection.selectedItem.name];
    }

    } onError:^(NSError *error) {

    NSLog(@"An error occurred: %@", error);
    }];

The code begins by getting the selected file: that is the main thing passed to the success handler. From that we can use a Creative SDK method, `IsAdobeSelectionAssetPSDFile`, to see if the file is a PSD. (We double check this even though we used a filter previously.) Once the file is cast down to an `AdobeAssetPSDFile`, you can request the layer selections.

In our example project, we get the array and loop over it. We are given a set of properties for each layer, and appends these properties to a string that it is output to the application along with the image of the layer. (You could do more than just enumerate and list these layers; for instance, you could create image previews of them and rebuild an image with just the selected layers.)

You can do almost anything with the layers. Since the Creative SDK handles user prompts and break-up and analysis of the PSD file, your code is free to handle the result as desired. To experiment with this, try the sample application.

<a name="reference"></a>
## Class Reference

+ [AdobeAsset](/Classes/AdobeAsset.html)
+ [AdobeAssetFile](/Classes/AdobeAssetFile.html)
+ [AdobeAssetMIMETypeFilter](/Classes/AdobeAssetMIMETypeFilter.html)
+ [AdobeAssetPSDFile](/Classes/AdobeAssetPSDFile.html)
+ [AdobePSDLayerNode](/Classes/AdobePSDLayerNode.html)
+ [AdobeSelectionAsset](/Classes/AdobeSelectionAsset.html)
+ [AdobeSelectionAssetPSDFile](/Classes/AdobeSelectionAssetPSDFile.html)
+ [AdobeSelectionPSDLayer](/Classes/AdobeSelectionPSDLayer.html)
+ [AdobeUXAssetBrowser](/Classes/AdobeUXAssetBrowser.html)
+ [AdobeUXAssetBrowserConfiguration](/Classes/AdobeUXAssetBrowserConfiguration.html)
