//
//  InvestorTzCaseCell.h
//  qmp_ios
//
//  Created by QMP on 2017/11/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonTouziModel.h"

@interface InvestorTzCaseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property(nonatomic,strong) PersonTouziModel *tzCaseM;
@property(nonatomic,strong) UIColor *iconColor;

@end
