//
//  JoinInvestController.h
//  CommonLibrary
//
//  Created by QMP on 2019/1/7.
//  Copyright © 2019 WSS. All rights reserved.
//合投参透

#import "BaseViewController.h"
#import "OrganizeItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface JoinInvestController : BaseViewController
@property(nonatomic,strong) OrganizeItem *organizeInfo;
@property(nonatomic,strong) NSDictionary *urlDic;

@end

NS_ASSUME_NONNULL_END
