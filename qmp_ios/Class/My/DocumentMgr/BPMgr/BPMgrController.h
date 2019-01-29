//
//  BPMgrController.h
//  qmp_ios
//
//  Created by QMP on 2017/11/7.
//  Copyright © 2017年 Molly. All rights reserved.
// BP  我的 ->

#import "BaseViewController.h"
#import "BPDownController.h"

/**
 我的 - BP管理
 */
@interface BPMgrController : BaseViewController

- (void)selectedIndexPage:(NSInteger)index;

- (void)refreshMYBPMenu:(BOOL)show;

@end
