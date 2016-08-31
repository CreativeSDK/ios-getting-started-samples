/*
 * Copyright (c) 2016 Adobe Systems Incorporated. All rights reserved.
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
 */

import UIKit

class TextContainerView: UITextView
{
    var fontSize: CGFloat!
    var defaultFont: UIFont!
    
    /// UIFont does not have a property for the style name, so this getter extracts the style name
    /// from
    var fontStyleName: String!
    {
        get
        {
            var fontStyleName = "Unknown"
            
            var fontNameComponents: Array = (self.font!.fontName.componentsSeparatedByString("-"))
            
            if fontNameComponents.count > 1
            {
                fontStyleName = fontNameComponents.popLast()!
            }
            else
            {
                fontStyleName = "Regular"
            }
            
           return fontStyleName
        }
    }
    
    private var typekitFontBackingVar: AdobeTypekitFont!
    
    /// Applies the Typekit font if one is specified and the specified font is available. If the
    /// specified is not available, the `defaultFont` value is used instead.
    var typekitFont: AdobeTypekitFont!
    {
        set
        {
            typekitFontBackingVar = newValue
            
            var font: UIFont!
            
            if newValue != nil
            {
                font = newValue.uiFontWithSize(self.fontSize, withDescriptorAttributes: nil)
            }
            
            if font != nil
            {
                self.font = font
            }
            else
            {
                // Fall back to the default font
                self.font = self.defaultFont
            }
        }
        get
        {
            return typekitFontBackingVar
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Initialize the fonts
        self.fontSize = 14
        self.defaultFont = UIFont.systemFontOfSize(self.fontSize)
        self.typekitFont = nil
    }
    
    func resetTypeKitFont()
    {
        // Reset the Typekit font
        let typekitFont: AdobeTypekitFont! = self.typekitFont
        self.typekitFont = typekitFont
    }
}
