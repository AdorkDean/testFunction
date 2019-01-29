//
//  ThirdConfigTool.h
//  CommonLibrary
//
//  Created by QMP on 2018/10/30.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThirdConfigTool : NSObject

+ (void)initThirdInfo:(NSDictionary *)launchOptions applications:(UIApplication*)application;
+ (void)processJIGuang;
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;
@end

NS_ASSUME_NONNULL_END
