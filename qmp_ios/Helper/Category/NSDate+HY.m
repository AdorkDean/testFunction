//
//  NSDate+HY.m
//  deepnet
//
//  Created by sleen on 2017/2/7.
//  Copyright © 2017年 fireplain. All rights reserved.
//

#import "NSDate+HY.h"

@implementation NSDate (HY)
- (NSInteger)hy_year {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}

- (NSInteger)hy_month {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
}

- (NSInteger)hy_day {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day];
}
- (BOOL)hy_isToday {
    if (fabs(self.timeIntervalSinceNow) >= 60 * 60 * 24) return NO;
    return [NSDate new].hy_day == self.hy_day;
}

- (BOOL)hy_isYesterday {
    NSDate *added = [self _dateByAddingDays:1];
    return [added hy_isToday];
}
- (NSDate *)_dateByAddingDays:(NSInteger)days {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 86400 * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSString *)formatDate:(NSString *)dateStr {
    if (!dateStr || dateStr.length < 19) {
        return @"";
    }
    dateStr = [dateStr substringToIndex:18];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss"; //.S
    
    NSDate *date = [formatter dateFromString:dateStr];
    
    if (!date) return @"";
    
    static NSDateFormatter *formatterYesterday;
    static NSDateFormatter *formatterSameYear;
    static NSDateFormatter *formatterFullDate;
    static NSDateFormatter *formatterToday;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatterToday = [[NSDateFormatter alloc] init];
        [formatterToday setDateFormat:@"HH:mm"];
        [formatterToday setLocale:[NSLocale currentLocale]];
        
        formatterYesterday = [[NSDateFormatter alloc] init];
        [formatterYesterday setDateFormat:@"昨天 HH:mm"];
        [formatterYesterday setLocale:[NSLocale currentLocale]];
        
        formatterSameYear = [[NSDateFormatter alloc] init];
        [formatterSameYear setDateFormat:@"M月d日"];
        [formatterSameYear setLocale:[NSLocale currentLocale]];
        
        formatterFullDate = [[NSDateFormatter alloc] init];
        [formatterFullDate setDateFormat:@"yy年M月dd日"];
        [formatterFullDate setLocale:[NSLocale currentLocale]];
    });
    
    NSDate *now = [NSDate new];
    NSTimeInterval delta = now.timeIntervalSince1970 - date.timeIntervalSince1970;
    if (delta < -60 * 10) { // 本地时间有问题
        return [formatterFullDate stringFromDate:date];
    } else if (delta < 60 * 10) { // 10分钟内
        return @"刚刚";
    } else if (delta < 60 * 60) { // 1小时内
        return [NSString stringWithFormat:@"%d分钟前", (int)(delta / 60.0)];
    } else if (delta < 60 * 60 * 6) { // 6小时内
        return [NSString stringWithFormat:@"%d小时前", (int)(delta / 60.0 / 60.0)];
    } else if (date.hy_isToday) {
        return [formatterToday stringFromDate:date];
    }else if (date.hy_isYesterday) {
        return [formatterYesterday stringFromDate:date];
    } else if (date.hy_year == now.hy_year) {
        return [formatterSameYear stringFromDate:date];
    } else {
        return [formatterFullDate stringFromDate:date];
    }
}
+ (NSString *)dayOfWeekWithDate:(NSString *)dateStr {
    if (!dateStr || dateStr.length < 19) {
        return @"";
    }
    dateStr = [dateStr substringToIndex:18];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss"; //.S
    
    NSDate *date = [formatter dateFromString:dateStr];
    
    if (!date) return @"";
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitWeekday;

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    comps = [calendar components:unitFlags fromDate:date];
    
    NSInteger day = [comps weekday];
    NSDictionary *dd = @{@"2":@"星期一",@"3":@"星期二",@"4":@"星期三",@"5":@"星期四",@"6":@"星期五",@"7":@"星期六",@"1":@"星期日"};
    NSString *s = [NSString stringWithFormat:@"%zd", day];
    
    return dd[s];
}
@end
