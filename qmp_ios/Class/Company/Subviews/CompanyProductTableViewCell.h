//
//  CompanyProductTableViewCell.h
//  qmp_ios
//
//  Created by molly on 2017/6/9.
//  Copyright © 2017年 Molly. All rights reserved.
//公司业务cell

#import <UIKit/UIKit.h>
#import "SearchCompanyModel.h"

@interface CompanyProductTableViewCell : UITableViewCell
@property(nonatomic,strong) UIView *bottomLine;
- (void)initData:(SearchCompanyModel *)company;
@property(nonatomic,strong) UIColor *iconColor;
@end
