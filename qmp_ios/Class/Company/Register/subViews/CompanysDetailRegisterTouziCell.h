//
//  CompanysDetailRegisterTouziCell.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/12.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CopyButton.h"
@class CompanysDetailRegisterTouziModel;

@interface CompanysDetailRegisterTouziCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic,strong) CopyButton *nameBtn;
@property (nonatomic,strong) UIImageView *iconImg;
@property (nonatomic,strong) UIButton *imgBtn;
//@property (nonatomic,strong) UIView *lineV;

-(void)refreshUI:(CompanysDetailRegisterTouziModel *)model;

@end
