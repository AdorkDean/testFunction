//
//  ProductDetailViewModel.h
//  qmp_ios
//
//  Created by QMP on 2018/6/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompanyDetailModel.h"
#import "FinanicalNeedModel.h"
#import "TagsFrame.h"
#import "TagsItem.h"
#import "ZhaopinModel.h"
#import "CountAndStatusModel.h"
#import "IntroduceCellLayout.h"

@interface ProductDetailViewModel : NSObject

//传入参
@property (nonatomic, strong) NSDictionary * requestDic;
@property (nonatomic, weak) UIScrollView * scrollView;


@property(nonatomic,strong)CompanyDetailModel *companyDetail;
@property(nonatomic,strong)NSMutableArray *workTagArr;
@property(nonatomic,strong) NSMutableArray *zhaopinArr; //招聘
@property(nonatomic,strong) NSMutableArray *similarArr; //招聘
@property(nonatomic,strong) NSMutableArray *newsArr; //新闻
@property(nonatomic,strong) NSMutableArray *prizeArr; //获奖

@property(nonatomic,strong) NSMutableArray *valueDynamicArr; //价值动态
@property(nonatomic,strong) NSMutableArray *investorsArr; //投资人
@property (nonatomic, strong) NSArray *apps; //app数据

@property (nonatomic, strong) FinanicalNeedModel * needModel;
@property(nonatomic,strong)NSMutableArray *commentLayouts;
@property (strong, nonatomic)CountAndStatusModel *status_Info;
@property (strong, nonatomic)NSArray *registInfoMenusArr;
@property (assign, nonatomic)BOOL tagIsSpread; //画像展开是否
@property (strong, nonatomic)NSMutableDictionary *introduceInfoDic;
@property (strong, nonatomic)IntroduceCellLayout *introduceCellLayout;
/**公司相似项目  新闻 公司业务 团队成员 动态  工商 招聘*/
@property (strong, nonatomic)NSMutableDictionary *sectionDataCountDic;

//企业画像
@property (strong, nonatomic) NSMutableArray *tagsMatchMArr;
@property (nonatomic, strong) TagsFrame *tagsFrame;//企业画像的frame
//关注 btnEvent 和 刷新 signal
@property (nonatomic ,readonly) RACCommand *updateAttentStatusCommand;

//进二级页
@property (nonatomic ,readonly) RACCommand *enterSecondPageCommand;

@property (nonatomic ,readonly) RACCommand *publishCommentCommand;

@property (nonatomic ,readonly) RACSignal *requestFinishSignal;
@property (nonatomic ,readonly) RACSignal *requestFinishTwoSignal; //第二部分的网络请求

@property (nonatomic ,readonly) RACSignal *requestStatusSignal;
@property (nonatomic ,readwrite) RACSignal *refreshCommentListSignal;
@property (nonatomic ,readonly) RACSignal *updateTagsFrameSignal;

@property (nonatomic, readwrite) RACSignal *requestAppsSignal;
@end
