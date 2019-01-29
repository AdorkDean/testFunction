//
//  MeDocumentManagerVC.m
//  qmp_ios
//
//  Created by QMP on 2018/1/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MeDocumentManagerVC.h"
#import "DocumentDownedController.h"
#import "BPDownController.h"
#import "DocumentCollecttedListVC.h"
#import "UploadReportView.h"
#import "GestureScrollView.h"
#import "DocuMgrMyUploadListVC.h"

@interface MeDocumentManagerVC ()<UIScrollViewDelegate,SPPageMenuDelegate>
{
    NSInteger _selectIndex;
    UISearchBar *_mySearchBar;
    UIButton *_cancleSearchBtn;
}
@property(nonatomic,strong) GestureScrollView *scrollView;
@property(nonatomic,strong)UIView *searchView;
@property (nonatomic, strong) SPPageMenu *pageMenu;
@property (nonatomic, strong) UIButton *uploadBtn;
@property (nonatomic, strong)UploadReportView *reportV;

@end

@implementation MeDocumentManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    [self buildRightBarbutton];
}


- (void)buildRightBarbutton{
    
    if (_selectIndex == 0) {
        
        if (!self.uploadBtn) {
            UIButton *jiaochengBtn = [[UIButton alloc]initWithFrame:RIGHTBARBTNFRAME];
            
            [jiaochengBtn setTitle:@"上传" forState:UIControlStateNormal];
            [jiaochengBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
            jiaochengBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [jiaochengBtn addTarget:self action:@selector(pressJiaochengBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:jiaochengBtn];
            self.navigationItem.rightBarButtonItem = buttonItem;
            self.uploadBtn = jiaochengBtn;
        }
        self.uploadBtn.hidden = NO;
        
    }else{
        self.uploadBtn.hidden = YES;

    }
}


- (void)pressJiaochengBtnClick:(UIButton*)btn{
    
    __weak typeof(self) weakSelf = self;
    UploadReportView *reportV = [[UploadReportView alloc]initWithIsBP:NO uploadSuccess:^(ReportModel *report) {
        DocumentCollecttedListVC *meUploadVC = weakSelf.childViewControllers[0];
        [meUploadVC.tableView.mj_header beginRefreshing];
        [weakSelf.pageMenu setSelectedItemIndex:0];
    }];
    self.reportV = reportV;
}
- (GestureScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[GestureScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.bounces = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        _scrollView.contentSize = CGSizeMake(SCREENW * 3, 0);
    }
    return _scrollView;
}
- (void)setUI{

    [self.view addSubview:self.scrollView];
    
    DocuMgrMyUploadListVC * pdfListVC = [[DocuMgrMyUploadListVC alloc] init];
    pdfListVC.view.frame = CGRectMake(0, 0, SCREENW, self.scrollView.height);
    [self.scrollView addSubview:pdfListVC.view];
    [self addChildViewController:pdfListVC];
    
    DocumentCollecttedListVC *zgsVC = [[DocumentCollecttedListVC alloc] init];
//    zgsVC.view.frame = CGRectMake(SCREENW, 0, SCREENW ,_scrollView.height);
//    [_scrollView addSubview:zgsVC.view];
    [self addChildViewController:zgsVC];
    
    DocumentDownedController *eneventVC = [[DocumentDownedController alloc] init];
//    eneventVC.view.frame = CGRectMake(SCREENW*2, 0, SCREENW ,_scrollView.height);
//    [_scrollView addSubview:eneventVC.view];
    [self addChildViewController:eneventVC];


    self.navigationItem.titleView = self.pageMenu;
}
- (void)showVC:(NSInteger)indx{
    if (self.childViewControllers.count) {
        BaseViewController * baseVC = self.childViewControllers[indx];
        if (![self.scrollView.subviews containsObject:baseVC.view]) {
            baseVC.view.frame = CGRectMake(indx * SCREENW, 0, SCREENW, self.scrollView.height);
            [self.scrollView addSubview:baseVC.view];
        }
    }
}

#pragma mark ----EVENT---
- (void)selectedIndexPage:(NSInteger)index{
    [_scrollView setContentOffset:CGPointMake(SCREENW*index, 0) animated:YES];
}


#pragma mark  mark - SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (fromIndex == toIndex) {
        return;
    }
    _selectIndex = toIndex;
    if (labs(toIndex - fromIndex) >= 2) {
        [_scrollView setContentOffset:CGPointMake(SCREENW*_selectIndex, 0) animated:NO];
    }else{
        [_scrollView setContentOffset:CGPointMake(SCREENW*_selectIndex, 0) animated:YES];
    }
    
    [self showVc:_selectIndex];
    
    DocuMgrMyUploadListVC * meUploadVC = self.childViewControllers[0];
    DocumentCollecttedListVC * collectedVC = self.childViewControllers[1];
    if (_selectIndex == 0) {
        [collectedVC.mySearchBar resignFirstResponder];
    }else if (_selectIndex == 1){
        [meUploadVC.mySearchBar resignFirstResponder];
    }else{
        
    }
    [self buildRightBarbutton];
    [self.view endEditing:YES];
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
    [_scrollView addSubview:vc.view];
}


- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, 250*ratioWidth, 44) trackerStyle:SPPageMenuTrackerStyleLine];
        
        _pageMenu.delegate = self;
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = _scrollView;
        [_pageMenu setItems:@[@"我上传的",@"已收藏",@"已下载"] selectedItemIndex:0];
        _pageMenu.itemPadding = 40;
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        
    }
    return _pageMenu;
}

@end
