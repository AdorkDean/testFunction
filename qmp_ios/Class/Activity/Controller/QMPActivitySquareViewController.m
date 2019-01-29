//
//  QMPActivitySquareViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/11/28.
//  Copyright © 2018 WSS. All rights reserved.
//

#import "QMPActivitySquareViewController.h"
#import "QMPActivityCell.h"
#import "ActivityModel.h"
#import "QMPActivityCellManager.h"
#import "ActivityDetailViewController.h"
#import "QMPActivityCellModel.h"

@interface QMPActivitySquareViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) QMPActivityCellManager *cellManager;
@property (nonatomic, strong) NSMutableArray<QMPActivityCellModel *> *cellModels;
@property (nonatomic, strong) NSDate *leftTime;
@end

@implementation QMPActivitySquareViewController
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.leftTime = [NSDate date];
    [self.cellManager removeMenuView];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.leftTime == nil) {
        return;
    }
    if (-self.leftTime.timeIntervalSinceNow >= 600) {
        [self.tableView.mj_header beginRefreshing];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.numPerPage = 1;
    [self setupViews];
    [self showHUD];
    [self requestData];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reRequestData) name:@"UserPostActivitySuccess" object:nil];
    
    __weak typeof(self) weakSelf = self;
    self.cellManager.activityDidDeleled = ^(NSIndexPath *indexPath) {
        [weakSelf.cellModels removeObjectAtIndex:indexPath.row];
        [weakSelf.tableView reloadData];
    };
    self.cellManager.activityFocusChange = ^(ActivityModel *activityM) {
        for (QMPActivityCellModel *cellVM in weakSelf.cellModels) {
            if ([cellVM.activity.headerRelate.ticket isEqualToString:activityM.headerRelate.ticket]) {
                cellVM.activity.headerRelate.isFollowed = activityM.headerRelate.isFollowed;
            }
        }
        [weakSelf.tableView reloadData];
    };
}
- (void)reRequestData {
    [self.tableView.mj_header beginRefreshing];
}
- (void)setupViews {
    
    CGRect rect = CGRectMake(0, 0, SCREENW, SCREENH-kScreenBottomHeight-kScreenTopHeight);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
    
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}
- (void)pullDown {
    [super pullDown];
    
    [QMPEvent event:@"tab_activity_pullrefresh"];
}
- (BOOL)requestData {
    if (![super requestData]) {
        return NO;
    }
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
//    [paramDict setValue:@(self.numPerPage) forKey:@"num"];
    [paramDict setValue:@(self.currentPage) forKey:@"page"];
    if (self.tableView.mj_header.isRefreshing) {
        [paramDict setValue:@(1) forKey:@"debug"];
    }
    [paramDict setValue:@(self.anonymous) forKey:@"type"];
    if (self.pushActivityID) { //请求后置空
//        [paramDict setValue:self.pushActivityID forKey:@"type"];
    }
    
    NSString *url = @"activity/activitySquare";
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:url HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSArray *arr = resultData[@"list"];
            NSMutableArray *mArr = [NSMutableArray array];
            for (NSDictionary *dict in arr) {
                ActivityModel *model = [ActivityModel squareVCModelWithDict:dict anonymous:self.anonymous];
                model.homeFollow = YES;
                QMPActivityCellModel *cellModel = [[QMPActivityCellModel alloc] initWithActivity:model forCommunity:NO];
                [mArr addObject:cellModel];
            }
            if (self.currentPage == 1) {
                self.cellModels = mArr;
                if (mArr.count < self.numPerPage) {
                    [self.tableView.mj_footer setState:MJRefreshStateNoMoreData];
                }
            } else {
                [self.cellModels addObjectsFromArray:mArr];
                [self refreshFooter:mArr];
            }
            [self.tableView reloadData];
        }
    }];
    return YES;
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellModels.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QMPActivityCell *cell = [QMPActivityCell activityCellWithTableView:tableView];
    cell.cellModel = self.cellModels[indexPath.row];
    cell.delegate = self.cellManager;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellModels[indexPath.row].cellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    QMPActivityCellModel *cellModel = self.cellModels[indexPath.row];
    ActivityModel *model = cellModel.activity;
    ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] init];
    vc.activityID = model.ID;
    vc.activityTicket = model.ticket;
    if (model.headerRelate) {
        vc.relateModel = model.headerRelate;
    }
    [self.navigationController pushViewController:vc animated:YES];
    
    QMPActivityCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    vc.activityCountChanged = ^(ActivityModel *activity) {
        model.reported = activity.reported;
        model.collected = activity.collected;
        model.digged = activity.digged;
        model.diggCount = activity.diggCount;
        model.commentCount = activity.commentCount;
        [cell updateCountWithModel:activity];
    };
    
    __weak typeof(self) weakSelf = self;
    vc.activityFocusChange = ^(ActivityModel *activityM) {
        for (QMPActivityCellModel *cellVM in weakSelf.cellModels) {
            if ([cellVM.activity.headerRelate.ticket isEqualToString:activityM.headerRelate.ticket]) {
                cellVM.activity.headerRelate.isFollowed = activityM.headerRelate.isFollowed;
            }
        }
        [weakSelf.tableView reloadData];
    };
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.cellManager removeMenuView];
}

#pragma mark - Getter
- (NSMutableArray<QMPActivityCellModel *> *)cellModels {
    if (!_cellModels) {
        _cellModels = [NSMutableArray array];
    }
    return _cellModels;
}
- (QMPActivityCellManager *)cellManager {
    if (!_cellManager) {
        _cellManager = [QMPActivityCellManager manager];
        _cellManager.tableView = self.tableView;
        _cellManager.controller = self;
    }
    return _cellManager;
}
@end
