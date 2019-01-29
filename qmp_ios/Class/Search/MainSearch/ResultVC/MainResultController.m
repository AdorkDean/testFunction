//
//  MainResultController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MainResultController.h"
#import "SPPageMenu.h"
#import "AllResultController.h"
#import "ProductResultController.h"
#import "JigouResultController.h"
#import "PersonResultController.h"
#import "BaseResultController.h"
#import "ReportResultController.h"
#import "CompanyResultController.h"
#import "NewsResultController.h"

@interface MainResultController ()<UIScrollViewDelegate,SPPageMenuDelegate>{
    
    NSInteger _selectIndex;
    UISearchBar *_mySearchBar;
    UIButton *_cancleSearchBtn;
}

@property (copy, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) SPPageMenu *pageMenu;
@property(nonatomic,strong)UIView *searchView;
@property(nonatomic,strong)NSMutableArray *newsArr;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)NSArray *menuTitles;

@end

@implementation MainResultController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
    
    if (@available(iOS 11.0, *)) {
        
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
   
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

- (void)resetPosition{
    [self.pageMenu setSelectedItemIndex:0];
}


- (void)setUI{
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, SCREENW, SCREENH - kScreenTopHeight-45)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.bounces = NO;
    _scrollView.scrollEnabled = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    _scrollView.contentSize = CGSizeMake(SCREENW * 7, 0);
    [self.view addSubview:_scrollView];
    
    __weak typeof(self) wf = self;
    // 添加4个子控制器
    AllResultController *firstVc = [[AllResultController alloc] init];
    firstVc.clickAllJigou = ^{
        [wf.pageMenu setSelectedItemIndex:[self.menuTitles indexOfObject:@"机构"]];
    };
    firstVc.clickAllPerson = ^{
        [wf.pageMenu setSelectedItemIndex:[self.menuTitles indexOfObject:@"人物"]];
    };
    firstVc.clickAllProduct = ^{
        [wf.pageMenu setSelectedItemIndex:[self.menuTitles indexOfObject:@"项目"]];
    };
    firstVc.clickAllRegist  = ^{
        [wf.pageMenu setSelectedItemIndex:[self.menuTitles indexOfObject:@"公司"]];
    };
    firstVc.clickAllNews   = ^{
        [wf.pageMenu setSelectedItemIndex:[self.menuTitles indexOfObject:@"新闻"]];
    };
    firstVc.view.frame = CGRectMake(0, 0, SCREENW, _scrollView.height);
    firstVc.searchType = SearchType_All;
    [self addChildViewController:firstVc];
    
    
    ProductResultController *secondVc = [[ProductResultController alloc] init];
    secondVc.searchType = SearchType_Product;
    [self addChildViewController:secondVc];
    
    
    JigouResultController *thirdVC = [[JigouResultController alloc] init];
    thirdVC.searchType = SearchType_Jigou;
    [self addChildViewController:thirdVC];
    
    PersonResultController *fourVC = [[PersonResultController alloc] init];
    fourVC.searchType = SearchType_Person;
    [self addChildViewController:fourVC];
    
    NewsResultController *fiveVC = [[NewsResultController alloc] init];
    fiveVC.searchType = SearchType_News;
    [self addChildViewController:fiveVC];
    
    CompanyResultController *sixVC = [[CompanyResultController alloc] init];
    sixVC.searchType = SearchType_Company;
    [self addChildViewController:sixVC];

    
    ReportResultController *sevenVC = [[ReportResultController alloc] init];
    sevenVC.searchType = SearchType_Report;
    [self addChildViewController:sevenVC];
    
    
    
    // 先将第一个子控制的view添加到scrollView上去
    [_scrollView addSubview:self.childViewControllers[0].view];

    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];
    
    [view addSubview:self.pageMenu];

    [self.view addSubview:view];
}


- (void)showVC:(NSInteger)index{
    
    BaseResultController *vc = self.childViewControllers[index];
    if (vc.isViewLoaded) {
        return;
    }
    else{
        CGFloat h = SCREENH - kScreenTopHeight-45;
        vc.view.frame = CGRectMake(SCREENW * index, 0, SCREENW , h);
        [_scrollView addSubview:vc.view];
    }
}


- (void)setKeyword:(NSString *)keyword{
    _keyword = [PublicTool isNull:keyword] ? @"" : keyword;
    for (BaseResultController *vc in self.childViewControllers) {
        vc.keyword = self.keyword;
    }
    [QMPEvent event:@"search_allresult_tabclick"];
}

#pragma mark ----EVENT---
- (void)selectedIndexPage:(NSInteger)index{
    [_scrollView setContentOffset:CGPointMake(SCREENW*index, 0) animated:YES];
}


- (void)refreshSelected{
    [self.view endEditing:YES];
}



#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView == _scrollView) {
        
        CGFloat currentW = SCREENW;
        CGFloat currentX = scrollView.contentOffset.x;
        NSInteger selectIndex = (currentX + 0.5 * currentW) /currentW;
        
        if (_selectIndex != selectIndex) {
            
            _selectIndex = selectIndex;
            [self refreshSelected];
            [QMPEvent event:@"mainsearch_resultkind_click" label:self.menuTitles[_selectIndex]];
           
            if  (_selectIndex == 0){
                [QMPEvent event:@"search_allresult_tabclick"];
            }else if (_selectIndex == 1) {
                [QMPEvent event:@"search_product_tabClick"];
            }else if(_selectIndex == 2){
                [QMPEvent event:@"search_jigou_tabClick"];
            }else if(_selectIndex == 3){
                [QMPEvent event:@"search_person_tabClick"];
            }else if(_selectIndex == 4){
                [QMPEvent event:@"search_company_tabClick"];

            }else if (_selectIndex == 5) {
                [QMPEvent event:@"search_report_click"];
            } else if (_selectIndex == 6) {
                [QMPEvent event:@"search_newstab_click,"];
            }
        }
    }
}


#pragma mark  mark - SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    _selectIndex = toIndex;
    [self refreshSelected];
    
    if (labs(toIndex - fromIndex) >= 2) {
        [_scrollView setContentOffset:CGPointMake(SCREENW*_selectIndex, 0) animated:NO];

    }else{
        [_scrollView setContentOffset:CGPointMake(SCREENW*_selectIndex, 0) animated:YES];

    }
    
    [self showVC:_selectIndex];
    
}


#pragma mark --- 懒加载--
- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {

        CGFloat x = 10;
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(x, 0, 360, 44.5) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = _scrollView;
        [_pageMenu setItems:self.menuTitles selectedItemIndex:0];
        _pageMenu.delegate = self;

        for (UIView *subV in _pageMenu.subviews) {
            if ([subV isKindOfClass:NSClassFromString(@"SPPageMenuLine")]) {
                [subV removeFromSuperview];
            }
        }
    }
    
    return _pageMenu;
}

-(NSArray *)menuTitles{
    if (!_menuTitles) {
        _menuTitles = @[@"全部",@"项目",@"机构",@"人物",@"新闻",@"公司",@"报告"];
    }
    return _menuTitles;
}
@end
