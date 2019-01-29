//
//  FMIEventKit.h
//  FengMi
//
//  Created by qfpay on 15/4/22.
//  Copyright (c) 2015年 FengMi. All rights reserved.
//统计

#import <Foundation/Foundation.h>

/**
 *  事件类型
 *
 */
typedef NS_ENUM(NSUInteger, FMIEventType){
    FMIEventTypeCount = 0,  //计数事件
    FMIEventTypeBegin,      //开始事件
    FMIEventTypeEnd,        //结束事件
};

@interface QMPBaseEvent : NSObject

- (void)configureBaseEventWithTimeInterval:(NSTimeInterval)interval;
- (void)disableServerEvent;
- (void)storeEvent:(NSString *)eventId attributes:(NSDictionary *)attributes;
- (void)handleBeginEvent:(NSString *)eventId attributes:(NSDictionary *)attributes;
- (void)handleEndEvent:(NSString *)eventId attributes:(NSDictionary *)attributes;

@end
