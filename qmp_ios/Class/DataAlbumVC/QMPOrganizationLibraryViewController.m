//
//  QMPOrganizationLibraryViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/8/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPOrganizationLibraryViewController.h"
#import "ActiveFAController.h"
#import "ActiveJigouController.h"
#import "GestureScrollView.h"
@interface QMPOrganizationLibraryViewController () <UIScrollViewDelegate, SPPageMenuDelegate>
@property (nonatomic, strong) GestureScrollView *scrollView;
@property (nonatomic, strong) SPPageMenu *pageMenu;
@end

@implementation QMPOrganizationLibraryViewController

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
    

    
    // 活跃机构
    ActiveJigouController *eneventVC = [[ActiveJigouController alloc] init];
    eneventVC.view.frame = CGRectMake(SCREENW*0, 0, SCREENW , h);
    [self addChildViewController:eneventVC];
    [_scrollView addSubview:eneventVC.view];
    
    // 活跃FA
    ActiveFAController *actionFAVC = [[ActiveFAController alloc] init];
    actionFAVC.isFA = YES;
    actionFAVC.view.frame = CGRectMake(SCREENW*1, 0, SCREENW ,h);
    [self addChildViewController:actionFAVC];
    [_scrollView addSubview:actionFAVC.view];
    
    self.navigationItem.titleView = self.pageMenu;
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
        [_pageMenu setItems:@[@"活跃机构", @"活跃FA"] selectedItemIndex:0];
        _pageMenu.delegate = self;
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        _pageMenu.itemPadding = 50*ratioWidth;
        
    }
    return _pageMenu;
}
@end
