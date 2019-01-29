//
//  CompanysDetailRegisterGudongCell.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/12.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CopyLabel.h"
#import "SearchButton.h"

@class CompanysDetailRegisterGudongModel;
@interface CompanysDetailRegisterGudongCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) UILabel *percentLab;

@property (nonatomic,strong) CopyLabel *nameLbl;
@property (nonatomic,strong) UIImageView *iconImg;
@property (nonatomic,strong) UIButton *imgBtn;
@property (nonatomic,copy)NSString *nameDetailUrl;

-(void)refreshUI:(CompanysDetailRegisterGudongModel *)model;

@end
