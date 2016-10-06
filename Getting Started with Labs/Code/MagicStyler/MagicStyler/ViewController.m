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
//  MagicStyler
//

#import "ViewController.h"
#import "ViewController+Buttons.h"
#import <AdobeCreativeSDKCore/AdobeUXAuthManager.h>

#define CC_CLIENT_ID                @"CHANGE_ME_CLIENT_ID"
#define CC_CLIENT_SECRET            @"CHANGE_ME_CLIENT_SECRET"

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // first set the clientID and clientSecret
    [AdobeUXAuthManager.sharedManager setAuthenticationParametersWithClientID: CC_CLIENT_ID
                                                             withClientSecret: CC_CLIENT_SECRET];
    // add the buttons
    [self addButtons];
    
    // init and add the magic styler
    self.magicStyle = [[AdobeLabsMagicStyle alloc] init];
    
    // set up the image views
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, VIEW_Y_OFFSET, viewWidth, viewHeight-VIEW_Y_OFFSET)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // set up the style views
    int numStyles = 4;
    CGFloat leftoverWidth = viewWidth - (BUTTON_WIDTH*numStyles);
    int numGaps = numStyles+1;
    CGFloat interSpacing = (leftoverWidth/numGaps) + BUTTON_WIDTH;

    self.style1View = [[UIImageView alloc] initWithFrame:CGRectMake((leftoverWidth/numGaps), viewHeight-BUTTON_HEIGHT-2*BUTTON_Y_OFFSET_BOT-BUTTON_WIDTH, BUTTON_WIDTH, BUTTON_WIDTH)];
    self.style1View.contentMode = UIViewContentModeScaleAspectFit;
    self.style1View.image = [UIImage imageNamed: @"style-000.jpg"];
    
    self.style2View = [[UIImageView alloc] initWithFrame:CGRectMake((leftoverWidth/numGaps)+interSpacing, viewHeight-BUTTON_HEIGHT-2*BUTTON_Y_OFFSET_BOT-BUTTON_WIDTH, BUTTON_WIDTH, BUTTON_WIDTH)];
    self.style2View.contentMode = UIViewContentModeScaleAspectFit;
    self.style2View.image = [UIImage imageNamed: @"style-001.jpg"];
    
    self.style3View = [[UIImageView alloc] initWithFrame:CGRectMake((leftoverWidth/numGaps)+2*interSpacing, viewHeight-BUTTON_HEIGHT-2*BUTTON_Y_OFFSET_BOT-BUTTON_WIDTH, BUTTON_WIDTH, BUTTON_WIDTH)];
    self.style3View.contentMode = UIViewContentModeScaleAspectFit;
    self.style3View.image = [UIImage imageNamed: @"style-002.jpg"];
    
    [self.view addSubview: self.imageView];
    [self.view addSubview: self.style1View];
    [self.view addSubview: self.style2View];
    [self.view addSubview: self.style3View];
    
    self.input = nil;
    self.result = nil;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)onButtonImage1 {
    [self loadImage: @"input-000.jpg"];
}

- (void)onButtonImage2 {
    [self loadImage: @"input-001.jpg"];
}

- (void)onButtonStyle1 {
    [self applyStyleImage: @"style-000.jpg"];
}

- (void)onButtonStyle2 {
    [self applyStyleImage: @"style-001.jpg"];
}

- (void)onButtonStyle3 {
    [self applyStyleImage: @"style-002.jpg"];
}

- (void)onButtonClear {
    [self.magicStyle clearStyle];
    self.imageView.image = self.input;
}

- (void)loadImage: (NSString *)imageName {
    self.input = [UIImage imageNamed: imageName];
    if (self.input)
    {
        self.imageView.image = self.input;
        self.result = nil;

        UIActivityIndicatorView * spinner;
        __unsafe_unretained typeof(self) weakSelf = self;
        
        // set image may take some time to finish processing the image so put up a spinner
        spinner = [self createSpinner];
        [self hideImageButtons];
        [self hideStyleButtons];
        
        [self.magicStyle setInputImage:self.input withCompletionBlock: ^(NSError *error) {
            [spinner removeFromSuperview];
            if (error == nil) {
                [weakSelf showImageButtons];
                [weakSelf showStyleButtons];
            }
        } ];
    }
}

- (void)applyStyleImage: (NSString *)imageName {
    // load the style image
    UIImage *styleImage = [UIImage imageNamed: imageName];
    
    // if both the input and style images exist
    if (self.input && styleImage)
    {
         UIActivityIndicatorView * spinner;
        
         // set image may take some time to finish processing the image so put up a spinner
        spinner = [self createSpinner];
        [self hideImageButtons];
        [self hideStyleButtons];
        
        // apply the style image's style to the input image
        self.result = [self.magicStyle applyStyleFrom:styleImage];
        
        [spinner removeFromSuperview];
        [self showImageButtons];
        [self showStyleButtons];
        
        // displace the result
        self.imageView.image = self.result;
    }
}

@end

