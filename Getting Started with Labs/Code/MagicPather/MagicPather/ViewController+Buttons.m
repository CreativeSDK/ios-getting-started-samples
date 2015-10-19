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
//  MagicPather
//

#import "ViewController.h"
#import "ViewController+Buttons.h"

#import "PathView.h"

#define BUTTON_TITLE_UNDO             @"Undo"
#define BUTTON_TITLE_NEWPATH          @"New Path"
#define BUTTON_TITLE_RESET            @"Reset"

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
    // add the first row of buttons
    self.undoButton = [self addButton: BUTTON_TITLE_UNDO withAction: @selector(onButtonUndo) withRect: buttonRect];
    buttonRect.origin.x += BUTTON_X_MARGIN + BUTTON_WIDTH;
    self.pathButton = [self addButton: BUTTON_TITLE_NEWPATH withAction: @selector(onButtonPath) withRect: buttonRect];
    buttonRect.origin.x += BUTTON_X_MARGIN + BUTTON_WIDTH;
    self.resetButton = [self addButton: BUTTON_TITLE_RESET withAction: @selector(onButtonReset) withRect: buttonRect];
}

- (void)onButtonUndo {
    [self.pathView undo];
}

- (void)onButtonPath {
    [self.pathView newPath];
}

- (void)onButtonReset {
    [self.pathView reset];
}

@end
