//
//  ActivityListViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/7/4.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ActivityListViewController.h"
#import "ActivityModel.h"
#import "ActivityDetailViewController.h"
#import "PostActivityViewController.h"

#import "QMPActivityCell.h"
#import "QMPActivityCellModel.h"
#import "QMPActivityCellManager.h"
@interface ActivityListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *paramDict;
@property (nonatomic, strong) NSMutableArray *activityData;
@property (nonatomic, strong) QMPActivityCellManager *cellManager;
@end

@implementation ActivityListViewController
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.cellManager removeMenuView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"全部动态";
    [self setupViews];
    
    if (self.type == ActivityListViewControllerTypeUser) {
        [self.paramDict setValue:@"user" forKey:@"type"];
        [self.paramDict setValue:self.ticket?:@"" forKey:@"ticket"];
        
    } else if (self.type == ActivityListViewControllerTypePerson) {
        [self.paramDict setValue:@"person" forKey:@"type"];
        [self.paramDict setValue:self.ticket?:@"" forKey:@"ticket"];

    } else if (self.type == ActivityListViewControllerTypeProduct) {
        [self.paramDict setValue:@"product" forKey:@"type"];
        [self.paramDict setValue:self.ticket?:@"" forKey:@"ticket"];
    } else if (self.type == ActivityListViewControllerTypeOrgnize) {
        [self.paramDict setValue:@"jigou" forKey:@"type"];
        [self.paramDict setValue:self.ticket?:@"" forKey:@"ticket"];
    }
    
    [self showHUD];
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
    CGRect rect = CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
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
    
    //    self.tableView.contentInset = UIEdgeInsetsMake(self.headerView.height, 0, 0, 0);
    //    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.headerView.height, 0, 0, 0);
    //    [self.view addSubview:self.headerView];

    if (self.type == ActivityListViewControllerTypeOrgnize || self.type == ActivityListViewControllerTypeProduct) {        
        UIButton *noteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 53, 53)];
        [noteBtn setImage:[BundleTool imageNamed:@"me_activityEdit"] forState:UIControlStateNormal];
        [noteBtn addTarget:self action:@selector(postDynamic) forControlEvents:UIControlEventTouchUpInside];
        //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:noteBtn];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = RIGHTNVSPACE;
        if (iOS11_OR_HIGHER) {
            
            noteBtn.width = 30;
            noteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:noteBtn];
            
            self.navigationItem.rightBarButtonItems = @[buttonItem];
        } else {
            
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:noteBtn];
            self.navigationItem.rightBarButtonItems = @[ negativeSpacer,buttonItem];
        }
        
    }
    
}
- (void)postDynamic{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    if (![PublicTool userisCliamed]) {
        return;
    }
    PostActivityViewController *vc = [[PostActivityViewController alloc] init];
    vc.postFrom = PostFrom_Detail;
    vc.model = self.model;
//    vc.postSuccessBlock = self.activityValueChangeBlock;
    __weak typeof(self) wkSf = self;
    vc.postSuccessBlock = ^{
        wkSf.currentPage = 1;
        [wkSf loadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
    
    __weak typeof(self) weakSelf = self;
    vc.postSuccessBlock = ^{
        if (weakSelf.activityValueChangeBlock) {
            weakSelf.activityValueChangeBlock();
        }
        [weakSelf.tableView.mj_header beginRefreshing];
    };
}

- (BOOL)requestData {
    if (![super requestData]) {
        return NO;
    }
    if (self.type == ActivityListViewControllerTypeUser) {
        [self loadData2];
    } else if (self.type == ActivityListViewControllerTypePerson) {
       [self loadData3];
    } else if (self.type == ActivityListViewControllerTypeProduct) {
        [self loadData];
    } else if (self.type == ActivityListViewControllerTypeOrgnize) {
        [self loadData];
    }
    
    
    return YES;
}
- (void)loadData {
    [self.paramDict setValue:@(self.currentPage) forKey:@"page"];
    [self.paramDict setValue:@(self.numPerPage) forKey:@"num"];
    if (self.tableView.mj_header.isRefreshing) {
        [self.paramDict setValue:@"1" forKey:@"debug"];
    }

    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/getDetailRelationList" HTTPBody:self.paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSArray *arr = resultData[@"list"];
            NSMutableArray *mArr = [NSMutableArray array];
            for (NSDictionary *dict in arr) {
                ActivityModel *model = [ActivityModel activityModelWithDict:dict forId:self.ticket];
                QMPActivityCellModel *viewModel = [[QMPActivityCellModel alloc] initWithActivity:model forCommunity:NO];
                [mArr addObject:viewModel];
            }
            if (self.currentPage == 1) {
                self.activityData = mArr;
            } else {
                [self.activityData addObjectsFromArray:mArr];
                [self refreshFooter:mArr];
            }
            
            [self.tableView reloadData];
        }
        [self hideHUD];
        
    }];
}
- (void)loadData2 {
    [self.paramDict setValue:@(self.currentPage) forKey:@"page"];
    [self.paramDict setValue:@(self.numPerPage) forKey:@"num"];
    if (self.tableView.mj_header.isRefreshing) {
        [self.paramDict setValue:@"1" forKey:@"debug"];
    }
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/getDetailReleaseList" HTTPBody:self.paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSArray *arr = resultData[@"list"];
            NSMutableArray *mArr = [NSMutableArray array];
            for (NSDictionary *dict in arr) {
                ActivityModel *model = [ActivityModel activityModelWithDict:dict];
                QMPActivityCellModel *viewModel = [[QMPActivityCellModel alloc] initWithActivity:model forCommunity:NO];
                [mArr addObject:viewModel];
            }
            if (self.currentPage == 1) {
                self.activityData = mArr;
            } else {
                [self.activityData addObjectsFromArray:mArr];
                [self refreshFooter:mArr];
            }
            
            [self.tableView reloadData];
        }
        [self hideHUD];
        
    }];
}
- (void)loadData3 {
    [self.paramDict setValue:@(self.currentPage) forKey:@"page"];
    [self.paramDict setValue:@(self.numPerPage) forKey:@"num"];
    if (self.tableView.mj_header.isRefreshing) {
        [self.paramDict setValue:@"1" forKey:@"debug"];
    }
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/getPersonReleaseList" HTTPBody:self.paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSArray *arr = resultData[@"list"];
            NSMutableArray *mArr = [NSMutableArray array];
            for (NSDictionary *dict in arr) {
                ActivityModel *model = [ActivityModel personVCactivityModelWithDict:dict ticket:self.ticket];
                QMPActivityCellModel *viewModel = [[QMPActivityCellModel alloc] initWithActivity:model forCommunity:NO];
                [mArr addObject:viewModel];
            }
            if (self.currentPage == 1) {
                self.activityData = mArr;
            } else {
                [self.activityData addObjectsFromArray:mArr];
                [self refreshFooter:mArr];
            }
            
            [self.tableView reloadData];
        }
        [self hideHUD];
        
    }];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.cellManager removeMenuView];
}
#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activityData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    QMPActivityCell *cell = [QMPActivityCell activityCellWithTableView:tableView];
    cell.cellModel = self.activityData[indexPath.row];
    cell.delegate = self.cellManager;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QMPActivityCellModel *viewModel = self.activityData[indexPath.row];
    return viewModel.cellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.000001;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    if (self.activityData.count == 0) {
        return;
    }
    QMPActivityCellModel *cellModel = self.activityData[indexPath.row];
    ActivityModel *model = cellModel.activity;
    ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] init];
    vc.activityID = model.ID;
    vc.activityTicket = model.ticket;
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
        for (QMPActivityCellModel *cellVM in weakSelf.activityData) {
            if ([cellVM.activity.headerRelate.ticket isEqualToString:activityM.headerRelate.ticket]) {
                cellVM.activity.headerRelate.isFollowed = activityM.headerRelate.isFollowed;
            }
        }
        [weakSelf.tableView reloadData];
    };

}

- (NSMutableDictionary *)paramDict {
    if (!_paramDict) {
        _paramDict = [NSMutableDictionary dictionary];
    }
    return _paramDict;
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
