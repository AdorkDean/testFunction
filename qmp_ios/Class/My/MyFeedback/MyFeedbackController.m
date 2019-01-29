//
//  MyFeedbackController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MyFeedbackController.h"
#import "GestureScrollView.h"
#import "FeedBackListController.h"
#import "CreateFeedBackViewController.h"
@interface MyFeedbackController ()<UIScrollViewDelegate,SPPageMenuDelegate>
{
    GestureScrollView *_scrollView;
    
    BOOL _tapSegment;
    NSInteger _selectIndex;
}
@property (nonatomic, strong) SPPageMenu *pageMenu;
@property (nonatomic, weak) FeedBackListController *runtimeVC;
@end

@implementation MyFeedbackController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

- (void)setUI{
    
    //    _scrollView = [[GestureScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight)];
    //    _scrollView.backgroundColor = [UIColor whiteColor];
    //    _scrollView.delegate = self;
    //    _scrollView.showsHorizontalScrollIndicator = NO;
    //    _scrollView.pagingEnabled = YES;
    //    _scrollView.bounces = NO;
    //    _scrollView.contentSize = CGSizeMake(SCREENW, 0);
    //    [self.view addSubview:_scrollView];
    
    FeedBackListController *finishVC = [[FeedBackListController alloc] init];
    //    finishVC.position = 0;
    finishVC.view.frame = CGRectMake(0, 0, SCREENW ,SCREENH - kScreenTopHeight);
    [self addChildViewController:finishVC];
    [self.view addSubview:finishVC.view];
    self.runtimeVC = finishVC;
    
    self.title = @"我的反馈";
    
    
    UIButton *navRightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    [navRightButton setTitle:@"我要反馈" forState:UIControlStateNormal];
    [navRightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [navRightButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    navRightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:navRightButton];
    [navRightButton addTarget:self action:@selector(createFeedBack) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Event
- (void)createFeedBack {
    [QMPEvent event:@"me_feedback_editClick"];
    CreateFeedBackViewController *createFeedVC = [[CreateFeedBackViewController alloc] init];
    createFeedVC.source = 2;
    [self.navigationController pushViewController:createFeedVC animated:YES];
    __weak typeof(self) welf = self;
    createFeedVC.block = ^(NSDictionary *dict) {
        //        _scrollView.contentOffset = CGPointMake(SCREENW, 0);
        [welf.runtimeVC.tableView.mj_header beginRefreshing];
        
        self.pageMenu.selectedItemIndex = 1;
        _selectIndex = 1;
    };
}
#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView == _scrollView) {
        
        CGFloat currentW = SCREENW;
        CGFloat currentX = scrollView.contentOffset.x;
        NSInteger selectIndex = (currentX + 0.5 * currentW) /currentW;
        
        if (_selectIndex != selectIndex) {
            
            _selectIndex = selectIndex;
            if (_selectIndex == 1) {
                [QMPEvent event:@"me_feed_enterProcess"];
            }
        }
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    //    _tapSegment = NO;
}



#pragma mark  mark - SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    _tapSegment = YES;
    _selectIndex = toIndex;
    
    [_scrollView setContentOffset:CGPointMake(SCREENW*_selectIndex, 0) animated:YES];
}


- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, 140*ratioWidth, 44) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        
        _pageMenu.delegate = self;
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = _scrollView;
        [_pageMenu setItems:@[@"已完成",@"处理中"] selectedItemIndex:0];
        _pageMenu.itemPadding = 32;
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        
    }
    return _pageMenu;
}

@end
