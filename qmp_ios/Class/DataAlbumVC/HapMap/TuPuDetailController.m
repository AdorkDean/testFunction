//
//  TuPuDetailController.m
//  qmp_ios
//
//  Created by QMP on 2017/11/13.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "TuPuDetailController.h"
#import "HapMapAreaModel.h"
#import "StarProductsModel.h"
#import "ReportModel.h"
#import "HapMapTrendModel.h"
#import "HapMapTrendCell.h"
#import "HapMapActionJigouCell.h"
#import "HapMapProductController.h"
#import "HapMapTrendController.h"
#import "HapMapReportController.h"
#import "GestureScrollView.h"

@interface TuPuDetailController ()<UIScrollViewDelegate,SPPageMenuDelegate>
{
    NSInteger _selectIndex;
    dispatch_semaphore_t semaphore;
    NSMutableArray *_areaListArr;
    NSMutableArray *_groupArr;
    
    NSMutableArray *_productArr;
    NSMutableArray *_reportArr;
    NSMutableArray *_trendArr;
    NSMutableArray *_activeJigouArr;

    GestureScrollView *_scrollView;

}
@property(nonatomic,strong)DBHelper *dbHelper;
@property (strong, nonatomic) FMDatabase *db;
@property (nonatomic, strong) SPPageMenu *pageMenu;


@end

@implementation TuPuDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; 
    _areaListArr = [NSMutableArray array];
    _groupArr = [NSMutableArray array];
    _productArr = [NSMutableArray array];
    _reportArr = [NSMutableArray array];
    _trendArr = [NSMutableArray array];
    _activeJigouArr = [NSMutableArray array];
    
    self.currentPage = 1;
    self.numPerPage = 30;
    _db = [[DBHelper shared] toGetDB];
    
    self.title = [[self.tagStr componentsSeparatedByString:@"|"] lastObject];
    [self setUI];
    
    [self.pageMenu setSelectedItemIndex:self.position];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideNavigationBarLine];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self showNavigationBarLine];
}
#pragma mark --UI
- (void)setUI{
    
    _scrollView = [[GestureScrollView alloc] initWithFrame:CGRectMake(0, 44, SCREENW, SCREENH - kScreenTopHeight - 44)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.bounces = NO;
    _scrollView.scrollEnabled = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    _scrollView.contentSize = CGSizeMake(SCREENW * 3, 0);
    [self.view addSubview:_scrollView];
    
    [self.view addSubview:self.pageMenu];
    
    HapMapProductController *productVC = [[HapMapProductController alloc] init];
    productVC.tagStr = self.tagStr;
    productVC.view.frame = CGRectMake(SCREENW*0, 0, SCREENW ,_scrollView.height);
    [self addChildViewController:productVC];
    [_scrollView addSubview:productVC.view];

    
    
    HapMapTrendController *mapVC = [[HapMapTrendController alloc] init];
    mapVC.tagStr = self.tagStr;
    mapVC.view.frame = CGRectMake(SCREENW*1, 0, SCREENW , _scrollView.height);
    [_scrollView addSubview:mapVC.view];
    [self addChildViewController:mapVC];
    
    
    HapMapReportController *reportVC = [[HapMapReportController alloc] init];
    reportVC.tagStr = self.tagStr;
    reportVC.view.frame = CGRectMake(SCREENW*2, 0, SCREENW , _scrollView.height);
    [_scrollView addSubview:reportVC.view];
    [self addChildViewController:reportVC];
    

}

#pragma mark - SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {

    _selectIndex = toIndex;
    
    [self showVC:toIndex];
}

- (void)didSelectItemAtIndex:(NSInteger)index{
    
    if (_selectIndex == index) {
        return;
    }
    _selectIndex = index;
    
    [self showVC:index];
}

- (void)showVC:(NSInteger)index{
    
    [_scrollView setContentOffset:CGPointMake(SCREENW*index, 0) animated:YES];
   
}

#pragma mark - scrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView == _scrollView) {
        
        CGFloat currentW = SCREENW;
        CGFloat currentX = scrollView.contentOffset.x;
        NSInteger selectIndex = (currentX + 0.5 * currentW) /currentW;
        
        
        if (_selectIndex != selectIndex) {
            
            _selectIndex = selectIndex;
            NSArray *arr = [self.tagStr componentsSeparatedByString:@"|"];
            if (arr && arr.count == 2) {
                if (_selectIndex == 1) {
                    [QMPEvent event:@"trz_map_second_enterPro"];
                }else if(_selectIndex == 3){
                    [QMPEvent event:@"trz_map_second_enterRep"];
                }else if(_selectIndex == 2){
                    [QMPEvent event:@"trz_map_second_enterqushi"];
                }
            }
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, SCREENW, 44) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
       
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = _scrollView;

        [_pageMenu setItems:@[@"项目",@"趋势",@"研报"] selectedItemIndex:0];
        _pageMenu.delegate = self;
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        
    }
    return _pageMenu;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
