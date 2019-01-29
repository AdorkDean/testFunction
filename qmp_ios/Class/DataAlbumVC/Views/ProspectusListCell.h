//
//  ProspectusListCell.h
//  qmp_ios
//
//  Created by QMP on 2018/1/8.
//  Copyright © 2018年 Molly. All rights reserved.
//招股书列表cell

#import <UIKit/UIKit.h>

@interface ProspectusListCell : UITableViewCell

@property(nonatomic,strong) ReportModel *report;

//
@property (copy, nonatomic) NSString *keyWord;

//已下载cell
- (void)refreshUI:(ReportModel*)report;

@end
