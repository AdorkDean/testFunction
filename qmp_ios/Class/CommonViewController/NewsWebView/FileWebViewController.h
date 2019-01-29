//
//  FileWebViewController.h
//  qmp_ios
//
//  Created by Molly on 2016/11/4.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "FileItem.h"
#import "ReportModel.h"

@protocol changeNoPdfCollectionStatusDelegate <NSObject>
@optional
- (void)changeNoPdfCollectionStatusByClick:(ReportModel *)changeModel;
@end

@interface FileWebViewController : UIViewController

@property (strong, nonatomic) FileItem *fileItem;

@property (strong, nonatomic) WKWebView *myWKWebView;
@property (nonatomic, copy) NSString * collect_flag_status ;
@property (nonatomic, copy) NSString * local_collect_flag;
@property (strong, nonatomic) ReportModel * reportModel;
@property (nonatomic, weak) id <changeNoPdfCollectionStatusDelegate>deleage;
@end
