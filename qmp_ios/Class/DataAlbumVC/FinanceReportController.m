//
//  FinanceReportController.m
//  qmp_ios
//
//  Created by QMP on 2018/7/20.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "FinanceReportController.h"
#import "GestureScrollView.h"
#import "WebViewController.h"
#import "LrdOutputView.h"

@interface FinanceReportController ()<UIScrollViewDelegate,LrdOutputViewDelegate,SPPageMenuDelegate>
{
    LrdOutputView *_outputView;
    NSInteger _selectIndex;
    NSArray *_moreOptionsArr;
}
@property(nonatomic,strong)GestureScrollView *scrollView;
@property(nonatomic,strong)UISegmentedControl *segment;
@property(nonatomic,strong)SPPageMenu *pageMenu;



@end

@implementation FinanceReportController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    [QMPEvent event:@"trz_rztongji_click"];
}



- (void)setUI{
    
    _scrollView = [[GestureScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.scrollEnabled = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(SCREENW * 2, 0);
    [self.view addSubview:_scrollView];
    
    WebViewController *VC = [[WebViewController alloc]init];
    VC.url = RONGZIXINWEN_BASE;
    VC.titleLabStr = @"融资日报";
    VC.view.frame = CGRectMake(0, 0, SCREENW, _scrollView.height);
    [self addChildViewController:VC];
    [_scrollView addSubview:VC.view];
    
    
    
    WebViewController *weekVC = [[WebViewController alloc]init];
    weekVC.url = RONGZIZHOUBAO_NEWS;
    weekVC.titleLabStr = @"融资周报";
    weekVC.view.frame = CGRectMake(SCREENW, 0, SCREENW, _scrollView.height);
    [self addChildViewController:weekVC];
    [_scrollView addSubview:weekVC.view];
    
    self.navigationItem.titleView = self.pageMenu;
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = RIGHTNVSPACE;
    UIButton * moreBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
    [moreBtn setImage:[UIImage imageNamed:@"nav_right_more"] forState:UIControlStateNormal];
    if (iOS11_OR_HIGHER) {
        [moreBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    }
    [moreBtn addTarget:self action:@selector(moreOptions:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreBtn];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,moreItem];
    
}



- (void)moreOptions:(UIButton *)sender{
    
    CGFloat x = SCREENW - 10;
    CGFloat y = kScreenTopHeight + 10;
    
    //更多选项数据源
    LrdCellModel *shareModel = [[LrdCellModel alloc] initWithTitle:@"分享" imageName:@"web_share"];
    LrdCellModel *captureScreenModel = [[LrdCellModel alloc] initWithTitle:@"截图分享" imageName:@"captureScreen_more1"];
    LrdCellModel *refreshModel = [[LrdCellModel alloc] initWithTitle:@"刷新" imageName:@"update_more"];
    _moreOptionsArr = @[shareModel,captureScreenModel,refreshModel];
    
    
    _outputView = [[LrdOutputView alloc] initWithDataArray:_moreOptionsArr origin:CGPointMake(x, y) width:165 height:44 direction:kLrdOutputViewDirectionRight ofAction:@"moreOptions" hasImg:YES];
    
    _outputView.delegate = self;
    _outputView.dismissOperation = ^(){
        //设置成nil，以防内存泄露
        _outputView = nil;
    };
    [_outputView pop];
}


#pragma mark --SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [self.scrollView setContentOffset:CGPointMake(SCREENW*toIndex, 0) animated:YES];
    
    if (toIndex == 1) {
        [QMPEvent event:@"trz_ribao_zhoubao_click"];
    }else{
        [QMPEvent event:@"trz_rztongji_click"];
        
    }
}

#pragma mark - LrdOutputViewDelegate
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger currentIndex = ceil(_scrollView.contentOffset.x/SCREENW);
    WebViewController *childVC = self.childViewControllers[currentIndex];
    switch (indexPath.row) {
            
        case 0:{
            [childVC rongziShare];
            break;
        }
        case 1:{
            if (_selectIndex == 0) { //日报
                [QMPEvent event:@"trz_ribao_screen_share"];
            }else{ //周报
                [QMPEvent event:@"trz_zhoubao_share"];
            }
            [childVC buildPrintscreenView];
            break;
        }
        case 2:{
            if (_selectIndex == 0) { //日报
                [QMPEvent event:@"trz_ribao_refresh"];
            }else{
                [QMPEvent event:@"trz_zhoubao_refresh"];
            }
            [childVC refreshPage];
            break;
        }
        default:
            break;
    }
}


- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, 200, 44) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        
        _pageMenu.delegate = self;
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = _scrollView;
        [_pageMenu setItems:@[@"今日",@"本周"] selectedItemIndex:0];
        _pageMenu.itemPadding = 40;
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        
    }
    return _pageMenu;
}
@end
