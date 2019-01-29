//
//  ShowInfo.m
//  QimingpianSearch
//
//  Created by Molly on 16/8/14.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "ShowInfo.h"
#import <UIKit/UIKit.h>
#import "GetSizeWithText.h"

@interface ShowInfo()

@property (strong, nonatomic) GetSizeWithText *getSizeTool;

@end
@implementation ShowInfo

+ (void)showInfoOnView:(UIView *)view withInfo:(NSString *)info delay:(CGFloat)delay {
    
    UILabel *label = [view viewWithTag:333];
    if (label) {
        [label removeFromSuperview];
    }
    
    UIFont *font = [UIFont systemFontOfSize:14.f];
    
    CGSize size = [GetSizeWithText calculateSize:info withFont:font withWidth:SCREENW - 100];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ceil(size.width) + 30, ceil(size.height) + 30)];
    lbl.layer.cornerRadius = 10.f;
    lbl.layer.masksToBounds = YES;
    lbl.text = info;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = font;
    lbl.textColor = [UIColor whiteColor];
    lbl.backgroundColor = [UIColor blackColor];
    lbl.center =  CGPointMake(SCREENW / 2, SCREENH / 2);
    lbl.alpha = 0.0;
    
    [view addSubview:lbl];
    lbl.tag = 33333;
    
    
    [UIView animateWithDuration:0.2 animations:^{
        lbl.alpha = 1.0;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
            lbl.alpha = 0.0;
        } completion:^(BOOL finished) {
            
            [lbl removeFromSuperview];
        }];
    }];
}

+ (void)showInfoOnView:(UIView *)view withInfo:(NSString *)info{
    
    UILabel *label = [view viewWithTag:333];
    if (label) {
        [label removeFromSuperview];
    }
    
    UIFont *font = [UIFont systemFontOfSize:14.f];
    
    CGSize size = [GetSizeWithText calculateSize:info withFont:font withWidth:SCREENW - 100];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ceil(size.width) + 30, ceil(size.height) + 30)];
    lbl.layer.cornerRadius = 10.f;
    lbl.layer.masksToBounds = YES;
    lbl.text = info;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = font;
    lbl.textColor = [UIColor whiteColor];
    lbl.backgroundColor = [UIColor blackColor];
    lbl.center =  CGPointMake(SCREENW / 2, SCREENH / 2);
    lbl.alpha = 0.0;
    
    [view addSubview:lbl];
    lbl.tag = 33333;

    
    [UIView animateWithDuration:0.2 animations:^{
        lbl.alpha = 1.0;
    } completion:^(BOOL finished) {
       
        [UIView animateWithDuration:0.2 delay:0.8 options:UIViewAnimationOptionCurveLinear animations:^{
            lbl.alpha = 0.0;
        } completion:^(BOOL finished) {
           
            [lbl removeFromSuperview];
        }];
    }];
}

+ (void)showInfoOnViewTop:(UIView *)view withInfo:(NSString *)info{
    //创建消息提示框
    UIView *fatherLabelView = [[UIView alloc] initWithFrame:CGRectMake(-1, 0, SCREENW + 2, 40)];
    fatherLabelView.backgroundColor = RGB(255, 241, 220, 1);
    fatherLabelView.layer.masksToBounds = YES;
    [fatherLabelView.layer setBorderColor:RGB(255, 227, 184, 1).CGColor];
    [fatherLabelView.layer setBorderWidth:1.f];
    [view addSubview:fatherLabelView];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 1, SCREENW - 16, 38)];
    infoLabel.text = info;
    infoLabel.font = [UIFont systemFontOfSize:14.f];
    [fatherLabelView addSubview:infoLabel];

    [UIView animateWithDuration:.2 animations:^{
        fatherLabelView.alpha = 1.0;
    }completion:^(BOOL finished) {
       
        [UIView animateWithDuration:.2 delay:2.0 options:UIViewAnimationOptionCurveLinear animations:^{
            fatherLabelView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [fatherLabelView removeFromSuperview];
        }];
    }];
}


@end
