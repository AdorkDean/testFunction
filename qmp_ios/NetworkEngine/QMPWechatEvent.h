//
//  QMPWechatEvent.h
//  qmp_ios
//
//  Created by QMP on 2018/8/21.
//  Copyright © 2018年 Molly. All rights reserved.
//微信登录相关

#import <Foundation/Foundation.h>

@interface QMPWechatEvent : NSObject

+ (instancetype)shared;
- (BOOL)loginWechat;
- (void)registWechat;
- (BOOL)handleOpenUrl:(NSURL*)url;

@end
