//
//  PersonDetailViewModel.h
//  qmp_ios
//
//  Created by QMP on 2018/6/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC.h>
#import "PersonModel.h"
#import "CountAndStatusModel.h"
#import "TagsFrame.h"
#import "ActivityLayout.h"
#import "PersonTouziModel.h"
#import "IntroduceCellLayout.h"

@interface PersonDetailViewModel : NSObject
//传入
@property(nonatomic,copy) NSString *unionid;
@property(nonatomic,copy) NSString *personId;

//@property(nonatomic,copy) NSString *ticket;

@property (nonatomic, weak) UIScrollView * scrollView;
@property(nonatomic,strong) PersonModel *person; //官方人物
@property(nonatomic,strong) NSArray *allCompany; //工商信息
@property(nonatomic,assign) NSInteger allCompanyCount; //工商信息数量
@property(nonatomic,strong) NSMutableDictionary *personInfo; //普通用户
@property (strong, nonatomic)NSMutableDictionary *personBasicInfo;
@property(nonatomic,strong) CountAndStatusModel *status_Info;
@property (assign, nonatomic)BOOL tagIsSpread; //画像展开是否
@property(nonatomic,strong) TagsFrame *tagsFrame; //人物画像
@property(nonatomic,strong) TagsFrame *tzlyFrame; //投资领域
@property (assign, nonatomic)BOOL tagLingyuIsSpread; //投资领域展开是否
@property (assign, nonatomic)BOOL tagJieduanIsSpread; //主投阶段展开是否


@property(nonatomic,strong) TagsFrame *jtjdFrame; //投资阶段
@property(nonatomic,strong)NSMutableArray *commentLayouts; //动态数组


@property (strong, nonatomic)NSMutableDictionary *introduceInfoDic;
@property (strong, nonatomic)IntroduceCellLayout *introduceCellLayout;

//信号
@property(nonatomic,readonly) RACSignal *requestFinishSignal;
@property(nonatomic,readonly) RACSignal *requestStatusSignal; //请求数量状态
@property (nonatomic ,readonly) RACSignal *updateTagsFrameSignal; //更新画像tagsFrame
@property (nonatomic ,readwrite) RACSignal *refreshDataSignal; //重新刷新数据的信号
@property (nonatomic ,readwrite) RACSignal *refreshCommentSignal; //重新刷新数据的信号

//关注 btnEvent 和 刷新 signal
@property (nonatomic ,readonly) RACCommand *updateAttentStatusCommand;

//发布动态
@property (nonatomic ,readonly) RACCommand *publishCommentCommand;

//分区头部 sectionHeaderBtnClick
@property (nonatomic ,readonly) RACCommand *sectionHeaderBtnCommand;

@property (nonatomic ,readonly) RACCommand *cellEditCommand;

@end
