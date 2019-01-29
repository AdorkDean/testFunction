//
//  CompanyReportListViewController.h
//  qmp_ios
//
//  Created by Molly on 2016/12/16.
//  Copyright © 2016年 Molly. All rights reserved.

// 公司公告

#import <UIKit/UIKit.h>


@interface CompanyReportListViewController : BaseViewController

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSMutableDictionary *requestDict;
@property (strong, nonatomic) NSString *company;

@end
