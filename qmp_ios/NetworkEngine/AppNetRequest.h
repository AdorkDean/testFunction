//
//  AppNetRequest.h
//  FlyComm
//
//  Created by wss on 15/12/24.
//  Copyright © 2015年 WSS. All rights reserved.
//应用需要的网络请求

#import <Foundation/Foundation.h>
//#import "NetMacro.h"
#import "NetworkManager.h"

typedef void(^BoolResultHandler)(NSURLSessionDataTask *dataTask,BOOL resultTrue,NSError *error);

@interface AppNetRequest : NSObject

+ (void)uploadPDFWithFilePath:(NSString *)path fileName:(NSString *)name params:(NSDictionary *)params progress:(Progress)progress completeHandler:(CompleteHandler)completeHandler;
#pragma mark --首页
/**
 首页融资
 */
+ (NSURLSessionDataTask*)getRZNewsWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/**
 企业头条
 */
+ (NSURLSessionDataTask*)gettoutiaoListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

#pragma mark --公司
/**
  公司详情
 */
+ (NSURLSessionDataTask*)getCompanyDetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/**
 公司相似项目
 */
+ (NSURLSessionDataTask*)getCompanySimilarWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;


/**
 公司公告
 */
+ (NSURLSessionDataTask*)getCompanyReportWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/**
 公司招聘信息
 */
+ (NSURLSessionDataTask*)getCompanyZhaopinWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 项目 添加到专辑  */
+ (NSURLSessionDataTask*)addProductToWorkTagWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 项目 用户加入的专辑tag */
+ (NSURLSessionDataTask*)getWorkTagByProductWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 公司 相关成员 */
+ (NSURLSessionDataTask*)getCompanyPersonWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 项目投资人列表 */
+ (NSURLSessionDataTask*)getProductInvestorListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
#pragma mark --机构
/**
  机构详情
 */
+ (NSURLSessionDataTask*)getJigouDetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/**投资案例*/
+ (NSURLSessionDataTask*)getJigouTouziExampleWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** 合投机构 */
+ (NSURLSessionDataTask*)getJigouCombineTZWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 参投机构 */
+ (NSURLSessionDataTask*)getJigouCanTouWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 投资案子  case */
+ (NSURLSessionDataTask*)getJigouCaseWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 机构新闻列表 */
+ (NSURLSessionDataTask*)getJigouNewsWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** 机构 相关公司 */
+ (NSURLSessionDataTask*)getRelateCompanyWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 机构 相关成员 */
+ (NSURLSessionDataTask*)getJigouPersonWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 机构  在服项目 */
+ (NSURLSessionDataTask*)getJigouFAProductWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/**
 项目-融资需求
 */
+ (NSURLSessionDataTask *)getFinanalNeedWithPararmeter:(NSDictionary *)para completionHandle:(CompleteHandler)completeHandler;


#pragma mark --工作流--
/**
 从工作流删除项目
 */
+ (NSURLSessionDataTask*)deleteProductFromWorkFlowWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/**
 工作流批量导入项目到专辑
 */
+ (NSURLSessionDataTask*)workflowToAlbumWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/**
  机构工作流加入机构
 */
+ (NSURLSessionDataTask*)jigouWorkflowAddWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/**
  关注新闻动态
 */
+ (NSURLSessionDataTask*)attentionNewsListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;


#pragma mark --投融资
/** 企项优选*/
+ (NSURLSessionDataTask*)getRongziAbutmentListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 活跃机构 */
+ (NSURLSessionDataTask*)getActiveJigouListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 热度机构 */
+ (NSURLSessionDataTask*)getHotJigouListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;


/** 热门专辑 */
+ (NSURLSessionDataTask*)getHotAlbumWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** 专辑库 */
+ (NSURLSessionDataTask*)getAlbumListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

#pragma mark --我的
/** 手机号验证 */
+ (NSURLSessionDataTask*)verifyPhoneWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 验证码 */
+ (NSURLSessionDataTask*)getVerifyCodeWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 验证 验证码 */
+ (NSURLSessionDataTask*)verifyCodeWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 绑定手机号 */
+ (NSURLSessionDataTask*)userBindPhoneWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 我的好友 */
+ (NSURLSessionDataTask*)getMyfriendListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** 加好友 */
+ (NSURLSessionDataTask*)addFriendWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** 赠送金币 */
+ (NSURLSessionDataTask*)friendSendCoinWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** 删除好友  */
+ (NSURLSessionDataTask*)friendDeleteWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** 获取unionid */
+ (NSURLSessionDataTask*)getUnionidWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 获取 用户信息 */
+ (NSURLSessionDataTask*)getUserInfoWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 保存 工作经历 */
+ (NSURLSessionDataTask*)saveUserWorkExperienceWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** 删除 工作经历 */
+ (NSURLSessionDataTask*)delUserWorkExperienceWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** 存储 教育经历 */
+ (NSURLSessionDataTask*)saveUserEducationWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** 删除 教育经历 */
+ (NSURLSessionDataTask*)delUserEducationWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 好友申请列表 */
+ (NSURLSessionDataTask*)getFriendApplyListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 好友申请处理 */
+ (NSURLSessionDataTask*)dealFriendApplyWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

#pragma mark --文档
/** BP 列表*/
+ (NSURLSessionDataTask*)getBPListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** BP TOME  列表*/
+ (NSURLSessionDataTask*)getBPToMeListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 删除 BP  */
+ (NSURLSessionDataTask*)deleteBPWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** 添加删除过的 BP*/
+ (NSURLSessionDataTask*)addBPWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;


/** 用户新建专辑 （标签） */
+ (NSURLSessionDataTask*)tagAddNewWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 招股书列表 */
+ (NSURLSessionDataTask*)ProspectusListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

#pragma mark --人物相关
/** 人物详情 */
+ (NSURLSessionDataTask*)personDetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** 人物列表 */
+ (NSURLSessionDataTask*)getPersonListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 投递BP 给 投资人 */
+ (NSURLSessionDataTask*)deliverBPToInvestorWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 修改 官方人物的基本信息 */
+ (NSURLSessionDataTask*)submitPersonInfoOfDetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 添加 编辑 官方人物的工作经历 */
+ (NSURLSessionDataTask*)submitPersonWorkOfDetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 添加 编辑 官方人物的教育经历 */
+ (NSURLSessionDataTask*)submitPersonEducationOfDetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 学校的人物 */
+ (NSURLSessionDataTask*)getSchoolPersonWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 推荐的好友 */
+ (NSURLSessionDataTask*)getRecommendFriendWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;


/** 获取用户权限
 1、项目的融资需求查看       : pro_financialinfo
 2、项目的委托联系              : pro_getcontact
 3、查看 项目投资人             : pro_investors
 4、FA的服务项目（BP和联系方式） : jigou_fapro_conatct
 5、交换联系方式：                     ： exchangePersonCard
 */
+ (NSURLSessionDataTask*)getUserPrivilegeWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;



#pragma mark  --数据
/** 数据图谱 */
+ (NSURLSessionDataTask*)getDataTuPuWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 图谱细分领域 */
+ (NSURLSessionDataTask*)getTuPuAreaWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;


/** 图谱 项目 */
+ (NSURLSessionDataTask*)getProductByTagWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/**  报告 */
+ (NSURLSessionDataTask*)getReportByTagWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 图谱 趋势 */
+ (NSURLSessionDataTask*)getTrendByTagWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 获取banner */
+ (NSURLSessionDataTask*)getBannerListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

#pragma mark --笔记
/** 新建笔记 */
+ (NSURLSessionDataTask*)addNewNoteWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 笔记列表 */
+ (NSURLSessionDataTask*)getNoteListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 删除笔记 */
+ (NSURLSessionDataTask*)deleteNoteWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

#pragma mark -- 推送
/** 推送列表 */
+ (NSURLSessionDataTask*)getPushListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 反馈列表 */
+ (NSURLSessionDataTask*)getFeedBackListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;


#pragma mark --搜索
/** 主 搜索 */
+ (NSURLSessionDataTask*)mainSearchWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;


#pragma mark --二级市场
/** IPO 列表*/
+ (NSURLSessionDataTask*)getIPOlistWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
/** IPO详情 */
+ (NSURLSessionDataTask*)getIPODetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 并购库 事件 */
+ (NSURLSessionDataTask*)getBingGouEventWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 上市库 事件 */
+ (NSURLSessionDataTask*)getSmarketEventWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 新三板 企业库 */
+ (NSURLSessionDataTask*)getThreeBoardProductWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** A股 企业库 */
+ (NSURLSessionDataTask*)getAStockProductWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;
#pragma mark --资讯
/** 投资人说 */
+ (NSURLSessionDataTask*)getInvestorCommentWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;


#pragma mark --领域
/** 领域 项目 */
+ (NSURLSessionDataTask*)getProOfLingyuWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;

/** 领域  趋势图 */
+ (NSURLSessionDataTask*)getPicOfLingyuWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler;



#pragma mark --回调结果后，有公共操作的请求 (如 获取用户权限，交换联系方式剩余次数)

/**
 获取用户权限,
 1、项目的融资需求查看       : pro_financialinfo
 2、项目的委托联系              : pro_getcontact
 3、查看 项目投资人             : pro_investors
 4、FA的服务项目（BP和联系方式） : jigou_fapro_conatct
 5、交换联系方式：                     ： exchangePersonCard
 */
+ (NSURLSessionDataTask*)getUserPrivilegeWithType:(NSString*)typeStr resultHandle:(BoolResultHandler)boolResult;

/**
 获取交换联系方式剩余次数
 */
+ (NSURLSessionDataTask*)getLeftCountOfExchangeCardWithParameter:(NSDictionary*)param completionHandle:(BoolResultHandler)resultHandle;

/**
  更新未读数
 send_count   //推送消息
 system_send_count   系统通知
 all_read_count  全部已读
 system_notification_count  新系统通知
 activity_notifi_count 动态互动通知
 apply_count    交换联系方式申请
 exchange_card_count  交换的名片
 */
+ (void)updateUnreadCountWithKey:(NSString*)saveKey type:(NSString*)typeStr completeHandler:(CompleteHandler)completeHandler;

/**项目机构人物 关注取关*/
+ (NSURLSessionDataTask*)attentFunctionWithParam:(NSDictionary*)param completeHandler:(CompleteHandler)completeHandler;

/** 项目机构人物  获取点赞关注状态及数量*/
+ (NSURLSessionDataTask*)getCountOfDetailWIthParam:(NSDictionary*)param completeHandler:(CompleteHandler)completeHandler;

/** 项目机构人物 动态  点赞操作*/
+ (NSURLSessionDataTask*)likeOrCancelwithParam:(NSDictionary*)param completeHandler:(CompleteHandler)completeHandler;

/** 我的关注列表 在用 */
+ (NSURLSessionDataTask *)getUserFollowListWithParam:(NSDictionary*)param completeHandler:(CompleteHandler)completeHandler;

/** 我的关注列表 新  */
+ (NSURLSessionDataTask *)getAttentionListWithParam:(NSDictionary*)param completeHandler:(CompleteHandler)completeHandler;

+ (NSURLSessionDataTask *)getContactMemberOfProductWithParam:(NSDictionary*)param completeHandler:(CompleteHandler)completeHandler;


@end
