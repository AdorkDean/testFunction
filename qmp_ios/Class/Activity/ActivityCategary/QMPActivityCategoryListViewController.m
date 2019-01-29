//
//  QMPActivityCategoryListViewController.m
//  CommonLibrary
//
//  Created by QMP on 2018/12/4.
//  Copyright © 2018 WSS. All rights reserved.
//

#import "QMPActivityCategoryListViewController.h"
#import "QMPActivityCellModel.h"
#import "ActivityModel.h"
#import "QMPActivityCell.h"
#import "ActivityDetailViewController.h"
#import "QMPActivityCellManager.h"
#define TICK   NSDate *startTime = [NSDate date];
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow]);
@interface QMPActivityCategoryListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *activityData;
@property (nonatomic, strong) QMPActivityCellManager *cellManager;
@property (nonatomic, strong) NSDate *leftTime;

@property (nonatomic, assign) BOOL notFirst;
@end

@implementation QMPActivityCategoryListViewController

- (instancetype)initWithTicket:(NSString *)ticket {
    self = [super init];
    if (self) {
        self.ticket = ticket;
    }
    return self;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.leftTime = [NSDate date];
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
    [self setupViews];
    [self showHUDAtTop:10];
    [self requestData];
    
    __weak typeof(self) weakSelf = self;
    self.cellManager.activityDidDeleled = ^(NSIndexPath *indexPath) {
        [weakSelf.activityData removeObjectAtIndex:indexPath.row];
        [weakSelf.tableView reloadData];
    };
    self.cellManager.activityFocusChange = ^(ActivityModel *activityM) {
        for (QMPActivityCellModel *cellVM in weakSelf.activityData) {
            if ([cellVM.activity.headerRelate.ticket isEqualToString:activityM.headerRelate.ticket]) {
                cellVM.activity.headerRelate.isFollowed = activityM.headerRelate.isFollowed;
            }
        }
        [weakSelf.tableView reloadData];
    };
}


- (void)setupViews {
    CGRect rect = CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight-kScreenBottomHeight-42);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
}
- (BOOL)requestData {
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:@(self.currentPage) forKey:@"page"];
    [paramDict setValue:@(self.numPerPage) forKey:@"num"];
    [paramDict setValue:@"theme" forKey:@"type"];
    [paramDict setValue:self.ticket forKey:@"ticket"];
    if (self.tableView.mj_header.isRefreshing) {
        [paramDict setValue:@"1" forKey:@"debug"];
    }
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/getDetailRelationList" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                TICK
                NSArray *arr = resultData[@"list"];
                NSMutableArray *mArr = [NSMutableArray array];
                for (NSDictionary *dict in arr) {
                    ActivityModel *model = [ActivityModel themeVcModelWithDict:dict];
                    QMPActivityCellModel *layout = [[QMPActivityCellModel alloc] initWithActivity:model forCommunity:NO];
                    [mArr addObject:layout];
                }
                if (self.currentPage == 1) {
                    self.activityData = mArr;
                    if (self.numPerPage > mArr.count) {
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }
                } else {
                    [self.activityData addObjectsFromArray:mArr];
                    [self refreshFooter:mArr];
                }
                TOCK
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!self.notFirst) {
                        self.notFirst = YES;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self hideHUD];
                            [self.tableView reloadData];
                        });
                    } else {
                        [self.tableView reloadData];
                    }
                });
                
            });
            
        } else {
            [self hideHUD];
        }
        
        
    }];
    return YES;
}
#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activityData.count ? self.activityData.count : 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.activityData.count == 0) {
        return [self nodataCellWithInfo:@"暂无动态" tableView:tableView];
    }
    QMPActivityCell *cell = [QMPActivityCell activityCellWithTableView:tableView];
    cell.cellModel = self.activityData[indexPath.row];
    cell.delegate = self.cellManager;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.activityData.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    QMPActivityCellModel *cellModel = self.activityData[indexPath.row];
    return cellModel.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.activityData.count == 0) {
        return;
    }
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    QMPActivityCellModel *cellModel = self.activityData[indexPath.row];
    ActivityModel *model = cellModel.activity;
    ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] init];
    vc.activityID = model.ID;
    vc.activityTicket = model.ticket;
    if (model.headerRelate) {
        vc.relateModel = model.headerRelate;
    }

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
        for (QMPActivityCellModel *cellVM in weakSelf.activityData) {
            if ([cellVM.activity.headerRelate.ticket isEqualToString:activityM.headerRelate.ticket]) {
                cellVM.activity.headerRelate.isFollowed = activityM.headerRelate.isFollowed;
            }
        }
        [weakSelf.tableView reloadData];
    };
    vc.activityDidDeleted = ^{
        [weakSelf.activityData removeObjectAtIndex:indexPath.row];
        [weakSelf.tableView reloadData];
    };
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.cellManager removeMenuView];
}
- (NSMutableArray *)activityData {
    if (!_activityData) {
        _activityData = [NSMutableArray array];
    }
    return _activityData;
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
