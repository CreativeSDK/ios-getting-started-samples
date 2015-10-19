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
//  CurveView.m
//  Magic Curver
//


#import "CurveView.h"

#define CONTROL_POINT_SIZE      24
#define CURVE_LINE_WIDTH        5

@implementation CurveView {
    AdobeLabsMagicCurve * _magicCurve;
    NSUInteger _currentControlPointIndex;
}

- (void)setMagicCurve: (AdobeLabsMagicCurve *)magicCurve
{
    // make a copy of the magic curve passed in and mark self for display
    _magicCurve = [[AdobeLabsMagicCurve alloc] initWithMagicCurve: magicCurve];
    _currentControlPointIndex = AdobeLabsMagicCurveNullIndex;
    [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect {
    
    // 1.  fill the background of the view with white
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    // 2.  generate the UIBezierPath from the Magic Curve
    UIBezierPath * path = [_magicCurve generateUIBezierPath];
    
    if (nil == path) return;

    // 3.  if the MagicCurve is a closed curve, fill the path
    if (_magicCurve.isClosed)
    {
        [[UIColor redColor] setFill];
        [path fill];
    }
    
    // 4. draw the stroke
    [[UIColor blackColor] setStroke];
    path.lineWidth = CURVE_LINE_WIDTH;
    [path stroke];
    
    // 5. draw the control points
    NSUInteger numControlPoints = _magicCurve.numControlPoints;
    for (NSUInteger i = 0; i < numControlPoints; i++)
    {
        CGPoint controlPoint = [_magicCurve controlPointAt: i];
        CGContextSetFillColorWithColor(context, [_magicCurve isCorner: i] ? [UIColor purpleColor].CGColor : [UIColor blueColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(controlPoint.x - CONTROL_POINT_SIZE/2,
                                                       controlPoint.y - CONTROL_POINT_SIZE/2,
                                                       CONTROL_POINT_SIZE,
                                                       CONTROL_POINT_SIZE));
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView: self];
    CGFloat radius = MAX(CONTROL_POINT_SIZE, touch.majorRadius);
    NSUInteger index = 0;
    
    _currentControlPointIndex = AdobeLabsMagicCurveNullIndex;
    
    BOOL bFoundControlPoint = [_magicCurve findClosestControlPoint: location withRadius: radius andControlPointIndexToSet: &index];
    
    if (self.changeControlPoint)
    {
        if (bFoundControlPoint)
        {
            [_magicCurve toggleCorner: index];
            [self setNeedsDisplay];
        }
        return;
    }
    
    if (self.deleteControlPoint)
    {
        if (bFoundControlPoint)
        {
            [_magicCurve removeControlPoint: index];
            [self setNeedsDisplay];
        }
        return;
    }
    
    // not changing or deleting a control point, see if we found one to select
    if (bFoundControlPoint)
    {
        _currentControlPointIndex = index;
        [_magicCurve setControlPoint: _currentControlPointIndex withPosition: location];
        [self setNeedsDisplay];
        return;
    }
    
    // if a control point wasn't found for selection, try to insert a new control point
    if ([_magicCurve insertControlPoint: location withRadius: radius andControlPointIndexToSet: &index])
    {
        _currentControlPointIndex = index;
        [self setNeedsDisplay];
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_currentControlPointIndex != AdobeLabsMagicCurveNullIndex)
    {
        [_magicCurve setControlPoint: _currentControlPointIndex withPosition: [[touches anyObject] locationInView: self]];
        [self setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_currentControlPointIndex != AdobeLabsMagicCurveNullIndex)
    {
        [_magicCurve setControlPoint: _currentControlPointIndex withPosition: [[touches anyObject] locationInView: self]];
        _currentControlPointIndex = AdobeLabsMagicCurveNullIndex;
        [self setNeedsDisplay];
    }
}

@end
