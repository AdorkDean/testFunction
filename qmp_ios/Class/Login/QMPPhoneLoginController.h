//
//  QMPPhoneLoginController.h
//  qmp_ios
//
//  Created by QMP on 2018/11/7.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMPPhoneLoginController : BaseViewController
@property (copy, nonatomic) void(^submitPhone)(NSString *phone);
@end

NS_ASSUME_NONNULL_END
