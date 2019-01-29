//
//  ProRegisterCell.h
//  qmp_ios
//
//  Created by QMP on 2018/6/28.
//  Copyright © 2018年 Molly. All rights reserved.

//工商cell

#import <UIKit/UIKit.h>

@interface ProRegisterCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView*)tableView titles:(NSArray*)titles  images:(NSArray*)images didSelectedItem:(void(^)(NSString *title))didSelectItem;

@end
