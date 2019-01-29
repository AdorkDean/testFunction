//
//  CreateBPProjectViewController.h
//  qmp_ios
//
//  Created by QMP on 2018/5/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"
@class ReportModel;
@interface CreateBPProjectViewController : BaseViewController
@property (nonatomic, strong) ReportModel *reportModel;
@property (nonatomic, weak) UIViewController *sourceVC;

@property (copy, nonatomic) void(^ didFinishedbandProject)(void);
@end
