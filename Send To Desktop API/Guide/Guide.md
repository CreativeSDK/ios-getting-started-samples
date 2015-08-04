# Send To Desktop API

The Creative SDK provides a simple way for your mobile users to directly open assets on their desktop machines from the application itself. In this guide, we look at how this is done and how you can connect your mobile application to the full power of Creative Cloud on the desktop.

You can specify which application to open with the shared data. Three applications support this feature: Photoshop, Illustrator, and InDesign.

## Contents

- [Prerequisites](#prerequisites)
- [Project Setup](#setup)
- [Integration](#integration)
- [Class Reference](#reference)

<a name="prerequisites"></a>
## Prerequisites

+ This guide assumes that you've already read the <a href="/articles/gettingstarted/index.html">Getting Started</a> guide.
+ For a complete list of framework dependencies, see the <a href="/articles/dependencies/index.html">Framework Dependencies</a> guide.

<a name="integration"></a>
## Integration

`AdobeSendToDesktopApplication` enables you to send an asset to the desktop directly. Here is an example that takes a `UIImage` object, saves it as "SendToDesktopImage.jpg", and launches Photoshop on a user's desktop with the specified image.

    [AdobeSendToDesktopApplication sendImage:img 
                               toApplication:AdobePhotoshopCreativeCloud
                                    withName:@"SendToDesktopImage.jpg" 
                                   onSuccess:^{
                                             NSLog(@"opened in Photoshop");
                               }  onProgress: nil
                              onCancellation: nil
                                     onError:^(NSError *error) {
                                             NSLog(@"error: %@", error);
                                }];

`AdobeSendToDesktopApplication` supports the following launch types:

+ `sendAsset:` - Launch with an Asset that already exists in the Creative Cloud.
+ `sendData:` - Launch with an NSData object.
+ `sendImage:` - Launch with a UIImage object.
+ `sendLocalFile:` - Launch with a file stored locally on the device.

You can read more about these options in the `AdobeSendToDesktopApplication` class reference.

<a name="reference"></a>
## Class Reference

+ [AdobeSendToDesktopApplication](/Classes/AdobeSendToDesktopApplication.html)
