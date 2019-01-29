//
//  ActivityShareViewController.h
//  qmp_ios
//
//  Created by QMP on 2018/7/5.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"
#import "ActivityModel.h"

@class QMPActivityCellModel, ActivityRelateModel;
@interface ActivityShareViewController : BaseViewController
@property (nonatomic, strong) QMPActivityCellModel *cellModel;
@property (nonatomic, strong) ActivityModel *activity;

@property (nonatomic, strong) ActivityRelateModel *relateModel;
@end
