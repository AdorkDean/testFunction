//
//  HomeBaseViewController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/11/7.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "HomeBaseViewController.h"

NSNotificationName const ChildHomeScrollViewDidScrollNSNotification = @"ChildScrollViewDidScrollNSNotification";
NSNotificationName const ChildHomeScrollViewRefreshStateNSNotification = @"ChildScrollViewRefreshStateNSNotification";

@interface HomeBaseViewController ()

@end

@implementation HomeBaseViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    BannerHeight = (NSInteger)ceil([UIScreen mainScreen].bounds.size.width*219.0/780.0);
    
    [self addView];
}


- (void)setHeaderHeight:(CGFloat)headerHeight{
    _headerHeight = headerHeight;
    
    if (self.tableView) {
        self.tableView.contentInset = UIEdgeInsetsMake((kStatusBarHeight+47+45+78+45), 0, 0, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake((kStatusBarHeight+47+45+78+45), 0, 0, 0);
        [self.tableView reloadData];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + 10)];
    }
}

- (void)refreshData {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [self.tableView.mj_header beginRefreshing];
}
- (void)addView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenBottomHeight) style:UITableViewStyleGrouped];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.layer.masksToBounds = NO;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.contentInset = UIEdgeInsetsMake((kStatusBarHeight+47+45+78+45), 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake((kStatusBarHeight+47+45+78+45), 0, 0, 0);

    [self.view addSubview:self.tableView];
    
    self.scrollView = self.tableView;
    self.tableView.mj_footer = nil;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    //footerView
//    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 70)];
//    footerView.backgroundColor = [UIColor whiteColor];
//    
//    UIButton *moreBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 10, 100, 30)];
//    moreBtn.layer.masksToBounds = YES;
//    moreBtn.layer.cornerRadius = 15;
//    moreBtn.layer.borderColor = BORDER_LINE_COLOR.CGColor;
//    moreBtn.layer.borderWidth = 0.5;
//    [moreBtn setTitle:@"浏览更多" forState:UIControlStateNormal];
//    [moreBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
//    moreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//    [moreBtn addTarget:self action:@selector(moreBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [footerView addSubview:moreBtn];
//    moreBtn.centerX = footerView.width/2.0;
//    moreBtn.centerY = footerView.height/2.0;
//    
//    self.tableView.tableFooterView = footerView;
}


- (void)moreBtnClick{
    
}

//- (void)pullDown {
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:ChildHomeScrollViewRefreshStateNSNotification object:nil userInfo:@{@"isRefreshing":@(YES)}];
//    
//}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetDifference = scrollView.contentOffset.y - self.lastContentOffset.y;
    // 滚动时发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:ChildHomeScrollViewDidScrollNSNotification object:nil userInfo:@{@"scrollingScrollViewOfHome":scrollView,@"offsetDifferenceofHome":@(offsetDifference)}];
    self.lastContentOffset = scrollView.contentOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell_1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行",indexPath.row];
    return cell;
}
@end
