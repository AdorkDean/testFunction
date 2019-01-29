//
//  GetNowTime.m
//  Jiu
//
//  Created by Molly on 16/1/5.
//  Copyright © 2016年 NTTDATA. All rights reserved.
//

#import "GetNowTime.h"

@implementation GetNowTime

/**
  获取当前YY-MM-dd HH:mm:ss

 @return
 */
- (NSString*)getDayWithHour{
    NSDate* date = [NSDate date];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"YY-MM-dd HH:mm:ss"];
    
    return [dateFormat stringFromDate:date];
}
/**
 获取当前YY-MM-dd HH:mm:ss
 
 @return
 */
- (NSString*)getCompleteYearDayWithHour{
    NSDate* date = [NSDate date];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"YYYY-M-d HH:mm:ss"];
    
    return [dateFormat stringFromDate:date];
}

+ (NSString*)getCompleteYearDayWithHour{
    NSDate* date = [NSDate date];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"YYYY-M-d HH:mm:ss"];
    
    return [dateFormat stringFromDate:date];
}

/**
 获取当前 YYYY-MM-dd

 @return
 */
- (NSString *)getDayWithoutHour{

    NSDate* date = [NSDate date];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    
    return [dateFormat stringFromDate:date];
}


/**
 获取当前时间戳

 @return
 */
- (NSString *)getRecordTime{

    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    
    return timeString;
}
@end
