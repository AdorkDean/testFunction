//
//  ManagerHud.h
//  qmp_ios
//
//  Created by Molly on 16/9/2.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ProgressHUD.h"


@interface ManagerHud : NSObject

@property (strong, nonatomic) ProgressHUD *hud;
@property (strong, nonatomic) UIView *backgroundView;

- (void)addHud:(UIView *)view;
- (void)removeHud;

- (void)showHudOnViewAutoHide:(UIView *)view withInfo:(NSString *)info;

- (void)showHudOnViewAutoHide:(UIView *)view withInfo:(NSString *)info withSeconds:(CGFloat)seconds;

- (void)changeInfo:(NSString *)info;

- (void)addBackgroundViewWithHud:(UIView *)view;
- (void)addBlackBackgroundViewWithHud:(UIView *)view;
- (void)addBlackBackgroundViewWithHud:(UIView *)view withCenter:(CGPoint )center;

- (void)removeHudWithBackground;
@end
