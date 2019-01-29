//
//  NotificationHandle.m
//  CommonLibrary
//
//  Created by QMP on 2018/10/30.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "NotificationHandle.h"
#import "ChatHelper.h"
#import <UserNotifications/UserNotifications.h>
#import <JPUSHService.h>
#import "NewsWebViewController.h"
#import "OneSquareListViewController.h"
#import "GroupModel.h"
#import "WebViewController.h"
#import "OnlyContentController.h"
#import "BPMgrController.h"
#import "FriendApplyListController.h"
#import "FriendModel.h"
#import "EaseSDKHelper.h"
#import "ProductContactsController.h"

@implementation NotificationHandle

static NotificationHandle *notifiHandle = nil;
static dispatch_once_t onceToken = 0;
+ (instancetype)shared{
    dispatch_once(&onceToken, ^{
        notifiHandle = [[NotificationHandle alloc]init];
    });
    return notifiHandle;
}

- (void)resetAppBadge{
    [JPUSHService resetBadge];
}


#pragma mark --通知内容的处理

- (void)handleNotificationContent:(id)notification{
    
    [JPUSHService resetBadge];
    
    NSMutableDictionary *userInfo;
    
    if ([notification isKindOfClass:[NSDictionary class]]) {
        userInfo = [NSMutableDictionary dictionaryWithDictionary:notification];
    }else{
        
        UNNotification *tf = notification;
        userInfo = [NSMutableDictionary dictionaryWithDictionary:tf.request.content.userInfo];
    }
    
    
    //判断是消息
    if ([userInfo.allKeys containsObject:@"ConversationChatter"]) {
        
        QMPLog(@"环信推送---------%@",[self logDic:userInfo]);
        
        [[ChatHelper shareHelper] userResponseRemoteNotification:notification];
        return;
    }
    
    //还是极光推送
    [QMPEvent event:@"push_open"];
    if ([userInfo.allKeys containsObject:@"data"] && userInfo[@"data"] ) { //后台推送
        QMPLog(@"后台推送信息---------%@",[self logDic:userInfo]);
        NSDictionary *dic = userInfo[@"data"];
        NSDictionary *alert = userInfo[@"aps"][@"alert"];
        NSString *type = dic[@"type"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), ^{
            if (type.integerValue == 1 && ![PublicTool isNull:dic[@"detail"]]) {  //机构
                [self enterJigouDetail:dic];
                [self setMessageReadedCount:@"HT_PUSH_MESSAGE_READED_COUNT"];
            }else if (type.integerValue == 2 && ![PublicTool isNull:dic[@"detail"]]) {  //项目
                [self enterCompanyDetail:dic];
                [self setMessageReadedCount:@"HT_PUSH_MESSAGE_READED_COUNT"];
            }
//            else if (type.integerValue == 3 && ![PublicTool isNull:dic[@"activity_id"]]) {  //动态推送
//                [[ToLogin shared].delegate appPageSkipToActivityTag:@"推送" activityID:dic[@"activity_id"]];
//                [self setMessageReadedCount:@"HT_PUSH_MESSAGE_READED_COUNT"];
//            }
            else if (type.integerValue == 3 && ![PublicTool isNull:dic[@"url"]]) {  //url
                [self enterWebDetail:dic];
                [self setMessageReadedCount:@"HT_PUSH_MESSAGE_READED_COUNT"];
            }else if (type.integerValue == 4 && ![PublicTool isNull:dic[@"name"]]) {  //专辑
                [self enterSquareList:dic];
                [self setMessageReadedCount:@"HT_PUSH_MESSAGE_READED_COUNT"];
            }else if(type.integerValue == 5){
                NSString *body = alert[@"body"];
                NSInteger content_type = [dic[@"content_type"] integerValue];
                if(content_type == 2 && ![PublicTool isNull:dic[@"person_id"]]){ //交换的名片已入驻 （旧）
                    [[AppPageSkipTool shared] appPageSkipToPersonDetail:dic[@"person_id"]];
                    
                }else if(content_type == 3 && ![PublicTool isNull:dic[@"usercode"]]&& ![PublicTool isNull:dic[@"apply_id"]]){ //收到交换通知
                    [self enterChatView:dic];
                    
                }else if(content_type == 4){ //委托联系列表
                    [self enterProductContact];
                    
                }else if ([body containsString:@"您收到了一份BP"]) {
                    [self enterMyBp];
                }else{
                    [self enterOnlyContent:alert];
                }
                
            }else if(type.integerValue == 6 && ![PublicTool isNull:dic[@"day_url"]]) { //日报
                [self enterRibao];
                [self setMessageReadedCount:@"HT_PUSH_MESSAGE_READED_COUNT"];
            }else if(type.integerValue == 7 && ![PublicTool isNull:dic[@"week_url"]]) { //日报
                [self enterZhouBao];
                [self setMessageReadedCount:@"HT_PUSH_MESSAGE_READED_COUNT"];
            }
        });
    }
    
    //通知已读
    NSString *type = @"新系统通知";
    NSString *key = @"system_notification_count";
    [AppNetRequest updateUnreadCountWithKey:key type:type completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
    }];
}

- (void)enterProductContact{
    ProductContactsController *cardVC = [[ProductContactsController alloc]init];
    [[PublicTool topViewController].navigationController pushViewController:cardVC animated:YES];
}

- (void)enterChatView:(NSDictionary*)dic{
    
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    
    NSMutableArray *aaa = [NSMutableArray array];
    for (EMConversation *conversation in conversations) {
        QMPLog(@"%@", conversation.conversationId);
        [aaa addObject:conversation.conversationId];
    }
    
    if (![aaa containsObject:dic[@"usercode"]]) {
        // 生成回话
        NSInteger changeType = [dic[@"apply_type"] integerValue];
        NSString *msg = changeType == 1 ? @"[交换电话]" : @"[交换微信]";
        NSString *type = changeType == 1 ? @"exphone1" : @"exwechat1";
        NSString *headUrl = [PublicTool isNull:dic[@"icon"]]?@"":dic[@"icon"];
        NSString *nickname = [PublicTool isNull:dic[@"nickname"]]?@"":dic[@"nickname"];
        EMMessage *message = [EaseSDKHelper getTextMessage:msg to:[WechatUserInfo shared].usercode messageType:EMChatTypeChat messageExt:@{@"userAvatar":headUrl,@"userNick":nickname,@"type":type,@"forme":@"1",@"aid":dic[@"apply_id"]}];
        message.from = dic[@"usercode"];
        message.to = [WechatUserInfo shared].usercode;
        message.conversationId = dic[@"usercode"];
        message.direction = EMMessageDirectionReceive;
        
        [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
            
        } completion:^(EMMessage *message, EMError *error) {
            
        }];
    }
    
    [[AppPageSkipTool shared] appPageSkipToChatView:dic[@"usercode"]];

}


- (void)setMessageReadedCount:(NSString *)DFkey{
    NSInteger messageReadedCount = [[USER_DEFAULTS objectForKey:DFkey] integerValue];
    messageReadedCount ++;
    [USER_DEFAULTS setValue:@(messageReadedCount) forKey:DFkey];
}

- (void)enterFriendApply{
    FriendApplyListController *applyVC = [[FriendApplyListController alloc]init];
    [[PublicTool topViewController].navigationController pushViewController:applyVC animated:YES];
    
}

- (void)enterMyBp {
    BPMgrController *mybpVC = [[BPMgrController alloc] init];
    [[PublicTool topViewController].navigationController pushViewController:mybpVC animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [mybpVC selectedIndexPage:1];
    });
}

- (void)enterOnlyContent:(NSDictionary*)dic{
    
    OnlyContentController *onlyContentVC = [[OnlyContentController alloc]init];
    if (![dic.allKeys containsObject:@"body"]) {
        return;
    }
    
    NSDictionary *dict = @{@"title":dic[@"title"],@"content":dic[@"body"]};
    onlyContentVC.dic = dict;
    [[PublicTool topViewController].navigationController pushViewController:onlyContentVC animated:YES];
    
}
- (void)enterSquareList:(NSDictionary*)dic{
    
    GroupModel *groupM = [[GroupModel alloc]initWithDictionary:dic error:nil];
    OneSquareListViewController *listVC = [[OneSquareListViewController alloc] init];
    listVC.groupModel = groupM;
    listVC.action = @"ManagerSquare";
    
    [[PublicTool topViewController].navigationController pushViewController:listVC animated:YES];
}

- (void)enterWebDetail:(NSDictionary*)dic{
    
    URLModel *urlM = [[URLModel alloc]init];
    urlM.url = dic[@"url"];
    
    NewsWebViewController *webVC = [[NewsWebViewController alloc]initWithUrlModel:urlM];
    
    if (![PublicTool isNull:dic[@"detail"]] && ![PublicTool isNull:dic[@"company"]]) {
        webVC.companyDic = dic;
    }
    
    [[PublicTool topViewController].navigationController pushViewController:webVC animated:YES];
    
}

- (void)enterRibao{
    
    WebViewController *VC = [[WebViewController alloc]init];
    VC.url = RONGZIXINWEN_BASE;
    VC.titleLabStr = @"融资日报";
    VC.hidesBottomBarWhenPushed = YES;
    [[PublicTool topViewController].navigationController pushViewController:VC animated:YES];
}

- (void)enterZhouBao{
    
    WebViewController *VC = [[WebViewController alloc]init];
    VC.url = RONGZIZHOUBAO_NEWS;
    VC.titleLabStr = @"融资周报";
    VC.hidesBottomBarWhenPushed = YES;//
    [[PublicTool topViewController].navigationController pushViewController:VC animated:YES];
}

- (void)enterJigouDetail:(NSDictionary*)dic{
    NSString *detail = dic[@"detail"];
    NSDictionary *paramDic = [PublicTool toGetDictFromStr:detail];
    [[AppPageSkipTool shared] appPageSkipToJigouDetail:paramDic];
    
}
- (void)enterCompanyDetail:(NSDictionary*)dic{
    
    NSString *detail = dic[@"detail"];
    NSDictionary *paramDic = [PublicTool toGetDictFromStr:detail];
    [[AppPageSkipTool shared] appPageSkipToProductDetail:paramDic];
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    return str;
    
}

#pragma mark --UIApplication--
- (void)applicationWillEnterForeground:(UIApplication*)application{
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [JPUSHService handleRemoteNotification:userInfo];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [JPUSHService handleRemoteNotification:userInfo];
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
}
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [self handleNotificationContent:response.notification];
    }
    
}


#pragma mark - login changed

- (void)loginStateChange:(NSNotification *)notification
{
    BOOL loginSuccess = [notification.object boolValue];
    
    if (loginSuccess) {//登陆成功加载主窗口控制器
        
    }else{//登陆失败加载登陆页面控制器
        
    }
    
    
}


@end
