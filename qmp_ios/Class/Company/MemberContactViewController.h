//
//  MemberContactViewController.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/10/30.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "BaseViewController.h"
#import "CompanyDetailBasicModel.h"
#import "OrganizeItem.h"
#import "CompanyDetailModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MemberContactViewController : BaseViewController
@property (strong, nonatomic) NSMutableDictionary *requestDict;
/**
 公司/机构 的团队
 */
@property (strong, nonatomic) NSString *action;

/**
 公司基本信息
 */
@property (strong, nonatomic) CompanyDetailBasicModel *companyItem;
@property (strong, nonatomic) CompanyDetailModel * companyDetail;
/**
 机构基本信息
 */
@property (strong, nonatomic) OrganizeItem *organizeItem;
@end

NS_ASSUME_NONNULL_END
