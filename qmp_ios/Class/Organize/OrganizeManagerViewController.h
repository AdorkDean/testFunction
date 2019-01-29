//
//  OrganizeManagerViewController.h
//  qmp_ios
//
//  Created by Molly on 2016/11/28.
//  Copyright © 2016年 Molly. All rights reserved.
//  机构、项目团队

#import <UIKit/UIKit.h>
#import "CompanyDetailBasicModel.h"
#import "OrganizeItem.h"
#import "CompanyDetailModel.h"

@interface OrganizeManagerViewController : BaseViewController

@property (strong, nonatomic) NSMutableDictionary *requestDict;


/**
 公司/机构 的团队
 */
@property (strong, nonatomic) NSString *action;

/**
 公司基本信息
 */
@property (strong, nonatomic) CompanyDetailBasicModel *companyItem;
/**
 机构基本信息
 */
@property (strong, nonatomic) OrganizeItem *organizeItem;

@end
