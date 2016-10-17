/*
 * Copyright (c) 2016 Adobe Systems Incorporated. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>
#import <AdobeCreativeSDKCommonUX/AdobeCreativeSDKCommonUX.h>
#import <AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h>

#import "RKCViewController.h"

#import "RKCView.h"

#warning Please update the ClientId and Secret to the values provided by creativesdk.com or from Adobe
static NSString * const kCreativeSDKClientId = @"Change Me";
static NSString * const kCreativeSDKClientSecret = @"Change Me";


@interface RKCViewController ()

@end

@implementation RKCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    RKCView *tv = [[RKCView alloc] initWithFrame:frame];
    
    self.view = tv;
    
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:kCreativeSDKClientId
                                                               withClientSecret:kCreativeSDKClientSecret];
    
    //The authManager caches our login, so check on startup
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    
    if (loggedIn)
    {
        [((RKCView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        ((RKCView *)self.view).showAlbumsButton.hidden = NO;
    }
}

- (void)doLogin
{
    //Are we logged in?
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    
    if (!loggedIn)
    {
        [[AdobeUXAuthManager sharedManager] login:self
                                        onSuccess:^(AdobeAuthUserProfile *userProfile)
        {
            [((RKCView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
            ((RKCView *)self.view).showAlbumsButton.hidden = NO;
        }
                                          onError:^(NSError *error)
        {
            NSLog(@"Error in Login: %@", error);
        }];
        
    }
    else
    {
        [[AdobeUXAuthManager sharedManager] logout:^
        {
            [((RKCView *)self.view).loginButton setTitle:@"Login" forState:UIControlStateNormal];
            ((RKCView *)self.view).showAlbumsButton.hidden = YES;
        }
                                           onError:^(NSError *error)
        {
            NSLog(@"Error on Logout: %@", error);
        }];
    }
}

- (void)showPhotos
{
    [AdobePhotoCatalog listOfType:AdobePhotoCatalogTypeLightroom
                     successBlock:^(AdobePhotoCatalogs *catalogs)
    {
        NSLog(@"number of catalogs - %lu", (unsigned long)catalogs.count);
        
        for(AdobePhotoCatalog *catalog in catalogs)
        {
            NSLog(@"Catalog name: %@", catalog.name);
            
            // Now get collections
            [catalog listCollectionsAfterName:nil
                                        limit:100
                    includeDeletedCollections:NO
                                 successBlock:^(AdobePhotoCollections *collections)
            {
                __block NSInteger y = 275;
                
                for (AdobePhotoCollection *collection in collections)
                {
                    NSLog(@"Collection name: %@", collection.name);
                    
                    [collection listAssetsOnPage: nil
                                        sortType:AdobePhotoCollectionSortByDate
                                           limit:100
                                            flag:AdobePhotoCollectionFlagUnflagged
                                    successBlock:^(NSArray *assets, AdobePhotoPage *previousPage, AdobePhotoPage *nextPage)
                    {
                        for (AdobePhotoAsset *asset in assets)
                        {
                            NSLog(@"Asset name: %@", asset.name);
                            
                            AdobePhotoAssetRenditionDictionary *assetDict = asset.renditions;
                            NSString *photoAssetRenditionSize = nil;
                            
                            if (assetDict[AdobePhotoAssetRenditionImageThumbnail2x] != nil)
                            {
                                NSLog(@"ok going to get thumbnail2x");
                                photoAssetRenditionSize = AdobePhotoAssetRenditionImageThumbnail2x;
                            }
                            else if (assetDict[AdobePhotoAssetRenditionImageThumbnail] != nil)
                            {
                                NSLog(@"ok going to get thumbnail1x");
                                photoAssetRenditionSize = AdobePhotoAssetRenditionImageThumbnail;
                            }
                            
                            if (photoAssetRenditionSize != nil)
                            {
                                [asset downloadRendition:asset.renditions[photoAssetRenditionSize]
                                         requestPriority:NSOperationQueuePriorityNormal
                                           progressBlock:NULL
                                            successBlock:^(NSData *data, BOOL wasCached)
                                {
                                    UIImage *preview = [UIImage imageWithData:data];
                                    
                                    UIImageView *uiImage = [[UIImageView alloc] initWithImage:preview];
                                    uiImage.frame = CGRectMake(10, y, preview.size.width, preview.size.height);
                                    [self.view addSubview:uiImage];
                                    
                                    y += preview.size.height + 10;
                                    
                                    UIScrollView *subview = (UIScrollView *)self.view;
                                    
                                    if (subview.contentSize.height < y)
                                    {
                                        subview.contentSize = CGSizeMake(subview.contentSize.width, y);
                                    }
                                }
                                       cancellationBlock:^
                                {
                                    NSLog(@"Cancellation");
                                }
                                              errorBlock:^(NSError *error)
                                {
                                    NSLog(@"Error %@", error);
                                }];
                            }
                            else
                            {
                                NSLog(@"Error: Thumbnail rendition is not defined");
                            }
                        }
                    }
                                      errorBlock:^(NSError *error)
                    {
                        NSLog(@"Error: %@", error);
                    }];
                }
            }
                                   errorBlock:^(NSError *error)
            {
                NSLog(@"Error: %@", error);
            }];
        }
    }
                       errorBlock:^(NSError *error)
    {
        NSLog(@"%@", error);
    }];
}

@end
