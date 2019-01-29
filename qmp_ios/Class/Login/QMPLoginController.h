//
//  QMPLoginController.h
//  qmp_ios
//
//  Created by QMP on 2018/11/7.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "BaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface QMPLoginController : BaseViewController

/** 通过block去执行AppDelegate中的wechatLoginByRequestForUserInfo方法 */
@property (copy, nonatomic) void (^requestForUserInfoBlock)(void);
@property (copy, nonatomic) void (^updateWechatUserInfoBlock)(NSDictionary *userInfoDict);//获得微信用户信息后 更新我的界面UI
@property (strong, nonatomic) WechatUserInfo *wechatUserInfo;//用户

@property (strong, nonatomic) NSString *action;
@property (strong,nonatomic) UIButton *cancelWechatLoginBtn;

@end

NS_ASSUME_NONNULL_END
