//
//  CompanysDetailRegisterPeoplesCell.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/27.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CopyLabel.h"
@class CompanysDetailRegisterPeoplesModel;
@interface CompanysDetailRegisterPeoplesCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) UIButton *searchBtn;

-(void)refreshUI:(CompanysDetailRegisterPeoplesModel *)model nameColor:(UIColor *)nameColor;
@end
