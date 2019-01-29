//
//  UIButton+Extension.m
//  qmp_ios
//
//  Created by QMP on 2017/9/8.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "UIButton+Extension.h"

@implementation UIButton (Extension)

- (void)buttonWithTitle:(NSString*)title image:(NSString*)imageName{
    [self setTitle:title forState:UIControlStateNormal];
    if (imageName && imageName.length) {
        [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];

    }
}

- (void)buttonWithTitle:(NSString*)title image:(NSString*)imageName titleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize{
    [self buttonWithTitle:title image:imageName];
    [self setTitleColor:titleColor forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    
}

- (void)buttonWithTitleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize{
    [self setTitleColor:titleColor forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
}
@end


@implementation UIButton (ImageTitleStyle)


- (void)layoutButtonWithEdgeInsetsStyle:(MKButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space
{
    // 1. 得到imageView和titleLabel的宽、高
    CGFloat imageWith = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = self.titleLabel.intrinsicContentSize.width;
        labelHeight = self.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = self.titleLabel.frame.size.width;
        labelHeight = self.titleLabel.frame.size.height;
    }
    
    // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
    switch (style) {
        case MKButtonEdgeInsetsStyleTop:
        {
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space/2.0, 0);
        }
            break;
        case MKButtonEdgeInsetsStyleLeft:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0);
        }
            break;
        case MKButtonEdgeInsetsStyleBottom:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space/2.0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space/2.0, -imageWith, 0, 0);
        }
            break;
        case MKButtonEdgeInsetsStyleRight:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space/2.0, 0, imageWith+space/2.0);
        }
            break;
        default:
            break;
    }
    // 4. 赋值
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}

@end
