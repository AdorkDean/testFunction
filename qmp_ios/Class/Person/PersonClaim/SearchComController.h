//
//  SearchComController.h
//  qmp_ios
//
//  Created by QMP on 2018/2/28.
//  Copyright © 2018年 Molly. All rights reserved.
//搜索 公司 或者 机构

#import "BaseViewController.h"

@interface SearchComController : BaseViewController

@property (copy, nonatomic) void(^ didSelected)(id selectedObject);
@property (copy, nonatomic) void(^ didSelectedCreateProject)(NSString *searchText);
@property (copy, nonatomic) void(^ backLastPage)(void);


//传入公司名 或 机构名
@property(nonatomic,assign) BOOL isCompany;
@property(nonatomic,assign) BOOL isTouziCase;
@property(nonatomic,assign) BOOL isFinance; // 发布融资搜索

@property (copy, nonatomic)NSString *keyword;


@end
