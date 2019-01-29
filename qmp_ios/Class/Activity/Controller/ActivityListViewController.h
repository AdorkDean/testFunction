//
//  ActivityListViewController.h
//  qmp_ios
//
//  Created by QMP on 2018/7/4.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"


@interface ActivityListViewController : BaseViewController
@property (nonatomic, assign) ActivityListViewControllerType type;

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *ticket;
@property (nonatomic, strong) id model;
@property (nonatomic, copy) void(^activityValueChangeBlock)(void);
@end
