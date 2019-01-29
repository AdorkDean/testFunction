//
//  NewsWebViewController.h
//  qmp_ios
//
//  Created by Molly on 16/9/11.
//  Copyright © 2016年 Molly. All rights reserved.
//  使用 webView 打开 URL

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "ShareTo.h"
#import "URLModel.h"

@protocol NewsWebViewDelegate <NSObject>
@optional
- (void)changeCollectUrlTypeToPdfSuccess:(URLModel *)urlModel;
- (void)getUrlTitleWithOldModel:(URLModel *)oldUrlModel;
- (void)changeTitleOfHistory:(NSDictionary *)newDict;
@end


@interface NewsWebViewController : UIViewController

@property (strong, nonatomic) WKWebView *webView;
@property (copy, nonatomic)   NSString  *fromVC;
@property (strong ,nonatomic) URLModel  *urlModel;
@property (strong, nonatomic) URLModel  *oldUrlModel;
@property (strong, nonatomic) ShareTo  *shareToTool;
@property (assign, nonatomic) NSInteger cellId;
@property (assign, nonatomic) BOOL      isLocal;
@property (copy, nonatomic)   NSString  *feedbackFlag;


@property (nonatomic, assign) id<NewsWebViewDelegate> delegate;

// 公司信息 @{@"company":newsModel.product,@"lunci":newsModel.lunci,@"icon":newsModel.icon,@"yewu":newsModel.yewu};
@property (nonatomic, strong) NSDictionary *companyDic;
@property (nonatomic, strong) NSDictionary *requestDic;

@property (nonatomic, strong) NSDictionary *company;
@property (nonatomic, strong) NSDictionary *person;
@property (nonatomic, strong) NSDictionary *jigou;


- (instancetype)initWithUrlModel:(URLModel *)urlModel withAction:(NSString *)action;
- (instancetype)initWithUrlModel:(URLModel *)urlModel;
@end
