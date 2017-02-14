/*
 * Copyright (c) 2017 Adobe Systems Incorporated. All rights reserved.
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

#import "ViewController.h"

#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>
#import <AdobeCreativeSDKImage/AdobeCreativeSDKImage.h>

static NSString *const kAVYAdobeCreativeCloudKey = @"changeme";
static NSString *const kAVYAdobeCreativeCloudSecret = @"changeme";

@interface ViewController () <AdobeUXImageEditorViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) AdobeUXImageEditorViewController *controller;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:kAVYAdobeCreativeCloudKey
                                                               withClientSecret:kAVYAdobeCreativeCloudSecret];
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    if ([sender state] == UIGestureRecognizerStateRecognized) {
        
        if ([self controller] != nil) {
            return;
        }
        
        UIImage *image = [UIImage imageNamed:@"exampleImage"];
        [self setController:[[AdobeUXImageEditorViewController alloc] initWithImage:image]];
        [[self controller] setDelegate:self];
        [self presentViewController:[self controller] animated:YES completion:nil];
    }
}

- (void)dismissEditor
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self setController:nil];
    }];
}

#pragma mark - AdobeUXImageEditorViewControllerDelegate

- (void)photoEditor:(AdobeUXImageEditorViewController *)editor finishedWithImage:(UIImage *__nullable)image
{
    [[self imageView] setImage:image];
    [self dismissEditor];
}

- (void)photoEditorCanceled:(AdobeUXImageEditorViewController *)editor
{
    [self dismissEditor];
}

@end
