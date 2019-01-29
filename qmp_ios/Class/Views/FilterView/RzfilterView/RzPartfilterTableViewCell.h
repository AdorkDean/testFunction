//
//  RzPartfilterTableViewCell.h
//  qmp_ios
//
//  Created by molly on 2017/4/26.
//  Copyright © 2017年 Molly. All rights reserved.
//领域 section

#import <UIKit/UIKit.h>
#import "IndustryItem.h"

@interface RzPartfilterTableViewCell : UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDataMArr:(NSMutableArray *)dataMArr withSelectedMArr:(NSMutableArray *)selectMArr withCount:(NSInteger)count;

@end
