//
//  OrganizeInvestCaseTableCell.h
//  qmp_ios
//
//  Created by QMP on 2018/7/27.
//  Copyright © 2018年 Molly. All rights reserved.
//


@interface OrganizeInvestCaseTableCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView*)tableView idnetifier:(NSString*)identifier;
+ (instancetype)cellWithTableView:(UITableView*)tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end


