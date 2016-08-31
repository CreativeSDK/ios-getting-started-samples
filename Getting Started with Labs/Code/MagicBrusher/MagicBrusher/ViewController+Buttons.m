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
//  ViewController+Buttons.m
//  Magic Brusher
//

#import "ViewController.h"
#import "ViewController+Buttons.h"
#import "BrushView.h"
#import <AdobeCreativeSDKLabs/AdobeLabsMagicBrush.h>
#import <AdobeCreativeSDKCore/AdobeUXAuthManager.h>

#define BUTTON_TITLE_CLEAR_CANVAS       @"Clear Canvas"

@implementation ViewController (Buttons)
NSArray* _display_type_titles;

- (void)addUI {
    
    // calculate UI element placement
    int numItems = 5;
    CGRect buttonRect       = CGRectMake(BUTTON_X_MARGIN, BUTTON_Y_MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGRect sliderRect       = CGRectMake(BUTTON_X_MARGIN, BUTTON_Y_MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGRect labelRect        = CGRectMake(BUTTON_X_MARGIN, BUTTON_Y_MARGIN, LABEL_WIDTH, BUTTON_HEIGHT);
    CGRect pickerViewRect   = CGRectMake(BUTTON_X_MARGIN, BUTTON_Y_MARGIN, BUTTON_WIDTH, (BUTTON_HEIGHT+BUTTON_Y_OFFSET)*3);
    CGFloat viewWidth       = self.view.bounds.size.width;
    CGFloat leftoverWidth   = viewWidth - (BUTTON_X_MARGIN * 2 + BUTTON_WIDTH*numItems);
    CGFloat interSpacing    = (leftoverWidth / numItems) + BUTTON_WIDTH;
    
    // add the "Clear Canvas" button
    self.clearCanvasButton = [self addButton: BUTTON_TITLE_CLEAR_CANVAS withAction: @selector(clearCanvas) withRect: buttonRect];
    self.clearCanvasButton.backgroundColor = [UIColor clearColor];
    
    // add the "thickness" slider
    sliderRect.origin.x += interSpacing;
    self.brushThicknessSlider = [self addSliderWithAction:@selector(updateBrushThickness) withRect:(sliderRect)];
    self.brushThicknessSlider.minimumValue  = 6.0f;
    self.brushThicknessSlider.maximumValue  = 50.0f;
    self.brushThicknessSlider.value         = 28.0f;
    labelRect.origin.x = sliderRect.origin.x - LABEL_WIDTH - LABEL_MARGIN;
    [self addLabelWithText:@"thickness: " WithRect:labelRect];
    
    // add the "red" slider
    sliderRect.origin.x += interSpacing;
    self.brushRedSlider = [self addSliderWithAction:@selector(updateBrushColor) withRect:(sliderRect)];
    self.brushRedSlider.minimumValue        = 0.0f;
    self.brushRedSlider.maximumValue        = 1.0f;
    self.brushRedSlider.value               = 0.5f;
    labelRect.origin.x = sliderRect.origin.x - LABEL_WIDTH - LABEL_MARGIN;
    labelRect.origin.y = sliderRect.origin.y;
    [self addLabelWithText:@"red: " WithRect:labelRect];
    
    // add the "green" slider
    sliderRect.origin.y += BUTTON_HEIGHT;
    self.brushGreenSlider = [self addSliderWithAction:@selector(updateBrushColor) withRect:(sliderRect)];
    self.brushGreenSlider.minimumValue      = 0.0f;
    self.brushGreenSlider.maximumValue      = 1.0f;
    self.brushGreenSlider.value             = 0.5f;
    labelRect.origin.x = sliderRect.origin.x - LABEL_WIDTH - LABEL_MARGIN;
    labelRect.origin.y = sliderRect.origin.y;
    [self addLabelWithText:@"green: " WithRect:labelRect];
    
    // add the "blue" slider
    sliderRect.origin.y += BUTTON_HEIGHT;
    self.brushBlueSlider = [self addSliderWithAction:@selector(updateBrushColor) withRect:(sliderRect)];
    self.brushBlueSlider.minimumValue       = 0.0f;
    self.brushBlueSlider.maximumValue       = 1.0f;
    self.brushBlueSlider.value              = 0.5f;
    labelRect.origin.x = sliderRect.origin.x - LABEL_WIDTH - LABEL_MARGIN;
    labelRect.origin.y = sliderRect.origin.y;
    [self addLabelWithText:@"blue: " WithRect:labelRect];
    
    // add the picker view to select different natural medium
    pickerViewRect.origin.x = sliderRect.origin.x + interSpacing;
    self.brushTypePickerView = [self addPickerViewWithRect:pickerViewRect];
    self.brushTypePickerView.tag = 0;
    
    
    // add the picker view to select two different display types
    _display_type_titles = @[@"current canvas",
                             @"current stroke"];
    pickerViewRect.origin.x += interSpacing;
    self.displayTypePickerView = [self addPickerViewWithRect:pickerViewRect];
    self.displayTypePickerView.tag = 1;
}

- (UIButton *)addButton: (NSString *)title withAction: (SEL)action withRect: (CGRect)rect {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: title forState: UIControlStateNormal];
    [button setFrame: rect];
    [button addTarget:self action: action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: button];
    button.hidden = NO;
    return button;
}

- (UISlider *)addSliderWithAction: (SEL)action withRect: (CGRect) rect {
    UISlider * slider = [[UISlider alloc] initWithFrame:rect];
    [slider addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [slider setBackgroundColor:[UIColor clearColor]];
    slider.continuous = YES;
    slider.hidden = NO;
    [self.view addSubview:slider];
    return slider;
}

- (void)addLabelWithText: (NSString *)theText WithRect: (CGRect) rect{
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    
    [label setTextColor:[UIColor blackColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:theText];
    [label setFont:[UIFont systemFontOfSize: 14.0f]];
    [label setTextAlignment: NSTextAlignmentRight];
    [self.view addSubview:label];
}

- (UIPickerView *)addPickerViewWithRect: (CGRect) rect{
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:rect];
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    [self.view addSubview:pickerView];
    return pickerView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    if ([self brushView]){
        if (pickerView.tag == 0)
            [[self brushView] setBrushType:(AdobeLabsMagicBrushType)row];
        else
            [[self brushView] setDisplayType:(AdobeLabsMagicBrushDisplayType)row];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([self brushView]){
        if (pickerView.tag == 0)
            return [[self brushView] numBrushTypes];
        else
            return [_display_type_titles count];
    }
    else
        return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:13];
    if ([self brushView]){
        if (pickerView.tag == 0)
            label.text = [[self brushView] brushTypeName:row];
        else
            label.text = [_display_type_titles objectAtIndex:row];
    }
    else
        label.text = @"";
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 150;
}

- (void)clearCanvas {
    if (!self.brushView) return;
    [self.brushView clearCanvas];
}

- (void)updateBrushThickness {
    if (!self.brushView) return;
    [self.brushView setBrushThickness:self.brushThicknessSlider.value];
}

- (void)updateBrushColor {
    if (!self.brushView) return;
    UIColor * color = [UIColor colorWithRed:self.brushRedSlider.value
                                      green:self.brushGreenSlider.value
                                       blue:self.brushBlueSlider.value
                                      alpha:0.5];
    [self.brushView setBrushColor:color];
}

@end
