//
//  DiscoverTabController.m
//  qmp_ios
//
//  Created by QMP on 2018/10/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DiscoverTabController.h"
#import "DiscoverRecomendListController.h"
#import "DiscoverBannerView.h"
#import "PersonDetailsController.h"
#import "UnauthPeresonPageController.h"
#import "QMPDataGraphViewController.h"
#import "ReportController.h"
#import "NewsWebViewController.h"
#import "ManagerSquareViewController.h"
#import "SearchCreateProductViewController.h"
#import "FinanceSearchComController.h"
#import "QMPCreateMoreView.h"

@interface DiscoverTabController ()

@property (nonatomic, strong) DiscoverBannerView *bannerView;
@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) NSArray *bannerList;

@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, strong) NSArray *musicCategories;

@property (nonatomic, strong) MJRefreshGifHeader *gifHeader;

@property (nonatomic, strong) UIButton *createButton;
@end

@implementation DiscoverTabController
- (instancetype)init {
    if (self = [super init]) {
        
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.progressColor = BLUE_TITLE_COLOR;
        self.progressWidth = 20;
        self.titleColorSelected = PageMenuTitleSelectColor;
        self.titleColorNormal = PageMenuTitleUnSelectColor;
        self.menuViewStyle = WMMenuViewStyleLine;
        self.menuViewLayoutMode = WMMenuViewLayoutModeLeft;
        //        self.menuItemWidth = [UIScreen mainScreen].bounds.size.width; // self.musicCategories.count;
        self.automaticallyCalculatesItemWidths = YES;
        self.itemsMargins = @[@(16),@(25),@(25),@(25),@(0)];
        self.menuViewHeight = 44;
        self.maximumHeaderViewHeight = ceilf(SCREENW*34.0/75.0)+10;//SCREENW
        self.minimumHeaderViewHeight = 0;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = TABLEVIEW_COLOR;
    
    self.menuView.backgroundColor = [UIColor whiteColor];
    self.menuView.delegate = self;
    
    self.progressWidth = 20;
    
    self.menuView.progressView.backgroundColor = H568COLOR;
    self.menuView.progressViewCornerRadius = 1;
    
    //    self.menuView.rightView = self.createButton;
//    [self.menuView addSubview:self.createButton];
    
    [self.view addSubview:self.headerView];
    
    UIScrollView *scrollView = (UIScrollView *)self.view;
    scrollView.mj_header = self.gifHeader;
    [self.gifHeader setRefreshingTarget:self refreshingAction:@selector(refresh)];
    
    /// 监听进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroud:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self requestBanner];
}

- (void)refresh {
    
    UIViewController *currentVC = self.currentViewController;
    
    DiscoverRecomendListController *vc = (DiscoverRecomendListController *)currentVC;
    vc.currentPage = 1;
    [vc requestData];
}

#pragma mark --网络请求--
- (void)requestBanner{
    
    [AppNetRequest getBannerListWithParameter:@{} completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && resultData[@"list"]) {
            self.bannerList = resultData[@"list"];
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in self.bannerList) {
                [arr addObject:dic[@"img_src"]];
            }
            
            self.bannerView.dataSource = arr;
            
        }else{
            
            self.bannerView.dataSource = @[[UIImage imageFromColor:TABLEVIEW_COLOR andSize:self.bannerView.size]];
        }
        
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    if (scrollView.contentOffset.y < 0) {
        [self.view setNeedsLayout];
    }
}

#pragma mark - Event
- (void)enterForegroud:(NSNotification *)noit{
    [self requestBanner];
}

- (void)enterPersonPage{
    if (![ToLogin isLogin]) {
        return;
    }
    if ([WechatUserInfo shared].claim_type.integerValue == 2 && ![PublicTool isNull:[WechatUserInfo shared].person_id]) {
        PersonDetailsController *detailVC = [[PersonDetailsController alloc]init];
        detailVC.persionId = [WechatUserInfo shared].person_id;
        [[PublicTool topViewController].navigationController pushViewController:detailVC animated:YES];
        return;
        
    }
    
    UnauthPeresonPageController *personPage = [[UnauthPeresonPageController alloc]init];
    personPage.unionid = [WechatUserInfo shared].unionid;
    [[PublicTool topViewController].navigationController pushViewController:personPage animated:YES];
}

- (void)enterAlbum{
    
    ManagerSquareViewController *squareVC = [[ManagerSquareViewController alloc]init];
    [[PublicTool topViewController].navigationController pushViewController:squareVC animated:YES];
}

- (void)enterHapMap{
    QMPDataGraphViewController *mapVC = [[QMPDataGraphViewController alloc] init];
    [[PublicTool topViewController].navigationController pushViewController:mapVC animated:YES];
    
}

- (void)enterReportList{
    ReportController *reportVC = [[ReportController alloc]init];
    [[PublicTool topViewController].navigationController pushViewController:reportVC animated:YES];
}


- (void)bannerClick:(NSInteger)index{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    if (_bannerList.count) {
        NSDictionary *dic = _bannerList[index];
        NSInteger type = [dic[@"banner_type"] integerValue] ;
        switch (type) {
            case 6:{  //内链
                if ([dic[@"content"] isEqualToString:@"activity_giveData"]) {
                    
                    //                    [self enterChatVC:dic];
                }else if([dic[@"content"] isEqualToString:@"report"]){ // 报告
                    [self enterReportList];
                }else if([dic[@"content"] isEqualToString:@"hapmap"]){ //图谱
                    [self enterHapMap];
                }else if([dic[@"content"] isEqualToString:@"album"]){ //专辑
                    [self enterAlbum];
                }else if([dic[@"content"] isEqualToString:@"personPage"]){ //个人页
                    [self enterPersonPage];
                }
                [QMPEvent event:@"BannerClickValue" attributes:@{@"type":@(type),@"value":dic[@"content"]}];
                
                break;
            }
                
            case 5:{  //外链
                
                URLModel *model = [[URLModel alloc]init];
                model.url = dic[@"content"];
                NewsWebViewController *webVC = [[NewsWebViewController alloc]initWithUrlModel:model];
                [[PublicTool topViewController].navigationController pushViewController:webVC animated:YES];
                [QMPEvent event:@"BannerClickValue" attributes:@{@"type":@(type),@"value":dic[@"content"]}];
                
                break;
            }
            case 1:{ //项目
                NSString *detail = dic[@"link"];
                if (![PublicTool isNull:detail]) {
                    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:detail]];
                }
                [QMPEvent event:@"BannerClickValue" attributes:@{@"type":@(type),@"value":detail}];
                
                break;
            }
                
            case 2:{ //机构
                NSString *detail = dic[@"link"];
                if (![PublicTool isNull:detail]) {
                    NSDictionary *urlDic = [PublicTool toGetDictFromStr:detail];
                    [[AppPageSkipTool shared] appPageSkipToJigouDetail:urlDic];

                }
                [QMPEvent event:@"BannerClickValue" attributes:@{@"type":@(type),@"value":detail}];
                
                break;
            }
                
            default:
                break;
        }
    }
}


#pragma mark - ScrollViewDelegate
- (CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
    return [super menuView:menu widthForItemAtIndex:index];
}
- (CGFloat)menuView:(WMMenuView *)menu itemMarginAtIndex:(NSInteger)index {
    return [super menuView:menu itemMarginAtIndex:index];
}

#pragma mark - Datasource & Delegate
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.musicCategories.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    
    DiscoverRecomendListController *hotVC = [[DiscoverRecomendListController alloc] init];
    __weak typeof(self) weakSelf = self;
    hotVC.refreshComplated = ^{
        [weakSelf.gifHeader endRefreshing];
    };
    
    switch (index) {
        case 0:{
            hotVC.attentType = AttentType_Subject;
            return hotVC;
            
        }
        case 1:{
            hotVC.attentType = AttentType_Product;
            return hotVC;
        }
        
        case 2:{
            hotVC.attentType = AttentType_Person;
            return hotVC;
            
        }
        case 3:{
            hotVC.attentType = AttentType_Organization;
            return hotVC;
        }
        default:
            return [[UIViewController alloc]init];
    }
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.musicCategories[index];
}


#pragma mark - lazy
- (NSArray *)musicCategories {
    if (!_musicCategories) {
        _musicCategories = @[@"主题", @"项目", @"人物", @"机构"];
    }
    return _musicCategories;
}

- (MJRefreshGifHeader *)gifHeader {
    if (!_gifHeader) {
        NSMutableArray *images = [NSMutableArray array];
        for (int i = 1; i <= 65; i++) {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading%d",i]]];
        }
        _gifHeader = [[MJRefreshGifHeader alloc] init];
        _gifHeader.lastUpdatedTimeLabel.hidden = YES;
        _gifHeader.stateLabel.hidden=YES;
        
        [_gifHeader setImages:@[[UIImage imageNamed:@"loading1"]] duration:1 forState:MJRefreshStateIdle];
        [_gifHeader setImages:@[[UIImage imageNamed:@"loading1"]] duration:1 forState:MJRefreshStatePulling];
        [_gifHeader setImages:images duration:0.8 forState:MJRefreshStateRefreshing];
    }
    return _gifHeader;
}

- (UIView*)headerView{
    
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW,ceilf(SCREENW*34.0/75.0)+10)];
        _headerView.backgroundColor = TABLEVIEW_COLOR;
        
        [_headerView addSubview:self.bannerView];
    }
    
    return _headerView;
}

- (DiscoverBannerView *)bannerView {
    if (!_bannerView) {
        __weak typeof(self) weakSelf = self;
        DiscoverBannerView *bannerView = [[DiscoverBannerView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, ceilf(SCREENW*34.0/75.0)) didSelectedIndex:^(NSInteger index) {
            [weakSelf bannerClick:index];
        }];
        bannerView.backgroundColor = [UIColor whiteColor];
        _bannerView = bannerView;
    }
    return _bannerView;
}
- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [[UIButton alloc] init];
        _createButton.frame = CGRectMake(SCREENW-38, 2, 38, 38);
        [_createButton setImage:[UIImage imageNamed:@"data_create"] forState:UIControlStateNormal];
        [_createButton addTarget:self action:@selector(haha) forControlEvents:UIControlEventTouchUpInside];
        _createButton.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 6);
    }
    return _createButton;
}
- (void)haha {
    QMPCreateMoreView *view = [[QMPCreateMoreView alloc] init];
    [view show];
    view.createMoreViewItemClick = ^(NSString *title) {
        if (![ToLogin canEnterDeep]) {
            [ToLogin accessEnterDeep];
            return;
        }
        if ([title isEqualToString:@"创建项目"]) {
            SearchCreateProductViewController *editVC = [[SearchCreateProductViewController alloc] init];
            [[PublicTool topViewController].navigationController pushViewController:editVC animated:YES];
        } else if ([title isEqualToString:@"发布融资需求"]) {
            
            FinanceSearchComController *commenteditVC = [[FinanceSearchComController alloc]init];
            [[PublicTool topViewController].navigationController pushViewController:commenteditVC animated:YES];
        } else if ([title isEqualToString:@"披露融资事件"]) {
            [PublicTool contactKefu:@"你好客服，我有一条融资信息要曝光，请你帮我处理。" reply:@"好的，请您稍等，我们的客服人员会主动和您联系。"];
        }
    };
}
@end
