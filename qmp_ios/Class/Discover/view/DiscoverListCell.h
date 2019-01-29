//
//  DiscoverListCell.h
//  qmp_ios
//
//  Created by QMP on 2018/8/27.
//  Copyright © 2018年 Molly. All rights reserved.
//发现 和 我的关注人物 主题在用

#import <UIKit/UIKit.h>
#import "MeTopItemModel.h"


@interface DiscoverListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *attentBtn;

@property(nonatomic,strong) UIColor *iconColor;
@property(nonatomic,strong) MeTopItemModel *attentionM;


+ (DiscoverListCell*)cellWithTableView:(UITableView*)tableView recommendType:(AttentType)recommendType dataDic:(NSDictionary*)dataDic;
//我的关注
+ (DiscoverListCell*)cellWithTableView:(UITableView*)tableView recommendType:(AttentType)recommendType attentionModel:(MeTopItemModel*)attentionM;

@end
