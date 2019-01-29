//
//  HotJigouListCell.h
//  qmp_ios
//
//  Created by QMP on 2018/1/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrganizeItem.h"

@interface HotJigouListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *orderLab;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *countLab;

@property(nonatomic,strong) OrganizeItem *organize;

@end
