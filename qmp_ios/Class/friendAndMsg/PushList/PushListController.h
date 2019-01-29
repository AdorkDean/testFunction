//
//  PushListController.h
//  qmp_ios
//
//  Created by QMP on 2018/1/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

/**
 推送列表 - 需要进行区分，是从推送消息进入，还是从系统通知进入
 */
@interface PushListController : BaseViewController
@property (nonatomic, copy) NSString * navTitleStr;
@property (nonatomic, copy) NSString * pushType;
@end
