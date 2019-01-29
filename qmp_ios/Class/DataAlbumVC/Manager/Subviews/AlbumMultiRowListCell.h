//
//  AlbumMultiRowListCell.h
//  qmp_ios
//
//  Created by QMP on 2018/4/20.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupModel.h"

/**
 榜单
 */
@interface AlbumMultiRowListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
//@property (weak, nonatomic) IBOutlet UILabel *topStaL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLeading;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (copy, nonatomic) NSString *keyword;
@property(nonatomic,strong) GroupModel *groupModel;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end
