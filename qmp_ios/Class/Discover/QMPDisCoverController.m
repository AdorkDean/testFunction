//
//  QMPDisCoverController.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/25.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "QMPDisCoverController.h"
#import "SettingTableViewCell.h"
#import "HomeNavigationBar.h"
#import "QMPHomeFollowViewController.h"

@interface QMPDisCoverController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *tableConfigDatas;
@property (nonatomic, strong) HomeNavigationBar *navSearchBar;

@end

@implementation QMPDisCoverController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navSearchBar refreshMsdCount];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    
}



- (void)setupViews {
    
    [self.view addSubview:self.navSearchBar];
    
    CGRect rect = CGRectMake(0, kScreenTopHeight, SCREENW, SCREENH-kScreenBottomHeight-kScreenTopHeight);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
    
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
}


#pragma mark ----Event--
- (void)searchBtnClick{
    [[AppPageSkipTool shared] appPageSkipToMainSearch];
}

/**优质项目*/
- (void)enterProduct{
    
}
/**信息订阅*/
- (void)enterSubscibe{
    QMPHomeFollowViewController *homeFollowVC = [[QMPHomeFollowViewController alloc]init];
    [self.navigationController pushViewController:homeFollowVC animated:YES];
    
}
/**热招职位*/
- (void)enterZhaopin{
    
}
/**赛道趋势*/
- (void)enterTracktrend{
    
}
/**优质机构*/
- (void)enterAgency{
    
}
/**热搜榜单*/
- (void)enterHotBangdan{
    
}
/**人脉探索*/
- (void)enterChapter{
    
}
/**优质FA*/
- (void)enterFa{
    
}

#pragma mark ---- UITableView--
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableConfigDatas.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rows = self.tableConfigDatas[section];
    return rows.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingTableViewCell *cell = [SettingTableViewCell cellWithTableView:tableView];
    
    NSArray *rows = self.tableConfigDatas[indexPath.section];
    NSDictionary *rowDict = rows[indexPath.row];
    cell.lineView.hidden = (indexPath.row+1 == rows.count);
    [cell.leftImageV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView).offset(16);
        make.width.equalTo(@(30));
        make.height.equalTo(@(30));
        make.centerY.equalTo(cell.contentView);
    }];
    
    [cell.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView).offset(62);
        make.top.equalTo(cell.contentView).offset(0);
        make.bottom.equalTo(cell.contentView).offset(0);
        make.width.greaterThanOrEqualTo(@(30));
    }];
    [cell.titleLab labelWithFontSize:17 textColor:H3COLOR];
    cell.redPointView.hidden = YES;
    cell.keyRedView.hidden = YES;
    
    cell.titleLab.text = rowDict[@"title"];
    cell.leftImageV.image = [BundleTool imageNamed:rowDict[@"icon"]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 10)];
    v.backgroundColor = TABLEVIEW_COLOR;
    return v;
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    NSArray *rows = self.tableConfigDatas[indexPath.section];
    NSDictionary *rowDict = rows[indexPath.row];
    
    SEL selector = NSSelectorFromString(rowDict[@"action"]);
    ((void (*)(id, SEL))[self methodForSelector:selector])(self, selector);
}


#pragma mark --懒加载--
- (NSArray *)tableConfigDatas {
    if (!_tableConfigDatas) {
        _tableConfigDatas = @[
                              @[
                                  @{@"title":@"项目订阅", @"icon":@"discover_pro", @"action":@"enterProduct", @"extra":@"..."},
                                  @{@"title":@"事件订阅", @"icon":@"discover_things", @"action":@"enterProduct", @"extra":@"..."},
                                  @{@"title":@"信息订阅", @"icon":@"discover_subscibe", @"action":@"enterSubscibe", @"extra":@"..."},
                                  @{@"title":@"热招职位", @"icon":@"discover_zhaopin", @"action":@"enterZhaopin", @"extra":@"..."},
//                                  @{@"title":@"赛道趋势",@"icon":@"discover_track",@"action":@"enterTracktrend",@"extra":@"..."},
//                                  @{@"title":@"优质机构", @"icon":@"discover_agency", @"action":@"enterAgency", @"extra":@"..."},
//                                  @{@"title":@"热搜榜单", @"icon":@"discover_hotBang", @"action":@"enterHotBangdan", @"extra":@"..."},
                                  @{@"title":@"人脉探索", @"icon":@"discover_ chapter", @"action":@"enterChapter", @"extra":@"..."},
//                                  @{@"title":@"优质FA", @"icon":@"discover_fa", @"action":@"enterFa", @"extra":@"..."},

                                  ]
                              ];
    }
    return _tableConfigDatas;
}


- (HomeNavigationBar *)navSearchBar{
    
    if (!_navSearchBar) {
        _navSearchBar = [HomeNavigationBar navigationBarWithBarStyle:BarStyle_White];
        _navSearchBar.searchBtn.hidden = YES;
        
        //加上pageMenu
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, kStatusBarHeight, 50, 44)];
        if (@available(iOS 8.2, *)) {
            titleLab.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        } else {
            titleLab.font = [UIFont systemFontOfSize:17];
        }
        titleLab.textColor = H4COLOR;
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = @"发现";
        [_navSearchBar addSubview:titleLab];
        titleLab.centerX = SCREENW/2.0;
        
        UIButton *searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, kStatusBarHeight, 46, 44)];
        [searchBtn setImage:[BundleTool imageNamed:@"community_search"] forState:UIControlStateNormal];
        [searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_navSearchBar addSubview:searchBtn];
        
    }
    return _navSearchBar;
}


@end
