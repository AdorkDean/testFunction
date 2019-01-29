//
//  GestureScrollView.m
//  qmp_ios
//
//  Created by QMP on 2017/9/14.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "GestureScrollView.h"

@implementation GestureScrollView


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event     {
    //大于 50 是为了行研报告的searchBar点击
    if (((int)point.x % (int)SCREENW) < 20 && point.y > 50) {  //滑动点靠近屏幕40以内  不响应scrollView的滑动手势
        return nil;
    } else {
        return [super hitTest:point withEvent:event];
    }
}

@end
