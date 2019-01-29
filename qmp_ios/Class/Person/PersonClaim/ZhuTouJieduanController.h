//
//  ZhuTouJieduanController.h
//  qmp_ios
//
//  Created by QMP on 2018/3/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"
#import "SearchCompanyModel.h"

@class SearchComController;
@interface ZhuTouJieduanController : BaseViewController

@property(nonatomic,assign) SearchCompanyModel *companyM;

@property (copy, nonatomic) NSString *originalJieduan;
@property (copy, nonatomic) void(^selectedJieDuan)(NSString *jieduanStr);
@property (copy, nonatomic) void(^backToLastpage)(void);

@end
