//
//  OneSourceViewController.h
//  qmp_ios
//
//  Created by Molly on 2016/11/9.
//  Copyright © 2016年 Molly. All rights reserved.
//  机构、项目新闻列表

#import <UIKit/UIKit.h>
#import "SearchCompanyModel.h"
#import "CompanyDetailBasicModel.h"
#import "OrganizeItem.h"
#import "PersonModel.h"

@interface OneSourceViewController : BaseViewController

@property (strong, nonatomic) NSMutableArray *newsMArr;
@property (strong, nonatomic) NSString *action;
@property (strong, nonatomic) NSMutableDictionary *requestDict;
@property (strong, nonatomic) CompanyDetailBasicModel *companyItem;//公司基本信息
@property (strong, nonatomic) OrganizeItem *organizeItem;
@property (strong, nonatomic) PersonModel *person;

@end
