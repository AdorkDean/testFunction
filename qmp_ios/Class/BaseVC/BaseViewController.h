//
//  BaseViewController.h
//  qmp_ios
//
//  Created by QMP on 2017/8/24.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJRefresh.h>

#import "HomeInfoTableViewCell.h"
#import "ShareTo.h"


#define DetailCommonWidth  (SCREENW - 32)
#define DetailBgImageHeight (kScreenTopHeight + 500)
@interface BaseViewController : UIViewController


/**
 列表 页面有关tableview和listdata以及header和footer
 */
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,assign) NSUInteger numPerPage;
@property(nonatomic,assign) NSUInteger currentPage;

//公共变量
@property(nonatomic,strong) ShareTo *shareTool;

//加载样式统一
@property(nonatomic,strong) MJRefreshAutoNormalFooter *mjFooter;
@property(nonatomic,strong) MJRefreshGifHeader *mjHeader;

//接口请求成功无数据返回情况 显示背景
- (void)showNoDataViewWithTitle:(NSString*)title;
- (void)showNoDataView;
- (void)hideNoDataView;

//上拉加载
- (void)pullUp;

//下拉刷新
- (void)pullDown;

//请求数据,子类必须实现
- (BOOL)requestData;

//传入本次请求的数组，刷新footer，
- (void)refreshFooter:(NSArray*)arr;

//网络异常 背景图
- (void)showNetFailedView;
- (void)hideNetFailedView;


//加载 动画hud
- (void)showHUD;
- (void)showHUDAtTop:(CGFloat)top;
- (void)hideHUD;

- (void)hideNavigationBarLine;
- (void)showNavigationBarLine;


//无数据 cell
- (HomeInfoTableViewCell*)nodataCellWithInfo:(NSString*)title subInfo:(NSString*)subTitle tableView:(UITableView*)tableview;
- (HomeInfoTableViewCell*)nodataCellWithInfo:(id)title tableView:(UITableView*)tableview;

/**
 对无数据 Cell 进行选中点击，直接return，禁止向下执行

 @param tb uitableview
 @param indexPath 保留参数
 @return 是否无数据Cell
 */
- (BOOL)noDataIsAllowSelectedTbVw:(UITableView *)tb withIndexPaht:(NSIndexPath *)indexPath;
@end
