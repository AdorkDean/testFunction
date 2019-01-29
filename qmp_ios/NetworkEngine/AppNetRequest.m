//
//  AppNetRequest.m
//  FlyComm
//
//  Created by wss on 15/12/24.
//  Copyright © 2015年 WSS. All rights reserved.
//

#import "AppNetRequest.h"
#import "NetConst.h"

//微信


@implementation AppNetRequest

+ (void)uploadPDFWithFilePath:(NSString *)path fileName:(NSString *)name params:(NSDictionary *)params progress:(Progress)progress completeHandler:(CompleteHandler)completeHandler {
    [[NetworkManager sharedMgr] uploadFileWithUrl:QMPPdfUpLoadURL filePath:path fileName:name fileKey:@"file" params:params progress:progress completeHandler:completeHandler];
}


+ (NSURLSessionDataTask*)getRZNewsWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPHomeRongziURL HTTPBody:param completeHandler:completeHandler];
}


+ (NSURLSessionDataTask*)getCompanyDetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPProductDetailURL HTTPBody:param completeHandler:completeHandler];

}


+ (NSURLSessionDataTask*)getCompanySimilarWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPProductSimilarURL HTTPBody:param completeHandler:completeHandler];

}


+ (NSURLSessionDataTask*)getCompanyReportWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPProductReportURL HTTPBody:param completeHandler:completeHandler];

    
}

+ (NSURLSessionDataTask*)getCompanyZhaopinWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPProductZhaoPinURL HTTPBody:param completeHandler:completeHandler];
}

/**
 项目-融资需求
 */
+ (NSURLSessionDataTask *)getFinanalNeedWithPararmeter:(NSDictionary *)para completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPProductFinancedURL HTTPBody:para completeHandler:completeHandler];
}

/**
 机构详情
 */
+ (NSURLSessionDataTask*)getJigouDetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPOrganizeDetailURL HTTPBody:param completeHandler:completeHandler];
    
}
/**投资案例*/
+ (NSURLSessionDataTask*)getJigouTouziExampleWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPOrganizeDetailURL HTTPBody:param completeHandler:completeHandler];
    
}
/** 合投机构 */
+ (NSURLSessionDataTask*)getJigouCombineTZWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPOrganizeCombineCaseURL HTTPBody:param completeHandler:completeHandler];

    
}

/** 参投机构 */
+ (NSURLSessionDataTask*)getJigouCanTouWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPOrganizeTogetherCaseURL HTTPBody:param completeHandler:completeHandler];

    
}

/** 投资案子  case */
+ (NSURLSessionDataTask*)getJigouCaseWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPOrganizeInvestCaseURL HTTPBody:param completeHandler:completeHandler];

}
/** 机构新闻列表 */
+ (NSURLSessionDataTask*)getJigouNewsWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPOrganizeNewsURL HTTPBody:param completeHandler:completeHandler];

}
/** 机构 相关公司 */
+ (NSURLSessionDataTask*)getRelateCompanyWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPOrganizeRelateCompanyURL HTTPBody:param completeHandler:completeHandler];

}


/** 工作流  */

+ (NSURLSessionDataTask*)deleteProductFromWorkFlowWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPWorkflowDeleteProductURL HTTPBody:param completeHandler:completeHandler];

}

+ (NSURLSessionDataTask*)workflowToAlbumWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPWorkflowAddProductsURL HTTPBody:param completeHandler:completeHandler];

}

+ (NSURLSessionDataTask*)getRongziAbutmentListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPFinanceDemandURL HTTPBody:param completeHandler:completeHandler];

}


/** 手机号验证 */
+ (NSURLSessionDataTask*)verifyPhoneWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPVerifyPhoneURL HTTPBody:param completeHandler:completeHandler];

}

/** 验证 验证码 */
+ (NSURLSessionDataTask*)verifyCodeWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPVerifyCodeURL HTTPBody:param completeHandler:completeHandler];

}
/** 验证码 */
+ (NSURLSessionDataTask*)getVerifyCodeWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPGetVerifyCodeURL HTTPBody:param completeHandler:completeHandler];

}
/** 绑定手机号 */
+ (NSURLSessionDataTask*)userBindPhoneWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPBindPhoneURL HTTPBody:param completeHandler:completeHandler];

}

/** 我的好友 */
+ (NSURLSessionDataTask*)getMyfriendListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPFriendsListURL HTTPBody:param completeHandler:completeHandler];

}

/** 加好友 */
+ (NSURLSessionDataTask*)addFriendWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPAddFriendURL HTTPBody:param completeHandler:completeHandler];

}

/** 赠送金币 */
+ (NSURLSessionDataTask*)friendSendCoinWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPSendCoinURL HTTPBody:param completeHandler:completeHandler];

}
/** 删除好友  */
+ (NSURLSessionDataTask*)friendDeleteWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPDeleteFriendURL HTTPBody:param completeHandler:completeHandler];

}

/** 获取unionid */
+ (NSURLSessionDataTask*)getUnionidWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPUnionidByCodeURL HTTPBody:param completeHandler:completeHandler];

}


/** 人物详情 */
+ (NSURLSessionDataTask*)personDetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPPersonDetailURL HTTPBody:param completeHandler:completeHandler];

}
/** 人物列表 */
+ (NSURLSessionDataTask*)getPersonListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPPersonListURL HTTPBody:param completeHandler:completeHandler];

}

/** 投递BP 给 投资人 */
+ (NSURLSessionDataTask*)deliverBPToInvestorWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPDeliverBPURL HTTPBody:param completeHandler:completeHandler];
}

/** BP 列表*/
+ (NSURLSessionDataTask*)getBPListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPBPListURL HTTPBody:param completeHandler:completeHandler];

}

/** BP TO ME  列表*/
+ (NSURLSessionDataTask*)getBPToMeListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPMyBPListURL HTTPBody:param completeHandler:completeHandler];
}
/** 删除 BP  */
+ (NSURLSessionDataTask*)deleteBPWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPDeleteBPURL HTTPBody:param completeHandler:completeHandler];

}

/** 添加删除过的 BP*/
+ (NSURLSessionDataTask*)addBPWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPFileBPCollectURL HTTPBody:param completeHandler:completeHandler];

}

/** 招股书列表 */
+ (NSURLSessionDataTask*)ProspectusListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPProspetcusListURL HTTPBody:param completeHandler:completeHandler];
}

/** 活跃机构 */
+ (NSURLSessionDataTask*)getActiveJigouListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPActiveOrganizeURL HTTPBody:param completeHandler:completeHandler];

}

/** 热度机构 */
+ (NSURLSessionDataTask*)getHotJigouListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPHotOrganizeURL HTTPBody:param completeHandler:completeHandler];

}

/** 数据图谱 */
+ (NSURLSessionDataTask*)getDataTuPuWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPDataMapURL HTTPBody:param completeHandler:completeHandler];

}

/** 图谱细分领域 */
+ (NSURLSessionDataTask*)getTuPuAreaWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPDataMapAreaURL HTTPBody:param completeHandler:completeHandler];

}

/** 图谱 项目 */
+ (NSURLSessionDataTask*)getProductByTagWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPDataMapProductsURL HTTPBody:param completeHandler:completeHandler];
}

/** 图谱 报告 */
+ (NSURLSessionDataTask*)getReportByTagWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPDataMapReportURL HTTPBody:param completeHandler:completeHandler];

}
/** 图谱 趋势 */
+ (NSURLSessionDataTask*)getTrendByTagWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPDataMapTrendURL HTTPBody:param completeHandler:completeHandler];

}

/** 项目 添加到专辑  */
+ (NSURLSessionDataTask*)addProductToWorkTagWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPProductAddAlnumURL HTTPBody:param completeHandler:completeHandler];

}

/** 项目 用户加入的专辑tag */
+ (NSURLSessionDataTask*)getWorkTagByProductWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPProductTagURL HTTPBody:param completeHandler:completeHandler];

}

/** 用户新建专辑 （标签） */
+ (NSURLSessionDataTask*)tagAddNewWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPAddTagURL HTTPBody:param completeHandler:completeHandler];

}

/**
 机构工作流加入机构
 */
+ (NSURLSessionDataTask*)jigouWorkflowAddWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPWorkflowAddOrganizeURL HTTPBody:param completeHandler:completeHandler];

}



/**
 关注新闻动态
 */
+ (NSURLSessionDataTask*)attentionNewsListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPNewsOfWorkflowURL HTTPBody:param completeHandler:completeHandler];
}

/** 获取banner */
+ (NSURLSessionDataTask*)getBannerListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPBannerURL HTTPBody:param completeHandler:completeHandler];

}

#pragma mark --笔记
/** 新建笔记 */
+ (NSURLSessionDataTask*)addNewNoteWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPNoteAddURL HTTPBody:param completeHandler:completeHandler];

}

/** 笔记列表 */
+ (NSURLSessionDataTask*)getNoteListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPNoteListURL HTTPBody:param completeHandler:completeHandler];

}
/** 删除笔记 */
+ (NSURLSessionDataTask*)deleteNoteWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPNoteDeleteURL HTTPBody:param completeHandler:completeHandler];

}

/** 推送历史列表 */
+ (NSURLSessionDataTask*)getPushListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPPushListURL HTTPBody:param completeHandler:completeHandler];
}

/** 热门专辑 */
+ (NSURLSessionDataTask*)getHotAlbumWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPHotDataMapURL HTTPBody:param completeHandler:completeHandler];

}

/** 专辑库 */
+ (NSURLSessionDataTask*)getAlbumListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPAllDataMapURL HTTPBody:param completeHandler:completeHandler];

}

/** 反馈列表 */
+ (NSURLSessionDataTask*)getFeedBackListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
   
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPFeedBackListURL HTTPBody:param completeHandler:completeHandler];
}

/** 主 搜索 type为空返回全部、1：项目、2：机构、3：人物、4：公司、5：报告、6：赛道*/
+ (NSURLSessionDataTask*)mainSearchWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPMainSearchURL HTTPBody:param completeHandler:completeHandler];

}


/** 获取 用户信息 */
+ (NSURLSessionDataTask*)getUserInfoWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPUserInfoURL HTTPBody:param completeHandler:completeHandler];

}

/** 保存 工作经历 */
+ (NSURLSessionDataTask*)saveUserWorkExperienceWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPEditWorkExperienceURL HTTPBody:param completeHandler:completeHandler];
}

/** 删除 工作经历 */
+ (NSURLSessionDataTask*)delUserWorkExperienceWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPDeleteWorkExperienceURL HTTPBody:param completeHandler:completeHandler];

}

/** 存储 教育经历 */
+ (NSURLSessionDataTask*)saveUserEducationWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPEditEducationalExperienceURL HTTPBody:param completeHandler:completeHandler];
}

/** 删除 教育经历 */
+ (NSURLSessionDataTask*)delUserEducationWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPDeleteEducationalExperienceURL HTTPBody:param completeHandler:completeHandler];
}

/** 好友申请列表 */
+ (NSURLSessionDataTask*)getFriendApplyListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPFriendRequestListURL HTTPBody:param completeHandler:completeHandler];

}

/** 好友申请处理 */
+ (NSURLSessionDataTask*)dealFriendApplyWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPFriendRequestHandleURL HTTPBody:param completeHandler:completeHandler];

}

/** 修改 官方人物的基本信息 */
+ (NSURLSessionDataTask*)submitPersonInfoOfDetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:QMPUpdatePersonURL HTTPBody:param completeHandler:completeHandler];
}

/** 添加 编辑 官方人物的工作经历 */
+ (NSURLSessionDataTask*)submitPersonWorkOfDetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPSavePersonWorkExperienceURL HTTPBody:param completeHandler:completeHandler];
}

/** 添加 编辑 官方人物的教育经历 */
+ (NSURLSessionDataTask*)submitPersonEducationOfDetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPSavePersonEduExperienceURL HTTPBody:param completeHandler:completeHandler];

}


/** IPO */
+ (NSURLSessionDataTask*)getIPOlistWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPIPOListURL HTTPBody:param completeHandler:completeHandler];
}

/** IPO详情 */
+ (NSURLSessionDataTask*)getIPODetailWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPIPODetailURL HTTPBody:param completeHandler:completeHandler];
}

/** 公司 相关成员 */
+ (NSURLSessionDataTask*)getCompanyPersonWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:QMPProductMemberURL HTTPBody:param completeHandler:completeHandler];
}


/** 机构 相关成员 */
+ (NSURLSessionDataTask*)getJigouPersonWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:QMPOrganizeMemberURL HTTPBody:param completeHandler:completeHandler];
}

/** 并购库 事件 */
+ (NSURLSessionDataTask*)getBingGouEventWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPMergerListURL HTTPBody:param completeHandler:completeHandler];

}

/** 上市库 事件 */
+ (NSURLSessionDataTask*)getSmarketEventWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:QMPIPOEventURL HTTPBody:param completeHandler:completeHandler];
}

/** 新三板 企业库 */
+ (NSURLSessionDataTask*)getThreeBoardProductWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPNEEQListURL HTTPBody:param completeHandler:completeHandler];
}


/** A股 企业库 */
+ (NSURLSessionDataTask*)getAStockProductWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPAStockListURL HTTPBody:param completeHandler:completeHandler];
}
/** 投资人说 */
+ (NSURLSessionDataTask*)getInvestorCommentWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPInvestorCommentURL HTTPBody:param completeHandler:completeHandler];
}

/** 学校的人物 */
+ (NSURLSessionDataTask*)getSchoolPersonWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPSaveSchoolPersonListURL HTTPBody:param completeHandler:completeHandler];
}


/** 推荐的好友 */
+ (NSURLSessionDataTask*)getRecommendFriendWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPRecommendFriendsURL HTTPBody:param completeHandler:completeHandler];
}

/** 领域 项目 */
+ (NSURLSessionDataTask*)getProOfLingyuWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPAreaURL HTTPBody:param completeHandler:completeHandler];

}

/** 领域  趋势图 */
+ (NSURLSessionDataTask*)getPicOfLingyuWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPAreaTrendURL HTTPBody:param completeHandler:completeHandler];

}

/** 机构  在服项目 */
+ (NSURLSessionDataTask*)getJigouFAProductWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:QMPOrganizeFAServiceCaseURL HTTPBody:param completeHandler:completeHandler];

}

/** 获取用户权限 */
+ (NSURLSessionDataTask*)getUserPrivilegeWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPUserPrivilegeURL HTTPBody:param completeHandler:completeHandler];
}

/* 获取用户权限 返回是否 BOOL*/
+ (NSURLSessionDataTask*)getUserPrivilegeWithType:(NSString*)typeStr resultHandle:(BoolResultHandler)boolResult{
   
    return [AppNetRequest getUserPrivilegeWithParameter:@{@"type":typeStr} completionHandle:^(NSURLSessionDataTask *dataTask,
                                                                                              id resultData, NSError *error) {
                if ([resultData[@"status"] integerValue] == 1) {
                    
                    boolResult(dataTask,true,error);
                    
                }else{
                    
                    boolResult(dataTask,false,error);

                    NSString *msg = resultData[@"msg"];
                    if ([msg containsString:@"认证"] && ([WechatUserInfo shared].claim_type.integerValue != 2) && ([WechatUserInfo shared].claim_type.integerValue != 1)) {
                        [PublicTool alertActionWithTitle:@"提示" message:resultData[@"msg"] leftTitle:@"去认证" rightTitle:@"确定" leftAction:^{
                            [[AppPageSkipTool shared] appPageSkipToClaimPage];
                        } rightAction:^{
                            
                        }];
                    } else {
                        [PublicTool alertActionWithTitle:@"提示" message:resultData[@"msg"] btnTitle:@"确定" action:^{
                            
                        }];
                    }
                }
            }];
}


+ (NSURLSessionDataTask*)getLeftCountOfExchangeCardWithParameter:(NSDictionary*)param completionHandle:(BoolResultHandler)resultHandle{
    //加剩余次数限制
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/checkCardNum" HTTPBody:@{} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        if (resultData) {
            NSInteger leftCount = [resultData[@"left_count"] integerValue];
            if ([resultData[@"msg"] isEqualToString:@"success"]) {
                if (leftCount == 0) {
                    [PublicTool alertActionWithTitle:@"提示" message:@"您的交换联系方式次数已用完\n请明日再来" leftTitle:@"取消" rightTitle:@"交换联系方式" leftActionClick:^{
                        
                    } rightActionClick:^{
                        
                    } leftEnable:YES rightEnable:NO];
                }else{
                    resultHandle(dataTask,YES,error);
                }
            }else if(![PublicTool isNull:resultData[@"msg"]]){ //弹框文案
                if (leftCount == 0) {
                    [PublicTool alertActionWithTitle:@"提示" message:resultData[@"msg"] leftTitle:@"取消" rightTitle:@"交换" leftActionClick:^{
                        
                    } rightActionClick:^{
                        
                    } leftEnable:YES rightEnable:NO];
                    
                }else{
                    
                    [PublicTool alertActionWithTitle:@"提示" message:resultData[@"msg"] leftTitle:@"取消" rightTitle:@"交换" leftActionClick:^{
                        
                    } rightActionClick:^{
                        resultHandle(dataTask,YES,error);
                    } leftEnable:YES rightEnable:YES];
                }
                
            }
        }
    }];
}

+ (void)updateUnreadCountWithKey:(NSString*)saveKey type:(NSString*)typeStr completeHandler:(CompleteHandler)completeHandler{
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"user/updateUnreadCount" HTTPBody:@{@"keyword":[WechatUserInfo shared].vip,@"type":typeStr} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
       
        if (resultData && [resultData[@"message"] isEqualToString:@"success"] && saveKey) {
            [[WechatUserInfo shared] setValue:@"0" forKey:saveKey];
            [[WechatUserInfo shared] save];
        }
    }];
}

/**项目机构人物 关注取关*/
+ (NSURLSessionDataTask*)attentFunctionWithParam:(NSDictionary*)param completeHandler:(CompleteHandler)completeHandler{
   
   return  [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPAttentURL HTTPBody:param completeHandler:completeHandler];
}

/** 项目机构人物  获取点赞关注评论数量*/
+ (NSURLSessionDataTask*)getCountOfDetailWIthParam:(NSDictionary*)param completeHandler:(CompleteHandler)completeHandler{
    return  [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"common/getCounts" HTTPBody:param completeHandler:completeHandler];
}

/** 项目机构人物 动态  点赞操作*/
+ (NSURLSessionDataTask*)likeOrCancelwithParam:(NSDictionary*)param completeHandler:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Activity/activityLike" HTTPBody:param completeHandler:completeHandler];
}


+ (NSURLSessionDataTask *)getContactMemberOfProductWithParam:(NSDictionary*)param completeHandler:(CompleteHandler)completeHandler {
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPProductMemberContactURL HTTPBody:param completeHandler:completeHandler];
}

/** 我的关注列表 新  */
+ (NSURLSessionDataTask *)getAttentionListWithParam:(NSDictionary*)param completeHandler:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:QMPUserNewFollowedURL HTTPBody:param completeHandler:completeHandler];
}

+ (NSURLSessionDataTask *)getUserFollowListWithParam:(NSDictionary*)param completeHandler:(CompleteHandler)completeHandler {
    return [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:QMPUserFollowedURL HTTPBody:param completeHandler:completeHandler];
}


/** 项目投资人列表 */
+ (NSURLSessionDataTask*)getProductInvestorListWithParameter:(NSDictionary*)param completionHandle:(CompleteHandler)completeHandler{
    return [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMProductInvestorURL HTTPBody:param completeHandler:completeHandler];
    
}
@end
