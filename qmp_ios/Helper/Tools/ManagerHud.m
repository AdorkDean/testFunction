//
//  ManagerHud.m
//  qmp_ios
//
//  Created by Molly on 16/9/2.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "ManagerHud.h"

@implementation ManagerHud

- (void)addBlackBackgroundViewWithHud:(UIView *)view withCenter:(CGPoint )center{
    if(![self.hud isDescendantOfView:view]){
        
        UIView *backgroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        backgroudView.backgroundColor = [UIColor blackColor];
        backgroudView.alpha = 0.8;
        backgroudView.layer.masksToBounds = YES;
        backgroudView.layer.cornerRadius = 10.f;
        [view addSubview:backgroudView];
        backgroudView.center = center;
        _backgroundView = backgroudView;
        
        self.hud =  [[ProgressHUD alloc] initWithView:view];
        [view addSubview:self.hud];
        self.hud.center = backgroudView.center;
        
        [self.hud showAnimated:YES];
    }
}

- (void)addBlackBackgroundViewWithHud:(UIView *)view{
    if(![self.hud isDescendantOfView:view]){
        
        UIView *backgroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        backgroudView.backgroundColor = [UIColor blackColor];
        backgroudView.alpha = 0.8;
        backgroudView.layer.masksToBounds = YES;
        backgroudView.layer.cornerRadius = 10.f;
        [view addSubview:backgroudView];
        backgroudView.center = view.center;
        _backgroundView = backgroudView;
        
        self.hud =  [[ProgressHUD alloc] initWithView:view];
        [view addSubview:self.hud];
        self.hud.center = backgroudView.center;

        [self.hud showAnimated:YES];
    }
}

- (void)addBackgroundViewWithHud:(UIView *)view{
    if(![self.hud isDescendantOfView:view]){
        
        UIView *backgroudView = [[UIView alloc] initWithFrame:view.bounds];
        backgroudView.backgroundColor = [UIColor whiteColor];
        [view addSubview:backgroudView];
        _backgroundView = backgroudView;
        
        self.hud =  [[ProgressHUD alloc] initWithView:view];
        self.hud.center = view.center;
        [view addSubview:self.hud];
        
        backgroudView.center = self.hud.center;
        
        [self.hud showAnimated:YES];
    }
    
    
}


- (void)addHud:(UIView *)view{
    if(![self.hud isDescendantOfView:view]){
        self.hud =  [[ProgressHUD alloc] initWithView:view];
        self.hud.center = view.center;
        [view addSubview:self.hud];
        
        [self.hud showAnimated:YES];
    }
}

- (void)changeInfo:(NSString *)info{
    if (self.hud) {
        self.hud.label.text = NSLocalizedString(info, @"HUD message title");
    }
}

- (void)removeHud{
    
    if (self.hud) {
        [self.hud removeFromSuperview];
        self.hud = nil;
    }
}

- (void)removeHudWithBackground{
    [self removeHud];
    
    if (self.backgroundView) {
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
    
}

- (void)showHudOnViewAutoHide:(UIView *)view withInfo:(NSString *)info{
    
    [self showHudOnViewAutoHide:view withInfo:info withSeconds:2.f];
}

- (void)showHudOnViewAutoHide:(UIView *)view withInfo:(NSString *)info withSeconds:(CGFloat)seconds{
    
    ProgressHUD *hud = [ProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = ProgressHUDModeText;
    hud.tintColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = RGBa(50, 49, 55, 1);
    hud.label.textColor = [UIColor whiteColor];
    hud.label.text = info;
    [hud hideAnimated:YES afterDelay:seconds];
}

@end
