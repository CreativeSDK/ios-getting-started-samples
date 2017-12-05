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
 *
 */

//
//  ViewController.m
//  MagicPuppy
//


#import "ViewController.h"

#import <AdobeCreativeSDKLabs/AdobeLabsUXMagicSelectionView.h>
#import <AdobeCreativeSDKCore/AdobeUXAuthManager.h>

#error The Creative SDK Labs component is no longer supported. Adobe will release a new version of the SDK in November 2017, and this component will not be included in the new version. We suggest removing this component from your application as soon as possible to avoid any interruption in service. You can find more information on this deprecation here: https://creativesdk.zendesk.com/hc/en-us/articles/115004788463-End-of-Support-for-the-Creative-SDK-Image-Editor-UI-Color-UI-Market-Browser-and-Labs-Components

#warning Please update these required values to match the ones provided by creativesdk.com
static NSString * const kCreativeSDKClientId = @"Change me";
static NSString * const kCreativeSDKClientSecret = @"Change me";
static NSString * const kCreativeSDKRedirectURLString = @"Change me";

#define BUTTON_X_MARGIN             0
#define BUTTON_Y_MARGIN             20
#define BUTTON_Y_OFFSET             0
#define BUTTON_WIDTH                126
#define BUTTON_HEIGHT               40
#define VIEW_Y_OFFSET               (BUTTON_Y_MARGIN + (2*(BUTTON_Y_OFFSET+BUTTON_HEIGHT)))
#define BUTTON_TITLE_FOREGROUND     @"Mark Foreground"
#define BUTTON_TITLE_BACKGROUND     @"Mark Background"
#define BUTTON_TITLE_MIXED          @"Mark Mixed"
#define BUTTON_TITLE_CLEAR          @"Clear"
#define BUTTON_TITLE_SHOW_RESULTS   @"Show Results"
#define BUTTON_TITLE_HIDE_RESULTS   @"Hide Results"
#define BUTTON_TITLE_LOAD_PUPPY     @"Load Puppy"
#define BUTTON_TITLE_LOGOUT         @"Logout"
#define PUPPY_IMAGE_NAME            @"puppy.jpg"

@interface ViewController ()

@end

@implementation ViewController {
    AdobeLabsUXMagicSelectionView * _magicSelectionView;
    UIImageView * _resultsView;
    UIButton * _markForegroundButton;
    UIButton * _markBackgroundButton;
    UIButton * _markMixedButton;
    UIButton * _showHideResultsButton;
    UIButton * _loadPuppyLogoutButton;
    UIButton * _clearSelectionButton;
}

- (UIButton *)addButton: (NSString *)title withAction: (SEL)action withRect: (CGRect)rect {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: title forState: UIControlStateNormal];
    [button setFrame: rect];
    [button addTarget:self action: action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: button];
    button.hidden = YES;
    return button;
}

- (void)viewDidLoad {
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
    
    // calculate button placement
    CGRect buttonRect = CGRectMake(BUTTON_X_MARGIN, BUTTON_Y_MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat leftoverWidth = viewWidth - (BUTTON_X_MARGIN * 2 + BUTTON_WIDTH*3);
    CGFloat interSpacing = (leftoverWidth / 2) + BUTTON_WIDTH;
    
    // add the first row of buttons
    _markForegroundButton = [self addButton: BUTTON_TITLE_FOREGROUND withAction: @selector(setBrushForeground) withRect: buttonRect];
    _markForegroundButton.backgroundColor = [UIColor orangeColor];
    buttonRect.origin.x += interSpacing;
    _markBackgroundButton = [self addButton: BUTTON_TITLE_BACKGROUND withAction: @selector(setBrushBackground) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    _markMixedButton = [self addButton: BUTTON_TITLE_MIXED withAction: @selector(setBrushMixed) withRect: buttonRect];
    
    // add the second row of buttons
    buttonRect.origin.x = BUTTON_X_MARGIN;
    buttonRect.origin.y += buttonRect.size.height + BUTTON_Y_OFFSET;
    _showHideResultsButton = [self addButton: BUTTON_TITLE_SHOW_RESULTS withAction: @selector(showHideResults) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    _loadPuppyLogoutButton = [self addButton: BUTTON_TITLE_LOAD_PUPPY withAction: @selector(loadPuppyLogout) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    _clearSelectionButton = [self addButton: BUTTON_TITLE_CLEAR withAction: @selector(clearSelection) withRect: buttonRect];
 
    // all buttons are hidden by default, show the load puppy button
    _loadPuppyLogoutButton.hidden = NO;
    
    // initialize the views to nil
    _magicSelectionView = nil;
    _resultsView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBrushMixed {
    if (_magicSelectionView.brushMode != AdobeLabsMagicSelectionBrushModeMixed) {
        _magicSelectionView.brushMode = AdobeLabsMagicSelectionBrushModeMixed;
        _markMixedButton.backgroundColor = [UIColor orangeColor];
        _markBackgroundButton.backgroundColor = [UIColor clearColor];
        _markForegroundButton.backgroundColor = [UIColor clearColor];
    }
}

- (void)setBrushBackground {
    if (_magicSelectionView.brushMode != AdobeLabsMagicSelectionBrushModeBackground) {
        _magicSelectionView.brushMode = AdobeLabsMagicSelectionBrushModeBackground;
        _markMixedButton.backgroundColor = [UIColor clearColor];
        _markBackgroundButton.backgroundColor = [UIColor orangeColor];
        _markForegroundButton.backgroundColor = [UIColor clearColor];
    }
}

- (void)setBrushForeground {
    if (_magicSelectionView.brushMode != AdobeLabsMagicSelectionBrushModeForeground) {
        _magicSelectionView.brushMode = AdobeLabsMagicSelectionBrushModeForeground;
        _markMixedButton.backgroundColor = [UIColor clearColor];
        _markBackgroundButton.backgroundColor = [UIColor clearColor];
        _markForegroundButton.backgroundColor = [UIColor orangeColor];
    }
}

- (void)clearSelection {
    [_magicSelectionView clearStrokes];
}

- (void)loadPuppyLogout {
    if (! _magicSelectionView)
    {
        // the magic selection view is not showing.  Create it and load puppy.
        __unsafe_unretained typeof(self) weakSelf = self;
        _magicSelectionView = [[AdobeLabsUXMagicSelectionView alloc] initWithFrame: CGRectMake(0, VIEW_Y_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VIEW_Y_OFFSET)];
        
        // set image may take some time (especially in the simulator) so put up a spinner
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(
                                            _magicSelectionView.bounds.origin.x + (_magicSelectionView.bounds.size.width / 2 - 25),
                                            _magicSelectionView.bounds.origin.y + (_magicSelectionView.bounds.size.height / 2 - 25),
                                            50,
                                            50)];
        spinner.color = [UIColor blueColor];
        [spinner startAnimating];
        [self.view addSubview:spinner];
        
        [_magicSelectionView setImage: [UIImage imageNamed:PUPPY_IMAGE_NAME]
                  withCompletionBlock:^(NSError *error)
            {
                [spinner removeFromSuperview];

                if (error)
                 {
                     // setImage failed - user failed to log in
                     weakSelf->_magicSelectionView = nil;
                 }
                 else
                 {
                     // success with setImage, add _magicSelectionView as subview and change button states
                     [weakSelf.view addSubview: weakSelf->_magicSelectionView];
                     weakSelf->_markForegroundButton.hidden    = NO;
                     weakSelf->_markBackgroundButton.hidden    = NO;
                     weakSelf->_markMixedButton.hidden         = NO;
                     weakSelf->_showHideResultsButton.hidden   = NO;
                     weakSelf->_clearSelectionButton.hidden    = NO;
                     [weakSelf->_loadPuppyLogoutButton setTitle:BUTTON_TITLE_LOGOUT forState:UIControlStateNormal];
                 }
            }
         ];
    }
    else
    {
        // the magic selection view is showing.  Get rid of it and log the user out
        [_magicSelectionView removeFromSuperview];
        _magicSelectionView = nil;
        [AdobeUXAuthManager.sharedManager logout: nil onError: nil];
        
        // hide all of the other buttons and change my label back to load puppy
        _markForegroundButton.hidden    = YES;
        _markBackgroundButton.hidden    = YES;
        _markMixedButton.hidden         = YES;
        _showHideResultsButton.hidden   = YES;
        _clearSelectionButton.hidden    = YES;
        [_loadPuppyLogoutButton setTitle:BUTTON_TITLE_LOAD_PUPPY forState:UIControlStateNormal];
    }
}

- (void)showHideResults {
    if (_resultsView) {
        // results are showing, hide results and show buttons
        _markForegroundButton.hidden    = NO;
        _markBackgroundButton.hidden    = NO;
        _markMixedButton.hidden         = NO;
        _clearSelectionButton.hidden    = NO;
        _loadPuppyLogoutButton.hidden   = NO;
        [_showHideResultsButton setTitle:BUTTON_TITLE_SHOW_RESULTS forState:UIControlStateNormal];
        [_resultsView removeFromSuperview];
        _resultsView = nil;
    }
    else {
        // show the results
        // first create a UIImage of just the foreground bits per the documentation in AdobeLabsUXMagicSelectionView.h
        size_t w = _magicSelectionView.image.size.width;
        size_t h = _magicSelectionView.image.size.height;
        
        uint8_t *data = (uint8_t *)malloc(4*w*h*sizeof(uint8_t));
        [_magicSelectionView readForegroundAndMatteIntoBuffer:data];
        
        // Paint the non-selected portion of the image black
        for (int i = 0; i < 4*w*h; i += 4)
        {
            float alpha = (float)data[i + 3] / 255;
            data[i    ] *= alpha;
            data[i + 1] *= alpha;
            data[i + 2] *= alpha;
        }
        CGContextRef ctx = CGBitmapContextCreate(data, w, h, 8, 4*w, CGColorSpaceCreateDeviceRGB(), (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
        CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
        UIImage * foregroundBits = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        // show the results
        _resultsView = [[UIImageView alloc] initWithFrame: CGRectMake(0, VIEW_Y_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VIEW_Y_OFFSET)];
        _resultsView.contentMode = UIViewContentModeScaleAspectFit;
        [_resultsView setImage: foregroundBits];
        [self.view addSubview: _resultsView];
        [_showHideResultsButton setTitle:BUTTON_TITLE_HIDE_RESULTS forState:UIControlStateNormal];
        
        // hide the buttons
        _markForegroundButton.hidden    = YES;
        _markBackgroundButton.hidden    = YES;
        _markMixedButton.hidden         = YES;
        _clearSelectionButton.hidden    = YES;
        _loadPuppyLogoutButton.hidden   = YES;
    }
}



@end
