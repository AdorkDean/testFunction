//
//  BPListController.h
//  qmp_ios
//
//  Created by QMP on 2017/11/7.
//  Copyright © 2017年 Molly. All rights reserved.
//我的BP 收到的BP

#import "BaseViewController.h"
#import <objc/runtime.h>

@class BPMgrController;
@interface BPListController : BaseViewController

@property (copy, nonatomic) NSString *searchWord;
@property (strong, nonatomic) UISearchBar *mySearchBar;

@property(nonatomic,assign) BOOL isToMe;

@property (nonatomic, strong) NSMutableArray *selectedMArr;
@property (nonatomic, strong) NSMutableArray *selectedProvinceArr;
@property (nonatomic, strong) NSMutableArray *selectedFlagArr;

- (void)cancleSearch;

- (void)disAppear;  //左右切换

- (void)beginSearch:(NSString*)text;

@end
