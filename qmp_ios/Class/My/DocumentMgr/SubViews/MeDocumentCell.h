//
//  MeDocumentCell.h
//  qmp_ios
//
//  Created by QMP on 2018/7/27.
//  Copyright © 2018年 Molly. All rights reserved.
//我的文档 的cell

#import <UIKit/UIKit.h>
#import "MeDocumentListModel.h"

@interface MeDocumentCell : UITableViewCell
@property(nonatomic,strong)UILabel *sourceLabel;

@property (copy, nonatomic) NSString *keyWord;
@property(nonatomic,strong) ReportModel *report;
@property(nonatomic,assign) BOOL showSource;

- (void)refreshUI:(ReportModel*)report;
@property (nonatomic, strong) MeDocumentListModel * documentsModel;
@end
