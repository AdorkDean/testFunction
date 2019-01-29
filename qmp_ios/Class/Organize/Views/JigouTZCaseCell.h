//
//  JigouTZCaseCell.h
//  qmp_ios
//
//  Created by QMP on 2017/9/27.
//  Copyright © 2017年 Molly. All rights reserved.
// 机构详情 ----投资案例 cell

#import <UIKit/UIKit.h>
#import "JigouInvestmentsCaseModel.h"

typedef void(^RefreshHeight)(CGFloat height);
@interface JigouTZCaseCell : UITableViewCell

@property(nonatomic,strong) UIColor *iconColor;

+ (JigouTZCaseCell *)cellWithTableView:(UITableView *)tableView;

// 投资 、FA 案例，合投项目, 战绩
- (CGFloat)setCaseModel:(JigouInvestmentsCaseModel*)model;

/**参投 赋值*/
- (void)layoutWithCaseModel:(JigouInvestmentsCaseModel*)model;

@end
