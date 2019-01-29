//
//  NSDate+HY.h
//  deepnet
//
//  Created by sleen on 2017/2/7.
//  Copyright © 2017年 fireplain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (HY)
@property (nonatomic, readonly) NSInteger hy_year;
@property (nonatomic, readonly) NSInteger hy_month;
@property (nonatomic, readonly) NSInteger hy_day;
@property (nonatomic, readonly) BOOL hy_isToday;
@property (nonatomic, readonly) BOOL hy_isYesterday;

+ (NSString *)formatDate:(NSString *)dateStr;
+ (NSString *)dayOfWeekWithDate:(NSString *)dateStr;
@end
