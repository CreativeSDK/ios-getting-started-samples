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

#define BUTTON_TITLE_PARK               @"Park"
#define BUTTON_TITLE_TOWNSEND           @"Townsend"
#define BUTTON_TITLE_BAKER_HAMILTON     @"Baker-Hamilton"

#define BUTTON_TITLE_NONE               @"None"
#define BUTTON_TITLE_AUTOMATIC          @"Auto"
#define BUTTON_TITLE_HORIZONTAL         @"Horizontal"
#define BUTTON_TITLE_VERTICAL           @"Vertical"
#define BUTTON_TITLE_LEVEL              @"Level"
#define BUTTON_TITLE_RECTIFY            @"Rectify"

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
    // calculate button placement
    CGRect buttonRect = CGRectMake(BUTTON_X_MARGIN, BUTTON_Y_MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat leftoverWidth = viewWidth - (BUTTON_X_MARGIN * 2 + BUTTON_WIDTH*3);
    CGFloat interSpacing = (leftoverWidth / 2) + BUTTON_WIDTH;
    
    // add the first row of buttons
    self.parkButton = [self addButtonA: BUTTON_TITLE_PARK withAction: @selector(onImageButton:) andClientAction: @selector(onButtonPark) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    
    self.townsendButton = [self addButtonA: BUTTON_TITLE_TOWNSEND withAction: @selector(onImageButton:) andClientAction:@selector(onButtonTownsend) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    
    self.bakerButton = [self addButtonA: BUTTON_TITLE_BAKER_HAMILTON withAction: @selector(onImageButton:) andClientAction: @selector(onButtonBakerHamilton) withRect: buttonRect];
    
    self.parkButton.hidden = NO;
    self.townsendButton.hidden = NO;
    self.bakerButton.hidden = NO;
    
    // add the second row of buttons
    buttonRect.origin.x = BUTTON_X_MARGIN;
    buttonRect.origin.y += buttonRect.size.height + BUTTON_Y_OFFSET;
    leftoverWidth = viewWidth - (BUTTON_X_MARGIN * 2 + BUTTON_WIDTH*6);
    interSpacing = (leftoverWidth / 5) + BUTTON_WIDTH;
    
    self.noneButton = [self addButtonA: BUTTON_TITLE_NONE withAction: @selector(onModeButton:) andClientAction: @selector(onButtonNone) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    
    self.autoButton = [self addButtonA: BUTTON_TITLE_AUTOMATIC withAction: @selector(onModeButton:) andClientAction: @selector(onButtonAutomatic) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    
    self.horizontalButton = [self addButtonA: BUTTON_TITLE_HORIZONTAL withAction: @selector(onModeButton:) andClientAction: @selector(onButtonHorizontal) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    
    self.verticalButton = [self addButtonA: BUTTON_TITLE_VERTICAL withAction: @selector(onModeButton:) andClientAction: @selector(onButtonVertical) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    
    self.levelButton = [self addButtonA: BUTTON_TITLE_LEVEL withAction: @selector(onModeButton:) andClientAction: @selector(onButtonLevel) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    
    self.rectifyButton = [self addButtonA: BUTTON_TITLE_RECTIFY withAction: @selector(onModeButton:) andClientAction: @selector(onButtonRectify) withRect: buttonRect];

}

- (void)onImageButton: (id)sender {
    MyUIButton * myButton = (MyUIButton *)sender;
    [self setImageButton: myButton];
    [myButton callAction: self];

}

- (void)onModeButton: (id)sender {
    MyUIButton * myButton = (MyUIButton *)sender;
    [self setModeButton: myButton andHidden: NO];
    [myButton callAction: self];
}

- (void)setImageButton: (UIButton *) button {
    self.parkButton.backgroundColor = [UIColor clearColor];
    self.townsendButton.backgroundColor = [UIColor clearColor];
    self.bakerButton.backgroundColor = [UIColor clearColor];
    button.backgroundColor = [UIColor orangeColor];
}

- (void)setModeButton: (UIButton *)button andHidden: (BOOL)hidden {
    
    self.noneButton.backgroundColor = [UIColor clearColor];
    self.autoButton.backgroundColor = [UIColor clearColor];
    self.horizontalButton.backgroundColor = [UIColor clearColor];
    self.verticalButton.backgroundColor = [UIColor clearColor];
    self.levelButton.backgroundColor = [UIColor clearColor];
    self.rectifyButton.backgroundColor = [UIColor clearColor];
    
    self.noneButton.hidden = hidden;
    self.autoButton.hidden = hidden;
    self.horizontalButton.hidden = hidden;
    self.verticalButton.hidden = hidden;
    self.levelButton.hidden = hidden;
    self.rectifyButton.hidden = hidden;
    
    button.backgroundColor = [UIColor redColor];
}

-(void)showModeButtons {
    [self setModeButton: self.noneButton andHidden: NO];
}

-(void)hideModeButtons {
    [self setModeButton: nil andHidden: YES];
}

- (UIActivityIndicatorView *)createSpinner {
    
    UIActivityIndicatorView * spinner =  [[UIActivityIndicatorView alloc]initWithFrame: CGRectMake(
        self.magicPerspectiveView.bounds.origin.x + (self.magicPerspectiveView.bounds.size.width / 2 - 75),
        self.magicPerspectiveView.bounds.origin.y + (self.magicPerspectiveView.bounds.size.height / 2 - 75),
        150,
        150)];
    
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    spinner.color = [UIColor magentaColor];
    [spinner startAnimating];
    
    [self.view addSubview: spinner];
    return spinner;
}

@end
