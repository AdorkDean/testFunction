//
//  ChatHelper.m
//  qmp_ios
//
//  Created by QMP on 2017/11/28.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "ChatHelper.h"
#import <UserNotifications/UserNotifications.h>
#import "ChatViewController.h"
#import "ConversationListController.h"
#import "FriendModel.h"
#import "EaseUI.h"

static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static NSString *kGroupName = @"GroupName";

@interface ChatHelper()<EMClientDelegate,EMChatManagerDelegate,EMContactManagerDelegate,EMGroupManagerDelegate,EMChatroomManagerDelegate>
@property (nonatomic, assign) BOOL helped;
@property (nonatomic, assign) BOOL helped2;
@end

@implementation ChatHelper

static ChatHelper *helper = nil;


+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[ChatHelper alloc] init];
    });
    return helper;
}

- (void)dealloc
{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];

}

- (id)init
{
    self = [super init];
    if (self) {
//        [self initHelper];
    }
    return self;
}

- (void)bindDeviceToken:(NSData*)deviceToken{
    [[EMClient sharedClient]bindDeviceToken:deviceToken];
}

#pragma mark - init

- (void)initHelper
{
    if (self.helped) {
        return;
    }
    self.helped = YES;
#ifdef REDPACKET_AVALABLE
    [[RedPacketUserConfig sharedConfig] beginObserveMessage];
#endif
    
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];

#if DEMO_CALL == 1
    [DemoCallManager sharedManager];
#endif
}


#pragma mark --账户
- (void)registUser{
    
    [[EMClient sharedClient] registerWithUsername:[WechatUserInfo shared].usercode password:[WechatUserInfo shared].usercode completion:^(NSString *aUsername, EMError *aError) {
        if (!aError) {
            QMPLog(NSLocalizedString(@"register.success", @"Registered successfully, please log in"));
        }else{
            switch (aError.code) {
                case EMErrorServerNotReachable:
                    QMPLog(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                    break;
                case EMErrorUserAlreadyExist:
                    QMPLog(NSLocalizedString(@"register.repeat", @"You registered user already exists!"));
                    break;
                case EMErrorNetworkUnavailable:
                    QMPLog(NSLocalizedString(@"error.connectNetworkFail", @"No network connection!"));
                    break;
                case EMErrorServerTimeout:
                    QMPLog(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                    break;
                case EMErrorServerServingForbidden:
                    QMPLog(NSLocalizedString(@"servingIsBanned", @"Serving is banned"));
                    break;
                default:
                    QMPLog(NSLocalizedString(@"register.fail", @"Registration failed"));
                    break;
            }
        }
        
        if (!aError) {
            QMPLog(@"注册环信成功-------%@  --error--%@",aUsername,aError);
            
            [[EMClient sharedClient] loginWithUsername:[WechatUserInfo shared].usercode password:[WechatUserInfo shared].usercode completion:^(NSString *aUsername, EMError *aError) {
                if (!aError) {

                }
            }];
        }
    }];


}

- (void)loginUser{

    //登录 环信
    
    if ([ToLogin isLogin] && ![EMClient sharedClient].isAutoLogin) {
       
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            [[EMClient sharedClient] loginWithUsername:[WechatUserInfo shared].usercode password:[WechatUserInfo shared].usercode completion:^(NSString *aUsername, EMError *aError) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!aError) {
                        //设置是否自动登录
                        [[EMClient sharedClient].options setIsAutoLogin:YES];
                        
                        //保存最近一次登录用户名
                        [self kefuWelCome];
                        //发送自动登陆状态通知
                        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:[NSNumber numberWithBool:YES]];
                        
                    }else{
                        
                        [[EMClient sharedClient] loginWithUsername:[WechatUserInfo shared].usercode password:[WechatUserInfo shared].usercode completion:^(NSString *aUsername, EMError *aError) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!aError) {
                                    //设置是否自动登录
                                    [[EMClient sharedClient].options setIsAutoLogin:YES];
                                    
                                    //保存最近一次登录用户名
                                    [self kefuWelCome];
                                    //发送自动登陆状态通知
                                    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:[NSNumber numberWithBool:YES]];
                                }
                            });
                        }];
                        
                    }
                });
            }];
        });
        
    }

}

- (void)kefuWelCome{
    
    if ([EMClient sharedClient].isLoggedIn) {
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:QMPHelperUserCode type:EMConversationTypeChat createIfNotExist:NO];
        
        EMMessage *latestMessage = [conversation latestMessage];
        if (latestMessage) {
            return;
        }
        if (self.helped2) {
            return;
        }
        self.helped2 = YES;
        
        //调到增辉客服
        EMMessage *message = [EaseSDKHelper getTextMessage:kDefaultWel to:[WechatUserInfo shared].usercode messageType:EMChatTypeChat messageExt:@{@"userAvatar":kHeadImgUrl,@"userNick":kCustomerName}];
        message.to = [WechatUserInfo shared].usercode;
        message.from = QMPHelperUserCode;
        message.conversationId = QMPHelperUserCode;
        message.direction = EMMessageDirectionReceive;
        
        [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
            
        } completion:^(EMMessage *message, EMError *error) {
            if (!error) {
                
            }
        }];

    }
    
}
- (void)loginOutUser{
    //退出登录 环信
    if ([ToLogin isLogin] && [EMClient sharedClient].isLoggedIn) {
        
        [[EMClient sharedClient] logout:YES];
    }

}

- (void)addBlackList:(NSString *)QID{
      [[EMClient sharedClient].contactManager addUserToBlackList:QID completion:^(NSString *aUsername, EMError *aError) {
        QMPLog(@"name------%@,error----%@",aUsername,aError.errorDescription);
      }];
}

- (void)removeBlackList:(NSString*)QID{
    [[EMClient sharedClient].contactManager removeUserFromBlackList:QID];
    [ChatHelper shareHelper].blackList = nil;
    
}


- (void)loginStateChange:(NSNotification *)notification
{
    BOOL loginSuccess = [notification.object boolValue];
    
    if (loginSuccess) {//登陆成功加载主窗口控制器
        
    }else{//登陆失败加载登陆页面控制器
        
    }
    
    
}

#pragma mark ---消息
- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.type == EMConversationTypeChatRoom)) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        for (EMConversation *conversation in needRemoveConversations) {
            [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
                QMPLog(@"删除成功是否---%@",aError);
            }];
            
        }
    }
}



- (void)userResponseLocalNotification:(UILocalNotification*)messageTf{
    //进入聊天窗口
    
    NSDictionary *dic = messageTf.userInfo;
    if (!dic[@"ConversationChatter"]) {
        return;
    }
    
    if ([PublicTool isNull:dic[@"userAvatar"]]) {
        
        if (![[PublicTool topViewController] isKindOfClass:NSClassFromString(@"ConversationListController")] && ![[PublicTool topViewController] isKindOfClass:NSClassFromString(@"ChatViewController")]) {
            
            ConversationListController *vc = [[ConversationListController alloc]init] ;
            vc.title = @"消息";
            [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
            return;
            
        }else if([[PublicTool topViewController] isKindOfClass:NSClassFromString(@"ChatViewController")]){
            for (UIViewController *vc in [[PublicTool topViewController].navigationController childViewControllers]) {
                if ([vc isKindOfClass:NSClassFromString(@"ConversationListController")]) {
                    [[PublicTool topViewController].navigationController popToViewController:vc animated:YES];
                    return;
                }
            }
        }
        ConversationListController *vc = (ConversationListController*)[PublicTool topViewController];
        [vc refresh];
        return;
    }
    
    if ([[PublicTool topViewController] isKindOfClass:[ChatViewController class]]) {
        [[PublicTool topViewController].navigationController popViewControllerAnimated:YES];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3), dispatch_get_main_queue(), ^{
        [[AppPageSkipTool shared] appPageSkipToChatView:dic[@"ConversationChatter"]];

    });
    
}

- (void)userResponseRemoteNotification:(id)messageTf{
    
    //iOS10之前
    NSDictionary *dic;
    if ([messageTf isKindOfClass:[NSDictionary class]]) {
        
        //进入聊天窗口
        dic = messageTf;
        
    }else{ //iOS10 之后
        
        UNNotification *tf = messageTf;
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:tf.request.content.userInfo];
        
        //环信后台推送进入也是这里
        if ([userInfo.allKeys containsObject:@"userAvatar"]) {
            dic = userInfo;
            
        }else{
            
            NSString *from = userInfo[@"f"];
            
            [userInfo setValue:from forKey:@"ConversationChatter"];
            FriendModel *friend1 = [PublicTool friendForUsercode:from];
            
            if (!friend1.nickname) {
                EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:from.lowercaseString type:EMConversationTypeChat createIfNotExist:NO];
                NSDictionary *dic = conversation.lastReceivedMessage.ext;
                
                [userInfo setValue:dic[@"userAvatar"] forKey:@"userNick"];
                [userInfo setValue:dic[@"userNick"] forKey:@"userAvatar"];
                
            }else{
                
                [userInfo setValue:friend1.nickname forKey:@"userNick"];
                [userInfo setValue:friend1.headimgurl forKey:@"userAvatar"];
                
            }
            dic = userInfo;
        }
        
    }
    
    if (!dic[@"ConversationChatter"]) {
        return;
    }
    
    //没有个人信息 进入消息列表
    if ([PublicTool isNull:dic[@"userAvatar"]]) {
        if (![[PublicTool topViewController] isKindOfClass:NSClassFromString(@"ConversationListController")]) {
           
            ConversationListController *vc = [[ConversationListController alloc]init] ;
            vc.title = @"消息";
            [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
            return;

        }else{
            
            ConversationListController *vc = (ConversationListController*)[PublicTool topViewController];
            [vc refresh];
            return;
        }

    }
    
    //在聊天页面且不是发消息的人
    if ([[PublicTool topViewController] isKindOfClass:[ChatViewController class]]) {
       
        ChatViewController *chatVC = (ChatViewController*)[PublicTool topViewController];
        if([chatVC.conversation.conversationId isEqualToString:dic[@"ConversationChatter"]]){
            
            return;
        }else{
            
            [[PublicTool topViewController].navigationController popViewControllerAnimated:NO];
        }
    }
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3), dispatch_get_main_queue(), ^{
        [[AppPageSkipTool shared] appPageSkipToChatView:dic[@"ConversationChatter"]];
    });
    
    
}



- (void)showNotificationWithMessage:(id)messag
{
    EMMessage *message = (EMMessage*)messag;
    NSString *header =  message.ext[@"userAvatar"];
    NSString *nickName = message.ext[@"userNick"];
    
    
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    NSString *alertBody = nil;
    //根据message的from判断是后端推送 还是  消息
    
    if (options.displayStyle == EMPushDisplayStyleMessageSummary) { //显示消息内容
        EMMessageBody *messageBody = message.body;
        NSString *messageStr = nil;
        switch (messageBody.type) {
            case EMMessageBodyTypeText:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case EMMessageBodyTypeImage:
            {
                messageStr = @"您收到了一个图片消息";
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                messageStr = @"您收到了一个位置消息";
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                messageStr = @"您收到了一条语音消息";
            }
                break;
            case EMMessageBodyTypeVideo:{
                messageStr = NSLocalizedString(@"message.video", @"Video");
            }
                break;
            default:
                break;
        }
        
        do {
            
           
    
            NSString *title = nickName;
            if (message.chatType == EMChatTypeGroupChat) {
                NSDictionary *ext = message.ext;
                if (ext && ext[kGroupMessageAtList]) {
                    id target = ext[kGroupMessageAtList];
                    if ([target isKindOfClass:[NSString class]]) {
                        if ([kGroupMessageAtAll compare:target options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                            alertBody = [NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"group.atPushTitle", @" @ me in the group")];
                            break;
                        }
                    }
                    else if ([target isKindOfClass:[NSArray class]]) {
                        NSArray *atTargets = (NSArray*)target;
                        if ([atTargets containsObject:[EMClient sharedClient].currentUsername]) {
                            alertBody = [NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"group.atPushTitle", @" @ me in the group")];
                            break;
                        }
                    }
                }
                NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
                for (EMGroup *group in groupArray) {
                    if ([group.groupId isEqualToString:message.conversationId]) {
                        title = [NSString stringWithFormat:@"%@(%@)", message.from, group.subject];
                        break;
                    }
                }
            }
            else if (message.chatType == EMChatTypeChatRoom)
            {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[EMClient sharedClient] currentUsername]];
                NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
                NSString *chatroomName = [chatrooms objectForKey:message.conversationId];
                if (chatroomName)
                {
                    title = [NSString stringWithFormat:@"%@(%@)", message.from, chatroomName];
                }
            }
//如果是后端推送内容，另外设置
            alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
            
        } while (0);
    }
    else{
        alertBody = @"您收到一条聊天消息";
    }
    
   
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
    [userInfo setValue:message.conversationId forKey:kConversationChatter];
    [userInfo setValue:header?header:@"" forKey:@"userAvatar"];
    [userInfo setValue:nickName?nickName:@"" forKey:@"userNick"];

    //发送本地推送
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.sound = [UNNotificationSound defaultSound];
        content.body =alertBody;
        content.badge = @(1);
        content.userInfo = userInfo;
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:message.messageId content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
    }
    else {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date]; //触发通知的时间
        notification.alertBody = alertBody;
        notification.applicationIconBadgeNumber = 1;
//        notification.alertAction = NSLocalizedString(@"open", @"Open");
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.userInfo = userInfo;
        
        //发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}



#pragma mark ---EMClientDelegate
- (void)connectionStateDidChange:(EMConnectionState)aConnectionState{
    QMPLog(@"SDK 链接状态----%d",aConnectionState);
    if (aConnectionState == EMConnectionConnected) {
        [[ChatHelper shareHelper] loginUser];
    }
}

#pragma mark --EMChatManagerDelegate
- (void)conversationListDidUpdate:(NSArray *)aConversationList{
   
    //刷新列表
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MESSAGE_RECEIVE object:nil];

}


- (void)userAccountDidForcedToLogout:(EMError *)aError{
//    [PublicTool alertActionWithTitle:@"提示" message:@"账号被强制退出" leftTitle:@"取消" rightTitle:@"重新登录" leftAction:^{
//
//    } rightAction:^{
//        [self loginUser];
//    }];
//    [self loginUser];
}

-(void)userAccountDidLoginFromOtherDevice{
    
//    [self loginUser];
//    [PublicTool alertActionWithTitle:@"提示" message:@"账号在另一台设备登录，消息将无法发送和接收" leftTitle:@"取消" rightTitle:@"重新登录" leftAction:^{
//
//    } rightAction:^{
//        [self loginUser];
//    }];
}

#pragma mark - Message

/*!
 *  \~chinese
 *  收到消息
 */
- (void)messagesDidReceive:(NSArray *)aMessages{
    
    //刷新列表
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MESSAGE_RECEIVE object:nil];
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    switch (state) {
        case UIApplicationStateActive:

            break;
            
        case UIApplicationStateInactive:
            break;
            
        case UIApplicationStateBackground:
            [self showNotificationWithMessage:aMessages.lastObject];
            break;
        default:
            break;
    }
    
//    EMMessage *a = [aMessages lastObject];
//    NSDictionary *ext = a.ext;
//    if ([ext.allKeys containsObject:@"type"]) {
//        if ([ext[@"type"] isEqualToString:@"exphone2"]) {
//            EMMessage *message = [EaseSDKHelper getTextMessage:@"[电话消息]" to:a.conversationId messageType:EMChatTypeChat messageExt:@{@"userAvatar":[WechatUserInfo shared].headimgurl,@"userNick":[WechatUserInfo shared].nickname,@"type":@"exphone3",@"phone":[WechatUserInfo shared].bind_phone}];
//            message.conversationId = a.conversationId;
//
//            [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
//
//            } completion:^(EMMessage *aMessage, EMError *aError) {
//
//                if (!aError) {
//                    EMError *saveError = nil;
//                }else {
//                    if (aError.code == EMErrorUserPermissionDenied) {
//                        //                [self appendMessage:MESSAGE_REJECTED];
//                    }else{
//                        [PublicTool showMsg:@"消息发送失败"];
//                    }
//                }
//            }];
//        } else if ([ext[@"type"] isEqualToString:@"exwechat2"]) {
//            EMMessage *message = [EaseSDKHelper getTextMessage:@"[电话消息]" to:a.conversationId messageType:EMChatTypeChat messageExt:@{@"userAvatar":[WechatUserInfo shared].headimgurl,@"userNick":[WechatUserInfo shared].nickname,@"type":@"exwechat3",@"wechat":[WechatUserInfo shared].wechat}];
//            message.conversationId = a.conversationId;
//
//            [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
//
//            } completion:^(EMMessage *aMessage, EMError *aError) {
//
//                if (!aError) {
//                    EMError *saveError = nil;
//                }else {
//                    if (aError.code == EMErrorUserPermissionDenied) {
//                        //                [self appendMessage:MESSAGE_REJECTED];
//                    }else{
//                        [PublicTool showMsg:@"消息发送失败"];
//                    }
//                }
//            }];
//        }
//
//
//    }
}

/*!
 *  \~chinese
 *  收到Cmd消息
 */
- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages{

    for (EMMessage *cmdMessage in aCmdMessages) {
        EMCmdMessageBody *body = (EMCmdMessageBody *)cmdMessage.body;
        if ([body.action isEqualToString:@"REVOKE_FLAG"]) {
            NSString *revokeMessageId = cmdMessage.ext[@"msgId"];
             [self removeRevokeMessageWithChatter:cmdMessage.conversationId conversationType:(EMConversationType)cmdMessage.chatType messageId:revokeMessageId];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"conversationListRefresh" object:nil];
            
        }
    }
}

- (BOOL)removeRevokeMessageWithChatter:(NSString *)aChatter
                      conversationType:(EMConversationType)type
                             messageId:(NSString *)messageId{
    
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aChatter type:type createIfNotExist:YES];
    [conversation deleteMessageWithId:messageId error:nil];
    return YES;
}

/*!
 *  \~chinese
 *  收到已读回执
 */
- (void)messagesDidRead:(NSArray *)aMessages{
    
}

/*!
 *  \~chinese
 *  收到消息送达回执

 */
- (void)messagesDidDeliver:(NSArray *)aMessages{
    
}

/*!
 *  \~chinese
 *  收到消息撤回
 */
- (void)messagesDidRecall:(NSArray *)aMessages{
    
}


/*!
 *  消息状态发生变化
*/
- (void)messageStatusDidChange:(EMMessage *)aMessage
                         error:(EMError *)aError{
    
}

#pragma mark --UIApplication
//聊天
- (void)registerHyphenatePush:(UIApplication*)application launchOption:(NSDictionary*)launchOptions
{
    //存储客服好友信息
    FriendModel *friend1 = [[FriendModel alloc]init];
    friend1.usercode = QMPHelperUserCode;
    friend1.headimgurl = kHeadImgUrl;
    friend1.nickname = kCustomerName;
    [PublicTool saveFriendInfo:@[friend1]];
    
    NSString *apnsCertName = nil;
#ifdef DEBUG
    
    apnsCertName = @"chatDevPush"; //证书名称
#else
    apnsCertName = @"chatAppstorePush";
#endif
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *appkey = [ud stringForKey:@"identifier_appkey"];
    if (!appkey) {
        appkey = EaseMobAppKey;
        [ud setValue:appkey forKey:@"identifier_appkey"];
    }
    
    
    //注册登录状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
    BOOL isHttpsOnly = [ud boolForKey:@"identifier_httpsonly"];
    
    [[EaseSDKHelper shareHelper] hyphenateApplication:application
                        didFinishLaunchingWithOptions:launchOptions
                                               appkey:appkey
                                         apnsCertName:apnsCertName
                                          otherConfig:@{@"httpsOnly":[NSNumber numberWithBool:isHttpsOnly], kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES],@"easeSandBox":@(0)}];
    
    EMPushOptions *pushOptions = [[EMClient sharedClient] pushOptions];
    [pushOptions setDisplayStyle:EMPushDisplayStyleSimpleBanner];
    //更新服务器推送属性配置
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] updatePushOptionsToServer];
    });
    
    BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
    if (isAutoLogin){
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
    }else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
    
    [self initHelper];
}


- (void)applicationWillEnterForeground:(UIApplication*)application{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [[EaseSDKHelper shareHelper] hyphenateApplication:application didReceiveRemoteNotification:userInfo];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [[EaseSDKHelper shareHelper] hyphenateApplication:application didReceiveRemoteNotification:userInfo];
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [[EaseSDKHelper shareHelper] hyphenateApplication:[UIApplication sharedApplication] didReceiveRemoteNotification:notification.userInfo];
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary *userInfo = notification.request.content.userInfo;
    [[EaseSDKHelper shareHelper] hyphenateApplication:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
}


#pragma mark --getter   setter--
-(NSArray *)blackList{
    
    if (!_blackList || _blackList.count == 0) {
        EMError *error;
        _blackList = [[EMClient sharedClient].contactManager getBlackListFromServerWithError:&error];
    }
    return _blackList;
}

- (BOOL)isConnect{
    return [EMClient sharedClient].isConnected;
}
- (BOOL)isLoggedIn{
    return [EMClient sharedClient].isLoggedIn;
}
//        QMPLog(@"blackList------%@",blackList);
@end
