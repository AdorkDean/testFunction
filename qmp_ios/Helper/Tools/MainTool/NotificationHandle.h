//
//  NotificationHandle.h
//  CommonLibrary
//
//  Created by QMP on 2018/10/30.
//  Copyright © 2018年 WSS. All rights reserved.
//通知处理

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>


NS_ASSUME_NONNULL_BEGIN

@interface NotificationHandle : NSObject

+ (instancetype)shared;

- (void)resetAppBadge;

//通知的处理
- (void)handleNotificationContent:(id)notification;


- (void)applicationWillEnterForeground:(UIApplication*)application;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler;
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler;
@end

NS_ASSUME_NONNULL_END
