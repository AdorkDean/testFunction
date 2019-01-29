//
//  QMPActivityActionView.h
//  qmp_ios
//
//  Created by QMP on 2018/8/25.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ActivityModel;
@interface QMPActivityActionView : UIView
- (instancetype)initWithActivity:(ActivityModel *)activity;
- (void)show;
- (void)hide;


@property (nonatomic, copy) void (^activityActionItemTap)(NSString *item);
@end
