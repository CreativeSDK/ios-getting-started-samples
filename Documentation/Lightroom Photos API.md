# Lightroom Photos API

Adobe Lightroom enables photo management and editing on the desktop and mobile devices. The Creative SDK allows you to access photos that users have managed with Lightroom and synced to the Creative Cloud.  The API give you both read and write access to their collections. As an example, your application could let a user download a photo, modify it, then send it back. Or you could take new art designed by the user and make it available to their Lightroom collections. All edits are done non-destructively; full history support is built in.

This guide will show you how to use the Lightroom Photos API to access photos in the Creative Cloud and upload new photos to the Creative Cloud.

If you're interested in embedding with the UI we already made for iOS devices, please see [Asset Browser UI Component](/articles/assetbrowser/index.html).

## Contents

- [Prerequisites](#prerequisites)
- [Access Lightroom Photos in the Creative Cloud](#access)
- [Upload Lightroom Photos to the Creative Cloud](#upload)
- [Class Reference](#reference)

<a name="prerequisites"></a>

## Prerequisites

This guide will assume that you have installed all software and completed all of the steps in the following guides:

* Getting Started
* Framework Dependencies

_**Note:**_

*   _This component requires that the user is **logged in with their Adobe ID**._
*   _Your Client ID must be [approved for **Production Mode** by Adobe](https://creativesdk.zendesk.com/hc/en-us/articles/204601215-How-to-complete-the-Production-Client-ID-Request) before you release your app._

<a name="access"></a>
## Access Lightroom Photos in the Creative Cloud

This example shows you how to accesses a user's collection and displays it's contents.
*You can find the complete sample project for this guide in <a href="https://github.com/CreativeSDK/ios-getting-started-samples" target="_blank">GitHub</a>.*

This is what a logged-in user sees when running our sample project:

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/photos/photos1.jpg)

After the user clicks **Show Photos**, the code asks the Photos API for all catalogs to which the user has access. (Currently, Lightroom allows only one catalog to be synced with the Creative Cloud, so only one catalog is returned.)

Think of a catalog as a high-level grouping. Under each catalog is a set of collections that further organizes assets. (Instructions on how to set up syncing of Lightroom collections to the Creative Cloud are found [here](https://helpx.adobe.com/lightroom/help/lightroom-mobile-desktop-features.html).)

Our code asks each collection for a rendition of its assets. Here is an example of the result:

![](https://aviarystatic.s3.amazonaws.com/creativesdk/ios/photos/photos2.jpg)

In the code, everything is driven from a main `showPhotos` method. We begin by asking for the list of catalogs from the user's data:

    [AdobePhotoCatalog listOfType:AdobePhotoCatalogTypeLightroom onCompletion:^(NSArray
      *catalogs) {

This method allows for filtering by a type (currently limited to one, Lightroom).

Once catalogs are received, you can iterate over them (currently there will be only one) and ask for list of collections:

    for(AdobePhotoCatalog *catalog in catalogs) {
       NSLog(@"Catalog name: %@", catalog.name);

       /* Now get collections */
       [catalog listCollectionsAfterName:nil withLimit:100 includeDeletedCollections:NO
         onCompletion:^(NSArray *collections) {

For each collection, we ask for the assets:

    for(AdobePhotoCollection *collection in collections) {
       NSLog(@"Collection name: %@", collection.name);

       [collection listAssetsOnPage: nil
                       withSortType:AdobePhotoCollectionSortByDate
                          withLimit:100
                           withFlag:AdobePhotoCollectionFlagUnflagged
                       onCompletion:^(NSArray *assets, AdobePhotoPage *previousPage, AdobePhotoPage *nextPage) {

You can filter by date and in multiple directions, and provide a hard limit to the result set. We ask for everything, limited to 100 results.

The completion block is sent an array of assets of type `AdobePhotoAsset`. You can get multiple pieces of information about the photo, but the important one for us is the renditions property. This provides a dictionary representing which renditions are available. The dictionary of possible keys includes everything from full-size versions to thumbnails. We check for either the thumbnail (`AdobePhotoAssetRenditionImageThumbnail`) or the retina thumbnail (`AdobePhotoAssetRenditionImageThumbnail2x`):

    NSString *RenditionSize;
    if([assetDict valueForKey:AdobePhotoAssetRenditionImageThumbnail2x]!= nil) {
    NSLog(@"ok going to get thumbnail2x");
    RenditionSize = AdobePhotoAssetRenditionImageThumbnail2x;
    } else if ([assetDict valueForKey:AdobePhotoAssetRenditionImageThumbnail]!= nil) {
    NSLog(@"ok going to get thumbnail1x");
    RenditionSize = AdobePhotoAssetRenditionImageThumbnail;
    }

We then call the downloadRendition method:

    [asset downloadRendition:asset.renditions[RenditionSize]
                withPriority:NSOperationQueuePriorityNormal
                  onProgress:^(double fractionCompleted) {
                               //Nothing here...
              } onCompletion:^(NSData *data, BOOL wasCached) {

                  UIImage *preview = [UIImage imageWithData:data];
                  UIImageView *uiImage = [[UIImageView alloc] initWithImage:preview];
                  ...

              } onCancellation:^{
                  ...
              } onError:^(NSError *error) {
                  ...
              }];


As seen fromthe code sample above, We use the onCompletion handler and create a `UIImage` from the pure data retrieved.  The rest of the application is simply layout.

<a name="upload"></a>
## Upload Lightroom Photos to the Creative Cloud

See the Class Reference below for a list of Classes for uploading Lightroom Photos to the Creative Cloud with our headless API.

<a name="reference"></a>
## Class Reference

+ AdobePhotoAsset
+ AdobePhotoCatalog
+ AdobePhotoCollection
