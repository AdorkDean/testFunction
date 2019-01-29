//
//  ActivityDetailViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/6/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "ActivityModel.h"
#import "ActivityCommentModel.h"
#import "ActivityCommentViewCell.h"
#import "QMPActivityCellModel.h"
#import "QMPActivityCell.h"
#import "QMPCommunityActivityCell.h"
#import "QMPActivityCellManager.h"
#import "QMPActivityActionView.h"
#import "QMPActivityDetialBarView.h"
#import "MainNavViewController.h"
#import "ClaimCell.h"


@interface ActivityDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<ActivityCommentModel *> *commentsData;

@property (nonatomic, strong) QMPActivityDetialBarView *barView;

@property (nonatomic, strong) QMPActivityCellModel *cellModel;

@property (nonatomic, strong) QMPActivityCellManager *cellManager;

@end

@implementation ActivityDetailViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.navigationController isKindOfClass:[MainNavViewController class]]) {
        MainNavViewController *vc = (MainNavViewController *)self.navigationController;
        vc.grayLine.hidden = YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController isKindOfClass:[MainNavViewController class]]) {
        MainNavViewController *vc = (MainNavViewController *)self.navigationController;
        vc.grayLine.hidden = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [QMPEvent event:@"activity_enerdetail"];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"动态";
    [self setupViews];
    
    [self showHUD];
    [self loadActivityDetailData];
    [self loadActivityCommentsData];
    



//    self.bottomView.activityValueChanged = ^{
//
//    };
    __weak typeof(self) weakSelf = self;
    self.barView.activityCommentPost = ^(ActivityCommentModel *model) {
        [weakSelf activityPostComment:model];
    };
    self.barView.activityTicket = self.activityTicket;
    
    self.cellManager.activityDidChanged = ^{
        if (weakSelf.activityCountChanged) {
            weakSelf.activityCountChanged(weakSelf.cellModel.activity);
        }
    };
    self.cellManager.activityFocusChange = ^(ActivityModel *activityM) {
        if (weakSelf.activityFocusChange) {
            weakSelf.activityFocusChange(weakSelf.cellModel.activity);
        }
    };
    self.cellManager.activityDidDeleled = ^(NSIndexPath *indexPath) {
        if (weakSelf.activityDidDeleted) {
            weakSelf.activityDidDeleted();
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
//    if (self.autoShowCommentInput) {
//        [self.bottomView commentButtonClick];
//    }
    
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    negativeSpacer.width = -50;
//    UIButton * moreBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
//    [moreBtn setImage:[BundleTool imageNamed:@"activity_detail_more"] forState:UIControlStateNormal];
//    [moreBtn addTarget:self action:@selector(moreOptions) forControlEvents:UIControlEventTouchUpInside];
//    moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 6, 0, -6);
//    UIBarButtonItem * moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreBtn];
//    self.navigationItem.rightBarButtonItems = @[moreItem, negativeSpacer];
}
- (void)moreOptions {
//    ActivityModel *activity = self.cellModel.activity;
//    QMPActivityActionView *view = [[QMPActivityActionView alloc] initWithActivity:activity];
//    [view show];
//
//    __weak typeof(self) weakSelf = self;
//    view.activityActionItemTap = ^(NSString *item) {
//        [weakSelf.cellManager doActionWithItem:item activity:activity];
//    };
}
- (void)setupViews {
    CGRect rect = CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight-45);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    
    self.tableView.mj_header = self.mjHeader;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
    
    [self.view addSubview:self.barView];
//    self.bottomView.activityID = self.activityID;
//    self.bottomView.activityTicket = self.activityTicket;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    QMPLog(@"%s", __func__);
}
- (void)activityPostComment:(ActivityCommentModel *)model {
    self.cellModel.activity.commentCount += 1;
    [self.commentsData insertObject:model atIndex:0];
    [self.tableView reloadData];
    
    if (self.activityCountChanged) {
        self.activityCountChanged(self.cellModel.activity);
    }
    [QMPEvent event:@"activity_action_click" label:@"动态评论发布"];
}

- (void)pullDown{
    [super pullDown];
    [self loadActivityCommentsData];
}
- (void)pullUp {
    [super pullUp];
    
    [self loadActivityCommentsData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.cellModel) {
        return 0;
    }
    if (section == 0) {
        return 1;
    }
    if (self.community && ![self canSeeComment]) { //认证才能看评论
        return 1;
    }
    return MAX(1, self.commentsData.count);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.community) {
            QMPCommunityActivityCell *cell = [QMPCommunityActivityCell activityCellWithTableView:tableView];
            cell.cellModel = self.cellModel;
            cell.delegate = self.cellManager;
            return cell;
        } else {
            QMPActivityCell *cell = [QMPActivityCell activityCellWithTableView:tableView];
            cell.cellModel = self.cellModel;
            cell.delegate = self.cellManager;
            return cell;
        }
    }
    if (self.community && ![self canSeeComment]) { //认证才能看评论
        ClaimCell *cell = [ClaimCell cellWithTableView:tableView tipInfo:@"认证投资人和FA才能查看话题评论" showbgImg:NO];
        return cell;
    }
    
    if (self.commentsData.count == 0) {
        ActivityNoCommentViewCell *cell = [ActivityNoCommentViewCell cellWithTableView:tableView];
        return cell;
    }
    
    ActivityCommentViewCell *cell = [ActivityCommentViewCell cellWithTableView:tableView];
    cell.comment = self.commentsData[indexPath.row];
    cell.activityID = self.activityID;
    cell.lineView.hidden = indexPath.row+1 == self.commentsData.count;
    
    
    __weak typeof(self) weakSelf = self;
    cell.didDeletedComment = ^{ //删除
        weakSelf.cellModel.activity.commentCount -= 1;
        [weakSelf.commentsData removeObjectAtIndex:indexPath.row];
        [weakSelf.tableView reloadData];
//        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];

        if (weakSelf.activityCountChanged) {
            weakSelf.activityCountChanged(weakSelf.cellModel.activity);
        }
    };
    cell.didLikeComment = ^(BOOL likeStatus) {
        
    };
    
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.cellModel.cellHeight;
    }
    
    if (self.community && ![self canSeeComment]) { //认证才能看评论
        return 140+15;
    }
    if (self.commentsData.count == 0) {
        return ActivityNoCommentViewCellHeight;
    }
    return self.commentsData[indexPath.row].cellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 42;
    }
    return 0.0001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, SCREENW, 42);
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(13, 20, 120, 16);
        label.text = @"全部评论";
        label.textColor = NV_TITLE_COLOR;
        if (@available(iOS 8.2, *)) {
            label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        }else{
            label.font = [UIFont systemFontOfSize:16];
        }
        [view addSubview:label];
        
//        UIImageView *line = [[UIImageView alloc] init];
//        line.frame = CGRectMake(0, 44.5, SCREENW, 0.5);
//        line.backgroundColor = TABLEVIEW_COLOR;
//        [view addSubview:line];
        
        return view;
    }
    return [[UIView alloc] init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    if (section == 0) {
//        return 10;
//    }
    return 0.0001;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}



- (void)loadActivityDetailData {
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:self.activityID?:@"" forKey:@"id"];
    [paramDict setValue:self.activityTicket?:@"" forKey:@"ticket"];

    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/activityDetail" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        ActivityModel *model = [ActivityModel detailVCModelWithDict:resultData fixRealte:self.relateModel];
        model.showEdit = self.fromMyActivityList;
        self.cellModel = [[QMPActivityCellModel alloc] initWithActivity:model forCommunity:self.community detail:YES];
        self.cellModel.detail = YES;
        self.cellModel.needDelete = self.fromMyActivityList;
        [self.tableView reloadData];
        
    }];
}

- (void)loadActivityCommentsData {
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:self.activityTicket?:@"" forKey:@"ticket"];
    [paramDict setValue:@(self.currentPage) forKey:@"page"];
    [paramDict setValue:@(self.numPerPage) forKey:@"num"];
    
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/activityCommentList" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            
            
            NSMutableArray *tmpArr = [NSMutableArray array];
            for (NSDictionary *dict in resultData[@"list"]) {
                ActivityCommentModel *model = [ActivityCommentModel activityDetail_commentModelWithResponse:dict];
                [tmpArr addObject:model];
            }
            if (self.currentPage == 1) {
                self.commentsData = tmpArr;
            } else {
                [self.commentsData addObjectsFromArray:tmpArr];
            }
            
            [self refreshFooter:tmpArr];
            [self.tableView reloadData];

        }
    }];
}
- (NSMutableArray *)commentsData {
    if (!_commentsData) {
        _commentsData = [NSMutableArray array];
    }
    return _commentsData;
}
- (QMPActivityDetialBarView *)barView {
    if (!_barView) {
        _barView = [[QMPActivityDetialBarView alloc] init];
        CGFloat h = 50;
        if (isiPhoneX) {
            h = 66;
        }
        _barView.frame = CGRectMake(0, SCREENH-h-kScreenTopHeight, SCREENW, h);
    }
    return _barView;
}
- (QMPActivityCellManager *)cellManager {
    if (!_cellManager) {
        _cellManager = [[QMPActivityCellManager alloc] init];
        _cellManager.tableView = self.tableView;
        _cellManager.controller = self;
    }
    return _cellManager;
}
- (BOOL)canSeeComment{
    if ([WechatUserInfo shared].claim_type.integerValue == 2 && ([[WechatUserInfo shared].person_role containsString:@"investor"] || [[WechatUserInfo shared].person_role containsString:@"FA"])) {
        return YES;
    }
    return NO;
}


@end
