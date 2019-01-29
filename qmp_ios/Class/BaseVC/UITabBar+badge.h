//
//  UITabBar+badge.h
//  qmp_ios
//
//  Created by QMP on 2017/12/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (badge)

- (void)showBadgeOnItemIndex:(int)index;   //显示小红点
- (void)showBadgeOnItemIndex:(int)index value:(NSInteger)value;

- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点

@end
