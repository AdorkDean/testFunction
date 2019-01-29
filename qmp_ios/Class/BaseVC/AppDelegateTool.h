//
//  AppDelegateTool.h
//  CommonLibrary
//
//  Created by QMP on 2018/10/31.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegateTool : NSObject

+ (instancetype)shared;

//app启动需要做的事情
- (void)applicationLaunchWork;

- (BOOL)hangdelUrlToOther:(NSURL *)url withApplication:(UIApplication *)application;

@end

NS_ASSUME_NONNULL_END
