//
//  CardListController.h
//  qmp_ios
//
//  Created by QMP on 2018/5/3.
//  Copyright © 2018年 Molly. All rights reserved.
//名片列表

#import "BaseViewController.h"

@interface CardListController : BaseViewController
@property (nonatomic,strong) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *tableData;
- (void)pressAddCardBtn;
//删除名片
- (void)deleteBtnClick;

//导入到通讯录
- (void)leadBtnClick;
@end
