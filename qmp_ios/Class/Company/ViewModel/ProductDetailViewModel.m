//
//  ProductDetailViewModel.m
//  qmp_ios
//
//  Created by QMP on 2018/6/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductDetailViewModel.h"
#import "OrganizeManagerViewController.h"

#import "CompanySimilarViewController.h"
#import "CompanyProductionViewController.h"
#import "CompanyInvestorsController.h"
#import "CompanyZhaopinController.h"
#import "RegisterInfoViewController.h"
#import "OneSourceViewController.h"
#import "SearchCompanyModel.h"
#import "ActivityModel.h"
#import "ActivityLayout.h"
#import "PostActivityViewController.h"
#import "ActivityListViewController.h"
#import "ProductValuelistController.h"
#import "ProductAppListController.h"
#import "PersonModel.h"
#import "MemberContactViewController.h"
#import "ManagerItem.h"
#import "WinExperienceModel.h"
#import "PersonWinExperienceVC.h"

@interface ProductDetailViewModel()

@property (nonatomic ,readwrite) RACSignal *requestProductSignal;
@property (nonatomic ,readwrite) RACSignal *requestNeedMoneySignal;
@property (nonatomic ,readwrite) RACSignal *requestZhaopinSignal;
@property (nonatomic ,readwrite) RACSignal *requestCommentSignal;
@property (nonatomic ,readwrite) RACSignal *requestValueDynamicSignal;
@property (nonatomic ,readwrite) RACSignal *requestInvestorListSignal;
@property (nonatomic ,readwrite) RACSignal *requestNewsSignal;
@property (nonatomic ,readwrite) RACSignal *requestPrizeSignal;
@property (nonatomic ,readwrite) RACSignal *requestSimilarSignal;


@end


@implementation ProductDetailViewModel
- (instancetype)init{
    if (self = [super init]) {
        self.status_Info = [[CountAndStatusModel alloc]init];
        self.status_Info.like_status = -1;
        self.status_Info.focus_status = -1;
    }
    return self;
}
- (void)dealloc
{
    NSLog(@"%s", __func__);
}

#pragma mark ---SIGNAL 信号--
@synthesize requestFinishSignal = _requestFinishSignal;

-(RACSignal *)requestFinishSignal{
    if (!_requestFinishSignal) {
        @synchronized (self) {
            @weakify(self)
            _requestFinishSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                
                RACSignal *zipSignal0 = [self.requestCommentSignal zipWith:self.requestInvestorListSignal];
                
                RACSignal *zipSignal00 = [self.requestProductSignal then:^RACSignal * _Nonnull{
                    return zipSignal0;
                }];
                
                RACSignal *zipSignal1 = [zipSignal00 zipWith:self.requestNeedMoneySignal];
                [zipSignal1 subscribeNext:^(id  _Nullable x) {
                
                    [subscriber sendNext:nil];
                    [subscriber sendCompleted];
                }];

                return nil;
            }];
        }
    }
    return _requestFinishSignal;
}

@synthesize requestFinishTwoSignal = _requestFinishTwoSignal;
-(RACSignal *)requestFinishTwoSignal{
    if (!_requestFinishTwoSignal) {
        @synchronized (self) {
            @weakify(self)
            _requestFinishTwoSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                
//                RACSignal *zipSIgnal0 = [ zipWith:self.requestAppsSignal];
                RACSignal *zipSignal1 = [self.requestAppsSignal zipWith:self.requestSimilarSignal];
                RACSignal *zipSignal2 = [zipSignal1 zipWith:self.requestZhaopinSignal];
                RACSignal *zipSignal3 = [zipSignal2 zipWith:self.requestNewsSignal];
                RACSignal *zipSignal4 = [zipSignal3 zipWith:self.requestPrizeSignal];

                [zipSignal4 subscribeNext:^(id  _Nullable x) {
                    
                    [subscriber sendNext:nil];
                    [subscriber sendCompleted];
                }];
                
                return nil;
            }];
        }
    }
    return _requestFinishTwoSignal;
}

-(RACSignal *)requestProductSignal{
    @synchronized (self) {
        if (!_requestProductSignal) {
            @weakify(self)
            _requestProductSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestProductDetailWithCompletion:^{
                    [subscriber sendNext:nil];
                    [subscriber sendCompleted];
                }];
                return nil;
            }];
        }
    }
    return _requestProductSignal;
}

-(RACSignal *)requestValueDynamicSignal{
    if (!_requestValueDynamicSignal) {
        @synchronized (self) {
            @weakify(self)
            _requestValueDynamicSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestValueDynamicCompletion:^{
                    [subscriber sendNext:nil];
                }];
                return nil;
            }];
        }
    }
    return _requestValueDynamicSignal;
}

-(RACSignal *)requestInvestorListSignal{
    if (!_requestInvestorListSignal) {
        @synchronized (self) {
            @weakify(self)
            _requestInvestorListSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestInvestorListCompletion:^{
                    [subscriber sendNext:nil];
                }];
                return nil;
            }];
        }
    }
    return _requestInvestorListSignal;
}

-(RACSignal *)requestNewsSignal{
    if (!_requestNewsSignal) {
        @synchronized (self) {
            @weakify(self)
            _requestNewsSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestNewsListWithCompletion:^{
                    [subscriber sendNext:nil];
                }];
                return nil;
            }];
        }
    }
    return _requestNewsSignal;
}//

-(RACSignal *)requestPrizeSignal{
    if (!_requestPrizeSignal) {
        @synchronized (self) {
            @weakify(self)
            _requestPrizeSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestPrizeListWithCompletion:^{
                    [subscriber sendNext:nil];
                }];
                return nil;
            }];
        }
    }
    return _requestPrizeSignal;
}

-(RACSignal *)requestSimilarSignal{
    if (!_requestSimilarSignal) {
        @synchronized (self) {
            @weakify(self)
            _requestSimilarSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestSimilarListWithCompletion:^{
                    [subscriber sendNext:nil];
                }];
                return nil;
            }];
        }
    }
    return _requestSimilarSignal;
}

-(RACSignal *)requestZhaopinSignal{
    if (!_requestZhaopinSignal) {
        @synchronized (self) {
            @weakify(self)
            _requestZhaopinSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestZhaopinListWithCompletion:^{
                    [subscriber sendNext:nil];
                }];
                return nil;
            }];
        }
    }
    return _requestZhaopinSignal;
}
-(RACSignal *)requestNeedMoneySignal{
    if (!_requestNeedMoneySignal) {
        @synchronized (self) {
            @weakify(self)
            _requestNeedMoneySignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestNeedMoneyData:^{
                    [subscriber sendNext:nil];
                }];
                return nil;
            }];
        }
    }
    return _requestNeedMoneySignal;
}

-(RACSignal *)requestCommentSignal{
    if (!_requestCommentSignal) {
        @synchronized (self) {
            @weakify(self)
            _requestCommentSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestCommentList:^{
                    [subscriber sendNext:nil];
                }];
                return nil;
            }];
        }
    }
    return _requestCommentSignal;
}


@synthesize requestStatusSignal = _requestStatusSignal;
-(RACSignal *)requestStatusSignal{
    if (!_requestStatusSignal) {
        @synchronized (self) {
            @weakify(self)
            _requestStatusSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestStatusCountInfo:^{
                    [subscriber sendNext:nil];
                }];
                return nil;
            }];
        }
    }
    return _requestStatusSignal;
}

-(RACSignal *)requestAppsSignal{
    if (!_requestAppsSignal) {
        @synchronized (self) {
            @weakify(self)
            _requestAppsSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self requestProductApps:^{
                    [subscriber sendNext:nil];
                }];
                return nil;
            }];
        }
    }
    return _requestAppsSignal;
}

//更新tagsFrame
@synthesize updateTagsFrameSignal = _updateTagsFrameSignal;
-(RACSignal *)updateTagsFrameSignal{
    if (!_updateTagsFrameSignal) {
        @synchronized (self) {
            @weakify(self)
            _updateTagsFrameSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self dealTags];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }];
        }
    }
    return _updateTagsFrameSignal;
}

#pragma mark --RACCommand
@synthesize updateAttentStatusCommand = _updateAttentStatusCommand;
-(RACCommand *)updateAttentStatusCommand{
    if (!_updateAttentStatusCommand) {
        
        @weakify(self)
        _updateAttentStatusCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self);
            [self updateFoucsStatus];
            return [RACSignal empty];
        }];
    }
    return _updateAttentStatusCommand;
}

@synthesize enterSecondPageCommand = _enterSecondPageCommand;
-(RACCommand *)enterSecondPageCommand{
    if (!_enterSecondPageCommand) {
        
        @weakify(self)
        _enterSecondPageCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(NSString *input) {
            @strongify(self);
            
            [self enterSecondPageEventTypeTitle:input];
            return [RACSignal empty];
            
        }];
    
    }
    return _enterSecondPageCommand;
}


@synthesize publishCommentCommand = _publishCommentCommand;
-(RACCommand *)publishCommentCommand{
    if (!_publishCommentCommand) {
        
        @weakify(self)
        _publishCommentCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(NSString *input) {
            @strongify(self);
            [self enterPublishCommentPage];
            return [RACSignal empty];
            
        }];
        
    }
    return _publishCommentCommand;
}


#pragma mark ---网络请求--
- (void)requestProductDetailWithCompletion:(void(^)(void))completion{
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];
    
    if (self.scrollView && self.scrollView.mj_header.isRefreshing) {
        [mDict setValue:@"1" forKey:@"debug"];
    }
    [AppNetRequest getCompanyDetailWithParameter:mDict completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            CompanyDetailModel *companyDetail = [[CompanyDetailModel alloc]initWithDictionary:resultData error:nil];
            if ([companyDetail.company_basic.claim_unionid containsString:@"null"]) {
                companyDetail.company_basic.claim_unionid = @"";
            }
            self.companyDetail.company_basic.miaoshu = [PublicTool filterSpecialString:self.companyDetail.company_basic.miaoshu];

            self.companyDetail = companyDetail;
            self.companyDetail.ticket = self.requestDic[@"ticket"];
            self.companyDetail.ticketMD5 = self.requestDic[@"id"];
            //请求点赞关注
            [self.requestStatusSignal subscribeNext:^(id  _Nullable x) {
            }];
//            [self.sectionDataCountDic setValue:resultData[@"company_team"][@"count"] forKey:@"团队成员"];

            self.introduceInfoDic = [NSMutableDictionary dictionaryWithDictionary:@{@"content":companyDetail.company_basic.miaoshu?companyDetail.company_basic.miaoshu:@"",@"spread":@(NO)}];
            self.introduceCellLayout = [[IntroduceCellLayout alloc]initWithIntroduce:self.introduceInfoDic];
            //工商信息菜单
            [self dealRegisterMenus:resultData[@"module"]];
            [self dealTags];
            self.tagsMatchMArr = [NSMutableArray arrayWithArray:self.companyDetail.company_basic.tags_portrait];
        }
        
        completion();
    }];
}

- (void)setIntroduceInfoDic:(NSMutableDictionary *)introduceInfoDic{
    _introduceInfoDic = introduceInfoDic;
    [self.introduceCellLayout layout];
}

- (void)requestInvestorListCompletion:(void(^)(void))completion{
    
    NSInteger isdebug = [self.scrollView.mj_header isRefreshing] ? 1 : 0;
    
    NSDictionary *dic = @{@"page":@(1),@"num":@(6),@"debug":@(isdebug),@"ticket":self.companyDetail.ticket?:@""};

    [AppNetRequest getProductInvestorListWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.sectionDataCountDic setValue:resultData[@"count"] forKey:@"投资人"];
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                PersonModel *person = [[PersonModel alloc]initWithDictionary:dic error:nil];
                person.name = dic[@"person_name"];
                person.detail = dic[@"person_detail"];
                [arr addObject:person];
            }
            self.investorsArr = arr;
        }
        completion();

    }];
}

- (void)requestPrizeListWithCompletion:(void(^)(void))completion{
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];
    [param setValue:(self.scrollView && self.scrollView.mj_header.isRefreshing ? @"1" :@"0") forKey:@"debug"];
    [param setValue:@(100) forKey:@"num"];
    [param setValue:@(1) forKey:@"page"];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"companyDetail/companyAwards" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]] && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *winMarr = [NSMutableArray array];
            [self.sectionDataCountDic setValue:resultData[@"count"] forKey:@"获奖经历"];
            for (NSDictionary *info in resultData[@"list"]) {
                WinExperienceModel *win = [[WinExperienceModel alloc] initWithDictionary:info error:nil];
                [winMarr addObject:win];
            }
            self.prizeArr = [NSMutableArray arrayWithArray:winMarr];
            
        }
        completion();
    }];
}


- (void)requestNewsListWithCompletion:(void(^)(void))completion{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];
    [param setValue:(self.scrollView && self.scrollView.mj_header.isRefreshing ? @"1" :@"0") forKey:@"debug"];
    [param setValue:@(6) forKey:@"num"];
    [param setValue:@(1) forKey:@"page"];

    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"News/productNews" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]] && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *newsMarr = [NSMutableArray array];
            [self.sectionDataCountDic setValue:resultData[@"count"] forKey:@"新闻"];
            for (NSDictionary *newsInfo in resultData[@"list"]) {
                NewsModel *news = [[NewsModel alloc] initWithDictionary:newsInfo error:nil];
                [newsMarr addObject:news];
            }
            self.newsArr = [NSMutableArray arrayWithArray:newsMarr];
            
        }
        completion();
    }];
}

- (void)requestSimilarListWithCompletion:(void(^)(void))completion{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];
    [param setValue:(self.scrollView && self.scrollView.mj_header.isRefreshing ? @"1" :@"0") forKey:@"debug"];
    [param setValue:@(5) forKey:@"num"];
    [param setValue:@(1) forKey:@"page"];

    [AppNetRequest getCompanySimilarWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
    
        if (resultData && [resultData isKindOfClass:[NSDictionary class]] && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *marr = [NSMutableArray array];
            [self.sectionDataCountDic setValue:resultData[@"count"] forKey:@"相似项目"];
            for (NSDictionary *info in resultData[@"list"]) {
                SearchCompanyModel *news = [[SearchCompanyModel alloc] initWithDictionary:info error:nil];
                [marr addObject:news];
            }
            self.similarArr = [NSMutableArray arrayWithArray:marr];

        }
        completion();
    }];
}

- (void)requestZhaopinListWithCompletion:(void(^)(void))completion{

    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];

    [param setValue:(self.scrollView.mj_header.isRefreshing ? @"1" :@"0") forKey:@"debug"];
    [param setValue:@(1) forKey:@"page"];
    [param setValue:@(6) forKey:@"num"];
    
    [AppNetRequest getCompanyZhaopinWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]] && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            self.zhaopinArr = [NSMutableArray array];
            [self.sectionDataCountDic setValue:resultData[@"count"] forKey:@"招聘"];
            for (NSDictionary *zhaopinDic in resultData[@"list"]) {
                ZhaopinModel *zhaopinInfo = [[ZhaopinModel alloc] initWithDictionary:zhaopinDic error:nil];
                [self.zhaopinArr addObject:zhaopinInfo];
            }
            
        }
        completion();
    }];
}

- (void)requestValueDynamicCompletion:(void(^)(void))completion{
    
    self.valueDynamicArr = [NSMutableArray array];
    if ([PublicTool isNull:self.companyDetail.ticket]) {
        completion();
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"product" forKey:@"type"];
    [dic setValue:self.companyDetail.ticket forKey:@"ticket"];
    [dic setValue:@(2) forKey:@"comment_type"];
    [dic setValue:@(1) forKey:@"page"];
    [dic setValue:@(12) forKey:@"num"];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/getDetailRelationList" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        NSArray *list = @[];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {

            [self.sectionDataCountDic setValue:resultData[@"count"] forKey:@"价值动态"];
            list = resultData[@"list"];
            [self.valueDynamicArr removeAllObjects];
            for (NSDictionary *dict in list) {
                ActivityModel *model = [ActivityModel activityModelWithDict:dict];
                if (![PublicTool isNull:model.linkInfo.linkUrl]) {
                    model.linkInfo.linkTitle = @"新闻链接";
                }
                ActivityLayout *layout = [[ActivityLayout alloc] initLayoutWithActivityModel:model type:ActivityLayoutTypeCompany];
                [self.valueDynamicArr addObject:layout];
            }
        }
        
        completion();
    }];
}


- (void)requestNeedMoneyData:(void(^)(void))completion{

    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];
    
    [param setValue:(self.scrollView.mj_header.isRefreshing ? @"1" :@"0") forKey:@"debug"];

    [AppNetRequest getFinanalNeedWithPararmeter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData != nil && [resultData isKindOfClass:[NSDictionary class]]) {
            FinanicalNeedModel * model = [[FinanicalNeedModel alloc] initWithDictionary:resultData error:nil];
            self.needModel = model;
            
        }else{
            
            self.needModel = nil;
        }
        completion();
    }];
}

- (void)requestCommentList:(void(^)(void))completion{
    
    if ([PublicTool isNull:self.companyDetail.ticket]) {
        completion();
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"product" forKey:@"type"];
    [dic setValue:self.companyDetail.ticket forKey:@"ticket"];
    [dic setValue:@(1) forKey:@"page"];
    [dic setValue:@(12) forKey:@"num"];

    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/getDetailRelationList" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        NSArray *list = @[];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            self.status_Info.comment_count = [resultData[@"count"] integerValue];
            [self.sectionDataCountDic setValue:resultData[@"count"] forKey:@"用户分享"];
            list = resultData[@"list"];
            [self.commentLayouts removeAllObjects];
            for (NSDictionary *dict in list) {
                ActivityModel *model = [ActivityModel activityModelWithDict:dict];
                //                ActivityLayout *layout = [ActivityLayout layoutWithActivityModel:model];
                if (![PublicTool isNull:model.linkInfo.linkUrl]) {
                    model.linkInfo.linkTitle = @"新闻链接";
                }
                ActivityLayout *layout = [[ActivityLayout alloc] initLayoutWithActivityModel:model type:ActivityLayoutTypeCompany];
                [self.commentLayouts addObject:layout];
            }
        }
        
        completion();
    }];

}


- (void)requestStatusCountInfo:(void(^)(void))completion{
    
    if ([PublicTool isNull:self.companyDetail.company_basic.product_id]) {
        completion();
        return;
    }

    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [mDict setValue:self.companyDetail.company_basic.product_id forKey:@"project_id"];
    [mDict setValue:self.companyDetail.company_basic.product?self.companyDetail.company_basic.product:@"" forKey:@"project"];
    [mDict setValue:@"product" forKey:@"project_type"];
    
    __weak typeof(self) weakSelf = self;
    [AppNetRequest getCountOfDetailWIthParam:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDic = resultData;
            weakSelf.status_Info.like_status = [resultDic[@"like_status"] integerValue];
            weakSelf.status_Info.focus_status = [resultDic[@"focus_status"] integerValue];
            weakSelf.status_Info.like_count = [resultDic[@"like_count"] integerValue];
            weakSelf.status_Info.focus_count = [resultDic[@"focus_count"] integerValue];
//            weakSelf.status_Info.comment_count = [resultDic[@"comment_count"] integerValue];
            
            
        }
        completion();
    }];
}

- (void)requestProductApps:(void(^)(void))completion {
    if ([PublicTool isNull:self.companyDetail.company_basic.product_id]) {
        completion();
        return;
    }
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"CompanyDetail/companyApp" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSArray *arr = resultData[@"list"];
            NSMutableArray *mArr = [NSMutableArray array];
            for (NSDictionary *dict in arr) {
                if ([PublicTool isNull:dict[@"app_name"]]) {
                    continue;
                }
                [mArr addObject:dict];
                
            }
            self.apps = [NSArray arrayWithArray:mArr];
            [self.sectionDataCountDic setValue:@(mArr.count) forKey:@"App"];
        }
        completion();
    }];
}

- (void)dealRegisterMenus:(NSDictionary*)menuDic{
    if (!(menuDic && [menuDic isKindOfClass:[NSDictionary class]])) {
        return;
    }
    NSMutableArray *arr = [NSMutableArray array];
    if ([menuDic[@"basic"] integerValue] == 1) {
        [arr addObject:@"注册信息"];
    }
    
    if ([menuDic[@"gudong"] integerValue] == 1) {
        [arr addObject:@"股东信息"];
    }
    if ([menuDic[@"people"] integerValue] == 1) {
        [arr addObject:@"主要成员"];
    }
    if ([menuDic[@"invest"] integerValue] == 1) {
        [arr addObject:@"对外投资"];
    }
    if ([menuDic[@"com_icp"] integerValue] == 1) {
        [arr addObject:@"备案信息"];
    }
    if ([menuDic[@"change_record"] integerValue] == 1) {
        [arr addObject:@"变更记录"];
    }
    
    if ([menuDic[@"contact"] integerValue] == 1) {
        [arr addObject:@"联系方式"];
    }
    [self.sectionDataCountDic setValue:@(arr.count) forKey:@"工商"];
    [arr removeObject:@"联系方式"];
    self.registInfoMenusArr = arr;

}

- (void)dealTags{
    
    if (self.companyDetail.company_basic.tags_portrait.count == 0) {
        self.companyDetail.company_basic.tags = @"";
    }else{
        self.companyDetail.company_basic.tags = [NSString stringWithFormat:@"%@",[self.companyDetail.company_basic.tags_portrait componentsJoinedByString:@"|"]];
    }
    self.companyDetail.company_basic.tags = [NSString stringWithFormat:@"加画像|%@",self.companyDetail.company_basic.tags];
    
    NSArray *tags = [self.companyDetail.company_basic.tags componentsSeparatedByString:@"|"];
    
    if (self.companyDetail.company_basic.tags.length <= 5) {
        tags = @[@"加画像"];
        self.companyDetail.company_basic.tags = @"加画像";
        
    }
    
    NSMutableArray *tagsArr = [NSMutableArray array];
    
    //只显示2行
    TagsFrame *tagframe = [self getHeightFromArr:tags];
    for (int i=0; i<tagframe.tagsArray.count; i++) {
        CGRect frame = CGRectFromString(tagframe.tagsFrames[i]);
        
        if (frame.origin.y >= (12+(12+24)*2)) { //第三行y
            break;
        }
        [tagsArr addObject:tagframe.tagsArray[i]];
        
    }
    
    NSString *tagsStr = self.companyDetail.company_basic.tags;
    //有查看更多
    if (tagsArr.count < [[tagsStr componentsSeparatedByString:@"|"] count]) {
        if (!self.tagIsSpread) {

        }else{  //收起
            tagsArr = [NSMutableArray arrayWithArray:tags];
            [tagsArr addObject:@"加收起"];
        }
        
    }else{
        
    }
    
    self.tagsFrame = [self getHeightFromArr:tagsArr];
    
}


#pragma mark --交互请求

- (void)updateFoucsStatus{
    
    NSString *changeStatus = _status_Info.focus_status == 1 ? @"0":@"1";
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [mDict setValue:self.companyDetail.ticket?:@"" forKey:@"ticket"];
    [mDict setValue:self.companyDetail.company_basic.product?:@"" forKey:@"project"];
    [mDict setValue:@"product" forKey:@"type"];
    [mDict setValue:changeStatus forKey:@"work_flow"];
    
    [AppNetRequest attentFunctionWithParam:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            [PublicTool showMsg:changeStatus.integerValue == 0?@"取消关注成功":@"关注成功"];
            self.status_Info.focus_status = changeStatus.integerValue;
            self.status_Info.focus_count += (changeStatus.integerValue==0?-1:1);
            if (changeStatus.integerValue == 1) {
                [QMPEvent event:@"pro_attentBtnClick"];
            }
        }else{
            [PublicTool showMsg:changeStatus.integerValue == 0?@"取消关注失败":@"关注失败"];
        }
    }];
}


#pragma mark --Event--
- (void)enterPublishCommentPage{
    if (![PublicTool userisCliamed]) {
        return;
    }
    
    [QMPEvent event:@"pro_acvitityPublish_click"];
    PostActivityViewController *postVC = [[PostActivityViewController alloc]init];
    postVC.postFrom = PostFrom_Detail;
    postVC.company = self.companyDetail;
    [[PublicTool topViewController].navigationController pushViewController:postVC animated:YES];
   
    @weakify(self);
    postVC.postSuccessBlock = ^{
        
        @strongify(self);
        //如果发布了动态 ,重新请求动态，则刷新 refreshCommentListSignal
        [self requestCommentList:^{
            [self.refreshCommentListSignal subscribeNext:^(id  _Nullable x) {
                
            }];
        }];
    };
    
}


- (void)enterSecondPageEventTypeTitle:(NSString*)typeTitle{
    
    if ([typeTitle containsString:@"立即联系"]) {
        [self enterManagerList2];
    }else if([typeTitle containsString:@"团队"]){
        [self enterManagerList];
    }else if ([typeTitle containsString:@"业务"]){
        [self enterYwList];
    }else if ([typeTitle containsString:@"招聘"]){
        [self enterZhaopinList];
    }else if ([typeTitle containsString:@"相似项目"]){
        [self enterSimilarList];
    }else if ([typeTitle containsString:@"新闻"]){
        [self enterNewsList];
    }else if ([typeTitle containsString:@"用户分享"]){
        [self enterCommentList];
    }else if ([typeTitle containsString:@"工商"]){
        [self enterRegister];
    }else if ([typeTitle containsString:@"投资人"]){
        [self enterInvestorList];
    }else if ([typeTitle containsString:@"获奖经历"]){
        if ([self.sectionDataCountDic[@"获奖经历"] integerValue] > 5) {
            [self enterAllWinExperience];
        }
    }else if([typeTitle containsString:@"App数据"]){
        [self enterAppDataList];
    }
}

- (void)enterAllWinExperience{
    
    PersonWinExperienceVC *winVC = [[PersonWinExperienceVC alloc]init];
    winVC.productM = self.companyDetail;
    winVC.navTitleStr = [NSString stringWithFormat:@"%@获奖经历",self.companyDetail.company_basic.product];
    winVC.formType = ExperionStylePro;
    winVC.listArr = [NSMutableArray arrayWithArray:self.prizeArr];
    [[PublicTool topViewController].navigationController pushViewController:winVC animated:YES];
}

- (void)enterAppDataList{
    ProductAppListController *listVC = [[ProductAppListController alloc]init];
    listVC.appArr = self.apps;
    [[PublicTool topViewController].navigationController pushViewController:listVC animated:YES];
}

- (void)enterValueList{
    
    if ([PublicTool isNull:self.companyDetail.company_basic.product_id]) {
        return;
    }
    
    ProductValuelistController *valueVC = [[ProductValuelistController alloc]init];
    valueVC.companyTicket = self.companyDetail.ticket;
    [[PublicTool topViewController].navigationController pushViewController:valueVC animated:YES];
}

- (void)enterCommentList{
    [QMPEvent event:@"pro_acvitityall_click"];
    @weakify(self);
    [PublicTool enterActivityListControllerWithTicket:self.companyDetail.ticket type:ActivityListViewControllerTypeProduct model:self.companyDetail refresh:^{
        @strongify(self);

        //发布删除的话 动态刷新
        [self requestCommentList:^{
            [self.refreshCommentListSignal subscribeNext:^(id  _Nullable x) {
                
            }];
        }];
    }];
   
}

- (void)enterManagerList{
    if (![PublicTool userisCliamed]) {
        if ([WechatUserInfo shared].claim_type.integerValue != 1) {
            [QMPEvent event:@"pro_team_noclaim_alert"];
        }
        return;
    }
    OrganizeManagerViewController *vc = [[OrganizeManagerViewController alloc] init];
    vc.action = @"company";
    vc.requestDict = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];
    vc.companyItem = self.companyDetail.company_basic;
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
    [QMPEvent event:@"pro_team_seeAll"];
}

- (void)enterManagerList2{
    
    MemberContactViewController *vc = [[MemberContactViewController alloc] init];
    vc.action = @"company";
    vc.requestDict = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];
    vc.companyItem = self.companyDetail.company_basic;    
    vc.companyDetail = self.companyDetail;
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
    [QMPEvent event:@"pro_team_seeAll"];
}


/**
 进入工商信息
 */
- (void)enterRegister{
    
    RegisterInfoViewController *registerDetailVC = [[RegisterInfoViewController alloc]init];
    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];
    [mdic removeObjectForKey:@"id"];
    [mdic removeObjectForKey:@"p"];
    registerDetailVC.urlDict = mdic;
    registerDetailVC.companyName = self.companyDetail.company_basic.company&&![self.companyDetail.company_basic.company isEqualToString:@""] ? self.companyDetail.company_basic.company:@"";
    
    [[PublicTool topViewController].navigationController pushViewController:registerDetailVC animated:YES];

}


/**
 进入公司新闻列表
 */
- (void)enterNewsList{
    
    OneSourceViewController *newsVC = [[OneSourceViewController alloc]init];
    newsVC.action = @"CompanyView";
    newsVC.newsMArr = [NSMutableArray arrayWithArray:self.companyDetail.news];
    newsVC.requestDict = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];
    newsVC.companyItem = self.companyDetail.company_basic;
    [[PublicTool topViewController].navigationController pushViewController:newsVC animated:YES];
    [QMPEvent event:@"pro_news_seeAll"];
}

/**
 进入招聘列表
 */
- (void)enterZhaopinList{
    
    CompanyZhaopinController *zhaopinVC = [[CompanyZhaopinController alloc]init];
    zhaopinVC.isProduct = YES;
    zhaopinVC.requestDict = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];
    [[PublicTool topViewController].navigationController pushViewController:zhaopinVC animated:YES];

}
/*
 进如投资人列表
 */
- (void)enterInvestorList{
    
    if ([WechatUserInfo shared].claim_type.integerValue != 2) {
        [PublicTool showMsg:@"仅认证用户才有此权限"];
        return;
    }
    
    SearchCompanyModel *company = [[SearchCompanyModel alloc] init];
    company.product = self.companyDetail.company_basic.product;
    company.productId = self.companyDetail.company_basic.product_id;
    company.icon = self.companyDetail.company_basic.icon;
    company.company = self.companyDetail.company_basic.company;
    company.yewu = self.companyDetail.company_basic.yewu;
    company.lunci = self.companyDetail.company_basic.lunci;
    company.allipo = self.companyDetail.company_basic.allipo;
    company.need_flag = self.companyDetail.company_basic.need_flag;
    CompanyInvestorsController *investorVC = [[CompanyInvestorsController alloc]init];
    investorVC.companyModel = company;
    investorVC.ticket = self.companyDetail.ticket;
    [[PublicTool topViewController].navigationController pushViewController:investorVC animated:YES];

}

/**
 进入相似项目列表
 */
- (void)enterSimilarList{
    
    CompanySimilarViewController *similarVC = [[CompanySimilarViewController alloc] init];
    
    similarVC.tagArr = [NSMutableArray arrayWithArray:self.tagsMatchMArr];
    similarVC.requestDict = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];
    similarVC.companyItem = self.companyDetail.company_basic;
    similarVC.refreshCompanySimilarInfoBlock = ^(NSMutableArray *tableData){
        
    };
    [[PublicTool topViewController].navigationController pushViewController:similarVC animated:YES];
    [QMPEvent event:@"enterSimilarList"];

}

/**
 进入公司业务列表
 */
- (void)enterYwList{
    
    CompanyProductionViewController *pVC = [[CompanyProductionViewController alloc] init];
    pVC.companyTicket = self.companyDetail.ticket;
    [[PublicTool topViewController].navigationController pushViewController:pVC animated:YES];
    [QMPEvent event:@"pro_product_seeAll"];

}

- (TagsFrame *)getHeightFromArr:(NSArray *)tagsArr{
    
    TagsFrame *frame = [[TagsFrame alloc] init];
    if (tagsArr.count>0) {
        
        frame.tagsArray = tagsArr;
        
    }
    return frame;
}


#pragma mark ---懒加载

- (NSMutableArray *)tagsMatchMArr{
    
    if (!_tagsMatchMArr) {
        _tagsMatchMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _tagsMatchMArr;
}
- (NSMutableArray *)commentLayouts{
    
    if (!_commentLayouts) {
        _commentLayouts = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _commentLayouts;
}

-(NSMutableArray *)workTagArr{
    if (!_workTagArr) {
        _workTagArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _workTagArr;
}

-(NSMutableArray *)investorsArr{
    if (!_investorsArr) {
        _investorsArr = [NSMutableArray array];
    }
    return _investorsArr;
}

-(NSMutableDictionary *)sectionDataCountDic{
    if (!_sectionDataCountDic) {
        _sectionDataCountDic = [NSMutableDictionary dictionary];
    }
    return _sectionDataCountDic;
}

@end
