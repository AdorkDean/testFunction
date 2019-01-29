//
//  ProductContactsController.h
//  qmp_ios
//
//  Created by QMP on 2018/5/3.
//  Copyright © 2018年 Molly. All rights reserved.
// 委托联系 

#import "BaseViewController.h"

@interface ProductContactsController : BaseViewController
@property (nonatomic,strong) UISearchBar *searchBar;
- (void)beginSearch:(NSString*)keyword; //项目详情页 进入 直接搜索项目

//删除名片
- (void)deleteBtnClick;

//导入到通讯录
- (void)leadBtnClick;
@end
