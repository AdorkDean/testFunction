//
//  QMPCommunityViewController.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/9.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "QMPCommunityListController.h"
#import "QMPActivityCell.h"
#import "ActivityModel.h"
#import "QMPActivityCellManager.h"
#import "ActivityDetailViewController.h"
#import "HomeNavigationBar.h"
#import "QMPActivityCellModel.h"
#import "QMPCommunityActivityCell.h"
#import "PostActivityViewController.h"
#import "CommunityClaimView.h"

@interface QMPCommunityListController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) QMPActivityCellManager *cellManager;
@property (nonatomic, strong) NSMutableArray<QMPActivityCellModel *> *cellModels;
@property (nonatomic, strong) NSDate *leftTime;

@end

@implementation QMPCommunityListController

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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullDown) name:@"UserPostActivitySuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullDown) name:NOTIFI_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullDown) name:NOTIFI_QUITLOGIN object:nil];

    __weak typeof(self) weakSelf = self;
    self.cellManager.activityDidDeleled = ^(NSIndexPath *indexPath) {
        [weakSelf.cellModels removeObjectAtIndex:indexPath.row];
        [weakSelf.tableView reloadData];
    };
}

- (void)postButtonClick {
    
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    if (self.communityType == CommunityType_Topic) { //话题讨论
        if (![PublicTool userisClaimInvestor]) {
            return;
        }
    }else{    //用户分享
        if (![PublicTool userisCliamed]) {
            return;
        }
    }
       
    PostActivityViewController *vc = [[PostActivityViewController alloc] init];
    vc.postFrom = self.communityType == CommunityType_UserShare ? PostFrom_Flash : PostFrom_Circle;
    __weak typeof(self) weakSelf = self;
    vc.postSuccessBlock = ^{
        [weakSelf.tableView.mj_header beginRefreshing];
    };
    MainNavViewController *nav = [[MainNavViewController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)setupViews {
        
    CGRect rect = CGRectMake(0, 0, SCREENW, SCREENH-kScreenBottomHeight-kScreenTopHeight);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //    self.tableView.contentInset = UIEdgeInsetsMake(41, 0, 0, 0);
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


- (void)pullDown {
    [super pullDown];
    if (self.tableView.tableFooterView) {
        self.tableView.tableFooterView = nil;
    }
    if (!self.tableView.mj_footer) {
        self.tableView.mj_footer = self.mjFooter;
    }
    [QMPEvent event:@"tab_activity_pullrefresh"];
}

- (BOOL)requestData {
    if (![super requestData]) {
        return NO;
    }
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:@(self.currentPage) forKey:@"page"];
    if (self.tableView.mj_header.isRefreshing) {
        [paramDict setValue:@(1) forKey:@"debug"];
    }
    if (self.communityType == CommunityType_UserShare) {
        [paramDict setValue:@(0) forKey:@"type"];
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
                ActivityModel *model = [ActivityModel squareVCModelWithDict:dict];
                model.homeFollow = YES;
                QMPActivityCellModel *cellModel = [[QMPActivityCellModel alloc] initWithActivity:model forCommunity:self.communityType == CommunityType_Topic];
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
            
            if ([ToLogin isLogin]) {
                if (self.currentPage == 2 && self.cellModels.count<10) {
                    if (self.communityType == CommunityType_Topic && self.cellModels.count) {
                        if ([WechatUserInfo shared].claim_type.integerValue != 2 || ([WechatUserInfo shared].claim_type.integerValue == 2 && ![[WechatUserInfo shared].person_role containsString:@"FA"]&& ![[WechatUserInfo shared].person_role containsString:@"investor"])) {
                            [CommunityClaimView showClaimView];
                        }
                    }
                }
            }else{
                if (self.currentPage == 2 && self.cellModels.count<10) {
                    self.tableView.mj_footer = nil;
                    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 80)];
                    [lab labelWithFontSize:14 textColor:BLUE_TITLE_COLOR];
                    lab.textAlignment = NSTextAlignmentCenter;
                    lab.text = @"登录查看更多";
                    lab.userInteractionEnabled = YES;
                    [lab addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(login)]];
                    self.tableView.tableFooterView = lab;
                }
            }
        }
    }];
    return YES;
}

- (void)login{
    [ToLogin enterLoginPage:self];
}
#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.00001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellModels.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.communityType == CommunityType_UserShare) {
        QMPActivityCell *cell = [QMPActivityCell activityCellWithTableView:tableView];
        cell.cellModel = self.cellModels[indexPath.row];
        cell.delegate = self.cellManager;
        return cell;
    }
    
    QMPCommunityActivityCell *cell = [QMPCommunityActivityCell activityCellWithTableView:tableView];
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
    vc.community = self.communityType == CommunityType_Topic;
    vc.activityID = model.ID;
    vc.activityTicket = model.ticket;
    if (model.headerRelate) {
        vc.relateModel = model.headerRelate;
    }
    [self.navigationController pushViewController:vc animated:YES];
    
    if (self.communityType == CommunityType_Topic) {
        QMPCommunityActivityCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        vc.activityCountChanged = ^(ActivityModel *activity) {
            model.reported = activity.reported;
            model.collected = activity.collected;
            model.digged = activity.digged;
            model.diggCount = activity.diggCount;
            model.commentCount = activity.commentCount;
            [cell updateCountWithModel:activity];
        };
        __weak typeof(self) weakSelf = self;
        vc.activityDidDeleted = ^{
            [weakSelf.cellModels removeObjectAtIndex:indexPath.row];
            [weakSelf.tableView reloadData];
        };
    }else{
        
        QMPActivityCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        vc.activityCountChanged = ^(ActivityModel *activity) {
            model.reported = activity.reported;
            model.collected = activity.collected;
            model.digged = activity.digged;
            model.diggCount = activity.diggCount;
            model.commentCount = activity.commentCount;
            [cell updateCountWithModel:activity];
        };
    }
  
    
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
        _cellManager.isCommunity = YES;
    }
    return _cellManager;
}

@end
