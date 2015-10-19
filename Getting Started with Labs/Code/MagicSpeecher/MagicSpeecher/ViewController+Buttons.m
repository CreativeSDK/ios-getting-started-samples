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
//  MagicSpeecher
//

#import "ViewController.h"
#import "ViewController+Buttons.h"

#define BUTTON_Y_MARGIN                 100
#define BUTTON_WIDTH                    360
#define BUTTON_HEIGHT                   60
#define BUTTON_SPACING                  40

#define BUTTON_TITLE_A1                 @"Play Audio File One"
#define BUTTON_TITLE_A2                 @"Play Audio File Two"
#define BUTTON_TITLE_B1                 @"Play Both Files Matched to File One"
#define BUTTON_TITLE_B2                 @"Play Both Files Matched to File Two"

static void * AudioPlayerStatusContext = &AudioPlayerStatusContext;

@interface MyUIButton : UIButton
@property SEL myAction;
- (void)callAction: (id)controller;
- (void)enable: (BOOL)bEnabled;
@end

@implementation MyUIButton
-(void)callAction: (id)controller {
    IMP imp = [controller methodForSelector: self.myAction];
    if (imp) { void (*func)(id, SEL) = (void *)imp; func(controller, self.myAction); }
}
-(void)enable:(BOOL)bEnabled {
    self.enabled = bEnabled;
    self.backgroundColor = bEnabled ? [UIColor colorWithRed: .1 green: .1 blue: .5 alpha: 1.0] : [UIColor grayColor];
    [self setTitleColor: bEnabled ? [UIColor yellowColor] : [UIColor darkGrayColor] forState: UIControlStateNormal];
}
@end

@implementation ViewController (Buttons)

- (UIButton *)addButton: (NSString *)title withAction: (SEL)action andClientAction: (SEL)clientAction withRect: (CGRect)rect {
    MyUIButton * button = [MyUIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: title forState: UIControlStateNormal];
    [button setFrame: rect];
    button.myAction = clientAction;
    [button addTarget:self action: action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: button];
    button.backgroundColor = [UIColor colorWithRed: .1 green: .1 blue: .5 alpha: 1.0];
    [button setTitleColor: [UIColor yellowColor] forState: UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:20]];
    button.hidden = NO;
    return button;
}

- (void)addButtons
{
    // calculate button placement
    CGFloat viewWidth = self.view.bounds.size.width;
    CGRect buttonRect = CGRectMake(viewWidth/2-BUTTON_WIDTH/2, BUTTON_Y_MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT);
    
    // add the buttons
    self.playAudioFile1 = [self addButton: BUTTON_TITLE_A1 withAction: @selector(onButtonPress:) andClientAction: @selector(onButtonPlayAudioFile1) withRect: buttonRect];
    buttonRect.origin.y += (BUTTON_HEIGHT + BUTTON_SPACING);
    
    self.playAudioFile2 = [self addButton: BUTTON_TITLE_A2 withAction: @selector(onButtonPress:) andClientAction: @selector(onButtonPlayAudioFile2) withRect: buttonRect];
    buttonRect.origin.y += (BUTTON_HEIGHT + BUTTON_SPACING);

    self.playBothMatchedToFile1 = [self addButton: BUTTON_TITLE_B1 withAction: @selector(onButtonPress:) andClientAction: @selector(onButtonPlayBothMatchedToFile1) withRect: buttonRect];
    buttonRect.origin.y += (BUTTON_HEIGHT + BUTTON_SPACING);

    self.playBothMatchedToFile2 = [self addButton: BUTTON_TITLE_B2 withAction: @selector(onButtonPress:) andClientAction: @selector(onButtonPlayBothMatchedToFile2) withRect: buttonRect];

    [self enableButtons];
    
    // init the audio player
    self.audioPlayer = [[AVQueuePlayer alloc] init];
    [self addObserver:self forKeyPath:@"audioPlayer.currentItem" options:NSKeyValueObservingOptionNew context: AudioPlayerStatusContext];

}

- (void)onButtonPress: (id)sender {
    MyUIButton * myButton = (MyUIButton *)sender;
    // do some enable/disablement
    [myButton callAction: self];
}

- (void)startSpinner {
    if (nil == self.spinner)
    {
        self.spinner =  [[UIActivityIndicatorView alloc] initWithFrame:
                            CGRectMake(self.view.bounds.origin.x + (self.view.bounds.size.width / 2 - 20),
                                       2 * BUTTON_HEIGHT + BUTTON_SPACING + BUTTON_Y_MARGIN - 3,
                                       50,
                                       50)];
        
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.spinner.color = [UIColor blueColor];
        [self.spinner startAnimating];
        
        [self.view addSubview: self.spinner];
    }
}

- (void)stopSpinner {
    if (nil != self.spinner) { [self.spinner removeFromSuperview]; self.spinner = nil; }
}

- (void)enableButtons {
    if (self.audioPlayer.items.count > 0) return; // ignore enable if we're playing

    [self stopSpinner];
    
    [(MyUIButton*)self.playAudioFile1 enable: YES];
    [(MyUIButton*)self.playAudioFile2 enable: YES];

    [(MyUIButton*)self.playBothMatchedToFile1 enable: self.audioAsset2MatchedToAudioAsset1 == nil ? NO : YES];
    [(MyUIButton*)self.playBothMatchedToFile2 enable: self.audioAsset1MatchedToAudioAsset2 == nil ? NO : YES];
}

- (void)disableButtons {
    [self startSpinner];
    
    [(MyUIButton*)self.playAudioFile1 enable: NO];
    [(MyUIButton*)self.playAudioFile2 enable: NO];
    [(MyUIButton*)self.playBothMatchedToFile1 enable: NO];
    [(MyUIButton*)self.playBothMatchedToFile2 enable: NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != AudioPlayerStatusContext || (self.audioPlayer.items.count != 0)) return;
    // audio playback has ended
    [self enableButtons];
}

- (void)onButtonPlayAudioFile1 {
    [self.audioPlayer insertItem: [[AVPlayerItem alloc] initWithAsset: self.audioAsset1] afterItem: nil];
    [self disableButtons];
    [self.audioPlayer play];
}

- (void)onButtonPlayAudioFile2 {
    [self.audioPlayer insertItem: [[AVPlayerItem alloc] initWithAsset: self.audioAsset2] afterItem: nil];
    [self disableButtons];
    [self.audioPlayer play];
}

- (void)onButtonPlayBothMatchedToFile1 {
    [self.audioPlayer insertItem: [[AVPlayerItem alloc] initWithAsset: self.audioAsset1] afterItem: nil];
    [self.audioPlayer insertItem: [[AVPlayerItem alloc] initWithAsset: self.audioAsset2MatchedToAudioAsset1] afterItem: nil];
    [self disableButtons];
    [self.audioPlayer play];
    
}

- (void)onButtonPlayBothMatchedToFile2 {
    [self.audioPlayer insertItem: [[AVPlayerItem alloc] initWithAsset: self.audioAsset1MatchedToAudioAsset2] afterItem: nil];
    [self.audioPlayer insertItem: [[AVPlayerItem alloc] initWithAsset: self.audioAsset2] afterItem: nil];
    [self disableButtons];
    [self.audioPlayer play];
}

@end
