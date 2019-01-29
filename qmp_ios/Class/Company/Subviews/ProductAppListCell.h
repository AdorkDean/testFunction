//
//  ProductAppListCell.h
//  qmp_ios
//
//  Created by QMP on 2018/9/19.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProductAppListCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *appInfo;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end

NS_ASSUME_NONNULL_END
