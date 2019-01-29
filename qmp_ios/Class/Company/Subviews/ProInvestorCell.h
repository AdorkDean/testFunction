//
//  ProInvestorCell.h
//  qmp_ios
//
//  Created by QMP on 2017/12/29.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonModel.h"

@interface ProInvestorCell : UITableViewCell

@property(nonatomic,strong) PersonModel *person;
@property(nonatomic,strong) UIColor *iconColor;
@property(nonatomic,assign) BOOL fromProductDetail;
+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end
