//
//  UITabBar+badge.m
//  qmp_ios
//
//  Created by QMP on 2017/12/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "UITabBar+badge.h"

#define TabbarItemNums 4.0    //tabbar的数量



@implementation UITabBar (badge)

-(UITraitCollection *)traitCollection{
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        return [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassCompact];
        
    }
    
    return [super traitCollection];
}

- (void)showBadgeOnItemIndex:(int)index{
    
    
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];
    
    //新建小红点
    UILabel *badgeView = [[UILabel alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 4;
    badgeView.layer.masksToBounds = YES;
    badgeView.backgroundColor = HTColorFromRGB(0xEC525B);
    CGRect tabFrame = self.frame;
    
    //确定小红点的位置
    float percentX = (index + 0.6) / TabbarItemNums;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = 5;
    badgeView.frame = CGRectMake(x, y, 8, 8);
    [self addSubview:badgeView];
    
}


- (void)showBadgeOnItemIndex:(int)index value:(NSInteger)value{
    
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];
    
    //新建小红点
    UILabel *badgeView = [[UILabel alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 8;
    badgeView.layer.masksToBounds = YES;
    badgeView.backgroundColor = HTColorFromRGB(0xEC525B);
    badgeView.font = [UIFont systemFontOfSize:10];
    badgeView.textAlignment = NSTextAlignmentCenter;
    badgeView.textColor = [UIColor whiteColor];
    CGRect tabFrame = self.frame;
    
    
    //确定小红点的位置
    float percentX = (index +0.6) / TabbarItemNums;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = 5;
    badgeView.frame = CGRectMake(x, y, 16, 16);
    [self addSubview:badgeView];
    badgeView.text = [NSString stringWithFormat:@"%ld",value];
    
}

- (void)hideBadgeOnItemIndex:(int)index{
    
    //移除小红点
    [self removeBadgeOnItemIndex:index];
    
}

- (void)removeBadgeOnItemIndex:(int)index{
    
    //按照tag值进行移除
    for (UIView *subView in self.subviews) {
        
        if (subView.tag == 888+index) {
            
            [subView removeFromSuperview];
            
        }
    }
}

@end
