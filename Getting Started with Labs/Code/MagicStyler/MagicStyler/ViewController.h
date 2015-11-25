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
//  ViewController.h
//  MagicStyler
//

#import <UIKit/UIKit.h>

#import <AdobeCreativeSDKLabs/AdobeLabsMagicStyle.h>

@interface ViewController : UIViewController

@property AdobeLabsMagicStyle *magicStyle;

@property UIImageView *imageView;
@property UIImageView *style1View;
@property UIImageView *style2View;
@property UIImageView *style3View;

@property UIButton * image1Button;
@property UIButton * image2Button;

@property UIButton * style1Button;
@property UIButton * style2Button;
@property UIButton * style3Button;
@property UIButton * clearButton;

- (void)onButtonImage1;
- (void)onButtonImage2;

- (void)onButtonStyle1;
- (void)onButtonStyle2;
- (void)onButtonStyle3;
- (void)onButtonClear;

@property UIImage* input;
@property UIImage* result;

@end

