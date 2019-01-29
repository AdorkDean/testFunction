//
//  HomeViewController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/5/15.
//  Copyright © 2018年 Molly. All rights reserved.
//  首页控制器

#import "HomeViewController.h"
#import <CommonLibrary/SPPageMenu.h>
#import "HomeHeaderView.h"
#import <CommonLibrary/MainSearchController.h>
#import <CommonLibrary/HomeNavigationBar.h>
#import "HomeHeaderView.h"
#import "Home3ViewController.h"
#import "Home5ViewController.h"
#import "Home6ViewController.h"
#import "HomeIPOViewController.h"
#import  <CommonLibrary/HomeAllViewController.h>
#import <CommonLibrary/ReportController.h>
#import  <CommonLibrary/InvestOpportunityViewController.h>
#import  <CommonLibrary/QMPOrganizationLibraryViewController.h>
#import  <CommonLibrary/QMPSecondaryMarketViewController.h>
#import  <CommonLibrary/QMPDataGraphViewController.h>
#import  <CommonLibrary/FinanceReportController.h>
#import  <CommonLibrary/InvestorsListController.h>
#import  <CommonLibrary/ProspectusListController.h>
#import  <CommonLibrary/ProductAlbumController.h>
#import  <CommonLibrary/FinanceReportController.h>
#import <CommonLibrary/AppDelegateTool.h>

#define TOPHEIGHT (kStatusBarHeight+47+45+78) //47是搜索按钮以上的高度,45搜索高度
#define PageMenuH 40

@interface HomeViewController () <UIScrollViewDelegate, SPPageMenuDelegate, HomeHeaderViewDelegate> {
    NSInteger _selectIndex;
    CGFloat _top;
}
@property (nonatomic, strong) UIView *topHeaderView;
@property (nonatomic, strong) UIView *stopView;
@property (nonatomic, strong) SPPageMenu *pageMenu;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat lastPageMenuY;

@property (nonatomic, strong) HomeHeaderView *headerView;
@property (nonatomic, strong) HomeNavigationBar *navBar;

@property (nonatomic, assign) BOOL fix;
@property (nonatomic, strong) NSDate *leftTime;
@end

@implementation HomeViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [QMPEvent beginEvent:@"tab_home_timer"];
    
    NSString *label;
    if (self.pageMenu.selectedItemIndex == 0) {
        label = @"国内";
    } else if (self.pageMenu.selectedItemIndex == 1) {
        label = @"国外";
    } else if (self.pageMenu.selectedItemIndex == 2) {
        label = @"IPO";
    }  else if (self.pageMenu.selectedItemIndex == 3) {
        label = @"并购";
    }
    [QMPEvent beginEvent:@"tab_home_recent_timer" attributes:@{@"name":label}];


    if (![ToLogin isLogin]) {
        return;
    }
    
    [self.navBar refreshMsdCount];
    [[AppDelegateTool shared] applicationLaunchWork];

}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.leftTime = [NSDate date];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self enterForeground];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [QMPEvent endEvent:@"tab_home_timer"];

    NSString *label;
    if (self.pageMenu.selectedItemIndex == 0) {
       label = @"国内";
    } else if (self.pageMenu.selectedItemIndex == 1) {
        label = @"国外";
    } else if (self.pageMenu.selectedItemIndex == 2) {
        label = @"IPO";
    }  else if (self.pageMenu.selectedItemIndex == 3) {
        label = @"并购";
    }
    [QMPEvent endEvent:@"tab_home_recent_timer" attributes:@{@"name":label}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _top = TOPHEIGHT;
    NSLog(@"HomeViewController 开始执行");

    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self setUI];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    QMPLog(@"HomeViewController 执行完了");

}
- (void)enterBackground {
    self.leftTime = [NSDate date];
}
- (void)enterForeground{
    if (self.leftTime == nil) {
        return;
    }
    if (-self.leftTime.timeIntervalSinceNow >= 600) {
        for (HomeBaseViewController *vc in self.childViewControllers) {
            if ([vc isKindOfClass:[HomeBaseViewController class]]) {
                [vc refreshData];
            }
        }
    }

}

- (void)setUI{
    
    [self.view addSubview:self.scrollView];
    
    [self addChildViewContollers];
    
    [self.view addSubview:self.topHeaderView];
    [self.view addSubview:self.stopView];
    
    [self.topHeaderView addSubview:self.headerView];
    [self.view addSubview:self.navBar];
    
//    UIView *grayView = [[UIView alloc]initWithFrame:CGRectMake(0, self.headerView.height-10, SCREENW, 10)];
//    grayView.backgroundColor = HTColorFromRGB(0xf5f5f5);
//    [_topHeaderView addSubview:grayView];
//
    // 监听子控制器中scrollView正在滑动所发出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subScrollViewDidScroll:) name:ChildHomeScrollViewDidScrollNSNotification object:nil];
    // 监听自控制器的刷新状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshState:) name:ChildHomeScrollViewRefreshStateNSNotification object:nil];
    [self.pageMenu setSelectedItemIndex:0];
}
- (void)subScrollViewDidScroll:(NSNotification *)noti {
    
    // 取出当前正在滑动的tableView
    UIScrollView *scrollingScrollView = noti.userInfo[@"scrollingScrollViewOfHome"];
    CGFloat offsetDifference = [noti.userInfo[@"offsetDifferenceofHome"] floatValue];
    
    CGFloat distanceY;
    if (self.childViewControllers.count <= self.pageMenu.selectedItemIndex) {
        return;
    }
    // 取出的scrollingScrollView并非是唯一的，当有多个子控制器上的scrollView同时滑动时都会发出通知来到这个方法，所以要过滤
    HomeBaseViewController *baseVc = self.childViewControllers[self.pageMenu.selectedItemIndex];
    
    if (scrollingScrollView == baseVc.scrollView) {
        
        // 让悬浮菜单跟随scrollView滑动
        CGRect pageMenuFrame = self.stopView.frame;
        
        if (pageMenuFrame.origin.y >= kScreenTopHeight) {
            // 往上移
            if (offsetDifference > 0 && scrollingScrollView.contentOffset.y+(TOPHEIGHT+PageMenuH) > 0) {
                
                if (((scrollingScrollView.contentOffset.y+(TOPHEIGHT+PageMenuH)+self.stopView.frame.origin.y)>=TOPHEIGHT) || scrollingScrollView.contentOffset.y+(TOPHEIGHT+PageMenuH) < 0) {
                    // 悬浮菜单的y值等于当前正在滑动且显示在屏幕范围内的的scrollView的contentOffset.y的改变量(这是最难的点)
                    pageMenuFrame.origin.y += -offsetDifference;
                    if (pageMenuFrame.origin.y <= kScreenTopHeight) {
                        pageMenuFrame.origin.y = kScreenTopHeight;
                    }
                }
            } else { // 往下移
                if ((scrollingScrollView.contentOffset.y+(TOPHEIGHT+PageMenuH)+self.stopView.frame.origin.y)<TOPHEIGHT) {
                    pageMenuFrame.origin.y = -scrollingScrollView.contentOffset.y-(TOPHEIGHT+PageMenuH)+TOPHEIGHT;
                    if (pageMenuFrame.origin.y >= TOPHEIGHT) {
                        pageMenuFrame.origin.y = TOPHEIGHT;
                    }
                }
            }
        }
        
        self.stopView.frame = pageMenuFrame;
        
        
        CGRect headerFrame = self.topHeaderView.frame;
        headerFrame.origin.y = self.stopView.frame.origin.y-TOPHEIGHT;
        self.topHeaderView.frame = headerFrame;
        
        // 记录悬浮菜单的y值改变量
        distanceY = pageMenuFrame.origin.y - self.lastPageMenuY;
        //差值=
        CGFloat changeDistance = 47-(45-30)/2.0; //搜索button上移47，但是高度45变成30，所以需要小于47
        
        CGFloat finishDistanceY = (TOPHEIGHT-(TOPHEIGHT-changeDistance)); //最终值
        CGFloat currentDistanceY = (TOPHEIGHT-pageMenuFrame.origin.y); //当前值 升
        CGFloat scale = (finishDistanceY-currentDistanceY)/finishDistanceY; //1->0
        if (scale>=0 && scale<=1) {
            //按钮的差值
            CGFloat width = 75-26;
            CGFloat height = 45-30;
            CGRect searchFrame = self.headerView.searchButton.frame;
            
            searchFrame.size.width = (SCREENW-26)-(1-scale)*width;
            searchFrame.size.height = (45)-(1-scale)*height;
            self.headerView.searchButton.frame = searchFrame;
        }
        
        self.lastPageMenuY = self.stopView.frame.origin.y;
        if (self.lastPageMenuY < (TOPHEIGHT-(changeDistance)) && self.navBar.barStyle != BarStyle_White) {
            self.navBar.barStyle = BarStyle_White;
            self.navBar.searchBtn.hidden = NO;
        }
        if (self.lastPageMenuY >(TOPHEIGHT-(changeDistance)) && self.navBar.barStyle != BarStyle_Clear) {
            self.navBar.barStyle = BarStyle_Clear;
            self.navBar.searchBtn.hidden = YES;
        }
        
        distanceY = -self.stopView.frame.origin.y-PageMenuH;
        // 让其余控制器的scrollView跟随当前正在滑动的scrollView滑动
//        if (scrollingScrollView.contentOffset.y <= -109) {
            [self followScrollingScrollView:scrollingScrollView distanceY:distanceY];
        //        }
        
    }
    
    
}

- (void)followScrollingScrollView:(UIScrollView *)scrollingScrollView distanceY:(CGFloat)distanceY{
    HomeBaseViewController *baseVc = nil;
    for (int i = 0; i < self.childViewControllers.count; i++) {
        baseVc = self.childViewControllers[i];
        if (baseVc.scrollView == scrollingScrollView) {
            continue;
        } else {
            CGPoint contentOffSet = baseVc.scrollView.contentOffset;
            //            contentOffSet.y += distanceY;
            CGFloat f = distanceY;
            contentOffSet.y = MIN(f, -kScreenTopHeight-PageMenuH);
            baseVc.scrollView.contentOffset = contentOffSet;
        }
    }
}
- (void)refreshState:(NSNotification *)noti {
    BOOL state = [noti.userInfo[@"isRefreshing"] boolValue];
    // 正在刷新时禁止self.scrollView滑动
    self.scrollView.scrollEnabled = !state;
}
- (NSString *)fixType:(NSString *)t {
    NSDictionary *dict = @{@"全部":@"",@"融资":@"国内融资",@"国外融资":@"国外融资",@"募资":@"机构募资",@"并购":@"并购事件",@"财报":@"财报速递",@"IPO":@"IPO动向"};
    return dict[t];
}
- (void)addChildViewContollers{
    NSArray *arr = @[@"融资",@"国外",@"IPO",@"并购"];
    __weak typeof(self) weakSelf = self;
    for (NSString *str in arr) {
        HomeBaseViewController *vc = [HomeBaseViewController new];
        if ([str isEqualToString:@"融资"]) {
            vc = [Home3ViewController new];
        } else if ([str isEqualToString:@"国外"]) {
            vc = [Home5ViewController new];
        } else if ([str isEqualToString:@"并购"]) {
            vc = [Home6ViewController new];
        } else if ([str isEqualToString:@"IPO"]) {
            vc = [HomeIPOViewController new];
        } else if ([str isEqualToString:@"全部"]) {
            vc.type = @"";
        } else {
            vc.type = [self fixType:str];
        }
        vc.headerHeight = 351;
        
        //        if ([arr indexOfObject:str] == 0) {
        vc.view.frame = CGRectMake(SCREENW*[arr indexOfObject:str], 0, SCREENW, _scrollView.height);
        //        }
        [self addChildViewController:vc];
        [self.scrollView addSubview:vc.view];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //    HomeBaseViewController *baseVc = self.childViewControllers[self.pageMenu.selectedItemIndex];
    //
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        if (baseVc.scrollView.contentSize.height < SCREENH && [baseVc isViewLoaded]) {
    //            [baseVc.scrollView setContentOffset:CGPointMake(0, -(TOPHEIGHT+PageMenuH)) animated:YES];
    //            QMPLog(@"-----%f",kHeaderViewH+kPageMenuH);
    //        }
    //    });
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    //
    //
    //    [self showVc:index];
    
    //    HomeBaseViewController *baseVc = self.childViewControllers[self.pageMenu.selectedItemIndex];
    //
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        if (baseVc.scrollView.contentSize.height < SCREENH && [baseVc isViewLoaded]) {
    //            [baseVc.scrollView setContentOffset:CGPointMake(0, -(TOPHEIGHT+PageMenuH)) animated:YES];
    //        }
    //    });
    
    //    [self showVc:self.pageMenu.selectedItemIndex];
}

-(void)showVc:(NSInteger)index
{
    //    CGFloat offsetX = index*SCREENW;
    //
    //    HomeBaseViewController *vc = self.childViewControllers[index];
    //
    //
    ////    if (vc.isViewLoaded) {
    ////        return;
    ////    }
    //    if (vc.isFirstViewLoaded) {
    //        return;
    //    }
    //    vc.isFirstViewLoaded = YES;
    //
    //    [vc requestData];
    ////    vc.view.frame = CGRectMake(offsetX, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    ////    [self.scrollView addSubview:vc.view];
    //
    ////    vc.view.frame = CGRectMake(SCREENW*toIndex, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    //    UIScrollView *s = vc.scrollView;
    //    CGPoint contentOffset = s.contentOffset;
    //    contentOffset.y = -self.topHeaderView.frame.origin.y-(TOPHEIGHT+PageMenuH);
    //    if (contentOffset.y + (TOPHEIGHT+PageMenuH) >= TOPHEIGHT) {
    //        contentOffset.y = TOPHEIGHT-(TOPHEIGHT + PageMenuH);
    //    }
    //    s.contentOffset = contentOffset;
}

- (void)pageMenu:(SPPageMenu *)pageMenu currentButtonClickAtIndex:(NSInteger)index {
    
    
}
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    _selectIndex = toIndex;
    
    if (!self.childViewControllers.count) {return;}
    
    
    
    // 如果上一次点击的button下标与当前点击的buton下标之差大于等于2,说明跨界面移动了,此时不动画.
    if (labs(toIndex - fromIndex) >= 2) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * toIndex, 0) animated:NO];
        });
    } else {
        // 动画为YES，会迟一些走scrollViewDidScroll
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * toIndex, 0) animated:YES];
        });
        
    }
    
    HomeBaseViewController *targetViewController = self.childViewControllers[toIndex];
    NSString *str = [pageMenu titleForItemAtIndex:toIndex];

    NSString *toName;
    if (toIndex == 0) {
        toName = @"国内";
    } else if (toIndex == 1) {
        toName = @"国外";
    } else if (toIndex == 2) {
        toName = @"IPO";
    }  else if (toIndex == 3) {
        toName = @"并购";
    }
    [QMPEvent event:@"tab_home_recent_click" label:toName];
    [QMPEvent beginEvent:@"tab_home_recent_timer" attributes:@{@"name":toName}];
    
    NSString *fromName;
    if (fromIndex == 0) {
        fromName = @"国内";
    } else if (fromIndex == 1) {
        fromName = @"国外";
    } else if (fromIndex == 2) {
        fromName = @"IPO";
    } else if (fromIndex == 4) {
        fromName = @"并购";
    }
    [QMPEvent endEvent:@"tab_home_recent_timer" attributes:@{@"name":toName}];
}

- (UIView*)topHeaderView{
    
    if (!_topHeaderView) {
        _topHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, HomeHeaderViewBgHeight+HomeHeaderMetaViewHeight)];
        
        _topHeaderView.backgroundColor = HTColorFromRGB(0xf5f8fa);
        
        UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [_topHeaderView addGestureRecognizer:panGest];
    }
    
    return _topHeaderView;
}
- (void)pan:(UIPanGestureRecognizer *)panGest {
}

- (UIView*)stopView{
    if (!_stopView) {
        
        _stopView = [[UIView alloc]initWithFrame:CGRectMake(0,  CGRectGetMaxY(self.topHeaderView.frame), SCREENW, PageMenuH)];
        _stopView.backgroundColor = [UIColor whiteColor];
        
        [_stopView addSubview:self.pageMenu];
    }
    return _stopView;
}
- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        CGFloat left = SCREENW > 375 ? 13:5;
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(-left, 0, SCREENW+left*2, PageMenuH) trackerStyle:SPPageMenuTrackerStyleLine];
        CGFloat fontSize = 15 ;
        _pageMenu.itemTitleFont = [UIFont systemFontOfSize:fontSize];
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = BLUE_TITLE_COLOR;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = self.scrollView;

        [_pageMenu setItems:@[@"国内融资",@"国外融资",@"IPO上市",@"并购事件"] selectedItemIndex:0];
        
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        _pageMenu.delegate = self;
        for (UIView *subV in _pageMenu.subviews) {
            if ([subV isKindOfClass:NSClassFromString(@"SPPageMenuLine")]) {
                subV.hidden = YES;
                UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, PageMenuH-0.5, SCREENW+left*2, 1)];
                line.backgroundColor = HTColorFromRGB(0xEEEEEE);
                [_pageMenu insertSubview:line belowSubview:subV];
            }
        }
    }
    return _pageMenu;
}

-(UIScrollView *)scrollView{
    
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, SCREENW, SCREENH-kScreenBottomHeight);
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREENW*4, 0);
    }
    return _scrollView;
}


- (HomeHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[HomeHeaderView alloc] init];
        
        _headerView.frame = CGRectMake(0, 0, SCREENW, HomeHeaderViewBgHeight+HomeHeaderMetaViewHeight);
        _headerView.delegate = self;
    }
    return _headerView;
}
- (HomeNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [HomeNavigationBar navigationBarWithBarStyle:BarStyle_Clear];
        _navBar.searchBtn.hidden = YES;
        _navBar.tabbarIndex = 0;
    }
    return _navBar;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
#pragma mark - HomeHeaderViewDelegate
- (void)homeHeaderView:(HomeHeaderView *)view didScroll:(CGFloat)y {
    self.stopView.top = TOPHEIGHT+y;
    //    [self followScrollingScrollView:nil distanceY:-351-y];
    //    self.tableView.contentOffset = CGPointMake(0, -self.headerView.height-self.headerView.top);
    
    HomeBaseViewController *baseVc = nil;
    for (int i = 0; i < self.childViewControllers.count; i++) {
        baseVc = self.childViewControllers[i];
        
        CGPoint contentOffSet = baseVc.scrollView.contentOffset;
        contentOffSet.y = -351-y;
        baseVc.scrollView.contentOffset = contentOffSet;
        
    }
}

- (void)homeHeaderView:(HomeHeaderView *)view metaButtonClick:(UIButton *)button {
    NSString *title = [button currentTitle];
    
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    NSString *clickMenu = title;
    [QMPEvent event:@"tab_home_data_click" label:clickMenu];
    UINavigationController *navController = [PublicTool topViewController].navigationController;
    if ([clickMenu isEqualToString:@"机构库"]) {
        [QMPEvent event:@"home_jigouku_click"];
        QMPOrganizationLibraryViewController *vc = [[QMPOrganizationLibraryViewController alloc] init];
        [navController pushViewController:vc animated:YES];
        return;
    }else if ([clickMenu isEqualToString:@"项目库"]) {
        [QMPEvent event:@"home_proku_click"];
        HomeAllViewController *vc = [[HomeAllViewController alloc]init];
        [navController pushViewController:vc animated:YES];
        
        return;
    }else if ([title isEqualToString:@"投资机会"]) {
        // 认证限制
        if (![PublicTool userisClaimInvestor]) {
            if ([WechatUserInfo shared].claim_type.integerValue == 2) {
                [QMPEvent event:@"investchance_noclaim_alert"];
            }
            return;
        }
        InvestOpportunityViewController *vc = [[InvestOpportunityViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }else if ([clickMenu isEqualToString:@"融资统计"]) {
        [QMPEvent event:@"home_finaceStatisc_click"];
        FinanceReportController *reportVC = [[FinanceReportController alloc]init];
        [navController pushViewController:reportVC animated:YES];
        
        return;
    }else if ([clickMenu isEqualToString:@"项目专辑"]) {
        [QMPEvent event:@"home_proAlbum_click"];
        ProductAlbumController *zhuanjiVC = [[ProductAlbumController alloc]init];
        [navController pushViewController:zhuanjiVC animated:YES];
        [QMPEvent event:@"trz_bangdan_click"];
        return;
    }else if ([clickMenu isEqualToString:@"招股书"]) {
        [QMPEvent event:@"home_prospectus_click"];
        ProspectusListController *prospectusVC = [[ProspectusListController alloc]init];
        [navController pushViewController:prospectusVC animated:YES];
        [QMPEvent event:@"trz_prospectus_click"];
        
        return;
        
    }else if ([clickMenu isEqualToString:@"行研报告"]) {
        [QMPEvent event:@"home_report_click"];
        ReportController *vc = [[ReportController alloc] init];
        [navController pushViewController:vc animated:YES];
        return;
    }else if([clickMenu isEqualToString:@"极速找人"]) {
        // 认证限制
        if (![PublicTool userisCliamed]) {
            if ([WechatUserInfo shared].claim_type.integerValue != 1) {
                [QMPEvent event:@"proku_noclaim_alert"];
            }
            return;
        }
        [QMPEvent event:@"home_personku_click"];
        InvestorsListController *investorVC = [[InvestorsListController alloc]init];
        [navController pushViewController:investorVC animated:YES];
        return;
        
    } else if ([clickMenu isEqualToString:@"二级市场"]) {
        [QMPEvent event:@"home_secondMarket_click"];
        QMPSecondaryMarketViewController *vc = [[QMPSecondaryMarketViewController alloc] init];
        [navController pushViewController:vc animated:YES];
    } else if ([clickMenu isEqualToString:@"图谱"]) {
        [QMPEvent event:@"home_tupu_click"];
        QMPDataGraphViewController *vc = [[QMPDataGraphViewController alloc] init];
        [navController pushViewController:vc animated:YES];
    }
    
    
}

- (void)homeHeaderView:(HomeHeaderView *)view searchButtonClick:(UIButton *)button {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    MainSearchController *vc = [[MainSearchController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [QMPEvent event:@"tab_nabar_searchclick"];
}
@end
