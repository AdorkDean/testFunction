//
//  PersonRoleCell.h
//  CommonLibrary
//
//  Created by QMP on 2019/1/7.
//  Copyright © 2019 WSS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonRoleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PersonRoleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *roleLab;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;


@property (nonatomic, strong) PersonRoleModel *roleModel;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end

NS_ASSUME_NONNULL_END
