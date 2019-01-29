//
//  InfoWithoutConfirmAlertView.h
//  qmp_ios
//
//  Created by molly on 2017/7/20.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InfoWithoutConfirmAlertViewDelegate<NSObject>

@optional
- (void)cancelUpload;
- (void)confirmToChoose;
- (void)confirmToChooseWithData:(NSString *)dataStr;
- (void)confirmToChooseWithData:(NSString *)dataStr isBP:(BOOL)isBP;

@end

@interface InfoWithoutConfirmAlertView : UIView

@property (weak, nonatomic) id<InfoWithoutConfirmAlertViewDelegate> delegate;
@property (strong, nonatomic) NSString *dataStr;

+ (instancetype)initFrame;

- (void)initViewWithTitle:(NSString *)title withInfo:(NSString *)info withLeftBtnTitle:(NSString *)leftTitle  onAction:(NSString *)action;

- (void)initViewWithTitle:(NSString *)title withInfo:(NSString *)info withLeftBtnTitle:(NSString *)leftTitle onAction:(NSString *)action withCenter:(CGPoint )centerPoint withInfoLblH:(CGFloat)infoLblH;

@end
