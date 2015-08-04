//
//Copyright (c) 2015 Adobe Systems Incorporated. All rights reserved.
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
//  RKCView.m
//  PSDExtraction
//


#import "RKCView.h"
#import "RKCViewController.h"

@implementation RKCView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
        _loginButton.frame = CGRectMake(0, 0, frame.size.width, 100);
        [_loginButton addTarget:(RKCViewController *)self.superview action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_loginButton];
        
        _showMarketBrowserButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_showMarketBrowserButton setTitle:@"Show Market Browser" forState:UIControlStateNormal];
        _showMarketBrowserButton.frame = CGRectMake(0, 80, frame.size.width, 100);
        [_showMarketBrowserButton addTarget:(RKCViewController *)self.superview action:@selector(showMarketBrowser) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_showMarketBrowserButton];
    
        _resultText = [[UITextView alloc] initWithFrame:CGRectMake(0, 180, frame.size.width/2, 800)];
        _resultText.editable = NO;
        [self addSubview:_resultText];
        
        _uiImage = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2,180,250,250)];
        [self addSubview:_uiImage];

        
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
