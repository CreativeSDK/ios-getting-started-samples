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
#import <AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h>
#import <AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h>

#import "ViewController.h"

#warning Please update the ClientId and Secret to the values provided by creativesdk.com or from Adobe
static NSString * const kCreativeSDKClientId = @"Change Me";
static NSString * const kCreativeSDKClientSecret = @"Change Me";

@interface ViewController () <AdobeUXAssetBrowserViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *selectionThumbnailImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set the client ID and secret values so the SDK can identify the calling app.
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:kCreativeSDKClientId
                                                               withClientSecret:kCreativeSDKClientSecret];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Actions

- (IBAction)showLibraryBrowserTouchUpInside
{
    // Only show the Library datasource in the Asset Browser. This helps keep this test app focused.
    AdobeAssetDataSourceFilter *datasourceFilter =
        [[AdobeAssetDataSourceFilter alloc] initWithDataSources:@[AdobeAssetDataSourceLibrary]
                                                     filterType:AdobeAssetDataSourceFilterInclusive];
    
    // Create an Asset Browser configuration object that can be used to filter the datasources and
    // to specify the supported Library item types.
    AdobeUXAssetBrowserConfiguration *configuration = [AdobeUXAssetBrowserConfiguration new];
    configuration.dataSourceFilter = datasourceFilter;
    
    // Create a new instance of the Asset Brwoser view contrller, set it's configuration and
    // delegate and present it.
    AdobeUXAssetBrowserViewController *assetBrowser =
        [AdobeUXAssetBrowserViewController assetBrowserViewControllerWithConfiguration:configuration
                                                                              delegate:self];
    
    [self presentViewController:assetBrowser animated:YES completion:nil];
}

#pragma mark - AdobeUXAssetBrowserViewControllerDelegate

- (void)assetBrowserDidSelectAssets:(AdobeSelectionAssetArray *)itemSelections
{
    // Dismiss the Asset Browser view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Grab the first selected item. This item is the a selection object that has information about
    // the selected item(s). We can use this object to pinpoint the selected Library item and
    // perform interesting tasks, like downloading a thumbnail.
    AdobeSelectionLibraryAsset *librarySelection = itemSelections.firstObject;
    
    // Make sure we're dealing with a Library selection object.
    if (IsAdobeSelectionLibraryAsset(librarySelection))
    {
        // Grab the Library object.
        AdobeAssetLibrary *library = (AdobeAssetLibrary *)librarySelection.selectedItem;
        
        // Get the first selected item ID.
        NSString *selectedImageId = librarySelection.selectedImageIDs.firstObject;
        
        // Now get the selected item, in this case an image, from the Library. Note that, for this
        // demo, we only handline images, however all other supported Library item types can be
        // retrieved and processed.
        AdobeAssetLibraryItemImage *libraryImage = library.images[selectedImageId];
        
        // Get the rendition file reference. This reference can be used to download the rendition
        // from the server.
        AdobeAssetFile *thumbnailFile = libraryImage.rendition;
        
        // If the Library item doesn't have a rendition, fall back to the actual image data.
        if (thumbnailFile == nil)
        {
            thumbnailFile = libraryImage.image;
        }
        
        // We can't find any usable data to download, we bail out.
        if (thumbnailFile == nil)
        {
            NSString *message = @"For the purposes of this demo, please select an image/graphic Library item type.";
            
            NSLog(@"%@", message);
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Demo"
                                                                                     message:message
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            return;
        }
        
        // Start the activity indicator to get the user feedback.
        [self.activityIndicator startAnimating];
        
        // Kick off the download action. Here we're requesting a PNG rendition with dimensions of
        // 1024×1024 points. The network request priority is set to normal. We've opted to not
        // specify a progress handler, however, we've chosen to listen for when the thumbnail is
        // downloaded successfully, so we can display it, when the request has been canceled and
        // for when there is an error with the request.
        [thumbnailFile downloadRenditionWithType:AdobeAssetFileRenditionTypePNG
                                      dimensions:CGSizeMake(1024, 1024)
                                 requestPriority:NSOperationQueuePriorityNormal
                                   progressBlock:NULL
                                    successBlock:^(NSData *data, BOOL fromCache)
         {
             // Try to parse the data.
             UIImage *thumbnailImage = [UIImage imageWithData:data];
             
             if (thumbnailImage != nil)
             {
                 // Everything is good, display the image and stop the activity indicator.
                 self.selectionThumbnailImageView.image = thumbnailImage;
                 
                 [self.activityIndicator stopAnimating];
             }
             else
             {
                 NSLog(@"The returned data cannot be converted into an image.");
             }
         }
                               cancellationBlock:^
         {
             NSLog(@"Rendition request canceled.");
             
             [self.activityIndicator stopAnimating];
         }
                                      errorBlock:^(NSError *error)
         {
             NSLog(@"An error occured when attempting to download a rendition: %@", error);
             
             [self.activityIndicator stopAnimating];
         }];
    }
    else
    {
        NSLog(@"The selected item isn't a Library selection.");
    }
}

- (void)assetBrowserDidEncounterError:(NSError *)error
{
    // Dismiss the Asset Browser
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Handle the error. Here we only print out a log of the error.
    NSLog(@"An error occurred: %@", error);
}

@end
