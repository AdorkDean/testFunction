//
//  LeadCardCell.h
//  qmp_ios
//
//  Created by QMP on 2018/4/11.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardItem.h"
#import "FriendModel.h"

@interface LeadCardCell : UITableViewCell
@property(nonatomic,strong)UIView *line;

@property(nonatomic,strong)UIButton *selectBtn;

@property(nonatomic,strong) CardItem *cardItem;

- (void)refreshContactInfo:(CardItem*)cardItem;
- (void)refreshFriendInfo:(FriendModel*)friendM;

@end
