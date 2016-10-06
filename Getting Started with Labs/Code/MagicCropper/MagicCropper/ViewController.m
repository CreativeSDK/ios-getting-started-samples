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
//  MagicCropper
//

#import "ViewController.h"
#include <AdobeCreativeSDKLabs/AdobeLabsMagicCropper.h>
#import <AdobeCreativeSDKCore/AdobeUXAuthManager.h>

#define CC_CLIENT_ID                  @"CHANGE_ME_CLIENT_ID"
#define CC_CLIENT_SECRET              @"CHANGE_ME_CLIENT_SECRET"


#define BUTTON_X_MARGIN             0
#define BUTTON_Y_MARGIN             20
#define BUTTON_Y_OFFSET             0
#define BUTTON_WIDTH                126
#define BUTTON_HEIGHT               40
#define VIEW_Y_OFFSET               (BUTTON_Y_MARGIN + (1*(BUTTON_Y_OFFSET+BUTTON_HEIGHT)))
#define BUTTON_PREV_IMAGE           @"Previous Image"
#define BUTTON_NEXT_IMAGE           @"Next Image"
#define BUTTON_CROP_IMAGE           @"Crop Image"
#define IMAGE_FORMAT_STRING         @"image%02d.jpg"

@interface ViewController ()

@end

static UIImage  * _debugImage;
static int        _cropIndex;

@implementation ViewController {
    UIImageView * _imageView;
    UIButton * _prevImageButton;
    UIButton * _nextImageButton;
    UIButton * _cropImageButton;
    int _currentImageNum;
    
    AdobeLabsMagicCropper *_magicCrop;
}




- (UIButton *)addButton: (NSString *)title withAction: (SEL)action withRect: (CGRect)rect {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: title forState: UIControlStateNormal];
    [button setFrame: rect];
    [button addTarget:self action: action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: button];
    return button;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // first set the clientID and clientSecret
    
    [AdobeUXAuthManager.sharedManager setAuthenticationParametersWithClientID: CC_CLIENT_ID
                                                             withClientSecret: CC_CLIENT_SECRET];

    
    // calculate button placement
    CGRect buttonRect = CGRectMake(BUTTON_X_MARGIN, BUTTON_Y_MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat leftoverWidth = viewWidth - (BUTTON_X_MARGIN * 2 + BUTTON_WIDTH*3);
    CGFloat interSpacing = (leftoverWidth / 2) + BUTTON_WIDTH;
    
    // add the first row of buttons
    _prevImageButton = [self addButton: BUTTON_PREV_IMAGE withAction: @selector(onButtonPrevImage) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    _nextImageButton = [self addButton: BUTTON_NEXT_IMAGE withAction: @selector(onButtonNextImage) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    _cropImageButton = [self addButton: BUTTON_CROP_IMAGE withAction: @selector(onButtonCropImage) withRect: buttonRect];

    // add the image view
    _imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, VIEW_Y_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VIEW_Y_OFFSET)];
    [self.view addSubview: _imageView];
    
    _debugImage = NULL;
    _cropIndex = 0;
    
    // load the first image
    _currentImageNum = 0;
    [self onButtonNextImage];
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


- (void)onButtonPrevImage {
    [self loadImage: _currentImageNum-1];
    _cropIndex = 0;
}

- (void)onButtonNextImage {
    [self loadImage: _currentImageNum+1];
    _cropIndex = 0;
}

- (void)loadImage: (int)imageNum {
    NSString * imageName = [NSString stringWithFormat: IMAGE_FORMAT_STRING, imageNum];
    UIImage * image = [UIImage imageNamed: imageName];
    if (image) {
        _imageView.image = image;
        _currentImageNum = imageNum;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////



- (void)onButtonCropImage {
    if (!_magicCrop)
        // it is enough to initialize it just once
        _magicCrop = [AdobeLabsMagicCropper new];
    
    NSString * imageName = [NSString stringWithFormat: IMAGE_FORMAT_STRING, _currentImageNum];
    
    // set image only once, setting an image will reinitialize the magicCrop values
    if (_cropIndex == 0)
        _magicCrop.image = [UIImage imageNamed: imageName];
    if (!_magicCrop.image)
        return;
    
    _magicCrop.useFaceDetector = true; // you may consider disabling it if performance is critical and you know there is no face in the image

    //_magicCrop.robustMode = true; // not exposed yet
 
    [_magicCrop generateCrops]; //
    
    // OR 
    //NSArray *aspectRatios = @[@1.0];
    //[_magicCrop generateCrops : aspectRatios]; //
    
    // OR
    //[_magicCrop generateCrops : aspectRatios cropSizes: @[@0.3, @0.4, @0.5]]; //
    
    // collect all faces
    //for (CIFaceFeature *f in faceFeatures)
    //{
    //    const smartCrop::CRectOfInterest rectOfInterest(
    //            f.bounds.origin.x, f.bounds.origin.x + f.bounds.size.width - 1, 
    //            f.bounds.origin.y, f.bounds.origin.y + f.bounds.size.height - 1, true /* face */);
    //    pSmartCrop->ModifyRectsOfInterest(rectOfInterest);
    //}
    
    NSUInteger numCrops = 8;
    NSArray *cropResults = [_magicCrop getTopCropResults: numCrops];
    
    AdobeLabsMagicCropResult *crop = cropResults[_cropIndex];
    
    if (_debugImage)
    {
        _imageView.image = _debugImage;
        _imageView.contentMode = UIViewContentModeCenter;
    }
    else if (_magicCrop.image && crop.cropRect.size.height > 0) 
    {
        CGImageRef croppedImageRef = CGImageCreateWithImageInRect([_magicCrop.image CGImage], crop.cropRect);
        UIImage * croppedImage = [UIImage imageWithCGImage:croppedImageRef];
        CGImageRelease(croppedImageRef);
        if (croppedImage) {
            _imageView.image = croppedImage;
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }

    if(_cropIndex < cropResults.count-1)
        _cropIndex++;
    
    // UIImage * croppedImage = (image ? [self cropImage: image withRect: cropRect] : nil);
    
    }

- (UIImage *)cropImage: (UIImage *)image withRect: (CGRect)cropRect
{
    UIGraphicsBeginImageContext(cropRect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect drawRect = CGRectMake(-cropRect.origin.x, -cropRect.origin.y, image.size.width, image.size.height);

    CGContextClipToRect(context, CGRectMake(0, 0, cropRect.size.width, cropRect.size.height));
    
    [image drawInRect:drawRect];
    
    // grab image
    UIImage * croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return croppedImage;
}

@end
