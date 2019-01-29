//
//  SearchJigouCell.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/3.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsetsLabel.h"

@class SearchJigouModel;

@interface SearchJigouCell : UITableViewCell
{
    UIImageView * _iconImageV;//icon
    UILabel * _iconLabel;
    
    UILabel * _jieduanLab;//阶段
    UILabel * _touzijigouLab;//"投资机构"
    
}
@property (nonatomic, strong) UILabel * jigou_nameLab;//机构名字
@property(nonatomic,strong) UIView* lineV;
@property(nonatomic,strong) InsetsLabel *zaifuLab;
@property (nonatomic,copy) NSString * detailUrl;//存取model的detail,后边点击cell进入详情页时会用到
@property(nonatomic,strong) SearchJigouModel* model;
@property(nonatomic,strong) NSDictionary* modelDic;

@property(nonatomic,strong) UIColor *iconColor;

//刷新函数
-(void)refreshUI:(SearchJigouModel *)model;

//项目投资机构
-(void)refreshTzJigouUI:(NSDictionary *)dic;
-(void)refreshIconColor:(UIColor *)color;

+ (SearchJigouCell *)searchJigouCellWithTableView:(UITableView *)tableView;
@end
