//
//  JigouInvestGeneralCell.h
//  qmp_ios
//
//  Created by QMP on 2017/9/27.
//  Copyright © 2017年 Molly. All rights reserved.
// 机构详情 投资概况

#import <UIKit/UIKit.h>
#import "OrganizeItem.h"

@interface JigouInvestGeneralCell : UITableViewCell
@property(nonatomic,strong) OrganizeItem *organizeItem;
@property(nonatomic,assign) BOOL secondRequestFinish;
@property (copy, nonatomic) void(^clickIndex)(NSString *selectedStr);

+ (JigouInvestGeneralCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, copy) NSString *memberCount;
@end
