//
//  CompanyDetailModel.h
//  qmp_ios
//
//  Created by QMP on 2017/9/1.
//  Copyright © 2017年 Molly. All rights reserved.

//公司详情

#import <JSONModel/JSONModel.h>

#import "CompanyDetailBasicModel.h" //公司基本信息
#import "ReportModel.h"
#import "SearchCompanyModel.h"
#import "CompanyDetailNewThirdModel.h"

@protocol NewsModel;     //公司新闻
@protocol ManagerItem; //公司团队
@protocol CompanyDetailRongziModel; //融资
@protocol CompanyDetailLianxiModel; //联系方式
@protocol SearchCompanyModel; //业务和相似项目

@interface CompanyDetailModel : JSONModel

@property (copy, nonatomic) NSString <Optional>*ticket;
@property (copy, nonatomic) NSString <Optional>*ticketMD5;

@property(nonatomic,strong) CompanyDetailBasicModel <Optional>*company_basic;
@property(nonatomic,strong) NSArray <ManagerItem,Optional> *company_team; //公司团队
@property(nonatomic,strong) NSArray <CompanyDetailRongziModel,Optional>* company_rongzi;//融资历史
@property(nonatomic,strong) NSArray <CompanyDetailLianxiModel,Optional>*company_contact; //联系方式
@property(nonatomic,strong) NSArray <SearchCompanyModel,Optional>* company_business;//公司业务

@property(nonatomic,strong) NSArray <NewsModel,Optional> *news;
@property(nonatomic,strong) NSArray <SearchCompanyModel,Optional> *similar;

/**
 1:可以委托   2:委托成功  3：今日已委托(失败或没结果)，明日可再委托
 */
@property (copy, nonatomic) NSString <Optional>*obtain_status;

@property (strong, nonatomic) NSNumber <Optional>*is_register;

@property (nonatomic, strong) NSNumber <Optional>*claim_type; ///< 认领状态 1:审核中 2:通过 3:拒绝
@property (nonatomic, strong) NSNumber <Optional>*rz_flag; ///< 自己发布的融资需求审核状态  融资审核中 = 1 

@end
