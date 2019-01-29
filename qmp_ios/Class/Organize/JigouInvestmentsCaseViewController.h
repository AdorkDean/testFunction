//
//  JigouInvestmentsCaseViewController.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/11/26.
//  Copyright © 2016年 Molly. All rights reserved.
//  机构案例 （FA案例、投资案例)

#import <UIKit/UIKit.h>
#import "OrganizeItem.h"

@interface JigouInvestmentsCaseViewController : BaseViewController

@property (nonatomic, strong) NSMutableArray *selectedMArr;
@property (strong, nonatomic) NSMutableArray *selectedLunciMArr;
@property (strong, nonatomic) NSMutableArray *selectedTimeMArr;

@property (nonatomic,strong) NSDictionary * parametersDic;

@property (strong, nonatomic) OrganizeItem *organizeItem;
@property (strong, nonatomic) NSString *action;
@end
