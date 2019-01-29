//
//  MyWalletViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/8/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MyWalletViewController.h"
#import "WalletCoinListCell.h"
#import "WalletHeaderView.h"
#import "CoinFlowModel.h"
#import "PersonModel.h"

@interface MyWalletViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSMutableArray *tradeList;
@property(nonatomic,strong)UIImageView *topStatusView;
@property(nonatomic,strong)UIView *barView;
@property(nonatomic,strong) UIActivityIndicatorView *animatorView;

@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addViews];
    [self showHUD];
    [self requestData];
}

- (void)addViews{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.tableView];
    self.tableView.mj_header = self.mjHeader;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    WalletHeaderView *headerV = [nilloadNibNamed:@"WalletHeaderView" owner:nil options:nil].lastObject;
    headerV.height = isiPhoneX ? 230:210;
    [headerV.backBtn addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = headerV;
    
    self.topStatusView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 1)];
    self.topStatusView.image = [UIImage imageNamed:@"me_wallet_topbg"];
    [self.view addSubview:self.topStatusView];
    
    [self navigaitonView];
    
}

- (void)navigaitonView{
    //导航
    UIView *navigationBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, kScreenTopHeight)];
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:navigationBarView.bounds];
    imgV.image = [UIImage imageFromColor:BLUE_TITLE_COLOR andSize:CGSizeMake(SCREENW, kScreenTopHeight)];
    [navigationBarView addSubview:imgV];
    imgV.userInteractionEnabled = YES;
    imgV.tag = 999;
    imgV.hidden = YES;
    
    [navigationBarView addSubview:[self createBackButton]];
    [navigationBarView addSubview:[self userHeaderView]];
    [self.view addSubview:navigationBarView];
    
    UILabel *centerLab = [[UILabel alloc]initWithFrame:CGRectMake(0, kStatusBarHeight, 150, kNavigationBarHeight)];
    [centerLab labelWithFontSize:17 textColor:[UIColor whiteColor]];
    centerLab.text = @"钱包";
    [navigationBarView addSubview:centerLab];
    centerLab.textAlignment = NSTextAlignmentCenter;
    centerLab.centerX = SCREENW/2.0;
    centerLab.hidden = YES;
    centerLab.tag = 3000;
    
    UILabel *rightLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREENW - 50, kStatusBarHeight, 40, kNavigationBarHeight)];
    [rightLab labelWithFontSize:16 textColor:[UIColor whiteColor]];
    rightLab.text = @"主页";
    rightLab.userInteractionEnabled = YES;
    [rightLab addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterPersonDetail)]];
    [navigationBarView addSubview:rightLab];
    rightLab.hidden = YES;
    rightLab.tag = 3001;
    navigationBarView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.0];
    
    _barView = navigationBarView;
}
- (UIButton*)createBackButton{
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(17,kStatusBarHeight, 60, kNavigationBarHeight)];
    [leftButton setImage:[UIImage imageNamed:@"left_arrow_white"] forState:UIControlStateNormal];
    [leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [leftButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    
    return leftButton;
}

- (UIView*)userHeaderView{
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(SCREENW - 76, (kNavigationBarHeight-32)/2.0+kStatusBarHeight, 90, 32)];
    headerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    
    headerView.layer.cornerRadius = 16;
    headerView.layer.masksToBounds = YES;
    
   
    UIImageView *userIcon = [[UIImageView alloc]initWithFrame:CGRectMake(2, 2, 28, 28)];
    [userIcon sd_setImageWithURL:[NSURL URLWithString:[WechatUserInfo shared].headimgurl] placeholderImage:[UIImage imageNamed:@"heading"]];
    userIcon.layer.cornerRadius = 14;
    userIcon.layer.masksToBounds = YES;
    userIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    userIcon.layer.borderWidth = 0.5;
    [headerView addSubview:userIcon];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(userIcon.right+6, 0, 40, 20)];
    [lab labelWithFontSize:16 textColor:[UIColor whiteColor]];
    lab.text = @"主页";
    [headerView addSubview:lab];
    lab.centerY = userIcon.centerY;
    
    [headerView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterPersonDetail)]];
    headerView.tag = 2000;
    return headerView;
}


- (void)enterPersonDetail{
    
    PersonModel *person = [[PersonModel alloc]init];
    person.personId = [WechatUserInfo shared].person_id;
    person.unionid = [WechatUserInfo shared].unionid;
    [PublicTool goPersonDetail:person];
}

- (void)popSelf{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark --用户流水
-(void)pullDown{
    [super pullDown];
    [self.mjHeader endRefreshing];
    [self showAnimator];
}

- (void)showAnimator{
    self.tableView.mj_header = nil;
    [self.view addSubview:self.animatorView];
    [self.animatorView startAnimating];
}
- (void)hideAnimator{
    [self.animatorView startAnimating];
    [self.animatorView removeFromSuperview];
    self.tableView.mj_header = self.mjHeader;
}

- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"user/userCoinOperatedFlowing" HTTPBody:@{@"uuid":[WechatUserInfo shared].uuid} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self hideAnimator];
        
        if (resultData) {
            QMPLog(@"剩余金币----%@",resultData[@"surplusCoin"]);
            
            WalletHeaderView *headerV = (WalletHeaderView*)self.tableView.tableHeaderView;
            headerV.coinNumLab.text = [NSString stringWithFormat:@"%@ 币",resultData[@"surplusCoin"]];
            UILabel *centerLab = [self.barView viewWithTag:3000];
            centerLab.text = [NSString stringWithFormat:@"%@币",resultData[@"surplusCoin"]];
            if (self.currentPage == 1) {
                [self.tradeList removeAllObjects];
            }
            for (NSDictionary *dic in resultData[@"flowingList"]) {
                [self.tradeList addObject:[[CoinFlowModel alloc]initWithDictionary:dic error:nil]];
            }
            [self.tableView reloadData];
        }
    }];
    return YES;
}



#pragma mark ---UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 79;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tradeList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WalletCoinListCell *cell = [WalletCoinListCell cellWithTableView:tableView];
    
    cell.tradeModel = self.tradeList[indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        CGRect frame = _topStatusView.frame;
        frame.size.height = 1 - scrollView.contentOffset.y;
        _topStatusView.frame = frame;
        
    }else {
        CGRect frame = _topStatusView.frame;
        frame.size.height = 1;
        _topStatusView.frame = frame;
    }
    if (scrollView.contentOffset.y > self.tableView.tableHeaderView.height-kScreenTopHeight) {
        [self.barView viewWithTag:999].hidden = NO;
        [self.barView viewWithTag:3000].hidden = NO;
        [self.barView viewWithTag:3001].hidden = NO;
        [self.barView viewWithTag:2000].hidden = YES;


    }else{
        [self.barView viewWithTag:999].hidden = YES;
        [self.barView viewWithTag:3000].hidden = YES;
        [self.barView viewWithTag:3001].hidden = YES;
        [self.barView viewWithTag:2000].hidden = NO;
    }
}

#pragma mark --Getter\Setter--

- (NSMutableArray *)tradeList{
    if (!_tradeList) {
        _tradeList = [NSMutableArray array];
    }
    return _tradeList;
}

-(UIActivityIndicatorView *)animatorView{
    if (!_animatorView) {
        _animatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _animatorView.hidesWhenStopped = YES;
        _animatorView.frame = CGRectMake(SCREENW/2.0-20, kStatusBarHeight, 40, kNavigationBarHeight);
    }
    return _animatorView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
