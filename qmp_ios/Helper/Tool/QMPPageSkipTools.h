//
//  LoginTools.h
//  qmp_ios
//
//  Created by QMP on 2018/11/7.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonLibrary/AppPageSkipTool.h>


NS_ASSUME_NONNULL_BEGIN

@interface QMPPageSkipTools : NSObject<AppPageSkipProtocol>

+ (instancetype)shared;

-(void)appPageSkipToPhoneLogin;
-(void)appPageSkipToBindPhone;
-(void)appPageSkipToBindPhoneFinish:(void (^)(NSString * _Nonnull))bindFinish;
-(void)appPageSkipToLogin;
@end

NS_ASSUME_NONNULL_END
