//
//  CompanysDetailRegisterChangeRecordsCell.h
//  qmp_ios
//
//  Created by qimingpian10 on 2017/2/20.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CopyLabel.h"
#import "VerticalToplabel.h"

@class CompanysDetailRegisterChangeRecordsModel;
@interface CompanysDetailRegisterChangeRecordsCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property(nonatomic,strong) UIView *bottomLine;

@property (nonatomic,strong) UILabel *timeLab;
@property (nonatomic,strong) CopyLabel *nameLab;
@property (nonatomic,strong) UILabel *beforeLab;
@property (nonatomic,strong) UILabel *afterLab;
@property (nonatomic,strong) VerticalToplabel *beforeCopyLab;
@property (nonatomic,strong) VerticalToplabel *afterCopyLab;

-(void)refreshUI:(CompanysDetailRegisterChangeRecordsModel *)model;

@end
