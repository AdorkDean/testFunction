//
//  JointInvestmentViewController.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/11/30.
//  Copyright © 2016年 Molly. All rights reserved.
//  合投机构列表

#import <UIKit/UIKit.h>
#import "OrganizeCombineItem.h"

typedef NS_ENUM(NSInteger,InvestType){
    InvestType_Together = 1, //合投
    InvestType_Join   //参投
};
@interface JointInvestmentListController : BaseViewController

@property (nonatomic,strong)NSDictionary *urlDict;
@property(nonatomic,assign) InvestType investType;
@property (nonatomic,strong) OrganizeCombineItem *model;

@end
