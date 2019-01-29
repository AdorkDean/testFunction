//
//  ChatHelper.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2017/11/28.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import <HyphenateLite/HyphenateLite.h>

#define kHaveUnreadAtMessage    @"kHaveAtMessage"
#define kAtYouMessage           1
#define kAtAllMessage           2

#define NOTI_MESSAGE_RECEIVE  @"receiveNewMsg"

#define SHOWINFO_MSG_KEY    @"默认提示信息的消息"
#define QMPHelperUserCode     @"276278485"  //qimingpian01的usercode276278485
#define kCustomerName    @"企名片客服"
#define PERSONINFO       @"我们会在审核您的资料后，给您回复，请耐心等待。"
#define kDefaultWel      @"您好，我是企名片客服，很高兴为您服务！"
#define kGetContactText  @"委托已成功，稍后会短信发送联系方式，也可以到[我的/工作台]中查看。"
#define kBePersonText    @"你好，我在成为官方人物时遇到了问题。"

#define kHeadImgUrl      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1511966694541&di=0aeccf0f829bd953f52eb094024596e9&imgtype=0&src=http%3A%2F%2Fimg.kanzhun.com%2Fimages%2Flogo%2F20161009%2F525739c6b5d51210342146cd6130bfce.jpg"


@interface ChatHelper : NSObject
/**
 黑名单，存储用户QID
 */
@property(nonatomic,strong) NSArray *blackList;

@property(nonatomic,assign,getter=isConnect) BOOL connect;
@property(nonatomic,assign,getter=isLoggedIn)BOOL loggedIn;

+ (instancetype)shareHelper;
- (void)bindDeviceToken:(NSData*)deviceToken;
- (void)registUser;
- (void)loginUser;
- (void)loginOutUser;

- (void)removeEmptyConversationsFromDB; //删除空会话
- (void)showNotificationWithMessage:(id)message; //收到消息（前台和后台）
- (void)userResponseLocalNotification:(UILocalNotification*)messageTf;
- (void)userResponseRemoteNotification:(id)messageTf;

//黑名单管理
- (void)addBlackList:(NSString*)QID;
- (void)removeBlackList:(NSString*)QID;

//通知
- (void)registerHyphenatePush:(UIApplication*)application launchOption:(NSDictionary*)launchOptions;
- (void)applicationWillEnterForeground:(UIApplication*)application;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;

@end
