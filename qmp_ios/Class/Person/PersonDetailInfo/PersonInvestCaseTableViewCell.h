//
//  PersonInvestCaseTableViewCell.h
//  qmp_ios
//
//  Created by QMP on 2018/9/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonInvestCaseTableViewCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView*)tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

NS_ASSUME_NONNULL_END
