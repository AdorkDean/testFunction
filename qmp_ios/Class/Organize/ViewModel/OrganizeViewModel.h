//
//  OrganizeViewModel.h
//  qmp_ios
//
//  Created by QMP on 2018/6/25.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JiGouDetailModel, SocialCircleCellLayout, TagsFrame, OrganizeItem,
JigouInvestmentsCaseModel, OrganizeCombineItem, IntroduceCellLayout, NewsModel,
RelateCompanyModel,WinExperienceModel,ZhaopinModel;
@interface OrganizeViewModel : NSObject

- (CGFloat)tableHeaderViewHeight;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowInSection:(NSInteger)section;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;


@property (nonatomic, strong) NSMutableArray *sectionTitles;
- (NSString *)titleOfSection:(NSInteger)section;
- (NSString *)rightTitleOfSection:(NSInteger)section;

- (JiGouDetailModel *)detailModelWithResponse:(NSDictionary *)resp;
- (NSString *)organizeID;
- (NSString *)organizeTicket;

@property (nonatomic, strong) JiGouDetailModel *detailModel;
@property (nonatomic, strong) NSDictionary *lianxi;
@property (nonatomic, strong) OrganizeItem *organizeInfo;
@property (nonatomic, strong) NSNumber *claimType;


@property (nonatomic, assign) CGFloat infoCellHeight;


// 动态
- (void)handleOrganizeActivityWithResponse:(NSDictionary *)resp;
@property (nonatomic, assign) NSInteger countOfActivities;
@property (nonatomic, strong) NSArray *activityData;


// 简介
@property (nonatomic, strong) NSMutableDictionary *introduceInfoDic;
@property (nonatomic, strong) IntroduceCellLayout *introduceCellLayout;

// 投资团队
@property (nonatomic, strong) NSMutableArray *organizeMember;
- (void)handleManagersWithResponse:(NSDictionary*)resp;
@property (nonatomic, assign) NSInteger teamCount;


// 案例
- (NSArray *)caseArrWithTitle:(NSString *)sectionTitle;
- (void)handleInvestCaseWithResponse:(NSDictionary *)resp;
- (JigouInvestmentsCaseModel *)investCaseAtRow:(NSInteger)row;
- (void)handleFACaseWithResponse:(NSDictionary *)resp;
@property (nonatomic, assign) NSInteger investCasesCount;

// 在服项目
- (void)handleServiceCaseWithResponse:(NSDictionary *)resp;
@property (nonatomic, strong) NSMutableArray *serviceCases;

// 合投
- (void)handleTogetherOrganizeWithResponse:(NSArray *)resp;
- (OrganizeCombineItem *)togetherInvestOrganizeAtRow:(NSInteger)row;
@property (nonatomic, assign) NSInteger togetherCount; //合投


// 相关公司
- (void)handleRelateCompanyWithResponse:(NSDictionary *)resp;
- (NSString *)relateCompanyNameAtRow:(NSInteger)row;
- (RelateCompanyModel *)relateCompanyAtRow:(NSInteger)row;
@property (nonatomic, assign) NSInteger countOfRelatePro;

// 新闻
- (NewsModel *)newsModelAtRow:(NSInteger)row;
@property (nonatomic, assign) NSInteger newsAllCount;
@property (nonatomic, strong) NSMutableArray *organizeNewsData;
- (void)handleNewsWithResponse:(NSDictionary*)resp;

// 获奖
- (WinExperienceModel *)prizesModelAtRow:(NSInteger)row;
@property (nonatomic, assign) NSInteger prizeAllCount;
@property (nonatomic, strong) NSMutableArray *organizePrizeData;
- (void)handlePrizeWithResponse:(NSDictionary*)resp;

// 招聘
- (ZhaopinModel *)zhaopinModelAtRow:(NSInteger)row;
@property (nonatomic, assign) NSInteger zhaopinCount;
@property (nonatomic, strong) NSMutableArray *zhaopinArr;
- (void)handleZhaopinInfoWithResponse:(NSDictionary*)resp;

    
- (void)fixSectionTitles;

@property (nonatomic, assign) BOOL followed;

- (void)handleCommonCountWithResponse:(NSDictionary *)resp;
@property (nonatomic, assign) BOOL digged;
@property (nonatomic, assign) NSInteger diggCount;
@end
