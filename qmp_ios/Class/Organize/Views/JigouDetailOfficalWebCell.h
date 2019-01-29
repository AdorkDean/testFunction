//
//  JigouIntroduceCell.h
//  qmp_ios
//
//  Created by QMP on 2017/9/27.
//  Copyright © 2017年 Molly. All rights reserved.
//机构官网单独 cell

#import <UIKit/UIKit.h>
#import "OrganizeItem.h"
@interface JigouDetailOfficalWebCell : UITableViewCell

@property(nonatomic,strong)  UIViewController *vc;

- (CGFloat)setOrganize:(OrganizeItem*)organizeItem;
+ (JigouDetailOfficalWebCell *)cellWithTableView:(UITableView *)tableView;
@end
