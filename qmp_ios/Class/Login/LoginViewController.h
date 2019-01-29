//
//  LoginViewController.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/26.
//  Copyright © 2016年 qimingpian. All rights reserved.
//审核时候用的手机登录，账户密码

#import <UIKit/UIKit.h>

@class WechatUserInfo;

@interface LoginViewController : BaseViewController //BaseViewController

/** 通过block去执行AppDelegate中的wechatLoginByRequestForUserInfo方法 */
@property (copy, nonatomic) void (^requestForUserInfoBlock)(void);
@property (copy, nonatomic) void (^updateWechatUserInfoBlock)(NSDictionary *userInfoDict);//获得微信用户信息后 更新我的界面UI
@property (strong, nonatomic) WechatUserInfo *wechatUserInfo;//用户

@property (strong, nonatomic) NSString *action;
@property (strong,nonatomic) UIButton *cancelWechatLoginBtn;

@end
