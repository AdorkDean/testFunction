//
//  BPDeliverStatueCell.h
//  qmp_ios
//
//  Created by QMP on 2018/7/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPDeliverStatusModel.h"

@interface BPDeliverStatusCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *deliverBtn;

@property (nonatomic, strong) BPDeliverStatusModel * bpstatusModel;

+ (instancetype)defaultInitCellWithTableView:(UITableView *)tableview;
@end
