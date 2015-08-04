#Creative Cloud Market UI Component

The Creative Cloud Market is a collection of curated, high quality assets, free for use in applications by any member of the Creative Cloud. Assets include vector graphics, icons, images, and brushes. While these are available from the Creative Cloud application itself, you also can provide Market assets to users of your applications. For instance, a paint program can let your users browse brushes to enhance their creative experience.

The Creative SDK provides a simple way to expose the Market to your users, greatly extending your application.

## Contents

- [Prerequisites](#prerequisites)
- [Integrating the Market UI Component](#integrate)
- [Specifying Content Categories](#contentcategories)
- [Class Reference](#reference)

## Prerequisites

+ This guide assumes that you've already read the <a href="/articles/gettingstarted/index.html">Getting Started</a> guide and have implemented Auth.
+ For a complete list of framework dependencies, see the <a href="/articles/dependencies/index.html">Framework Dependencies</a> guide.

<a name="integrate"></a>
## Integrating the Market UI Component

*You can find the complete `MarketAssetBrowserDemo` project for this guide in <a href="https://github.com/CreativeSDK/ios-getting-started-samples" target="_blank">GitHub</a>.*

The core class our sample application uses is `AdobeUXMarketAssetBrowser`. This class provides a browser to the Market. It gives the user the ability to sort by featured assets, filter by categories, and search.

By default, the Market does not filter what is shown to the user, but the class does let you filter which categories are shown to the user. For example, a painting program may want to limit results to brushes.

If the user finds an asset he likes, he can select it to see a larger preview:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/market/market2.jpg"/>

In either the grid view or preview, users can download the asset. This copies the asset to their Files on the Creative Cloud (in a **Market Downloads** folder):

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/market/market3.jpg"/>

Users also can send an asset to the application. In the preview, this is automatic. In the grid view, the user must explicitly click the icon after downloading the asset:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/market/market4.jpg"/>

The `AdobeUXMarketAssetBrowser` class provides a way to handle this “open in app” action and lets your action take whatever next steps make sense for it. Let's look at a sample application that makes use of the browser.

Note that if you run the Market browser with a user who is not logged into the Creative Cloud, the user will be asked to login. You do not need a login button in your application if only the browser uses the Creative SDK.

The main way you will use the Market browser is via the `sharedBrowser` property of `AdobeUXMarketAssetBrowser`. There are two methods for opening up a browser:

+ `popupMarketAssetBrowserWithParent` - This is more generic and allows you to specify which view controller will contain the UI. 
+ `popupMarketAssetBrowserWithCategory ` - This method also lets method you filter by category(ies) as well as default to a specified category.

Both methods let you handle the user action of opening a resource within the application.

A simple use of `popupMarketAssetBrowserWithParent` might look like this:

    [[AdobeUXMarketAssetBrowser sharedBrowser] popupMarketAssetBrowserWithParent:self
       category:nil
       withCategoryFilter:nil
       withCategoryFilterType:AdobeUXMarketAssetBrowserCategoryFilterTypeInclusion
       onSuccess:^(AdobeMarketAsset *itemSelection) {
       }
       onError: ^(NSError * error) {
       }];

Specifying a default category is simple too. You can dynamically fetch categories from the API using the categories method of the `AdobeMarketCategory` class, or you can use one of the constants. As an example:

    [[AdobeUXMarketAssetBrowser sharedBrowser] popupMarketAssetBrowserWithParent:self
       category:kMarketAssetsCategoryBrushes
       withCategoryFilter:nil
       withCategoryFilterType:AdobeUXMarketAssetBrowserCategoryFilterTypeInclusion
       onSuccess:^(AdobeMarketAsset *itemSelection) {
       }
       onError: ^(NSError * error) {
       }];

You have created the market browser, but how do you handle selections from it? The `onSuccess` block executes after a user selects an asset to send to the application. (Remember that the interaction for this differs depending on the user’s view of the market browser. The grid view requires two clicks; the detail view, one.) The block is passed an instance of an `AdobeMarketAsset`. You can get detailed information about the asset (who created it, when it was created, and so on), as well as a thumbnail view of the asset. Optionally, you can choose to download the asset or copy it to the user's Creative Cloud folder. (Again, remember that in the detail view in the market browser, the asset goes directly to the application rather than being copied to the user's folder first.) For our sample application, we simply print metadata about the asset, then request a rendition. Here is the modified `onSuccess` handler:

    onSuccess:^(AdobeMarketAsset *itemSelection) {

       // Ok, let's create a text block of data about the selection for the demo
       NSMutableString *desc = [[NSMutableString alloc] initWithFormat:@"Market Asset: %@\n",
         itemSelection.title ];
       [desc appendFormat:@"Created by: %@\n %@n", itemSelection.creator.firstName,
         itemSelection.creator.lastName];
       [desc appendFormat:@"Featured on: %@\n", itemSelection.featured];
       [desc appendFormat:@"Asset ID: %@\n", itemSelection.assetID];
       [desc appendFormat:@"Date Created: %@\n", itemSelection.dateCreated];
       [desc appendFormat:@"Date Published: %@\n", itemSelection.datePublished];
       [desc appendFormat:@"File Size: %ld\n", itemSelection.fileSize];
       [desc appendFormat:@"Tags: %@\n", itemSelection.tags];
       [((RKCView *)self.view).resultText setText:desc];

       [itemSelection downloadRenditionWithDimension:AdobeMarketImageDimensionWidth
          withSize:250
          withPriority:NSOperationQueuePriorityHigh
          onProgress:nil
          onCompletion:^( UIImage *image , BOOL fromCache ) {
             [((RKCView *)self.view) uiImage].image = image;
             [[((RKCView *)self.view) uiImage] sizeToFit];
           }
          onCancellation:nil
          onError:^(NSError *error) {
             NSLog(@"Error getting rendition: %@", error);
          }];
       }

In the code above, we update a label item in our view with information about the asset. A rendition is then requested, and when it completes, an image is updated with the result. Here are two examples:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/market/market5.jpg"/>
<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/market/market6.jpg"/>

<a name="contentcategories"></a>
## Specifying Content Categories

If only certain content categories (types of content) are relevant to your application, you can specify that when you launch the Market component, so your users see only those categories. There are two ways to determine which categories are usable with the Market Browser. First, the `AdobeMarketCategory` class defines the following constants:

    /** The market asset category for "for placement". */
    extern NSString* const kMarketAssetsCategoryForPlacement;

    /** The market asset category for user interfaces. */
    extern NSString* const kMarketAssetsCategoryUserInterfaces;

    /** The market asset category for vector shapes. */
    extern NSString* const kMarketAssetsCategoryVectorShapes;

    /** The market asset category for icons. */
    extern NSString* const kMarketAssetsCategoryIcons;

    /** The market asset category for patterns. */
    extern NSString* const kMarketAssetsCategoryPatterns;

    /** The market asset category for brushes. */
    extern NSString* const kMarketAssetsCategoryBrushes;

You would pass the appropriate constant into the category: parameter when you call `popupMarketAssetBrowserWithCategory:` or `popupMarketAssetBrowserWithParent: `

You also can fetch categories dynamically. By using this method on AdobeMarketCategory:, your code can dynamically fetch both categories and subcategories:

    categories:onProgress:onCompletion:onCancellation:onError:

This simple example fetches the categories and displays relevant properties:

    [AdobeMarketCategory categories:NSOperationQueuePriorityHigh
       onProgress:nil
       onCompletion:^(NSArray *categories) {
          for(AdobeMarketCategory *cat in categories) {
             NSLog(@"cat %@\n hasSub? %hhd\n subCats %@\nEnglish name: %@\n\n",
               cat.categoryName, cat.hasSubCategories, cat.subCategories,
               cat.englishCategoryName);
          }
       }
       onCancellation:nil
       onError:nil];

This data could be fetched and then cached in your application, to provide more control over which assets are displayed in the browser. In our example, this code was added to the same code that makes a request to open the Market browser. To see the result, check the login XCode.

<a name="reference"></a>
## Class Reference

+ [AdobeMarketAsset](/Classes/AdobeMarketAsset.html)
+ [AdobeMarketCategory](/Classes/AdobeMarketCategory.html)
+ [AdobeUXMarketAssetBrowser](/Classes/AdobeUXMarketAssetBrowser.html) 

