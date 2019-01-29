//
//  ToLogin.m
//  QimingpianSearch
//
//  Created by Molly on 16/7/29.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "ToLogin.h"
#import "LoginViewController.h"

#import "WXApi.h"

@implementation ToLogin

static ToLogin *loginTool = nil;
static dispatch_once_t onceToken = 0;

+ (instancetype)shared{
    
    dispatch_once(&onceToken, ^{
        loginTool = [[ToLogin alloc]init];
    });
    return loginTool;
}

/**
 *  提示"安装微信客户端"
 *
 *  @param viewController
 */
+ (void)setupWXAlert:(UIViewController *)viewController{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请先安装微信客户端" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:actionConfirm];
        [viewController presentViewController:alert animated:YES completion:nil];
    }
}

/**
 *  进入登录页
 *
 *  @param viewController
 */
+ (void)enterLoginPage:(UIViewController *)viewController{

    if ([USER_DEFAULTS boolForKey:APPVERSION_CHECKSTATUS]) {
        LoginViewController *loginVC = [[LoginViewController alloc]init];
        [viewController.navigationController pushViewController:loginVC animated:YES ];

    }else{
        [[ToLogin shared].delegate appPageSkipToLogin];
    }
            
}

+ (void)enterAttentionPage{ //进入关注引导界面
    [[ToLogin shared].delegate appPageSkipToInitFocus];
//
//    LoginLeaderController *leaderVC = [[LoginLeaderController alloc]init];
//    [[PublicTool topViewController].navigationController pushViewController:leaderVC animated:YES];

}


/**
 *  判断是否已登录
 *
 *  @return YES已经登录 NO未登录
 */
+ (BOOL)isLogin{
    
    NSString *uuid = [WechatUserInfo shared].uuid;
#warning ---两者都不空才是登陆
    BOOL isLogin = (![PublicTool isNull:uuid]) || ![PublicTool isNull:[WechatUserInfo shared].unionid];
    
    return isLogin;
}

+ (void)hasWxToLogin:(UIViewController *)currentVC{

    if ([WXApi isWXAppInstalled]) {
        
        [ToLogin enterLoginPage:currentVC];
        
    }
    else{
        //提示安装微信
//        [self setupWXAlert:currentVC];
    }

}

//手机号
+ (BOOL)isBindPhone{
    
    return  [WechatUserInfo shared].bind_flag.integerValue == 1;
}

+ (void)enterBindPhonePage:(UIViewController*)viewController{
    [[ToLogin shared].delegate appPageSkipToBindPhone];
//    PhoneViewController *vc = [[PhoneViewController alloc]init];
//    [viewController.navigationController pushViewController:vc  animated:YES ];
}

//新
+ (BOOL)canEnterDeep{ //是否能进入深层页面
    
    NSString *uuid = [WechatUserInfo shared].uuid;
    BOOL isLogin = ![PublicTool isNull:uuid];
//    return isLogin;
    
    BOOL isBind = [WechatUserInfo shared].bind_flag.integerValue == 1;
    return isLogin && isBind;
}

+ (void)accessEnterDeep{ //登录或绑定
    
    if ([PublicTool isNull:[WechatUserInfo shared].uuid]) {
        
        [ToLogin enterLoginPage:[PublicTool topViewController]];
    }else{
        [ToLogin enterBindPhonePage:[PublicTool topViewController]];
    }
}
+ (void)loginFailWithFunction:(NSString *)function desc:(NSString *)desc fromURL:(NSString *)url {
    
    NSDictionary *param = @{@"fromurl":url ? : @"fromurl是null[=", @"desc":desc, @"function":function};
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/notRightLogin" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
    }];
}

+ (void)loginSuccessLoadPage{
    //退出登录页面
    
    if ([KEYWindow.rootViewController isKindOfClass:[UITabBarController class]]) {
        NSArray *childVCArr = [PublicTool topViewController].navigationController.childViewControllers;
        for (UIViewController *childVC in childVCArr) {
            if ([childVC isKindOfClass:NSClassFromString(@"NewLoginController")] || [childVC isKindOfClass:NSClassFromString(@"LoginViewController")]) {
                NSInteger index = [childVCArr indexOfObject:childVC];
                [[PublicTool topViewController].navigationController popToViewController:childVCArr[index-1] animated:YES];
                return;
            }
        }
        [[PublicTool topViewController].navigationController popViewControllerAnimated:YES];
    
    }else{
        [[ToLogin shared].delegate setRootController];
    }
}


@end
