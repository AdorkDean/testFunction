//
//  DownloadView.h
//  qmp_ios
//
//  Created by Molly on 2016/11/15.
//  Copyright © 2016年 Molly. All rights reserved.
//pdf下载
/*
 1、action字段标识页面来源： gongsigonggao， hangyanbaogao
 */

#import <UIKit/UIKit.h>

#import "ReportModel.h"

@protocol DownloadViewDelegate <NSObject>

@optional

- (void)pressHiddenDownLoad:(ReportModel *)pdfModel;
- (void)pressCancleDownLoad:(ReportModel *)pdfModel;
- (void)downloadPdfFromUrlSuccess:(ReportModel *)pdfModel;

@end
@interface DownloadView : UIView

@property (weak, nonatomic) id<DownloadViewDelegate> delegate;
@property (assign, nonatomic) BOOL fromUrl;  //
@property (assign, nonatomic) BOOL isShow;

+(instancetype)initFrame;

- (void)initViewWithTitle:(NSString *)title withInfo:(NSString *)info withLeftBtnTitle:(NSString *)leftTitle withRightBtnTitle:(NSString *)rightTitle withCenter:(CGPoint )centerPoint withInfoLblH:(CGFloat)infoLblH ofDocument:(ReportModel *)pdfModel;

@end
