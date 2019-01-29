//
//  AlbumListCell.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/10/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlbumListCell : UITableViewCell

@property(nonatomic,strong) GroupModel *groupM;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end

NS_ASSUME_NONNULL_END
