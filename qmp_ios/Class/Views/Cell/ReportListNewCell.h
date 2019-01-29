//
//  ReportListNewCell.h
//  qmp_ios
//
//  Created by QMP on 2017/9/28.
//  Copyright © 2017年 Molly. All rights reserved.

//行研报告

#import <UIKit/UIKit.h>
#import "ReportModel.h"
#import "MeDocumentListModel.h"

@interface ReportListNewCell : UITableViewCell
@property(nonatomic,strong)UIImageView *downIcon;

@property(nonatomic,strong)UILabel *sourceLabel;

@property (copy, nonatomic) NSString *keyWord;
@property(nonatomic,assign) BOOL showScanCount; //显示浏览数，热度
@property(nonatomic,strong) ReportModel *report;

- (void)refreshUI:(ReportModel*)report;
@property (nonatomic, strong) MeDocumentListModel * documentsModel;

@end
