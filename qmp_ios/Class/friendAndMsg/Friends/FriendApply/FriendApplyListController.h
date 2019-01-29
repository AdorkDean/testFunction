//
//  FriendApplyListController.h
//  qmp_ios
//
//  Created by QMP on 2018/2/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

@interface FriendApplyListController : BaseViewController

@property (copy, nonatomic) void(^refreshVC)(BOOL countReduce);

@end
