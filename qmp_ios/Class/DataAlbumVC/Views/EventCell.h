//
//  EventCell.h
//  qmp_ios
//
//  Created by QMP on 2017/12/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RZNewsModel.h"

@interface EventCell : UITableViewCell

@property(nonatomic,strong)RZNewsModel *newsModel;

@property(nonatomic,strong) UIColor *iconColor;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end
