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
#import <AdobeCreativeSDKTypekit/AdobeCreativeSDKTypekit.h>

#import "ViewController.h"

#import "TextContainerView.h"

#warning Please update these required values to match the ones provided by creativesdk.com
static NSString *const CreativeSDKClientId = @"change me";
static NSString *const CreativeSDKClientSecret = @"change me";
static NSString *const CreativeSDKRedirectURLString = @"Change me";

const CGFloat typekitFontSize = 18;

@interface ViewController ()<AdobeTypekitFontPickerControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *mainViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *fontNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fontStyleLabel;
@property (weak, nonatomic) IBOutlet UILabel *fontStatusLabel;
@property (weak, nonatomic) IBOutlet TextContainerView *textView;

@end

@implementation ViewController

#pragma mark - ViewController override

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the client ID and secret values so the CSDK can identify the calling app.
    // Typekit Platform service requires 2 Typekit scopes in addition to the minimum set of scopes.
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId
                                                                   clientSecret:CreativeSDKClientSecret
                                                            additionalScopeList:@[AdobeAuthManagerUserProfileScope,
                                                                                  AdobeAuthManagerEmailScope,
                                                                                  AdobeAuthManagerAddressScope,
                                                                                  AdobeAuthManagerTypekitPlatformScope,
                                                                                  AdobeAuthManagerTypekitPlatformSyncScope]];
    
    // Also set the redirect URL, which is required by the CSDK authentication mechanism.
    [AdobeUXAuthManager sharedManager].redirectURL = [NSURL URLWithString:CreativeSDKRedirectURLString];
    
    // Change the font size for Typekit fonts
    self.textView.fontSize = typekitFontSize;

    // Add observer for the notification dispatched when Typekit font is changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(typekitChanged:)
                                                 name:AdobeTypekitChangedNotification
                                               object:nil];
    
    // Add observer for the notification dispatched when a user logged in of Creative Cloud
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLogin)
                                                 name:AdobeAuthManagerLoggedInNotification
                                               object:nil];
    
    // Add observer for the notification dispatched when a user logged out of Creative Cloud
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLogout)
                                                 name:AdobeAuthManagerLoggedOutNotification
                                               object:nil];

    // Initialize the app, syncing Typekit fonts and updating UI labels.
    [self initializeUIAndTypekitManager];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

- (void)initializeUIAndTypekitManager
{
    if ([AdobeUXAuthManager sharedManager].isAuthenticated)
    {
        // Change the label of the login button
        [self.loginButton setTitle:@"Log Out of Creative Cloud" forState:UIControlStateNormal];
        
        // Sync Typekit fonts
        [[AdobeTypekitManager sharedInstance] syncFonts];
        
        // Set the font name and the font status
        [self populateUI:nil];
    }
    else
    {
        // Change the label of the login button
        [self.loginButton setTitle:@"Log In to Creative Cloud" forState:UIControlStateNormal];
    }
}

- (void)populateUI:(NSString *)reasonFontsChanged
{
    // Set the font family and style names in UI labels
    self.fontNameLabel.text = self.textView.font.familyName;
    self.fontStyleLabel.text = self.textView.fontStyleName;

    // Set the font status
    [self updateStatusLabel:reasonFontsChanged];
}

/**
 * Updates the text view's font and informs the user about the reason the text view's font was 
 * changed.
 *
 * @param reason   Reason for the update.
 */
- (void)resetTextViewWithReason:(NSString *)reason
{
    // Update font in the textView
    [self.textView resetTypekitFont];
    
    // Update the font name and the font status
    [self populateUI:reason];
}

/**
 * The status label indicates whether a Typekit font is in use. If a Typekit font is in use for the 
 * textView, and the user removes the font from the synced fonts list, the font for the textView 
 * falls back to the default one. As the default font is a system font in this demo, the status 
 * label displays "Using default font"
 *
 * @param reasonFontsChanged The reason the font for the text view was changed.
 */
- (void)updateStatusLabel:(NSString *)reasonFontsChanged
{
    if (self.textView.typekitFont == nil || self.textView.font == self.textView.defaultFont)
    {
        self.fontStatusLabel.text = @"Using default font";
        self.fontStatusLabel.textColor = [UIColor redColor];
        
        if (reasonFontsChanged != nil)
        {
            NSString *previousString = self.fontStatusLabel.text;
            
            // The font has expired. See the definition of @c kTypekitFontsChangedReasonExpiring
            // for more information
            if ([reasonFontsChanged isEqualToString:kTypekitFontsChangedReasonExpiring])
            {
                self.fontStatusLabel.text = [previousString stringByAppendingString:@", font is expired"];
            }
            else
            {
                self.fontStatusLabel.text = [previousString stringByAppendingString:@", font was updated"];
            }
        }
    }
    else
    {
        self.fontStatusLabel.text = @"Using Typekit font";
        self.fontStatusLabel.textColor = [UIColor greenColor];
    }
}

- (void)handleLogin
{
    [self initializeUIAndTypekitManager];
}

- (void)handleLogout
{
    [self initializeUIAndTypekitManager];
}

#pragma mark - Button actions

- (IBAction)loginButtonTouchUpInside
{
    if ([AdobeUXAuthManager sharedManager].isAuthenticated)
    {
        [[AdobeUXAuthManager sharedManager] logout:^
        {
            NSLog(@"logged out successfully from Creative Cloud");
        }
                                           onError:^(NSError *error)
        {
            NSLog(@"error logging out = %@", error);
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
            NSLog(@"error logging in = %@", error);
        }];
    }
}

- (IBAction)launchFontPickerButtonTouchUpInside:(UIButton *)launchButton
{
    // Initialize Font Picker
    AdobeTypekitFontPickerController *fontPickerController = [AdobeTypekitFontPickerController new];
    fontPickerController.pickerDelegate = self;
    fontPickerController.currentFont = [AdobeTypekitFont fontWithName:self.textView.font.fontName];
    fontPickerController.pickerType = AdobeTypekitFontPickerFamilies;
    fontPickerController.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popoverPresentationController = fontPickerController.popoverPresentationController;
    popoverPresentationController.backgroundColor = [UIColor whiteColor];
    popoverPresentationController.sourceRect = launchButton.bounds;
    popoverPresentationController.sourceView = launchButton;
    popoverPresentationController.delegate = self;
    
    [self presentViewController:fontPickerController animated:YES completion:nil];
    
    // Exit edit mode to resume editing after Font Browser is used
    [self.textView endEditing:YES];
}

#pragma mark - UIAdaptivePresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection
{
    // Use font picker as popup style for both iPhone and iPad
    return UIModalPresentationNone;
}

#pragma mark - AdobeTypekitFontPickerControllerDelegate

- (void)fontPicker:(AdobeTypekitFontPickerController *)controller didFinishPickingFont:(AdobeTypekitFont *)typekitFont
{
    // Apply the selected Typekit font to the text view
    self.textView.typekitFont = typekitFont;
    
    // Update the labels of the font family and style names
    [self populateUI:nil];
}

#pragma mark - Notification handler

/**
 * Handle Typekit fonts that are removed or added back while syncing.
 *
 * @param notification The notification object that contains more information about the sync 
 *                     process.
 */
- (void)typekitChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (self.textView.typekitFont == nil)
        {
            // Do nothing when a Typekit font has never been applied
            return;
        }
        
        // Get the arrays of added and removed Typekit IDs
        NSArray *added = notification.userInfo[kTypekitFontsAddedKey];
        NSArray *removed = notification.userInfo[kTypekitFontsRemovedKey];
        
        // Get the reason why fonts are changed
        NSString *fontsChangedReason = notification.userInfo[kTypekitFontsChangedReasonKey];
        
        BOOL refreshTextView = NO;
        BOOL downloadNewFonts = NO;
        
        // Id of the typekit font that is added, if any.
        NSString *typekitFontId = nil;
        
        // Determine which text view objects are affected by removing or adding back Typekit fonts
        // Also determine which text view objects need to download Typekit fonts
        NSString *typekitIdString = self.textView.typekitFont.typekitId;
        
        if (typekitIdString.length > 0)
        {
            // When a Typekit font is added, the font needs to be downloaded, then the text view
            // needs to be refreshed later
            BOOL addedUsedByTextViewObject = [added containsObject:typekitIdString];
            
            if (addedUsedByTextViewObject)
            {
                downloadNewFonts = YES;
                typekitFontId = typekitIdString;
            }
            
            // When a Typekit font is removed, the text view needs only to be refreshed
            BOOL removedUsedByTextViewObject = [removed containsObject:typekitIdString];
            
            if (removedUsedByTextViewObject)
            {
                refreshTextView = YES;
            }
        }
        
        // Download any Typekit fonts that are added. After a successful download, refresh the text
        // view by adding back Typekit fonts.
        if (downloadNewFonts && typekitFontId.length > 0)
        {
            // Request that this font be downloaded and registered
            [AdobeTypekitFont supplyMissingFont:typekitFontId
                                     completion:^(NSString *psFontName, NSError *error)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    if (error != nil)
                    {
                        NSLog(@"error downloading Typekit fonts = %@", error);
                    }
                    else
                    {
                        // Refresh affected text view objects
                        if ([self.textView.typekitFont.fontName isEqualToString:psFontName])
                        {
                            [self resetTextViewWithReason:fontsChangedReason];
                        }
                    }
                });
            }];
        }
        
        // Refresh the text view objects affected by removing Typekit fonts
        if (refreshTextView)
        {
            [self resetTextViewWithReason:fontsChangedReason];
        }
    });
}

@end
