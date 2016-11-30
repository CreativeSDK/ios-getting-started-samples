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
//  Magic Curver
//


#import "ViewController.h"
#import "ViewController+Buttons.h"

#import <AdobeCreativeSDKLabs/AdobeLabsMagicCurve.h>
#import <AdobeCreativeSDKCore/AdobeUXAuthManager.h>

#warning Please update these required values to match the ones provided by creativesdk.com
static NSString * const kCreativeSDKClientId = @"Change me";
static NSString * const kCreativeSDKClientSecret = @"Change me";
static NSString * const kCreativeSDKRedirectURLString = @"Change me";


@implementation ViewController

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
    
    // add the buttons
    [self addButtons];
    
    // make the curve view
    self.curveView = [[CurveView alloc] initWithFrame: CGRectMake(0, VIEW_Y_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VIEW_Y_OFFSET)];
    
    // set the initial state to be circle
    _shapeMode = AdobeMagicCurverShapeModeCircle;
    [self resetCurve];
    
    // add the curve view
    [self.view addSubview: self.curveView];
    
}

- (void)resetCurve {
    
    // make a magic curve and set its control points and open/close property
    AdobeLabsMagicCurve * magicCurve = [[AdobeLabsMagicCurve alloc] init];
    
    switch (_shapeMode) {
        case AdobeMagicCurverShapeModeCircle:
            [magicCurve addControlPoint: CGPointMake(  0,   0) isCorner: NO];
            [magicCurve addControlPoint: CGPointMake(100,   0) isCorner: NO];
            [magicCurve addControlPoint: CGPointMake(100, 100) isCorner: NO];
            [magicCurve addControlPoint: CGPointMake(  0, 100) isCorner: NO];
            magicCurve.isClosed = YES;
            break;
        case AdobeMagicCurverShapeModeSquare:
            [magicCurve addControlPoint: CGPointMake(  0,   0) isCorner: YES];
            [magicCurve addControlPoint: CGPointMake(100,   0) isCorner: YES];
            [magicCurve addControlPoint: CGPointMake(100, 100) isCorner: YES];
            [magicCurve addControlPoint: CGPointMake(  0, 100) isCorner: YES];
            magicCurve.isClosed = YES;
            break;
        case AdobeMagicCurverShapeModePath:
            [magicCurve addControlPoint: CGPointMake(  0, -50) isCorner: NO];
            [magicCurve addControlPoint: CGPointMake(100,   0) isCorner: NO];
            [magicCurve addControlPoint: CGPointMake(  0, 100) isCorner: NO];
            [magicCurve addControlPoint: CGPointMake(100, 150) isCorner: NO];
            magicCurve.isOpen = YES;
            break;
        default:
            break;
    }
    
    // center the curve in the view
    [magicCurve translate: CGPointMake(self.curveView.frame.size.width / 2 - (self.curveView.frame.origin.x + 50),
                                       self.curveView.frame.size.height / 2 - self.curveView.frame.origin.y)];
    
    // set the curve in the view
    [self.curveView setMagicCurve: magicCurve];
    
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

@end
