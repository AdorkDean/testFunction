//
//  UILabel+Style.m
//  qmp_ios
//
//  Created by QMP on 2017/8/22.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "UILabel+Style.h"
#import <objc/runtime.h>

@implementation UILabel (Style)

- (void)labelWithFontSize:(CGFloat)fontSize textColor:(UIColor*)textColor{
    self.font = [UIFont systemFontOfSize:fontSize];
    self.textColor = textColor;
}
- (void)labelWithFontSize:(CGFloat)fontSize fontName:(NSString*)fontName textColor:(UIColor *)textColor{
    self.font = [UIFont fontWithName:fontName size:fontSize];
    self.textColor = textColor;

}

- (void)labelWithFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor cornerRadius:(CGFloat)cornerRadius{
    
    [self labelWithFontSize:fontSize textColor:textColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
}

- (void)labelWithFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor cornerRadius:(CGFloat)cornerRadius borderWdith:(CGFloat)borderWidth borderColor:(UIColor*)borderColor{
    
    [self labelWithFontSize:fontSize textColor:textColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = borderColor.CGColor;
    
}

- (void)labelWithFontSize:(CGFloat)fontSize  fontName:(NSString*)fontName textColor:(UIColor *)textColor cornerRadius:(CGFloat)cornerRadius borderWdith:(CGFloat)borderWidth borderColor:(UIColor*)borderColor{
    
    [self labelWithFontSize:fontSize fontName:fontName textColor:textColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = borderColor.CGColor;
    
}


@end
