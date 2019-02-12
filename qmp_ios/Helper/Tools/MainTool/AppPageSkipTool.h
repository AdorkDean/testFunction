//
//  AppPageSkipTool.h
//  CommonLibrary
//
//  Created by QMP on 2018/11/7.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppPageSkipTool : NSObject

+ (instancetype)shared;

#pragma mark --账户
-(void)appPageSkipToPhoneLogin;
-(void)appPageSkipToBindPhone;
-(void)appPageSkipToBindPhoneFinish:(void (^)(NSString * _Nonnull))bindFinish;
-(void)appPageSkipToLogin;
- (void)refreshUserInfo;
- (void)setRootController;
- (void)appPageSkipToActivitySquare;
- (void)appPageSkipToActivityHotOrAnonymous:(BOOL)hot;
-(void)appPageSkipToActivityTag:(NSString *)tagName activityID:(NSString *)activityID;

#pragma mark --用户人物

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

