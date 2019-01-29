//
//  UserActionStatistics.h
//  qmp_ios
//
//  Created by QMP on 2018/8/24.
//  Copyright © 2018年 Molly. All rights reserved.
//用户行为统计

#import <Foundation/Foundation.h>

@interface UserActionStatistics : NSObject

+ (instancetype)shared;

/** 在线30分钟 */
- (void)startForegroundTimer;
- (void)endForegroundTimer;

/** 每日登陆 */
- (void)loginEventEveryday;

@end
