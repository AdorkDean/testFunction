//
//  QMPThemeDetailViewController.h
//  qmp_ios
//
//  Created by QMP on 2018/9/21.
//  Copyright © 2018年 Molly. All rights reserved.
//主题动态列表

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMPThemeDetailViewController : BaseViewController
@property (nonatomic, strong) NSString *uID;  ///< ‘ticket’

@property (nonatomic, copy) NSString *ticket;
@property (nonatomic, copy) NSString *ticketID;
@end

NS_ASSUME_NONNULL_END
