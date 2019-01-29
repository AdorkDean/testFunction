//
//  WinExperienceCell.h
//  qmp_ios
//
//  Created by QMP on 2018/4/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WinExperienceModel.h"

@interface WinExperienceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;

@property(nonatomic,strong) WinExperienceModel *experienceM;

@end
