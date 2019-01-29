//
//  InvestorListCell.h
//  qmp_ios
//
//  Created by QMP on 2017/12/29.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonModel.h"

@interface InvestorListCell : UITableViewCell

@property(nonatomic,strong) PersonModel *person;
@property (weak, nonatomic) IBOutlet UIButton *xibChatBtn;
@property(nonatomic,strong) UIColor *iconColor;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end
