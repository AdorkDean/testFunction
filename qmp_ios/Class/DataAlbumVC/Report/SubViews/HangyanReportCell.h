//
//  HangyanReportCell.h
//  qmp_ios
//
//  Created by QMP on 2018/7/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReportModel.h"
#import "MeDocumentListModel.h"


@interface HangyanReportCell : UITableViewCell

@property(nonatomic,strong)UIImageView *downIcon;

@property(nonatomic,strong)UILabel *sourceLabel;

@property(nonatomic,strong) ReportModel *report;

- (void)refreshUI:(ReportModel*)report;
@property (nonatomic, strong) MeDocumentListModel * documentsModel;


@end
