//
//  AppDelegate.m
//  qmp_ios
//
//  Created by QMP on 2018/11/2.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "AppDelegate.h"


#import <UserNotifications/UserNotifications.h>

#import <JPUSHService.h>
#import <CommonLibrary/AppDelegateTool.h>
#import <CommonLibrary/UserActionStatistics.h>
#import "QMPTabbarController.h"
#import <CommonLibrary/MainNavViewController.h>
#import <CommonLibrary/ChatHelper.h>
#import <CommonLibrary/NotificationHandle.h>
#import <CommonLibrary/UpgradeVersionView.h>
#import "QMPLoginController.h"
#import "QMPPhoneBindController.h"
#import <CommonLibrary/ThirdConfigTool.h>
#import <CommonLibrary/UploadView.h>

@interface AppDelegate ()<AlertViewDelegate, InfoWithoutConfirmAlertViewDelegate,UploadViewDelegate, UNUserNotificationCenterDelegate, JPUSHRegisterDelegate, UITabBarControllerDelegate>{
    BOOL _isInBackground; // 是否在后台，pdf用
    BOOL _onlyGetUsrInfo;
    NSDictionary *_launchOption;
    NSInteger selectedTabIndex;
    ShareTo *_shareTool;
}
@property (nonatomic, strong) InfoAlertView *alertView;
@property (nonatomic, strong) InfoWithoutConfirmAlertView *fileAlertView;
@property (nonatomic, strong) UploadView *fileUploadView;

@property (nonatomic, strong) GetNowTime *getNowTimeTool;
@property (nonatomic, strong) GetSizeWithText *sizeTool;
//@property (nonatomic, strong) ManagerHud *loginHudTool;

@property (nonatomic, strong) NSString *paste;  // 粘贴板内容
@property (nonatomic, strong) NSString *title;  // 获取的url的标题
@property (nonatomic, strong) NSString *urlStr; // 获取的url的字符串
@property (nonatomic, strong) NSString *fromUrl;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [self checkoutAppVersion]; // 强制更新
    [ThirdConfigTool initThirdInfo:launchOptions applications:application]; // 配置第三方数据

//    [self setWebViewUseAgent]; // 设置浏览器的UA
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        [ToLogin shared].delegate = [QMPPageSkipTools shared];
    });
    [self checkAppStoreReviewStatus]; // 判断有没有审核通过

    [self updateUserInfo];


    [[ChatHelper shareHelper]registerHyphenatePush:application launchOption:launchOptions];

    // 环信客服
    [[ChatHelper shareHelper] loginUser];

    if (iOS10_OR_HIGHER) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }

    // 注册手动截屏通知
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];//此方法
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quiteLoginEvent) name:NOTIFI_QUITLOGIN object:nil];
 
    [self setupWindowRootController];

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}


 #pragma mark - App Life
 

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    //pdf --
    _isInBackground = YES;
    //--pdf end
    
    [[SDImageCache sharedImageCache] clearMemory];
    
    [[UserActionStatistics shared] endForegroundTimer];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber>0){
        [self resetBageNumber];
    }
    [[UserActionStatistics shared] startForegroundTimer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //pdf --
    _isInBackground = NO;
    //--pdf end
    _title = @"";
    _urlStr = @"";
      
    // 如果未登录
    if (![ChatHelper shareHelper].isConnect) {
        [[ChatHelper shareHelper] applicationWillEnterForeground:[UIApplication sharedApplication]];
    }
    if ([ToLogin isLogin] && ![ChatHelper shareHelper].isLoggedIn) {
        [[ChatHelper shareHelper] loginUser];
    }
    
    //当APP 处于前台时,识别粘贴板中的内容 0801 molly
    if ([[PublicTool topViewController] isKindOfClass:NSClassFromString(@"PostActivityViewController")]) {
        return;
    }
    [self recognizePasteboard];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    
    //pdf --
    //--pdf end
    [[SDWebImageManager sharedManager] cancelAll];
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    //禁止横屏
    return UIInterfaceOrientationMaskPortrait;
}

- (void)checkoutAppVersion {
//#ifdef DEBUG
//    return;
//#endif
    
    if (![TestNetWorkReached isWifi]) {
        return;
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"http://itunes.apple.com/lookup?id=1103060310"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil][@"results"];
            NSString *version = [arr[0] valueForKey:@"version"];
            
            //用户版本 -  appStore版本
            BOOL  isUpdate = [self checkoutAppStoreVersion:version  userVersion:AppVersion];
            
            if (!isUpdate) {
                //请求后台
                [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/iosversionjudge" HTTPBody:@{@"version":AppVersion} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                    NSDictionary *dic = (NSDictionary*)resultData;
                    
                    if ([dic[@"state"] integerValue] == 2) { //强制更新，低于节点版本
                        [UpgradeVersionView showUpgradView:dic[@"content"] showClose:NO version:version];
                        
                    }else if ([dic[@"state"] integerValue] == 1) { //强制更新，高于节点，非强制更新
                        //判断时间差
                        NSTimeInterval timerInterval = [[NSDate date] timeIntervalSinceDate:[USER_DEFAULTS valueForKey:@"UPDATEALERT"]];
                        if (![USER_DEFAULTS valueForKey:@"UPDATEALERT"] || timerInterval >= 24*60*60) {
                            [UpgradeVersionView showUpgradView:dic[@"content"] showClose:YES version:version];
                            [USER_DEFAULTS setValue:[NSDate date] forKey:@"UPDATEALERT"];
                            
                        }
                    }
                }];
            }
        }
        
    }];
    
    [task resume];
}

- (BOOL)checkoutAppStoreVersion:(NSString*)appStoreVersion userVersion:(NSString*)userVersion{
    NSArray *appstoreVersionArray = [appStoreVersion componentsSeparatedByString:@"."];
    NSArray *appVersionArray = [userVersion componentsSeparatedByString:@"."];
    
    NSInteger store_one = [appstoreVersionArray[0] integerValue];
    NSInteger store_two = [appstoreVersionArray[1] integerValue];
    NSInteger store_three = [appstoreVersionArray[2] integerValue];
    NSInteger user_one = [appVersionArray[0] integerValue];
    NSInteger user_two = [appVersionArray[1] integerValue];
    NSInteger user_three = [appVersionArray[2] integerValue];
    
    if ((store_one == user_one) &&(store_two == user_two)&&(store_three == user_three)) {
        return YES;
    }
    return NO;
}


#pragma mark - User NSNotification
-(void)resetBageNumber{
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber) {
        [USER_DEFAULTS setValue:@([UIApplication sharedApplication].applicationIconBadgeNumber) forKey:@"applicationIconBadgeNumber"];
    }
    
    [[NotificationHandle shared] resetAppBadge];
    if (@available(iOS 11.0, *)) {
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = -1; //清角标 不清通知
        
    }else{
        //请求后台发送一个badge为0 的通知，就可以清空角标
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
}
//手动截屏响应
- (void)userDidTakeScreenshot:(NSNotification *)notification {
    QMPLog(@"检测到手动截屏");
    if (!_shareTool) {
        _shareTool = [[ShareTo alloc]init];
    }
    [[[ShareTo alloc]init] shareScreenShotImage:[PublicTool screenshotWithView:KEYWindow size:CGSizeMake(SCREENW, SCREENH)]];
}

#pragma mark - NSNotification Register & Receive
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    [ThirdConfigTool application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    QMPLog(@"通知注册失败--------：%@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [[NotificationHandle shared] handleNotificationContent:userInfo];
    
    
    NSInteger bageInt = [[USER_DEFAULTS objectForKey:@"applicationIconBadgeNumber"] integerValue];
    [USER_DEFAULTS setValue:@(bageInt + 1) forKey:@"applicationIconBadgeNumber"];
    [USER_DEFAULTS synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MESSAGE_RECEIVE object:nil]; /// 处理在前台时改变小红点状态
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [[NotificationHandle shared] handleNotificationContent:userInfo];
    
    //10之前 前台
    if (application.applicationState == UIApplicationStateActive) {
        NSInteger bageInt = [[USER_DEFAULTS objectForKey:@"applicationIconBadgeNumber"] integerValue];
        [USER_DEFAULTS setValue:@(bageInt + 1) forKey:@"applicationIconBadgeNumber"];
        [USER_DEFAULTS synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MESSAGE_RECEIVE object:nil];
    }
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (notification) { //iOS 10 以下起作用 清角标
        [application scheduleLocalNotification:notification];
    }
    //在后台时点击推送
    [[ChatHelper shareHelper]userResponseLocalNotification:notification];
}

// iOS 10 之后, 前台收到消息
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    if ([notification.request.content.userInfo[@"id"] isEqualToString:@"123"]) { //iOS 10  清角标
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:notification.request withCompletionHandler:nil];
    }
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    //前台也alert
    if ([userInfo.allKeys containsObject:@"data"] && userInfo[@"data"] ) { // 后台推送
        NSDictionary *dic = userInfo[@"data"];
        NSDictionary *alert = userInfo[@"aps"][@"alert"];
        NSString *type = dic[@"type"];
        NSString *body = alert[@"body"];
        if (type.integerValue == 5 && [body containsString:@"您收到了一份BP"]) { // 收到BP才弹框
            completionHandler(UNNotificationPresentationOptionAlert);
        } else {
            completionHandler(UNNotificationPresentationOptionAlert);
        }
    }
    
    NSInteger bageInt = [[USER_DEFAULTS objectForKey:@"applicationIconBadgeNumber"] integerValue];
    [USER_DEFAULTS setValue:@(bageInt + 1) forKey:@"applicationIconBadgeNumber"];
    [USER_DEFAULTS synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MESSAGE_RECEIVE object:nil];
}

//点击
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    [[NotificationHandle shared] handleNotificationContent:response.notification];
    completionHandler();
}
#pragma mark - JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required[
    [[NotificationHandle shared] jpushNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    }
}
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    // Required
    [[NotificationHandle shared] jpushNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    
    completionHandler();  // 系统要求执行这个方法
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
   
    return YES;
    
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[AppDelegateTool shared] hangdelUrlToOther:url withApplication:application];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    return [[AppDelegateTool shared] hangdelUrlToOther:url withApplication:application];
    
}
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options{
    
    return [[AppDelegateTool shared] hangdelUrlToOther:url withApplication:application];
    
}

#pragma mark - Public
- (void)quiteLoginEvent{
    [[WechatUserInfo shared] clear];
    [USER_DEFAULTS setValue:nil forKey:@"lastLoginTime"];
    
    __block NSInteger sequ = 0;
    [JPUSHService setAlias:nil completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        sequ = seq;
    } seq:sequ];
    [self setupWindowRootController];
}

- (void)resetUserAccount{
    //5.0 未登录 且 本地没绑定记录，请求后台该设备是否进行过绑定
    if (![ToLogin isLogin]) {
        //请求后台user/checkIndexFocus
        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"user/checkIndexFocus" HTTPBody:@{} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            if (resultData && ([resultData[@"focus"] integerValue] == 1)) {
                [USER_DEFAULTS setBool:YES forKey:LOGINLEADER_HAVEATTENT];
            }else{
                [USER_DEFAULTS setBool:NO forKey:LOGINLEADER_HAVEATTENT];
            }
        }];
    }
}

- (void)setWebViewUseAgent {
    NSString *userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *executableFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    
    NSString *ua = userAgent;
    if (![ua hasSuffix:executableFile]) {
        ua = [NSString stringWithFormat:@"%@/%@/qmp_ios=%@/FromTYCOpenIosClient",userAgent,executableFile,VERSION];
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":ua, @"User-Agent": ua}];
}


//初始化数据到本地数据库

- (void)initLocalSearchHistry {
    
    NSString *tableName = @"NewSearchHistory";
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [docDir stringByAppendingPathComponent:@"user.sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        
        DBHelper *helper = [DBHelper shared];
        if ([helper isTableOK:tableName ofDataBase:db]) { // 如果表存在
        } else {
            
            // 如果表不存在，则创建并初始化数据
            NSString *sql = [NSString stringWithFormat:@"create table '%@' ('searchid' integer primary key autoincrement,'keywords' text,'version' text)",tableName];
            BOOL res = [db executeUpdate:sql];
            
            if (res) {
                NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'(keywords,version) VALUES('种瓜得瓜','%@'),('启迪种子','%@'),('明势资本','%@'),('晨兴资本','%@'),('极客帮创投','%@'),('企名片','%@')",tableName,VERSION,VERSION,VERSION,VERSION,VERSION,VERSION];
                [db executeUpdate:insertSql];
                QMPLog(@"==========%@=======",insertSql);
            }
        }
        [db close];
    }
}

//  判断是否在审核期，登录页展示

- (void)checkAppStoreReviewStatus {
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/iossh" HTTPBody:@{} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            BOOL isCheck = NO;
            if ([resultData[@"pass"] integerValue] == 0) {
                isCheck = YES;
            }
            [USER_DEFAULTS setBool:isCheck forKey:APPVERSION_CHECKSTATUS];
            [USER_DEFAULTS synchronize];
            if (![ToLogin isLogin] && isCheck) {
                [self setupWindowRootController];
            }
            
        }
    }];
}

- (void)setupWindowRootController {
    QMPTabbarController *tabBarVC = [[QMPTabbarController alloc] init];
    tabBarVC.delegate = self;
    self.window.rootViewController = tabBarVC;
    
}

- (void)getUserInfo:(NSString *)uuid { //返回了uuid和unionid
    // 老用户进入没网情况
    if(![TestNetWorkReached networkIsReachedNoAlert] && [PublicTool isNull:uuid]){
        [WechatUserInfo shared].unionid =  nil;
        [[WechatUserInfo shared] save];
        [self setupWindowRootController];
        return;
    }
    //    uuid = @"d9d95f8700be5845af4a5a892766ba3c";
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [mDict setValue:@"qmp_ios" forKey:@"ptype"];
    [mDict setValue:[NSString stringWithFormat:@"%@",VERSION] forKey:@"version"];
    if ([PublicTool isNull:uuid]) {
        if(![PublicTool isNull:[WechatUserInfo shared].unionid]){
            [mDict setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
        }else{
            return;
        }
    }
    
//    [mDict setValue:uuid ? uuid :@"" forKey:@"uuid"];
    
    [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:@"user/getUserInfo" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];

        if (resultData) {
            NSDictionary *infoDict = resultData;
            WechatUserInfo *userModel = [WechatUserInfo shared];
            [userModel setValuesForKeysWithDictionary:infoDict];
            [userModel save];
            
            [[ChatHelper shareHelper]loginUser]; //IM登录
            [[ChatHelper shareHelper] registerHyphenatePush:[UIApplication sharedApplication] launchOption:_launchOption];
            
            if ([PublicTool isNull:uuid]) { //老用户进入 没有uuid
                [[NSNotificationCenter defaultCenter]  postNotificationName:NOTIFI_LOGIN object:nil userInfo:@{@"isLogin":@"YES"}];
                [self setupWindowRootController]; //走批量关注
            }
            if (_onlyGetUsrInfo) {  //didfinishlaunch获取userInfo不显示登陆成功

                _onlyGetUsrInfo = NO;
                
                return;
            }
            
            //            [self.loginHudTool removeHud];
            
            [[NSNotificationCenter defaultCenter]  postNotificationName:NOTIFI_LOGIN object:nil userInfo:@{@"isLogin":@"YES"}];
            
            [QMPEvent event:@"Login"];
            [ThirdConfigTool processJIGuang];
            
            [[UserActionStatistics shared] loginEventEveryday];
            
            //判断用户是否绑定手机号
            if (![WechatUserInfo shared].bind_flag || [WechatUserInfo shared].bind_flag.integerValue == 0) {
                [[QMPPageSkipTools shared] appPageSkipToBindPhone];
            }else{
                //退出登录页面
                [[PublicTool topViewController].navigationController popToRootViewControllerAnimated:YES];
                
            }
            
        }else{
            if (_onlyGetUsrInfo) {
                return;
            }
            [PublicTool alertActionWithTitle:@"提示" message:@"登录失败" btnTitle:@"确定" action:^{
                
            }];
            
        }
        
    }];
    
}

// 识别粘贴板中的内容
- (void)recognizePasteboard {
    if (![ToLogin isLogin]) return;
    
    _paste = [[UIPasteboard generalPasteboard] string];
    QMPLog(@"============%@===========",_paste);
    
    if (_paste.length <= 0) return;
    
    NSArray *urlWhiteList = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"activityUrlWhiteList" ofType:@"plist"]];
    if ([urlWhiteList containsObject:_paste]) {
        return;
    }
    
    if ([_paste hasPrefix:@"http://"]||[_paste hasPrefix:@"https://"]) {
        _urlStr = _paste;
    } else if ([_paste rangeOfString:@"http://" ].location != NSNotFound) {
        [self getTitleAndUrlOf:@"http://"];
    } else if ([_paste rangeOfString:@"https://" ].location != NSNotFound){
        [self getTitleAndUrlOf:@"https://"];
    } else {
        return;
    }
    
    NSMutableArray *pasteUrlMArr = nil;
    
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"pasteUrlMArr"];
    if (arr) {
        pasteUrlMArr = [NSMutableArray arrayWithArray:arr];
    } else {
        pasteUrlMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    NSMutableArray *urlMArr = [[NSMutableArray alloc] initWithCapacity:0];
    if (pasteUrlMArr.count > 0) {
        for (NSDictionary *dict in pasteUrlMArr) {
            [urlMArr addObject:[dict objectForKey:@"url"]];
        }
    }
    
    if (![urlMArr containsObject:self.urlStr]) {
        
        NSString *oldContent = [[NSUserDefaults standardUserDefaults] valueForKey:@"Clipboard"];
        if ([oldContent containsString:self.urlStr]) {
            return;
        }
        
        NSArray *views = [KEYWindow subviews];
        UIView *lastV = [views lastObject];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveFilterView" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveStarFilterView" object:nil];
        //            [[NSNotificationCenter defaultCenter] postNotificationName:@"addUrlHistory" object:nil];
        
        NSString *info = [NSString stringWithFormat:@"检测到您的粘贴板里包含链接:%@", self.urlStr];
        CGFloat lblH = [self.sizeTool calculateSize:info withFont:[UIFont systemFontOfSize:15.f] withWidth:230].height;
        lblH = lblH > 100 ? 100 : lblH;
        
        self.alertView = [InfoAlertView initFrame];
        [self.alertView initViewWithTitle:@"提示" withInfo:info withLeftBtnTitle:@"取消" withRightBtnTitle:@"去发布" onAction:@"collectUrl" withCenter: CGPointMake(SCREENW / 2, SCREENH / 2) withInfoLblH:lblH];
        [self.alertView initCloseBtnView];
        self.alertView.delegate = self;
        //弹窗
        [KEYWindow addSubview:self.alertView];
        [[NSUserDefaults standardUserDefaults]setValue:self.urlStr forKey:@"Clipboard"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
}
- (void)getTitleAndUrlOf:(NSString *)prexStr {
    // 标题+链接 形式的文字提取链接和标题
    NSRange  range = [_paste rangeOfString:prexStr];
    if (range.location != NSNotFound) {
        _title = [_paste substringToIndex:range.location];
        _urlStr = [_paste substringFromIndex:range.location];
    }
}


#pragma mark - AlertViewDelegate
- (void)infoAlertViewCollectUrl:(InfoAlertView *)view {
    if (![ToLogin isLogin]) {
        [self handleWhenNotLogin];
        return;
    }
    [self.alertView removeFromSuperview];
    [[AppPageSkipTool shared]appPageSkipToActivityPostNeedGo:YES linkUrl:[_urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
}

- (void)handleWhenNotLogin {
    [ToLogin enterLoginPage:[PublicTool topViewController]];
}

// 更新用户数据
- (void)updateUserInfo {
    if ([ToLogin isLogin]) {
        _onlyGetUsrInfo = YES;
        [self getUserInfo:[WechatUserInfo shared].uuid];
    }
}

#pragma mark - Getter
- (GetNowTime *)getNowTimeTool {
    if (!_getNowTimeTool) {
        _getNowTimeTool = [[GetNowTime alloc] init];
    }
    return _getNowTimeTool;
}
- (GetSizeWithText *)sizeTool {
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}


+ (instancetype)shareDelegate{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}


@end
