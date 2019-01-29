//
//  CardListCell.h
//  CommonLibrary
//
//  Created by QMP on 2018/11/19.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardItem.h"
#import "FriendModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface CardListCell : UITableViewCell
@property(nonatomic,strong) FriendModel *friendM;
@property(nonatomic,strong) CardItem *cardItem;
@property (nonatomic, assign) CardStyleFrom area;


+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end

NS_ASSUME_NONNULL_END
