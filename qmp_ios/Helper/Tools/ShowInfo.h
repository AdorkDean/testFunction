//
//  ShowInfo.h
//  QimingpianSearch
//
//  Created by Molly on 16/8/14.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ShowInfo : NSObject
+ (void)showInfoOnView:(UIView *)view withInfo:(NSString *)info delay:(CGFloat)delay;
+ (void)showInfoOnView:(UIView *)view withInfo:(NSString *)info;
+ (void)showInfoOnViewTop:(UIView *)view withInfo:(NSString *)info;

@end
