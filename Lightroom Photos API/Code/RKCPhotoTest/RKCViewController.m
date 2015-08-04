//
//Copyright (c) 2015 Adobe Systems Incorporated. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//
//
//  RKCViewController.m
//  RKCPhotoTest
//

#import "RKCViewController.h"
#import "RKCView.h"
#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h> //uses AdobeUXAuthManager.h
#import <AdobeCreativeSDKCommonUX/AdobeCreativeSDKCommonUX.h>
#import <AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h>//uses AdobeAssetFile.h AdobePhotoAsset.h AdobePhotoPage.h AdobeSelectionAsset.h AdobePhotoCatalog.h & AdobePhotoCollection.h
#import <AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h> //uses AdobeUXAssetBrowser.h



@interface RKCViewController ()

@end

@implementation RKCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    RKCView *tv = [[RKCView alloc] initWithFrame:frame];
    
    self.view = tv;
    
    // Please update the ClientId and Secret to the values provided by creativesdk.com or from Adobe
    static NSString* const CreativeSDKClientId = @"changeme";
    static NSString* const CreativeSDKClientSecret = @"changeme";

    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId clientSecret:CreativeSDKClientSecret enableSignUp:true];
    
    //The authManager caches our login, so check on startup
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    if(loggedIn) {
        [((RKCView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        [((RKCView *)self.view).showAlbumsButton setHidden:NO];
        
    }
    
}

- (void)doLogin {
    
    //Are we logged in?
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    
    if(!loggedIn) {
        
        [[AdobeUXAuthManager sharedManager] login:self
                                        onSuccess: ^(AdobeAuthUserProfile * userProfile) {
                                            [((RKCView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
                                            [((RKCView *)self.view).showAlbumsButton setHidden:NO];
                                        }
         
                                          onError: ^(NSError * error) {
                                              NSLog(@"Error in Login: %@", error);
                                          }];
        
    } else {
        
        [[AdobeUXAuthManager sharedManager] logout:^void {
            [((RKCView *)self.view).loginButton setTitle:@"Login" forState:UIControlStateNormal];
            [((RKCView *)self.view).showAlbumsButton setHidden:YES];
        } onError:^(NSError *error) {
            NSLog(@"Error on Logout: %@", error);
        }];
    }
}

- (void)showPhotos {

    
    [AdobePhotoCatalog listOfType:AdobePhotoCatalogTypeLightroom onCompletion:^(NSArray *catalogs) {
        NSLog(@"number of catalogs - %lu", (unsigned long)[catalogs count]);
        
        for(AdobePhotoCatalog *catalog in catalogs) {
            NSLog(@"Catalog name: %@", catalog.name);
            
            /* Now get collections */
            [catalog listCollectionsAfterName:nil withLimit:100 includeDeletedCollections:NO onCompletion:^(NSArray *collections) {

                __block int y = 275;

                for(AdobePhotoCollection *collection in collections) {
                    NSLog(@"Collection name: %@", collection.name);
                    [collection listAssetsOnPage: nil
                                    withSortType:AdobePhotoCollectionSortByDate
                                       withLimit:100
                                        withFlag:AdobePhotoCollectionFlagUnflagged
                                    onCompletion:^(NSArray *assets, AdobePhotoPage *previousPage, AdobePhotoPage *nextPage) {
                         for(AdobePhotoAsset *asset in assets) {
                             NSLog(@"Asset name: %@", asset.name);
                             
                             AdobePhotoAssetRenditionDictionary *assetDict = asset.renditions;
                             
                             NSString *RenditionSize;
                             if([assetDict valueForKey:AdobePhotoAssetRenditionImageThumbnail2x]!= nil) {
                                 NSLog(@"ok going to get thumbnail2x");
                                 RenditionSize = AdobePhotoAssetRenditionImageThumbnail2x;
                             } else if ([assetDict valueForKey:AdobePhotoAssetRenditionImageThumbnail]!= nil) {
                                 NSLog(@"ok going to get thumbnail1x");
                                 RenditionSize = AdobePhotoAssetRenditionImageThumbnail;
                             }
                             
                             if(RenditionSize != nil) {
                                 [asset downloadRendition:asset.renditions[RenditionSize]
                                             withPriority:NSOperationQueuePriorityNormal
                                               onProgress:^(double fractionCompleted) {
                                                   //Nothing here...
                                               } onCompletion:^(NSData *data, BOOL wasCached) {
                                                   
                                                   UIImage *preview = [UIImage imageWithData:data];
                                                   UIImageView *uiImage = [[UIImageView alloc] initWithImage:preview];
                                                   uiImage.frame = CGRectMake(0, y, preview.size.width, preview.size.height);
                                                   [self.view addSubview:uiImage];
                                                   y+=preview.size.height+10;
                                                   
                                                   UIScrollView *subview = (UIScrollView *)self.view;
                                                   if(subview.contentSize.height < y) {
                                                       subview.contentSize = CGSizeMake(subview.contentSize.width, y);
                                                   }
                                                   
                                               } onCancellation:^{
                                                   NSLog(@"Cancellation");
                                               } onError:^(NSError *error) {
                                                   NSLog(@"Error %@", error);
                                               }];
                             } else {
                                 NSLog(@"Error: Thumbnail rendition is not defined");
                             }
                                 
                         }
                         
                         
                     }
                                         onError:^(NSError *error) {
                                             NSLog(@"Error: %@", error);
                                         }];

                    
/*                    [collection listAssetsUsingOrder:nil
                      withOrderRestriction:AdobePhotoCollectionSortByDate
                                withOrderRestriction:AdobePhotoOrderRestrictionAfterValue
                                           withLimit:100
                                            withFlag:AdobePhotoCollectionFlagUnflagged
                                        onCompletion:^(NSArray *assets, NSString *previousPage, NSString *nextPage) {
 
                                            for(AdobePhotoAsset *asset in assets) {
                                                NSLog(@"Asset name: %@", asset.name);
 
                                                AdobePhotoAssetRenditionDictionary *assetDict = asset.renditions;
 
                                                if([assetDict valueForKey:AdobePhotoAssetRenditionImageThumbnail2x]!= nil) {
                                                    NSLog(@"ok going to get thumbnail2x");
                                                    [asset downloadRendition:asset.renditions[AdobePhotoAssetRenditionImageThumbnail2x]
                                                                withPriority:NSOperationQueuePriorityNormal
                                                                  onProgress:^(double fractionCompleted) {
                                                                      //Nothing here...
                                                                  } onCompletion:^(NSData *data, BOOL wasCached) {
                                                                      
                                                                      UIImage *preview = [UIImage imageWithData:data];
                                                                      UIImageView *uiImage = [[UIImageView alloc] initWithImage:preview];
                                                                      uiImage.frame = CGRectMake(0, y, preview.size.width, preview.size.height);
                                                                      [self.view addSubview:uiImage];
                                                                      y+=preview.size.height+10;
                                                                      
                                                                      UIScrollView *subview = (UIScrollView *)self.view;
                                                                      if(subview.contentSize.height < y) {
                                                                          subview.contentSize = CGSizeMake(subview.contentSize.width, y);
                                                                      }
                                                                      
                                                                  } onCancellation:^{
                                                                      NSLog(@"Cancellation");
                                                                  } onError:^(NSError *error) {
                                                                      NSLog(@"Error %@", error);
                                                                  }];
                                                    
                                                    
                                                } else if([assetDict valueForKey:AdobePhotoAssetRenditionImageThumbnail]!= nil) {
                                                    NSLog(@"ok going to get thumbnail2x");
                                                    [asset downloadRendition:asset.renditions[AdobePhotoAssetRenditionImageThumbnail]
                                                                withPriority:NSOperationQueuePriorityNormal
                                                                  onProgress:^(double fractionCompleted) {
                                                                      //Nothing here...
                                                                  } onCompletion:^(NSData *data, BOOL wasCached) {
                                                                      
                                                                      UIImage *preview = [UIImage imageWithData:data];
                                                                      UIImageView *uiImage = [[UIImageView alloc] initWithImage:preview];
                                                                      uiImage.frame = CGRectMake(0, y, preview.size.width, preview.size.height);
                                                                      [self.view addSubview:uiImage];
                                                                      y+=preview.size.height+10;
                                                                      
                                                                      UIScrollView *subview = (UIScrollView *)self.view;
                                                                      if(subview.contentSize.height < y) {
                                                                          subview.contentSize = CGSizeMake(subview.contentSize.width, y);
                                                                      }
                                                                      
                                                                  } onCancellation:^{
                                                                      NSLog(@"Cancellation");
                                                                  } onError:^(NSError *error) {
                                                                      NSLog(@"Error %@", error);
                                                                  }];
                                                    
                                                }
                                            }
                                            
                                            
                                        }
                                             onError:^(NSError *error) {
                        NSLog(@"Error: %@", error);
                    }];
*/
                }
                
            } onError:^(NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
            
        }
        
    } onError:^(NSError *error) {
        NSLog(@"um error");
        NSLog(@"%@", error);
    }];
    
}


@end
