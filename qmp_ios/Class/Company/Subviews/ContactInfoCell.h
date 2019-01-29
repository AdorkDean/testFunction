//
//  ContactInfoCell.h
//  qmp_ios
//
//  Created by QMP on 2018/1/12.
//  Copyright © 2018年 Molly. All rights reserved.
//项目联系方式

#import <UIKit/UIKit.h>
#import "CompanyDetailLianxiModel.h"

@interface ContactInfoCell : UITableViewCell

@property (strong, nonatomic) UIButton *showAllBtn2;//右侧按钮
@property (strong, nonatomic) UIButton *showAllBtn;//右侧按钮
@property (strong, nonatomic) UILabel *contentLabel;//右侧内容
@property(nonatomic,assign) BOOL onlyOneRow;

//new
- (void)dataWithKey:(NSString*)key lianxiModel:(CompanyDetailLianxiModel*)lianxiModel;

- (void)dataWithKey:(NSString*)key lianxiInfo:(NSDictionary*)lianxiinfo;

+ (ContactInfoCell *)cellWithTableView:(UITableView *)tableView;
@end
