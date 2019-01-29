//
//  DataHandle.m
//  qmp_ios
//
//  Created by Molly on 2017/2/9.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "DataHandle.h"
#import "EaseSDKHelper.h"

@implementation DataHandle
- (void)handleOtherRetStatus:(NSString *)status onCurrentVC:(UIViewController *)currentVC  withAction:(NSString *)actionStr withData:(NSDictionary *)dict{
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\niOS Version : %@ %@",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         [UIDevice currentDevice].model,
                         [UIDevice currentDevice].systemName,
                         [UIDevice currentDevice].systemVersion];
    NSString *ip = dict[@"ip"];
//    NSString *ip = @"";
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    
    NSString *info = @"";
    switch (status.intValue) {
        case 1:
            info = @"参数缺失，请尝试重新加载";
            break;
        case 2:
            info = @"ticket error,请尝试重新加载";
            break;
        case 3:
            info = @"IP被封,请尝试刷新";
            break;
        case 5:
        case 10003:
            info = @"用户被封,请尝试刷新或联系客服解决";
            break;
        case 13:
            info = @"禁止访问";
            break;
    
        case 27:
            info = @"合作接口请求频繁";
            break;
        case 97:
            info = @"系统繁忙，请稍后再试";
            break;
        case 98:
            info = @"数据库错误,请尝试刷新";
            break;
        case 99:
            info = @"需要您重新登录";
            break;
        case 10004:
            info = @"需要您重新登录";
            break;
            
        default:
            info = @"其他-访问失败，请稍后访问";
            break;
    }
    
    
    info = [NSString stringWithFormat:@"ErrorCode-%@：%@。\nIP：%@ \n%@\n name: %@\n操作:%@" ,status,info,ip,appInfo,name ? name : @"",actionStr];
    
#ifdef DEBUG

    if (status.intValue != 22) {
        [PublicTool alertActionWithTitle:@"异常提示(开发测试)" message:info btnTitle:@"好的" action:^{
        }];
    }
#else
   
    //发布版本 仅这几种status需要展示给用户
    NSArray *statusArr = @[@"3",@"5",@"13",@"27",@"99",@"10004",@"10003"];
    
    if ([statusArr containsObject:status]) {
        if (status.integerValue == 10003||status.integerValue == 5) {
            [PublicTool alertActionWithTitle:@"异常提示" message:info leftTitle:@"我知道了" rightTitle:@"联系客服" leftAction:nil rightAction:^{
                NSString *chatInfo = [NSString stringWithFormat:@"%@\n%@",@"你好，我的账号遇到异常情况需要处理",info];
                [PublicTool contactKefu:chatInfo reply:nil];
            }];
        }else{
            [PublicTool alertActionWithTitle:@"异常提示" message:info btnTitle:@"好的" action:^{
                if ([self.delegate respondsToSelector:@selector(pressOKOnDataHandleAlertView)]) {
                    [self.delegate pressOKOnDataHandleAlertView];
                }
            }];
        }
    }
    
#endif
   
}

- (NSString *)getPublicIP{
    NSString *ip = @"";
    
    NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"http://ip.taobao.com/service/getIpInfo.php?ip=myip"];
    NSString *retStr = [NSString stringWithContentsOfURL:ipURL encoding:NSUTF8StringEncoding error:&error];
    NSDictionary *retDict = [self dictionaryWithJsonString:retStr];
    NSDictionary *dataDict = retDict[@"data"];
    if (dataDict && [dataDict isKindOfClass:[NSDictionary class]]) {
        ip = dataDict[@"ip"];
    }
    return ip;
}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        QMPLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
    
}
@end
