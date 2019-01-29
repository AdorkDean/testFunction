//
//  PersonDetailViewModel.m
//  qmp_ios
//
//  Created by QMP on 2018/6/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonDetailViewModel.h"
#import "BPDeliverController.h"
#import "AlertActionView.h"
#import "EditInfoViewController.h"
#import "TouziLingyuController.h"
#import "EditWinExpeController.h"
#import "ZhuTouJieduanController.h"
#import "EditExprienceController.h"
#import "SearchComController.h"
#import "SearchProRegisterModel.h"
#import "InvestorNewsController.h"
#import "PersonWinExperienceVC.h"
#import "InvestorTzCaseController.h"
#import "WinExperienceModel.h"
#import "ActivityModel.h"
#import "PostActivityViewController.h"
#import "PersonRoleModel.h"
#import "PersonAllBusinessRoleController.h"

@interface PersonDetailViewModel()
@property(nonatomic,copy) NSString *lingyu;
@property(nonatomic,copy) NSString *jieduan;
@property(nonatomic,strong) NSArray *tzanli;
@property(nonatomic,strong) NSArray *faanli;



@property(nonatomic,readwrite) RACSignal *requestPersonDetailSignal;
@property(nonatomic,readwrite) RACSignal *requestCommentListSignal;

@end

@implementation PersonDetailViewModel

- (instancetype)init{
    if (self = [super init]) {
        self.status_Info = [[CountAndStatusModel alloc]init];
    }
    return self;
}


#pragma mark --信号
@synthesize requestFinishSignal = _requestFinishSignal;
-(RACSignal *)requestFinishSignal{
    if (!_requestFinishSignal) {
        @weakify(self);
        _requestFinishSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            
            RACSignal *requestDetailSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                [self requestPersonDetail:^{
                    [subscriber sendNext:nil];
                    [subscriber sendCompleted];
                }]; //请求详情
                return nil;
            }];
            
            //投资案例
            RACSignal *requestTouziSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                [self requestPersonTzInfo:^{
                    [subscriber sendNext:nil];
                }]; //投资案例
                return nil;
            }];
            
            //投资案例
            RACSignal *requestFASignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                [self requestPersonFAInfo:^{
                    [subscriber sendNext:nil];
                }]; //投资案例
                return nil;
            }];
            
            RACSignal *requestCommentSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                [self requestCommentList:^{
                    [subscriber sendNext:nil];
                }]; //请求用户分享
                return nil;
            }];
            
            RACSignal *requestAllCompany = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                [self requestAllCompany:^{
                    [subscriber sendNext:nil];
                }];
                return nil;
            }];
            RACSignal *zipSignal = [requestAllCompany zipWith:requestCommentSignal];
            RACSignal *detailSignal = [requestDetailSignal then:^RACSignal * _Nonnull{
                return zipSignal;
            }];
            
            RACSignal *detailTz = [detailSignal zipWith:requestTouziSignal];
            RACSignal *finishSignal  = [detailTz zipWith:requestFASignal];
            
            [finishSignal subscribeNext:^(id  _Nullable x) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                
            }];
            
            return nil;
        }];
    }
    
    return _requestFinishSignal;
}

@synthesize requestStatusSignal = _requestStatusSignal;
-(RACSignal *)requestStatusSignal{
    if (!_requestStatusSignal) {
        @weakify(self)
        _requestStatusSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self requestStatusCountInfo:^{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];

            }];
            return nil;
        }];
    }
    return _requestStatusSignal;
}

//更新tagsFrame
@synthesize updateTagsFrameSignal = _updateTagsFrameSignal;
-(RACSignal *)updateTagsFrameSignal{
    if (!_updateTagsFrameSignal) {
        @weakify(self)
        _updateTagsFrameSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self dealTags];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }
    return _updateTagsFrameSignal;
}


#pragma mark --Command---

@synthesize updateAttentStatusCommand = _updateAttentStatusCommand;
-(RACCommand *)updateAttentStatusCommand{
    if (!_updateAttentStatusCommand) {
        
        @weakify(self)
        _updateAttentStatusCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return
            [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self updateFoucsStatus:^{
                    [subscriber sendNext:nil];
                    [subscriber sendCompleted];
                }];
                return nil;
            }];        }];
    }
    return _updateAttentStatusCommand;
}



@synthesize sectionHeaderBtnCommand = _sectionHeaderBtnCommand;
-(RACCommand *)sectionHeaderBtnCommand{
    if (!_sectionHeaderBtnCommand) {
        
        @weakify(self)
        _sectionHeaderBtnCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self);
            [self sectionHeaderBtnClickWithheaderInfoDic:input];
            return [RACSignal empty];

        }];
    }
    return _sectionHeaderBtnCommand;
}

@synthesize cellEditCommand = _cellEditCommand;
-(RACCommand *)cellEditCommand{
    if (!_cellEditCommand) {
        
        @weakify(self)
        _cellEditCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self);
            [self cellEditClickWithModel:input];
            return [RACSignal empty];

        }];
    }
    return _cellEditCommand;
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



#pragma mark --网络请求
- (void)requestPersonDetail:(void(^)(void))completion{
    if ([PublicTool isNull:self.personId]) {
        completion();
        return;
    }

    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.personId,@"person_id", nil];
    
    [AppNetRequest personDetailWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData && [resultData[@"list"] isKindOfClass:[NSDictionary class]]) {
            
            PersonModel *person = [[PersonModel alloc]initWithDictionary:resultData[@"list"] error:nil];
            person.personId = self.personId;
            for (ZhiWeiModel *zhiwei in person.work_exp) {
                zhiwei.old_type = zhiwei.type; //记录工作经历 旧的type
                zhiwei.name = zhiwei.company ? : zhiwei.product;
            }
            self.person = person;
            BOOL isMy = [person.personId isEqualToString:[WechatUserInfo shared].person_id] ;
            NSString *content = [PublicTool isNull:person.jieshao] ? (isMy?@"":@"无自我介绍"):person.jieshao;
            self.introduceInfoDic = [NSMutableDictionary dictionaryWithDictionary:@{@"content":content,@"spread":@(NO)}];
            self.introduceCellLayout = [[IntroduceCellLayout alloc]initWithIntroduce:self.introduceInfoDic];
//            [self dealTags];
            [self.requestStatusSignal subscribeNext:^(id  _Nullable x) {
                
            }];
            [self extractBasicInfo]; //抽取基本信息
            
            if (self.lingyu) {
                self.person.tzanli1 = self.tzanli;
                self.person.lingyu = self.lingyu;
                self.person.jieduan = self.jieduan;
                self.tzlyFrame = [self getTZPreferences:(NSString*)self.person.lingyu lingyu:YES];
                self.jtjdFrame = [self getTZPreferences:(NSString*)self.person.jieduan lingyu:NO];
            }
            if (self.faanli) {
                self.person.faanli = self.faanli;
            }
        }
        completion();
        
    }];
}

- (void)requestAllCompany:(void(^)(void))completion{
    
    if ([PublicTool isNull:self.person.uniq_hid]) {
        completion();
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.person.uniq_hid,@"uniq_hid", nil];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"person/personRegister" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                [arr addObject:[[PersonRoleModel alloc]initWithDictionary:dic error:nil]];
            }
            self.allCompany = arr;
            self.allCompanyCount = [resultData[@"count"] integerValue];
        }
        completion();
    }];
}

- (void)requestPersonTzInfo:(void(^)(void))completion{
    if ([PublicTool isNull:self.personId]) {
        completion();
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.personId,@"person_id", nil];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"person/personInvestInfo" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && [resultData[@"list"] isKindOfClass:[NSDictionary class]]) {
            
            self.lingyu = resultData[@"list"][@"lingyu"];
            self.jieduan = resultData[@"list"][@"jieduan"];
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"][@"tzanli"]) {
                [arr addObject:[[PersonTouziModel alloc]initWithDictionary:dic error:nil]];
            }
            self.tzanli = arr;
            if (self.person) {
                self.person.tzanli1 = self.tzanli;
                self.person.lingyu = self.lingyu;
                self.person.jieduan = self.jieduan;
                self.tzlyFrame = [self getTZPreferences:(NSString*)self.person.lingyu lingyu:YES];
                self.jtjdFrame = [self getTZPreferences:(NSString*)self.person.jieduan lingyu:NO];
            }
        }
        completion();
    }];

}

- (void)requestPersonFAInfo:(void(^)(void))completion{
    if ([PublicTool isNull:self.personId]) {
        completion();
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.personId,@"person_id", nil];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"person/personFaCases" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                [arr addObject:[[PersonTouziModel alloc]initWithDictionary:dic error:nil]];
            }
            self.faanli = arr;
            if (self.person) {
                self.person.faanli = self.faanli;
            }
        }
        completion();
    }];
    
}


- (void)requestCommentList:(void(^)(void))completion{

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:@"1" forKey:@"page"];
    [paramDict setValue:@"12" forKey:@"num"];
    [paramDict setValue:self.person.ticket forKey:@"ticket"];

    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/getPersonReleaseList" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        NSArray *list = @[];
        if (resultData) {
            list = resultData[@"list"];
            self.status_Info.comment_count = [resultData[@"count"] integerValue];
            [self.commentLayouts removeAllObjects];
            for (NSDictionary *dict in list) {
                ActivityModel *model = [ActivityModel personVCactivityModelWithDict:dict ticket:self.person.ticket];
                if (![PublicTool isNull:model.linkInfo.linkUrl]) {
                    model.linkInfo.linkTitle = @"新闻链接";
                }
                ActivityLayout *layout = [[ActivityLayout alloc] initLayoutWithActivityModel:model type:ActivityLayoutTypePerson];
                [self.commentLayouts addObject:layout];
            }
        }
        
        completion();
    }];
}

- (void)updateFoucsStatus:(void(^)(void))completion{
    if ([[WechatUserInfo shared].person_id isEqualToString:self.personId]) {
        [PublicTool showMsg:@"您不能关注自己"];
        return;
    }
    
    if ([PublicTool isNull:self.person.ticket]) {
        return;
    }
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setValue:self.person.ticket forKey:@"ticket"];
    [dic setValue:self.person.name?self.person.name:@"" forKey:@"project"];
    NSString *changeStatus = _status_Info.focus_status == 1 ? @"0":@"1";
    [dic setValue:changeStatus forKey:@"work_flow"];
    [dic setValue:@"person" forKey:@"type"];
    
    [AppNetRequest attentFunctionWithParam:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            [PublicTool showMsg:changeStatus.integerValue == 0?@"取消关注成功":@"关注成功"];
            self.status_Info.focus_status = changeStatus.integerValue;
            self.status_Info.focus_count += (changeStatus.integerValue==0?-1:1);
        }else{
            [PublicTool showMsg:changeStatus.integerValue == 0?@"取消关注失败":@"关注失败"];
        }
        completion();
    }];
    
}

//提交用户数据  基本信息、主投阶段、投资领域
- (void)submitInfoWithKey:(NSString*)key  value:(NSString*)value{
    
    [PublicTool showHudWithView:KEYWindow];
    NSDictionary *param = @{@"person_id":self.personId,@"field":key,@"value":value};
    
    [AppNetRequest submitPersonInfoOfDetailWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        
        if ([resultData[@"msg"] isEqualToString:@"success"]) {
            [PublicTool showMsg:@"修改成功"];

            [self.refreshDataSignal subscribeNext:^(id  _Nullable x) {

            }];
            
        }else{
            [PublicTool showMsg:@"修改失败"];
            
        }
        
    }];
}

- (void)submitWithTouzianli:(PersonTouziModel*)model submitFlag:(NSString*)flag{
    
    [PublicTool showHudWithView:KEYWindow];
    if ((self.person.tzanli.length>2) && [[self.person.tzanli substringFromIndex:self.person.tzanli.length-1] containsString:@"|"]) {
        self.person.tzanli = [self.person.tzanli substringToIndex:self.person.tzanli.length-1];
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.person.personId,@"person_id",flag,@"op_flag",model.product,@"tzanli", nil];
    [paramDic setValue:[PublicTool isNull:model.tzlunci]?@"":model.tzlunci forKey:@"tzlunci"];
    [paramDic setValue:[PublicTool isNull:model.hangye]?@"":model.hangye forKey:@"hangye"];
    [paramDic setValue:[PublicTool isNull:model.hangye]?@"":model.hangye forKey:@"hangye"];
    [paramDic setValue:self.person.tzanli forKey:@"cases"];
    
    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/modifyInvestCase" HTTPBody:paramDic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            NSString *showMsg = flag.integerValue == 1 ? @"添加成功":@"删除成功";
            
            [PublicTool showMsg:showMsg];
        }
        [self.refreshDataSignal subscribeNext:^(id  _Nullable x) {
            
        }];
    }];
}


- (void)submitWinExperience:(WinExperienceModel*)experienceM  submitFlag:(NSString*)flag {
    
    [PublicTool showHudWithView:KEYWindow];
    
    unsigned int count = 0;
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.person.personId,@"person_id",flag,@"flag", nil];
    objc_property_t *properties = class_copyPropertyList([experienceM class], &count);
    for (int i = 0; i < count; i++) {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        id propertyValue = [experienceM valueForKey:propertyName];
        if (propertyValue) {
            [paramDic setValue:propertyValue forKey:propertyName];
        }
    }
    free(properties);
    
    if ([self.person.win_experience containsObject:experienceM]) {
        [paramDic setValue:experienceM.winExId forKey:@"id"];
    }
    
    if (flag.integerValue == 0 || flag.integerValue == 1) { //添加或编辑
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/addWinexp" HTTPBody:paramDic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [PublicTool dismissHud:KEYWindow];
            
            if (resultData && [resultData[@"message"] isEqualToString:@"success"]) {
                
                NSString *showMsg = flag.integerValue == 0 ? @"添加成功":(flag.integerValue == 1 ? @"修改成功":@"删除成功");
                [PublicTool showMsg:showMsg];
                
            }else{
                
                [PublicTool showMsg:REQUEST_ERROR_TITLE];
            }
            [self.refreshDataSignal subscribeNext:^(id  _Nullable x) {
                
            }];
            
        }];
        
    }else{ //删除
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/delWinexp" HTTPBody:paramDic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            if (resultData && [resultData[@"message"] isEqualToString:@"success"]) {
                
                NSString *showMsg = @"删除成功";
                [PublicTool showMsg:showMsg];
                
            }else{
                
                [PublicTool showMsg:REQUEST_ERROR_TITLE];
            }
        }];
        [self.refreshDataSignal subscribeNext:^(id  _Nullable x) {
            
        }];
        
    }
    
    
}

- (void)submitWorkExperience:(ZhiWeiModel*)zhiwei  submitFlag:(NSString*)flag{
    
    [PublicTool showHudWithView:KEYWindow];
    zhiwei.company = zhiwei.name;
    unsigned int count = 0;
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.personId,@"person_id",flag,@"flag", nil];
    objc_property_t *properties = class_copyPropertyList([zhiwei class], &count);
    for (int i = 0; i < count; i++) {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        id propertyValue = [zhiwei valueForKey:propertyName];
        if (propertyValue) {
            [paramDic setValue:propertyValue forKey:propertyName];
        }
    }
    free(properties);
    
    if ([self.person.work_exp containsObject:zhiwei]) {
        [paramDic setValue:zhiwei.zhiweiId forKey:@"id"];
    }
    
    [AppNetRequest submitPersonWorkOfDetailWithParameter:paramDic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            
            NSString *showMsg = flag.integerValue == 0 ? @"添加成功":(flag.integerValue == 1 ? @"修改成功":@"删除成功");
            [PublicTool showMsg:showMsg];
            
        }else{
            
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
        [self.refreshDataSignal subscribeNext:^(id  _Nullable x) {
            
        }];
    }];
}

- (void)submitEducationExperience:(EducationExpModel*)edu_experience submitFlag:(NSString*)flag {
    
    [PublicTool showHudWithView:KEYWindow];
    unsigned int count = 0;
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.personId,@"person_id",flag,@"flag", nil];
    objc_property_t *properties = class_copyPropertyList([edu_experience class], &count);
    for (int i = 0; i < count; i++) {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        id propertyValue = [edu_experience valueForKey:propertyName];
        if (propertyValue) {
            [paramDic setValue:propertyValue forKey:propertyName];
        }
    }
    free(properties);
    
    if ([self.person.edu_exp containsObject:edu_experience]) {
        [paramDic setValue:edu_experience.educationId forKey:@"id"];
    }
    
    [AppNetRequest submitPersonEducationOfDetailWithParameter:paramDic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            
            NSString *showMsg = flag.integerValue == 0 ? @"添加成功":(flag.integerValue == 1 ? @"修改成功":@"删除成功");
            [PublicTool showMsg:showMsg];
            
        }else{
            
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
        [self.refreshDataSignal subscribeNext:^(id  _Nullable x) {
            
        }];
        
    }];
}


#pragma mark --Event--
- (void)enterPublishCommentPage{
    if (![PublicTool userisCliamed]) {
        return;
    }
    PostActivityViewController *postVC = [[PostActivityViewController alloc]init];
    postVC.postFrom = PostFrom_Detail;
    @weakify(self);
    postVC.postSuccessBlock = ^{
        //如果发布了用户分享 ,重新请求用户分享，则刷新 refreshCommentListSignal
        [self requestCommentList:^{
            @strongify(self);
            [self.refreshCommentSignal subscribeNext:^(id  _Nullable x) {
                
            }];
        }];
    };
    if (![[WechatUserInfo shared].person_id isEqualToString:self.person.person_id]) {
        postVC.person = self.person;
    }
    
    [[PublicTool topViewController].navigationController pushViewController:postVC animated:YES];

}


- (void)addWinExperience{
    
    EditWinExpeController *winExVC = [[EditWinExpeController alloc]init];
    __weak typeof(self) weakSelf = self;
    winExVC.saveInfoSuccess = ^(id newExperienceM) {
        [weakSelf submitWinExperience:newExperienceM submitFlag:@"0"];
    };
    [[PublicTool topViewController].navigationController pushViewController:winExVC animated:YES];
    
}

- (void)addEducationExperience{
    
    EditExprienceController *editVC = [[EditExprienceController alloc]init];
    editVC.fromView = FromView_PersonDetail;
    editVC.isJob = NO;
    __weak typeof(self) weakSelf = self;
    editVC.saveInfoSuccess = ^(id newExperienceM) {
        [weakSelf submitEducationExperience:newExperienceM submitFlag:@"0"];
    };
   
    [[PublicTool topViewController].navigationController pushViewController:editVC animated:YES];
    
}

- (void)addWorkExperience{
    
    EditExprienceController *editVC = [[EditExprienceController alloc]init];
    editVC.fromView = FromView_PersonDetail;
    editVC.isJob = YES;
    __weak typeof(self) weakSelf = self;
    editVC.saveInfoSuccess = ^(id newExperienceM) {
        
        [weakSelf submitWorkExperience:newExperienceM submitFlag:@"0"];
    };
    
    [[PublicTool topViewController].navigationController pushViewController:editVC animated:YES];
}

- (void)addTouziAnli{
    
    SearchComController *searchComVC = [[SearchComController alloc]init];
    searchComVC.isCompany = YES;
    searchComVC.isTouziCase = YES;
    __weak typeof(self) weakSelf = self;
    
    searchComVC.didSelected = ^(id selectedObject) {
        
        PersonTouziModel *model = [[PersonTouziModel alloc]init];
        if ([selectedObject isKindOfClass:[SearchCompanyModel class]]) {
            
            SearchCompanyModel *company = selectedObject;
            model.product = company.product;
            model.tzlunci = company.tzLunci;
            model.hangye = company.hangye1;
            
        }else if([selectedObject isKindOfClass:[NSString class]]){
            model.product = selectedObject;
            
        }else if([selectedObject isKindOfClass:[SearchProRegisterModel class]]){
            SearchProRegisterModel *registM = selectedObject;
            model.product = registM.company;
        }
        if (![PublicTool isNull:model.product]) {
            NSMutableString *touziStr = [NSMutableString string];
            for (PersonTouziModel *touzM in self.person.tzanli1) {
                [touziStr appendFormat:@"%@|",touzM.product];
            }
            [touziStr appendString:model.product];
            self.person.tzanli = touziStr;
            [weakSelf submitWithTouzianli:model submitFlag:@"1"];
        }
        
    };
   
    [[PublicTool topViewController].navigationController pushViewController:searchComVC animated:YES];
}

- (void)updatePersonJieshao{
    EditInfoViewController *editInfo = [[EditInfoViewController alloc]init];
    
    editInfo.key = @"无自我介绍";
    editInfo.value = self.person.jieshao;
    __weak typeof(self) weakSelf = self;
    editInfo.sureBtnClick = ^(NSString *value) {
        weakSelf.person.jieshao = value;
        [weakSelf submitInfoWithKey:@"jieshao" value:value];
    };
    
    [[PublicTool topViewController].navigationController pushViewController:editInfo animated:YES];
    
}

- (void)updateTouZiLingyu{
    TouziLingyuController *lingyuVC = [[TouziLingyuController alloc]init];
    NSString *lingyu = (NSString*)self.person.lingyu;
    lingyuVC.originalLingyu = lingyu;
    __weak typeof(self) weakSelf = self;
    lingyuVC.selectedLingyu = ^(NSString *lingyuStr) {
        weakSelf.person.lingyu = lingyuStr;
        weakSelf.tzlyFrame = [weakSelf getTZPreferences:(NSString*)weakSelf.person.lingyu lingyu:YES];
        [weakSelf submitInfoWithKey:@"lingyu" value:lingyuStr];
    };
    
    [[PublicTool topViewController].navigationController pushViewController:lingyuVC animated:YES];
}

- (void)updateZhuToujieduan{
    ZhuTouJieduanController *jieduanVC = [[ZhuTouJieduanController alloc]init];
    jieduanVC.originalJieduan = (NSString*)self.person.jieduan;
    __weak typeof(self) weakSelf = self;
    jieduanVC.selectedJieDuan = ^(NSString *jieduanStr) {
        weakSelf.person.jieduan = jieduanStr;
        weakSelf.jtjdFrame = [weakSelf getTZPreferences:(NSString*)weakSelf.person.jieduan lingyu:NO];
        [weakSelf submitInfoWithKey:@"jieduan" value:jieduanStr];
    };
   
    [[PublicTool topViewController].navigationController pushViewController:jieduanVC animated:YES];
}

- (void)touziLiDelete:(PersonTouziModel*)touziM{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.person.tzanli1];
    PersonTouziModel *touzi = touziM;
    [arr removeObject:touzi];
    NSMutableString *touziStr = [NSMutableString string];
    for (PersonTouziModel *touzM in arr) {
        [touziStr appendFormat:@"%@|",touzM.product];
    }
    
    self.person.tzanli = touziStr;
    [self submitWithTouzianli:touzi submitFlag:@"2"];
}

- (void)editWinExperience:(WinExperienceModel*)winExperienceM{
    
    EditWinExpeController *editWinVC = [[EditWinExpeController alloc]init];
    editWinVC.experienceM = winExperienceM;
    
    __weak typeof(self) weakSelf = self;
    editWinVC.saveInfoSuccess = ^(id newExperienceM) {
        [weakSelf submitWinExperience:newExperienceM submitFlag:@"1" ];
    };
    editWinVC.delInfoSuccess = ^(id newExperienceM) {
        [weakSelf submitWinExperience:newExperienceM submitFlag:@"2"];
    };
    
    [[PublicTool topViewController].navigationController pushViewController:editWinVC animated:YES];
}


- (void)editWorkExperience:(ZhiWeiModel*)experience{
    
    EditExprienceController *editInfoVC = [[EditExprienceController alloc]init];
    editInfoVC.isJob = YES;
    editInfoVC.fromView = FromView_PersonDetail;
    editInfoVC.experienceM = experience;
    __weak typeof(self) weakSelf = self;
    editInfoVC.saveInfoSuccess = ^(id newExperienceM) {
        [weakSelf submitWorkExperience:newExperienceM submitFlag:@"1" ];
    };
    editInfoVC.delInfoSuccess = ^(id newExperienceM) {
        [weakSelf submitWorkExperience:newExperienceM submitFlag:@"2"];
        
    };
   
    [[PublicTool topViewController].navigationController pushViewController:editInfoVC animated:YES];
}

- (void)editSchoolExperience:(EducationExpModel*)experience{
    
    EditExprienceController *editInfoVC = [[EditExprienceController alloc]init];
    editInfoVC.isJob = NO;
    editInfoVC.fromView = FromView_PersonDetail;
    editInfoVC.experienceM = experience;
    __weak typeof(self) weakSelf = self;
    editInfoVC.saveInfoSuccess = ^(id newExperienceM) {
        [weakSelf submitEducationExperience:newExperienceM submitFlag:@"1"];
    };
    editInfoVC.delInfoSuccess = ^(id newExperienceM) {
        [weakSelf submitEducationExperience:newExperienceM submitFlag:@"2"];
    };
   
    [[PublicTool topViewController].navigationController pushViewController:editInfoVC animated:YES];
}

- (void)sectionHeaderBtnClickWithheaderInfoDic:(NSDictionary*)sectionInfo{
    
    //标题和类型 type：all全部  edit编辑
    NSString *title = sectionInfo[@"title"];
    NSString *type = sectionInfo[@"type"];
    if (!type) {
        return;
    }
    BOOL isEdit = [type isEqualToString:@"edit"]  ?  YES:NO;
    
    if ([title isEqualToString:@"自我介绍"]) {
        [self updatePersonJieshao];
    }else if ([title isEqualToString:@"投资领域"]) {
        [self updateTouZiLingyu];
    }else if ([title isEqualToString:@"主投阶段"]) {
        [self updateZhuToujieduan];
    }else if ([title isEqualToString:@"投资案例"]) {
        if (isEdit) {
            [self addTouziAnli];
            return;
        }else{
            [self enterTzCase];
            return;
        }
    }else if([title isEqualToString:@"服务案例"]) {
        [self enterFaCase];
    }else if ([title isEqualToString:@"工作经历"]) {
        [self addWorkExperience];
    }else if ([title isEqualToString:@"教育经历"]) {
        [self addEducationExperience];
    }else if ([title isEqualToString:@"获奖经历"]) {
        if (isEdit) {
            [self addWinExperience];
        }else{
            [self enterAllWinExperience];
            return;
        }
    }else if([title isEqualToString:@"人物新闻"]){
        [self enterPersonNews];
    }else if([title containsString:@"用户分享"]){
        [self enterCommentList];
    }else if([title containsString:@"商业关系"]){
        [self enterAllCompanyList];
    }
}


- (void)cellEditClickWithModel:(id)editModel{
    
    if ([editModel isKindOfClass:[ZhiWeiModel class]]) {
        [self editWorkExperience:editModel];
    }else if ([editModel isKindOfClass:[WinExperienceModel class]]) {
        [self editWinExperience:editModel];
    }else if ([editModel isKindOfClass:[EducationExpModel class]]) {
        [self editSchoolExperience:editModel];
    }else if ([editModel isKindOfClass:[PersonTouziModel class]]) {
        [self touziLiDelete:editModel];
    }
}


- (void)deliverBPCommandExecute{
    
    [PublicTool showHudWithView:KEYWindow];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"f/getUserAuthCount" HTTPBody:@{} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData) {
            
            NSString *haveGetCount = resultData[@"deliverbp_count"]; //已经发的次数
            NSString *leftCount = resultData[@"left_deliverbp_count"];  //剩余次数
            NSString *message;
            
            if (!leftCount || leftCount.intValue == 0) {
                message = @"今日可投递BP次数已用完";
                NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:message];
                [attText addAttributes:@{NSForegroundColorAttributeName:RED_TEXTCOLOR} range:NSMakeRange(message.length-3, 3)];
                NSMutableAttributedString *tipInfo = [[NSMutableAttributedString alloc]initWithString:@"请移步http://vip.qimingpian.com继续投递"];
                [tipInfo addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:NSMakeRange(3,tipInfo.length - 7)];
                [AlertActionView alertViewWithMessage:attText tipInfo:tipInfo sureBtnAction:^{
                    
                } sureBtnEnabled:NO];
                
                
            }else{
                message = [NSString stringWithFormat:@"每日可投递BP %ld次",haveGetCount.integerValue+leftCount.integerValue];
                NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:message];
                NSMutableAttributedString *tipInfo = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"剩余%@次",leftCount]];
                [tipInfo addAttributes:@{NSForegroundColorAttributeName:RED_TEXTCOLOR} range:NSMakeRange(2 ,tipInfo.length - 3)];
                [AlertActionView alertViewWithMessage:attText tipInfo:tipInfo cancelBtnAction:^{
                } sureBtnAction:^{
                    [self sureDeliverBtnClick];
                } sureBtnEnabled:YES];
                
            }
            
        }else{
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
    
}

- (void)sureDeliverBtnClick{
    
    BPDeliverController *selectVC = [[BPDeliverController alloc]init];
    selectVC.personId = self.personId;
    @weakify(self);
    selectVC.selectedBP = ^(ReportModel *report) {
        @strongify(self);
        [self deliverBPEvent:report];
    };
   
    [[PublicTool topViewController].navigationController pushViewController:selectVC animated:YES];
}

- (void)deliverBPEvent:(ReportModel*)report{
    
    if ([PublicTool isNull:report.pdfUrl]) {
        [PublicTool showMsg:@"BP数据错误"];
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:report.name forKey:@"bp_name"];
    [param setValue:report.pdfUrl forKey:@"bp_link"];
    [param setValue:[PublicTool isNull:report.size]?@"":report.size forKey:@"size"];
    
    if (report.isMy) {
        [param setValue:report.reportId forKey:@"fileid"];
    }else{
        [param setValue:report.fileid forKey:@"fileid"]; //收到的BP
    }
    
    [param setValue:self.person.name forKey:@"huoyue_name"];
    [param setValue:self.person.personId forKey:@"huoyue_id"];
    [param setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
    [param setValue:report.product?report.product:@"" forKey:@"product"];
    
    QMPLog(@"投递BP----------%@",report.name);
    [AppNetRequest deliverBPToInvestorWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData[@"msg"] isKindOfClass:[NSString class]] && [resultData[@"msg"] isEqualToString:@""]) {
            [PublicTool showMsg:@"投递成功"];
        }else{
            if ([PublicTool isNull:resultData[@"msg"]]) {
                [PublicTool showMsg:REQUEST_ERROR_TITLE];
            }else{
                [PublicTool showMsg:resultData[@"msg"]];
                
            }
        }
    }];
}


- (void)enterAllWinExperience{
    
    PersonWinExperienceVC *winVC = [[PersonWinExperienceVC alloc]init];
    winVC.person = self.person;
    winVC.navTitleStr = [NSString stringWithFormat:@"%@获奖经历",self.person.name];
    winVC.formType = ExperionStylePerson;
    winVC.listArr = [NSMutableArray arrayWithArray:self.person.win_experience];
    [[PublicTool topViewController].navigationController pushViewController:winVC animated:YES];
}

- (void)enterTzCase{
    
    InvestorTzCaseController *tzcaseVC = [[InvestorTzCaseController alloc]init];
    tzcaseVC.person = self.person;
    tzcaseVC.listArr = [NSMutableArray arrayWithArray:self.person.tzanli1];
    tzcaseVC.title = @"投资案例";
    [[PublicTool topViewController].navigationController pushViewController:tzcaseVC animated:YES];
    [QMPEvent event:@"person_tacase_seeAll"];
}

- (void)enterFaCase{
    
    InvestorTzCaseController *tzcaseVC = [[InvestorTzCaseController alloc]init];
    tzcaseVC.person = self.person;
    tzcaseVC.listArr = [NSMutableArray arrayWithArray:self.person.faanli];
    tzcaseVC.title = @"服务案例";
    [[PublicTool topViewController].navigationController pushViewController:tzcaseVC animated:YES];
    [QMPEvent event:@"person_tacase_seeAll"];
}

// 跳用户分享列表
- (void)enterCommentList{
    
    @weakify(self);

    [PublicTool enterActivityListControllerWithTicket:self.person.ticket type:ActivityListViewControllerTypePerson model:nil refresh:^{
        
        [self requestCommentList:^{
            @strongify(self);
            [self.refreshCommentSignal subscribeNext:^(id  _Nullable x) {
                
            }];
        }];
    }];
    
  
}

- (void)enterAllCompanyList{
    
    PersonAllBusinessRoleController *roleVC = [[PersonAllBusinessRoleController alloc] init];
    roleVC.personID = self.person.uniq_hid;
    roleVC.personModel = self.person;
    [[PublicTool topViewController].navigationController pushViewController:roleVC animated:YES];
    [QMPEvent event:@"person_sygx_allroleClick"];
}


- (void)enterPersonNews{
    
    InvestorNewsController *newsVC = [[InvestorNewsController alloc]init];
    newsVC.person = self.person;
    newsVC.listArr = [NSMutableArray arrayWithArray:self.person.person_news];
    [[PublicTool topViewController].navigationController pushViewController:newsVC animated:YES];
    [QMPEvent event:@"person_news_seeAll"];
   
}

- (void)extractBasicInfo{
    
    self.personBasicInfo = [NSMutableDictionary dictionary];
    
    NSString *company;
    NSString *zhiwu;
    ZhiWeiModel *zhiwei;
    if (self.person.work_exp.count) {
        zhiwei = self.person.work_exp[0];
        company = zhiwei.product;
        zhiwu = zhiwei.zhiwu;
    }else{
        company = @"-";
        zhiwu = @"-";
    }
    
    [self.personBasicInfo setValue:self.person.personId forKey:@"personId"];
    [self.personBasicInfo setValue:self.person.name forKey:@"nickname"];
    
    [self.personBasicInfo setValue:company forKey:@"company"];
    [self.personBasicInfo setValue:zhiwu forKey:@"zhiwei"];
    [self.personBasicInfo setValue:self.person.icon forKey:@"headimgurl"];
    [self.personBasicInfo setValue:self.person.wechat forKey:@"wechat"];
    [self.personBasicInfo setValue:self.person.phone forKey:@"phone"];
    [self.personBasicInfo setValue:self.person.email forKey:@"email"];
    [self.personBasicInfo setValue:self.person.cardurl forKey:@"card"];

}


- (void)requestStatusCountInfo:(void(^)(void))completion{
    
    NSMutableDictionary * parameterDic = [NSMutableDictionary dictionary];
    [parameterDic setValue:[PublicTool isNull:self.personId]?@"":self.personId forKey:@"project_id"];
    [parameterDic setValue:[PublicTool isNull:self.person.name]?@"":self.person.name forKey:@"project"];
    [parameterDic setValue:@"person" forKey:@"project_type"];
    
    __weak typeof(self) weakSelf = self;
    [AppNetRequest getCountOfDetailWIthParam:parameterDic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
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


//投资偏好 投资领域 和 投资阶段

- (TagsFrame*)getTZPreferences:(NSString*)tagsString lingyu:(BOOL)isLingyu{
    
    BOOL isSpread = isLingyu ? self.tagLingyuIsSpread : self.tagJieduanIsSpread;
    
    if ([PublicTool isNull:tagsString]) {
        return [[TagsFrame alloc]init];
    }
    if (![tagsString containsString:@"|"]) {
        return [self getHeightFromArr:@[tagsString]];
    }
    
    NSArray *tags = [tagsString componentsSeparatedByString:@"|"];
    NSMutableArray *tagsArr = [NSMutableArray array];
    
    //只显示2行
    TagsFrame *tagframe = [self getHeightFromArr:tags];
    for (int i=0; i<tagframe.tagsArray.count; i++) {
        CGRect frame = CGRectFromString(tagframe.tagsFrames[i]);
        if (frame.origin.y >= (5+(12+24)*2)) {
            break;
        }
        [tagsArr addObject:tagframe.tagsArray[i]];
        
    }
    
    NSString *tagsStr = tagsString;
    //有查看更多
    if (tagsArr.count < [[tagsStr componentsSeparatedByString:@"|"] count]) {
        //查看更多
        if (!isSpread) {
            
        }else{  //收起
            tagsArr = [NSMutableArray arrayWithArray:tags];
            [tagsArr addObject:@"加收起"];
        }
    }
    return [self getHeightFromArr:tagsArr];
    
}

- (TagsFrame *)getHeightFromArr:(NSArray *)tagsArr{
    
    TagsFrame *frame = [[TagsFrame alloc] init];
    if (tagsArr.count == 0 || (tagsArr.count == 1 &&[tagsArr[0] length] == 0)) {
        frame.tagsArray = @[];
        return frame;
    }
    
    if (tagsArr.count>0) {
        
        frame.tagsArray = tagsArr;
        
    }
    return frame;
}

- (void)dealTags{
    
    if ([PublicTool isNull:self.person.tags]) {
        self.person.tags = @"";
    }
    if (![PublicTool isNull:self.person.tags] && [[self.person.tags substringFromIndex:self.person.tags.length - 1] isEqualToString:@"|"]) {
        self.person.tags = [self.person.tags substringToIndex:self.person.tags.length-1];
    }
    self.person.tags = [NSString stringWithFormat:@"加画像|%@",self.person.tags];
    
    NSArray *tags = [self.person.tags componentsSeparatedByString:@"|"];
    
    if (self.person.tags.length <= 5) {
        tags = @[@"加画像"];
        self.person.tags = @"加画像";
        
    }
    
    NSMutableArray *tagsArr = [NSMutableArray array];
    
    //只显示2行
    TagsFrame *tagframe = [self getHeightFromArr:tags];
    for (int i=0; i<tagframe.tagsArray.count; i++) {
        CGRect frame = CGRectFromString(tagframe.tagsFrames[i]);
        
        if (frame.origin.y >= (5+(12+24)*2)) {
            break;
        }
        [tagsArr addObject:tagframe.tagsArray[i]];
        
    }
    
    NSString *tagsStr = self.person.tags;
    //有查看更多
    if (tagsArr.count < [[tagsStr componentsSeparatedByString:@"|"] count]) {
        //查看更多
        if (!self.tagIsSpread) {
            
        }else{  //收起
            tagsArr = [NSMutableArray arrayWithArray:tags];
            [tagsArr addObject:@"加收起"];
        }
    }
    _tagsFrame = [self getHeightFromArr:tagsArr];
}


#pragma mark --懒加载--
-(NSMutableArray *)commentLayouts{
    if (!_commentLayouts) {
        _commentLayouts = [NSMutableArray array];
    }
    return _commentLayouts;
}
@end



