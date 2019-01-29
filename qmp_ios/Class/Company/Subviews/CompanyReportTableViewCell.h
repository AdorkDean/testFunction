//
//  CompanyReportTableViewCell.h
//  qmp_ios
//
//  Created by Molly on 2016/12/15.
//  Copyright © 2016年 Molly. All rights reserved.

/**
 公司公告
 
 */

#import <UIKit/UIKit.h>

#import "ReportModel.h"

@interface CompanyReportTableViewCell : UITableViewCell
@property (strong, nonatomic)  UIView  *bottomLine;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)initData:(ReportModel *)pdfModel;

@end
