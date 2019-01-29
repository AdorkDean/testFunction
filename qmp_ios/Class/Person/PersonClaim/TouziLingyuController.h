//
//  TouziLingyuyuController.h
//  qmp_ios
//
//  Created by QMP on 2018/2/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

@interface TouziLingyuController : BaseViewController

@property (copy, nonatomic) NSString *originalLingyu;
@property (copy, nonatomic) void(^selectedLingyu)(NSString *lingyuStr);
@property (copy, nonatomic) void(^backToLastpage)(void);

@end
