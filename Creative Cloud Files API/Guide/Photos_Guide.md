# Creative Cloud Files API

The Creative SDK provides headless APIs for uploading files to photos(Lightroom photos). This guide demonstrates how to use these APIs to upload files to a photo collection or a photo catalog.

## Contents

- [Prerequisites](#prerequisites)
- [Upload Files to the Photos](#upload)
- [Class Reference](#reference)

<a name="prerequisites"></a>

## Prerequisites

This guide will assume that you have installed all software and completed all of the steps in the following guides:

*   [Getting Started](https://creativesdk.adobe.com/docs/ios/#/articles/gettingstarted/index.html)
*   [Framework Dependencies](https://creativesdk.adobe.com/docs/ios/#/articles/dependencies/index.html) guide.

_**Note:**_

*   _This component requires that the user is **logged in with their Adobe ID**._
*   _Your Client ID must be [approved for **Production Mode** by Adobe](https://creativesdk.zendesk.com/hc/en-us/articles/204601215-How-to-complete-the-Production-Client-ID-Request) before you release your app._

<a name="upload"></a>
## Upload Files to the Photos
AdobePhotoCatalog is the topmost container of assets in a user's lightroom photos. Each catalog contains zero or more AdobePhotoCollection. AdobePhotoCollection is a container of collections in a user's catalog. Each collection contains zero or more AdobePhotoAsset. You can upload assets to photo catalog or a photo collection.

* Use the below API in AdobePhotoCatalog to list user photo catalogs
    + (void)listOfType:(AdobePhotoCatalogType)type
          successBlock:(void (^)(AdobePhotoCatalogs *catalogs))successBlock
            errorBlock:(void (^)(NSError *error))errorBlock;

* Use the below API in in AdobePhotoCatalog to list user photo collections
    - (void)listCollectionsAfterName:(NSString *)name
                               limit:(NSUInteger)limit
           includeDeletedCollections:(BOOL)deleted
                        successBlock:(void (^)(AdobePhotoCollections *collections))successBlock
                          errorBlock:(void (^)(NSError *error))errorBlock;

* Uploading to photo collection
    // Upload assets to selected photo collection.
    [AdobePhotoAsset create:<assetName>
                 collection:<selectedPhotoCollection>
                   dataPath:<assetURL>
                contentType:kAdobeMimeTypePNG
              progressBlock:nil
               successBlock:^(AdobePhotoAsset *asset)
    {
        NSLog(@"Upload success: %@", assetName);
    }
          cancellationBlock:nil
                 errorBlock:^(NSError *error)
    {
        NSLog(@"Upload failed: %@", error);
    }];

* Uploading to photo catalog
    // Upload assets to selelcted photo catalog.
    [AdobePhotoAsset create:<assetName>
                    catalog:<selectedPhotoCatalog>
                   dataPath:<assetURL>
                contentType:kAdobeMimeTypePNG
              progressBlock:nil
               successBlock:^(AdobePhotoAsset *asset)
    {
        NSLog(@"Upload success: %@", assetName);
    }
          cancellationBlock:nil
                 errorBlock:^(NSError *error)
    {
        NSLog(@"Upload failed: %@", error);
    }];

<a name="reference"></a>
## Class Reference

+ [AdobePhotoAsset](https://creativesdk.adobe.com/docs/ios/#/Classes/AdobePhotoAsset.html)
+ [AdobePhotoCatalog](https://creativesdk.adobe.com/docs/ios/#/Classes/AdobePhotoCatalog.html)
+ [AdobePhotoCollection](https://creativesdk.adobe.com/docs/ios/#/Classes/AdobePhotoCollection.html)
