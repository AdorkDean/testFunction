//
//  IPOCompanyCell.h
//  qmp_ios
//
//  Created by QMP on 2018/1/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCompanyModel.h"

@interface IPOCompanyCell : UITableViewCell

@property(nonatomic,strong) UIView* bottomLine;


@property (nonatomic,strong)UILabel * productLab;
-(void)refreshUI:(SearchCompanyModel *)model;
@property(nonatomic,strong) UIColor *iconBgColor;
@end
