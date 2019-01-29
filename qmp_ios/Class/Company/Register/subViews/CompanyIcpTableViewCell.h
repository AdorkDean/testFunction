//
//  CompanyIcpTableViewCell.h
//  qmp_ios
//
//  Created by molly on 2017/4/18.
//  Copyright © 2017年 Molly. All rights reserved.
//备案信息  cell

#import <UIKit/UIKit.h>
#import "CompanyIcpModel.h"

@interface CompanyIcpTableViewCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) UILabel *moneyLab;

- (void)initData:(CompanyIcpModel *)model;
@end
