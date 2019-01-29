//
//  SettingTableViewCell.h
//  QimingpianSearch
//
//  Created by Molly on 16/8/3.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView*)tableView;

@property (nonatomic,strong)UIImageView *leftImageV;
@property (nonatomic,strong)UIImageView *rightImageV;
@property (nonatomic,strong)UILabel *titleLab;
@property (nonatomic,strong)UIView *lineView;
@property (nonatomic,strong)UILabel *redPointView;
@property (nonatomic,strong)UIView *keyRedView;

@property (copy, nonatomic) NSString *commentNum;
@property (nonatomic, strong) UIImageView *hotView;

@end
