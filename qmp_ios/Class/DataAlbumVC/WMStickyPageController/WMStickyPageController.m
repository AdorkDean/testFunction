//
//  WMStickyPageViewController.m
//  StickyExample
//
//  Created by Tpphha on 2017/7/22.
//  Copyright © 2017年 Tpphha. All rights reserved.
//

#import "WMStickyPageController.h"
#import "WMMagicScrollView.h"
#import <MJRefresh.h>
@interface WMStickyPageController () <WMMagicScrollViewDelegate>

@property(nonatomic, strong) WMMagicScrollView *contentView;

@property (nonatomic, strong) MJRefreshGifHeader *gifHeader;
@end

@implementation WMStickyPageController
@dynamic delegate;

#pragma mark - Life Cycle
- (void)loadView {
    self.contentView.frame = [UIScreen mainScreen].bounds;
    self.contentView.frame = CGRectMake(0, kScreenTopHeight, SCREENW, SCREENH-kScreenTopHeight-kScreenBottomHeight);
    self.view = self.contentView;
    
    self.contentView.backgroundColor = TABLEVIEW_COLOR;
//    self.contentView.mj_header = self.gifHeader;
//    [self.gifHeader setRefreshingTarget:self refreshingAction:@selector(refresh)];
}
- (void)refresh {
    
    if ([self.delegate conformsToProtocol:@protocol(WMStickyPageControllerDelegate)]) {
        id<WMStickyPageControllerDelegate> delegate = (id<WMStickyPageControllerDelegate>)self.delegate;
        if ([delegate respondsToSelector:@selector(pageController:scrollViewRefresh:)]) {
            [delegate pageController:self scrollViewRefresh:@""];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.gifHeader endRefreshing];
        
    });
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.contentView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds),
                                              CGRectGetHeight(self.view.bounds) +
                                              self.maximumHeaderViewHeight);
    
    
}

#pragma mark - WMMagicScrollViewDelegate

- (BOOL)scrollView:(WMMagicScrollView *)scrollView shouldScrollWithSubview:(UIScrollView *)subview {
    
    if ([subview isKindOfClass:WMScrollView.class]) {
        return NO;
    }
//    NSLog(@"scr:%f",scrollView.contentOffset.y);
//    if ([subview isKindOfClass:UITableView.class]) {
//        return NO;
//    }
    
    
    if ([self.delegate conformsToProtocol:@protocol(WMStickyPageControllerDelegate)]) {
        id<WMStickyPageControllerDelegate> delegate = (id<WMStickyPageControllerDelegate>)self.delegate;
        if ([delegate respondsToSelector:@selector(pageController:shouldScrollWithSubview:)]) {
            return [delegate pageController:self shouldScrollWithSubview:subview];
        }
    }
    
    return YES;
}

#pragma mark - WMPageControllerDataSource

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    CGFloat originY = self.maximumHeaderViewHeight;
    if (originY <= 0) {
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        originY = (self.showOnNavigationBar && navigationBar) ? 0 : CGRectGetMaxY(navigationBar.frame);
    }
    return CGRectMake(0, originY, CGRectGetWidth( self.view.frame), self.menuViewHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGRect preferredFrameForMenuView = [self pageController:pageController preferredFrameForMenuView:pageController.menuView];
    UITabBar *tabBar = self.tabBarController.tabBar;
    CGFloat tabBarHeight = tabBar && !tabBar.hidden ? CGRectGetHeight(tabBar.frame) : 0;
    return CGRectMake(0,
                      CGRectGetMaxY(preferredFrameForMenuView),
                      CGRectGetWidth(preferredFrameForMenuView),
                      CGRectGetHeight(self.view.frame) -
                      self.minimumHeaderViewHeight -
                      CGRectGetHeight(preferredFrameForMenuView) -
                      tabBarHeight);
    
}

#pragma mark - setter & getter

- (WMMagicScrollView *)contentView {
    if (!_contentView) {
        _contentView = [WMMagicScrollView new];
        _contentView.delegate = self;
    }
    return _contentView;
}

- (void)setMinimumHeaderViewHeight:(CGFloat)minimumHeaderViewHeight {
    self.contentView.minimumHeaderViewHeight = minimumHeaderViewHeight;
}

- (CGFloat)minimumHeaderViewHeight {
    return self.contentView.minimumHeaderViewHeight;
}

- (void)setMaximumHeaderViewHeight:(CGFloat)maximumHeaderViewHeight {
    self.contentView.maximumHeaderViewHeight = maximumHeaderViewHeight;
}

- (CGFloat)maximumHeaderViewHeight {
    return self.contentView.maximumHeaderViewHeight;
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
        [_gifHeader setImages:images duration:1.3 forState:MJRefreshStateRefreshing];
    }
    return _gifHeader;
}
@end

