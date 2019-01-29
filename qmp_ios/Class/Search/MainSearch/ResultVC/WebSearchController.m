//
//  WebSearchController.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/23.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "WebSearchController.h"
#import "SPPageMenu.h"
#import "GestureScrollView.h"
#import "NewsWebViewController.h"

@interface WebSearchController ()<UIScrollViewDelegate,SPPageMenuDelegate>
{
    NSInteger _selectIndex;
}
@property(nonatomic,strong)SPPageMenu *pageMenu;
@property(nonatomic,strong)GestureScrollView *scrollView;

@end

@implementation WebSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addViews];
}

- (void)addViews{
    self.navigationItem.titleView = self.pageMenu;
    [self.view addSubview:self.scrollView];
    
    URLModel *baiduUrlM = [[URLModel alloc] init];
    baiduUrlM.url = [NSString stringWithFormat:@"https://m.baidu.com/s?word=%@",self.keyword];
    NewsWebViewController *baidu = [[NewsWebViewController alloc]initWithUrlModel:baiduUrlM];
    baidu.view.frame = CGRectMake(0, 0, SCREENW, self.scrollView.height);
    [self.scrollView addSubview:baidu.view];
    [self addChildViewController:baidu];
    
    
    URLModel *wechatUrlM = [[URLModel alloc] init];
    wechatUrlM.url = [NSString stringWithFormat:@"http://weixin.sogou.com/weixinwap?type=2&query=%@",self.keyword];
    NewsWebViewController *wechat = [[NewsWebViewController alloc]initWithUrlModel:wechatUrlM];
    [self addChildViewController:wechat];
    
    URLModel *zhihuUrlM = [[URLModel alloc] init];
    zhihuUrlM.url = [NSString stringWithFormat:@"http://zhihu.sogou.com/zhihuwap?query=%@",self.keyword];
    NewsWebViewController *zhihu = [[NewsWebViewController alloc]initWithUrlModel:zhihuUrlM];
    [self addChildViewController:zhihu];
    
    
    URLModel *weiboUrlM = [[URLModel alloc] init];
    weiboUrlM.url = [NSString stringWithFormat:@"https://s.weibo.com/weibo?q=%@",self.keyword];
    NewsWebViewController *weibo = [[NewsWebViewController alloc]initWithUrlModel:weiboUrlM];
    [self addChildViewController:weibo];
    
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
- (GestureScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[GestureScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.bounces = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        _scrollView.contentSize = CGSizeMake(SCREENW * 4, 0);
    }
    return _scrollView;
}

- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, 260, 44) trackerStyle:SPPageMenuTrackerStyleLine];

        CGFloat fontSize = 15 ;
        _pageMenu.itemTitleFont = [UIFont systemFontOfSize:fontSize];
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = BLUE_TITLE_COLOR;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = self.scrollView;
        _pageMenu.contentInset = UIEdgeInsetsMake(0, 4, 0, 2);
        
        [_pageMenu setItems:@[@"百度",@"微信",@"知乎",@"微博"] selectedItemIndex:0];
        
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        _pageMenu.delegate = self;
    }
    
    return _pageMenu;
}
@end
