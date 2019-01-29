//
//  HomeNavigationBar.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/6/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,BarStyle) {
    BarStyle_White = 1,
    BarStyle_Blue,
    BarStyle_Clear
};

@interface HomeNavigationBar : UIView
@property (copy, nonatomic) void(^addBtnClickEvent)();
@property(nonatomic,strong)UIButton *searchBtn; //用于隐藏
@property(nonatomic,assign)BarStyle barStyle;
@property(nonatomic,assign)NSInteger tabbarIndex;

+ (HomeNavigationBar*)navigationBarWithBarStyle:(BarStyle)barStyle;
+ (HomeNavigationBar*)navigationBarWithBarStyle:(BarStyle)barStyle showAdd:(BOOL)showAdd;

- (void)refreshMsdCount;

@end
