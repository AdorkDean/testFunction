//
//  AppPageSkipTool.h
//  CommonLibrary
//
//  Created by QMP on 2018/11/7.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AppPageSkipProtocol

@optional
#pragma mark ---登录相关
/** 去登录 */
- (void)appPageSkipToLogin;
- (void)appPageSkipToPhoneLogin;

/** 去绑定手机 */
- (void)appPageSkipToBindPhone;
- (void)appPageSkipToBindPhoneFinish:(void(^)(NSString* bindPhone))bindFinish;
/** 去初始化关注 */
- (void)appPageSkipToInitFocus;

/* 刷新用户信息 */
- (void)refreshUserInfo;

- (void)setRootController;

#pragma mark ---人物相关
- (void)appPageSkipToPersonDetail:(NSString*)personId;
- (void)appPageSkipToPersonDetail:(NSString*)personId fromClaimReq:(BOOL)fromClaim;

- (void)appPageSkipToUserDetail:(NSString*)unionid;

#pragma mark ---项目相关
- (void)appPageSkipToProductDetail:(NSDictionary*)productParam;

#pragma mark ---机构相关
- (void)appPageSkipToJigouDetail:(NSDictionary*)jigouParam;

#pragma mark --动态相关
- (void)appPageSkipToActivitySquare;
- (void)appPageSkipToActivityHotOrAnonymous:(BOOL)hot;

//跳转到动态指定tag
- (void)appPageSkipToActivityTag:(NSString*)tagName activityID:(NSString*)activityID;

@end



@interface AppPageSkipTool : NSObject

+ (instancetype)shared;

-(void)appPageSkipToPersonDetail:(NSString *)personId;
-(void)appPageSkipToPersonDetail:(NSString *)personId nameLabBgColor:(UIColor*)nameLabColor; //无header的背景色
-(void)appPageSkipToUserDetail:(NSString *)unionid;

-(void)appPageSkipToPersonDetail:(NSString *)personId fromClaimReq:(BOOL)fromClaim;

- (void)appPageSkipToClaimPage;
- (void)appPageSkipToMainSearch;

#pragma mark --项目机构
- (void)appPageSkipToDetail:(NSString*)urlStr;
- (void)appPageSkipToProductDetail:(NSDictionary*)productParam;
- (void)appPageSkipToRegisterDetail:(NSDictionary*)registerDic;

#pragma mark ---机构相关
- (void)appPageSkipToJigouDetail:(NSDictionary*)jigouParam;

#pragma mark ---聊天相关
- (void)appPageSkipToChatView:(NSString *)userCode verifyUserClaim:(BOOL)verifyUser;
- (void)appPageSkipToChatView:(NSString *)userCode;
- (void)appPageSkipToConversationList;

#pragma mark ---动态相关
- (void)appPageSkipToActivityPost;
- (void)appPageSkipToActivityPostNeedGo:(BOOL)go linkUrl:(NSString*)linkUrl;
- (void)appPageSkipToActivityDetail:(NSString*)activityID;
- (void)appPageSkipToActivityCommunity:(NSString*)communityName activityID:(NSString*)activityID;

@end

NS_ASSUME_NONNULL_END
