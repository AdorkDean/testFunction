//
//  CombineTableViewCell.h
//  qmp_ios
//
//  Created by Molly on 2016/11/29.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OrganizeCombineItem.h"

/**
 合投/参投 old cell
 */
@interface CombineTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *countLbl;
@property (strong, nonatomic) UIView *lineView;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

- (void)initData:(OrganizeCombineItem *)item;

@property(nonatomic,strong)UIColor *iconColor;
@end
