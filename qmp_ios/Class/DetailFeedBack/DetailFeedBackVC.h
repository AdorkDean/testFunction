//
//  DetailFeedBackVC.h
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"
#import "PersonModel.h"
#import "OrganizeItem.h"
#import "CompanyDetailModel.h"

typedef NS_ENUM(NSUInteger, DetailFeedBackType) {
    DetailFeedBackTypePerson,
    DetailFeedBackTypeOrganize,
    DetailFeedBackTypeProduct,
};

/**
 详情反馈
 */
@interface DetailFeedBackVC : BaseViewController

//反馈类型，与数据源相关、数据传参不一样
@property (nonatomic, assign) DetailFeedBackType type;
@property(nonatomic,strong) PersonModel *personM;
@property(nonatomic,strong) OrganizeItem *organizeInfo;
@property(nonatomic,strong) CompanyDetailModel *companyM;

@property (nonatomic, copy) NSString * imgUrlStr;//顶部图片url

@property (nonatomic, copy) NSString * productName;//项目名字 or 品牌名字 or 产品名
@property (nonatomic, copy) NSString * companyName;//公司名字，全名
@property (nonatomic, strong) NSArray * rongziHistory;//融资历史

@property (nonatomic, strong) NSArray * teamArr;//团队成员


@property (nonatomic, copy) NSString * personName;//人物名字
@property (nonatomic, copy) NSString * personId;
@property (nonatomic, strong) NSArray * workArr;//工作经历
@property (nonatomic, strong) NSArray * educationArr;//教育经历


@property (nonatomic, strong) NSArray * faArr;//FA案例
@property (nonatomic, strong) NSArray * touziArr;//投资案例
@property (nonatomic, copy) NSString * jigouName;//机构名字

@end
