//
//  BPDeliverController.h
//  qmp_ios
//
//  Created by QMP on 2018/3/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

@interface BPDeliverController : BaseViewController
@property (copy, nonatomic) void(^ selectedBP)(ReportModel *report);
@property (copy, nonatomic)void(^backToLastpage)(void);
@property (nonatomic, assign) BOOL isCreateFinanceVC;
@property (nonatomic, strong) ReportModel *sourceReport;
@property (nonatomic, copy) NSString *personId;

@end
