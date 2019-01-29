//
//  AppDelegateTool.m
//  CommonLibrary
//
//  Created by QMP on 2018/10/31.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "AppDelegateTool.h"
#import "FriendApplyListController.h"
#import "InfoWithoutConfirmAlertView.h"
#import "MeDocumentManagerVC.h"
#import "BPMgrController.h"
#import "UploadReportView.h"
#import "MainNavViewController.h"
#import <MuPDF/MuDocumentController.h>
#import "UploadView.h"
#import "GetNowTime.h"
#import "UserActionStatistics.h"
#import "UpgradeVersionView.h"

@interface AppDelegateTool()<InfoWithoutConfirmAlertViewDelegate,UploadViewDelegate>
{
    InfoWithoutConfirmAlertView *_fileAlertView;
}

@end

@implementation AppDelegateTool

static AppDelegateTool *delegateTool = nil;
static dispatch_once_t onceToken = 0;
+ (instancetype)shared{
    dispatch_once(&onceToken, ^{
        delegateTool = [[AppDelegateTool alloc]init];
    });
    return delegateTool;
}


- (void)applicationLaunchWork{
    [self setWebViewUseAgent];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UserActionStatistics shared ]startForegroundTimer]; //设置timer，计算前台时长
        [self initLocalSearchHistry];   //设置初始搜索历史
        [[UserActionStatistics shared] loginEventEveryday];
    });
}

#pragma mark --启动后工作
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
- (void)setWebViewUseAgent {
    NSString *userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *executableFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    
    NSString *ua = userAgent;
    if (![ua hasSuffix:executableFile]) {
        ua = [NSString stringWithFormat:@"%@/%@/qmp_ios=%@/FromTYCOpenIosClient",userAgent,executableFile,VERSION];
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":ua, @"User-Agent": ua}];
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


#pragma mark --HandleURL--
- (BOOL)hangdelUrlToOther:(NSURL *)url withApplication:(UIApplication *)application{

    if ([url isFileURL]) { // 其他 App 拷贝的文件 file:
        if (![ToLogin isLogin]) {
            [ToLogin enterLoginPage:[PublicTool topViewController]];
            return YES;
        }
        
        NSString *path = [url path]; // 从其他地方打开的url 地址在documents中的Inbox
        NSString *fileName = [[path componentsSeparatedByString:@"/"] lastObject];
        NSString *destinationPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        destinationPath = [destinationPath stringByAppendingPathComponent:fileName];
        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtPath:path toPath:destinationPath error:&error];
        
        
        NSArray *handleArr = [fileName componentsSeparatedByString:@"."];
        NSString *ext = [[handleArr lastObject] lowercaseString];
        NSArray *pdtExt = @[@"pdf"];
        NSArray *otherExt = @[@"ppt",@"pptx",@"doc",@"docx",@"xls",@"xlsx",@"txt"];
        if ([pdtExt containsObject:ext]||[otherExt containsObject:ext]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveFilterView" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveStarFilterView" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveFeedbackView" object:nil];
            
            // 如果是在上传页跳转到了微信返回的，通知其处理上传, 传入文件地址
            if ([KEYWindow.subviews.lastObject isKindOfClass:[UploadReportView class]]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_HANDLEUPLOAD object:destinationPath];
                return YES;
            }
            
            UIViewController *vc = [PublicTool topViewController];
            
            if([vc isKindOfClass:[MuDocumentController class]]){ // 退出后再push
                [vc.navigationController dismissViewControllerAnimated:NO completion:nil];
            }
            
            UITabBarController *tabbarVC = (UITabBarController *)KEYWindow.rootViewController;
            if (![[PublicTool topViewController] isKindOfClass:NSClassFromString(@"MyViewController")]) {
                [tabbarVC setSelectedIndex:tabbarVC.childViewControllers.count-1]; // 跳转我的
            }
            
            InfoWithoutConfirmAlertView *alertView = [InfoWithoutConfirmAlertView initFrame];
            [alertView initViewWithTitle:@"上传文件" withInfo:fileName withLeftBtnTitle:@"上传"  onAction:@"uploadFile"];
            alertView.dataStr = destinationPath;
            alertView.delegate = self;
            _fileAlertView = alertView;
            [KEYWindow addSubview:alertView];
            
        }
        
        return YES;
    }
    
    BOOL result = YES;
    if ([[url absoluteString] hasPrefix:@"wx"]) {
        
        if ([USER_DEFAULTS boolForKey:LOGIN_WECHAT_CLICK]) { //来自登录界面
            result = [[QMPWechatEvent shared]handleOpenUrl:url];
            [USER_DEFAULTS setBool:NO forKey:LOGIN_WECHAT_CLICK];
            [USER_DEFAULTS synchronize];
        } else { //其他微信事件
            [[QMPWechatEvent shared]handleOpenUrl:url];
        }
        QMPLog(@"%d", result);
    }
    
    return result;
}

#pragma mark - InfoWithoutConfirmAlertViewDelegate
#pragma mark - UploadViewDelegate
- (void)pressCancleDownLoad{
    //隐藏到后台
    [_fileAlertView removeFromSuperview];
}
/**
 上传文件
 @param dataStr 要上传的文件所在的路径
 */
- (void)confirmToChooseWithData:(NSString *)dataStr isBP:(BOOL)isBP{
    if (isBP) {
        if(![[PublicTool topViewController] isKindOfClass:[BPMgrController class]]){
            BPMgrController *bpVC = [[BPMgrController alloc]init];
            bpVC.title = @"我的BP";
            [bpVC selectedIndexPage:0];
            [[PublicTool topViewController].navigationController pushViewController:bpVC animated:YES];
            
        }
        
    }else{
        
        if(![[PublicTool topViewController] isKindOfClass:[MeDocumentManagerVC class]]){
            //文档管理
            MeDocumentManagerVC *inVC = [[MeDocumentManagerVC alloc] init];
            
            inVC.navigationItem.title = @"文档管理";
            [inVC selectedIndexPage:0];
            [[PublicTool topViewController].navigationController pushViewController:inVC animated:YES];
        }
    }
    
    NSArray *nameArr = [dataStr componentsSeparatedByString:@"/"];
    NSString *filename = [nameArr lastObject];
    
    UploadView *uploadView = [UploadView initFrameWithInfo:filename];
    uploadView.delegate = self;
    [uploadView initData];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:uploadView];
    
    //报告：cloud     BP：work_bp
    NSString *uploadType = isBP ? @"work_bp":@"cloud";
    
    NSDictionary *param = @{@"upload_type": uploadType};
    
    [AppNetRequest uploadPDFWithFilePath:dataStr fileName:filename params:param progress:^(CGFloat progress) {
        [uploadView changeProgressWithProgress:progress];
    } completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            
            NSString *info = @"上传成功";
            //将本地文件重命名 dataStr -> resultDic[@"data"][@"name"]
            NSFileManager *fileManager = [NSFileManager defaultManager];
            //库里的文件名
            NSString *newfileName = isBP ? resultData[@"bp_name"] : resultData[@"name"];
            NSString *newNamePath = [[dataStr stringByDeletingLastPathComponent] stringByAppendingPathComponent:newfileName];
            [fileManager moveItemAtPath:dataStr toPath:newNamePath error:nil];
            //InfoWithoutConfirmAlertView移除
            for (UIView *subv in keyWindow.subviews) {
                if ([subv isKindOfClass:[InfoWithoutConfirmAlertView class]]) {
                    [subv removeFromSuperview];
                    break;
                }
            }
            [uploadView removeFromSuperview];
            
            [ShowInfo showInfoOnView:KEYWindow withInfo:info];
            //----------根据name和from更改本地数据库中的pdf的收藏状态
            DBHelper *dbHelper = [DBHelper shared];
            FMDatabase *db = [dbHelper toGetDB];
            NSString *tableName = PDFTABLENAME;
            
            if ([db open]) {
                BOOL hasTable = [[DBHelper shared] isTableOK:tableName ofDataBase:db];
                if (!hasTable) {
                    //如果不存在,先创建表
                    NSString *countrySql = [NSString stringWithFormat:@"create table '%@' ('name' text, 'url' text, 'id' text, 'type' text, 'time' text, 'size' text , 'come' text, 'collect' text)",tableName];
                    [db executeUpdate:countrySql];
                }
                NSString *pdfUrl = isBP ? resultData[@"bp_link"]:resultData[@"url"];
                NSString *pdfId = isBP ? resultData[@"id"]:resultData[@"id"];
                NSString *pdfSize = isBP ? resultData[@"bp_size"]:resultData[@"size"];
                NSString *type = @"cloud";
                NSString * comeStr = isBP ? BP : HYBG;
                if (![[DBHelper shared] oneTable:tableName hasOneInfo:newfileName ofDataBase:db]) {
                    //不存在当前文件的名字
                    NSString *time = [GetNowTime getCompleteYearDayWithHour];
                    
                    NSString *insertSql = [NSString stringWithFormat:@"insert into '%@' (name,url,id,type,time,size,come,collect) values('%@','%@','%@','%@','%@','%@','%@','%@')",tableName,newfileName,pdfUrl,pdfId,type,time,pdfSize,comeStr,@"1"];
                    [db executeUpdate:insertSql];
                }else{
                    NSString *updateSql = [NSString stringWithFormat:@"update '%@' set collect='%@' where name='%@' and id='%@'", tableName,@"1",newfileName, pdfId];
                    [db executeUpdate:updateSql];
                }
                
                [db close];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"collectPdfSuccess" object:nil];
        } else {
            NSString *info = @"上传失败，请重新操作";
            [ShowInfo showInfoOnView:KEYWindow withInfo:info];
            [uploadView removeFromSuperview];
        }
    }];
}




@end
