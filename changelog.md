# Creative SDK v3.0.2218
(Dynamic Frameworks)
November 27, 2017

To download the Creative SDK for iOS, visit the [Adobe I/O Downloads Console](https://console.adobe.io/downloads).

## What's New

- Supports iPhone X.
- Creative SDK frameworks are now built and archived using Xcode 9.0.
- Deployment target in Creative SDK frameworks are now set to iOS 10.0.
- The following CSDK frameworks are no longer supported:
    - Color
    - MarketUX
    - Image
    - Labs
- Creative SDK static frameworks have been removed.

### Foundation

- Asset Model
    - Fixed the length overwriting bug in the refresh: method. Now correct value is reported for the fileSize property of AdobeAssetFile on performing a refresh method call.
    - Implemented support for rendition links.
    Added methods for copying and moving (and renaming) AdobeAssetFile and AdobeAssetFolder instances. These methods can be used to copy and move such assets within the Creative Cloud storage space. The move methods also provide the ability to rename an existing asset. Note: Nullability specifiers are present for both copy and move methods but they are commented out. These specifiers are valid and present the correct state. They are commented out since adding nullability specifiers for the other methods in AdobeAssetFile and AdobeAssetFolder was out of scope for this release.
    - New Version of downloadRendition APIs. Now it is possible to specify the version of the AdobeAssetFile to fetch using the new version parameter. If you want to get the latest, using this API (this is equivalent to using the unversioned API) use AdobeAssetFileVersionLatest otherwise specify the version number, in the parameter. AdobeAssetFile also gets the currentVersion, which may be different than the latest. Previously this value was not correct. If you want this you should use the asset.currentVersion api and pass that to the rendition fetch API.
    - A new headless API has been added for reading and extracting layer renditions from a PSD file. The newly added classes have a prefix of "AdobePhotoshop" and are going to replace the old, and now-deprecated, "PSD Composite" method of accessing and exploring PSD files. These classes provide read-only access for now.
    The starting point is AdobePhotoshopReader which can be instantiated from an AdobeAssetPSDFile. Assuming an AdobeAssetPSDFile object exists, calling the photoshopReaderWithSuccessBlock:cancellationBlock:errorBlock:method will return a usable AdobePhotoshopReader instance that can be used to explore all the layers and Layer Comps within the corresponding PSD file.
    Each layer in the PSD file is represented by the AdobePhotoshopLayer class. Many layer types, and several properties per each layer type, are currently presented. Note that the list of properties is not exhaustive. Only the most commonly used properties for each layer type is present.
- Asset Browser
    - Added support for displaying and selecting Motion Graphics Templates Library Elements in the Libraries datasource.
    - Added a new mime type kAdobeMimeTypeAdobeXDProject for XD projects.
- Asset Uploader
    - Added support for displaying Motion Graphics Templates Library Elements in the Libraries datasource.
- App Library
    - Bugfix: Fixed an issue with the App Library on iOS 11 where the In-App Store Sheet would display two spinners while the app details was loading.
- Authentication
    - Removed public API setAuthenticationParametersWithClientID:clientSecret:enableSignUp:.
    - Fixed a rare crash when IMS has a critical system outage.

### Typekit

Prevent a set of special characters from being input in Sample Text field on Asian Font tab.
Various bug fixes.

### Behance

- Added: Created AdobePublishToolGallery to represent an Adobe Creative Tools gallery.
- Added: Created AdobePublishToolGalleryContent and AdobePublishCuratedGalleryContent to represent the content of an Adobe Creative Tools gallery and curated gallery.
- Change: Image Editing through AdobeCreativeSDKImage from the project publishing workflow has been removed.
- Drag and Drop headers have Project visibility.
- Project Publishing: Facebook and Twitter sharing is no longer supported at the time of publish. Instead, projects can be shared from the viewer using the OS share sheet after publishing a project. As a result, setting a facebookAppId is also no longer supported.
- Fixed: Fixed bug where app crashes if input characters with Japanese or Chinese keyboard in text box.
- Added: Collections API method allowing clients to retrieve co-owners who are pending (have not yet accepted an invite).
- Added: The Project Editor now includes placeholders for audio modules.
- Added: Users can now remove themselves from project credits in the project info popup, or via a new API call on AdobePublishProject.
- Fixed: Fixed an issue loading some iCloud-backed photos in the project editor.
- Bug fix for "View on Behance" button does not work on addding image from CC or camera in Behance publish screen.
- Added: Project API to un-appreciate a previously appreciated project.
- Added: Comments now include linked usernames when users are @-mentioned in a comment.
- Fixed: Project embed modules appearing zoomed rather than conforming to their display size.

## Known Issues

###Foundation

- Adobe Universal Search is unsupported.
- Sending a large file to desktop may fail.
- The caching mechanism provided by the CSDK doesn't work on iOS 10.x Simulators if no Capabilities are enabled.
- The only way to work around this problem is to have an entitlement.plist file. The existence of this file forces Xcode and the Simulator to behave correctly. Note that if an existing Keychain Sharing capability is enabled, this issue won't appear.

### iOS Support

- Creative SDK supports iOS 11 and iOS 10.
- This Creative SDK release was validated on iOS 11.0.3 and iOS 10.3.3.

***

# Creative SDK v0.15.2181.1
(Dynamic Frameworks)
December 6th, 2016

## General

- Bitcode is now fully supported in the Dynamic iOS framework.

## Typekit

- Added Japanese fonts back in the Font Browser for use with API Key.


# Creative SDK v0.15.2181
(Dynamic Frameworks)
November 2, 2016

**IMPORTANT:**
If you are updating to v0.15 and above, you will need to register a new API Key, Secret and redirectURL from the new [Adobe I/O Console](https://console.adobe.io/integrations).

## General

- The Static framework in v0.15.2181 is the last static frameworks release.  We will only release the dynamic frameworks in the next release. You can learn more about Dynamic Frameworks [here](https://creativesdk.zendesk.com/hc/en-us/articles/212156866).
- Authentication now requires a new unique redirect URL.  Instead of the previous ClientID/Secret authentication, the new authentication requires new API Key, Secret, the unique redirectURL and the scopes needed for the integration.  New API Key, secret and redirectURL can be generated and then add the scopes using the new [Adobe I/O Console](https://console.adobe.io/integrations).  More integration related information can be found on the Getting Started Guide and in the API reference for `AdobeUXAuthManager`.
- The 3 scopes basic are required for apps that uses the API Key authentication. More information on scopes can be found on the Getting Started Guide and in the API reference for `AdobeUXAuthManager`.
        - `[AdobeUXAuthManager setAuthenticationParametersWithClientID:clientSecret:additionalScopeList:].AdobeAuthManagerUserProfileScope, AdobeAuthManagerEmailScope, AdobeAuthManagerAddressScope`
- Library dependency changed from libsqlite.tbd to libsqlite3.tbd.
- Removed the support for iOS8. iOS 9 is now the lowest version of iOS supported by the SDK.
- Adds [AdobeUXAuthManager openContinuableAuthenticationURLForError:] to the public API. This method takes the error code made available to the application on the detectedContinuableAuthenticationEvent delegate call.
- New tintColor property is added to customization of the primary and user-actionable controls of the SDK. This property can be used to bring the appearance of the SDK UI component closer to an app's chosen tint color from the following configuration:
    - `AdobeUXAssetUploaderConfiguration`
    - `AdobeUXAppLibraryBrowserConfiguration`
    - `AdobeUXMarketBrowserConfiguration`
    - `AdobeUXStockBrowserConfiguration`
    - `AdobeUXStockContributorConfiguration`
- Known Issue:
    - Bitcode is not fully supported in the Dynamic iOS framework.  We are planning to add the bitcode support before the next major release.
    - Core Data concurrency is not supported.  The app will crash when Core Data concurrency checking is enabled.
        - `e.g. When “-com.apple.CoreData.ConcurrencyDebug 1” is added to the app run argument.`


## Asset Browser

- New asset types Materials, Lights and Animations have been added to Asset Library in Creative Cloud.
- AdobeDesignLibraryModelType is the new type for 3D element.  It is replacing the deprecated AdobeDesignLibrary3DElementType.
- kAdobeMimeTypeIllustrator now refers to application/vnd.adobe.illustrator rather than the typeapplication/illustrator. The old type is defined by kAdobeMimeTypeIllustratorLegacy. In order to support backward compatibility, the Asset Browser returns both types of ai files when the filter includes kAdobeMimeTypeIllustrator orkAdobeMimeTypeIllustratorLegacy.
- Added openURL:completion:  to match the signature with UIApplicationDelegate API for in-app purchase.  This should be used, instead of the deprecated -handleOpenURL:fromApplication:withCompletion: method.
- Added a new API in AdobeUXAuthManager to disable event generation sendUsageData:completion:.
- Fixed a bug with AdobeAssetFolder (and all subclasses) nextPage where the value returned in the success block for the totalItemsInFolder was incorrectly reporting the total number  of items in the folder, but instead was reporting the count of items in the returned array. If you were relying on totalItemsInFolder for the number of items in the returned array, change to use items.Count instead.

## Behance

- Dependency Changed. AdobeCreativeSDKBehance is now dependent on AdobeCreativeSDKColor.
- The Accent Color of all AdobeCreativeSDKBehance UI components using the accentColor property of the AdobePublish shared Instance can now be customized.
- New Project Editor is added to make project editing easier. E.g. Background color of projects can be changed by double tapping the project canvas
- The initial position of the new image-picker drawer can now be customized via ‘initialDrawerStateOption’ in ‘AdobePublishProjectSpecs’.
- Existing project can now be edited by providing a ‘projectId’ to ‘AdobePublishProjectSpecs’.
- AdobePublishUser now has an isAvatarDefault property to indicate if a user has not customized their avatar
- Validation is added for links added to projects through the Publishing component.
- Higher image resolution version of the image is used in the Project Viewer for iPad and larger iPhones.
- Image editor icon will no longer show up when AdobeCreativeSDKImage framework is not included in the project.
- Fixed the lock up issue when user using the camera in the Edit Profile controller.
- Fixed the crash issue when accessing the camera and camera roll assets through the Publishing component.
- Fixed the navigation bar layout issue when the Publishing component re-opened after it failed to upload.
- Improved the text styles in the Publishing component to better align with Behance.net (for default text and image captions).
- AdobePublishCuratedGallery has been split to AdobePublishPartnerGallery and AdobePublishCuratedGallery which are both subclasses of AdobePublishGallery. Added public interfaces for these classes and added APIs as well.
- WIP is no longer supported.  All WIP related APIs have now been removed.

## Image Editor

- Improved runtime stability.

## Typekit

- Added support for Typekit platform service. No API is changed, however, the back end is changed to point to the new TK platform service which doesn't require user authentication to browse fonts and provides access to more new fonts. As bundled fonts in an app must comply with the new Typekit platform formats, clients that provide bundled fonts in their apps need to update their bundled fonts. Please see projects on the sample project on [Github](https://github.com/CreativeSDK/ios-getting-started-samples) for more details.
- Added symbols for Typekit platform and User Consent scopes. User Consent scopes are needed for use with API Key.  The 5 scopes needed for apps that use the new Typekit platform service are as follow:
  ```
  [AdobeUXAuthManager setAuthenticationParametersWithClientID:clientSecret:additionalScopeList:].AdobeAuthManagerUserProfileScope, AdobeAuthManagerEmailScope, AdobeAuthManagerAddressScope,AdobeAuthManagerTypekitPlatformScope, AdobeAuthManagerTypekitPlatformSyncScope
  ```
- Typekit service is re-enabled after a token refresh is triggered by an interruptive event such as accepting an updated Terms Of Use.
- Known Issues:
    - Japanese fonts are temporarily unavailable as one of the fonts in the Font Browser for new API Key. We are going to add the Japanese fonts for API Key as soon as its development is completed, possibly before the next major release.
    - Users with large synced font list may not be able to see all the synced font data due to the limit of pagination when synced font request is called.
    - The sync status may not shown accurately. Please re-sync the font to correct its sync status.
    - An entire character set of the selected font may not be applied immediately after the font is synced. Please re-select the font to re-apply.


# Creative SDK v0.14.2160
(Dynamic Frameworks)
September 1, 2016

## General

- Static frameworks have been deprecated in favor of new dynamic frameworks. You can learn more about Dynamic Frameworks [here](https://creativesdk.zendesk.com/hc/en-us/articles/212156866).


# Creative SDK v0.14.2160
August 2, 2016

## General

- Landscape support added for all UI components.
- Apps calling `AdobeUXAuthManager setAuthenticationParametersWithClientID:withClientSecret:` have their login period extended from two weeks to six months.
- The USE_CSDK_COMPONENTS pre-processor directive is no longer a requirement and can be removed.
- Adds Terms Of Use (TOU) and email verification support.
- Adds [AdobeUXAuthManager openContinuableAuthenticationURLForError:]w to the public API. This method takes the error code made available to the application on the detectedContinuableAuthenticationEvent delegate call.

## Asset Browser

- AdobeUXAssetBrowserConfiguration has a new property tintColor,  which allows the calling app to customize the tint color of the primary and user-actionable controls of the SDK. This property can be used to bring the appearance of the SDK UI component closer to an app's chosen tint color.
- Adds UI support for bookmarks (Live Library Links), read-only design libraries.
- Adds UI support for Paragraph Style Library elements.
- New pull-to-refresh support in Library element view.
- Metadata used to be missing in manually constructed AdobeAssetFolders. We've added a 'refresh' method on the AdobeAssetFolder object (to mirror what is already done on AdobeAssetFile) that will pull the latest metadata for the folder object. If you are using an AdobeAssetFolder object for folder listing, a refresh is not needed. Note: if an AdobeAssetFolder is returned as part of a folder listing, it will have the current metadata at the time of the listing.
- Deprecated AdobeAssetLibraryItem and all its derived classes.
- Deprecated AdobePSDPreview, AdobePSDPreviewLayerNode and AdobePSDPreviewLayerComp. The AdobePSDPreview now represents the PSD manifest with applied comp layer if any. New APIs will be added for PSD extraction in the near future.

## Behance

- User data returned by PPS will now fall back to IMS data for fields which are blank for: firstName, lastName, displayName, country.
- Project Viewer: Memory usage for loading animated GIFs has been improved.
- AdobePublishWIPConversion added to determine the conversion status of a work in progress into a project.
- The AdobePublishShareMenu component has been removed.
- Project Viewer: comments and commenting will be hidden if the project owner has disallowed comments on their project on Behance.net

## Color Tool

- Color component now has a base indicator on the theme swatch and the wheel marker in Picker view.  No change in Single color mode.
- Color component library selection now shows bookmarks. Saving to bookmarks is disabled.

## Image Editor

- Adobe ID sign for users to access and sync more free Effects, Stickers, Frames and Overlays.

## Typekit

- Initial release!
- Features:
    - Great onboarding and sign in experience.
    - Ability to search fonts.
    - Ability to sync font and download them to the device.



***

# Creative SDK v0.13.2139
March 3, 2016

## General

- armv7s frameworks are not included anymore.  Building for armv7s devices (iPhone 5/5c and iPad (4th generation)) now requires targeting armv7 and using the armv7 frameworks in Xcode 6 or later.
- AdobeCreativeSDKCore.framework Upgraded to WKWebView.  Apps need to link to WebKit.framework, in your project's target Build Phases, Link Binary with Libraries.
- The following frameworks now contain Asset Catalogs: AdobeCreativeSDKAppLibraryUX, AdobeCreativeSDKAssetUX, AdobeCreativeSDKColor, AdobeCreativeSDKCommonUX, AdobeCreativeSDKCore and AdobeCreativeSDKMarketUX.
.New, more granular error codes for network connections related to endpoint resolution.
Known Issues:
- Creative Cloud Market assets are not downloaded from Market Browser on iOS 8.1 and 8.2. Copy an asset to Creative Cloud Libraries or Creative Cloud Files in Market Browser, then download the asset from Asset Browser.

## App Library

- App Library GET/OPEN button renamed to "LAUNCH" on iOS 9. We launch the app if it's already installed else we show the Store Kit UI.
- Deprecated AdobeUXAppLibrary in favor of the new UIViewController-based API: AdobeUXAppLibraryBrowserViewController. Please see AdobeUXAppLibraryBrowserViewController.h in AdobeCreativeSDKAppLibrary.framework for more details.

## Asset UX

- Added support for 3D Elements in libraries. All existing APIs that handle library assets are now aware of 3D Elements can work with such assets.
- Added support for video assets in libraries. This includes all the related APIs for downloading a rendition or the linked video file from the Stock servers. Note that currently the only supported video asset in a library on the server is videos added through the Stock web interface.
- The PSD Extraction is now supported on iPhone.  The workflow has been updated to use Size Classes, to support iOS9 split view.
- Photo Browser: the default photo view is now "All Photos." It can be toggled to "View Collections" using the more (...) button.
- Ability to multi-select LR Photos
- The Looks/Patterns captured from Adobe Capture app can now be accessed in Creative Cloud Libraries. Looks/Patterns can now be viewed and opened like other already supported assets in the libraries. Support includes full API access to the rendition in addition to the file itself.
- The data transfer APIs for AdobeAssetFile now returns an AdobeAssetAsyncRequest object which can be used to re-prioritized or cancelled. This will allow for multiple streams of transfer without losing the ability to make changes.
- Deprecated AdobeUXAssetBrowser in favor of new, UIViewController-based API: AdobeUXAssetBrowserViewController. Please see AdobeUXAssetBrowserViewController.h in AdobeCreativeSDKAssetUX.framework for more details.
- Deprecated and modified AdobeUXAuthManager setAuthenticationParametersWithClientID:clientSecret:enableSignUp:. Both this andsetAuthenticationParametersWithClientID:withClientSecret: always allow user sign-up. The enableSignUpargument is ignored.
- The AdobeAsset APIs (AdobeAsset, AdobeAssetFile, AdobeAssetFolder, AdobeAssetPackage) have been moved (with deprecations) to use the newer API signatures.

## Behance

- The Assets Library Framework has been removed as a dependency of the AdobeCreativeSDKBehance component.
- Audio and Video files will no longer appear as selectable assets in the image picker.
- Profile Editor: Added the ability to delete an avatar without providing a replacement.
- Project Publish: The project publishing workflow and API's' now includes the ability to specify that project images should be shown as full-width
- Fixed an issue where long album names could overlap navigation buttons in the image picker.
- WIP Publishing/WIP Viewing has been deprecated and will be removed in a future version of the SDK. Please migrate to Projects if appropriate for your app.
- AdobePublishShareMenu has been deprecated and will be removed in a future version of the SDK.

## Color Tool

- AdobeCreativeSDKColorComponent.framework is renamed to AdobeCreativeSDKColor.framework.
- AdobeColorPickerControllerDelegate has a new optional API colorPickerControllerDidCancel, this is called from AdobeColorViewController when the Cancel button is hit.
- Always enable save to library button.

## Image

- Users can now log in with their Adobe ID to sync their content. This is optional and only available to approved partners. Interested partners can [learn more](https://creativesdk.zendesk.com/hc/en-us/articles/207914166) about content sync!
- Added nullability annotations for improved Swift integration

## Market UX

- Users can browse market assets without sign in into creative cloud account.
- Users will be prompted to login when they try to download assets/add-to-library.
- Deprecated AdobeUXMarketAssetBrowser in favor of the new UIViewController-based class: AdobeUXMarketBrowserViewController. Now the Market Browser can be presented like a normal UIViewController subclass as is the norm with almost all Apple-provided view controllers in iOS. Please see the documentations for AdobeUXMarketBrowserViewController for more information.


***

Adobe Labs SDK v0.3
January 25, 2016

## General

- Introduces the AdobeLabsMagicMusicRetargeting component.
- Re-enables BITCODE.
- Dramatically reduces the size of the binary.


***

# Creative SDK v0.12.2127.02
December 09, 2015

**Important:** If you are updating from SDK version v0.12.2127.01 or older, you will need to register a new Client ID and Secret on the [Adobe I/O Console](https://console.adobe.io/integrations).


## Image Editor UI Component

- Fixes minor issue with imaging compositing.


***

Adobe Labs SDK v0.2
November 24, 2015

## General

- New: AdobeLabsMagicVectorizer - converts a raster UIImage into UIBezierPath.
- New: MagicDepthMapper - creates a depth map from a UIImage.
- New: MagicCutoutMaker - automatically cuts out salient portions of an image.
- New: MagicBrush - simulate real world objects like crayons and play-doh as brushes.
- New: MagicStyle - make one image match the style of another image.


***

# Creative SDK v0.12.2127.01
November 12, 2015

## Image Editor UI Component

- Miscellaneous bug fixes.


***

# Creative SDK v0.12.2127
October 29, 2015

## General

- Added iOS 9 and Bitcode support.
- Deprecated support for iOS versions prior to iOS8.1.
- Various bug fixes.
Known Issues:
- In the App Library, the app description is not localized.
- Creative Cloud Market assets are not downloaded from Market Browser on iOS 8.1 and 8.2. Copy an asset to Creative Cloud Libraries or Creative Cloud Files in Market Browser, then download the asset from Asset Browser.

## Behance

- All components now fully support iPad Slide Over and Split View.
- A new asset chooser has been introduced in the Project Publishing component that takes advantage of Photos.framework.
- Project Viewer now includes support for non-flash based CCV Video and Audio embeds.
- Project/WIP Publishing: Now enforce file size limits of 12MB per image for publishing projects and WIPs on the client side.
- SDWebImage dependency has been updated which includes a number of bug fixes for image loading.
- Comment Panel: AdobePublishCommentPanel has been removed.

## Color Tool UI Component

- Color chip view to show selected color (iPad).
- The color history view has been moved into a separate picker, and because of that, it can be enabled and set as the initial picker value like the wheel, RGB, or CMYK views.
- Refer to 'currentPickerTypes' and 'initialPickerType' in 'AdobeColorViewController.h' for more information.
- Because the title bar is now based on traits and presentation modes, and integrating applications may want to override the navigation bar, we have exported two methods that perform the same behavior as the Done and Cancel buttons during the color component's default behavior. These are:
    ·'(void)cancelChanges;' - Performs the same operations as selecting the Cancel button will perform if the color controller manages the navigation bar. This routine is useful for clients that implement their own navigation/title bar for the color component.
    ·'(void)commitChanges;' - Performs the same operations as selecting the Done button will perform if the color controller manages the navigation bar. This routine is useful for clients that implement their own navigation/title bar for the color component.
    ·'(void)setShowTitleHeader:(BOOL)showHeader;' - Sets whether to show the title header on both iPad and iPhone. This is useful if the clients want to insert their own tile/navigation bar. YES by default.


## Image

- Added HTTPS support to all network requests.
- Revamped and refined the look and feel of the editor.
- The editor customizer app has been improved to reflect the new UI.
- The resource bundle has been reduced in size.


***

# Creative SDK v0.11.2118.02
October 19, 2015

## Adobe Labs

- New Features:
    - AdobeLabsMagicAudioSpeechMatcher
    - AdobeLabsMagicCropper
    - AdobeLabsMagicCurve
    - AdobeLabsMagicPath
    - AdobeLabsUXMagicPerspectiveView



***


# Creative SDK v0.11.2118.01
September 15, 2015

## General

- Fixes an issue related to iTunes Connect validation.


***


# Creative SDK v0.11.2118
August 6, 2015

## General

- The monolithic Foundation SDK has been broken up into six smaller SDKs. Existing developers should read the [Framework Breakup Migration Guide](https://creativesdk.zendesk.com/hc/en-us/articles/205019329) for more details. Below is a list of the new Frameworks:
    - AdobeCreativeSDKCore
    - AdobeCreativeSDKCommonUX
    - AdobeCreativeSDKAppLibraryUX
    - AdobeCreativeSDKAssetModel
    - AdobeCreativeSDKAssetUX
    - AdobeCreativeSDKMarketUX


## AssetBrowser UI Component

- Better empty/no file screen for Mobile Creations.
- Improved handling of library item selections in the Asset Browser:
    - No longer automatically filtering out brushes, character styles, or layout styles.
    - Added the library ID to the returned library selection info.
    - Fixed rounding issues with displaying colors or color hex values as names in certain situations.
    - Removed deprecated color properties/methods.


## App Library UI Component

- The App Library has been redesigned with new sort options and catgegory/subcategory filters.
    - The categories expand to show subcategories when there are a significant number of apps under the category.
    - Existing category filter & sort option APIs are deprecated.


## Behance Component

- Improved the stability of the Edit Profile component when it hide the status bar while opening the camera capture screen.
- The Edit Profile component's profileEditDidStart delegate method has been removed.
- The profileEditDidFail:, projectPublishDidFail:, projectLoadDidFail:, wipPublishDidFail:, wipLoadDidFail: delegate methods will all be called now in the case where shouldShowNetworkConnectionErrorAndCancel returns true and a workflow is cancelled early to do a lack of network connectivity.
- Fixed a potential crash in the project viewer for users who have mature content blocked.
- Fixed potential lag in the camera capture view used in publishing and edit profile components due to UI changes being made on a background thread.
- Fixed rotation issues in the camera capture view used in publishing and edit profile components.
- AdobePublishProject has a new containsFullBleedImages method to determine whether a project takes advantage of Behance's full bleed image feature.

## Color Tool UI Component

- Fixed the inconsistency in the initialization variables on AdobeColorViewController. Now, initialColorPickerView and initialColorPickerType are used only to setup the initial state and aren't changed by the component. We now return the current user set state using two new variables, currentColorPickerView and currentColorPickerType. To retrieve the state of the component on dismissal, use currentColorPickerView and initialColorPickerType.
- Miscellaneous bug fixes.


***

# Creative SDK v0.10.2096
June 4, 2015

## AdobeCreativeSDKFoundation

- Adds a new copyFile methods to AdobeStorageSession+Files.
- File extension to mime type mapping changes:
    - IDML to application/vnd.adobe.indesign-idml-package.
    - SHAPE to image/vnd.adobe.shape+svg.
- Adds ability to control logging level to the CSDK test app.
- Now displaying the user's profile picture in the account information view.
- Deprecates setAuthenticationParametersWithClientID:withClientSecret: in favor of setAuthenticationParametersWithClientID:clientSecret:enableSignUp: to allow new user sign up in 3rd-party apps.
- Fixes paging of Lightroom Photo collections.
- Miscellaneous bug fixes.
Known Issues:
- Asset Browser, Market Browser and App Library do not launch when internet connection is not available.
- To cancel downloading master data or proxy data of Lightroom Photo assets, use cancelDownloadRequest method instead of cancelDownloadMasterDataToFileRequest method.
- The downloadToPath: method of AdobeAssetFile, AdobeMarketAsset and AdobePhotoAsset classes increments memory usage per download on iOS 8. We are working with Apple to resolve this issue.

## AdobeCreativeSDKBehance

- Adds dismissProjectViewerAnimated:completion: and dismissWorkInProgressViewerAnimated:completion: to programmatically dismiss viewer components in AdobePublish.h.
- Improvements to Project and WIP Viewer UI in the "View Info" popup.
- Project Viewer component now includes a field for "Tools Used" in the "View Info" popup.
- Project Viewer now supports display of projects that include full-bleed images.
- Components with UITextFields will now hide their cursor immediately upon being dismissed.
- Adds a public interface to the AdobePublishShareMenu (migrated from AdobeCreativeSDKDevice).
- Various bug fixes, including:
    - Fixes an issue with the Edit Profile component not allowing users to update avatars.
    - Fixes a potential crash in the Project and WIP Viewer component when tapping "View Info" / "Share" buttons.
    - Fixes a potential memory leak in the camera roll image picker.
    - Fixes an issue with AdobePublishProjectViewDelegate and AdobePublishWIPViewDelegate callbacks not occurring for follow and unfollow methods.
    - Fixes issues with popups not being presented in some cases from the Project and WIP Viewer components, or the AdobePublishShareMenu.
    - Fixes a potential memory leak when closing the Project or WIP Viewer components.
    - Fixes an issue with UI sometimes failing to adapt correctly to orientation changes.


## AdobeCreativeSDKDevice

- The deprecated AdobeShareMenu has been removed from AdobeDevice.
- The pen tip menu no longer displays the share menu as a built-in node, and a 4th custom node has been added instead. For continued use of the share menu as a pen tip node, you must override customNode4ViewController and manage the AdobePublishShareMenu object directly. See the sample app for an example of this.

## AdobeCreativeSDKColor

- Issues in the landscape of Color Component have been fixed.
- Changes for a color theme from Harmony view can be saved.
- The picker has been expanded to include RGB and CMYK pickers in addition to the color wheel. You can configure which pickers to display with the colorPickerTypes and initialPickerType.
- AdobeColorPickerControllerDelegate has a new optional method that the clients can implement, colorPickerControllerColorSet. This is meant for client UI updates that don't need to be live. Slow running UI updates should be put in this delegate vs. colorPickerControllerColorChanged.
Known Issues:
- Changes in a color theme are not saved without making a copy after the initial change.

## AdobeCreativeSDKLabs

- Our first Adobe Labs release! The Magic Selection View, allows you to identify and pull selected portions of the image out of the foreground - with just two fingers.
- Disclaimer: This Adobe Labs component is a beta product, and is provided with very limited support.


***

# Creative SDK v0.9.2082.01
May 6, 2015

AdobeCreativeSDKFoundation
**Auth**
- Deprecated setAuthenticationParametersWithClientID:withClientSecret: in favor of setAuthenticationParametersWithClientID:clientSecret:enableSignUp: to allow new user sign up in 3rd-party apps.


***

# Creative SDK v0.9.2082
March 26, 2015

AdobeCreativeSDKFoundation
**General**
- Optimized Market images to reduce bundle size.
- Ability to download very large assets
    - Added new methods to AdobeAssetFile and AdobeMarketAsset which allow very large files to be downloaded easily without consuming a significant amount of memory. These new methods compliment the existing getData:onProgress:onCompletion:onCancellation:onError: (AdobeAssetFile) and download:withMimeType:onProgress:onCompletion:onCancellation:onError: (AdobeMarketAsset) methods.

- Ability to download large photo assets and handle proxy Data in AdobePhotoAsset class.
- Support for a new protected version of [AdobeAsset PSDFilegetRenditionForLayers] that support batch mode rendering of multiple layers.
- Support the ability to pull a minimal Composite object that only includes a manifest. The UI is not blocked by the pullMinimalPSDComposite call since that happens in the background.
·(iPad only) Added a zoomable, fullscreen view for the Market Asset browser. Tapping on an asset from the details view now hides the navigation and status bars and allows for zooming (similar in behavior to the Asset browser).
·(iPad only) Moved Market Asset metadata info into an ‘info’ popover, accessible from the navigation bar in the Details view. This behavior is now consistent with the iPhone version of the Market Asset browser.
**Auth**
- Fixed a memory leak in AdobeUXAuthManager login.
- Fixed an unexpected logout bug when upgrading from old versions of the SDK.​
- Augmented AdobeAuthLoginDelegate to give apps more control when to dismiss the login view controller.​
- Fixed typo in promptUserWithLoginUI method name.
- Added support for Auth verbose logging in Release builds. Apps wanting to control Auth verbose logging can do so by accessing the keyAdobeCreativeSDKVerboseAuthLogging key in NSUserDefaults.​
- Removed the utcOffset property from AdobeAuthUserProfile.​
**AdobeLibraryManager**
- Support for multiple delegates that can register with AdobeLibraryManager.
    - AdobeLibraryDelegate: each delegate now has its own set of startup options for filtering element type and auto sync downloading options. See AdobeLibraryDelegateStartupOptions.
    - AdobeLibraryManager: startupWithOptions is now startupWithFolder and only takes the root folder, storage session and an error ptr. Each delegate should now use registerDelegate to specify their options and register with the library manager. deregisterDelegate should be used to remove a delegate.
    - AdobeLibraryComposite: elements, elementsWithFilter, countElements, and insertElement now take the delegate as a parameter.

**SendToDesktop API**
- Deleted the deprecated sendItem method from the public AdobeSendToDesktopApplication API. Its functionality is covered by the other public methods.
- Added cancellation and progress report to AdobeSendToDesktopApplication.
- Added new methods: cancelSendToDesktopRequest and changeSendToDesktopRequestPriority to cancel or change the priority of a request.
- The AdobeSendToDesktopApplication send methods now return a request token that can be used to cancel or change the priority of the request.

## AdobeCreativeSDKDevice

- The AdobeShareMenu class has been deprecated. Use the AdobePublishShareMenu class from the AdobePublishSDK instead.
    - Note: The AdobeShareMenu class implementation will be removed in the next release.

- The Kuler pen tip menu item has been replaced with the new Adobe Color Component. AdobeDeviceKulerViewController has been replaced with AdobeColorViewControllerin the AdobeDevice object. You must link with the new color framework.
- To receive color selections from the new color component, you must add an object implementing the protocol AdobeColorPickerControllerDelegate as the delegate for [AdobeDevice sharedInstance].colorViewController. Refer to AdobeColorViewController.h in AdobeCreativeSDKColor.framework for more information.

## AdobeCreativeSDKBehance

- Fixed an issue that prevented projectPublishDidComplete: and wipPublishDidComplete:revisionId: delegate return values from being respected.
- The last screen of Project and Work in Progress publishing will call endEditing: immediately upon publishing to prevent short-lived text selection artifacts.
- Fixed some UI bugs.
- Most AdobeCreativeSDKBehance method signatures have been updated to require that a presenting view controller is supplied as a parameter.
- An AdobePublishURLDelegate has been introduced to allow clients to provide their own link-handling behaviors.
- Fixed a bug that caused Twitter sharing to be improperly hidden while publishing a work in progress if Facebook sharing was not also enabled.
- Posting to Facebook from the AdobeCreativeSDKBehance component has been modified to comply with the Facebook Platform Policy (https://developers.facebook.com/policy). As a result, no pre-filled text will be posted when sharing to Facebook, only a link to the published content. The projectPublishStringForExternalAccount:url:projectText: is also no longer supported for Facebook account types.
- A note has been added to make it clear that Facebook apps require the “publish_actions” permission for sharing to Facebook while publishing.
- Fixed a race condition when publishing is cancelled near the end of an upload.
- Fixed an issue with API calls failing to remove projects from a collection.

## AdobeCreativeSDKImage

- Fixed crash on launch related to in app purchases.

## AdobeCreativeSDKColor

- Development Status: Deprecated
- This framework has been deprecated and has been replaced by the AdobeCreativeSDKColorComponent framework.

## AdobeCreativeSDKColorComponent

- Development Status: Stable
- The AdobeCreativeSDKColor framework has been completely replaced by the AdobeCreativeSDKColorComponent framework which exposes a brand new standalone UI component for developers. See the ColorComponentSampleApp sample app for integration details.
Known Issues:
- To cancel downloading master data or proxy data of Lightroom Photo assets, use cancelDownloadRequest method instead of cancelDownloadMasterDataToFileRequest method.
- downloadToPath: method of AdobeAssetFile and AdobeMarketAsset classes increments memory usage per download on iOS 8. Working with Apple to resolve the issue.
- AdobeSendToDesktopApplication onProgress and onCancellation are still work in progress.
- In Market Browser, Welcome to Market screen is not dismissed by Continue or Cancel button on iOS 7 iPad. Tap outside of the screen to dismiss it.


***

# Creative SDK v0.8.2074
February 5, 2015

AdobeCreativeSDKFoundation
**General**
- New APIs for working directly with Creative Cloud Libraries.
    - New APIs to create and manage Creative Cloud Libraries.
    - New APIs to add colors, text styles and images to Creative Cloud Libraries.

- Photos API now properly handles spaces in collection and asset names (no need for % escaping).
- Improvements in the SendToDesktop API:
    - New sendAsset method supports sending a file already stored in Creative Cloud to the desktop.
    - New sendLocalFile method supports sending a local file to the desktop.
    - Method signatures have been updated for consistency. Methods now include onProgress and onCancellation block arguments -- work in progress.
    - DEPRECATED. sendItem method has been replaced by the above methods and will be removed from the SDK in a future release.

- Fixed issues with etags and HTTP 304 responses when fetching data from the Creative Cloud files.
**Asset Browser**
- Development Status: Stable
- Visual component that allows for browsing of Creative Cloud files, photos and libraries.
Known Issues:
- None
**Creative Cloud Market**
- Development Status: Stable
- Visual component that allows users to browse and import image assets from Creative Cloud Market.
- Updated Market component for iPad -- now full screen.
- New Market component for iPhone.
Known Issues:
- None
**App Library**
- Development Status: Stable
- Showcase for Creative Cloud connected apps.
- New categories added for better classification:
    - Storytelling
    - Capture
    - Photography
    - Video
    - Design

Known Issues:
- App Library shows all apps regardless of compatibility or form factor.
**Auth**
- Development Status: Stable
- Visual component that provides support for end-user login to the Creative Cloud.​

AdobeCreativeSDKImage
**General**
- Image editor component (formerly the Aviary SDK).
- Fixed an issue when selecting a target Image Component framework in the Customizer app.
Known Issues:
- None

AdobeCreativeSDKDevice
**Pen & Slide**
- Development Status: Stable
- Support for Adobe Ink-compatible pens (including Adonit Jot Touch Pixelpoint).
- Support for 3rd-party pens via device extensions:
    - Wacom Intuous Creative Stylus
    - Wacom Bamboo Stylus Fineline
    - Pencil by Fifty Three

- Device Extensions are now included in the SDK Framework download.
- New options included on AdobeDeviceNodeAppearance for greater control of the node's properties:
    - invertedColorTheme
    - adjustsImageWhenHighlighted

- Pen tip menu colors can now be configured independently from the accent color using inkMenuNodeBackgroundColor and inkMenuNodeAccentColor. SDK will use accent color by default.
- Pen tip menu layout has changed to account for the cloud clipboard menu item not being available based on the connected pen.
    - If you were previously using a five-node setup, you many need to swap custom node 1 and custom node 2. The six-node menu behavior has changed to account for this new requirement.

- Fixed a typo in the AdobeDevicePenPasteboardDelegate method. pasteboard:didFailedToPerformAction:withError:type: renamed to pasteboard:didFailToPerformAction:withError:type:
Notes:
- A compatible iPad and Adobe Ink and Slide hardware is required to test Ink and Slide support in the SDK. Testing is not available using the iOS simulator.
- Detection of Adobe Slide hardware is off by default until an Adobe Ink is connected to the iPad at least once. Does not affect Touch Slide. May be overridden.
Known Issues:
- None
**Touch Slide**
- Development Status: Stable
- Virtual ruler
Known Issues:
- None

AdobeCreativeSDKBehance
**Publish**
- Development Status: Stable
- Enable users to publish work-in-progress (WIP) and projects to Behance
    - Work-in-progress: A single image, commonly used to represent an unfinished work.
    - Project: A composed piece, including one or more images/video embeds, and a cover image.

- New (optional) support for the AdobeCreativeSDKImage framework. If the framework is included alongside AdobeCreativeSDKBehance, users will be able to edit all of their Behance assets in the AdobeCreativeSDKImage editor.
- AdobePublishCommentPanel now includes support for links in comments.
- Camera capture of assets is better handled on devices with only one camera.
- Project publishing now includes the contents of the pasteboard automatically when adding HTML embed content.
- Facebook integration has been updated to support version 2.2 of the Facebook Graph API.
Known Issues:
- None
**Project & WIP**
- Development Status: Stable
- Visual component for displaying projects and WIPs. Includes the ability to appreciate and comment on projects, and follow owners.
- showProjectWithId:delegate:, showWorkInProgressWithId:delegate: now include a new header design for the iPhone and iPod.
Known Issues:
- None
**Profile**
- Development Status: Stable
- Allow users to update their Behance and Creative Cloud profile.
Known Issues:
- None
**Feedback**
- Development Status: Stable
- Enable users to receive feedback from the Behance community.
Known Issues:
- None
**API**
- For deeper integrations with Behance, framework includes a wrapper for the Behance API which can be found at [http://www.behance.net/dev](http://www.behance.net/dev).


***
# Creative SDK v0.7.2072
December 15, 2014

AdobeCreativeSDKFoundation
**General**
- This release of the SDK was devoted to closing outstanding issues and improving the overall quality.
- Added NEW AdobeCreativeSDKImage framework that includes the Aviary image editor.
- New properties added to AdobeAuthUserProfile.
- Reduced the overall binary size of apps compiled with the framework.
    - Consolidated and removed extraneously fonts and images.

- No longer saving auth tokens in the url cache.
**Asset Browser**
- Development Status: Stable
- Numerous enhancement to Creative Cloud Library browsing.
- Fixed issue where a 404 error was thrown when a user with no defined Creative Cloud Libraries selects "My Libraries" for the first time in a session.
Known Issues:
- None
**Creative Cloud Market**
- Development Status: Stable
- Visual component that allows users to browse and import image assets from Creative Cloud Market.
Known Issues:
- Market component is currently unsupported on iPhone.
**App Library**
- Development Status: Stable
- Showcase for Creative Cloud connected apps.
Known Issues:
- App Library shows all apps regardless of compatibility or form factor.
**Auth**
- Development Status: Stable
- Visual component that provides support for end-user login to the Creative Cloud.​

AdobeCreativeSDKImage
**General**
- Image editor component (formerly the Aviary SDK).
- NEW Vignette tool.
- NEW Overlay tool.
- Improved Draw tool with velocity dependent stroke width.
- NEW Lighting and Color tools.
- Simplified high resolution API.
- High resolution output is now enabled by default for all partners.
- Fixes an error found in v0.7.2070 with duplicated symbols in some integrations when building for the iOS simulator.
Known Issues:
- None

AdobeCreativeSDKDevice
**Pen & Slide**
- Development Status: Stable
- Support for Adobe Ink-compatible pens (including Adonit Jot Touch Pixelpoint).
- Support for 3rd-party pens via device extensions
    - Wacom Intuous Creative Stylus
    - Wacom Bamboo Stylus Fineline
    - Pencil by Fifty Three

- activeWritingStyle and penPreferredWritingStyle have been unified into penWritingStyle.
- PenTip menu layout has changed to account for instances where the cloud clipboard menu is not available. If you previously used a 5-button setup, you may need to swap custom node 1 and custom node 2. The 6-button menu behavior has changed to account for this new requirement.
- Fixed an issue where the colors from the color selector off of the PenTup menu were not accessible.
- Fixed iOS8 issue where DeviceSDK would crash when Cancel button from the Share option.
Notes:
- A compatible iPad and Adobe Ink and Slide hardware is required to test Ink and Slide support in the SDK. Testing is not available using the iOS simulator.
- Detection of Adobe Slide hardware is off by default until an Adobe Ink is connected to the iPad at least once. Does not affect Touch Slide. May be overridden.
Known Issues:
- None
**Touch Slide**
- Development Status: Stable
- Virtual ruler
Known Issues:
- None

AdobeCreativeSDKBehance
**Publish**
- Development Status: Stable
- Enable users to publish work-in-progress (WIP) and projects to Behance
    - Work-in-progress: A single image, commonly used to represent an unfinished work.
    - Project: A composed piece, including one or more images/video embeds, and a cover image.

- Project images can be added from user photo library as well as from Creative Cloud.
- Ability to share work to Facebook and/or Twitter upon publishing to Behance.
Known Issues:
- None
**Project & WIP**
- Development Status: Beta
- New component for displaying projects and WIPs. Includes the ability to appreciate and comment on projects, and follow owners.
Known Issues:
- None
**Profile**
- Development Status: Stable
- Allow users to update their Behance and Creative Cloud profile.
Known Issues:
- None
**Feedback**
- Development Status: Stable
- Enable users to receive feedback from the community.
- Include a comment panel in your app to allow users to view comments on a project or work-in-progress
    - Provided button that can be used to present the comment panel that updates automatically to display unread counts when new comments are received.

Known Issues:
- None
**API**
- For deeper integrations with Behance, framework includes a wrapper for the Behance API which can be found at [http://www.behance.net/dev](http://www.behance.net/dev).


***

# Creative SDK v0.6.2067
November 21, 2014

AdobeCreativeSDKFoundation
**General**
- This release of the SDK was devoted to closing outstanding issues and improving the overall quality.
- Send to Desktop API is no longer restricted and is available to all clients.
**Asset Browser**
- Development Status: Stable
- Numerous enhancement to Creative Cloud Library browsing.
Known Issues:
- A 404 error is thrown when a user with no defined Creative Cloud Libraries selects "My Libraries" for the first time in a session.
**Creative Cloud Market**
- Development Status: Stable
- Visual component that allows users to browse and import image assets from Creative Cloud Market.
Known Issues:
- Market component is currently unsupported on iPhone.
**App Library**
- Development Status: Stable
- Showcase for Creative Cloud connected apps.
Known Issues:
- App Library shows all apps regardless of compatibility or form factor.
**Auth**
- Development Status: Stable
- Visual component that provides support for end-user login to the Creative Cloud.​


***

# Creative SDK v0.5.2062
October 16, 2014

AdobeCreativeSDKFoundation
**General**
- Creative SDK now supports Xcode 6. Compiling with Xcode 5 is no longer supported.
- Now based on iOS SDK.
Known Issues:
- Send to Desktop API is whitelisted and not currently available without approval. If you would to request access to this service, please email creativesdk@adobe.com.
**Asset Browser**
- Development Status: Stable
- Visual component that provides access to files and photos stored in the Creative Cloud.
- Creative Cloud Library support on iPhone.
Known Issues:
- iPhone: Some design library element types has incorrect thumbnails dimension.
- Some design library thumbnails may look different between iPad and iPhone.
- Pull to Refresh is not available in My Libraries of Asset Browser.
**Creative Cloud Market**
- Development Status: Stable
- Visual component that allows users to browse and import image assets from Creative Cloud Market.
Known Issues:
- Market component is currently unsupported on iPhone.
**App Library**
- Development Status: Stable
- Showcase for Creative Cloud connected apps.
Known Issues:
- App Library shows all apps regardless of compatibility or form factor.
**Auth**
- Development Status: Stable
- Visual component that provides support for end-user login to the Creative Cloud.​


***

# Creative SDK v0.4.2059
October 5, 2014

AdobeCreativeSDKFoundation
**Auth**
- Development Status: Stable
- Visual component that provides support for end-user login to the Creative Cloud.
- Provides authentication token which is required by Creative Cloud API.
- Allows for Creative Cloud sign-up as well as sign-in.
- Handle legal requirements such as TOU and age/email verification.
**Creative Cloud Market**
- Development Status: Stable
- Visual component that allows users to browse and import image assets from Creative Cloud Market.
- Market component now integrated with Creative Cloud Libraries.
Known Issues:
- Market component is currently unsupported on iPhone.
**Asset Browser**
- Development Status: Stable
- Visual component that provides access to files and photos stored in the Creative Cloud.
- Support for single selection mode and multi-selection mode.
- PSD layer extraction workflow enabled.
- File and Lightroom Photo API access for use outside of component.
- Browser and import creations from Adobe Line, Adobe Sketch, Photoshop Mix & more.
- Access content from user-defined Creative Cloud Libraries.
Known Issues:
- Creative Cloud Library is current unsupported on iPhone.
**App Library**
- Development Status: Stable
- Showcase for Creative Cloud connected apps.
Known Issues:
- App Library shows all apps regardless of compatibility.
**General**
- SDK tested against iOS8 built with Xcode 5.
Known Issues:
- Send to Desktop API is whitelisted and not currently available without approval. If you would to request access to this service, please email creativesdk@adobe.com.

AdobeCreativeSDKDevice
**Pen**
- Development Status: Stable
- Support for Adobe Ink-compatible pens (including Adonit Jot Touch Pixelpoint).
- Support for 3rd-party pens via device extensions
    - Wacom Intuous Creative Stylus
    - Wacom Bamboo Stylus Fineline
    - Pencil by Fifty Three

Notes:
- A compatible iPad and Adobe Ink and Slide hardware is required to test Ink and Slide support in the SDK. Testing is not available using the iOS simulator.
Known Issues:
- Currently colors from the color selector off of the PenTip menu are not accessible.
- iOS8: DeviceSDK crash when Cancel button from Share option.
**Slide**
- Development Status: Stable
- Detection of Adobe Slide on screen as a gesture.
- Access to button state of Adobe Slide hardware that is on the screen.
- Drawing, tracing and stamping of shapes and guide lines presented by Adobe Slide (optionally provided in addition to basic hardware detection).
- Gesture driven adjustment of guide lines and shapes.
- Button driven cycling through guide shapes.
- Slide settings view.
Notes:
- Detection of Adobe Slide hardware is off by default until an Adobe Ink is connected to the iPad at least once. Does not affect Touch Slide. May be overridden.
**Touch Slide**
- Development Status: Stable
- Support for tracing and stamping behavior for users without Adobe Slide hardware.
- Position guide lines and shapes using Touch Slide touch points, toggled with touch slide button.

AdobeCreativeSDKBehance
**Publish**
- Development Status: Stable
- Enable users to publish work-in-progress (WIP) and projects to Behance
    - Work-in-progress: A single image, commonly used to represent an unfinished work.
    - Project: A composed piece, including one or more images/video embeds, and a cover image.

- Project images can be added from user photo library as well as from Creative Cloud.
- Ability to share work to Facebook and/or Twitter upon publishing to Behance.
**Project**
- Development Status: Beta
- New component for displaying projects. Includes the ability to appreciate and comment on projects, and follow owners.
**Profile**
- Development Status: Stable
- Allow users to update their Behance and Creative Cloud profile.
**Feedback**
- Development Status: Stable
- Enable users to receive feedback from the community.
- Include a comment panel in your app to allow users to view comments on a project or work-in-progress
    - Provided button that can be used to present the comment panel that updates automatically to display unread counts when new comments are received.

**API**
- For deeper integrations with Behance, framework includes a wrapper for the Behance API which can be found at [http://www.behance.net/dev](http://www.behance.net/dev).

AdobeCreativeSDKColor
**Color**
- Development Status: Under Development
- Currently only in use by the AdobeCreativeSDKDevice framework. In the future, this framework will provide visual components and direct access to Adobe Color service.


***

# Creative SDK v0.3.2043
September 20, 2014

AdobeCreativeSDKFoundation
**Auth**
- Development Status: Stable
- Visual component that provides support for end-user login to the Creative Cloud.
**Creative Cloud Market**
- Development Status: Stable
- Visual component that allows users to browse and import image assets from Creative Cloud Market.
- Market component now integrated with Creative Cloud Libraries.
Known Issues:
- Market component is currently unsupported on iPhone.
- Download asset fails and Market browser is blank next time it opens.
- iOS8: Market browser view is placed off center downward in landscape mode.
**Asset Browser**
- Development Status: Stable
- Browser v2 -- New and improved full screen asset browser.
- New support for accessing Lightroom photos.
Known Issues:
- Transition janky when rotating device in 1UP view.
- Source toggle not centering properly when rotating iPad.
- iOS8: list view only: list row moves left when it first load.
**App Library**
- Development Status: Stable
- Showcase for Creative Cloud connected apps.
Known Issues:
- App Library shows all apps regardless of compatibility.
**General**
- SDK is now being tested against iOS8 built with Xcode 5.
- New API to create Illustrator files.

AdobeCreativeSDKDevice
**Pen**
- Development Status: Stable
Known Issues:
- Currently colors from the color selector off of the PenTip menu are not accessible.
- iOS8: DeviceSDK crash when Cancel button from Share option.
**Slide**
- Development Status: Stable
**Touch Slide**
- Development Status: Stable

AdobeCreativeSDKBehance
**Publish**
- Development Status: Stable
**Project**
- Development Status: Beta
- New component for displaying projects. Includes the ability to appreciate and comment on projects, and follow owners.
**Profile**
- Development Status: Beta
**Feedback**
- Development Status: Stable
**API**
- For deeper integrations with Behance, framework includes a wrapper for the Behance API which can be found at [http://www.behance.net/dev](http://www.behance.net/dev).

AdobeCreativeSDKColor
**Kuler**
- Development Status: Stable


***

# Creative SDK v0.2.2006
August 27, 2014

AdobeCreativeSDKFoundation
**Auth**
- Development Status: Stable
- Visual component that provides support for end-user login to the Creative Cloud.
- Removed workflow to create new Adobe ID.
**Creative Cloud Market**
- Development Status: Beta - Under Development
- Visual component that allows users to browse and import image assets from Creative Cloud Market.
- Users are shown a notification that premium access to Creative Cloud Market is currently free during beta period.
New functionality:
- Browse, sort and filter assets.
- Acquire and download assets to user Creative Cloud storage.
- View artist / creator profile.
Known Issues:
- Market component is currently unsupported on iPhone.
- Searching by artist / creator name does not yield results.
- Acquired assets are not displayed under "Download" section.
- Information section of detail view is not scrollable.
- Artist / creator view is limited to 4 assets.
**Asset Browser**
- Development Status: Stable

AdobeCreativeSDKDevice
**Ink**
- Development Status: Stable
- Support for Adobe Ink-compatible pens (including Adonit Jot Touch Pixelpoint)
Notes:
- A compatible iPad and Adobe Ink and Slide hardware is required to test Ink and Slide support in the SDK. Testing is not available using the iOS simulator.
Known Issues:
- De-wiggle issue: Drawing slowly causes lines to be wave-like instead of straight.
- Bluetooth data delay jumps from 30ms to 500ms on some iPads. When this happens strokes drawn get re-drawn and look like strokes that are not rendered or are missing.
- Changing custom node appearance does not update properties of default nodes in the pen-tip menu.
- Kuler service error message is truncated when displayed.
- In cloud clipboard view, “This image failed to load" message is displayed when copy is interrupted before completion or clipboard service is down. Try again option workflow is not complete.
- Palm preferences assets are blurry on iPad mini (non-retina).
**Slide**
- Development Status: Stable
Known Issues:
- Slide trace path shows up when changing views in the app
**Touch Slide**
- Development Status: Stable
- Support for tracing and stamping behavior for users without Adobe Slide
Notes:
- Detection of Adobe Slide hardware is off by default until an Adobe Ink is connected to the iPad at least once. Does not affect Touch Slide. May be overridden.

AdobeCreativeSDKBehance
**Publish**
- Development Status: Stable
- Enable users to publish work-in-progress (WIP) and projects to Behance
- Work-in-progress: A single image, commonly used to represent an unfinished work.
- Project: A composed piece, including one or more images/video embeds, and a cover image.
Known Issues:
- Publishing is asynchronous, but currently supports publishing only one project or work-in-progress at a time.
- Behance recently transitioned its authentication scheme from Behance accounts to Adobe ID. Under normal circumstances, when an Adobe ID is created with an email address matching a previously existing Behance account’s email address, it will automatically be linked. However, if that Behance account is already linked to a different Adobe ID, these users will not be auto-linked, and requests to the Behance API will fail.
**Profile**
- Development Status: Beta
- Allow users to update their Behance and Creative Cloud profile.
- Name
- Job Title
- Company
- Location
- Website URL
- Profile Photo / Avatar
Known Issues:
- Caching currently prevents retrieval of the new profile until shortly after making an update.
**Feedback**
- Development Status: Stable
- Enable users to receive feedback from the community.
- Include a comment panel in your app to allow users to view comments on a project or work-in-progress
- Provided button that can be used to present the comment panel that updates automatically to display unread counts when new comments are received.
Known Issues:
- Comment panel requires user to be logged in to view and respond to comments.
**API**
- For deeper integrations with Behance, framework includes a wrapper for the Behance API which can be found at [http://www.behance.net/dev](http://www.behance.net/dev).

AdobeCreativeSDKColor
**Kuler**
- Development Status: Stable
- Visual component that provides kuler color navigation.
- Required when using AdobeCreativeSDKDevice.framework


***

# Creative SDK v0.1.1143
July 28, 2014

AdobeCreativeSDKFoundation
**Auth**
- Development Status: Stable
- Visual component that provides support for end-user login to the Creative Cloud.
- Removed workflow to create new Adobe ID.
**Creative Cloud Market**
- Development Status: Beta - Under Development
- Visual component that allows users to browse and import image assets from Creative Cloud Market.
- Users are shown a notification that premium access to Creative Cloud Market is currently free during beta period.
New functionality:
- Browse, sort and filter assets.
- Acquire and download assets to user Creative Cloud storage.
- View artist / creator profile.
Known Issues:
- Market component is currently unsupported on iPhone.
- Searching by artist / creator name does not yield results.
- Acquired assets are not displayed under "Download" section.
- Information section of detail view is not scrollable.
- Artist / creator view is limited to 4 assets.
**Asset Browser**
- Development Status: Stable

AdobeCreativeSDKDevice
**Ink**
- Development Status: Stable
- Support for Adobe Ink-compatible pens (including Adonit Jot Touch Pixelpoint)
Notes:
- A compatible iPad and Adobe Ink and Slide hardware is required to test Ink and Slide support in the SDK. Testing is not available using the iOS simulator.
Known Issues:
- De-wiggle issue: Drawing slowly causes lines to be wave-like instead of straight.
- Bluetooth data delay jumps from 30ms to 500ms on some iPads. When this happens strokes drawn get re-drawn and look like strokes that are not rendered or are missing.
- Changing custom node appearance does not update properties of default nodes in the pen-tip menu.
- Kuler service error message is truncated when displayed.
- In cloud clipboard view, “This image failed to load" message is displayed when copy is interrupted before completion or clipboard service is down. Try again option workflow is not complete.
- Palm preferences assets are blurry on iPad mini (non-retina).
**Slide**
- Development Status: Stable
Known Issues:
- Slide trace path shows up when changing views in the app
**Touch Slide**
- Development Status: Stable
- Support for tracing and stamping behavior for users without Adobe Slide
Notes:
- Detection of Adobe Slide hardware is off by default until an Adobe Ink is connected to the iPad at least once. Does not affect Touch Slide. May be overridden.

AdobeCreativeSDKBehance
**Publish**
- Development Status: Stable
- Enable users to publish work-in-progress (WIP) and projects to Behance
- Work-in-progress: A single image, commonly used to represent an unfinished work.
- Project: A composed piece, including one or more images/video embeds, and a cover image.
Known Issues:
- Publishing is asynchronous, but currently supports publishing only one project or work-in-progress at a time.
- Behance recently transitioned its authentication scheme from Behance accounts to Adobe ID. Under normal circumstances, when an Adobe ID is created with an email address matching a previously existing Behance account’s email address, it will automatically be linked. However, if that Behance account is already linked to a different Adobe ID, these users will not be auto-linked, and requests to the Behance API will fail.
**Profile**
- Development Status: Beta
- Allow users to update their Behance and Creative Cloud profile.
- Name
- Job Title
- Company
- Location
- Website URL
- Profile Photo / Avatar
Known Issues:
- Caching currently prevents retrieval of the new profile until shortly after making an update.
**Feedback**
- Development Status: Stable
- Enable users to receive feedback from the community.
- Include a comment panel in your app to allow users to view comments on a project or work-in-progress
- Provided button that can be used to present the comment panel that updates automatically to display unread counts when new comments are received.
Known Issues:
- Comment panel requires user to be logged in to view and respond to comments.
**API**
- For deeper integrations with Behance, framework includes a wrapper for the Behance API which can be found at [http://www.behance.net/dev](http://www.behance.net/dev).

AdobeCreativeSDKColor
**Kuler**
- Development Status: Stable
- Visual component that provides kuler color navigation.
- Required when using AdobeCreativeSDKDevice.framework


***

# Creative SDK v0.1.782
June 18, 2014

AdobeCreativeSDKFoundation
**Auth**
- Development Status: Stable
- Visual component that provides support for end-user login to the Creative Cloud.
- Provides authentication token which is required by Creative Cloud API.
- Allows for Creative Cloud sign-up as well as sign-in.
- Handle legal requirements such as TOU and age/email verification.
**Asset Browser**
- Development Status: Stable
- Visual component that provides access to files stored in the Creative Cloud.
- Support for single selection mode and multi-selection mode.
- Basic sorting and search/filtering.
- PSD layer extraction workflow enabled.
- File API access for use outside of component.
Known Issues:
- Global search (search in multiple folders) not available.
- iPhone only: User account info popup with user id, storage usage, get more storage, and switch account is not available.
- Multi select check mark state is incorrect when going in and out of 1UP or swiping inside 1UP.
- PSD Extraction: Use As Image and Extract Layers popup shifted when we rotate device orientation (landscape/portrait).
- PSD Extraction: Rendition of PSD files is not loaded in 1-up view on selecting a file for extraction in List view before thumbnail is available.

AdobeCreativeSDKDevice
**Ink**
- Development Status: Stable
- Access to pen touch location with pressure sensitivity data.
- Ability to enable palm rejection.
- Access to and configuration of Creative Cloud pen-tip menu.
- Access Kuler themes associated with the user’s Adobe Ink.
- Cloud copy and paste and cloud clipboard view.
- Pen setup and settings view (including linking to the Creative Cloud).
- Support for Adobe Ink-compatible pens (including Adonit Jot Touch Pixelpoint).
Notes:
- A compatible iPad and Adobe Ink and Slide hardware is required to test Ink and Slide support in the SDK. Testing is not available using the iOS simulator.
Known Issues:
- De-wiggle issue: Drawing slowly causes lines to be wave-like instead of straight.
- Bluetooth data delay jumps from 30ms to 500ms on some iPads. When this happens strokes drawn get re-drawn and look like strokes that are not rendered or are missing.
- Changing custom node appearance does not update properties of default nodes in the pen-tip menu.
- Kuler service error message is truncated when displayed.
- In cloud clipboard view, “This image failed to load" message is displayed when copy is interrupted before completion or clipboard service is down. Try again option workflow is not complete.
- Palm preferences assets are blurry on iPad mini (non-retina).
**Slide**
- Development Status: Stable
- Detection of Adobe Slide on screen as a gesture.
- Access to button state of Adobe Slide hardware that is on the screen.
- Drawing, tracing and stamping of shapes and guide lines presented by Adobe Slide (optionally provided in addition to basic hardware detection).
- Gesture driven adjustment of guide lines and shapes.
- Button driven cycling through guide shapes.
- Slide settings view.
Known Issues:
- Slide trace path shows up when changing views in the app.
**Touch Slide**
- Development Status: Stable
- Support for tracing and stamping behavior for users without Adobe Slide
- Position guide lines and shapes using Touch Slide touch points, toggled with touch slide button
Notes:
- Detection of Adobe Slide hardware is off by default until an Adobe Ink is connected to the iPad at least once. Does not affect Touch Slide. May be overridden.

AdobeCreativeSDKBehance
**Publish**
- Development Status: Stable
- Enable users to publish work-in-progress (WIP) and projects to Behance
- Work-in-progress: A single image, commonly used to represent an unfinished work.
- Project: A composed piece, including one or more images/video embeds, and a cover image.
- Project images can be added from user photo library as well as from Creative Cloud.
- Ability to share work to Facebook and/or Twitter upon publishing to Behance.
Known Issues:
- Publishing is asynchronous, but currently supports publishing only one project or work-in-progress at a time.
- Behance recently transitioned its authentication scheme from Behance accounts to Adobe ID. Under normal circumstances, when an Adobe ID is created with an email address matching a previously existing Behance account’s email address, it will automatically be linked. However, if that Behance account is already linked to a different Adobe ID, these users will not be auto-linked, and requests to the Behance API will fail.
**Feedback**
- Development Status: Stable
- Enable users to receive feedback from the community.
- Include a comment panel in your app to allow users to view comments on a project or work-in-progress
- Provided button that can be used to present the comment panel that updates automatically to display unread counts when new comments are received.
Known Issues:
- Comment panel requires user to be logged in to view and respond to comments.
**API**
- For deeper integrations with Behance, framework includes a wrapper for the Behance API which can be found at [http://www.behance.net/dev](http://www.behance.net/dev).

AdobeCreativeSDKColor
**Kuler**
- Development Status: Stable
- Visual component that provides kuler color navigation.
- Required when using AdobeCreativeSDKDevice.framework
