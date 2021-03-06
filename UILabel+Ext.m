//
//  UILabel+Ext.m
//  Mobo-iOS-ObjectiveC
//
//  Created by hoann on 11/18/14.
//  Copyright (c) 2014 Nam Truong. All rights reserved.
//

#import "UILabel+Ext.h"
#import "NSString+Ext.h"

@implementation UILabel (Ext)

- (CGFloat)heightStringWithEmojis:(NSString*)str fontType:(UIFont *)uiFont ForWidth:(CGFloat)width {
    // Get text
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (CFStringRef) str );
    CFIndex stringLength = CFStringGetLength((CFStringRef) attrString);
    
    // Change font
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef) uiFont.fontName, uiFont.pointSize, NULL);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, stringLength), kCTFontAttributeName, ctFont);
    
    // Calc the size
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    CFRange fitRange;
    CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(width, CGFLOAT_MAX), &fitRange);
    
    CFRelease(ctFont);
    CFRelease(framesetter);
    CFRelease(attrString);
    
    return frameSize.height + 10;
}

-(void)makeSizeToFixWordWrap:(CGFloat)height{
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;
    self.frame = CGRectMake(0, 0, height, 0);
    [self sizeToFit];
}

-(CGRect)rectForText:(NSString*)text{
    self.lineBreakMode = NSLineBreakByWordWrapping;
    NSRange range = [[self text]rangeOfString:text];
    if (range.location == NSNotFound) {
        return CGRectZero;
    }
    NSString* str = [[self text]substringToIndex:(range.location+ range.length)];
    NSString* str1 = [[self text]substringToIndex:range.location-1];
    NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    titleParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGRect rect = [str boundingRectWithSize:CGSizeMake(self.frame.size.width, 99999.0)
                                                   options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                                attributes:@{
                                                             NSFontAttributeName: self.font,
                                                             NSParagraphStyleAttributeName: titleParagraphStyle
                                                             }
                                                   context:nil];
    CGRect rectNoText = [str1 boundingRectWithSize:CGSizeMake(self.frame.size.width, 99999.0)
                                    options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                 attributes:@{
                                              NSFontAttributeName: self.font,
                                              NSParagraphStyleAttributeName: titleParagraphStyle
                                              }
                                    context:nil];
    
    
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(self.frame.size.width, 99999.0)
                                    options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                 attributes:@{
                                              NSFontAttributeName: self.font,
                                              NSParagraphStyleAttributeName: titleParagraphStyle
                                              }
                                    context:nil];
    if (round(rect.size.height) == round(rectNoText.size.height)) {
        textRect.origin.x = rect.size.width - textRect.size.width;//at first line
        textRect.origin.y = round(rect.size.height) - textRect.size.height;
        if (round(rect.size.height) > ceil(self.font.lineHeight) && round(rectNoText.size.height) > ceil(self.font.lineHeight)) {
            //find character at begin of lastLine
            CGRect tempRect = CGRectZero;
            NSInteger index = range.location;
            do {
                --index;
                NSString* firstLineString = [[self text]substringToIndex:index];
                tempRect = [firstLineString boundingRectWithSize:CGSizeMake(self.frame.size.width, 99999.0)
                                          options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                       attributes:@{
                                                    NSFontAttributeName: self.font,
                                                    NSParagraphStyleAttributeName: titleParagraphStyle
                                                    }
                                          context:nil];
            } while (ceil(tempRect.size.height) >= self.bounds.size.height);
            NSString* lastLineString = [self.text substringFromIndex:index];
            NSRange lastLineTextRange = [lastLineString rangeOfString:text];
            
            CGRect lastLineBeginAtText = [[lastLineString substringToIndex:lastLineTextRange.location] boundingRectWithSize:CGSizeMake(self.frame.size.width, 99999.0)
                                                                                                                      options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                                                                                                   attributes:@{
                                                                                                                                NSFontAttributeName: self.font,
                                                                                                                                NSParagraphStyleAttributeName: titleParagraphStyle
                                                                                                                                }
                                                                                                                      context:nil];
            textRect.origin.x = lastLineBeginAtText.size.width;
        }
    }else{
        textRect.origin.y = round(rectNoText.size.height);
        textRect.origin.x = 0;
    }
    if (textRect.origin.y < 0) {
        textRect.origin.y = 0;
    }
    return textRect;
}
@end
