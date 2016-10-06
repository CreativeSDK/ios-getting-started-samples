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
//  MagicVectorizer
//

#import "ViewController.h"
#import <AdobeCreativeSDKLabs/AdobeLabsMagicVectorizer.h>
#import <AdobeCreativeSDKCore/AdobeUXAuthManager.h>

#define CC_CLIENT_ID                @"CHANGE_ME_CLIENT_ID"
#define CC_CLIENT_SECRET            @"CHANGE_ME_CLIENT_SECRET"

#define SOURCE_IMAGE_NAME           @"madeInUSA.png"


@interface ViewController ()

@end

@implementation ViewController {
    UIImageView * _imageView;
    CAShapeLayer * _shapeLayer;
    UIButton * _buttonImage;
    UIButton * _buttonVectors;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // first set the clientID and clientSecret
    [AdobeUXAuthManager.sharedManager setAuthenticationParametersWithClientID: CC_CLIENT_ID
                                                             withClientSecret: CC_CLIENT_SECRET];

    // add two buttons: Image and Vectors
    CGRect rect = CGRectMake(0, 20, 126, 40);
    _buttonImage = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [_buttonImage setTitle: @"Image" forState: UIControlStateNormal];
    [_buttonImage setFrame: rect];
    [_buttonImage addTarget: self action: @selector(onButtonImage:) forControlEvents:UIControlEventTouchUpInside];
    _buttonImage.backgroundColor = [UIColor orangeColor];
    [self.view addSubview: _buttonImage];
    
    rect.origin.x = self.view.frame.size.width - rect.size.width;
    _buttonVectors = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [_buttonVectors setTitle: @"Vector" forState: UIControlStateNormal];
    [_buttonVectors setFrame: rect];
    [_buttonVectors addTarget: self action: @selector(onButtonVectors:) forControlEvents:UIControlEventTouchUpInside];
    _buttonVectors.backgroundColor = [UIColor clearColor];
    [self.view addSubview: _buttonVectors];
    
    // allocate an image view to display our source image
    _imageView = [[UIImageView alloc] initWithFrame:
                                CGRectMake(0,
                                           rect.origin.y + rect.size.height,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height-(rect.origin.y + rect.size.height))];
    
    // load the source image into the image view
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = [UIImage imageNamed: SOURCE_IMAGE_NAME];
    [self.view addSubview: _imageView];

    // MagicVectorize the image into a UIBezierPath
    AdobeLabsMagicVectorizer * magicVectorizer = [[AdobeLabsMagicVectorizer alloc] init];
    
    magicVectorizer.smoothing = 0.75;       // 0.0 - 4.0, default 1.0
    magicVectorizer.downsampling = 0;       // 0 - 4, default 1
    magicVectorizer.makeBezierCurves = NO;  // default YES, NO means create line segments
    magicVectorizer.iso = 148;              // 1 - 254, default 127, see below for meaning

    UIBezierPath * vectorizedPath = [magicVectorizer vectorize: _imageView.image];
    
    // scale the vectorized path to the image scale that is currently being displayed
    vectorizedPath = [self scaleVectorizedPathToDisplayedImageScale: vectorizedPath];
    
	// make a CAShapeLayer to display the vectorized version, but don't add it to the view's layer hierarchy until button press
    _shapeLayer = [[CAShapeLayer alloc] init];
    _shapeLayer.frame = _imageView.frame;
    _shapeLayer.strokeColor = [[UIColor redColor] CGColor];
    _shapeLayer.fillColor = [[UIColor greenColor] CGColor];
    _shapeLayer.lineWidth = 1;
    [_shapeLayer setPath: vectorizedPath.CGPath];
}

- (UIBezierPath *)scaleVectorizedPathToDisplayedImageScale: (UIBezierPath *)vectorizedPath {
    
    CGFloat scaleFactor = _imageView.bounds.size.width / _imageView.image.size.width;
    CGRect  boundingBox = CGPathGetBoundingBox(vectorizedPath.CGPath);
    
    // scale down the path and translate to 0, 0
    CGAffineTransform scaleTransform = CGAffineTransformIdentity;
    scaleTransform = CGAffineTransformScale(scaleTransform, scaleFactor, scaleFactor);
    scaleTransform = CGAffineTransformTranslate(scaleTransform, -CGRectGetMinX(boundingBox), -CGRectGetMinY(boundingBox));
    
    // center the scaled path in the view
    CGSize scaledSize = CGSizeApplyAffineTransform(boundingBox.size, CGAffineTransformMakeScale(scaleFactor, scaleFactor));
    CGSize centerOffset = CGSizeMake((CGRectGetWidth(_imageView.frame)-scaledSize.width)/(scaleFactor*2.0),
                                     (CGRectGetHeight(_imageView.frame)-scaledSize.height)/(scaleFactor*2.0));
    scaleTransform = CGAffineTransformTranslate(scaleTransform, centerOffset.width, centerOffset.height);
    
    // apply the transform and make a new UIBezierPath
    CGPathRef scaledPath = CGPathCreateCopyByTransformingPath(vectorizedPath.CGPath, &scaleTransform);
    if (scaledPath == nil) return vectorizedPath;
    UIBezierPath * scaledBezierPath = [UIBezierPath bezierPathWithCGPath: scaledPath];
    CGPathRelease(scaledPath); // release the copied path
    
    return scaledBezierPath;
}

- (void)onButtonImage: (id)sender {
    _buttonVectors.backgroundColor = [UIColor clearColor];
    _buttonImage.backgroundColor = [UIColor orangeColor];
    [self.view addSubview: _imageView];
    [_shapeLayer removeFromSuperlayer];
}

- (void)onButtonVectors: (id)sender {
    _buttonImage.backgroundColor = [UIColor clearColor];
    _buttonVectors.backgroundColor = [UIColor orangeColor];
    [[self.view layer] addSublayer: _shapeLayer];
    [_imageView removeFromSuperview];
}


@end
