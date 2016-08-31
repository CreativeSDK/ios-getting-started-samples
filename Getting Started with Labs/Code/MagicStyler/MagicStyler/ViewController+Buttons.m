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
//  ViewController+Buttons.m
//  MagicPerspectivator
//

#import "ViewController.h"
#import "ViewController+Buttons.h"

#define BUTTON_TITLE_IMAGE1          @"Image 1"
#define BUTTON_TITLE_IMAGE2          @"Image 2"
#define BUTTON_TITLE_STYLE1          @"Style 1"
#define BUTTON_TITLE_STYLE2          @"Style 2"
#define BUTTON_TITLE_STYLE3          @"Style 3"
#define BUTTON_TITLE_CLEAR           @"Clear"

@interface MyUIButton : UIButton
@property SEL myAction;
- (void)callAction: (id)controller;
@end

@implementation MyUIButton
-(void)callAction: (id)controller {
    IMP imp = [controller methodForSelector: self.myAction];
    if (imp) { void (*func)(id, SEL) = (void *)imp; func(controller, self.myAction); }
}
@end

@implementation ViewController (Buttons)

- (UIButton *)addButtonA: (NSString *)title withAction: (SEL)action andClientAction: (SEL)clientAction withRect: (CGRect)rect {
    MyUIButton * button = [MyUIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: title forState: UIControlStateNormal];
    [button setFrame: rect];
    button.myAction = clientAction;
    [button addTarget:self action: action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: button];
    button.hidden = YES;
    return button;
}

- (void)addButtons
{
    
    CGRect buttonRect = CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    CGFloat leftoverWidth, interSpacing;
    
    // calculate button placement for image buttons
    leftoverWidth = viewWidth - (BUTTON_WIDTH*2);
    interSpacing = (leftoverWidth / 3) + BUTTON_WIDTH;
    
    buttonRect.origin.x = (leftoverWidth / 3);
    buttonRect.origin.y = BUTTON_Y_OFFSET_TOP;
    
    // add the image buttons
    self.image1Button = [self addButtonA: BUTTON_TITLE_IMAGE1 withAction: @selector(onImageButton:) andClientAction: @selector(onButtonImage1) withRect: buttonRect];
    
    buttonRect.origin.x += interSpacing;
    self.image2Button = [self addButtonA: BUTTON_TITLE_IMAGE2 withAction: @selector(onImageButton:) andClientAction: @selector(onButtonImage2) withRect: buttonRect];
    
    // calculate button placement for style buttons
    leftoverWidth = viewWidth - ((BUTTON_WIDTH)*4);
    interSpacing = (leftoverWidth / 5) + BUTTON_WIDTH;

    buttonRect.origin.x = (leftoverWidth / 5);
    buttonRect.origin.y = viewHeight - (buttonRect.size.height) - BUTTON_Y_OFFSET_BOT;
    
    // add the style buttons
    self.style1Button = [self addButtonA: BUTTON_TITLE_STYLE1 withAction: @selector(onStyleButton:) andClientAction: @selector(onButtonStyle1) withRect: buttonRect];
    
    buttonRect.origin.x += interSpacing;
    self.style2Button = [self addButtonA: BUTTON_TITLE_STYLE2 withAction: @selector(onStyleButton:) andClientAction: @selector(onButtonStyle2) withRect: buttonRect];

    buttonRect.origin.x += interSpacing;
    self.style3Button = [self addButtonA: BUTTON_TITLE_STYLE3 withAction: @selector(onStyleButton:) andClientAction: @selector(onButtonStyle3) withRect: buttonRect];

    buttonRect.origin.x += interSpacing;
    self.clearButton = [self addButtonA: BUTTON_TITLE_CLEAR withAction: @selector(onStyleButton:) andClientAction: @selector(onButtonClear) withRect: buttonRect];
    

    self.image1Button.hidden = NO;
    self.image2Button.hidden = NO;

    self.style1Button.hidden = NO;
    self.style2Button.hidden = NO;
    self.style3Button.hidden = NO;
    self.clearButton.hidden = NO;
}

- (void)onImageButton: (id)sender {
    MyUIButton * myButton = (MyUIButton *)sender;
    [self setImageButton: myButton];
    [myButton callAction: self];
}

- (void)setImageButton: (UIButton *)button {
    
    self.image1Button.backgroundColor = [UIColor clearColor];
    self.image2Button.backgroundColor = [UIColor clearColor];
    
    button.backgroundColor = [UIColor colorWithRed:0.6 green:0.9 blue:0.0 alpha:1.0];
    
    self.style1Button.backgroundColor = [UIColor clearColor];
    self.style2Button.backgroundColor = [UIColor clearColor];
    self.style3Button.backgroundColor = [UIColor clearColor];
    self.clearButton.backgroundColor = [UIColor clearColor];
}

- (void)onStyleButton: (id)sender {
    MyUIButton * myButton = (MyUIButton *)sender;
    [self setStyleButton: myButton];
    [myButton callAction: self];
}

- (void)setStyleButton: (UIButton *)button {
    
    self.style1Button.backgroundColor = [UIColor clearColor];
    self.style2Button.backgroundColor = [UIColor clearColor];
    self.style3Button.backgroundColor = [UIColor clearColor];
    self.clearButton.backgroundColor = [UIColor clearColor];
    
    button.backgroundColor = [UIColor orangeColor];
}

-(void)showImageButtons {
    self.image1Button.hidden = NO;
    self.image2Button.hidden = NO;
}

-(void)hideImageButtons {
    self.image1Button.hidden = YES;
    self.image2Button.hidden = YES;
}

-(void)showStyleButtons {
    self.style1Button.hidden = NO;
    self.style2Button.hidden = NO;
    self.style3Button.hidden = NO;
    self.clearButton.hidden = NO;
}

-(void)hideStyleButtons {
    self.style1Button.hidden = YES;
    self.style2Button.hidden = YES;
    self.style3Button.hidden = YES;
    self.clearButton.hidden = YES;
}

- (UIActivityIndicatorView *)createSpinner {
    
    UIActivityIndicatorView * spinner =  [[UIActivityIndicatorView alloc]initWithFrame: CGRectMake(
        self.imageView.bounds.origin.x + (self.imageView.bounds.size.width / 2 - 75),
        self.imageView.bounds.origin.y + (self.imageView.bounds.size.height / 2 - 75),
        150,
        150)];
    
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    spinner.color = [UIColor magentaColor];
    [spinner startAnimating];
    
    [self.view addSubview: spinner];
    return spinner;
}

@end
