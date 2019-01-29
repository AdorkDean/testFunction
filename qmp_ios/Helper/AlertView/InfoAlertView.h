//
//  InfoAlertView.h
//  qmp_ios
//
//  Created by Molly on 16/9/6.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InfoAlertView;

@protocol AlertViewDelegate <NSObject>
@optional
- (void)confirmRemoveAllGroup:(UIView *)alertView;
- (void)confirmCollectUrl;
- (void)openUrl;


- (void)infoAlertViewOpenUrl:(InfoAlertView *)view;
- (void)infoAlertViewCollectUrl:(InfoAlertView *)view;
@end

@interface InfoAlertView : UIView
@property (weak, nonatomic) id<AlertViewDelegate> delegate;

+(instancetype)initFrame;
- (void)initCloseBtnView;
- (void)initViewWithTitle:(NSString *)title withInfo:(NSString *)info;
- (void)initViewWithTitle:(NSString *)title withInfo:(NSString *)info withLeftBtnTitle:(NSString *)leftTitle withRightBtnTitle:(NSString *)rightTitle onAction:(NSString *)action;
- (void)initViewWithTitle:(NSString *)title withInfo:(NSString *)info withLeftBtnTitle:(NSString *)leftTitle withRightBtnTitle:(NSString *)rightTitle onAction:(NSString *)action withCenter:(CGPoint )centerPoint withInfoLblH:(CGFloat)infoLblH;

@end
