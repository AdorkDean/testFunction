//
//  AlertInfo.h
//  QimingpianSearch
//
//  Created by Molly on 16/7/24.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"


@interface AlertInfo : NSObject

- (void)alertWithMessage:(NSString *)msg aTitle:(NSString *)title inController:(UIViewController *)currentVC;

-(void)launchAlert:(NetworkStatus)status showHUDAddedTo:(UIView *)view;
@end
