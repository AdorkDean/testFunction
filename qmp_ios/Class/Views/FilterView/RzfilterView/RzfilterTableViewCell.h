//
//  RzfilterTableViewCell.h
//  qmp_ios
//
//  Created by Molly on 2017/1/16.
//  Copyright © 2017年 Molly. All rights reserved.
//事件 section

#import <UIKit/UIKit.h>

#import "IndustryItem.h"

@interface RzfilterTableViewCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isCountry:(BOOL)isCountry withCount:(NSInteger)count withDataMArr:(NSMutableArray *)dataMArr withSelectedMArr:(NSMutableArray *)selectMArr;

@end
