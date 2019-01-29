//
//  NoCommontInfoCell.h
//  qmp_ios
//
//  Created by QMP on 2018/7/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoCommontInfoCell : UITableViewCell
@property (copy, nonatomic) NSString *title;

+(instancetype)cellWithTableView:(UITableView*)tableView clickAddBtn:(void(^)(void))clickAddEvent;

@end
