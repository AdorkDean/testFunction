//
//  TestNetWorkReached.m
//  QimingpianSearch
//
//  Created by Molly on 16/7/27.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "TestNetWorkReached.h"
#import "ShowInfo.h"
#import "Reachability.h"


@implementation TestNetWorkReached

+ (BOOL)isWifi{
    //判断网络连接状态
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    //    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    if (status == ReachableViaWiFi) {
        
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)networkIsReached:(UIViewController *)viewController{

    //判断网络连接状态
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
//    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    if (status == 0) {
        
        [ShowInfo showInfoOnView:KEYWindow withInfo:@"网络连接不可用，请稍后再试"];//网络未连接
        return NO;
    }
    else{
        return YES;
    }
}

+ (BOOL)networkIsReachedAlertOnView:(UIView *)view{
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == 0) {
        
        [ShowInfo showInfoOnView:KEYWindow withInfo:@"网络连接不可用，请稍后再试"];//网络未连接
        return NO;
    }
    else{
        
        return YES;
    }
}

+ (BOOL)networkIsReachedNoAlert{
    
    //判断网络连接状态
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
//    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    if (status == 0) {
        
        return NO;
    }
    else{
        
        return YES;
    }
}

@end
