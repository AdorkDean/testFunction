//
//  UIButton+Extension.h
//  qmp_ios
//
//  Created by QMP on 2017/9/8.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MKButtonEdgeInsetsStyle) {
    MKButtonEdgeInsetsStyleTop, // image在上，label在下
    MKButtonEdgeInsetsStyleLeft, // image在左，label在右
    MKButtonEdgeInsetsStyleBottom, // image在下，label在上
    MKButtonEdgeInsetsStyleRight // image在右，label在左
};


@interface UIButton (Extension)

- (void)buttonWithTitle:(NSString*)title image:(NSString*)imageName;
- (void)buttonWithTitle:(NSString*)title image:(NSString*)imageName titleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize;
- (void)buttonWithTitleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize;

@end


@interface UIButton (ImageTitleStyle)

/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
- (void)layoutButtonWithEdgeInsetsStyle:(MKButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space;

@end

