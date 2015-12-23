# Creative Cloud Files API

In addition to the [Asset Browser UI Component](/articles/assetbrowser/index.html), the Creative SDK provides headless APIs for accessing Creative Cloud files directly. This guide demonstrates how to use these APIs to download existing files in the Creative Cloud and upload new files to the Creative Cloud.

## Contents

- [Prerequisites](#prerequisites)
- [Access Files in the Creative Cloud](#access)
- [Upload Files to the Creative Cloud](#upload)
- [Class Reference](#reference)

<a name="prerequisites"></a>
## Prerequisites

+ This guide assumes that you've already read the <a href="/articles/gettingstarted/index.html">Getting Started</a> guide and have implemented Auth.
+ For a complete list of framework dependencies, see the <a href="/articles/dependencies/index.html">Framework Dependencies</a> guide.

<a name="access"></a>
## Accessing Files in the Creative Cloud

See below for a list of Classes for accessing Creative Cloud Files with our headless API:

+ [AdobeAssetFile](/Classes/AdobeAssetFile.html)
+ [AdobeAssetFolder](/Classes/AdobeAssetFolder.html)

<a name="upload"></a>
## Upload Files to the Creative Cloud

*You can find the complete sample project for this guide in <a href="https://github.com/CreativeSDK/ios-getting-started-samples" target="_blank">GitHub</a>.*

In this application, we send files to the user's Creative Cloud file storage.

### UI

We use a simple **Login** button on top, with a button below it (in this case, called **Upload Photo**) that is activated after the user logs in. This button works with new photos or ones in the user’s gallery. (This means you can run the code on the iOS simulator if desired.)

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/files/06.jpg"/>

As soon as this is done, the application begins to upload the file. Once the upload completes, an alert is displayed to let the user know what happened:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/files/08.jpg"/>

In a few seconds, the file (named) is available with the rest of the files the user has on the Creative Cloud. (In this example, new photos are named test.jpg or test.png.) To confirm this, login to Creative Cloud from any Creative Cloud connected app or visit [creative.adobe.com](http://creative.adobe.com) and check from the **Files** tab.

### Code

Here is the event handler for clicking the upload button from the device:

    + (void)uploadPhoto
    {
        UIImagePickerController *selImage = [UIImagePickerController new];
       
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            selImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else
        {
            selImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        selImage.delegate = self;
        
        [self presentViewController:selImage animated:YES completion:nil];
    }

We start the image-picker control, defaulting to the camera if the device supports it; otherwise, we use the photo library. (Tip: If you are testing with the simulator, your gallery may be empty. Go to any Web page, long-click on an image, and you can save that image to the simulator. Then the image will appear in the gallery.)

After an image is selected, this code runs:

    + (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
    {
        NSLog(@"%@", info);
        NSURL *path = info[UIImagePickerControllerReferenceURL];
        
        NSString *stringURL = [path absoluteString];
        NSLog(@"stringurl %@", stringURL);
        
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        [((RKCView *)self.view) selectedImgView].image = img;
        
        // convert to jpeg
        NSData *imgData = UIImageJPEGRepresentation( img, 0.8f );
        
        __block NSString *dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"foo.jpg"];
        NSURL* dataURL = [NSURL fileURLWithPath: dataPath];
        
        NSError* err;
        BOOL success = [imgData writeToFile:dataPath options:NSDataWritingAtomic error:&err];
        
        if (success)
        {
            AdobeAssetFolder *root = [AdobeAssetFolder getRootOrderedByField:AdobeAssetFolderOrderByName
                                                              orderDirection:AdobeAssetFolderOrderDescending];
            
            [AdobeAssetFile create:@"foo.jpg" 
                          inFolder:root
                      withDataPath:dataURL
                          withType:kMimeTypeJPEG
               withCollisionPolicy:AdobeAssetFileCollisionPolicyAppendUniqueNumber
                        onProgress:^(double fractionCompleted) {
                            NSLog(@"Percent complete %f", fractionCompleted);
                        }
                      onCompletion:^(AdobeAssetFile *file) {
                          NSLog(@"I DID IT!");
                          
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File Uploaded"
                                                                          message:@"Your file was uploaded!"
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                          [alert show];
                      }
                    onCancellation:NULL
                           onError:^(NSError *error) {
                               NSLog(@"error uploading %@", error);
                           }];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }

The handler is passed a dictionary of information, including the image’s location. From that, we create a temporary copy as a JPG file. We use a filename of foo.jpg; this will be important in a minute.

Next, we use the `getRootOrderedByField` method of the `AdobeAssetFolder` class. This provides a simple object representing the root of the user's Creative Cloud files folder. Typically, an application will want to work within a subdirectory. The API supports either overwriting an existing file or creating a new filename by appending a unique number. We used the latter option, so if you run this multiple times with different images, they will not overwrite each other.

We use the create method of the `AdobeAssetFile` class. We pass the folder, data path, and type, and define various event handlers. If you run the code in Xcode, you can follow the progress in the log view, but your application also could use this with a slider or other UI.

Finally, a `UIAlertView` is presented to let the user know the file was uploaded.

<a name="reference"></a>
## Class Reference

+ [AdobeAssetFile](/Classes/AdobeAssetFile.html)
+ [AdobeAssetFolder](/Classes/AdobeAssetFolder.html)
