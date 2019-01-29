//
//  ProductContactDetailVC.h
//  qmp_ios
//
//  Created by QMP on 2018/5/3.
//  Copyright © 2018年 Molly. All rights reserved.
//委托联系 和 通讯录详情

#import "BaseViewController.h"
#import "CardItem.h"
#import "FriendModel.h"


@interface ProductContactDetailVC : BaseViewController
@property(nonatomic,strong) FriendModel *friend1; //来自通讯录
@property(nonatomic,strong) CardItem *card;  //来自委托联系
@end
