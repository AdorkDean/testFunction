//
//  RecentEventController.m
//  qmp_ios
//
//  Created by QMP on 2019/1/28.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "RecentEventController.h"
#import <CommonLibrary/SPPageMenu.h>
#import <CommonLibrary/MainSearchController.h>
#import <CommonLibrary/HomeNavigationBar.h>
#import "Home3ViewController.h"
#import "Home5ViewController.h"
#import "Home6ViewController.h"
#import "HomeIPOViewController.h"


#define TOPHEIGHT (kStatusBarHeight+47+45+78) //47是搜索按钮以上的高度,45搜索高度
#define PageMenuH 40

@interface RecentEventController () <UIScrollViewDelegate, SPPageMenuDelegate> {
    NSInteger _selectIndex;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SPPageMenu *pageMenu;


@end

@implementation RecentEventController

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

    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self setUI];
}

- (void)setUI{
    
    [self.view addSubview:self.scrollView];
    
    [self addChildViewContollers];
}
- (void)addChildViewContollers{
    NSArray *arr = @[@"融资",@"国外",@"IPO",@"并购"];
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
        }
        vc.headerHeight = 351;
        if ([arr indexOfObject:str] == 0) {
            vc.view.frame = CGRectMake(SCREENW*[arr indexOfObject:str], 0, SCREENW, _scrollView.height);
        }
        [self addChildViewController:vc];
        [self.scrollView addSubview:vc.view];
    }
}


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

@end
