//
//  InvestorsListController.h
//  qmp_ios
//
//  Created by QMP on 2017/12/27.
//  Copyright © 2017年 Molly. All rights reserved.
//极速找人

#import "BaseViewController.h"

@interface InvestorsListController : BaseViewController

@property (assign, nonatomic) BOOL isRenzheng;

@property (strong, nonatomic) UISearchBar *mySearchBar;

- (void)cancleSearch;

- (void)disAppear;  //左右切换

- (void)beginSearch:(NSString*)text;

@end
