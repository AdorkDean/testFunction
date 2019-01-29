//
//  METopItemParentVC.m
//  qmp_ios
//
//  Created by QMP on 2018/5/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "METopItemParentVC.h"
#import "MyAttentListController.h"
//
//#import "MELingYuListVC.h"
//#import "MEProductListVC.h"
//#import "MeJiGouListVC.h"

#import "GestureScrollView.h"
@interface METopItemParentVC ()<UIScrollViewDelegate, SPPageMenuDelegate>

@property (nonatomic, strong) GestureScrollView * scrollView;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, assign) BOOL tapSegment;
@end

@implementation METopItemParentVC

- (GestureScrollView *)scrollView{
    if (_scrollView == nil) {
        CGFloat h = SCREENH - kScreenTopHeight;
        _scrollView = [[GestureScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, h)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = true;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREENW * 4, 0);
        
        MyAttentListController * personVC = [[MyAttentListController alloc] init];
        personVC.attentType = AttentType_Person;
        personVC.view.frame = CGRectMake(0, 0, SCREENW, h);
        [_scrollView addSubview:personVC.view];
        [self addChildViewController:personVC];


        MyAttentListController * productlistVC = [[MyAttentListController alloc] init];
        productlistVC.attentType = AttentType_Product;
        [self addChildViewController:productlistVC];

        MyAttentListController * jigoulistVC = [[MyAttentListController alloc] init];
        jigoulistVC.attentType = AttentType_Organization;
        [self addChildViewController:jigoulistVC];

        MyAttentListController * lingyulistVC = [[MyAttentListController alloc] init];
        lingyulistVC.attentType = AttentType_Subject;
        [self addChildViewController:lingyulistVC];

//        MELingYuListVC * personVC = [[MELingYuListVC alloc] init];
//        personVC.type = @"person";
//        personVC.view.frame = CGRectMake(0, 0, SCREENW, h);
//        [_scrollView addSubview:personVC.view];
//        [self addChildViewController:personVC];
//
//
//        MEProductListVC * productlistVC = [[MEProductListVC alloc] init];
//        [self addChildViewController:productlistVC];
//
//        MeJiGouListVC * jigoulistVC = [[MeJiGouListVC alloc] init];
//        [self addChildViewController:jigoulistVC];
//
//        MELingYuListVC * lingyulistVC = [[MELingYuListVC alloc] init];
//        lingyulistVC.type = @"lingyu";
//        [self addChildViewController:lingyulistVC];
    }
    
    return _scrollView;
}
- (SPPageMenu *)topPageMenu{
    if (_topPageMenu == nil) {
        _topPageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, 220*ratioWidth, 44) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        _topPageMenu.itemTitleFont = [UIFont systemFontOfSize:16];
        _topPageMenu.selectedItemTitleColor = NV_TITLE_COLOR;
        _topPageMenu.unSelectedItemTitleColor = HTColorFromRGB(0x888888);
        _topPageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _topPageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _topPageMenu.bridgeScrollView = self.scrollView;
        [_topPageMenu setItems:@[@"人物",@"项目", @"机构", @"主题"] selectedItemIndex:0];
        _topPageMenu.delegate = self;
        _topPageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        _topPageMenu.itemPadding = 32 * ratioWidth;
    }
    return _topPageMenu;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.scrollView];
    self.navigationItem.titleView = self.topPageMenu;
}
- (void)showVc:(NSInteger)index{
    CGFloat offsetX = index * SCREENW;
    UIViewController * vc = self.childViewControllers[index];
    if (vc.isViewLoaded) {
        return;
    }else{
        vc.view.frame = CGRectMake(offsetX, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView addSubview:vc.view];
    }
}
#pragma mark SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    _tapSegment = YES;
    _selectIndex = toIndex;
    [self showVc:_selectIndex];
    [self refreshSelected];
}
- (void)refreshSelected{
    [self.scrollView setContentOffset:CGPointMake(SCREENW * _selectIndex, 0) animated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_tapSegment) {
        return;
    }
    if (scrollView == self.scrollView) {
        CGFloat currentW = SCREENW;
        CGFloat currentX  = scrollView.contentOffset.x;
        NSInteger selectIndex = (currentX + 0.5 * currentW) / currentW;
        if (selectIndex != _selectIndex) {
            _selectIndex = selectIndex;
        }
        [self showVc:_selectIndex];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    _tapSegment = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
