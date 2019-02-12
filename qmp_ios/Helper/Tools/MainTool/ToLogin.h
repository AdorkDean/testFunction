//
//  ToLogin.h
//  QimingpianSearch
//
//  Created by Molly on 16/7/29.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppPageSkipTool.h"
#import <UIKit/UIKit.h>

@interface ToLogin : NSObject

+ (instancetype)shared;

+ (void)setupWXAlert:(UIViewController *)viewController;
+ (void)enterLoginPage:(UIViewController *)viewController;
+ (BOOL)isLogin;
+ (void)hasWxToLogin:(UIViewController *)currentVC;

//手机号
+ (BOOL)isBindPhone;
+ (void)enterBindPhonePage:(UIViewController*)viewController;

//新
+ (BOOL)canEnterDeep; //是否能进入深层页面
+ (void)accessEnterDeep; //登录或绑定
+ (void)enterAttentionPage; //进入关注引导界面

+ (void)loginFailWithFunction:(NSString *)function desc:(NSString *)desc fromURL:(NSString *)url;
+ (void)loginSuccessLoadPage;

@end
