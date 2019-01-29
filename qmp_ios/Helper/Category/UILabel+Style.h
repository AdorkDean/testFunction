//
//  UILabel+Style.h
//  qmp_ios
//
//  Created by QMP on 2017/8/22.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Style)

- (void)labelWithFontSize:(CGFloat)fontSize textColor:(UIColor*)textColor;

- (void)labelWithFontSize:(CGFloat)fontSize fontName:(NSString*)fontName textColor:(UIColor *)textColor;
- (void)labelWithFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor cornerRadius:(CGFloat)cornerRadius;

- (void)labelWithFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor cornerRadius:(CGFloat)cornerRadius borderWdith:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

- (void)labelWithFontSize:(CGFloat)fontSize  fontName:(NSString*)fontName textColor:(UIColor *)textColor cornerRadius:(CGFloat)cornerRadius borderWdith:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

@end
