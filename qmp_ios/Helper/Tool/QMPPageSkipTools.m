//
//  LoginTools.m
//  qmp_ios
//
//  Created by QMP on 2018/11/7.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "QMPPageSkipTools.h"
#import "QMPLoginController.h"
#import "QMPPhoneLoginController.h"
#import "QMPPhoneBindController.h"
#import "AppDelegate.h"
#import "NewerBindPhoneController.h"
#import "QMPTabbarController.h"
#import "TabbarActivityViewController.h"

@interface QMPPageSkipTools()

@end

@implementation QMPPageSkipTools

static QMPPageSkipTools *loginTool = nil;
static dispatch_once_t onceToken = 0;

+ (instancetype)shared{
    dispatch_once(&onceToken, ^{
        loginTool = [[QMPPageSkipTools alloc]init];
    });
    return loginTool;
}



#pragma mark --AppPageSkipProtocol
#pragma mark --登录
-(void)appPageSkipToPhoneLogin{
    QMPPhoneLoginController *phoneloginVC = [[QMPPhoneLoginController alloc]init];
    [[PublicTool topViewController].navigationController pushViewController:phoneloginVC animated:YES];
}
-(void)appPageSkipToBindPhone{
    NewerBindPhoneController *bindVC = [[NewerBindPhoneController alloc]init];
    [[PublicTool topViewController].navigationController pushViewController:bindVC animated:YES];
}
-(void)appPageSkipToBindPhoneFinish:(void (^)(NSString * _Nonnull))bindFinish{
    QMPPhoneBindController *bindVC = [[QMPPhoneBindController alloc]init];
    bindVC.submitPhone = ^(NSString * _Nonnull phone) {
        bindFinish(phone);
    };
    [[PublicTool topViewController].navigationController pushViewController:bindVC animated:YES];
}

-(void)appPageSkipToLogin{
    QMPLoginController *loginVC = [[QMPLoginController alloc]init];
    [[PublicTool topViewController].navigationController pushViewController:loginVC animated:YES];

}
#pragma mark --人物


#pragma mark --用户
- (void)refreshUserInfo{
    [[AppDelegate shareDelegate] getUserInfo:[WechatUserInfo shared].uuid];
}

- (void)setRootController{
    [[AppDelegate shareDelegate] setupWindowRootController];
}


- (void)appPageSkipToActivitySquare {
    UIViewController *vc = KEYWindow.rootViewController;
    if ([vc isKindOfClass:[QMPTabbarController class]]) {
        QMPTabbarController *tVc = (QMPTabbarController *)vc;
        UIViewController *vcf = [PublicTool topViewController];
        [tVc setSelectedIndex:1];
        [vcf.navigationController popToRootViewControllerAnimated:NO];
        UIViewController *vc1 = [PublicTool topViewController];
        
        if ([vc1 isKindOfClass:[TabbarActivityViewController class]]) {
            TabbarActivityViewController *vc2 = (TabbarActivityViewController *)vc1;
            [vc2 toSquare];
        }
    }
}

- (void)appPageSkipToActivityHotOrAnonymous:(BOOL)hot {
    UIViewController *vc = KEYWindow.rootViewController;
    if ([vc isKindOfClass:[QMPTabbarController class]]) {
        QMPTabbarController *tVc = (QMPTabbarController *)vc;
        UIViewController *vcf = [PublicTool topViewController];
        [tVc setSelectedIndex:2];
        [vcf.navigationController popToRootViewControllerAnimated:NO];
    }
}

-(void)appPageSkipToActivityTag:(NSString *)tagName activityID:(NSString *)activityID{
    UIViewController *vc = KEYWindow.rootViewController;
    if ([vc isKindOfClass:[QMPTabbarController class]]) {
        QMPTabbarController *tVc = (QMPTabbarController *)vc;
        UIViewController *vcf = [PublicTool topViewController];
        [tVc setSelectedIndex:1];
        [vcf.navigationController popToRootViewControllerAnimated:NO];
        UIViewController *vc1 = [PublicTool topViewController];
        
        if ([vc1 isKindOfClass:[TabbarActivityViewController class]]) {
            TabbarActivityViewController *vc2 = (TabbarActivityViewController *)vc1;
            [vc2 showToTag:tagName activityID:activityID];
        }
    }
}

@end
