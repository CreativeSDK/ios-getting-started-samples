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
#import <AdobeCreativeSDKMarketUX/AdobeCreativeSDKMarketUX.h>

#import "ViewController.h"

#error The Creative SDK Market Browser is no longer supported. Adobe will release a new version of the SDK in November 2017, and this component will not be included in the new version. We suggest removing this component from your application as soon as possible to avoid any interruption in service. You can find more information on this deprecation here: https://creativesdk.zendesk.com/hc/en-us/articles/115004788463-End-of-Support-for-the-Creative-SDK-Image-Editor-UI-Color-UI-Market-Browser-and-Labs-Components

#warning Please update the client ID and secret values to match the ones provided by creativesdk.com
static NSString * const kCreativeSDKClientId = @"Change me";
static NSString * const kCreativeSDKClientSecret = @"Change me";
static NSString * const kCreativeSDKRedirectURLString = @"Change me";

@interface ViewController () <AdobeUXMarketBrowserViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectionThumbnailImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set the client ID and secret values so the CSDK can identify the calling app. The three
    // specified scopes are required at a minimum.
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:kCreativeSDKClientId
                                                                   clientSecret:kCreativeSDKClientSecret
                                                            additionalScopeList:@[AdobeAuthManagerUserProfileScope,
                                                                                  AdobeAuthManagerEmailScope,
                                                                                  AdobeAuthManagerAddressScope]];
    
    // Also set the redirect URL, which is required by the CSDK authentication mechanism.
    [AdobeUXAuthManager sharedManager].redirectURL = [NSURL URLWithString:kCreativeSDKRedirectURLString];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.logoutButton.hidden = ![AdobeUXAuthManager sharedManager].isAuthenticated;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Actions

- (IBAction)displayMarketBrowserButtonTouchUpInside
{
    // Create an instance of the Market Browser view controller and display it.
    AdobeUXMarketBrowserViewController *mbvc = [AdobeUXMarketBrowserViewController marketBrowserViewControllerWithConfiguration:nil
                                                                                                                       delegate:self];
    
    [self presentViewController:mbvc animated:YES completion:nil];
}

- (IBAction)logoutButtonTouchUpInside
{
    [[AdobeUXAuthManager sharedManager] logout:^
    {
        NSLog(@"Successfully logged out.");
    }
                                       onError:^(NSError *error)
    {
        NSLog(@"There was an error when logging out: %@", error);
    }];
}

#pragma mark - AdobeUXMarketBrowserViewControllerDelegate

- (void)marketBrowserDidSelectAsset:(AdobeMarketAsset *)itemSelection
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Print out some useful information about the selected Market Asset
    NSLog(@"Selected Market Asset:\n\tID: %@\n\tName: %@\n\tLabel: %@\n\tCategory: %@\n\tCreator: %@\n\tDimensions: %@\n\tMIME Type:%@",
          itemSelection.assetID,
          itemSelection.name,
          itemSelection.label,
          itemSelection.category.englishName,
          itemSelection.creator.displayName,
          NSStringFromCGSize(itemSelection.dimensions),
          itemSelection.nativeMimeType);
    
    // Start the activity indicator while we fetch the thumbnail.
    [self.activityIndicator startAnimating];
    
    // Request a thumbnail for the selected Market Asset. We use the width as the reference size
    // and the value is the width of our UIImageView. The type of the thumbnail file is set to PNG
    // which is ideal for displaying. We also set the priority of the network connection.
    [itemSelection downloadRenditionWithDimension:AdobeCommunityAssetImageDimensionWidth
                                             size:CGRectGetWidth(self.selectionThumbnailImageView.frame)
                                             type:AdobeCommunityAssetImageTypePNG
                                         priority:NSOperationQueuePriorityNormal
                                    progressBlock:^(double fractionCompleted)
    {
        NSLog(@"Downloading... (%2.f%%)", fractionCompleted * 100.0);
    }
                                     successBlock:^(NSData *imageData, BOOL fromCache)
    {
        UIImage *thumbnail = [UIImage imageWithData:imageData];
        
        if (thumbnail == nil)
        {
            NSLog(@"Could not create a usable UIImage instance from returned data.");
        }
        else
        {
            // We have everything we need, so we display the image.
            self.selectionThumbnailImageView.image = thumbnail;
        }
        
        [self.activityIndicator stopAnimating];
    }
                                cancellationBlock:^
    {
        NSLog(@"Underlaying network connection was canceled.");
        
        [self.activityIndicator stopAnimating];
    }
                                       errorBlock:^(NSError *error)
    {
        NSLog(@"An error occurred while downloading a thumbnail for the selected Market Asset: %@", error);
        
        [self.activityIndicator stopAnimating];
    }];
}

- (void)marketBrowserDidEncounterError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"An error occurred in the Market Browser: %@", error);
}

@end
