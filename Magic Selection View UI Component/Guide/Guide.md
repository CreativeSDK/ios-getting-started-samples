# Magic Selection View

**Disclaimer:** This Adobe Labs component is a beta product, and is provided with very limited support. As with all of our SDKs, feedback is welcome.

With magic-selection view, you can use our latest technology to identify and pull selected portions of an image out of the foreground.

*You can find the complete sample project for this guide in <a href="https://github.com/CreativeSDK/ios-getting-started-samples" target="_blank">GitHub</a>.*

## Contents

- [Prerequisites](#prerequisites)
- [Project Setup](#setup)
- [Integration](#integration)
- [Class Reference](#reference)

<a name="prerequisites"></a>
## Prerequisites

+ This guide assumes that you've already read the <a href="/articles/gettingstarted/index.html">Getting Started</a> guide.
+ For a complete list of framework dependencies, see the <a href="/articles/dependencies/index.html">Framework Dependencies</a> guide.

<a name="setup"></a>
## Project Setup
1. From the application project's Build Phases:
   + Add `AdobeCreativeSDKLabs.framework`, `AdobeCreativeSDKCore.framework`, and several dependent frameworks (see the screenshot below) to **Link Binary With Libraries**.
   + Add `AdobeCreativeSDKCoreResources.bundle` and `AdobeCreativeSDKLabsResources.bundle` to **Copy Bundle Resources**.<br/><img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/magicselection/Build_Phase.png"/>
2. Specify an iOS Deployment Target of **8.0** or greater: <br/><img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/magicselection/Deployment_Target.png" />
3. Add the **-ObjC** Other Linker Flag:<br/><img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/magicselection/Linker_Flag.png"/>

<a name="integration"></a>
## Integration

The `AdobeLabsUXMagicSelectionView` class has characteristics of both `UIScrollView` and `UIImageView`: it displays an image and lets you scroll and pan the image. You instantiate it, add it as a subview to your view, and call `setImage`:

    magicSelectionView = [[AdobeLabsUXMagicSelectionView alloc] 
      initWithFrame: self.view.bounds];
         [magicSelectionView setImage: myImage withCompletionBlock: myCompletionBlock];
         [self.view addSubview: magicSelectionView];

`setImage` is asynchronous and requires the use of a `completionBlock` for robust operation. See the [sample application](/downloads.html) for details.

Once the image is set, the magic selection view is ready to use. Here is the initial display of an image in magic-selection view:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/magicselection/Initial_Display.png"/>

Unlike with `UIScrollView`, here panning is done with two fingers. With magic-selection view, the single-finger gesture is for painting a magic selection:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/magicselection/Mark_Foreground.png" />

Once the selection is painted, you can extract the selected foreground from the image:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/magicselection/Extracted_Foreground.png" />

<a name="reference"></a>
## Class Reference

+ [AdobeLabsUXMagicSelectionView](/Classes/AdobeLabsUXMagicSelectionView.html)
