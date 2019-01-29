//
//  OpenDocument.h
//  QimingpianSearch
//
//  Created by Molly on 16/8/3.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "ReportModel.h"
#import "Reachability.h"

@protocol OpenDocumentDelegate <NSObject>

- (void)downloadPdfUseWWAN:(ReportModel *)reportModel;

@end

@interface OpenDocument : NSObject

@property (weak, nonatomic) UIViewController *viewController;

@property (weak, nonatomic) id<OpenDocumentDelegate> delegate;
@property (strong, nonatomic) ReportModel *pdfModel;

- (void)openDocumentofFilePath:(NSString *)filePath reportModel:(ReportModel*)pdfModel;

- (void)openDocumentofReportModel:(ReportModel *)pdfModel;
//- (void)openDocument:(NSString *)nsfilename aUrl:(NSString *)urlStr aPDFType:(NSString *)pdfType aPDFId:(NSString *)pdfId;
- (BOOL)downDocumentToBox:(ReportModel *)pdfModel;
- (void)launchReachableViaWWANAlert:(NetworkStatus)status ofCurrentVC:(UIViewController *)currentVC withModel:(ReportModel *)reportModel;

@end
