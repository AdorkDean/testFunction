//
//  JoinInvestController.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/7.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "JoinInvestController.h"
#import "GestureScrollView.h"
#import "JointInvestmentListController.h"

@interface JoinInvestController ()<UIScrollViewDelegate,SPPageMenuDelegate>
{
    NSInteger _selectIndex;
    UISearchBar *_mySearchBar;
    UIButton *_cancleSearchBtn;
}
@property(nonatomic,strong) GestureScrollView *scrollView;
@property(nonatomic,strong)UIView *searchView;
@property (nonatomic, strong) SPPageMenu *pageMenu;
@property (nonatomic, strong) UIButton *uploadBtn;


@end

@implementation JoinInvestController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}



- (void)setUI{
    
    [self.view addSubview:self.scrollView];
    
    OrganizeCombineItem *model = [[OrganizeCombineItem alloc] init];
    model.name = self.organizeInfo.name;
    model.icon = self.organizeInfo.icon;
    model.detail = self.organizeInfo.detail;

    
    JointInvestmentListController * vc0 = [[JointInvestmentListController alloc] init];
    vc0.investType = InvestType_Together;
    vc0.model = model;
    vc0.urlDict = self.urlDic;
    vc0.view.frame = CGRectMake(0, 0, SCREENW, self.scrollView.height);
    [self.scrollView addSubview:vc0.view];
    [self addChildViewController:vc0];
    
    JointInvestmentListController * vc1 = [[JointInvestmentListController alloc] init];
    vc1.investType = InvestType_Join;
    vc1.model = model;
    vc1.urlDict = self.urlDic;
    [self addChildViewController:vc1];
    
    self.navigationItem.titleView = self.pageMenu;
}
- (void)showVC:(NSInteger)indx{
    if (self.childViewControllers.count) {
        BaseViewController * baseVC = self.childViewControllers[indx];
        if (![self.scrollView.subviews containsObject:baseVC.view]) {
            baseVC.view.frame = CGRectMake(indx * SCREENW, 0, SCREENW, self.scrollView.height);
            [self.scrollView addSubview:baseVC.view];
        }
    }
}

#pragma mark ----EVENT---
- (void)selectedIndexPage:(NSInteger)index{
    [_scrollView setContentOffset:CGPointMake(SCREENW*index, 0) animated:YES];
}


#pragma mark  mark - SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (fromIndex == toIndex) {
        return;
    }
    _selectIndex = toIndex;
    if (labs(toIndex - fromIndex) >= 2) {
        [_scrollView setContentOffset:CGPointMake(SCREENW*_selectIndex, 0) animated:NO];
    }else{
        [_scrollView setContentOffset:CGPointMake(SCREENW*_selectIndex, 0) animated:YES];
    }
    
    [self showVc:_selectIndex];
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
    [_scrollView addSubview:vc.view];
}

- (GestureScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[GestureScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.bounces = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        _scrollView.contentSize = CGSizeMake(SCREENW * 2, 0);
    }
    return _scrollView;
}

- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, 160*ratioWidth, 44) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        
        _pageMenu.delegate = self;
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = _scrollView;
        [_pageMenu setItems:@[@"合投",@"参投"] selectedItemIndex:0];
        _pageMenu.itemPadding = 40;
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        
    }
    return _pageMenu;
}

@end
