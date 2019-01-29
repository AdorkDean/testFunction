//
//  CompanyDetailSimilarCell.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/5.
//  Copyright © 2016年 qimingpian. All rights reserved.
//公司相似项目cell

#import <UIKit/UIKit.h>
@class SearchCompanyModel;

@interface CompanyDetailSimilarCell : UITableViewCell

@property(nonatomic,strong) UIView *bottomLine;
@property (nonatomic,strong)UIButton *moreBtn;

//刷新函数
-(void)refreshUI:(SearchCompanyModel *)model;

@property(nonatomic,strong) UIColor *iconColor;
@end
