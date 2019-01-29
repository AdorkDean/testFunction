//
//  BPSelectCell.h
//  qmp_ios
//
//  Created by QMP on 2018/1/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReportModel.h"

@interface BPSelectCell : UITableViewCell

@property(nonatomic,strong) UIButton *selecctBtn;

@property (copy, nonatomic) NSString *keyWord;
@property(nonatomic,strong) ReportModel *report;
@property (nonatomic, assign) BOOL isMyBP;

@end
