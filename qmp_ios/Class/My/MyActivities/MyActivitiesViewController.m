//
//  MyActivitiesViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/7/11.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MyActivitiesViewController.h"
#import "GestureScrollView.h"
#import "MyActivityListViewController.h"
#import "SPPageMenu.h"
#import "PostActivityViewController.h"
@interface MyActivitiesViewController () <UIScrollViewDelegate, SPPageMenuDelegate>
@property (nonatomic, strong) GestureScrollView *scrollView;
@property (nonatomic, strong) SPPageMenu *pageMenu;
@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, weak) MyActivityListViewController *allVC;
@end

@implementation MyActivitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
 
//    UIButton *noteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 53, 53)];
//    [noteBtn setImage:[UIImage imageNamed:@"me_activityEdit"] forState:UIControlStateNormal];
//    [noteBtn addTarget:self action:@selector(noteBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:noteBtn];
//    
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    negativeSpacer.width = RIGHTNVSPACE;
//    if (iOS11_OR_HIGHER) {
//        
//        noteBtn.width = 30;
//        noteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:noteBtn];
//        
//        self.navigationItem.rightBarButtonItems = @[buttonItem];
//    } else {
//        
//        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:noteBtn];
//        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,buttonItem];
//    }
}

- (void)setupViews {
    [self.view addSubview:self.scrollView];
    
    MyActivityListViewController *allVC = [[MyActivityListViewController alloc] init];
    allVC.type = MyActivityListViewControllerTypePublic;
    allVC.view.frame = CGRectMake(0, 0, SCREENW , self.scrollView.height);
    [self addChildViewController:allVC];
    [self.scrollView addSubview:allVC.view];
    self.allVC = allVC;
    
//    MyActivityListViewController *publicVC = [[MyActivityListViewController alloc] init];
//    publicVC.type = MyActivityListViewControllerTypePublic;
//    publicVC.view.frame = CGRectMake(0, 0, SCREENW , self.scrollView.height);
//    [self addChildViewController:publicVC];
    
//    MyActivityListViewController *anonymousVC = [[MyActivityListViewController alloc] init];
//    anonymousVC.type = MyActivityListViewControllerTypeAnonymous;
//    [self addChildViewController:anonymousVC];
    
//    MyActivityListViewController *noteVC = [[MyActivityListViewController alloc] init];
//    noteVC.type = MyActivityListViewControllerTypeNote;
//    [self addChildViewController:noteVC];
    
    self.navigationItem.title = @"我的发布";
}
- (void)noteBtnClick {
    if (![PublicTool userisCliamed]) {
        return;
    }
    PostActivityViewController *vc = [[PostActivityViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
    __weak typeof(self) weakSelf = self;
    vc.postSuccessBlock = ^{
        [weakSelf.allVC refreshData];
    };
}
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    self.selectIndex = toIndex;
    
    if (labs(toIndex - fromIndex) >= 2) {
        [self.scrollView setContentOffset:CGPointMake(SCREENW*self.selectIndex, 0) animated:NO];
        
    }else{
        [self.scrollView setContentOffset:CGPointMake(SCREENW*self.selectIndex, 0) animated:YES];
        
    }
    
    [self showVc:self.selectIndex];
    
}


- (void)showVc:(NSInteger)index{
    
    if (self.childViewControllers.count <= 0) {
        return;
    }
    UIViewController *vc = self.childViewControllers[index];
    
    if (vc.isViewLoaded && [self.scrollView.subviews containsObject:vc.view]) {
        return;
    }
    
    CGFloat h = SCREENH - kScreenTopHeight - 45;
    vc.view.frame = CGRectMake(SCREENW * index, 0, SCREENW , h);
    [self.scrollView addSubview:vc.view];
    
}
- (GestureScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[GestureScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.bounces = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        _scrollView.contentSize = CGSizeMake(SCREENW * 1, 0);
    }
    return _scrollView;
}
- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, 150*ratioWidth, 44) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        
        _pageMenu.delegate = self;
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = self.scrollView;
        [_pageMenu setItems:@[@"公开", @"匿名"] selectedItemIndex:0];
        _pageMenu.itemPadding = 40;
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        
    }
    return _pageMenu;
}
@end
