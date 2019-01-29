//
//  ShareTo.m
//  QimingpianSearch
//
//  Created by Molly on 16/8/6.
//  Copyright © 2016年 qimingpian. All rights reserved.
//
#import "ShareTo.h"
#import "TestNetWorkReached.h"
// 在需要进行授权的UIViewController中加入如下代码
#import "MainNavViewController.h"
#import "WXApi.h"
#import "ShareView.h"
#import "ImageShareController.h"
#import "ScreenShareView.h"

@interface ShareTo () 
@property (nonatomic,weak)UIViewController *vc;
@end

@implementation ShareTo

//分享支持复制

- (void)shareWithDetailStr:(NSString *)detailStr sessionTitle:(NSString *)sessionTitle timelineTitle:(NSString *)timelineTitle copyString:(NSString*)copyString aIcon:(id)icon aOpenUrl:(NSString *)urlStr onViewController:(UIViewController *)viewController shareResult:(ShareResult) shareResult{
    [[PublicTool topViewController].view endEditing:YES];
    
    self.shareResult = shareResult;
    _vc = viewController;
    //shareType 和友盟分享平台的enum相等
    BOOL supportCopy = ![PublicTool isNull:copyString];
    [ShareView showShareViewCanCopyURL:supportCopy didTapPlatform:^(ShareType shareType) {
        
        //微信分享API
        if ([TestNetWorkReached networkIsReached:viewController]) {
            if (shareType == ShareTypeCopyURL) {
                [UIPasteboard generalPasteboard].string = copyString;
                [PublicTool showMsg:@"复制链接成功"];
                self.shareResult(YES);
                return;
            }
            if (![WXApi isWXAppInstalled]) { //检查微信是否已被用户安装,微信已安装返回YES
                //没安装则提示
                [PublicTool showMsg:@"请先安装微信客户端"];//弹出提示框
                
            }else{
                //shareType 和友盟分享平台的enum相等
                
                //platformType:UMSocialPlatformType_WechatSession
                
                
                WXMediaMessage *message = [WXMediaMessage message];
                
                UIImage *image = nil;
                if ([icon isKindOfClass:[NSString class]]){
                    //                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:icon]]];
                    image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:icon];
                }else if([icon isKindOfClass:[UIImage class]]){
                    image = icon;
                }
                
                image = [PublicTool compressImage:image toByte:30*1024];
                [message setThumbImage:image];
                
                if (shareType == ShareTypeWechatTimeLine) { //朋友圈
                    message.title = timelineTitle;
                    message.description = detailStr;
                    
                }else{
                    message.title = sessionTitle;
                    message.description = detailStr;
                }
                
                WXWebpageObject *webpageObject = [WXWebpageObject object];
                webpageObject.webpageUrl = urlStr;
                message.mediaObject = webpageObject;
                
                SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
                req.bText = NO;
                req.message = message;
                if (shareType == ShareTypeWechatSession) {
                    req.scene = WXSceneSession;
                    
                }else if(shareType == ShareTypeWechatTimeLine){
                    req.scene = WXSceneTimeline;
                    
                }else{
                    req.scene = WXSceneFavorite;
                    
                }
                
                BOOL success = [WXApi sendReq:req];
                QMPLog(@"%@=======",@(success));
            }
            
        }else{
            self.shareResult(NO);
        }
        
    }];
    
}

/** 指定分享到微信好友*/
- (void)shareToWechat:(NSString *)detailStr aTitleSessionStr:(NSString *)titleSessionStr aTitleTimelineStr:(NSString *)titleTimelineStr aIcon:(id)icon aOpenUrl:(NSString *)urlStr shareResult:(ShareResult) shareResult{
   
    if (![WXApi isWXAppInstalled]) { //检查微信是否已被用户安装,微信已安装返回YES
        //没安装则提示
        [PublicTool showMsg:@"请先安装微信客户端"];//弹出提示框
        
    }else{
        
        WXMediaMessage *message = [WXMediaMessage message];
        
        UIImage *image = nil;
        if ([icon isKindOfClass:[NSString class]]){
            image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:icon];
        }else if([icon isKindOfClass:[UIImage class]]){
            image = icon;
        }
        
        image = [PublicTool compressImage:image toByte:30*1024];
        [message setThumbImage:image];
        
        
        WXWebpageObject *webpageObject = [WXWebpageObject object];
        webpageObject.webpageUrl = urlStr;
        message.mediaObject = webpageObject;
        message.title = titleSessionStr;
        message.description = detailStr;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneSession;
        BOOL success = [WXApi sendReq:req];
        QMPLog(@"%@=======",@(success));
    }
}



- (void)shareToOtherApp:(NSString *)detailStr aTitleSessionStr:(NSString *)titleSessionStr aTitleTimelineStr:(NSString *)titleTimelineStr aIcon:(id)icon aOpenUrl:(NSString *)urlStr onViewController:(UIViewController *)viewController shareResult:(ShareResult) shareResult;{
    
    [[PublicTool topViewController].view endEditing:YES];
    
    self.shareResult = shareResult;
    _vc = viewController;
    //shareType 和友盟分享平台的enum相等
    [ShareView showShareViewDidTapPlatform:^(ShareType shareType) {
        
        //微信分享API
        if ([TestNetWorkReached networkIsReached:viewController]) {
            if (![WXApi isWXAppInstalled]) { //检查微信是否已被用户安装,微信已安装返回YES
                //没安装则提示
                [PublicTool showMsg:@"请先安装微信客户端"];//弹出提示框
                
            }else{
                //shareType 和友盟分享平台的enum相等
               
                //platformType:UMSocialPlatformType_WechatSession
                
                
                WXMediaMessage *message = [WXMediaMessage message];
                
                UIImage *image = nil;
                if ([icon isKindOfClass:[NSString class]]){
//                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:icon]]];
                    image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:icon];
                }else if([icon isKindOfClass:[UIImage class]]){
                    image = icon;
                }
                
                image = [PublicTool compressImage:image toByte:30*1024];
                [message setThumbImage:image];
               
                if (shareType == ShareTypeWechatTimeLine) { //朋友圈
                    message.title = titleTimelineStr;
                    message.description = detailStr;
                
                }else{
                    message.title = titleSessionStr;
                    message.description = detailStr;
                }
            
                WXWebpageObject *webpageObject = [WXWebpageObject object];
                webpageObject.webpageUrl = urlStr;
                message.mediaObject = webpageObject;
                
                SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
                req.bText = NO;
                req.message = message;
                if (shareType == ShareTypeWechatSession) {
                    req.scene = WXSceneSession;
                    
                }else if(shareType == ShareTypeWechatTimeLine){
                    req.scene = WXSceneTimeline;
                    
                }else{
                    req.scene = WXSceneFavorite;
                    
                }
                
               BOOL success = [WXApi sendReq:req];
                QMPLog(@"%@=======",@(success));
            }
            
        }else{
            self.shareResult(NO);
        }
        
    }];
    
    
}
//
//- (BOOL)shareToOtherApp:(NSString *)detailStr aTitleSessionStr:(NSString *)titleSessionStr aTitleTimelineStr:(NSString *)titleTimelineStr aIcon:(id)icon aOpenUrl:(NSString *)urlStr onViewController:(UIViewController *)viewController{
//
//    _vc = viewController;
//    [[PublicTool topViewController].view endEditing:YES];
//
//    //detailStr = !detailStr ? @"":detailStr;
//    //titleSessionStr = !titleSessionStr ? @"":titleSessionStr;
//    //titleTimelineStr = !titleTimelineStr ? @"":titleTimelineStr;
//    //urlStr = !urlStr ? @"":urlStr;
//
//    //判断网络连接状态
//    if ([TestNetWorkReached networkIsReached:viewController]) {
//        if (![WXApi isWXAppInstalled]) { //检查微信是否已被用户安装,微信已安装返回YES
//            //没安装则提示
//            //            [self setupWXAlert:viewController];//弹出提示框
//            return NO;
//        }else{
//
//            //分享友盟
//            //-----------
//            //显示分享面板
//            __block BOOL ShareState;
//
//            [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_WechatFavorite)]];
//            [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
//                // 根据获取的platformType确定所选平台进行下一步操作
//                //platformType:UMSocialPlatformType_WechatSession
//                //创建分享消息对象
//                UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
//
//                UMShareWebpageObject *shareObject;//创建网页内容对象
//                if (icon) {
//                    UIImage *image = nil;
//                    if ([icon isKindOfClass:[NSString class]]){
////                        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:icon]]];
//                        image = [[SDImageCache sharedImageCache] imageFromCacheForKey:icon];
//                    }else if([icon isKindOfClass:[UIImage class]]){
//                        image = icon;
//                    }
//
//                    if (image) {
//                        if (platformType == UMSocialPlatformType_WechatTimeLine) {
//                            shareObject  = [UMShareWebpageObject shareObjectWithTitle:detailStr descr:titleSessionStr thumImage:icon];
//                        }else{
//                            shareObject  = [UMShareWebpageObject shareObjectWithTitle:titleSessionStr descr:detailStr thumImage:image];
//                        }
//
//                    }
//                }
//
//                //分享消息对象设置分享内容对象
//                messageObject.shareObject = shareObject;
//
//                shareObject.webpageUrl = urlStr;
//                //调用分享接口  网页分享
//                /*
//                 UMSocialPlatformType_WechatSession, //微信聊天
//                 UMSocialPlatformType_WechatTimeLine,//微信朋友圈
//                 UMSocialPlatformType_WechatFavorite,//微信收藏
//                 */
//                [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
//                    if (error) {
//                        NSLog(@"************Share fail with error %@*********",error);
//                        ShareState = NO;
//                    }else{
//                        ShareState = YES;
//                        if ([data isKindOfClass:[UMSocialShareResponse class]]) {
//                            UMSocialShareResponse *resp = data;
//                            //分享结果消息
//                            NSLog(@"response message is %@",resp.message);
//                            //第三方原始返回的数据
//                            NSLog(@"response originalResponse data is %@",resp.originalResponse);
//                        }else{
//                            NSLog(@"response data is %@",data);
//                        }
//                    }
//                    [self alertWithError:error];
//                }];
//
//            }];
//            return ShareState;
//
//        }
//
//
//    }else{
//        return NO;
//    }
//    return NO;
//}



- (void)shareOrginImgToApp:(id)shareImgOrImgUrl{
    [[PublicTool topViewController].view endEditing:YES];

    //显示分享面板
    [ShareView showShareViewDidTapPlatform:^(ShareType shareType) {
       
 
        
        WXMediaMessage *message = [WXMediaMessage message];
        WXImageObject *imageObejct = [WXImageObject object];
        NSData *data;
        if ([shareImgOrImgUrl isKindOfClass:[UIImage class]]) {
            
            UIImage *image = [PublicTool compressImage:shareImgOrImgUrl toByte:32*1024];
            [message setThumbImage:image];
            data = UIImagePNGRepresentation(shareImgOrImgUrl);

        }else if([shareImgOrImgUrl isKindOfClass:[NSString class]]){
            
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:shareImgOrImgUrl]];
            UIImage *image = [UIImage imageWithData:data];
            
            UIImage *compressImage = [PublicTool compressImage:image toByte:32*1024];
        
            [message setThumbImage:compressImage];
        }
        
        imageObejct.imageData = data;
        message.mediaObject = imageObejct;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
        req.bText = NO;
        req.message = message;
        if (shareType == ShareTypeWechatSession) {
            req.scene = WXSceneSession;

        }else if(shareType == ShareTypeWechatTimeLine){
            req.scene = WXSceneTimeline;

        }else{
            req.scene = WXSceneFavorite;

        }
        [WXApi sendReq:req];
    }];
}

- (void)shareImgToOtherApp:(id)shareImgOrImgUrl{
    
    //分享截屏到...
    [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"umshareImg"];
    [[NSUserDefaults standardUserDefaults] synchronize];
   
    [self shareOrginImgToApp:shareImgOrImgUrl];
}


- (void)alertWithError:(NSError *)error
{
    NSString *result = nil;
    if (!error) {
        result = [NSString stringWithFormat:@"分享成功"];
    }
    else{
        if (error) {
            result = [NSString stringWithFormat:@"分享取消"];//[NSString stringWithFormat:@"Share fail with error code: %d\n",(int)error.code];
        }
        else{
            result = [NSString stringWithFormat:@"分享出错"];
        }
    }
    
    [ShowInfo showInfoOnView:_vc.view withInfo:result];
}

#pragma mark - 设置提示语
- (void)setupWXAlert:(UIViewController *)viewController{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请先安装微信客户端" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alertView.tag = 602;
        [alertView show];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [viewController.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:actionConfirm];
        [viewController presentViewController:alert animated:YES completion:nil];
    }
}


#pragma mark --详情页截图分享
//详情页 截图的分享
- (void)shareDetailImage:(UIImage*)shareImg{
    
    [ImageShareController showShareViewWithImage:shareImg didTapPlatform:^(ShareType shareType) {
        
       
        
        //微信分享API
        WXMediaMessage *message = [WXMediaMessage message];
        WXImageObject *imageObejct = [WXImageObject object];
        NSData *data;
        UIImage *image = [PublicTool compressImage:shareImg toByte:32*1024];
        [message setThumbImage:image];
        data = UIImagePNGRepresentation(shareImg);
        
        imageObejct.imageData = data;
        message.mediaObject = imageObejct;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
        req.bText = NO;
        req.message = message;
        if (shareType == ShareTypeWechatSession) {
            req.scene = WXSceneSession;
            
        }else if(shareType == ShareTypeWechatTimeLine){
            req.scene = WXSceneTimeline;
            
        }else{
            req.scene = WXSceneFavorite;
            
        }
        [WXApi sendReq:req];
    }];
}

//系统截屏 分享
- (void)shareScreenShotImage:(UIImage*)shareImg{
    
    [ScreenShareView showShareViewWithImage:shareImg didTapPlatform:^(ShareType shareType) {

        //微信分享API
        WXMediaMessage *message = [WXMediaMessage message];
        WXImageObject *imageObejct = [WXImageObject object];
        NSData *data;
        UIImage *image = [PublicTool compressImage:shareImg toByte:32*1024];
        [message setThumbImage:image];
        data = UIImagePNGRepresentation(shareImg);
        
        imageObejct.imageData = data;
        message.mediaObject = imageObejct;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
        req.bText = NO;
        req.message = message;
        if (shareType == ShareTypeWechatSession) {
            req.scene = WXSceneSession;
            
        }else if(shareType == ShareTypeWechatTimeLine){
            req.scene = WXSceneTimeline;
            
        }else{
            req.scene = WXSceneFavorite;
            
        }
        [WXApi sendReq:req];
    }];
}

@end
