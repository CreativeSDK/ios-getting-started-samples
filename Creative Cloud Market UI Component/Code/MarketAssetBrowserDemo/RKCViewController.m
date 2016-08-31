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
//  RKCViewController.m
//  PSDExtraction
//


#import "RKCViewController.h"
#import "RKCView.h"
#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h> // AdobeUXAuthManager.h
#import <AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h> //
#import <AdobeCreativeSDKMarketUX/AdobeCreativeSDKMarketUX.h> //AdobeUXMarketAssetBrowser.h>

@interface RKCViewController () <AdobeUXMarketBrowserViewControllerDelegate>

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
    static NSString* const CreativeSDKClientSecret = @"changemetoo";
    
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId withClientSecret:CreativeSDKClientSecret];
        
    //The authManager caches our login, so check on startup
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    if(loggedIn) {
        NSLog(@"We have a cached logged in");
        [((RKCView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        AdobeAuthUserProfile *up = [AdobeUXAuthManager sharedManager].userProfile;
        NSLog(@"User Profile: %@", up);
        [((RKCView *)self.view).showMarketBrowserButton setHidden:NO];
        
    }
    
}


- (void)doLogin {
    
    //Are we logged in?
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    
    if(!loggedIn) {
        
        [[AdobeUXAuthManager sharedManager] login:self
                                        onSuccess: ^(AdobeAuthUserProfile * userProfile) {
                                            [((RKCView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
                                            [((RKCView *)self.view).showMarketBrowserButton setHidden:NO];
                                        }
         
                                          onError: ^(NSError * error) {
                                              NSLog(@"Error in Login: %@", error);
                                          }];
        
    } else {
        
        [[AdobeUXAuthManager sharedManager] logout:^void {
            [((RKCView *)self.view).loginButton setTitle:@"Login" forState:UIControlStateNormal];
            [((RKCView *)self.view).showMarketBrowserButton setHidden:YES];
        } onError:^(NSError *error) {
            NSLog(@"Error on Logout: %@", error);
        }];
    }
}

- (void)showMarketBrowser
{
    AdobeUXMarketBrowserConfiguration *configuration = [AdobeUXMarketBrowserConfiguration new];
    configuration.categories = @[kMarketAssetsCategoryBrushes,
                                 kMarketAssetsCategoryForPlacement,
                                 kMarketAssetsCategoryIcons,
                                 kMarketAssetsCategoryPatterns,
                                 kMarketAssetsCategoryUserInterfaces,
                                 kMarketAssetsCategoryVectors];
    configuration.categoryFilterType = AdobeUXMarketBrowserCategoryFilterTypeInclusion;
    
    AdobeUXMarketBrowserViewController *marketViewController =
    [AdobeUXMarketBrowserViewController marketBrowserViewControllerWithConfiguration:configuration
                                                                            delegate:self];
    
    [self presentViewController:marketViewController animated:YES completion:nil];
}

#pragma mark - AdobeUXMarketBrowserViewControllerDelegate

- (void)marketBrowserDidSelectAsset:(AdobeMarketAsset *)itemSelection
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (itemSelection != nil)
    {
        NSLog(@"Market asset selected: %@", itemSelection);
        
        // Ok, let's create a text block of data about the selection for the demo
        NSMutableString *desc = [[NSMutableString alloc] initWithFormat:@"Market Asset: %@\n", itemSelection.name ];
        
        [desc appendFormat:@"Created by: %@\n %@n", itemSelection.creator.firstName, itemSelection.creator.lastName];
        [desc appendFormat:@"Featured on: %@\n", itemSelection.dateFeatured];
        [desc appendFormat:@"Asset ID: %@\n", itemSelection.assetID];
        [desc appendFormat:@"Date Created: %@\n", itemSelection.dateCreated];
        [desc appendFormat:@"Date Published: %@\n", itemSelection.datePublished];
        [desc appendFormat:@"File Size: %ld\n", itemSelection.fileSize];
        [desc appendFormat:@"Tags: %@\n", itemSelection.tags];
        
        RKCView *view = (RKCView *)self.view;
        view.resultText.text = desc;
        
        [itemSelection downloadRenditionWithDimension:AdobeCommunityAssetImageDimensionWidth
                                                 size:250
                                                 type:AdobeCommunityAssetImageTypeJPEG
                                             priority:NSOperationQueuePriorityHigh
                                        progressBlock:nil
                                         successBlock:^(NSData *imageData, BOOL fromCache)
         {
             view.uiImage.image = [UIImage imageWithData:imageData];
         }
                                    cancellationBlock:nil
                                           errorBlock:^(NSError *error)
         {
             NSLog(@"Error getting rendition: %@", error);
         }];
    }
}

- (void)marketBrowserDidEncounterError:(NSError *)error
{
    NSLog(@"Market Browser failed with error: %@", error);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)marketBrowserDidClose
{
    NSLog(@"Market Browser was closed without selecting a Market Asset.");
}


@end
