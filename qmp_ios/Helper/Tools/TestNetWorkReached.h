//
//  TestNetWorkReached.h
//  QimingpianSearch
//
//  Created by Molly on 16/7/27.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TestNetWorkReached : NSObject
+ (BOOL)isWifi;
+ (BOOL)networkIsReached:(UIViewController *)viewController;
+ (BOOL)networkIsReachedAlertOnView:(UIView *)view;
+ (BOOL)networkIsReachedNoAlert;

@end
