//
//  BaseViewController.m
//  qmp_ios
//
//  Created by QMP on 2017/8/24.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "BaseViewController.h"
#import "TestNetWorkReached.h"
#import "MainNavViewController.h"
#import "LoadingAnimator.h"

@interface BaseViewController ()
{
    //    NSDate *_lastDate;
    NSString *_selectedController;
    NSString *_lastContoller;
    NSMutableArray *_headerAnimatorImgs;
}
@property(nonatomic,strong) ManagerHud *hudView;
@property(nonatomic,strong) LoadingAnimator *loadAnimator;

//--网络异常无数据view
@property(nonatomic,strong) UIView *netFailedView;
//无数据view
@property (nonatomic,strong)UIView *noDataView;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation BaseViewController

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    QMPLog(@"=======dealloc--------%@",self.childViewControllers);
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [QMPEvent endLogPageView:NSStringFromClass([self class])];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.tableView) {
        self.tableView.backgroundColor = TABLEVIEW_COLOR;
    }
    [QMPEvent beginLogPageView:NSStringFromClass([self class])];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.statusBarStyle = UIStatusBarStyleDefault;
    self.view.backgroundColor = [UIColor whiteColor];
    self.currentPage = 1;
    self.numPerPage = 20;
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshStatusBar:) name:NOTIFI_STATUSBAR_REFRESH object:nil];
}


- (void)refreshStatusBar:(NSNotification *)noti {
    //    self.statusBarStyle = [noti.userInfo[@"statusBarStyle"]?:@(UIStatusBarStyleDefault) integerValue];
    [self setNeedsStatusBarAppearanceUpdate];
}


#pragma mark --网络请求相关
- (void)refreshFooter:(NSArray*)arr{
    
    self.tableView.mj_footer = self.mjFooter;
    
    if (arr.count < self.numPerPage) {
        if (self.currentPage == 1) {
            self.mjFooter.stateLabel.hidden = YES;
            self.mjFooter.state = MJRefreshStateNoMoreData;
            [self.mjFooter endRefreshingWithNoMoreData];
            
        }else{
            self.mjFooter.stateLabel.hidden = NO;
            self.mjFooter.state = MJRefreshStateNoMoreData;
            [self.mjFooter endRefreshingWithNoMoreData];
        }
        
    }else{
        self.mjFooter.stateLabel.hidden = YES;
        self.mjFooter.state = MJRefreshStateIdle;
    }
}

//子类实现
- (BOOL)requestData{
    [self hideNoDataView];
    [self hideNetFailedView];
    
    //    //网络状况
    if (![TestNetWorkReached networkIsReachedNoAlert]) {
        
        [self hideHUD];
        
        if ([self.tableView.mj_header isRefreshing] || [self.tableView.mj_footer isRefreshing]) {
            [ShowInfo showInfoOnView:KEYWindow withInfo:@"网络连接不可用，请稍后再试"];//网络未连接
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            return NO;
        }
        if ([PublicTool topViewController].navigationController.childViewControllers.count > 1) {
            [self showNetFailedView];
        }
        return NO;
    }
    
    [self hideNetFailedView];
    
    return YES;
}

/*-(void)setTableView:(UITableView *)tableView{
 
 _tableView = tableView;
 _tableView.mj_header = self.mjHeader;
 _tableView.mj_footer = self.mjFooter;
 }*/


//上拉加载
- (void)pullUp{
    
    _currentPage++;
    [self requestData];
}

//下拉刷新
- (void)pullDown{
    
    _currentPage = 1;
    self.mjFooter = nil;
    [self requestData];
}


#pragma mark --各种视图
//网络异常 背景图
- (void)showNetFailedView{
    if (self.netFailedView.superview) {
        [self hideNetFailedView];
    }
    
    [self.view addSubview:self.netFailedView];
    self.netFailedView.centerY = self.view.centerY;
    
    //    if (self.navigationController.navigationBar.isHidden) {
    //    }else{
    //        self.netFailedView.centerY = self.view.centerY;
    //    }
}

- (void)hideNetFailedView{
    
    [self.netFailedView removeFromSuperview];
    
}


//接口请求成功无数据返回情况 显示背景
- (void)showNoDataViewWithTitle:(NSString*)title{
    [self showNoDataView];
    for (UIView *subV in self.noDataView.subviews) {
        if ([subV isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel*)subV;
            label.text = title;
        }
    }
    
}
- (void)showNoDataView{
    
    if (self.noDataView.superview) {
        [self.noDataView removeFromSuperview];
    }
    [self.view addSubview:self.noDataView];
    for (UIView *subV in self.noDataView.subviews) {
        if ([subV isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel*)subV;
            label.text = @"数据完善中";
        }
    }
    
}

- (void)hideNoDataView{
    [self.noDataView removeFromSuperview];
}

//加载 动画hud
- (void)showHUD{
    
    [self.loadAnimator showAnimatorInView:self.view];
}

//加载 动画hud
- (void)showHUDAtTop:(CGFloat)top{
    [self showHUD];
    self.loadAnimator.top = top;
}

- (void)hideHUD{
    
    [self.loadAnimator dismissAnimatorInView:self.view];
    self.loadAnimator = nil;
    
}


//点击网络异常背景图  重新加载数据
- (void)netFailedViewTap{
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }
    self.currentPage = 1;
    [self showHUD];
    [self requestData];
}


- (void)showNavigationBarLine{
    //导航的线隐藏
    for (UIView *subv in self.navigationController.navigationBar.subviews ) {
        if (subv.height <= 1 && subv.width > 200) {
            subv.hidden = NO;
            break;
        }
    }
}

- (void)hideNavigationBarLine{
    //导航的线隐藏
    for (UIView *subv in self.navigationController.navigationBar.subviews ) {
        if (subv.height <= 1 && subv.width > 200) {
            subv.hidden = YES;
            break;
        }
    }
}

- (HomeInfoTableViewCell*)nodataCellWithInfo:(NSString*)title subInfo:(NSString*)subTitle tableView:(UITableView*)tableview{
    HomeInfoTableViewCell *infoCell = [tableview dequeueReusableCellWithIdentifier:@"HomeInfoTableViewCellID"];
    if (!infoCell) {
        infoCell = [[nil loadNibNamed:@"HomeInfoTableViewCell" owner:nil options:nil] lastObject];
        infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [infoCell.iconImgView setImage:[UIImage imageNamed:IMAGE_DATA_NULL]];
    infoCell.infoLbl.text = [TestNetWorkReached networkIsReachedNoAlert] ? title:@"网络连接不可用";
    infoCell.subInfoLab.text = subTitle;
    infoCell.subInfoLab.hidden = NO;
    [infoCell.infoLbl sizeToFit];
    infoCell.createBtn.hidden = YES;
    return infoCell;
}

- (HomeInfoTableViewCell*)nodataCellWithInfo:(NSString*)title tableView:(UITableView*)tableview{
    
    HomeInfoTableViewCell *infoCell = [tableview dequeueReusableCellWithIdentifier:@"HomeInfoTableViewCellID"];
    if (!infoCell) {
        infoCell = [[nil loadNibNamed:@"HomeInfoTableViewCell" owner:nil options:nil] lastObject];
    }
    
    [infoCell.iconImgView setImage:[UIImage imageNamed:IMAGE_DATA_NULL]];
    if ([title isKindOfClass:[NSAttributedString class]] || [title isKindOfClass:[NSMutableAttributedString class]]) {
        infoCell.infoLbl.attributedText = (NSAttributedString*)title;
    }else{
        infoCell.infoLbl.text = [TestNetWorkReached networkIsReachedNoAlert] ?title:@"网络连接不可用";
    }
    infoCell.createBtn.hidden = YES;
    infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return infoCell;
}


- (BOOL)noDataIsAllowSelectedTbVw:(UITableView *)tb withIndexPaht:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tb cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[HomeInfoTableViewCell class]]) {
        return YES;
    }
    
    return NO;
}

- (void)goHome{
    
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:YES];
    //    ;
    [QMPEvent event:@"pro_nabar_more_homeClick"];
}

#pragma mark ---懒加载
- (MJRefreshGifHeader*)mjHeader{
    
    if (!_mjHeader) {
        
        _headerAnimatorImgs = [NSMutableArray array];
        for (int i=1; i<=65; i++) {
            [_headerAnimatorImgs addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading%d",i]]];
            
        }
        __weak typeof(self) weakSelf = self;
        MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            weakSelf.currentPage = 1;
            [weakSelf pullDown];
        }];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden=YES;
        
        [header setImages:@[[UIImage imageNamed:@"loading1"]] duration:1 forState:MJRefreshStateIdle];
        [header setImages:@[[UIImage imageNamed:@"loading1"]] duration:1 forState:MJRefreshStatePulling];
        [header setImages:_headerAnimatorImgs duration:0.8 forState:MJRefreshStateRefreshing];
        
        _mjHeader = header;
        //        _mjHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //            self.currentPage = 1;
        //            [self pullDown];
        //        }];
        //        _mjHeader.stateLabel.font = [UIFont systemFontOfSize:14];
        //        _mjHeader.stateLabel.textColor = H9COLOR;
        //        [_mjHeader setTitle:@"数据更新中" forState:MJRefreshStateRefreshing];
        //
        ////        _mjHeader.labelLeftInset = 50;
        //        _mjHeader.lastUpdatedTimeLabel.hidden = YES;
    }
    return _mjHeader;
}

- (MJRefreshAutoNormalFooter *)mjFooter{
    if (!_mjFooter) {
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullUp)];
        footer.stateLabel.hidden = YES;
        footer.refreshingTitleHidden = YES;
        [footer setTitle:@"-END-" forState:MJRefreshStateNoMoreData];
        footer.stateLabel.textColor = RGB(130, 129, 135, 1);
        footer.stateLabel.font = [UIFont systemFontOfSize:14];
        footer.stateLabel.numberOfLines = 0;
        _mjFooter = footer;
    }
    return _mjFooter;
    
}

- (ManagerHud *)hudView{
    if (!_hudView) {
        _hudView = [[ManagerHud alloc]init];
    }
    return _hudView;
}

-(LoadingAnimator *)loadAnimator{
    if (!_loadAnimator) {
        _loadAnimator = [[LoadingAnimator alloc]init];
    }
    return _loadAnimator;
}
- (UIView *)netFailedView{
    if (!_netFailedView) {
        UIView *fristView = [[UIView alloc]init];
        fristView.frame = CGRectMake(0, 0, SCREENW, SCREENH);
        fristView.backgroundColor = TABLEVIEW_COLOR;
        _netFailedView = fristView;
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame = CGRectMake((SCREENW-150)/2, kScreenTopHeight+86, 145, 145);
        imageView.image = [UIImage imageNamed:IMAGE_NONETWORK];
        [_netFailedView addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake((SCREENW-250)/2, imageView.bottom+15, 250, 30);
        label.text = REQUEST_ERROR_NETWORK;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = RGB(120, 119, 115, 1);
        label.font = [UIFont systemFontOfSize:16.f];
        label.userInteractionEnabled = YES;
        [_netFailedView addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(netFailedViewTap)];
        [_netFailedView addGestureRecognizer:tap];
    }
    
    return _netFailedView;
}

- (UIView *)noDataView{
    if (!_noDataView) {
        UIView *fristView = [[UIView alloc]init];
        fristView.frame = CGRectMake(0, 100, SCREENW, SCREENH-200);
        _noDataView = fristView;
        
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame = CGRectMake((SCREENW-100)/2, fristView.height/2.0-120, 100, 100);
        imageView.image = [UIImage imageNamed:IMAGE_DATA_NULL];
        [_noDataView addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake((SCREENW-250)/2,imageView.bottom, 250, 50);
        label.text = @"数据完善中...";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = RGB(120, 119, 115, 1);
        label.font = [UIFont systemFontOfSize:16.f];
        label.userInteractionEnabled = YES;
        [_noDataView addSubview:label];
    }
    return _noDataView;
}


- (ShareTo *)shareTool{
    if (!_shareTool) {
        _shareTool = [[ShareTo alloc]init];
    }
    return _shareTool;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return self.statusBarStyle;
}


@end
