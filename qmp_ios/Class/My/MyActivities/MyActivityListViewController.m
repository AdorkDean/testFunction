//
//  MyActivityListViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/7/11.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MyActivityListViewController.h"
#import "ActivityModel.h"
#import "ActivityDetailViewController.h"
#import "QMPActivityCell.h"
#import "QMPActivityCellModel.h"
#import "QMPActivityCellManager.h"

#import "NoteEditController.h"

@interface MyActivityListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<QMPActivityCellModel *> *cellModels;
@property (nonatomic, strong) QMPActivityCellManager *cellManager;

@end

@implementation MyActivityListViewController
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.cellManager removeMenuView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
    
    [self showHUD];
    if (self.type == MyActivityListViewControllerTypeFavor) {
        self.title = @"我的收藏";
        [self loadData2];
    } else if (self.type == MyActivityListViewControllerTypeNote) {
        self.title = @"我的笔记";
        [self loadNoteData];
        
        [self setupNavItem];
    } else if(self.type == MyActivityListViewControllerTypePublic){ //我的发布
        [self loadData];
    }else if(self.type == MyActivityListViewControllerTypeLike){ //我的点赞
        [self loadLikeData];
    }
    
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
- (void)refreshData {
    [self.tableView.mj_header beginRefreshing];
}
- (void)noteBtnClick {
    NoteEditController *vc = [[NoteEditController alloc] init];
    __weak typeof(self) weakSelf = self;
    vc.publishFinish = ^{
        weakSelf.currentPage = 1;
        [weakSelf loadNoteData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)setupNavItem {
    UIButton *noteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 53, 53)];
    [noteBtn setImage:[BundleTool imageNamed:@"me_activityEdit"] forState:UIControlStateNormal];
    [noteBtn addTarget:self action:@selector(noteBtnClick) forControlEvents:UIControlEventTouchUpInside];
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
- (void)setupViews {
    CGRect rect = CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
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
- (BOOL)requestData {
    if (![super requestData]) {
        return NO;
    }
    if (self.type == MyActivityListViewControllerTypeFavor) {
        [self loadData2];
    } else if (self.type == MyActivityListViewControllerTypeNote) {
        [self loadNoteData];
    } else if (self.type == MyActivityListViewControllerTypePublic){
        [self loadData];
    }else if (self.type == MyActivityListViewControllerTypeLike){
        [self loadLikeData];
    }
    
    return YES;
}

- (void)loadData2 {
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    
    if (self.type == MyActivityListViewControllerTypeFavor) {
        [paramDict setValue:@"collect" forKey:@"flag"];
    } 
    
    [paramDict setValue:@(self.currentPage) forKey:@"page"];
    [paramDict setValue:@(self.numPerPage) forKey:@"num"];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/activityOperatedList" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSArray *arr = resultData[@"list"];
            NSMutableArray *mArr = [NSMutableArray array];
            for (NSDictionary *dict in arr) {
                ActivityModel *model = [ActivityModel activityModelWithDict:dict];
                QMPActivityCellModel *cellModel = [[QMPActivityCellModel alloc] initWithActivity:model forCommunity:NO];
                [mArr addObject:cellModel];
            }
            if (self.currentPage == 1) {
                self.cellModels = mArr;
            } else {
                [self.cellModels addObjectsFromArray:mArr];
            }
            [self refreshFooter:mArr];
            [self.tableView reloadData];
        }
        [self hideHUD];
    }];
}
- (void)loadData {
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    
    [paramDict setValue:[WechatUserInfo shared].uuid?:@"" forKey:@"ticket"];
    [paramDict setValue:@"user" forKey:@"type"];
    [paramDict setValue:@(self.currentPage) forKey:@"page"];
    [paramDict setValue:@(self.numPerPage) forKey:@"num"];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/getDetailReleaseList" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSArray *arr = resultData[@"list"];
            NSMutableArray *mArr = [NSMutableArray array];
            for (NSDictionary *dict in arr) {
                ActivityModel *model = [ActivityModel activityModelWithDict:dict];
                model.showEdit = YES;
                QMPActivityCellModel *cellModel = [[QMPActivityCellModel alloc] initWithActivity:model forCommunity:NO];
                if (self.type == MyActivityListViewControllerTypePublic) {
                    cellModel.needDelete = YES;
                }
                [mArr addObject:cellModel];
            }
            if (self.currentPage == 1) {
                self.cellModels = mArr;
            } else {
                [self.cellModels addObjectsFromArray:mArr];
            }
            [self refreshFooter:mArr];
            [self.tableView reloadData];
        }
        [self hideHUD];
        
    }];
}

- (void)loadLikeData{
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    
    [paramDict setValue:[WechatUserInfo shared].uuid?:@"" forKey:@"ticket"];
    [paramDict setValue:@(self.currentPage) forKey:@"page"];
    [paramDict setValue:@(self.numPerPage) forKey:@"num"];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Activity/myLikeList" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSArray *arr = resultData[@"list"];
            NSMutableArray *mArr = [NSMutableArray array];
            for (NSDictionary *dict in arr) {
                ActivityModel *model = [ActivityModel activityModelWithDict:dict];
                QMPActivityCellModel *cellModel = [[QMPActivityCellModel alloc] initWithActivity:model forCommunity:NO];
                [mArr addObject:cellModel];
            }
            if (self.currentPage == 1) {
                self.cellModels = mArr;
            } else {
                [self.cellModels addObjectsFromArray:mArr];
            }
            [self refreshFooter:mArr];
            [self.tableView reloadData];
        }
        [self hideHUD];
        
    }];
}

- (void)loadNoteData {
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    
    [paramDict setValue:@"1" forKey:@"type"];
    
    [paramDict setValue:@"3" forKey:@"anonymous_flag"];
    
    [paramDict setValue:[WechatUserInfo shared].unionid?:@"" forKey:@"user_unionid"];
    
    [paramDict setValue:@(self.currentPage) forKey:@"page"];
    [paramDict setValue:@(self.numPerPage) forKey:@"num"];
    if (self.tableView.mj_header.isRefreshing) {
        [paramDict setValue:@"1" forKey:@"debug"];
    }
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"dynamic/showDynamicNew" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSArray *arr = resultData[@"list"];
            NSMutableArray *mArr = [NSMutableArray array];
            for (NSDictionary *dict in arr) {
                ActivityModel *model = [ActivityModel detialVcModelWithDict:dict];
                model.note = YES;
                QMPActivityCellModel *cellModel = [[QMPActivityCellModel alloc] initWithActivity:model forCommunity:NO];
                [mArr addObject:cellModel];
            }
            if (self.currentPage == 1) {
                self.cellModels = mArr;
            } else {
                [self.cellModels addObjectsFromArray:mArr];
            }
            [self refreshFooter:mArr];
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
    if (self.cellModels.count == 0) {
        return 1;
    }
    return self.cellModels.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellModels.count == 0) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
    
    QMPActivityCell *cell = [QMPActivityCell activityCellWithTableView:tableView];
    if (self.type == MyActivityListViewControllerTypeNote) {
        cell.noteCellModel = self.cellModels[indexPath.row];
        cell.delegate = self.cellManager;

    }else{
        cell.cellModel = self.cellModels[indexPath.row];
        cell.delegate = self.cellManager;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellModels.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    QMPActivityCellModel *cellM = self.cellModels[indexPath.row];
    CGFloat height = self.cellModels[indexPath.row].cellHeight;
    if (cellM.activity.note) {
        return height - 25;
    }
    return height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellModels.count == 0) {
        return;
    }
    if (self.type == MyActivityListViewControllerTypeNote) {
        return;
    }
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    QMPActivityCellModel *cellModel = self.cellModels[indexPath.row];
    ActivityModel *model = cellModel.activity;
    ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] init];
    vc.fromMyActivityList = (self.type ==  MyActivityListViewControllerTypePublic);
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
        for (QMPActivityCellModel *cellVM in weakSelf.cellModels) {
            if ([cellVM.activity.headerRelate.ticket isEqualToString:activityM.headerRelate.ticket]) {
                cellVM.activity.headerRelate.isFollowed = activityM.headerRelate.isFollowed;
            }
        }
        [weakSelf.tableView reloadData];
    };
    vc.activityDidDeleted = ^{
        [weakSelf.cellModels removeObjectAtIndex:indexPath.row];
        [weakSelf.tableView reloadData];
    };
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
