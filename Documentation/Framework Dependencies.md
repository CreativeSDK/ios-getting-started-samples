# Framework Dependencies

In the Creative SDK for iOS, we've broken the Foundation framework into Micro frameworks so that developers can include only the pieces that they need, thereby reducing the size of their binary. The AdobeCreativeSDKFoundation framework has been divided into the following frameworks:

- AdobeCreativeSDKCore
- AdobeCreativeSDKCommonUX
- AdobeCreativeSDKAppLibraryUX
- AdobeCreativeSDKAssetModel
- AdobeCreativeSDKAssetUX
- AdobeCreativeSDKMarketUX

You can read more about the Framework breakup on our [blog](https://blog.creativesdk.com/2015/08/dividing-up-the-foundation-sdk/).

<a name="Migrating to Dynamic Frameworks"></a>
## Migrating to Dynamic Frameworks

The below steps assumes you are currently using static frameworks.

1. Select project file, in Build Phases, Link Binary with Libraries, remove all the AdobeCreativeSDK frameworks currently linked.
2. In Build Phases, Copy Bundle Resources, remove all the AdobeCreativeSDK bundles that are currently added.
3. Under General, Embedded Binaries, add the necessary AdobeCreativeSDK frameworks you need.
4. Under Build Settings, Framework Search Paths, make sure you have correct path to folders containing AdobeCreativeSDK frameworks.
5. For each Embedded framework you include, you will need to run the strip-frameworks shell script in order to remove the simulator slices and force a code resign on the frameworks.
In Build Phases, add a run script phase (if not present) and add the below line for each embedded AdobeCreativeSDK framework to run the strip-frameworks script.
bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/AdobeCreativeSDKCore.framework/strip-frameworks.sh"
![](images/strip-frameworks.png)

## Frameworks Overview

Below is a table that contains all of the Framework and header dependencies for each feature of the Creative SDK:

<table>
   <tbody>
      <tr>
         <th colspan="1">Feature</th>
         <th colspan="1">Framework</th>
         <th>Framework/Headers</th>
      </tr>
      <tr>
         <td colspan="1">Authentication</td>
         <td colspan="1">
            <a href="#core">AdobeCreativeSDKCore.framework</a>
         </td>
         <td colspan="1">
            AdobeCreativeSDKCore/AdobeCreativeSDKCore.h
         </td>
      </tr>
      <tr>
         <td colspan="1">Asset Browser UI Component</td>
         <td colspan="1">
            <a href="#core">AdobeCreativeSDKCore.framework</a>
            <br /><a href="#commonux">AdobeCreativeSDKCommonUX.framework</a>
            <br /><a href="#assetmodel">AdobeCreativeSDKAssetModel.framework</a>
            <br /><a href="#assetux">AdobeCreativeSDKAssetUX.framework</a>
         </td>
         <td colspan="1">
            AdobeCreativeSDKCore/AdobeCreativeSDKCore.h
            <br />AdobeCreativeSDKCommonUX/AdobeCreativeSDKCommonUX.h
            <br />AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h
            <br />AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h
         </td>
      </tr>
      <tr>
         <td colspan="1">Lightroom Upload UI Component</td>
         <td colspan="1">
            <a href="#core">AdobeCreativeSDKCore.framework</a>
            <br /><a href="#commonux">AdobeCreativeSDKCommonUX.framework</a>
            <br /><a href="#assetmodel">AdobeCreativeSDKAssetModel.framework</a>
            <br /><a href="#assetux">AdobeCreativeSDKAssetUX.framework</a>
         </td>
         <td>
            AdobeCreativeSDKCore/AdobeCreativeSDKCore.h
            <br />AdobeCreativeSDKCommonUX/AdobeCreativeSDKCommonUX.h
            <br />AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h
            <br />AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h
         </td>
      </tr>
      <tr>
         <td colspan="1">Creative Cloud Files API</td>
         <td colspan="1">
            <a href="#core">AdobeCreativeSDKCore.framework</a>
            <br /><a href="#commonux">AdobeCreativeSDKCommonUX.framework</a>
            <br /><a href="#assetmodel">AdobeCreativeSDKAssetModel.framework</a>
            <br /><a href="#assetux">AdobeCreativeSDKAssetUX.framework</a>
         </td>
         <td>
            AdobeCreativeSDKCore/AdobeCreativeSDKCore.h
            <br />AdobeCreativeSDKCommonUX/AdobeCreativeSDKCommonUX.h
            <br />AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h
            <br />AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h
         </td>
      </tr>
      <tr>
         <td colspan="1">Lightroom Photos API</td>
         <td colspan="1">
            <a href="#core">AdobeCreativeSDKCore.framework</a>
            <br /><a href="#commonux">AdobeCreativeSDKCommonUX.framework</a>
            <br /><a href="#assetmodel">AdobeCreativeSDKAssetModel.framework</a>
            <br /><a href="#assetux">AdobeCreativeSDKAssetUX.framework</a>
         </td>
         <td>
            AdobeCreativeSDKCore/AdobeCreativeSDKCore.h
            <br />AdobeCreativeSDKCommonUX/AdobeCreativeSDKCommonUX.h
            <br />AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h
            <br />AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h
         </td>
      </tr>
      <tr>
         <td colspan="1">Creative Cloud Libraries</td>
         <td colspan="1">
            <a href="#core">AdobeCreativeSDKCore.framework</a>
            <br /><a href="#assetmodel">AdobeCreativeSDKAssetModel.framework</a>
         </td>
         <td>
            AdobeCreativeSDKCore/AdobeCreativeSDKCore.h
            <br />AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h
         </td>
      </tr>
      <tr>
         <td>Share Menu UI Component</td>
         <td colspan="1">
            <a href="#core">AdobeCreativeSDKCore.framework</a>
            <br /><a href="#commonux">AdobeCreativeSDKCommonUX.framework</a>
            <br /><a href="#assetmodel">AdobeCreativeSDKAssetModel.framework</a>
            <br /><a href="#assetux">AdobeCreativeSDKAssetUX.framework</a>
            <br /><a href="#behance">AdobeCreativeSDKBehance.framework</a>
         </td>
         <td>
            AdobeCreativeSDKCore/AdobeCreativeSDKCore.h
            <br />AdobeCreativeSDKCommonUX/AdobeCreativeSDKCommonUX.h
            <br />AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h
            <br />AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h
            <br />AdobeCreativeSDKBehance/AdobePublishShareMenu.h
         </td>
      </tr>
      <tr>
         <td>Send To Desktop API</td>
         <td colspan="1">
            <a href="#core">AdobeCreativeSDKCore.framework</a>
            <br /><a href="#assetmodel">AdobeCreativeSDKAssetModel.framework</a>
         </td>
         <td>
            AdobeCreativeSDKCore/AdobeCreativeSDKCore.h
            <br />AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h
         </td>
      </tr>
      <tr>
         <td>Behance UI Component</td>
         <td colspan="1">
            <a href="#core">AdobeCreativeSDKCore.framework</a>
            <br /><a href="#core">AdobeCreativeSDKCommonUX.framework</a>
            <br /><a href="#assetmodel">AdobeCreativeSDKAssetModel.framework</a>
            <br /><a href="#assetux">AdobeCreativeSDKAssetUX.framework</a>
            <br /><a href="#behance">AdobeCreativeSDKBehance.framework</a>
            <br /><a href="#color">AdobeCreativeSDKColor.framework</a>
         </td>
         <td>
            AdobeCreativeSDKCore/AdobeCreativeSDKCore.h
            <br />AdobeCreativeSDKCommonUX/AdobeCreativeSDKCommonUX.h
            <br />AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h
            <br />AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h
            <br />AdobeCreativeSDKBehance/AdobePublish.h
            <br />AdobeCreativeSDKColor/AdobeCreativeSDKColor.h
         </td>
      </tr>
   </tbody>
</table>


## Individual Frameworks

The following section outlines the required setup for each part of the Creative SDK.

### Frameworks

+ [AdobeCreativeSDKCore](#core)
+ [AdobeCreativeSDKCommonUX](#commonux)
+ [AdobeCreativeSDKAppLibraryUX](#applibraryux)
+ [AdobeCreativeSDKAssetModel](#assetmodel)
+ [AdobeCreativeSDKAssetUX](#assetux)
+ [AdobeCreativeSDKMarketUX](#marketux)
+ [AdobeCreativeSDKColor](#color)
+ [AdobeCreativeSDKImage](#imageeditor)
+ [AdobeCreativeSDKBehance](#behance)
+ [AdobeCreativeSDKLabs](#labs)


<a name="core"></a>
### AdobeCreativeSDKCore

The following configuration settings are required for this framework:

1. Add -ObjC as a linker flag in Build Settings/Linking/Other Linker Flags.
2. In Build Phases, expand Copy Bundle Resources, click the + button, select "Add Other" and select AdobeCreativeSDKCore.bundle. This file may be found where you extracted the SDK at AdobeCreativeSDKCore.framework/Resources/AdobeCreativeSDKCoreResources.bundle.
3. In Build Phases, Link Binary with Libraries, add the AdobeCreativeSDKCore.framework folder.
4. In the same area, add the following libraries:
    + MobileCoreServices.framework
    + SystemConfiguration.framework
    + libc++.tbd
    + libsqlite3.0.tbd
    + libz.tbd
    + WebKit.framework
5. In Build Settings, Apple LLVM - Preprocessing, add *USE_CSDK_COMPONENTS* to the *Preprocessor Macros*.

<a name="commonux"></a>
### AdobeCreativeSDKCommonUX

The following configuration settings are required for this framework:

1. Add -ObjC as a linker flag in Build Settings/Linking/Other Linker Flags.
2. In Build Phases, expand Copy Bundle Resources, click the + button, select "Add Other" and select the following bundles:
    + AdobeCreativeSDKCore.framework/Resources/AdobeCreativeSDKCoreResources.bundle
    + AdobeCreativeSDKCommonUX.framework/Resources/AdobeCreativeSDKCommonUXResources.bundle
3. In Build Phases, Link Binary with Libraries, add the following:
    + AdobeCreativeSDKCore.framework
    + AdobeCreativeSDKCommonUX.framework
4. In the same area, add the following libraries:
    + MobileCoreServices.framework
    + SystemConfiguration.framework
    + libc++.tbd
    + libsqlite3.0.tbd
    + libz.tbd
    + WebKit.framework
5. In Build Settings, Apple LLVM - Preprocessing, add *USE_CSDK_COMPONENTS* to the *Preprocessor Macros*.

<a name="applibraryux"></a>
### AdobeCreativeSDKAppLibraryUX

The following configuration settings are required for this framework:

1. Add -ObjC as a linker flag in Build Settings/Linking/Other Linker Flags.
2. In Build Phases, expand Copy Bundle Resources, click the + button, select "Add Other" and select the following bundles:
    + AdobeCreativeSDKCore.framework/Resources/AdobeCreativeSDKCoreResources.bundle
    + AdobeCreativeSDKCommonUX.framework/Resources/AdobeCreativeSDKCommonUXResources.bundle
    + AdobeCreativeSDKAssetModel.framework/Resources/AdobeCreativeSDKAssetModelResources.bundle
    + AdobeCreativeSDKAppLibraryUX.framework/Resources/AdobeCreativeSDKAppLibraryUXResources.bundle
3. In Build Phases, Link Binary with Libraries, add the following:
    + AdobeCreativeSDKCore.framework
    + AdobeCreativeSDKCommonUX.framework
    + AdobeCreativeSDKAssetModel.framework
    + AdobeCreativeSDKAppLibraryUX.framework
4. In the same area, add the following libraries:
    + MobileCoreServices.framework
    + SystemConfiguration.framework
    + libc++.tbd
    + libsqlite3.0.tbd
    + libz.tbd
    + WebKit.framework
5. In Build Settings, Apple LLVM - Preprocessing, add *USE_CSDK_COMPONENTS* to the *Preprocessor Macros*.

<a name="assetmodel"></a>
### AdobeCreativeSDKAssetModel

The following configuration settings are required for this framework:

1. Add -ObjC as a linker flag in Build Settings/Linking/Other Linker Flags.
2. In Build Phases, expand Copy Bundle Resources, click the + button, select "Add Other" and select the following bundles:
    + AdobeCreativeSDKCore.framework/Resources/AdobeCreativeSDKCoreResources.bundle
    + AdobeCreativeSDKAssetModel.framework/Resources/AdobeCreativeSDKAssetModelResources.bundle
3. In Build Phases, Link Binary with Libraries, add the following:
    + AdobeCreativeSDKCore.framework
    + AdobeCreativeSDKAssetModel.framework
4. In the same area, add the following libraries:
    + MobileCoreServices.framework
    + SystemConfiguration.framework
    + libc++.tbd
    + libsqlite3.0.tbd
    + libz.tbd
    + WebKit.framework
5. In Build Settings, Apple LLVM - Preprocessing, add *USE_CSDK_COMPONENTS* to the *Preprocessor Macros*.

<a name="assetux"></a>
### AdobeCreativeSDKAssetUX

The following configuration settings are required for this framework:

1. Add -ObjC as a linker flag in Build Settings/Linking/Other Linker Flags.
2. In Build Phases, expand Copy Bundle Resources, click the + button, select "Add Other" and select the following bundles:
    + AdobeCreativeSDKCore.framework/Resources/AdobeCreativeSDKCoreResources.bundle
    + AdobeCreativeSDKCommonUX.framework/Resources/AdobeCreativeSDKCommonUXResources.bundle
    + AdobeCreativeSDKAssetModel.framework/Resources/AdobeCreativeSDKAssetModelResources.bundle
    + AdobeCreativeSDKAssetUX.framework/Resources/AdobeCreativeSDKAssetUXResources.bundle
3. In Build Phases, Link Binary with Libraries, add the following:
    + AdobeCreativeSDKAssetModel.framework
    + AdobeCreativeSDKAssetUX.framework
    + AdobeCreativeSDKCore.framework
    + AdobeCreativeSDKCommonUX.framework
4. In the same area, add the following libraries:
    + MobileCoreServices.framework
    + SystemConfiguration.framework
    + libc++.tbd
    + libsqlite3.0.tbd
    + libz.tbd
    + WebKit.framework
5. In Build Settings, Apple LLVM - Preprocessing, add *USE_CSDK_COMPONENTS* to the *Preprocessor Macros*.

<a name="marketux"></a>
### AdobeCreativeSDKMarketUX

The following configuration settings are required for this framework:

1. Add -ObjC as a linker flag in Build Settings/Linking/Other Linker Flags.
2. In Build Phases, expand Copy Bundle Resources, click the + button, select "Add Other" and select the following bundles:
    + AdobeCreativeSDKCore.framework/Resources/AdobeCreativeSDKCoreResources.bundle
    + AdobeCreativeSDKCommonUX.framework/Resources/AdobeCreativeSDKCommonUXResources.bundle
    + AdobeCreativeSDKAssetModel.framework/Resources/AdobeCreativeSDKAssetModelResources.bundle
    + AdobeCreativeSDKAssetUX.framework/Resources/AdobeCreativeSDKAssetUXResources.bundle
    + AdobeCreativeSDKMarketUX.framework/Resources/AdobeCreativeSDKMarketUXResources.bundle
3. In Build Phases, Link Binary with Libraries, add the following:
    + AdobeCreativeSDKAssetModel.framework
    + AdobeCreativeSDKAssetUX.framework
    + AdobeCreativeSDKCore.framework
    + AdobeCreativeSDKCommonUX.framework
    + AdobeCreativeSDKMarketUX.framework
4. In the same area, add the following libraries:
    + MobileCoreServices.framework
    + SystemConfiguration.framework
    + libc++.tbd
    + libsqlite3.0.tbd
    + libz.tbd
    + WebKit.framework
5. In Build Settings, Apple LLVM - Preprocessing, add *USE_CSDK_COMPONENTS* to the *Preprocessor Macros*.

<a name="color"></a>
### AdobeCreativeSDKColor

The following configuration settings are required for this framework:

1. Add -ObjC as a linker flag in Build Settings/Linking/Other Linker Flags.
2. In Build Phases, expand Copy Bundle Resources, click the + button, select "Add Other" and select the following bundles:
    + AdobeCreativeSDKCore.framework/Resources/AdobeCreativeSDKCoreResources.bundle
    + AdobeCreativeSDKAssetModel.framework/Resources/AdobeCreativeSDKAssetModelResources.bundle
    + AdobeCreativeSDKColor.framework/Resources/AdobeCreativeSDKColorResources.bundle
3. In Build Phases, Link Binary with Libraries, add the following:
    + AdobeCreativeSDKCore.framework
    + AdobeCreativeSDKAssetModel.framework
    + AdobeCreativeSDKColor.framework
5. In the same area, add the following libraries:
    + MobileCoreServices.framework
    + SystemConfiguration.framework
    + libc++.tbd
    + libsqlite3.0.tbd
    + libz.tbd
    + WebKit.framework
6. In Build Settings, Apple LLVM - Preprocessing, add *USE_CSDK_COMPONENTS* to the *Preprocessor Macros*.


<a name="imageeditor"></a>
### AdobeCreativeSDKImage

The following configuration settings are required for this framework:

1. Add -ObjC and -all_load as linker flags in Build Settings/Linking/Other Linker Flags.
2. In Build Phases, expand Copy Bundle Resources, click the + button, select "Add Other" and select the following bundles:
    + AdobeCreativeSDKCore.framework/Resources/AdobeCreativeSDKCoreResources.bundle
    + AdobeCreativeSDKImage.framework/Resources/AdobeCreativeSDKImageResources.bundle
3. In Build Phases, Link Binary with Libraries, add the following:
    + AdobeCreativeSDKCore.framework
    + AdobeCreativeSDKImage.framework
4. In the same area, add the following libraries:
    + Accelerate.framework
    + CoreData.framework
    + libsqlite3.0.tbd
    + libz.1.2.5.tbd
    + Foundation.framework
    + MessageUI.framework
    + OpenGLES.framework
    + QuartzCore.framework
    + StoreKit.framework
    + UIKit.framework
    + WebKit.framework
5. In Build Settings, Apple LLVM - Preprocessing, add *USE_CSDK_COMPONENTS* to the *Preprocessor Macros*.

<a name="behance"></a>
### AdobeCreativeSDKBehance

The following configuration settings are required for this framework:

1. Add -ObjC as a linker flag in Build Settings/Linking/Other Linker Flags.
2. In Build Phases, expand Copy Bundle Resources, click the + button, select "Add Other" and select the following bundles:
    + AdobeCreativeSDKCore.framework/Resources/AdobeCreativeSDKCoreResources.bundle
    + AdobeCreativeSDKCommonUX.framework/Resources/AdobeCreativeSDKCommonUXResources.bundle
    + AdobeCreativeSDKAssetModel.framework/Resources/AdobeCreativeSDKAssetModelResources.bundle
    + AdobeCreativeSDKAssetUX.framework/Resources/AdobeCreativeSDKAssetUXResources.bundle
    + AdobeCreativeSDKBehance.framework/Resources/AdobeCreativeSDKBehanceResources.bundle
    + AdobeCreativeSDKColor.framework/Resources/AdobeCreativeSDKColorResources.bundle
3. In Build Phases, Link Binary with Libraries, add the following:
    + AdobeCreativeSDKAssetModel.framework
    + AdobeCreativeSDKAssetUX.framework
    + AdobeCreativeSDKCore.framework
    + AdobeCreativeSDKCommonUX.framework
    + AdobeCreativeSDKBehance.framework
    + AdobeCreativeSDKColor.framework
4. In the same area, add the following libraries:
    + libc++.tbd
    + libsqlite3.0.tbd
    + libz.tbd
    + WebKit.framework
5. In Build Settings, Apple LLVM - Preprocessing, add *USE_CSDK_COMPONENTS* to the *Preprocessor Macros*.

<a name="labs"></a>
### AdobeCreativeSDKLabs

The following configuration settings are required for this framework:

1. Add -ObjC as a linker flag in Build Settings/Linking/Other Linker Flags.
2. In Build Phases, expand Copy Bundle Resources, click the + button, select "Add Other" and select the following bundles:
    + AdobeCreativeSDKCore.framework/Resources/AdobeCreativeSDKCoreResources.bundle
    + AdobeCreativeSDKLabs.framework/Resources/AdobeCreativeSDKLabsResources.bundle
3. In Build Phases, Link Binary with Libraries, add the following:
    + AdobeCreativeSDKCore.framework
    + AdobeCreativeSDKLabs.framework
4. In the same area, add the following libraries:
    + MobileCoreServices.framework
    + SystemConfiguration.framework
    + libc++.tbd
    + libsqlite3.0.tbd
    + libz.tbd
    + WebKit.framework
5. In Build Settings, Apple LLVM - Preprocessing, add *USE_CSDK_COMPONENTS* to the *Preprocessor Macros*.
