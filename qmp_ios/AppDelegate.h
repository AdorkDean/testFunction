//
//  AppDelegate.h
//  qmp_ios
//
//  Created by QMP on 2018/11/2.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) void (^requestForUserInfoBlock)(void);
@property (copy, nonatomic) void (^updateWechatUserInfoBlock)(NSDictionary *userInfoDict);//获得微信用户信息后 更新我的界面UI

- (void)getUserInfo:(NSString*)unionid;
- (void)setupWindowRootController;
+ (instancetype)shareDelegate;

@end

