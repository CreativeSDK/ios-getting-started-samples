/*
 * Copyright (c) 2015 Adobe Systems Incorporated. All rights reserved.
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

#warning Please update the client ID and secret values to match the ones provided by creativesdk.com
static NSString * const kCreativeSDKClientId = @"Change me";
static NSString * const kCreativeSDKClientSecret = @"Change me";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *modificationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:kCreativeSDKClientId
                                                                   clientSecret:kCreativeSDKClientSecret
                                                                   enableSignUp:NO];
}

- (IBAction)showAssetBrowserButtonTouchUpInside
{
    // Create a datasource filter object that excludes the Libraries and Photos datasources. For
    // the purposes of this demo, we'll only deal with non-complex datasources like the Files
    // datasource.
    AdobeAssetDataSourceFilter *dataSourceFilter =
        [[AdobeAssetDataSourceFilter alloc] initWithDataSources:@[AdobeAssetDataSourceLibrary, AdobeAssetDataSourcePhotos]
                                                     filterType:AdobeAssetDataSourceFilterExclusive];
    
    // Create an Asset Browser configuration object and set the datasource filter object.
    AdobeUXAssetBrowserConfiguration *assetBrowserConfiguration = [AdobeUXAssetBrowserConfiguration new];
    assetBrowserConfiguration.dataSourceFilter = dataSourceFilter;
    
    [[AdobeUXAssetBrowser sharedBrowser] popupFileBrowserWithParent:self
                                                      configuration:assetBrowserConfiguration
                                                          onSuccess:^(AdobeSelectionAssetArray *itemSelections)
    {
        if (itemSelections.count == 0)
        {
            // Nothing selected so there is nothing to do.
            return;
        }
        
        // Get the first asset-selection object.
        AdobeSelectionAsset *assetSelection = itemSelections.firstObject;
        
        // Grab the generic AdobeAsset object from the selection object.
        AdobeAsset *selectedAsset = assetSelection.selectedItem;
        
        self.nameLabel.text = selectedAsset.name;
        
        // We should have a static instance of the date formatter here to avoid a performance hit,
        // but we'll go ahead and create one every time to the purposes of this demo.
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        dateFormatter.locale = [NSLocale currentLocale];
        
        self.modificationDateLabel.text = [dateFormatter stringFromDate:selectedAsset.modificationDate];
        
        // Make sure it's an AdobeAssetFile object.
        if (!IsAdobeAssetFile(selectedAsset))
        {
            return;
        }
        
        AdobeAssetFile *selectedAssetFile = (AdobeAssetFile *)selectedAsset;
        
        // Nicely format the file size
        if (selectedAssetFile.fileSize > 0)
        {
            self.sizeLabel.text = [NSByteCountFormatter stringFromByteCount:selectedAssetFile.fileSize
                                                                 countStyle:NSByteCountFormatterCountStyleFile];
        }
        
        // Download a thumbnail for common image formats
        if ([selectedAssetFile.type isEqualToString:kAdobeMimeTypeJPEG] ||
            [selectedAssetFile.type isEqualToString:kAdobeMimeTypePNG] ||
            [selectedAssetFile.type isEqualToString:kAdobeMimeTypeGIF] ||
            [selectedAssetFile.type isEqualToString:kAdobeMimeTypeBMP])
        {
            [self.loadingActivityIndicator startAnimating];
            
            // Round the width and the height up to avoid any half-pixel values.
            CGSize thumbnailSize = CGSizeMake(ceilf(self.thumbnailImageView.frame.size.width),
                                              ceilf(self.thumbnailImageView.frame.size.height));
            
            [selectedAssetFile getRenditionWithType:AdobeAssetFileRenditionTypePNG
                                           withSize:thumbnailSize
                                       withPriority:NSOperationQueuePriorityNormal
                                         onProgress:nil
                                       onCompletion:^(NSData *data, BOOL fromCache)
            {
                UIImage *rendition = [UIImage imageWithData:data];
                
                self.thumbnailImageView.image = rendition;
                
                [self.loadingActivityIndicator stopAnimating];
                
                NSLog(@"Successfully downloaded a thumbnail.");
                
            } onCancellation:^{
                
                NSLog(@"The rendition request was cancelled.");
                
                [self.loadingActivityIndicator stopAnimating];
                
            } onError:^(NSError *error) {
                
                NSLog(@"There was a problem downloading the file rendition: %@", error);
                
                [self.loadingActivityIndicator stopAnimating];
            }];
        }
        else
        {
            NSString *message = @"The selected file type isn't a common image format so no "
                "thumbnail will be fetched from the server.\n\nTry selecting a JPEG, PNG or BMP file.";
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Demo Project"
                                                                                     message:message
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:NULL];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    } onError:^(NSError *error) {
        
        NSLog(@"An error occurred: %@", error);
    }];
}

@end
