//
//  LayerTableViewCell.m
//  PSD Extraction
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "LayerTableViewCell.h"

@interface LayerTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *layerInformationLabel;

@end

@implementation LayerTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.layerInformationLabel.numberOfLines = 10;
    
    self.separatorInset = UIEdgeInsetsZero;
    
    // layoutMargins doesn't exist on iOS 7 so check before calling it.
    if ([self respondsToSelector:@selector(setLayoutMargins:)])
    {
        self.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)prepareForReuse
{
    self.thumbnailImageView.image = nil;
    self.layerInformationLabel.text = nil;
}

#pragma mark - Properties

- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    self.thumbnailImageView.image = thumbnailImage;
}

- (void)setLayerInformation:(NSString *)layerInformation
{
    self.layerInformationLabel.text = layerInformation;
}

@end
