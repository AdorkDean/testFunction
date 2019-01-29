//
//  FAProductCell.h
//  qmp_ios
//
//  Created by QMP on 2018/4/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrgFaProductModel.h"

@interface FAProductCell : UITableViewCell
@property(nonatomic,strong) OrgFaProductModel *faProductM;
+ (FAProductCell *)cellWithTableView:(UITableView *)tableView;
@end
