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
//  RKCTestViewController.m
//  TestCCSDK
//

#import "RKCTestViewController.h"
#import "RKCTestView.h"
#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h> // uses AdobeUXAuthManager.h>

@implementation RKCTestViewController

- (void)loadView
{
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    RKCTestView *tv = [[RKCTestView alloc] initWithFrame:frame];
    
    self.view = tv;

    // Please update the ClientId and Secret to the values provided by creativesdk.com or from Adobe
    static NSString* const CreativeSDKClientId = @"changeme";
    static NSString* const CreativeSDKClientSecret = @"changemetoo";
    
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId clientSecret:CreativeSDKClientSecret enableSignUp:true];

    //The authManager caches our login, so check on startup
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    if(loggedIn) {
        NSLog(@"We have a cached logged in");
        [((RKCTestView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        AdobeAuthUserProfile *up = [AdobeUXAuthManager sharedManager].userProfile;
        NSLog(@"User Profile: %@", up);
    }
    
}


- (void)doLogin {

    //Are we logged in?
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    
    if(!loggedIn) {

        [[AdobeUXAuthManager sharedManager] login:self
                                  onSuccess: ^(AdobeAuthUserProfile * userProfile) {
                                       NSLog(@"success for login");
                                      [((RKCTestView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
                                  }
                                    onError: ^(NSError * error) {
                                         NSLog(@"Error in Login: %@", error);
                                    }];
    } else {
        
        [[AdobeUXAuthManager sharedManager] logout:^void {
            NSLog(@"success for logout");
            [((RKCTestView *)self.view).loginButton setTitle:@"Login" forState:UIControlStateNormal];
        } onError:^(NSError *error) {
            NSLog(@"Error on Logout: %@", error);
        }];
    }
}

@end
