//
//  QMPCommunityController.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/24.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "QMPCommunityController.h"
#import "QMPCommunityListController.h"
#import "SPPageMenu.h"
#import "HomeNavigationBar.h"

@interface QMPCommunityController ()<UIScrollViewDelegate,SPPageMenuDelegate>
{
    NSInteger _selectIndex;
}

@property(nonatomic,strong)HomeNavigationBar *navSearchBar;
@property(nonatomic,strong)SPPageMenu *pageMenu;
@property(nonatomic,strong)UIScrollView *scrollView;

@property (nonatomic, assign) NSString *toGotagName;
@property (nonatomic, assign) NSString *toGoactivtyID;
@property (nonatomic, assign) BOOL needGo;

@end

@implementation QMPCommunityController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navSearchBar refreshMsdCount];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addViews];
}

- (void)addViews{
    [self.view addSubview:self.navSearchBar];

    [self.view addSubview:self.scrollView];
    
    QMPCommunityListController *userShareVC = [[QMPCommunityListController alloc]init];
    userShareVC.communityType = CommunityType_UserShare;
    userShareVC.view.frame = CGRectMake(0, 0, SCREENW, self.scrollView.height);
    [self addChildViewController:userShareVC];
    [self.scrollView addSubview:userShareVC.view];
    
    QMPCommunityListController *topicVC = [[QMPCommunityListController alloc]init];
    topicVC.communityType = CommunityType_Topic;
    [self addChildViewController:topicVC];
    
    __weak typeof(self) weakSelf = self;
    self.navSearchBar.addBtnClickEvent = ^{
        [weakSelf postBtnClick];
    };
}

#pragma mark --Event--
- (void)showToTag:(NSString*)tagName activityID:(NSString*)activityID{
    NSInteger index = [tagName containsString:@"用户分享"]?0:1;
    [self.pageMenu setSelectedItemIndex:index];
    _selectIndex = index;
    if (self.childViewControllers.count) {
        QMPCommunityListController *listVC = self.childViewControllers[_selectIndex];
        [listVC.tableView.mj_header beginRefreshing];
    }    
}

- (void)postBtnClick{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    QMPCommunityListController *listVC = self.childViewControllers[_selectIndex];
    [listVC postButtonClick];
}

- (void)msgBtnClick{
    
    [[AppPageSkipTool shared]appPageSkipToConversationList];
}
- (void)searchBtnClick{
    [[AppPageSkipTool shared] appPageSkipToMainSearch];
}

- (void)scrollTop {
    QMPCommunityListController *vc = (QMPCommunityListController *)self.childViewControllers[_selectIndex];
    [vc.tableView.mj_header beginRefreshing];
}


#pragma mark  mark - SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (fromIndex == toIndex) {
        return;
        
    }
    _selectIndex = toIndex;
    
    [self showVc:_selectIndex];
    
    if (labs(toIndex - fromIndex) >= 2) {
        [_scrollView setContentOffset:CGPointMake(SCREENW*_selectIndex, 0) animated:NO];
        
    }else{
        [_scrollView setContentOffset:CGPointMake(SCREENW*_selectIndex, 0) animated:YES];
        
    }
    
}

- (void)showVc:(NSInteger)index{
    if (self.childViewControllers.count <= 0) {
        return;
    }
    UIViewController *vc = self.childViewControllers[index];
    
    if (vc.isViewLoaded && [_scrollView.subviews containsObject:vc.view]) {
        return;
    }
    
    CGFloat h = SCREENH - kScreenTopHeight;
    vc.view.frame = CGRectMake(SCREENW * index, 0, SCREENW , h);
    [self.scrollView addSubview:vc.view];
}



#pragma mark -- 懒加载
- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kScreenTopHeight, SCREENW, SCREENH - kScreenTopHeight-kScreenBottomHeight)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREENW * 2, 0);
    }
    return _scrollView;
}

- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, kStatusBarHeight, 180, 44) trackerStyle:SPPageMenuTrackerStyleLine];
        
        CGFloat fontSize = 15 ;
        _pageMenu.itemTitleFont = [UIFont systemFontOfSize:fontSize];
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = BLUE_TITLE_COLOR;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = self.scrollView;
        _pageMenu.contentInset = UIEdgeInsetsMake(0, 4, 0, 2);
        
        [_pageMenu setItems:@[@"用户分享",@"话题讨论"] selectedItemIndex:0];
        
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        _pageMenu.delegate = self;
        for (UIView *subV in _pageMenu.subviews) {
            if ([subV isKindOfClass:NSClassFromString(@"SPPageMenuLine")]) {
                subV.hidden = YES;
            }
        }
    }
    
    return _pageMenu;
}

- (HomeNavigationBar *)navSearchBar{
    
    if (!_navSearchBar) {
        _navSearchBar = [HomeNavigationBar navigationBarWithBarStyle:BarStyle_White showAdd:YES];
        _navSearchBar.searchBtn.hidden = YES;

        //加上pageMenu
        [_navSearchBar addSubview:self.pageMenu];
        self.pageMenu.centerX = SCREENW/2.0;
        
        UIButton *searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, kStatusBarHeight, 46, 44)];
        [searchBtn setImage:[BundleTool imageNamed:@"community_search"] forState:UIControlStateNormal];
        [searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_navSearchBar addSubview:searchBtn];
        
    }    
    return _navSearchBar;
}

@end
