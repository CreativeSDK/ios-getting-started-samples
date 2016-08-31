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
//  BrushView.h
//  Magic Brusher
//

#import "BrushView.h"

@interface BrushView()
    @property (nonatomic, retain) IBOutlet UIImageView *canvasView;
    @property (nonatomic, retain) IBOutlet UIImageView *strokeView;
@end

@implementation BrushView {
    AdobeLabsMagicBrush * _magicBrush;
    AdobeLabsMagicBrushDisplayType _displayType;
}

- (void) setBrushView
{
    self.backgroundColor=[[UIColor whiteColor] colorWithAlphaComponent:1.0];
    _magicBrush = [[AdobeLabsMagicBrush alloc] initWithCanvasSize:self.bounds.size]; //If do this, then no need of the following two lines
    [_magicBrush setBrushType:AdobeLabsMagicBrushWatercolor];
    [_magicBrush setBrushThickness:30.0];
    [_magicBrush setBrushColor:[UIColor blackColor]];
    
    self.canvasView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self addSubview:self.canvasView];
}

- (void) clearCanvas
{
    [_magicBrush clearCanvas];
    [self setNeedsDisplay];
}

- (void)setDisplayType: (AdobeLabsMagicBrushDisplayType) displayIndex
{
    _displayType = displayIndex;
    if (displayIndex == AdobeLabsMagicBrushCurrentCanvas){
        [self.strokeView removeFromSuperview];
        [self addSubview:self.canvasView];
    }
    else if (displayIndex == AdobeLabsMagicBrushCurrentStroke){
        [self.canvasView removeFromSuperview];
    }
    [self setNeedsDisplay];
}

- (void)setBrushType: (AdobeLabsMagicBrushType)libraryIndex
{
    [_magicBrush setBrushType:libraryIndex];
}

- (NSString*) brushTypeName: (NSInteger)index
{
    return [_magicBrush brushTypeName:(int)index];
}

- (int) numBrushTypes
{
    return [_magicBrush numBrushTypes];
}


- (void) setBrushThickness: (float) thickness
{
    [_magicBrush setBrushThickness:thickness];
}

- (void) setBrushColor: (UIColor *)color
{
    [_magicBrush setBrushColor:color];
}

- (void) drawRect:(CGRect)rect
{
    
    if (_displayType == AdobeLabsMagicBrushCurrentCanvas){
        UIImage *currentCanvas = [_magicBrush canvas];
        if (currentCanvas){
            [self.canvasView setImage:currentCanvas];
        }
    }
    else if (_displayType == AdobeLabsMagicBrushCurrentStroke){
        int strokeWidth, strokeHeight;
        UIImage *currentStroke = [_magicBrush currentStroke];
        strokeWidth = currentStroke.size.width;
        strokeHeight = currentStroke.size.height;
        
        if (currentStroke != Nil && strokeWidth > 0 && strokeHeight > 0)
        {
            CGPoint strokeOrigin = [_magicBrush currentStrokeLocation];
            [self.strokeView removeFromSuperview];
            self.strokeView = [[UIImageView alloc] initWithFrame: CGRectMake(strokeOrigin.x, strokeOrigin.y,
                                                                             currentStroke.size.width, currentStroke.size.height)];
            [self.strokeView setImage:currentStroke];
            [self addSubview:self.strokeView];
        }
        else
            [self.strokeView removeFromSuperview];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView: self];
    [_magicBrush beginStroke:location];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView: self];
    [_magicBrush moveStroke:location];
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView: self];
    [_magicBrush endStroke:location];
    [self setNeedsDisplay];
}

@end
