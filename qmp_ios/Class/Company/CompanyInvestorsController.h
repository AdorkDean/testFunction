//
//  CompanyInvestorsController.h
//  qmp_ios
//
//  Created by QMP on 2018/4/4.
//  Copyright © 2018年 Molly. All rights reserved.
//项目投资人

#import "BaseViewController.h"
#import "SearchCompanyModel.h"

/**
 项目投资人（投资机构）列表
 */
@interface CompanyInvestorsController : BaseViewController

@property(nonatomic,strong)SearchCompanyModel *companyModel;
@property(nonatomic,strong)NSString *ticket;

@end
