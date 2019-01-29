//
//  NetConst.m
//  qmp_ios
//
//  Created by QMP on 2018/8/15.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "NetConst.h"


#ifdef  DEBUG
NSString *const  QMPImageUpLoadURL = @"https://testiosapi.qimingpian.com/upload/img";
#else
NSString *const  QMPImageUpLoadURL = @"https://iosapi.qimingpian.com/upload/img"; //旧http://img.api.qimingpian.com/t/uploadImgTool
#endif

NSString *const QMPPdfUpLoadURL   = @"http://pdf.api.qimingpian.com/t/webuploader1";

NSString *const QMPHomeRongziURL        = @"h/newrongzi3Is";            ///< 首页融资
NSString *const QMPHomeQiYeTouTiaoURL   = @"h/showHeadlineNews";        ///< 企业头条（新）


NSString *const QMPProductDetailURL         = @"CompanyDetail/basicInfo";   //d/c1@"CompanyDetail/basicInfo"///< 项目详情
NSString *const QMPProductReportURL         = @"h/getAllAshareinfo";        ///< 项目公告
NSString *const QMPProductAddAlnumURL       = @"h/workTagAddTagToProduct";  ///< 项目添加到专辑，传空就是删除
NSString *const QMPProductTagURL            = @"h/workTagByProduct";        ///< 项目的专辑tagitem
NSString *const QMPProductSimilarURL        = @"CompanyDetail/competingInfo";         ///< 项目相似项目
NSString *const QMPProductZhaoPinURL        = @"CompanyDetail/zhaopin";     ///d/zhaopin< 项目招聘
NSString *const QMPProductMemberURL         = @"CompanyDetail/showCompanyTeam";  ///d/getCompanyRelateMember < 项目相关成员
NSString *const QMPProductMemberContactURL  = @"Product/showProductContacts";       ///< 项目成员（立即联系）
NSString *const QMPProductFinancedURL       = @"d/getProductNeedRz";        ///< 项目融资需求


NSString *const QMPOrganizeDetailURL        = @"AgencyDetail/agencyBasic";              ///< 机构详情
NSString *const QMPOrganizeInvestCaseURL    = @"AgencyDetail/agencyInvestCompany";                    ///< 投资案例
NSString *const QMPOrganizeCombineCaseURL   = @"AgencyDetail/agencyCombineList";          ///< 合投机构（同一轮）
NSString *const QMPOrganizeTogetherCaseURL  = @"AgencyDetail/agencyTogetherList";         ///< 参投机构（同一项目）
NSString *const QMPOrganizeFaCaseURL        = @"AgencyDetail/agencyFaCase";            ///< FA案例
NSString *const QMPOrganizeNewsURL          = @"AgencyDetail/agencyNews";         ///< 机构新闻
NSString *const QMPOrganizeRelateCompanyURL = @"AgencyDetail/agencyRegisterCompany";              ///< 相关公司
NSString *const QMPOrganizeMemberURL        = @"AgencyDetail/agencyTeam";   ///< 机构成员d/getJiGouManagerByName
NSString *const QMPOrganizeFAServiceCaseURL = @"AgencyDetail/agencyServiceProduct";     ///< FA在服项目


NSString *const QMPFinanceDemandURL = @"h/rongziAbutmentList3"; ///< 融资需求列表
NSString *const QMPActiveOrganizeURL = @"Institutional/activeAgency";    ///< 活跃机构


NSString *const QMPGetVerifyCodeURL = @"login/sendVerifyCode";      ///< 获取验证码new  新：d/dysms
NSString *const QMPVerifyPhoneURL   = @"d/verifyPhone";             ///< 验证手机号是否已绑定
NSString *const QMPVerifyCodeURL    = @"d/bindUserinfo";            ///< 验证验证码
NSString *const QMPBindPhoneURL     = @"d/changbinduser";           ///< 绑定手机号
NSString *const QMPFriendsListURL   = @"card/friendList";              ///< 好友列表
NSString *const QMPAddFriendURL     = @"h/applyFriends";            ///< 加好友
NSString *const QMPSendCoinURL      = @"h/coinSend";                ///< 赠送金币
NSString *const QMPDeleteFriendURL  = @"h/friendDelete";            ///< 删除好友
NSString *const QMPUnionidByCodeURL = @"l/getQidByUserInfo";        ///< 通过 usercode 获取 unionid
NSString *const QMPUserInfoURL      = @"user/showUserInfomation";  ///< 获取用户信息
NSString *const QMPUserNewFollowedURL  = @"common/showFollowlist";      ///< 关注列表  用户和主题
NSString *const QMPUserFollowedURL  = @"h/getFocusLists";           ///< 旧 我的关注列表

NSString *const QMPEditWorkExperienceURL            = @"h/saveUserWorkExperience";      ///< 添加修改工作经历
NSString *const QMPDeleteWorkExperienceURL          = @"h/delUserWorkExperience";       ///< 删除工作经历
NSString *const QMPEditEducationalExperienceURL     = @"h/saveUserEducationExperience"; ///< 添加修改工作经历
NSString *const QMPDeleteEducationalExperienceURL   = @"h/delUserEducationExperience";  ///< 删除工作经历
NSString *const QMPFriendRequestListURL             = @"h/applyUserList";               ///< 好友申请列表
NSString *const QMPFriendRequestHandleURL           = @"h/receiveAction";               ///< 处理好友申请
NSString *const QMPUserFollowCountURL               = @"focus/getFocusCount";           ///< 用户关注的数量（项目，机构，领域）
NSString *const QMPUserEditCard                     = @"Card/editCardInfo";             ///< 用户编辑名片
NSString *const QMPUserAddCard                      = @"Card/addCardInfo";              ///< 用户上传名片
NSString *const QMPUserAddCardBack                  = @"Card/editCard";                  ///< 用户编辑名片背面


NSString *const QMPPersonDetailURL              = @"person/personDetail";                      ///< 人物详情
NSString *const QMPPersonListURL                = @"Person/personDataList";                    ///< 人物列表
NSString *const QMProductInvestorURL            = @"CompanyDetail/companyInvestor";   //公司投资人
NSString *const QMPDeliverBPURL                 = @"h/bpToActiveInvestor";          ///< 投递BP
NSString *const QMPUpdatePersonURL              = @"h/updateUserFigure";            ///< 更新人物信息
NSString *const QMPSavePersonWorkExperienceURL  = @"h/savePersonWorkExperience";    ///< 更新人物工作经历
NSString *const QMPSavePersonEduExperienceURL   = @"h/savePersonEduExperience";     ///< 更新人物教育经历
NSString *const QMPSaveSchoolPersonListURL      = @"h/showPersonEduList";           ///< 学校下的人物
NSString *const QMPRecommendFriendsURL          = @"h/recommendFriendList";         ///< 推荐好友
NSString *const QMPUserPrivilegeURL             = @"user/checkUserPrivilege";       ///< 用户权限限制


NSString *const QMPAddTagURL = @"h/workTagAdd";     ///< 用户新建专辑(标签)


NSString *const QMPWorkflowDeleteProductURL = @"h/workflowDeleteProduct";   ///< 工作流删除项目
NSString *const QMPWorkflowAddProductsURL   = @"h/worktagAddProduct1";      ///< 项目批量到专辑


NSString *const QMPWorkflowAddOrganizeURL       = @"h/workFlowAddJigou";            ///< 机构添加到工作流
NSString *const QMPNewsOfWorkflowURL            = @"h/showFocusNewsv1";             ///< 关注项目或机构的新闻


NSString *const QMPBPListURL            = @"h/workBpList";          ///< BP 列表
NSString *const QMPMyBPListURL          = @"h/workBpToMe";          ///< 我收到的 BP
NSString *const QMPDeleteBPURL          = @"h/workBpDelete";        ///< 删除 BP
NSString *const QMPFileBPCollectURL     = @"h/workBpCollect";       ///< 将刚删除的 BP 重新绑定给用户 BP
NSString *const QMPProspetcusListURL    = @"Report/prospectusList";    ///< 招股书列表


NSString *const QMPDataMapURL           = @"h/getHangyeTupulist1";  ///< 数据图谱
NSString *const QMPDataMapAreaURL       = @"h/showTupu";            ///< 图谱细分领域
NSString *const QMPDataMapReportURL     = @"Report/reportList";      ///< 报告
NSString *const QMPDataMapTrendURL      = @"d/touziCount";          ///< 图谱趋势
NSString *const QMPDataMapProductsURL   = @"d/getProByTag";         ///< 图谱(标签)下的项目
NSString *const QMPHotDataMapURL        = @"h/albumListField";      ///< 热门专辑
NSString *const QMPAllDataMapURL        = @"h/albumListField2";     ///< 专辑列表


NSString *const QMPBannerURL = @"d/bannerIos";  ///< Banner


NSString *const QMPNoteAddURL       = @"F/addpnotes";       ///< 新建笔记
NSString *const QMPNoteListURL      = @"F/showpnotes";      ///< 笔记列表
NSString *const QMPNoteDeleteURL    = @"F/removepnotes";    ///< 删除笔记


NSString *const QMPPushListURL = @"Jpush/showJpushHistory";              ///< 推送列表 旧：h/showSendHistory
NSString *const QMPFeedBackListURL = @"feedback/myFeedbackList";    ///< 反馈列表


NSString *const QMPNewsFastListURL = @"h/globalnewsbypage";         ///< 快讯列表
NSString *const QMPNewsBlockListURL = @"h/globalnewscoinsbypage";   ///< 区块链新闻
NSString *const QMPHotOrganizeURL = @"h/showHotJiGou";              ///< 热度机构
NSString *const QMPInvestorCommentURL = @"h/showInvestorComments";  ///< 投资人说


NSString *const QMPMainSearchURL = @"search/search";   ///< 主搜索

NSString *const QMPIPOListURL       = @"smarket/AuditSchedule1";        ///< IPO 列表
NSString *const QMPIPODetailURL     = @"smarket/showAuditScheduleinfo"; ///< IPO 详情
NSString *const QMPMergerListURL    = @"h/touziFilterMerge";            ///< 并购库
NSString *const QMPIPOEventURL      = @"SMarket/smarketList";           ///< 上市库 h/smarketEvent
NSString *const QMPNEEQListURL      = @"smarket/getNewstockInfo";       ///< 新三板
NSString *const QMPAStockListURL    = @"h/getzibeninfo3";               ///< A 股


NSString *const QMPAreaURL = @"d/showProductInfoByTag"; ///< 领域项目
NSString *const QMPAreaTrendURL = @"j/tagDetailPic";    ///< 领域趋势

NSString *const QMPAttentURL = @"common/commonFocus";    //新版项目机构人物主题关注
NSString *const QMPActivityNotificationListURL = @"activity/activityNoticeList490";   //动态互动提醒列表,11评论；12关注；13投币


static NSDictionary *_urlDescDict;
@implementation NetConst
+ (NSDictionary *)urlDescDict {
    if (_urlDescDict == nil) {
        _urlDescDict = @{
                         QMPHomeRongziURL:@"融资",
                         QMPProductDetailURL:@"项目详情",
                         QMPProductReportURL:@"公司公告",QMPMyBPListURL:@"收到的BP列表",
                         QMPOrganizeDetailURL:@"机构详情",
                         QMPOrganizeInvestCaseURL:@"投资案例", QMPOrganizeCombineCaseURL:@"合投机构",
                         QMPOrganizeTogetherCaseURL:@"参投机构", QMPOrganizeFaCaseURL:@"投资FA案例",
                         QMPOrganizeNewsURL:@"机构新闻列表",QMPFinanceDemandURL:@"企项优选",
                         QMPFriendsListURL:@"好友列表",QMPBPListURL:@"BP列表",
                         QMPActiveOrganizeURL:@"活跃机构列表",
                         QMPDataMapURL:@"数据图谱",QMPDataMapAreaURL:@"图谱细分领域",
                         QMPDataMapProductsURL:@"图谱项目",
                         QMPDataMapReportURL:@"图谱研报",QMPPersonListURL:@"人物列表",
                         QMPPersonDetailURL:@"人物详情",QMPProspetcusListURL:@"找招股书",
                         QMPNoteListURL:@"笔记列表",QMPHotOrganizeURL:@"热度机构",
                         QMPPushListURL:@"推送列表",QMPIPOListURL:@"IPO列表",
                        };
    }
    return _urlDescDict;
}
@end

