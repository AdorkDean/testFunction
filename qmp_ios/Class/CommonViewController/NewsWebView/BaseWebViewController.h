//
//  BaseWebViewController.h
//  qmp_ios
//
//  Created by Molly on 16/9/11.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "URLModel.h"

@protocol BaseWebViewDelegate <NSObject>

- (void)getUrlTitleWithOldModel:(URLModel *)oldUrlModel ofNewModel:(URLModel *)newUrlModel;

@end

@interface BaseWebViewController : UIViewController

@property (strong, nonatomic) WKWebView *myWKWebView;

@property (strong ,nonatomic) URLModel *urlModel;
@property (strong, nonatomic) URLModel *oldUrlModel;

@property (strong, nonatomic) ManagerHud *hudTool;

@property (copy, nonatomic) NSString *feedbackFlag;

@property (weak, nonatomic) id<BaseWebViewDelegate> baseDelegate;

- (instancetype)initWithUrlModel:(URLModel *)urlModel;


@end
