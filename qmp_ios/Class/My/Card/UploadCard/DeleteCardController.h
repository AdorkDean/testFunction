//
//  DeleteCardController.h
//  qmp_ios
//
//  Created by QMP on 2018/4/10.
//  Copyright © 2018年 Molly. All rights reserved.
//名片删除  委托联系删除

#import "BaseViewController.h"

@interface DeleteCardController : BaseViewController

@property(nonatomic,assign) NSInteger type; // 0 名片  1 委托联系
@property (copy, nonatomic) void(^deleteCardHandle)(void);
@end
