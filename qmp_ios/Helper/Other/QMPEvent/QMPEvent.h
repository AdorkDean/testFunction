//
//  FMIEvent.h
//  FengMi
//
//  Created by huhuan on 15/4/21.
//  Copyright (c) 2015年 FengMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMPBaseEvent.h"
/**
 *  埋点请求服务的目标
 *
 */
typedef NS_OPTIONS(NSUInteger, FMIEventTarget){

    //发送给友盟
    FMIEventTargetUmeng   = 1 << 0,

    //发送给服务器
    FMIEventTargetServer  = 1 << 1,

};

@interface QMPEvent : QMPBaseEvent

/**
 *  初始化FMIEvent
 *
 *  @param FMIEventCondition 发送的目标，默认为FMIEventConditionUmeng.
 */
+ (void)startWithEventCondition:(FMIEventTarget)condition;

/**
 *  事件数量统计
 *
 *  @param eventId 事件Id.
 */
+ (void)event:(NSString *)eventId;

/**
 *  事件时长统计;事件开始
 *
 *  @param eventId 事件Id.
 */
+ (void)beginEvent:(NSString *)eventId;

/**
 *  事件时长统计;事件结束
 *
 *  @param eventId 事件Id.
 */
+ (void)endEvent:(NSString *)eventId;

/**
 *  事件数量统计
 *
 *  @param eventId 事件Id.
 *  @param attributes 额外参数字典.
 */
+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes;

/**
 *  事件时长统计;事件开始
 *
 *  @param eventId 事件Id.
 *  @param attributes 额外参数字典.
 */
+ (void)beginEvent:(NSString *)eventId attributes:(NSDictionary *)attributes;

/**
 *  事件时长统计;事件结束
 *
 *  @param eventId 事件Id.
 *  @param attributes 额外参数字典.
 */
+ (void)endEvent:(NSString *)eventId attributes:(NSDictionary *)attributes;

/**
 *  事件时长统计;事件结束
 *
 *  @param eventId 事件Id.
 *  @param label 额外参数.
 */
+ (void)event:(NSString *)eventId label:(NSString *)label;

/**
 *  页面统计，事件开始
 *
 *  @param paegName 页面名称
 */

+ (void)beginLogPageView:(NSString*)pageName;

/**
 *  页面统计，事件结束
 *
 *  @param pageName 页面名称
 */
+ (void)endLogPageView:(NSString*)pageName;

@end
