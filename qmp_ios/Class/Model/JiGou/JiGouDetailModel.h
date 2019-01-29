//
//  JiGouDetailModel.h
//  qmp_ios
//
//  Created by QMP on 2017/9/8.
//  Copyright © 2017年 Molly. All rights reserved.
//机构详情页 model

#import <JSONModel/JSONModel.h>
#import "OrganizeItem.h"
#import "JigouDetailLianxiModel.h"
#import "WinExperienceModel.h"

@protocol ManagerItem;
@protocol NewsModel;
@protocol WinExperienceModel;

@interface JiGouDetailModel : JSONModel

@property(nonatomic,strong) OrganizeItem <Optional>*basic;
@property(nonatomic,strong) JigouDetailLianxiModel <Optional> *lianXI;
@property(nonatomic,strong) NSArray <ManagerItem,Optional> *manager;
@property(nonatomic,strong) NSArray <NewsModel,Optional> *news;
@property (nonatomic) NSArray <WinExperienceModel,Optional> *win_exp;


@property (nonatomic, strong) NSNumber <Optional>*claim_type; ///< 认领状态 1:审核中 2:通过 3:拒绝
@end
