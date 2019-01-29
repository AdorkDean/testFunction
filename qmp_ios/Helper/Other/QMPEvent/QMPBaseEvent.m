//
//  FMIEventKit.m
//  FengMi
//
//  Created by qfpay on 15/4/22.
//  Copyright (c) 2015年 FengMi. All rights reserved.
//

#import "QMPBaseEvent.h"
#import "AFNetworking.h"

@interface QMPBaseEvent ()

@property (nonatomic, strong) NSTimer *eventTimer;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, copy) NSString *timeEventPath;
@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, assign) BOOL isUploading;

@end

@implementation QMPBaseEvent

- (void)configureBaseEventWithTimeInterval:(NSTimeInterval)interval {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    self.filePath = [path stringByAppendingPathComponent:@"event.plist"];
    self.timeEventPath = [path stringByAppendingPathComponent:@"timeEvent.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:nil attributes:nil];
    }
    self.timeInterval = interval;
    if([self.eventTimer isValid]) {
        [self.eventTimer invalidate];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.eventTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.eventTimer forMode:NSRunLoopCommonModes];
    });
}

- (void)disableServerEvent {
    if([self.eventTimer isValid]) {
        [self.eventTimer invalidate];
    }
    [self clearEventFile];
}

- (void)storeEvent:(NSString *)eventId attributes:(NSDictionary *)attributes {
    
    NSMutableArray *fileArray = [NSMutableArray arrayWithContentsOfFile:self.filePath];
    if(!fileArray) {
        fileArray = [NSMutableArray array];
    }
    NSMutableDictionary *eventDic = [NSMutableDictionary new];
    eventDic[@"eventId"] = eventId;
    if(attributes) {
        eventDic[@"attributes"] = attributes;
    }
    [fileArray addObject:eventDic];
    [fileArray writeToFile:self.filePath atomically:NO];
}

- (void)handleBeginEvent:(NSString *)eventId attributes:(NSDictionary *)attributes {
    NSMutableDictionary *fileDic = [NSMutableDictionary dictionary];
    if (self.timeEventPath) {
       fileDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.timeEventPath];
    }
    
    if(!fileDic) {
        fileDic = [NSMutableDictionary dictionary];
    }
    NSString *nowTime = [NSString stringWithFormat:@"%.lf",[[NSDate date] timeIntervalSince1970]];
    NSMutableDictionary *eventDic = [NSMutableDictionary new];
    eventDic[@"eventId"] = eventId;
    eventDic[@"time"] = nowTime;
    if(attributes) {
        eventDic[@"attributes"] = attributes;
    }
    fileDic[eventId] = eventDic;
    [fileDic writeToFile:self.timeEventPath atomically:NO];
}

- (void)handleEndEvent:(NSString *)eventId attributes:(NSDictionary *)attributes {
    NSMutableDictionary *fileDic = [NSMutableDictionary dictionary];
    if (self.timeEventPath) {
       fileDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.timeEventPath];
    }
    
    NSDictionary *lastDic = fileDic[eventId];
    if(lastDic) {
        NSMutableDictionary *eventDic = [NSMutableDictionary new];
        NSString *nowTime = [NSString stringWithFormat:@"%.lf",[[NSDate date] timeIntervalSince1970]];
        double interval = [nowTime doubleValue] - [lastDic[@"time"] doubleValue];
        
        eventDic[@"second"] = [NSString stringWithFormat:@"%.lf", interval];
        if(attributes) {
            eventDic[@"attributes"] = attributes;
        }
        [fileDic removeObjectForKey:@"eventId"];
        [fileDic writeToFile:self.timeEventPath atomically:NO];
        [self storeEvent:eventId attributes:eventDic];
    }
}

- (void)clearEventFile {
    NSMutableArray *fileArray = [NSMutableArray arrayWithContentsOfFile:self.filePath];
//    NSLog(@"%@",fileArray);
    [fileArray removeAllObjects];
    [fileArray writeToFile:self.filePath atomically:NO];
}

- (void)timerHandler:(NSTimer *)timer {
    if(!self.isUploading) {
        [self requestServer];
    }
}

- (void)requestServer {
    self.isUploading = YES;
//    NSMutableArray *fileArray = [NSMutableArray arrayWithContentsOfFile:self.filePath];
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manager POST:@"" parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [self clearEventFile];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//
//    }];
    
    [self clearEventFile];
}

@end
