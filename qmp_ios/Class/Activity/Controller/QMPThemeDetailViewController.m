//
//  QMPThemeDetailViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/9/21.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPThemeDetailViewController.h"
#import "ActivityModel.h"
#import "DetailNavigationBar.h"
#import "ActivityDetailViewController.h"
#import "QMPActivityCellManager.h"
#import "QMPActivityCellModel.h"

@interface QMPThemeDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *activityData;

@property (nonatomic, strong) NSMutableDictionary *themeDict;
@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, weak) UIImageView *avatarView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *descLabel;
@property (nonatomic, weak) UILabel *metaLabel;
@property (nonatomic, weak) UIButton *followButton;

@property (nonatomic, weak) DetailNavigationBar *myNavBar;
@property (nonatomic, assign) UIStatusBarStyle barStyle;
@property (nonatomic, strong) QMPActivityCellManager *cellManager;

@end

@implementation QMPThemeDetailViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    self.tableView.backgroundColor = [UIColor clearColor];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.cellManager removeMenuView];
}
- (instancetype)init  {
    self = [super init];
    if (self) {
        self.barStyle = UIStatusBarStyleLightContent;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = TABLEVIEW_COLOR;
    
    [self setupViews];
    [self showHUD];
    [self test_loadData];
//    [self loadPersonData];
    [self loadThemeDetail];
    
    
    DetailNavigationBar *topBar = [DetailNavigationBar detailTopBarNoBtn];
    self.myNavBar = topBar;
    topBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    [self.view addSubview:topBar];
    
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
    UIImageView *bgImagV = [[UIImageView alloc]initWithFrame:CGRectMake(0, -kStatusBarHeight, SCREENW,kScreenTopHeight + 399)];
    bgImagV.image = [BundleTool imageNamed:@"detail_bgImg"];
    [self.view addSubview:bgImagV];
    
    CGRect rect = CGRectMake(0, 0, SCREENW, SCREENH);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.mjHeader.gifView.hidden = YES;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
    [self.headerView addSubview:self.cardView];
    self.tableView.tableHeaderView = self.headerView;
    
//    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 400)];
//    footerView.backgroundColor = TABLEVIEW_COLOR;
//    self.tableView.tableFooterView = footerView;
    
}
- (void)loadThemeDetail {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:self.ticketID forKey:@"ticket_id"];
    [param setValue:self.ticket forKey:@"ticket"];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"theme/themeDetail" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            self.metaLabel.attributedText = [self fixMetaShow:resultData];
            self.themeDict =  resultData;
            [self updateUserShow];
        }
    }];
}

- (NSAttributedString *)fixMetaShow:(NSDictionary *)resultData {
    NSInteger focusCount = [resultData[@"focus_count"]?:@(0) integerValue];
    NSInteger likeCount = [resultData[@"all_like_count"]?:@(0) integerValue];
    
    NSString *focusCountShow = [self fixCountShow:focusCount];
    NSString *likeCountShow = [self fixCountShow:likeCount];
    
    NSMutableAttributedString *ms = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"关注 %@", focusCountShow]
                                                                           attributes:@{
                                                                                        NSFontAttributeName: [UIFont systemFontOfSize:13],
                                                                                        NSForegroundColorAttributeName: H9COLOR
                                                                                        }];
    [ms addAttributes:@{NSForegroundColorAttributeName: BLUE_TITLE_COLOR} range:NSMakeRange(3, focusCountShow.length)];
//    [ms addAttributes:@{NSForegroundColorAttributeName: BLUE_TITLE_COLOR} range:NSMakeRange(ms.string.length-likeCountShow.length, likeCountShow.length)];
    return ms;
}

- (NSString *)fixCountShow:(NSInteger)count {
    if (count <= 0) {
        return @"0";
    } else if (count < 1000) {
        return [NSString stringWithFormat:@"%zd", count];
    } else if (count < 10000) {
        return [NSString stringWithFormat:@"%.1fk", count / 1000.0];
    } else if (count < 100000) {
        return [NSString stringWithFormat:@"%zdk", count / 1000];
    } else {
        return @"99k+";
    }
}
- (void)updateUserShow {
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:self.themeDict[@"icon"]?:@""]];
    self.nameLabel.text = self.themeDict[@"name"];
    self.descLabel.text = self.themeDict[@"desc"]?:@"";
    self.followButton.selected = [self.themeDict[@"focus_status"] boolValue];
    self.navigationItem.title = self.themeDict[@"name"];
}
- (void)pullDown {
    [super pullDown];
    [self test_loadData];
    
    [self.myNavBar showAnimator];
}
- (void)pullUp {
    
    [super pullUp];
    [self test_loadData];
}
- (void)test_loadData {
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
        [self.myNavBar hideAnimator];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSArray *arr = resultData[@"list"];
            NSMutableArray *mArr = [NSMutableArray array];
            CGFloat hh = 0;
            for (NSDictionary *dict in arr) {
                ActivityModel *model = [ActivityModel themeVcModelWithDict:dict];
                QMPActivityCellModel *layout = [[QMPActivityCellModel alloc] initWithActivity:model forCommunity:NO];
                [mArr addObject:layout];
                hh += layout.cellHeight;
            }
            if (self.currentPage == 1) {
                self.activityData = mArr;
                if (self.numPerPage > mArr.count) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                CGFloat a = SCREENH - self.headerView.height - hh;
                
                UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, MAX(a, 0))];
                footerView.backgroundColor = TABLEVIEW_COLOR;
                self.tableView.tableFooterView = footerView;
                
            } else {
                [self.activityData addObjectsFromArray:mArr];
                [self refreshFooter:mArr];
            }
            
            [self.tableView reloadData];
        }
        [self hideHUD];
        
    }];
}
- (void)followButtonClick:(UIButton *)button {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"theme" forKey:@"type"];
    [dict setValue:self.nameLabel.text forKey:@"project"];
    [dict setValue:self.ticket forKey:@"ticket"];
    NSString *changeStatus = button.selected ? @"0" : @"1";
    [dict setValue:changeStatus forKey:@"work_flow"];
    if (![PublicTool isNull:[WechatUserInfo shared].uuid]) {
        [dict setValue:[WechatUserInfo shared].uuid forKey:@"uuid"];
    }
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"common/commonFocus" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        NSString * successStatusStr = resultData[@"msg"];
        
        if ([successStatusStr isEqualToString:@"success"]) {
            [PublicTool showMsg:@"操作成功"];
            button.selected = !button.selected;
            
            NSInteger focusCount = [self.themeDict[@"focus_count"]?:@(0) integerValue];
            [self.themeDict setValue:@(focusCount + (button.selected? 1 : -1)) forKey:@"focus_count"];
            self.metaLabel.attributedText = [self fixMetaShow:self.themeDict];
            
        } else if ([successStatusStr isEqualToString:@"fail"]) {
            [PublicTool showMsg:@"操作失败"];
        } else {
            [PublicTool showMsg:@"操作异常"];
        }
    }];

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
    QMPActivityCellModel *cellModel = self.activityData[indexPath.row];
    ActivityModel *model = cellModel.activity;
    ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] init];
    vc.activityID = model.ID;
    vc.activityTicket = model.ticket;
//    vc.listLayout = self.activityData[indexPath.row];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.cellManager removeMenuView];
    if(scrollView != self.tableView){
        return;
    }
    //导航
    if (kScreenTopHeight - scrollView.contentOffset.y <= 44 && ![self.myNavBar isWhite]) {
        if([PublicTool isNull:self.myNavBar.title]){
            self.myNavBar.title = self.nameLabel.text;
        }
        [self.myNavBar changeColorToWhite:YES];
        self.barStyle = UIStatusBarStyleDefault;
        [self setNeedsStatusBarAppearanceUpdate];
        
    }else if(kScreenTopHeight - scrollView.contentOffset.y > 44 && [self.myNavBar isWhite]){
        
        if(![PublicTool isNull:self.myNavBar.title]){
            self.myNavBar.title = nil;
        }
        [self.myNavBar changeColorToWhite:NO];
        self.barStyle = UIStatusBarStyleLightContent;
        [self setNeedsStatusBarAppearanceUpdate];
        
    }
}
- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.frame = CGRectMake(0, 0, SCREENW, 144+kScreenTopHeight);
        
        UIImageView *view = [[UIImageView alloc] init];
        view.frame = CGRectMake(0, 144+kScreenTopHeight-68, SCREENW, 68);
        view.backgroundColor = [UIColor whiteColor];
        [_headerView addSubview:view];
    }
    return _headerView;
}

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.frame = CGRectMake(15, kScreenTopHeight+10, SCREENW-30, 120);
        _cardView.backgroundColor = [UIColor whiteColor];
        
        _cardView.layer.shadowColor = H9COLOR.CGColor;
        _cardView.layer.shadowOffset = CGSizeMake(0, 0);
        _cardView.layer.shadowOpacity = 0.2;
        _cardView.layer.shadowRadius = 4.0;
        _cardView.layer.cornerRadius = 6.0;
        
        UIImageView *avatarView = [[UIImageView alloc] init];
        avatarView.frame = CGRectMake(17, (120-70)/2.0, 70, 70);
        avatarView.layer.cornerRadius = 35.0;
        avatarView.layer.borderColor = [BORDER_LINE_COLOR CGColor];
        avatarView.layer.borderWidth = 0.5;
        avatarView.clipsToBounds = YES;
        [_cardView addSubview:avatarView];
        self.avatarView = avatarView;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(avatarView.right+14, 30, 180, 22);
        nameLabel.textColor = NV_TITLE_COLOR;
        if (@available(iOS 8.2, *)) {
            nameLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        }else{
            nameLabel.font = [UIFont systemFontOfSize:18];
        }
        [_cardView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        UILabel *descLabel = [[UILabel alloc] init];
        descLabel.frame = CGRectMake(nameLabel.left, nameLabel.bottom+4, 180, 17);
        descLabel.textColor = H6COLOR;
        descLabel.font = [UIFont systemFontOfSize:13];
        [_cardView addSubview:descLabel];
        self.descLabel = descLabel;
        
        UILabel *metaLabel = [[UILabel alloc] init];
        metaLabel.frame = CGRectMake(nameLabel.left, descLabel.bottom+4, 180, 17);
        metaLabel.textColor = H6COLOR;
        metaLabel.font = [UIFont systemFontOfSize:13];
        [_cardView addSubview:metaLabel];
        self.metaLabel = metaLabel;
        
        UIButton *followButton = [[UIButton alloc] init];
        followButton.frame = CGRectMake(SCREENW-30-15-50, 0, 50, 20);
        followButton.centerY = nameLabel.centerY;
        followButton.titleLabel.font = [UIFont systemFontOfSize:11];
        followButton.layer.cornerRadius = 2.0;
        followButton.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
        followButton.layer.borderWidth = 1.0;
        [followButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [followButton setTitle:@"+关注" forState:UIControlStateNormal];
        [followButton setTitle:@"已关注" forState:UIControlStateSelected];
        [followButton addTarget:self action:@selector(followButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_cardView addSubview:followButton];
        self.followButton = followButton;
    }
    return _cardView;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.barStyle;
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
