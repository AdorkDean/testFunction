/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

//
#import "EaseConversationListViewController.h"

@interface ConversationListController : EaseConversationListViewController

@property(nonatomic,strong)NSDictionary *systemMsgDic; //系统通知
@property(nonatomic,strong)NSDictionary *userActivityMsgDic; //互动提醒
@property(nonatomic,strong)NSArray *applyArr; //好友申请第一个

- (void)refresh;
- (void)refreshDataSource;

- (void)isConnect:(BOOL)isConnect;
- (void)networkChanged:(EMConnectionState)connectionState;

@end
