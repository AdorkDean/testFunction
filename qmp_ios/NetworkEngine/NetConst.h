//
//  NetConst.h
//  qmp_ios
//
//  Created by QMP on 2018/8/15.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXTERN NSString *const QMPImageUpLoadURL;
FOUNDATION_EXTERN NSString *const QMPPdfUpLoadURL;

FOUNDATION_EXTERN NSString *const QMPHomeRongziURL;         ///< 首页融资
FOUNDATION_EXTERN NSString *const QMPHomeQiYeTouTiaoURL;    ///< 企业头条（新）


FOUNDATION_EXTERN NSString *const QMPProductDetailURL;          ///< 项目详情
FOUNDATION_EXTERN NSString *const QMPProductReportURL;          ///< 项目公告
FOUNDATION_EXTERN NSString *const QMPProductAddAlnumURL;        ///< 项目添加到专辑，传空就是删除
FOUNDATION_EXTERN NSString *const QMPProductTagURL;             ///< 项目的专辑tagitem
FOUNDATION_EXTERN NSString *const QMPProductSimilarURL;         ///< 项目相似项目
FOUNDATION_EXTERN NSString *const QMPProductZhaoPinURL;         ///< 项目招聘
FOUNDATION_EXTERN NSString *const QMPProductMemberURL;          ///< 项目相关成员
FOUNDATION_EXTERN NSString *const QMPProductMemberContactURL;   ///< 项目成员（立即联系）
FOUNDATION_EXTERN NSString *const QMPProductFinancedURL;        ///< 项目融资需求
FOUNDATION_EXTERN NSString *const QMProductInvestorURL;         //公司投资人


FOUNDATION_EXTERN NSString *const QMPOrganizeDetailURL;         ///< 机构详情
FOUNDATION_EXTERN NSString *const QMPOrganizeInvestCaseURL;     ///< 投资案例
FOUNDATION_EXTERN NSString *const QMPOrganizeCombineCaseURL;    ///< 合投机构（同一轮）
FOUNDATION_EXTERN NSString *const QMPOrganizeTogetherCaseURL;   ///< 参投机构（同一项目）
FOUNDATION_EXTERN NSString *const QMPOrganizeFaCaseURL;         ///< FA案例
FOUNDATION_EXTERN NSString *const QMPOrganizeNewsURL;           ///< 机构新闻
FOUNDATION_EXTERN NSString *const QMPOrganizeRelateCompanyURL;  ///< 相关公司
FOUNDATION_EXTERN NSString *const QMPOrganizeMemberURL;         ///< 机构成员
FOUNDATION_EXTERN NSString *const QMPOrganizeFAServiceCaseURL;  ///< FA在服项目


FOUNDATION_EXTERN NSString *const QMPFinanceDemandURL;  ///< 融资需求列表
FOUNDATION_EXTERN NSString *const QMPActiveOrganizeURL; ///< 活跃机构


FOUNDATION_EXTERN NSString *const QMPGetVerifyCodeURL;  ///< 获取验证码
FOUNDATION_EXTERN NSString *const QMPVerifyPhoneURL;    ///< 验证手机号是否已绑定
FOUNDATION_EXTERN NSString *const QMPVerifyCodeURL;     ///< 验证验证码
FOUNDATION_EXTERN NSString *const QMPBindPhoneURL;      ///< 绑定手机号
FOUNDATION_EXTERN NSString *const QMPFriendsListURL;    ///< 好友列表
FOUNDATION_EXTERN NSString *const QMPAddFriendURL;      ///< 加好友
FOUNDATION_EXTERN NSString *const QMPSendCoinURL;       ///< 赠送金币
FOUNDATION_EXTERN NSString *const QMPDeleteFriendURL;   ///< 删除好友
FOUNDATION_EXTERN NSString *const QMPUnionidByCodeURL;  ///< 通过 usercode 获取 unionid
FOUNDATION_EXTERN NSString *const QMPUserInfoURL;       ///< 获取用户信息

FOUNDATION_EXTERN NSString *const QMPEditWorkExperienceURL;             ///< 添加修改工作经历
FOUNDATION_EXTERN NSString *const QMPDeleteWorkExperienceURL;           ///< 删除工作经历
FOUNDATION_EXTERN NSString *const QMPEditEducationalExperienceURL;      ///< 添加修改工作经历
FOUNDATION_EXTERN NSString *const QMPDeleteEducationalExperienceURL;    ///< 删除工作经历
FOUNDATION_EXTERN NSString *const QMPFriendRequestListURL;              ///< 好友申请列表
FOUNDATION_EXTERN NSString *const QMPFriendRequestHandleURL;            ///< 处理好友申请
FOUNDATION_EXTERN NSString *const QMPUserFollowCountURL;                ///< 用户关注的数量（项目，机构，领域）
FOUNDATION_EXTERN NSString *const QMPUserEditCard;                      ///< 用户编辑名片
FOUNDATION_EXTERN NSString *const QMPUserAddCard;                       ///< 用户上传名片
FOUNDATION_EXTERN NSString *const QMPUserAddCardBack;                   ///< 用户编辑名片背面



FOUNDATION_EXTERN NSString *const QMPPersonDetailURL;               ///< 人物详情
FOUNDATION_EXTERN NSString *const QMPPersonListURL;                 ///< 人物列表
FOUNDATION_EXTERN NSString *const QMPDeliverBPURL;                  ///< 投递BP
FOUNDATION_EXTERN NSString *const QMPUpdatePersonURL;               ///< 更新人物信息
FOUNDATION_EXTERN NSString *const QMPSavePersonWorkExperienceURL;   ///< 更新人物工作经历
FOUNDATION_EXTERN NSString *const QMPSavePersonEduExperienceURL;    ///< 更新人物教育经历
FOUNDATION_EXTERN NSString *const QMPSaveSchoolPersonListURL;       ///< 学校下的人物
FOUNDATION_EXTERN NSString *const QMPRecommendFriendsURL;           ///< 推荐好友
FOUNDATION_EXTERN NSString *const QMPUserPrivilegeURL;              ///< 用户权限限制


FOUNDATION_EXTERN NSString *const QMPAddTagURL;   ///< 用户新建专辑(标签)


FOUNDATION_EXTERN NSString *const QMPWorkflowDeleteProductURL;  ///< 工作流删除项目
FOUNDATION_EXTERN NSString *const QMPWorkflowAddProductsURL;    ///< 项目批量到专辑


FOUNDATION_EXTERN NSString *const QMPWorkflowAddOrganizeURL;    ///< 机构添加到工作流
FOUNDATION_EXTERN NSString *const QMPWorkflowOfOrganozeURL;     ///< 机构工作流信息
FOUNDATION_EXTERN NSString *const QMPNewsOfWorkflowURL;         ///< 关注项目或机构的新闻


FOUNDATION_EXTERN NSString *const QMPBPListURL;         ///< BP 列表
FOUNDATION_EXTERN NSString *const QMPMyBPListURL;       ///< 我收到的 BP
FOUNDATION_EXTERN NSString *const QMPDeleteBPURL;       ///< 删除 BP
FOUNDATION_EXTERN NSString *const QMPFileBPCollectURL;  ///< 将刚删除的 BP 重新绑定给用户 BP
FOUNDATION_EXTERN NSString *const QMPProspetcusListURL; ///< 招股书列表


FOUNDATION_EXTERN NSString *const QMPDataMapURL;            ///< 数据图谱
FOUNDATION_EXTERN NSString *const QMPDataMapAreaURL;        ///< 图谱细分领域
FOUNDATION_EXTERN NSString *const QMPDataMapReportURL;      ///< 图谱报告
FOUNDATION_EXTERN NSString *const QMPDataMapTrendURL;       ///< 图谱趋势
FOUNDATION_EXTERN NSString *const QMPDataMapProductsURL;    ///< 图谱(标签)下的项目
FOUNDATION_EXTERN NSString *const QMPHotDataMapURL;         ///< 热门专辑
FOUNDATION_EXTERN NSString *const QMPAllDataMapURL;         ///< 专辑列表


FOUNDATION_EXTERN NSString *const QMPBannerURL;  ///< Banner


FOUNDATION_EXTERN NSString *const QMPNoteAddURL;    ///< 新建笔记
FOUNDATION_EXTERN NSString *const QMPNoteListURL;   ///< 笔记列表
FOUNDATION_EXTERN NSString *const QMPNoteDeleteURL; ///< 删除笔记


FOUNDATION_EXTERN NSString *const QMPPushListURL;       ///< 推送列表
FOUNDATION_EXTERN NSString *const QMPFeedBackListURL;   ///< 反馈列表


FOUNDATION_EXTERN NSString *const QMPNewsFastListURL;       ///< 快讯列表
FOUNDATION_EXTERN NSString *const QMPNewsBlockListURL;      ///< 区块链新闻
FOUNDATION_EXTERN NSString *const QMPHotOrganizeURL;        ///< 热度机构
FOUNDATION_EXTERN NSString *const QMPInvestorCommentURL;    ///< 投资人说


FOUNDATION_EXTERN NSString *const QMPMainSearchURL; ///< 主搜索

FOUNDATION_EXTERN NSString *const QMPIPOListURL;    ///< IPO 列表
FOUNDATION_EXTERN NSString *const QMPIPODetailURL;  ///< IPO 详情
FOUNDATION_EXTERN NSString *const QMPMergerListURL; ///< 并购库
FOUNDATION_EXTERN NSString *const QMPIPOEventURL;   ///< 上市库
FOUNDATION_EXTERN NSString *const QMPNEEQListURL;   ///< 新三板
FOUNDATION_EXTERN NSString *const QMPAStockListURL; ///< A 股


FOUNDATION_EXTERN NSString *const QMPAreaURL;       ///< 领域项目
FOUNDATION_EXTERN NSString *const QMPAreaTrendURL;  ///< 领域趋势
FOUNDATION_EXTERN NSString *const QMPAttentURL;    //新版项目机构人物主题关注

FOUNDATION_EXTERN NSString *const QMPUserNewFollowedURL;   //新版关注列表（用户主题）
FOUNDATION_EXTERN NSString *const QMPUserFollowedURL;   //旧关注
FOUNDATION_EXTERN NSString *const QMPActivityNotificationListURL;   //动态互动提醒列表



@interface NetConst : NSObject
+ (NSDictionary *)urlDescDict;

@end
