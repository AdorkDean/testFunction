//
//  AlertInfo.m
//  QimingpianSearch
//
//  Created by Molly on 16/7/24.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "AlertInfo.h"
#import "Reachability.h"
//#import "RealReachability.h"
#import "ShowInfo.h"

@implementation AlertInfo

- (void)alertWithMessage:(NSString *)msg aTitle:(NSString *)title inController:(UIViewController *)currentVC{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
        }];
        [alert addAction:action];
        [currentVC presentViewController:alert animated:YES completion:nil];
        
    }
}

/**
 *  hud 网络连接不可用
 *
 *  @param status
 *  @param view
 */
-(void)launchAlert:(NetworkStatus)status showHUDAddedTo:(UIView *)view{
    [ShowInfo showInfoOnView:view withInfo:@"感谢您的反馈"];
}


@end

