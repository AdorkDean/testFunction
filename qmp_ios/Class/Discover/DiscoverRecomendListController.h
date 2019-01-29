//
//  DiscoverRecomendListController.h
//  qmp_ios
//
//  Created by QMP on 2018/8/14.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"


@interface DiscoverRecomendListController : BaseViewController
@property (copy, nonatomic) void(^refreshComplated)(void);

@property(nonatomic,assign) AttentType attentType;

@end
