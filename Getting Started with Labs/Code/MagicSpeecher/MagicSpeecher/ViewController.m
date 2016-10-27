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
//  MagicSpeecher

#import "ViewController.h"
#import "ViewController+Buttons.h"

#import <AVFoundation/AVFoundation.h>
#import <AdobeCreativeSDKCore/AdobeUXAuthManager.h>
#import <AdobeCreativeSDKLabs/AdobeLabsMagicAudioSpeechMatcher.h>

#warning Please update these required values to match the ones provided by creativesdk.com
static NSString * const kCreativeSDKClientId = @"Change me";
static NSString * const kCreativeSDKClientSecret = @"Change me";
static NSString * const kCreativeSDKRedirectURLString = @"Change me";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    // init the view
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
    
    // load the audio assets
    NSString * path1 = [[NSBundle mainBundle] pathForResource: @"audioFile1" ofType:@"wav"];
    NSString * path2 = [[NSBundle mainBundle] pathForResource: @"audioFile2" ofType:@"wav"];
    self.audioAsset1 = [AVURLAsset assetWithURL: [NSURL fileURLWithPath: path1]];
    self.audioAsset2 = [AVURLAsset assetWithURL: [NSURL fileURLWithPath: path2]];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    static BOOL firstTime = YES;
    //[[AdobeUXAuthManager sharedManager] logout: nil onError: nil];

    if (firstTime) {
        firstTime = NO;
        
        //[[AdobeUXAuthManager sharedManager] logout: nil onError: nil];

        // login, then match  (NOTE: also match on error, because error might be already logged in
        [[AdobeUXAuthManager sharedManager] login: self
                                        onSuccess:^(AdobeAuthUserProfile *profile) { [self engageAudioMatching]; }
                                          onError:^(NSError *error) {
              
              if (([AdobeUXAuthManager sharedManager].isAuthenticated) ||
                  (error.domain == AdobeAuthErrorDomain && error.code == AdobeAuthErrorCodeOffline))
              {
                  [self engageAudioMatching];
                  return;
              }
              
              CGRect rect = self.view.frame; rect.origin.x += 10; rect.size.width -= 10; rect.origin.y = 10; rect.size.height = 100;
              UILabel * errorLabel = [[UILabel alloc] initWithFrame: rect];
              errorLabel.text = @"Please restart app and login to Creative Cloud";
              [self.view addSubview: errorLabel];
        }];
    }
}

- (void)engageAudioMatching
{
    // init two speech matchers - one to match audio 2 to audio 1 and one to match audio 1 to audio 2
    AdobeLabsMagicAudioSpeechMatcher * match2To1 = [[AdobeLabsMagicAudioSpeechMatcher alloc] init];
    AdobeLabsMagicAudioSpeechMatcher * match1To2 = [[AdobeLabsMagicAudioSpeechMatcher alloc] init];
    
    // add the match targets to the speech matchers
    [match2To1 addMatchTarget: self.audioAsset1];
    [match1To2 addMatchTarget: self.audioAsset2];
    
    // match
    [match2To1 matchSpeechOf:  self.audioAsset2 completionBlock: ^(AVAsset * asset, NSError * error) {
        self.audioAsset2MatchedToAudioAsset1 = asset;
        [self enableButtons];
    }];
    [match1To2 matchSpeechOf:  self.audioAsset1 completionBlock: ^(AVAsset * asset, NSError * error) {
        self.audioAsset1MatchedToAudioAsset2 = asset;
        [self enableButtons];
    }];
}

@end
