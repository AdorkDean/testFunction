//
//  ThirdConfigTool.m
//  CommonLibrary
//
//  Created by QMP on 2018/10/30.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "ThirdConfigTool.h"
#import "JKEncrypt.h"
#import <JPush/JPUSHService.h>
#import <UMMobClick/MobClick.h>
#import <Bugly/Bugly.h>
#import <mupdf/fitz.h>
#import <mupdf/common.h>


@implementation ThirdConfigTool

#pragma mark --DeviceToken
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    if ([ChatHelper shareHelper].isLoggedIn) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[ChatHelper shareHelper] bindDeviceToken:deviceToken];
            
        });
        // 方式2
        NSString *deviceTokenString2 = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                                         stringByReplacingOccurrencesOfString:@">" withString:@""]
                                        stringByReplacingOccurrencesOfString:@" " withString:@""];
        QMPLog(@"方式2：%@", deviceTokenString2);
        //        [UIPasteboard generalPasteboard].string = deviceTokenString2;
        
    }
    
    [JPUSHService registerDeviceToken:deviceToken];
    
    [ThirdConfigTool processJIGuang]; //设置标签tags  和 alias
}

+ (void)initThirdInfo:(NSDictionary *)launchOptions applications:(UIApplication*)application{
    
    [ThirdConfigTool registerUMeng];
    
    [ThirdConfigTool registerWechat];//要写在初始化友盟后面
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [ThirdConfigTool registerBugly];//放在其他捕获crash组件的后面
        [ThirdConfigTool initPDFReader];
        
        //极光推送
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [JPUSHService registerForRemoteNotificationConfig:entity delegate:(id<JPUSHRegisterDelegate>)kAppdelegate];
        });
        
        NSString *appKey = JIGUANG_APPKEY;
        NSString *channel= @"appstore";
        BOOL isProduction = YES;
        
#ifdef DEBUG
        isProduction = NO; //环境
#else
        isProduction = YES;
#endif
        
        QMPLog(@"环境---------%@",@(isProduction));
        [JPUSHService setupWithOption:launchOptions appKey:appKey
                              channel:channel
                     apsForProduction:isProduction];
        
        [ThirdConfigTool processJIGuang];
        
    });
    
    [ThirdConfigTool managerKeyBoard];
}



+ (void)managerKeyBoard {
    // 使用IQKeyboardManager 管理键盘
    IQKeyboardManager *keyBoardManager = [IQKeyboardManager sharedManager];
    keyBoardManager.enable = NO;
//    keyBoardManager.shouldResignOnTouchOutside = YES;
    keyBoardManager.enableAutoToolbar = NO;
    
}


+ (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    
    int success = fz_shrink_store(ctx, (application.applicationState == UIApplicationStateBackground) ? 0 : 50);
    QMPLog(@"fz_shrink_store: success = %d", success);
}

+ (void)registerUMeng {
    
    [MobClick setLogEnabled:NO];//设置是否打印sdk的log信息, 默认NO(不打印log).
    //设置umeng统计
    UMConfigInstance.appKey = UMENG_SHARE_APPKEY;
    
    UMConfigInstance.channelId = [BundleTool isQMP] ? @"https://itunes.apple.com/cn/app/qi-ming-pian/id1103060310":@"https://itunes.apple.com/cn/app/qi-ming-pian/id1438955110";
    
    //取version标识
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    [MobClick startWithConfigure:UMConfigInstance];//初始化友盟统计模块
    
    //关闭友盟错误统计
    [MobClick setCrashReportEnabled:NO];
}


+ (void)processJIGuang {
    
    NSString *alias = [PublicTool isNull:[WechatUserInfo shared].usercode] ? @"1" : [WechatUserInfo shared].usercode;
    
    [JPUSHService setAlias:alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        QMPLog(@"设置别名-------%@",iAlias);
        
    } seq:(NSInteger)20171205];
    
    
    [JPUSHService setTags:[ThirdConfigTool getTagSet] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        QMPLog(@"设置标签-------%@",iTags);
    } seq:20171205]; //seq会话序列号  回调中原样返回
    
}
+ (NSMutableSet *)getTagSet {
    
    NSMutableSet *tagset = [[NSMutableSet alloc] init];
    //用户身份
    if ([ToLogin isLogin] && ![PublicTool isNull:[WechatUserInfo shared].vip]) {
        [tagset addObject:[WechatUserInfo shared].vip];
    }
    
    if (![PublicTool isNull:[WechatUserInfo shared].phone]) {
        [tagset addObject:[WechatUserInfo shared].phone];
    }
    
    [tagset addObject:AppVersionShort]; // app版本
    return tagset;
}




-(void)registerUMeng {
    
    [MobClick setLogEnabled:NO];//设置是否打印sdk的log信息, 默认NO(不打印log).
    //设置umeng统计
    UMConfigInstance.appKey = UMENG_SHARE_APPKEY;
    
    UMConfigInstance.channelId = [BundleTool isQMP] ? @"https://itunes.apple.com/cn/app/qi-ming-pian/id1103060310":@"https://itunes.apple.com/cn/app/qi-ming-pian/id1438955110";
    
    //取version标识
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    [MobClick startWithConfigure:UMConfigInstance];//初始化友盟统计模块
    
    //关闭友盟错误统计
    [MobClick setCrashReportEnabled:NO];
}

+ (void)registerWechat {
    //向微信注册APPID
    [[QMPWechatEvent shared] registWechat];
}

+ (void)registerBugly {
    BuglyConfig * config = [[BuglyConfig alloc] init];
    // 设置自定义日志上报的级别，默认不上报自定义日志
    config.reportLogLevel = BuglyLogLevelWarn;
    config.blockMonitorEnable = YES;
    config.unexpectedTerminatingDetectionEnable = YES;
    
    [Bugly startWithAppId:BUGLY_APP_ID config:config];
    
    NSString *unionid = [WechatUserInfo shared].unionid;    
    if (unionid) {
        
    } else {
        unionid = @"";
    }
    [Bugly setUserIdentifier:unionid];
}


+ (void)initPDFReader {
    
    queue = dispatch_queue_create("com.artifex.mupdf.queue", NULL);
    ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
    fz_register_document_handlers(ctx);
    screenScale = [UIScreen mainScreen].scale;
}


@end
