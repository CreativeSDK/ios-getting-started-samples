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
//  MagicCutoutMaker
//

#import "ViewController.h"
#import "ViewController+Buttons.h"

#import <AdobeCreativeSDKCore/AdobeUXAuthManager.h>

#define CC_CLIENT_ID                  @"CHANGE_ME_CLIENT_ID"
#define CC_CLIENT_SECRET              @"CHANGE_ME_CLIENT_SECRET"

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // first set the clientID and clientSecret
    [AdobeUXAuthManager.sharedManager setAuthenticationParametersWithClientID: CC_CLIENT_ID
                                                                 clientSecret: CC_CLIENT_SECRET
                                                                 enableSignUp: YES];
    // add the buttons
    [self addButtons];
    
    // init and add the magic perspective view
    self.magicCutout = [[AdobeLabsMagicCutoutMaker alloc] init];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, VIEW_Y_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VIEW_Y_OFFSET)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview: self.imageView];
    self.resultSaliency = nil;
    self.resultCutout = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    static BOOL firstTime = YES;
    
    if (firstTime) {
        firstTime = NO;
        
        // login to creative cloud
        
        [[AdobeUXAuthManager sharedManager] login: self onSuccess: nil onError: ^(NSError * error ) {
            if ([AdobeUXAuthManager sharedManager].isAuthenticated) return;
            if (error.domain == AdobeAuthErrorDomain && error.code == AdobeAuthErrorCodeOffline) return;
            
            CGRect rect = self.view.frame; rect.origin.x += 10; rect.size.width -= 10;
            UILabel * errorLabel = [[UILabel alloc] initWithFrame: rect];
            errorLabel.text = @"Please restart app and login to Creative Cloud";
            [self.view addSubview: errorLabel];
        }];
    }
}

- (void)onButtonImage1 {
    [self loadImage: @"kid.jpg"];
}

- (void)onButtonImage2 {
    [self loadImage: @"haleakala.jpg"];
}

- (void)onButtonSaliency {
    
    if (self.resultCutout == nil)
    {
        // set image may take some time to finish processing the image so put up a spinner
        UIActivityIndicatorView * spinner;
        spinner = [self createSpinner];
        
        [self.magicCutout estimateSaliency:self.input withCompletionBlock: ^(NSError *error) {
            [spinner removeFromSuperview];
            self.resultSaliency = [self.magicCutout getOutput];
            self.imageView.image = self.resultSaliency;
        } ];
    }
}

- (void)onButtonCutout {

    if (self.resultCutout == nil)
    {
        // set image may take some time to finish processing the image so put up a spinner
        UIActivityIndicatorView * spinner;
        spinner = [self createSpinner];
       @autoreleasepool {
        [self.magicCutout estimateCutout:self.input withCompletionBlock: ^(NSError *error) {
            [spinner removeFromSuperview];
            self.resultCutout = [self.magicCutout getOutput];
            self.imageView.image = self.resultCutout;
        } ];
       }
    }
}

- (void)loadImage: (NSString *)imageName {
    self.input = [UIImage imageNamed: imageName];
    if (self.input)
    {
        self.imageView.image = self.input;
        self.resultSaliency = nil;
        self.resultCutout = nil;
    }
}

@end
