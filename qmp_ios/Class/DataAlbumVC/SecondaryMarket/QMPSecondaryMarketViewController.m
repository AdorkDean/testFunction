//
//  QMPSecondaryMarketViewController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/9/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPSecondaryMarketViewController.h"
#import "SPPageMenu.h"
#import "GestureScrollView.h"
#import "QMPIPOLibraryViewController.h"
#import "QMPIPOLibrarySearchViewController.h"
@interface QMPSecondaryMarketViewController () <SPPageMenuDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) SPPageMenu *pageMenu;
@property (nonatomic, strong) GestureScrollView *scrollView;

@property (nonatomic, strong) QMPIPOLibraryViewController *ipoLibraryVc;

@property (nonatomic, strong) UIBarButtonItem *filterItem;
@property (nonatomic, strong) UIBarButtonItem *filterBlueItem;
@property (nonatomic, strong) UIBarButtonItem *searchItem;
@end

@implementation QMPSecondaryMarketViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.scrollView];
//    self.navigationItem.titleView = self.pageMenu;
    
    self.navigationItem.title = @"二级市场";
    [self.scrollView addSubview:self.ipoLibraryVc.view];
    [self addChildViewController:self.ipoLibraryVc];

    
    self.searchItem.imageInsets = UIEdgeInsetsMake(0, 16, 0, -16);

    
    UIBarButtonItem *item = self.ipoLibraryVc.filterFlag ? self.filterBlueItem : self.filterItem;
    self.navigationItem.rightBarButtonItems = @[item, self.searchItem];

}

- (void)refreshNavbarFilterShow {
    BOOL flag = self.ipoLibraryVc.filterFlag;
    UIBarButtonItem *item = flag ? self.filterBlueItem : self.filterItem;
    self.navigationItem.rightBarButtonItems = @[item, self.searchItem];
}
#pragma mark - Event
- (void)filterItemClick {
    [self.ipoLibraryVc showFilterView];

//    if (self.pageMenu.selectedItemIndex == 0) {
//        [self.ipoQueueVc showFilterView];
//    } else {
//        [self.ipoLibraryVc showFilterView];
//    }
}
- (void)searchItemClick {
    
    QMPIPOLibrarySearchViewController *vc = [[QMPIPOLibrarySearchViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)changeNavbarRightItem {
    [self refreshNavbarFilterShow];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self changeNavbarRightItem];
}
#pragma mark - SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [self.scrollView setContentOffset:CGPointMake(SCREENW*toIndex, 0) animated:YES];
    
    [self changeNavbarRightItem];
}

#pragma mark - Getter
- (SPPageMenu *)pageMenu {
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, 200, 44) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        if (SCREENW == 320) {
            _pageMenu.itemTitleFont = [UIFont systemFontOfSize:12];
            _pageMenu.itemPadding = 20;
        }
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollEqualWidths;
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        _pageMenu.bridgeScrollView = self.scrollView;
        [_pageMenu setItems:@[@"IPO排队",@"上市库"] selectedItemIndex:0];
        _pageMenu.delegate = self;
    }
    return _pageMenu;
}
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[GestureScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight);
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREENW*1, SCREENH-kScreenTopHeight);
    }
    return _scrollView;
}

- (QMPIPOLibraryViewController *)ipoLibraryVc {
    if (!_ipoLibraryVc) {
        _ipoLibraryVc = [[QMPIPOLibraryViewController alloc] init];
        _ipoLibraryVc.view.frame = CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight);
    }
    return _ipoLibraryVc;
}
- (UIBarButtonItem *)filterItem {
    if (!_filterItem) {
        UIImage *image = [UIImage imageNamed:@"nav_filter_gray"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _filterItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(filterItemClick)];
    }
    return _filterItem;
}
- (UIBarButtonItem *)filterBlueItem {
    if (!_filterBlueItem) {
        UIImage *image = [UIImage imageNamed:@"nav_filter_blue"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _filterBlueItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(filterItemClick)];
    }
    return _filterBlueItem;
}
- (UIBarButtonItem *)searchItem {
    if (!_searchItem) {
        UIImage *image = [UIImage imageNamed:@"nav_search_icon"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _searchItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClick)];
    }
    return _searchItem;
}
@end
