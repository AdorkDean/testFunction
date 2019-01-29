//
//  AlbumsListCell.h
//  qmp_ios
//
//  Created by QMP on 2017/10/25.
//  Copyright © 2017年 Molly. All rights reserved.
//首页数据 专辑cell   我的专辑管理cell

#import <UIKit/UIKit.h>
#import "GroupModel.h"

@interface AlbumsListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *topStaL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLeading;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (copy, nonatomic) NSString *keyword;
@property(nonatomic,strong) GroupModel *groupModel;
@end
