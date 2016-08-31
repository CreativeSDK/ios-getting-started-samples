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
//  PathView.m
//  MagicPather
//

#import "PathView.h"

@implementation PathView
{
    NSMutableArray *_magicPaths;
    AdobeLabsMagicPath *_currentMagicPath;
    int _currentMagicPathIndex;
}

- (void) drawRect:(CGRect)rect
{
    // 1. fill the background of the view with white
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    for (int s = 0; s < [_magicPaths count]; s++)
    {
        AdobeLabsMagicPath *_tempMagicPath = [_magicPaths objectAtIndex:s];
        // 2. draw each magic stroke
        CGPoint lastPoint;
        if ([_tempMagicPath numMagicPathPoints] > 1)
        {
            lastPoint = [_tempMagicPath magicPathPointAt:0];
            for (int i = 1; i < [_tempMagicPath numMagicPathPoints]; i++)
            {
                CGPoint currentPoint = [_tempMagicPath magicPathPointAt:i];
                CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
                CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
                CGContextSetLineCap(context, kCGLineCapRound);
                CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 3.0);
                if (s == _currentMagicPathIndex)
                {
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),
                                               0.1 + 0.8 * (double)i / (double)[_tempMagicPath numMagicPathPoints],
                                               0.95,
                                               0.1 + 0.8 * (double)i / (double)[_tempMagicPath numMagicPathPoints],
                                               1.0);
                }
                else
                {
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),
                                               0.2 + 0.6 * (double)i / (double)[_tempMagicPath numMagicPathPoints],
                                               0.2 + 0.6 * (double)i / (double)[_tempMagicPath numMagicPathPoints],
                                               1.0,
                                               1.0);
                }
                
                CGContextSetBlendMode(context,kCGBlendModeNormal);
                CGContextStrokePath(context);
                lastPoint = currentPoint;
            }
        }
        
        // 3. draw the modifier stroke
        if ([_tempMagicPath numCurrentPathPoints] > 1)
        {
            lastPoint = [_tempMagicPath currentPathPointAt:0];
            for (int i = 1; i < [_tempMagicPath numCurrentPathPoints]; i++)
            {
                CGPoint currentPoint = [_tempMagicPath currentPathPointAt:i];
                CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
                CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
                CGContextSetLineCap(context, kCGLineCapRound);
                CGContextSetLineWidth(context, 5.0);
                CGContextSetRGBStrokeColor(context, 0.8, 0.4, 0.4, 1.0);
                CGContextSetBlendMode(context,kCGBlendModeNormal);
                CGContextStrokePath(context);
                lastPoint = currentPoint;
            }
        }
    }
}

- (void) undo {
    if ([_currentMagicPath undoLastPath])
    {
        [self setNeedsDisplay];
    }
}

- (void) newPath {
    [_magicPaths addObject:[[AdobeLabsMagicPath alloc] init]];
    _currentMagicPath = [_magicPaths objectAtIndex:[_magicPaths count]-1];
    _currentMagicPathIndex = (int)[_magicPaths count]-1;
    [self setNeedsDisplay];
}

- (void) reset {
    _currentMagicPath = nil;
    _magicPaths = nil;
    _currentMagicPathIndex = -1;
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_magicPaths) {
        _magicPaths = [[NSMutableArray alloc] init];
        [_magicPaths addObject:[[AdobeLabsMagicPath alloc] init]];
        _currentMagicPath = [_magicPaths objectAtIndex:0];
        _currentMagicPathIndex = 0;
    }
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    if ([_currentMagicPath beginCurrentPath:currentPoint])
    {
        [self setNeedsDisplay];
    };
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    if ([_currentMagicPath moveCurrentPath:currentPoint])
    {
        [self setNeedsDisplay];
    };
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    if ([_currentMagicPath endCurrentPath:currentPoint])
    {
        [self setNeedsDisplay];
    };
}

@end