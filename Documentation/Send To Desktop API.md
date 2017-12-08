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

This guide will assume that you have installed all software and completed all of the steps in the following guides:

*   Getting Started
*   Framework Dependencies

_**Note:**_

*   _This component requires that the user is **logged in with their Adobe ID**._
*   _Your Client ID must be [approved for **Production Mode** by Adobe](https://creativesdk.zendesk.com/hc/en-us/articles/204601215-How-to-complete-the-Production-Client-ID-Request) before you release your app._

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

+ AdobeSendToDesktopApplication
