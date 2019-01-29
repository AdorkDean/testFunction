//
//  QMPCreateMoreView.h
//  qmp_ios
//
//  Created by QMP on 2018/8/29.
//  Copyright © 2018年 Molly. All rights reserved.
//  创建项目、发布融资、披露融资入口

#import <UIKit/UIKit.h>

@interface QMPCreateMoreView : UIView
- (void)show;
- (void)hide;

@property (nonatomic, copy) void(^createMoreViewItemClick)(NSString *title);
@end
