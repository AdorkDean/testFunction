//
//  JointInvestmentDetailViewController.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/11/30.
//  Copyright © 2016年 Molly. All rights reserved.
//  两个机构的合投 参投列表(项目)

#import <UIKit/UIKit.h>
#import "OrganizeCombineItem.h"

@interface JointInvestmentDetailViewController : BaseViewController

@property (nonatomic,strong) OrganizeCombineItem *model1;
@property (nonatomic,strong) OrganizeCombineItem *model2;

@property (nonatomic,strong) NSString *action;

@end
