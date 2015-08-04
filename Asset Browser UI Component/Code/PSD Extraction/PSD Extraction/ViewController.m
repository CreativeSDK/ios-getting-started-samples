//
//  ViewController.m
//  PSD Extraction
//
//  Copyright (c) 2015 Adobe Systems Incorporated. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>
#import <AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h>
#import <AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h>

#import "ViewController.h"
#import "LayerTableViewCell.h"

//warning Change the Client ID and Secret to match the values provided by the app registration website (creativesdk.adobe.com)

static NSString * const kAppClientId = @"changeme";
static NSString * const kAppClientSecret = @"changeme";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *psdFileNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) AdobeAssetPSDFile *psdFile;
@property (strong, nonatomic) NSArray *selectedLayers;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:kAppClientId
                                                                   clientSecret:kAppClientSecret
                                                                   enableSignUp:NO];
    
    // layoutMargins doesn't exist on iOS 7 so check before calling it.
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([AdobeUXAuthManager sharedManager].isAuthenticated)
    {
        [self.loginButton setTitle:NSLocalizedString(@"Log Out", @"Logout button")
                          forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UI Actions

- (IBAction)loginButtonTouchUpInside
{
    if ([AdobeUXAuthManager sharedManager].isAuthenticated)
    {
        [[AdobeUXAuthManager sharedManager] logout:^{
            
            [self.loginButton setTitle:NSLocalizedString(@"Log In", @"Login button") forState:UIControlStateNormal];
            
            self.psdFileNameLabel.text = nil;
            self.selectedLayers = nil;
            [self.tableView reloadData];
            self.tableView.hidden = YES;
            
        } onError:^(NSError *error) {
            
            NSLog(@"Error in logout: %@", error);
        }];
    }
    else
    {
        [[AdobeUXAuthManager sharedManager] login:self onSuccess:^(AdobeAuthUserProfile *profile) {
            
            [self.loginButton setTitle:NSLocalizedString(@"Log Out", "Logout button")
                              forState:UIControlStateNormal];
            
        } onError:^(NSError *error) {
            
            NSLog(@"Error in login: %@", error);
        }];
    }
}

- (IBAction)showAssetBrowserTouchUpInside
{
    // Exclude all other data sources. Only allow the "Files" datasource
    AdobeAssetDataSourceFilter *dataSourceFilter = [[AdobeAssetDataSourceFilter alloc] initWithDataSources:@[AdobeAssetDataSourceFiles]
                                                                                                filterType:AdobeAssetDataSourceFilterInclusive];
    
    // Exclude all other file types, other than PSD files.
    AdobeAssetMIMETypeFilter *mimeTypeFilter = [[AdobeAssetMIMETypeFilter alloc] initWithMIMETypes:@[kAdobeMimeTypePhotoshop]
                                                                                        filterType:AdobeAssetMIMETypeFilterTypeInclusion];
    
    // Create a new configuration object that can be used to customize the Asset Browser's behavior
    // or appearance.
    AdobeUXAssetBrowserConfiguration *configuration = [AdobeUXAssetBrowserConfiguration new];
    
    // Set all the options
    configuration.dataSourceFilter = dataSourceFilter;
    configuration.mimeTypeFilter = mimeTypeFilter;
    configuration.options = EnablePSDLayerExtraction | EnableMultiplePSDLayerSelection;
    
    // Call the Asset Browser and pass the configuration options
    [[AdobeUXAssetBrowser sharedBrowser] popupFileBrowserWithParent:self configuration:configuration onSuccess:^(NSArray *itemSelections) {
        
        // Grab the last item that was selected.
        AdobeSelectionAsset *itemSelection = itemSelections.lastObject;
        
        // Make sure it's a PSD file.
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
        else
        {
            
        }
        
    } onError:^(NSError *error) {
        
        NSLog(@"An error occurred: %@", error);
    }];
}

#pragma mark UITableViewDataSource

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
            type = @"RGP";
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
    NSString *layerInformation = [NSString stringWithFormat:@"Selected Layer: %li\nLayer name: %@\nType: %@\nLayer ID: %@\nLayer Index: %li\nVisible: %@",
                                  (long)indexPath.row, layer.name, type, layer.layerId, (long)layer.layerIndex, layer.visible ? @"Yes" : @"No"];
    
    cell.layerInformation = layerInformation;
    
    [self.psdFile getRenditionForLayer:layer.layerId
                         withLayerComp:nil
                              withType:AdobeAssetFileRenditionTypePNG
                              withSize:CGSizeMake(120, 0)
                          withPriority:NSOperationQueuePriorityHigh
                            onProgress:NULL
                          onCompletion:^(NSData *imageData, BOOL fromCache)
    {
        if ([cell.layerId isEqualToNumber:layer.layerId])
        {
            UIImage *image = [UIImage imageWithData:imageData];
            
            NSLog(@"%@", NSStringFromCGSize(image.size));
            
            cell.thumbnailImage = image;
        }
    }
                        onCancellation:^
    {
        NSLog(@"Layer rendition cancelled for layer: %@", layer);
    }
                               onError:^(NSError *error)
    {
        NSLog(@"An error occured when fetching the rendition for layer: %@", layer);
    }];
    
    return cell;
}

@end
