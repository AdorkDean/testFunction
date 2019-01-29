//
//  ProductValueActivityCell.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/8/7.
//  Copyright © 2018年 Molly. All rights reserved.
//价值动态

#import <UIKit/UIKit.h>

#import <YYText.h>
@interface ProductValueActivityCell : UITableViewCell
+ (instancetype)productValueActivityCellWithTableView:(UITableView *)tableView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) YYLabel *label;
@end
