//
//  ProductAlbumController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/10/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductAlbumController.h"
#import "AlbumListController.h"
#import "GestureScrollView.h"
#import "AlbumSearchController.h"


@interface ProductAlbumController () <UIScrollViewDelegate, SPPageMenuDelegate>
@property (nonatomic, strong) GestureScrollView *scrollView;
@property (nonatomic, strong) SPPageMenu *pageMenu;
@end

@implementation ProductAlbumController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}
- (void)setupViews {
    
    CGFloat h = SCREENH - kScreenTopHeight;
    _scrollView = [[GestureScrollView alloc] initWithFrame:CGRectMake(0,0, SCREENW, h)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(SCREENW * 2, 0);
    [self.view addSubview:_scrollView];
    

    // 领域专辑
    AlbumListController *eneventVC = [[AlbumListController alloc] init];
    eneventVC.fieldAlbum = YES;
    eneventVC.view.frame = CGRectMake(0, 0, SCREENW , h);
    [self addChildViewController:eneventVC];
    [_scrollView addSubview:eneventVC.view];
    
    // 榜单专辑
    AlbumListController *actionFAVC = [[AlbumListController alloc] init];
    actionFAVC.view.frame = CGRectMake(SCREENW*1, 0, SCREENW ,h);
    [self addChildViewController:actionFAVC];
    [_scrollView addSubview:actionFAVC.view];
    
    self.navigationItem.titleView = self.pageMenu;
    
    UIImage *image = [UIImage imageNamed:@"nav_search_icon"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClick)];
    self.navigationItem.rightBarButtonItem = searchItem;
    
}

- (void)searchItemClick{
    AlbumSearchController *searchVC = [[AlbumSearchController alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
}
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    [_scrollView setContentOffset:CGPointMake(SCREENW*toIndex, 0) animated:YES];
    
}
- (SPPageMenu *)pageMenu {
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, 180*ratioWidth, 44) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = _scrollView;
        [_pageMenu setItems:@[@"领域专辑", @"榜单专辑"] selectedItemIndex:0];
        _pageMenu.delegate = self;
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        _pageMenu.itemPadding = 50*ratioWidth;
        
    }
    return _pageMenu;
}

@end
