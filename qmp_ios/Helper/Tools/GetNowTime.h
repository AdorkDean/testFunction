//
//  GetNowTime.h
//  Jiu
//
//  Created by Molly on 16/1/5.
//  Copyright © 2016年 NTTDATA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetNowTime : NSObject
@property(nonatomic,strong)NSString* year;
- (NSString*)getDayWithHour;
- (NSString*)getCompleteYearDayWithHour;
+ (NSString*)getCompleteYearDayWithHour;
- (NSString *)getDayWithoutHour;

- (NSString *)getRecordTime;
@end
