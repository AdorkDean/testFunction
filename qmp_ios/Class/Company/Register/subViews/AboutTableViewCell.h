//
//  AboutTableViewCell.h
//  QimingpianSearch
//
//  Created by Molly on 16/7/22.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanyDetailLianxiModel.h"

@interface AboutTableViewCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) UILabel *contentLabel;//右侧内容

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)initData:(NSString *)key aValue:(NSString *)value;

- (void)initData:(NSString *)key aValue:(NSString *)value currentVC:(UIViewController *)currentVC;

//new
- (void)dataWithKey:(NSString*)key lianxiModel:(CompanyDetailLianxiModel*)lianxiModel;

@end
