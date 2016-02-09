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

#import "LayerTableViewCell.h"

#warning Please update the client ID and secret values to match the ones provided by creativesdk.com
static NSString * const kCreativeSDKClientId = @"Change me";
static NSString * const kCreativeSDKClientSecret = @"Change me";

@interface ViewController () <AdobeUXAssetBrowserViewControllerDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *psdFileNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) AdobeAssetPSDFile *psdFile;
@property (strong, nonatomic) NSArray<AdobePSDLayerNode *> *selectedLayers;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:kCreativeSDKClientId
                                                                   clientSecret:kCreativeSDKClientSecret
                                                                   enableSignUp:NO];
    
    self.tableView.layoutMargins = UIEdgeInsetsZero;
}

#pragma mark - UI Actions

- (IBAction)pickPSDFileButtonTouchUpInside
{
    // Create a datasource filter object that only displays the Files datasource. For the purposes
    // of this demo, we'll only deal with non-complex datasources like the Files datasource.
    AdobeAssetDataSourceFilter *dataSourceFilter =
        [[AdobeAssetDataSourceFilter alloc] initWithDataSources:@[AdobeAssetDataSourceFiles]
                                                     filterType:AdobeAssetDataSourceFilterInclusive];
    
    // Limit the types of the files that can be selected to Photoshop (.psd) files.
    AdobeAssetMIMETypeFilter *mimeTypeFilter =
        [[AdobeAssetMIMETypeFilter alloc] initWithMIMETypes:@[kAdobeMimeTypePhotoshop]
                                                 filterType:AdobeAssetMIMETypeFilterTypeInclusion];
    
    // Create an Asset Browser configuration object and configure it.
    AdobeUXAssetBrowserConfiguration *configuration = [AdobeUXAssetBrowserConfiguration new];
    
    configuration.dataSourceFilter = dataSourceFilter;
    configuration.mimeTypeFilter = mimeTypeFilter;
    configuration.options = EnablePSDLayerExtraction | EnableMultiplePSDLayerSelection;
    
    // Create an instance of the Asset Browser view controller
    AdobeUXAssetBrowserViewController *assetBrowserViewController =
        [AdobeUXAssetBrowserViewController assetBrowserViewControllerWithConfiguration:configuration
                                                                              delegate:self];
    
    // Present the Asset Browser view controller
    [self presentViewController:assetBrowserViewController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.selectedLayers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [LayerTableViewCell new];
    }
    
    AdobePSDLayerNode *layer = self.selectedLayers[indexPath.row];
    
    cell.layerId = layer.layerId;
    
    NSString *type = nil;
    
    switch (layer.type)
    {
        case AdobePSDLayerNodeTypeRGBPixels:
        {
            type = @"RGB";
            break;
        }
        case AdobePSDLayerNodeTypeSolidColor:
        {
            type = @"Solid color";
            break;
        }
        case AdobePSDLayerNodeTypeGroup:
        {
            type = @"Layer Group";
            break;
        }
        case AdobePSDLayerNodeTypeAdjustment:
        {
            type = @"Adjustment";
            break;
        }
        case AdobePSDLayerNodeTypeUnknown:
        {
            type = @"Unknown";
            break;
        }
    }
    
    // Create a temporary location for the result string.
    NSString *layerInformation = [NSString stringWithFormat:@"Selected Layer: %li\n"
                                  "Layer name: %@\n"
                                  "Type: %@\n"
                                  "Layer ID: %@\n"
                                  "Layer Index: %li\n"
                                  "Visible: %@",
                                  (long)indexPath.row,
                                  layer.name,
                                  type,
                                  layer.layerId,
                                  (long)layer.layerIndex,
                                  layer.visible ? @"Yes" : @"No"];
    
    cell.layerInformation = layerInformation;
    
    // Download a thumbnail for the specific layer
    [self.psdFile downloadRenditionForLayerID:layer.layerId
                                  layerCompID:nil
                                renditionType:AdobeAssetFileRenditionTypePNG
                                   dimensions:CGSizeMake(120, 0)
                              requestPriority:NSOperationQueuePriorityHigh
                                progressBlock:NULL
                                 successBlock:^(NSData *data, BOOL fromCache)
     {
         if ([cell.layerId isEqualToNumber:layer.layerId])
         {
             UIImage *image = [UIImage imageWithData:data];
             
             cell.thumbnailImage = image;
         }
     }
                            cancellationBlock:^
     {
         NSLog(@"Layer rendition cancelled for layer: %@", layer);
     }
                                   errorBlock:^(NSError *error)
     {
         NSLog(@"An error occurred when fetching the rendition for layer: %@", layer);
     }];
    
    return cell;
}

#pragma mark - AdobeUXAssetBrowserViewControllerDelegate

- (void)assetBrowserDidSelectAssets:(AdobeSelectionAssetArray *)itemSelections
{
    // Dismiss the Asset Browser
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Grab the first selection object.
    AdobeSelectionAsset *itemSelection = itemSelections.firstObject;
    
    if (IsAdobeSelectionAssetPSDFile(itemSelection))
    {
        // We know the selected item is a PSD file so we can safely cast it to the specific type.
        AdobeSelectionAssetPSDFile *psdSelection = (AdobeSelectionAssetPSDFile *)itemSelection;
        
        // Grab the actual Asset file instance.
        AdobeAssetPSDFile *psdFile = (AdobeAssetPSDFile *)psdSelection.selectedItem;
        
        self.psdFileNameLabel.text = [NSString stringWithFormat:@"PSD File: %@", psdFile.name];
        self.psdFile = psdFile;
        
        // Also grab all the selected layers
        AdobePSDLayerSelectionArray *layerSelections = psdSelection.layerSelections;
        
        NSMutableArray *selectedLayers = [NSMutableArray arrayWithCapacity:psdSelection.layerSelections.count];
        
        for (AdobeSelectionPSDLayer *psdLayerSelection in layerSelections)
        {
            [selectedLayers addObject:psdLayerSelection.layer];
        }
        
        self.selectedLayers = selectedLayers;
        
        [self.tableView reloadData];
        self.tableView.hidden = NO;
    }
}

- (void)assetBrowserDidEncounterError:(NSError *)error
{
    // Dismiss the Asset Browser
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"An error occurred: %@", error);
}

- (void)assetBrowserDidClose
{
    NSLog(@"The user closed the Asset Browser without choosing any assets.");
}

@end
