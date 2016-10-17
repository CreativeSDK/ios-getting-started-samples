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

//
//  ViewController.m
//  CreativeSDKColorSample
//

#import "ViewController.h"

#import <AdobeCreativeSDKCore/AdobeUXAuthManager.h>
#import <AdobeCreativeSDKAssetModel/AdobeColorTheme.h>
#import <AdobeCreativeSDKColor/AdobeCreativeSDKColor.h>

static NSString* const CreativeSDKClientId = @"CHANGEME_CLIENT_ID";
static NSString* const CreativeSDKClientSecret = @"CHANGEME_CLIENT_SECRET";

@interface ViewController () <AdobeColorPickerControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *launchColorPickerButton;
@property (nonatomic, weak) IBOutlet UIView *colorView;
@property (nonatomic, strong) AdobeColorViewController *colorViewController;
@property (nonatomic, strong) UIPopoverController *colorPopoverController;
@property (nonatomic, strong) NSMutableArray *colorHistoryArray;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId
                                                               withClientSecret:CreativeSDKClientSecret];
    
    self.colorView.backgroundColor = [UIColor redColor];
    
    // allow for 2 rows of color history
    self.colorHistoryArray = [NSMutableArray arrayWithCapacity:14];
}



- (IBAction)launchColorPicker:(id)sender
{
    if (![AdobeUXAuthManager sharedManager].isAuthenticated)
    {
        [[AdobeUXAuthManager sharedManager] login:self
                                        onSuccess:^(AdobeAuthUserProfile *profile)
         {
             NSLog(@"logged in successfully to Creative Cloud");
             [self initializeAndShowColorPicker];
         }
                                          onError:^(NSError *error)
         {
             NSLog(@"error = %@", error);
         }];
        
    }
    else
    {
        [self initializeAndShowColorPicker];
    }
}

- (IBAction)logoutOfCreativeCloud:(id)sender
{
    if ([AdobeUXAuthManager sharedManager].isAuthenticated)
    {
        [[AdobeUXAuthManager sharedManager] logout:^{
            NSLog(@"logged out of Creative Cloud");
        } onError:^(NSError *error) {
            NSLog(@"error = %@", error);
        }];
    }
    else
    {
        [[AdobeUXAuthManager sharedManager] login:self
                                        onSuccess:^(AdobeAuthUserProfile *profile)
         {
             NSLog(@"logged in successfully to Creative Cloud");
         }
                                          onError:^(NSError *error)
         {
             NSLog(@"error = %@", error);
         }];

    }
}

- (void) initializeAndShowColorPicker
{
    if(!self.colorViewController)
    {
        self.colorViewController = [[AdobeColorViewController alloc] init];
        
        // control which color selection views allowed and initial one
        self.colorViewController.initialColorPickerView = AdobeColorPickerColorPicker;
        self.colorViewController.colorPickerViewOptions = AdobeColorPickerViewPicker | AdobeColorPickerViewLibraries | AdobeColorPickerViewThemes;
        
        // set up app specific themes, themes are initialized with arrays of colors
        AdobeColorTheme *appColorTheme1 = [[AdobeColorTheme alloc]initWithUIColors:@[
                                                                                     [UIColor redColor],
                                                                                     [UIColor whiteColor],
                                                                                     [UIColor blueColor],
                                                                                     [UIColor yellowColor],
                                                                                     [UIColor blackColor]
                                                                                     ]];
        AdobeColorTheme *appColorTheme2 = [[AdobeColorTheme alloc]initWithUIColors:@[
                                                                                     [UIColor magentaColor],
                                                                                     [UIColor whiteColor],
                                                                                     [UIColor cyanColor],
                                                                                     [UIColor orangeColor],
                                                                                     [UIColor blackColor]
                                                                                     ]];
        
        self.colorViewController.appThemes = @[appColorTheme1, appColorTheme2];
        
        // set the starting color
        self.colorViewController.initialColor = self.colorView.backgroundColor;
        
        // register ourselves for color notifications
        self.colorViewController.delegate = self;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.colorPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.colorViewController];
        
        self.colorPopoverController.delegate = self;
        self.colorPopoverController.popoverContentSize = CGSizeMake(320, 560);
        
        [self.colorPopoverController presentPopoverFromRect:self.launchColorPickerButton.frame
                                                     inView:self.view
                                   permittedArrowDirections:UIPopoverArrowDirectionUp
                                                   animated:YES];
    }
    else
    {
        [self presentViewController:self.colorViewController animated:YES completion:nil];
    }
    
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.colorView.backgroundColor = self.colorViewController.currentColor;
    
    [self addToColorHistoryQueue:self.colorViewController.currentColor];
}

#pragma mark - AdobeColorPickerControllerDelegate methods

- (void)dismissColorPickerController:(AdobeColorViewController*)vc
{
    self.colorView.backgroundColor = vc.currentColor;
    
    [self addToColorHistoryQueue:vc.currentColor];
}

- (void)colorPickerColorHistoryCleared
{
    [self.colorHistoryArray removeAllObjects];
    self.colorViewController.colorHistory = self.colorHistoryArray;
}


#pragma mark - Color Picker Color History helpers

- (void)addToColorHistoryQueue:(UIColor *)colorToAdd
{
    // Now, add to our color history array, checking first to see if the count
    // is greater than 2 rows worth of colors.
    if(self.colorHistoryArray.count >= 14)
    {
        [self.colorHistoryArray removeLastObject];
    }
    [self.colorHistoryArray insertObject:colorToAdd atIndex:0];
    self.colorViewController.colorHistory = self.colorHistoryArray;
}

@end
