//
//  QMPWechatEvent.m
//  qmp_ios
//
//  Created by QMP on 2018/8/21.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPWechatEvent.h"
#import "WXApi.h"

@interface QMPWechatEvent()<WXApiDelegate>

@end



@implementation QMPWechatEvent



+ (instancetype)shared{
    static QMPWechatEvent *instanceWechat = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instanceWechat = [[QMPWechatEvent alloc]init];
    });
    return instanceWechat;
}


- (void)registWechat{
    [WXApi registerApp:kWXAPP_ID enableMTA:YES];
}

- (BOOL)loginWechat{
    
    if ([WXApi isWXAppInstalled]) {  //用户安装了微信客户端
        [USER_DEFAULTS setBool:YES forKey:LOGIN_WECHAT_CLICK];
        [USER_DEFAULTS synchronize];
        
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo,snsapi_base";
        req.state = @"qmp";
        [WXApi sendReq:req];
        return YES;
    }
    return NO;
}


- (BOOL)handleOpenUrl:(NSURL*)url{
    return  [WXApi handleOpenURL:url delegate:self];
}




#pragma mark --Request--
- (void)getToken:(NSString *)code{
    
    [PublicTool showHudWithView:KEYWindow];
    
    //由code得到token( 得到uuid)
    NSDictionary * dic = @{@"ptype": @"qmp_ios", @"version": [NSString stringWithFormat:@"%@",VERSION], @"code":code};
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"login/getToken" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        

        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSString *uuid = resultData[@"uuid"];
            NSString *unionid = resultData[@"unionid"];
            if (![PublicTool isNull:uuid]) {
                WechatUserInfo *userModel = [WechatUserInfo shared];
                userModel.unionid = unionid;
                [[ToLogin shared].delegate refreshUserInfo];
                
            }else{
                //getToken status=0 但是uuid有问题
                [ToLogin loginFailWithFunction:[NSString stringWithFormat:@"%s",__FUNCTION__]
                                          desc:[NSString stringWithFormat:@"status=0 但是uuid有问题"]
                                       fromURL:@"login/getToken"];
                
                [PublicTool alertActionWithTitle:@"微信登录失败" message:@"uuid获取失败" btnTitle:@"确定" action:nil];
            }
        }else{

            [PublicTool showMsg:@"登录失败"];            
        }
    }];
}


#pragma mark --WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *temp = (SendAuthResp *)resp;
        
        if (temp.errCode == 0) {
            [self getToken:temp.code];
        } else { // 将error授权
            [ShowInfo showInfoOnView:KEYWindow withInfo:@"微信授权失败,请重新登录!"];
            [ToLogin loginFailWithFunction:[NSString stringWithFormat:@"%s",__FUNCTION__]
                                      desc:[NSString stringWithFormat:@"微信登录回调了，是登录的授权信息，但是temp.errCode != 0，errCode=%D",temp.errCode]
                                   fromURL:@""];
        }
        
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]) { //微信分享
        if (resp.errCode == 0) { // 成功
            [ShowInfo showInfoOnView:KEYWindow withInfo:@"分享成功"];
        }else{
            [ShowInfo showInfoOnView:KEYWindow withInfo:@"分享失败"];
        }
    } else { // 如果返回的不是最新的
        [ToLogin loginFailWithFunction:[NSString stringWithFormat:@"%s",__FUNCTION__]
                                  desc:[NSString stringWithFormat:@"微信登录回调了，但是不是登录的授权信息"]
                               fromURL:@""];
    }
}



@end
