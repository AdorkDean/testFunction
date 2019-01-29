//
//  FMIEvent.m
//  FengMi
//
//  Created by huhuan on 15/4/21.
//  Copyright (c) 2015年 FengMi. All rights reserved.
//

#import "QMPEvent.h"
#import "FMIEventDefination.h"
#import <UMMobClick/MobClick.h>

@interface QMPEvent ()

@property (nonatomic, assign) FMIEventTarget eventTarget;

@end

static QMPEvent *__event = nil;

@implementation QMPEvent

+ (void)startWithEventCondition:(FMIEventTarget)condition {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *version = AppVersionShort;
        [MobClick setAppVersion:version];
        
        __event = [[QMPEvent alloc] init];
        if(condition & FMIEventTargetServer) {
            [__event configureBaseEventWithTimeInterval:5];
        }else {
            [__event disableServerEvent];
        }
        __event.eventTarget = condition;
        
    });

}

+ (QMPEvent *)eventInstance {
    if(!__event) {
        [QMPEvent startWithEventCondition:FMIEventTargetUmeng];
    }
    return __event;
}

+ (void)event:(NSString *)eventId {
    [QMPEvent event:eventId attributes:nil];
}

+ (void)beginEvent:(NSString *)eventId {
    [QMPEvent beginEvent:eventId attributes:nil];
}

+ (void)endEvent:(NSString *)eventId {
    [QMPEvent endEvent:eventId attributes:nil];
}

+ (void)event:(NSString *)eventId label:(NSString *)label {
    [[QMPEvent eventInstance] handleEventWithType:FMIEventTypeCount
                                          eventId:eventId
                                            label:label];
}


+ (void)beginLogPageView:(NSString*)pageName{
    [MobClick beginLogPageView:pageName];
}

+ (void)endLogPageView:(NSString *)pageName{

    [MobClick endLogPageView:pageName];
}

+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes {
    
    [[QMPEvent eventInstance] handleEventWithType:FMIEventTypeCount
                                          eventId:eventId
                                       attributes:attributes];
}

+ (void)beginEvent:(NSString *)eventId attributes:(NSDictionary *)attributes {
    [[QMPEvent eventInstance] handleEventWithType:FMIEventTypeBegin
                                          eventId:eventId
                                       attributes:attributes];
}

+ (void)endEvent:(NSString *)eventId attributes:(NSDictionary *)attributes {
    [[QMPEvent eventInstance] handleEventWithType:FMIEventTypeEnd
                                          eventId:eventId
                                       attributes:attributes];
}

- (void)handleEventWithType:(FMIEventType)eventType
                    eventId:(NSString *)eventId
                 attributes:(NSDictionary *)attributes {
    if(([QMPEvent eventInstance].eventTarget & FMIEventTargetUmeng)) {
        switch (eventType) {
            case FMIEventTypeCount:
            {
                if(attributes) {
                    [MobClick event:eventId attributes:attributes];
                }else {
                    [MobClick event:eventId];
                }
                
            }
                break;
            case FMIEventTypeBegin:
                [MobClick beginEvent:eventId];
                break;
            case FMIEventTypeEnd:
                [MobClick endEvent:eventId];
                break;
                
            default:
                break;
        }
    }
    
    if(([QMPEvent eventInstance].eventTarget & FMIEventTargetServer)) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            switch (eventType) {
                case FMIEventTypeCount:
                    [self storeEvent:eventId
                          attributes:attributes];
                    break;
                case FMIEventTypeBegin:
                    [self handleBeginEvent:eventId attributes:attributes];
                    break;
                case FMIEventTypeEnd:
                    [self handleEndEvent:eventId attributes:attributes];
                    break;
                    
                default:
                    break;
            }
        });
        
    }
}

- (void)handleEventWithType:(FMIEventType)eventType
                    eventId:(NSString *)eventId
                      label:(NSString *)label {
    if(([QMPEvent eventInstance].eventTarget & FMIEventTargetUmeng)) {
        switch (eventType) {
            case FMIEventTypeCount:
            {
                if(label) {
                    [MobClick event:eventId label:label];
                }else {
                    [MobClick event:eventId];
                }
                
            }
                break;
            case FMIEventTypeBegin:
                [MobClick beginEvent:eventId];
                break;
            case FMIEventTypeEnd:
                [MobClick endEvent:eventId];
                break;
                
            default:
                break;
        }
    }
    
    if(([QMPEvent eventInstance].eventTarget & FMIEventTargetServer)) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        });
    }
}

@end
