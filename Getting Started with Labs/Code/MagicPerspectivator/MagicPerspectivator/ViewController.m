//
// Copyright (c) 2015 Adobe Systems Incorporated. All rights reserved.
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
//  ViewController.m
//  MagicPerspectivator
//

#import "ViewController.h"
#import "ViewController+Buttons.h"
#import <AdobeCreativeSDKCore/AdobeUXAuthManager.h>

#warning Please update these required values to match the ones provided by creativesdk.com
static NSString * const kCreativeSDKClientId = @"Change me";
static NSString * const kCreativeSDKClientSecret = @"Change me";
static NSString * const kCreativeSDKRedirectURLString = @"Change me";

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    // Set the client ID and secret values so the CSDK can identify the calling app. The three
    // specified scopes are required at a minimum.
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:kCreativeSDKClientId
                                                                   clientSecret:kCreativeSDKClientSecret
                                                            additionalScopeList:@[AdobeAuthManagerUserProfileScope,
                                                                                  AdobeAuthManagerEmailScope,
                                                                                  AdobeAuthManagerAddressScope]];
    
    // Also set the redirect URL, which is required by the CSDK authentication mechanism.
    [AdobeUXAuthManager sharedManager].redirectURL = [NSURL URLWithString:kCreativeSDKRedirectURLString];
    
    // add the buttons
    [self addButtons];
   
    // init and add the magic perspective view
    self.magicPerspectiveView = [[AdobeLabsUXMagicPerspectiveView alloc] initWithFrame:
                                 CGRectMake(0, VIEW_Y_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VIEW_Y_OFFSET)];
    [self.view addSubview: self.magicPerspectiveView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)onButtonPark {
    [self loadImage: @"park.jpg"];
}

- (void)onButtonTownsend {
    [self loadImage: @"townsend.jpg"];
}

- (void)onButtonBakerHamilton {
    [self loadImage: @"baker-hamilton.jpg"];
}

- (void)onButtonNone {
    self.magicPerspectiveView.mode = AdobeLabsMagicPerspectiveModeNone;
}

- (void)onButtonAutomatic {
    self.magicPerspectiveView.mode = AdobeLabsMagicPerspectiveModeAutomatic;
}

- (void)onButtonHorizontal {
    self.magicPerspectiveView.mode = AdobeLabsMagicPerspectiveModeHorizontal;
}

- (void)onButtonVertical {
    self.magicPerspectiveView.mode = AdobeLabsMagicPerspectiveModeVertical;
}

- (void)onButtonLevel {
    self.magicPerspectiveView.mode = AdobeLabsMagicPerspectiveModeLevel;
}

- (void)onButtonRectify {
    self.magicPerspectiveView.mode = AdobeLabsMagicPerspectiveModeRectify;
}

- (void)loadImage: (NSString *)imageName {
    UIImage * image = [UIImage imageNamed: imageName];
    if (image)
    {
        UIActivityIndicatorView * spinner;
        __unsafe_unretained typeof(self) weakSelf = self;

        // set image may take some time to finish processing the image so put up a spinner
        spinner = [self createSpinner];
        [self hideModeButtons];

        [self.magicPerspectiveView setImage:image withCompletionBlock: ^(NSError *error) {
            [spinner removeFromSuperview];
            if (error == nil) [weakSelf showModeButtons];
        } ];
    }
}

@end
