//
//  TabbarActivityViewController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/10/31.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "TabbarActivityViewController.h"
#import "HomeNavigationBar.h"
#import "QMPActivityCategoryViewController.h"

@interface TabbarActivityViewController () <SPPageMenuDelegate> {
    NSInteger _selectIndex;
}
@property (nonatomic, strong) HomeNavigationBar *topSearchView; //bar
@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) QMPActivityCategoryViewController *categoryVC;
@property (nonatomic, strong) SPPageMenu *pageMenu;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) UIButton *messageButton;


@property (nonatomic, strong) NSDate *leftTime;
@end

@implementation TabbarActivityViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (![ToLogin isLogin]) {
        return;
    }
    [self.topSearchView refreshMsdCount];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.leftTime = [NSDate date];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.leftTime == nil) {
        return;
    }
    if (-self.leftTime.timeIntervalSinceNow >= 600) {
    }
    
}
- (void)toSquare {
    
}

- (void)showToTag:(NSString*)tagName activityID:(NSString*)activityID{
    [self.categoryVC showToTag:tagName activityID:activityID];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:self.categoryVC];
    [self.view addSubview:self.categoryVC.view];
    [self.view addSubview:self.topSearchView];
    __weak typeof(self) weakSelf = self;
    self.topSearchView.addBtnClickEvent = ^{
        [weakSelf.categoryVC postButtonClick];
    };
    [QMPEvent beginEvent:@"tab_actitity_timer"];
}


- (HomeNavigationBar *)topSearchView{
    
    if (!_topSearchView) {
        _topSearchView = [HomeNavigationBar navigationBarWithBarStyle:BarStyle_White];
        _topSearchView.tabbarIndex = 1;
    }
    
    return _topSearchView;
}

- (QMPActivityCategoryViewController *)categoryVC {
    if (!_categoryVC) {
        _categoryVC = [[QMPActivityCategoryViewController alloc] init];
        _categoryVC.view.frame = CGRectMake(0, kScreenTopHeight, SCREENW, SCREENH - kScreenTopHeight);
    }
    return _categoryVC;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}





- (void)scrollTop {
    [self.categoryVC scrollTop];
}


@end
