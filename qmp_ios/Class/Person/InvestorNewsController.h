//
//  InvestorNewsController.h
//  qmp_ios
//
//  Created by QMP on 2017/11/27.
//  Copyright © 2017年 Molly. All rights reserved.
//人物新闻

#import "BaseViewController.h"
#import "PersonModel.h"

@interface InvestorNewsController : BaseViewController

@property(nonatomic,strong)PersonModel *person;

@property(nonatomic,strong)NSMutableArray *listArr;

@end
