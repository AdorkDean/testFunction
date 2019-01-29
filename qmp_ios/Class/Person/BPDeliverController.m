//
//  BPDeliverController.m
//  qmp_ios
//
//  Created by QMP on 2018/3/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BPDeliverController.h"
#import "BPSelectController.h"
#import "GestureScrollView.h"
#import "UploadBPViewController.h"
#import "UploadReportView.h"

@interface BPDeliverController ()<UIScrollViewDelegate,SPPageMenuDelegate>
{
   
    NSInteger _selectIndex;
    UISearchBar *_mySearchBar;
    UIButton *_cancleSearchBtn;
    ReportModel *_selectBP;
    UIButton *_deliverBtn;
}


@property (nonatomic, strong) SPPageMenu *pageMenu;
@property(nonatomic,strong)UIView *searchView;
@property(nonatomic,strong)GestureScrollView *scrollView;
@property(nonatomic,strong)UploadReportView *reportV;

@end

@implementation BPDeliverController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

- (void)setUI{
    
    _scrollView = [[GestureScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.bounces = NO;
    _scrollView.scrollEnabled = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    _scrollView.contentSize = CGSizeMake(SCREENW * 2, 0);
    [self.view addSubview:_scrollView];
    
    
    BPSelectController *eneventVC = [[BPSelectController alloc] init];
    eneventVC.personId = self.personId;
    eneventVC.sourceReport = self.sourceReport;
    eneventVC.isToMe = NO;
    eneventVC.view.frame = CGRectMake(0, 0, SCREENW , _scrollView.height);
    [_scrollView addSubview:eneventVC.view];
    [self addChildViewController:eneventVC];
    
    BPSelectController *cneventVC = [[BPSelectController alloc] init];
    cneventVC.personId = self.personId;
    cneventVC.sourceReport = self.sourceReport;
    cneventVC.isToMe = YES;
    cneventVC.view.frame = CGRectMake(SCREENW, 0, SCREENW ,_scrollView.height);
    [self addChildViewController:cneventVC];
    [_scrollView addSubview:cneventVC.view];
    
    eneventVC.selectedReport = ^(ReportModel *report) {
        _selectBP = report;
        _selectBP.isMy = YES;
    };
    cneventVC.selectedReport = ^(ReportModel *report) {
        _selectBP = report;
        _selectBP.isMy = NO;
    };
    eneventVC.clearSelectedReport = ^{
        [cneventVC clearSelectedReportState];
    };
    cneventVC.clearSelectedReport = ^{
        [eneventVC clearSelectedReportState];

    };
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"上传" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
    
    _deliverBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, SCREENH - kScreenTopHeight - kScreenBottomHeight, 200, 34)];
    [_deliverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_deliverBtn setTitle:self.isCreateFinanceVC ? @"确定" : @"选择投递" forState:UIControlStateNormal];
    _deliverBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _deliverBtn.backgroundColor = BLUE_BG_COLOR;
    _deliverBtn.layer.masksToBounds = YES;
    _deliverBtn.layer.cornerRadius = 17.0;
    [self.view addSubview:_deliverBtn];
    _deliverBtn.centerX = SCREENW/2.0;
    [_deliverBtn addTarget:self action:@selector(deliverBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = self.pageMenu;
}

#pragma mark ----EVENT---
- (void)sureBtnClick{
    
    __weak typeof(self) weakSelf = self;
    UploadReportView *reportV = [[UploadReportView alloc]initWithIsBP:YES uploadSuccess:^(ReportModel *report) {
        BPSelectController * myBP = weakSelf.childViewControllers[0];
        [myBP.tableView.mj_header beginRefreshing];
        [weakSelf.pageMenu setSelectedItemIndex:0];
    }];
    self.reportV = reportV;
}

#pragma mark - 设置弹出提示语
- (void)setupAlertController {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (void)deliverBtnClick{
    
    if (_selectBP) {
        if (self.selectedBP) {
            self.selectedBP(_selectBP);
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        
        [PublicTool showMsg:@"请选择要投递的BP"];
    }
}

- (void)selectedIndexPage:(NSInteger)index{
    [_scrollView setContentOffset:CGPointMake(SCREENW*index, 0) animated:YES];
    self.pageMenu.selectedItemIndex = index;
}


- (void)refreshSelected{
    
    [self.view endEditing:YES];
    
    BPSelectController *bpVC = self.childViewControllers[0];
    
    BPSelectController *bpVCMe = self.childViewControllers[1];
    
    
    if (_selectIndex == 0) {
        
        if (bpVCMe.mySearchBar.text.length && ![bpVCMe.mySearchBar.text isEqualToString:bpVC.mySearchBar.text]) {
            [bpVC beginSearch:bpVCMe.mySearchBar.text];
            
        }else if(bpVCMe.mySearchBar.text.length == 0 && bpVC.mySearchBar.text.length){
            bpVC.mySearchBar.text = @"";
        }
        
    }else if (_selectIndex == 1){
        
        if (bpVC.mySearchBar.text.length && ![bpVCMe.mySearchBar.text isEqualToString:bpVC.mySearchBar.text]) {
            
            [bpVCMe beginSearch:bpVC.mySearchBar.text];
            
        }else if(bpVC.mySearchBar.text.length == 0 && bpVCMe.mySearchBar.text.length){
            bpVCMe.mySearchBar.text = @"";
        }
    }
    
    [bpVC disAppear];
    [bpVCMe disAppear];
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
        }
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    //    _tapSegment = NO;
}


#pragma mark  mark - SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    _selectIndex = toIndex;
    [self refreshSelected];
    [_scrollView setContentOffset:CGPointMake(SCREENW*_selectIndex, 0) animated:YES];
}


- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        CGFloat width = SCREENW > 375 ? 250*ratioWidth:220*ratioWidth;
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, width, 44) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        _pageMenu.delegate = self;
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollEqualWidths;
        _pageMenu.bridgeScrollView = self.scrollView;
        [_pageMenu setItems:@[@"我的BP", @"收到的BP"] selectedItemIndex:0];
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        
    }
    return _pageMenu;
}


@end


