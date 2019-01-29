//
//  UserActionStatistics.m
//  qmp_ios
//
//  Created by QMP on 2018/8/24.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "UserActionStatistics.h"

static  NSString *LastLoginTime = @"lastLoginTime";
static  NSString *OnlineTotalTime = @"onlineTotalTime";
static  NSString *OnlineTime = @"onlineTime";
static  NSString *StartTime = @"startTime";
static  NSString *EndTime = @"endTime";

@interface UserActionStatistics()
@property(nonatomic,strong)NSDateFormatter *dateFormat;
@end


@implementation UserActionStatistics

+ (instancetype)shared{
    static UserActionStatistics *userAction = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        userAction = [[UserActionStatistics alloc]init];
    });
    return userAction;
    
}


- (void)startForegroundTimer{
    
    if([PublicTool isNull:[WechatUserInfo shared].uuid]){
        return;
    }

    //已是第二天 或者 23：30以后都清零
    NSString *currentTime = [PublicTool currentDateTime]; //2018-09-10 08:09:32
    NSDate *endDate = [USER_DEFAULTS valueForKey:EndTime];
   
    NSString *endTime = [self.dateFormat stringFromDate:endDate];
    
    //月  日 
    NSString *month = [[[currentTime componentsSeparatedByString:@" "] firstObject] componentsSeparatedByString:@"-"][1];
    NSString *day = [[[currentTime componentsSeparatedByString:@" "] firstObject] componentsSeparatedByString:@"-"][2];
    
    NSString *endmonth = [[[endTime componentsSeparatedByString:@" "] firstObject] componentsSeparatedByString:@"-"][1];
    NSString *endday = [[[endTime componentsSeparatedByString:@" "] firstObject] componentsSeparatedByString:@"-"][2];
    
    //第二天
    if((endmonth.integerValue != month.integerValue) || (endday.integerValue != day.integerValue)){
        [USER_DEFAULTS setValue:nil forKey:OnlineTime];
    }
    
    [USER_DEFAULTS setValue:[NSDate date] forKey:StartTime];
    [USER_DEFAULTS synchronize];

}

- (void)endForegroundTimer{
    
    if([PublicTool isNull:[WechatUserInfo shared].uuid]){
        return;
    }
    
    if (![USER_DEFAULTS valueForKey:StartTime]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSTimeInterval timerInterval = [[NSDate date] timeIntervalSinceDate:[USER_DEFAULTS valueForKey:StartTime]];
        
        NSTimeInterval onlineTime = [[USER_DEFAULTS valueForKey:OnlineTime] floatValue];
        [USER_DEFAULTS setValue:@(onlineTime + timerInterval) forKey:OnlineTime];
        
        NSTimeInterval totalTime = [[USER_DEFAULTS valueForKey:OnlineTotalTime] floatValue];
        [USER_DEFAULTS setValue:@(onlineTime + timerInterval+totalTime) forKey:OnlineTotalTime];
        
        
        NSString *currentTime = [PublicTool currentDateTime]; //2018-09-10 08:09:32
        NSDate *startDate = [USER_DEFAULTS valueForKey:StartTime];
        NSString *startTime = [self.dateFormat stringFromDate:startDate];
        
        //月  日 时  分
        NSString *month = [[[currentTime componentsSeparatedByString:@" "] firstObject] componentsSeparatedByString:@"-"][1];
        NSString *day = [[[currentTime componentsSeparatedByString:@" "] firstObject] componentsSeparatedByString:@"-"][2];
        NSString *hour = [[[currentTime componentsSeparatedByString:@" "] lastObject] componentsSeparatedByString:@":"][0];
        NSString *minutes = [[[currentTime componentsSeparatedByString:@" "] lastObject] componentsSeparatedByString:@":"][1];
        
        
        NSString *startmonth = [[[startTime componentsSeparatedByString:@" "] firstObject] componentsSeparatedByString:@"-"][1];
        NSString *startday = [[[startTime componentsSeparatedByString:@" "] firstObject] componentsSeparatedByString:@"-"][2];
        
        //第二天
        if((startmonth.integerValue != month.integerValue) || (startday.integerValue != day.integerValue)){
            [USER_DEFAULTS setValue:@((hour.integerValue+8)*60*60+minutes.integerValue*60) forKey:OnlineTime];
            [USER_DEFAULTS setValue:@((hour.integerValue+8)*60*60+minutes.integerValue*60) forKey:OnlineTotalTime];
        }
        [USER_DEFAULTS synchronize];
        
        if (([[USER_DEFAULTS valueForKey:OnlineTime] floatValue] >= 30*60) && ([[USER_DEFAULTS valueForKey:OnlineTime] floatValue] <= 300*60)) {
            
            [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"user/online" HTTPBody:@{@"uuid":[WechatUserInfo shared].uuid} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                [USER_DEFAULTS setValue:nil forKey:OnlineTime];
                [USER_DEFAULTS setValue:nil forKey:StartTime];
            }];
        }
        [USER_DEFAULTS setValue:[NSDate date] forKey:EndTime];
        [USER_DEFAULTS synchronize];
    });
}

- (void)loginEventEveryday{
    if ([PublicTool isNull:[WechatUserInfo shared].uuid]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //上次登录日期  //09-01
        NSString *lastTime = [USER_DEFAULTS valueForKey:LastLoginTime];
        NSString *today = [PublicTool currentDay];
        BOOL loginToday = NO;
        if (!lastTime) {
            loginToday = YES;
        }else{
            NSArray *lastTimeArr = [lastTime componentsSeparatedByString:@"-"];
            NSArray *todayTimeArr = [today componentsSeparatedByString:@"-"];
            
            if (([lastTimeArr[0] integerValue] != [todayTimeArr[0] integerValue]) || ([lastTimeArr[1] integerValue] != [todayTimeArr[1] integerValue])) {
                loginToday = YES;
            }
        }
        if (loginToday) { //今日登录
            QMPLog(@"今日首次登录---------");
            [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"user/firstlogin" HTTPBody:@{@"uuid":[WechatUserInfo shared].uuid} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                
            }];
            
            [USER_DEFAULTS setValue:today forKey:LastLoginTime];
            [USER_DEFAULTS synchronize];
        }
    });
    
    
}

- (NSDateFormatter*)dateFormat{
    if (!_dateFormat) {
        _dateFormat = [[NSDateFormatter alloc] init];
        [_dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [_dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormat;
}
@end
