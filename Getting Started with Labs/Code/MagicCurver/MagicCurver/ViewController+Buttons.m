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

#import "CurveView.h"

#import <AdobeCreativeSDKLabs/AdobeLabsMagicCurve.h>
#import <AdobeCreativeSDKCore/AdobeUXAuthManager.h>

#define BUTTON_TITLE_CIRCLE             @"Circle"
#define BUTTON_TITLE_SQUARE             @"Square"
#define BUTTON_TITLE_PATH               @"Path"
#define BUTTON_TITLE_CLEAR              @"Reset"
#define BUTTON_TITLE_CHANGE_POINT       @"Change Point"
#define BUTTON_TITLE_DELETE_POINT       @"Delete Point"


@implementation ViewController (Buttons)

- (UIButton *)addButton: (NSString *)title withAction: (SEL)action withRect: (CGRect)rect {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: title forState: UIControlStateNormal];
    [button setFrame: rect];
    [button addTarget:self action: action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: button];
    button.hidden = NO;
    return button;
}

- (void)addButtons {

    // calculate button placement
    CGRect buttonRect = CGRectMake(BUTTON_X_MARGIN, BUTTON_Y_MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat leftoverWidth = viewWidth - (BUTTON_X_MARGIN * 2 + BUTTON_WIDTH*3);
    CGFloat interSpacing = (leftoverWidth / 2) + BUTTON_WIDTH;
    
    // add the first row of buttons
    self.circleButton = [self addButton: BUTTON_TITLE_CIRCLE withAction: @selector(onButtonSetCircle) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    self.squareButton = [self addButton: BUTTON_TITLE_SQUARE withAction: @selector(onButtonSetSquare) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    self.pathButton = [self addButton: BUTTON_TITLE_PATH withAction: @selector(onButtonSetPath) withRect: buttonRect];
    
    // add the second row of buttons
    buttonRect.origin.x = BUTTON_X_MARGIN; buttonRect.origin.y += buttonRect.size.height + BUTTON_Y_OFFSET;
    self.changePointButton = [self addButton: BUTTON_TITLE_CHANGE_POINT withAction: @selector(onButtonChangePoint) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    self.deletePointButton = [self addButton: BUTTON_TITLE_DELETE_POINT withAction: @selector(onButtonDeletePoint) withRect: buttonRect];
    buttonRect.origin.x += interSpacing;
    self.clearSelectionButton = [self addButton: BUTTON_TITLE_CLEAR withAction: @selector(onButtonClear) withRect: buttonRect];
    
    self.circleButton.backgroundColor = [UIColor orangeColor];
}

- (void)onButtonSetCircle {
    if (self.shapeMode != AdobeMagicCurverShapeModeCircle) {
        self.shapeMode = AdobeMagicCurverShapeModeCircle;
        self.circleButton.backgroundColor = [UIColor orangeColor];
        self.squareButton.backgroundColor = [UIColor clearColor];
        self.pathButton.backgroundColor = [UIColor clearColor];
        [self resetCurve];
    }
}

- (void)onButtonSetSquare {
    if (self.shapeMode != AdobeMagicCurverShapeModeSquare) {
        self.shapeMode = AdobeMagicCurverShapeModeSquare;
        self.circleButton.backgroundColor = [UIColor clearColor];
        self.squareButton.backgroundColor = [UIColor orangeColor];
        self.pathButton.backgroundColor = [UIColor clearColor];
        [self resetCurve];
    }
}

- (void)onButtonSetPath {
    if (self.shapeMode != AdobeMagicCurverShapeModePath) {
        self.shapeMode = AdobeMagicCurverShapeModePath;
        self.circleButton.backgroundColor = [UIColor clearColor];
        self.squareButton.backgroundColor = [UIColor clearColor];
        self.pathButton.backgroundColor = [UIColor orangeColor];
        [self resetCurve];
    }
}

- (void)onButtonChangePoint
{
    if (self.curveView.changeControlPoint)
    {
        self.curveView.changeControlPoint = NO;
        self.curveView.deleteControlPoint = NO;
        self.changePointButton.backgroundColor = [UIColor clearColor];
        self.deletePointButton.backgroundColor = [UIColor clearColor];
    }
    else
    {
        self.curveView.changeControlPoint = YES;
        self.curveView.deleteControlPoint = NO;
        self.changePointButton.backgroundColor = [UIColor redColor];
        self.deletePointButton.backgroundColor = [UIColor clearColor];
    }
}

- (void)onButtonDeletePoint
{
    if (self.curveView.deleteControlPoint)
    {
        self.curveView.changeControlPoint = NO;
        self.curveView.deleteControlPoint = NO;
        self.changePointButton.backgroundColor = [UIColor clearColor];
        self.deletePointButton.backgroundColor = [UIColor clearColor];
    }
    else
    {
        self.curveView.changeControlPoint = NO;
        self.curveView.deleteControlPoint = YES;
        self.changePointButton.backgroundColor = [UIColor clearColor];
        self.deletePointButton.backgroundColor = [UIColor redColor];
    }
}

- (void)onButtonClear {
    [self resetCurve];
}

@end
