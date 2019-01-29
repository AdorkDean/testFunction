//
//  FinancialInfoSubmitVC.h
//  qmp_ios
//
//  Created by QMP on 2018/5/29.
//  Copyright © 2018年 Molly. All rights reserved.
//融资信息编辑页

#import "BaseViewController.h"
#import "SearchCompanyModel.h"

@interface FinancialInfoSubmitVC : BaseViewController

@property(nonatomic,strong) SearchCompanyModel *model;
@property (nonatomic, assign) BOOL isNewProject;

@end
