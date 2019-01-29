//
//  CompanyFinancialViewController.h
//  qmp_ios
//
//  Created by QMP on 2018/5/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"
#import "FinanicalNeedModel.h"
#import "CompanyDetailModel.h"
@interface CompanyFinancialViewController : BaseViewController
@property(nonatomic, strong) FinanicalNeedModel * needModel;
@property (nonatomic, strong) CompanyDetailModel *companyDetail;
@end
