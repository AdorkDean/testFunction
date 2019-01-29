//
//  BPMgrController.m
//  qmp_ios
//
//  Created by QMP on 2017/11/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "BPMgrController.h"
#import "BPListController.h"

#import "GestureScrollView.h"
#import "BPfilterView.h"
#import "UploadBPViewController.h"
#import "NewUserLeadView.h"
#import "UploadReportView.h"

#define TabNameKey @"BPFilter"

@interface BPMgrController ()<UIScrollViewDelegate,SPPageMenuDelegate,BPfilterViewDelegate>
{
    BOOL isFilter;
    
    NSInteger _selectIndex;
    UISearchBar *_mySearchBar;
    UIButton *_cancleSearchBtn;
    BPfilterView *_filterV;
    UIButton *_bptomeBtn;
}
@property (nonatomic, strong) SPPageMenu *pageMenu;
@property (nonatomic, strong) GestureScrollView *scrollView;
@property(nonatomic,strong)UploadReportView *reportV;
@property(nonatomic,strong)UIView *searchView;

@property(nonatomic,strong)UIButton *filterBtn;

@property (strong, nonatomic) FMDatabase *db;

@property (nonatomic, strong) NSMutableArray *selectedMArr;
@property (nonatomic, strong) NSMutableArray *selectedProvinceArr;
@property (nonatomic, strong) NSMutableArray *selectedFlagArr;

@end


@implementation BPMgrController
- (FMDatabase *)db{
    if (_db == nil) {
        _db = [[DBHelper shared] toGetDB];
    }
    return _db;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUI];
//    [self loadLoeadVw];
    [self buildRightBarbutton];
    
    [self refreshMYBPMenu:[WechatUserInfo shared].bp_count.integerValue > 0];
   
}

- (void)loadLoeadVw{
    
    NSString *key = [NSString stringWithFormat:@"%@%@",[WechatUserInfo shared].unionid,@"3.7.0_BP"];

    if (![USER_DEFAULTS valueForKey:key]) {
        CGFloat left = SCREENW - 55;
        CGRect shadeFrame = CGRectMake(left, kScreenTopHeight - 45, 45, 45);
        NSArray *titleFrame = @[NSStringFromCGRect(CGRectMake(0, kScreenTopHeight+20+200, SCREENW, 20)),NSStringFromCGRect(CGRectMake(0, kScreenTopHeight+20+230, SCREENW, 20)),NSStringFromCGRect(CGRectMake(0, kScreenTopHeight+20+260, SCREENW, 20))];
        NewUserLeadView *leaderV = [[NewUserLeadView alloc]initWithshadeFrame:shadeFrame shadeImage:[UIImage imageNamed:@"newusr_leadCircle"] arrowImageFrame:CGRectMake(SCREENW/2.0 - 80, kScreenTopHeight, 220, 200) arrowImage:[UIImage imageNamed:@"newusr_leadArrow"] titleArr:@[@"3步上传文件教程",@"教你快速上传报告和BP",@"试试看吧～～"] titleFrameArr:titleFrame clickBtnFrame:CGRectMake(0, kScreenTopHeight+20+300, 110, 35) leaderKey:key];
    }
}

- (void)buildRightBarbutton{
    
    if (_selectIndex == 0) {
        UIButton *jiaochengBtn = [[UIButton alloc]initWithFrame:RIGHTBARBTNFRAME];
        
        [jiaochengBtn setTitle:@"上传" forState:UIControlStateNormal];
        [jiaochengBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        jiaochengBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [jiaochengBtn addTarget:self action:@selector(pressJiaochengBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = RIGHTNVSPACE;
        
        if (iOS11_OR_HIGHER) {
            
            jiaochengBtn.width = 30;
            jiaochengBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:jiaochengBtn];
            
            self.navigationItem.rightBarButtonItems = @[buttonItem];
        } else {
            
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:jiaochengBtn];
            self.navigationItem.rightBarButtonItems = @[ negativeSpacer,buttonItem];
        }
        
        return;
        
    }else if (_selectIndex == 1){
        
        UIImage *img = [UIImage imageNamed:@"bar_setgray"];
        if (self.selectedProvinceArr.count || self.selectedMArr.count || self.selectedFlagArr.count) {
            img = [UIImage imageNamed:@"bar_setBlue"];
        }
        
        UIButton *noteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 53)];
       
        [noteBtn setImage:img forState:UIControlStateNormal];
        [noteBtn addTarget:self action:@selector(pressNotStoreFilterBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = RIGHTNVSPACE;

        if (iOS11_OR_HIGHER) {
            
            noteBtn.width = 30;
            noteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:noteBtn];
            
            self.navigationItem.rightBarButtonItems = @[buttonItem];
        } else {
            
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:noteBtn];
            self.navigationItem.rightBarButtonItems = @[ negativeSpacer,buttonItem];
        }
    }else{
        
        UIButton *jiaochengBtn = [[UIButton alloc]initWithFrame:RIGHTBARBTNFRAME];
        
        [jiaochengBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        jiaochengBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = RIGHTNVSPACE;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:jiaochengBtn];
        
        if (iOS11_OR_HIGHER) {
            jiaochengBtn.width = 30;
            jiaochengBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            self.navigationItem.rightBarButtonItems = @[buttonItem];
        } else {
            self.navigationItem.rightBarButtonItems = @[negativeSpacer,buttonItem];
        }
    }
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
    
    BPListController *eneventVC = [[BPListController alloc] init];
    eneventVC.isToMe = NO;
    eneventVC.view.frame = CGRectMake(0, 0, SCREENW , self.scrollView.height);
    [self.scrollView addSubview:eneventVC.view];
    [self addChildViewController:eneventVC];
    
    BPListController *cneventVC = [[BPListController alloc] init];
    cneventVC.isToMe = YES;
    cneventVC.selectedMArr = self.selectedMArr;
    cneventVC.selectedProvinceArr = self.selectedProvinceArr;
    cneventVC.selectedFlagArr = self.selectedFlagArr;
    cneventVC.view.frame = CGRectMake(SCREENW, 0, SCREENW ,self.scrollView.height);
    [self addChildViewController:cneventVC];

    
    BPDownController *downloadedVC = [[BPDownController alloc] init];
    downloadedVC.view.frame = CGRectMake(SCREENW*2, 0, SCREENW ,self.scrollView.height);
    [self addChildViewController:downloadedVC];
    [self.scrollView addSubview:downloadedVC.view];

 
    self.navigationItem.titleView = self.pageMenu;
}

- (void)pressJiaochengBtnClick:(UIButton*)btn{
    __weak typeof(self) weakSelf = self;
    UploadReportView *reportV = [[UploadReportView alloc]initWithIsBP:YES uploadSuccess:^(ReportModel *report) {
        BPListController *meUploadVC = weakSelf.childViewControllers[0];
        [meUploadVC.tableView.mj_header beginRefreshing];
        [weakSelf.pageMenu setSelectedItemIndex:0];
    }];
    self.reportV = reportV;

//
//    UploadBPViewController *vc = [[UploadBPViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark ----EVENT---
- (void)selectedIndexPage:(NSInteger)index{
    [self.scrollView setContentOffset:CGPointMake(SCREENW*index, 0) animated:YES];
    [self.pageMenu setSelectedItemIndex:index];
}

- (void)refreshMYBPMenu:(BOOL)show{
    
    UIView *redV = [_bptomeBtn viewWithTag:1000];
    if (!redV) {
        redV = [[UIView alloc]initWithFrame:CGRectMake(_bptomeBtn.width, 10, 5, 5)];
        redV.backgroundColor = RED_TEXTCOLOR;
        redV.layer.masksToBounds = YES;
        redV.layer.cornerRadius = 2.5;
        [_bptomeBtn addSubview:redV];
        redV.tag = 1000;
    }
    
    if (show) {
        redV.hidden = NO;
    }else{
        redV.hidden = YES;
    }
}
- (void)refreshSelected{

    [self.view endEditing:YES];
    
    BPListController *bpVC = self.childViewControllers[0];
    BPListController *bpVCMe = self.childViewControllers[1];
    [bpVC resignFirstResponder];
    [bpVCMe resignFirstResponder];
}

- (void)pressNotStoreFilterBtn:(UIButton *)sender{
    
    if ([TestNetWorkReached networkIsReachedAlertOnView:self.view]) {
        isFilter = YES;
        for (BPListController *childVC in self.childViewControllers) {
            if ([childVC respondsToSelector:@selector(cancleSearch)]) {
                [childVC cancleSearch];
            }
        }
        
        _filterV = [BPfilterView initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH) withKey:TabNameKey];
        ((BPfilterView *)_filterV).delegate = self;
        [KEYWindow addSubview:_filterV];
    }
    
}
- (NSMutableArray *)getArrFromDataWithTablename:(NSString *)tablename{
    NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
    if ([self.db open]) {
        NSString *sql = [NSString stringWithFormat:@"select name from '%@' where selected='1'",tablename];
        FMResultSet *rs = [self.db executeQuery:sql];
        while ([rs next]) {
            [retMArr addObject:[rs stringForColumn:@"name"]];
        }
    }
    [self.db close];
    return retMArr;
}


#pragma mark - BPFilterViewDelegate
-(void)updateWithFirstArr:(NSMutableArray *)lingyuArr secondArr:(NSMutableArray *)provinceArr flagArr:(NSMutableArray *)flagArr{

    isFilter = YES;
    self.selectedMArr = [NSMutableArray arrayWithArray:lingyuArr];
    self.selectedProvinceArr = [NSMutableArray arrayWithArray:provinceArr];
    self.selectedFlagArr = [NSMutableArray arrayWithArray:flagArr];
    //处理筛选项的选中状态
    if ([self.db open]) {
        
        NSString *tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsindustry",TabNameKey]];
        NSString *values = [self handleArrToSqlStr:self.selectedMArr];
        NSString *selectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='1'  WHERE name in (%@)",tableName,values];
        NSString *notSelectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='0'  WHERE name not in (%@)",tableName,values];
        
        NSString *tableName1 = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterripoProvince",TabNameKey]];
        NSString *values1 = [self handleArrToSqlStr:self.selectedProvinceArr];
        NSString *selectSql1 = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='1'  WHERE name in (%@)",tableName1,values1];
        NSString *notSelectSql1 = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='0'  WHERE name not in (%@)",tableName1,values1];
        
        NSString *tableName2 = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsflag",TabNameKey]];
        NSString *values2 = [self handleArrToSqlStr:self.selectedFlagArr];
        NSString *selectSql2 = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='1'  WHERE name in (%@)",tableName2,values2];
        NSString *notSelectSql2 = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='0'  WHERE name not in (%@)",tableName2,values2];

        [self.db executeUpdate:selectSql];
        [self.db executeUpdate:notSelectSql];
        
        [self.db executeUpdate:selectSql1];
        [self.db executeUpdate:notSelectSql1];
        
        [self.db executeUpdate:selectSql2];
        [self.db executeUpdate:notSelectSql2];
    }
    
    [self.db close];
    BPListController *tomeBP = self.childViewControllers[1];
    tomeBP.selectedMArr = self.selectedMArr;
    tomeBP.selectedProvinceArr = self.selectedProvinceArr;
    tomeBP.selectedFlagArr = self.selectedFlagArr;
    [tomeBP.tableView.mj_header beginRefreshing];
    
    [self buildRightBarbutton];
}

- (NSString *)handleArrToSqlStr:(NSMutableArray *)selectedMArr{
    
    NSString *values = @"";
    if (selectedMArr.count > 0) {
        values = [NSString stringWithFormat:@"'%@'",selectedMArr[0]];
        
        if (selectedMArr.count > 1) {
            for (int i = 1 ; i < selectedMArr.count; i++) {
                
                values = [NSString stringWithFormat:@"%@,'%@'",values,selectedMArr[i]];
            }
        }
    }
    return values;
}

#pragma mark  mark - SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (fromIndex == toIndex) {
        return;
        
    }
    _selectIndex = toIndex;
    
    [self showVc:_selectIndex];
    if (_selectIndex == 1){ //收到的BP
        [self refreshMYBPMenu:NO];
    }
    if (labs(toIndex - fromIndex) >= 2) {
        [_scrollView setContentOffset:CGPointMake(SCREENW*_selectIndex, 0) animated:NO];
        
    }else{
        [_scrollView setContentOffset:CGPointMake(SCREENW*_selectIndex, 0) animated:YES];
        
    }
    [self refreshSelected];
    [self buildRightBarbutton];
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
        CGFloat width = SCREENW > 375 ? 250*ratioWidth:200*ratioWidth;
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, width, 44) trackerStyle:SPPageMenuTrackerStyleLine];
        _pageMenu.delegate = self;
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = self.scrollView;
        [_pageMenu setItems:@[@"我上传的", @"我收到的", @" 已下载 "] selectedItemIndex:0];
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        
        for (UIView *subV in self.pageMenu.subviews) {
           
            if ([subV isKindOfClass:[UIView class]]) {
                
                for (UIView *subV1 in subV.subviews) {
                    if ([subV1 isKindOfClass:[UIScrollView class]]) {

                        NSMutableArray *btnArr = [NSMutableArray array];
                        for (UIView *subV2 in subV1.subviews) {
                            if ([subV2 isKindOfClass:NSClassFromString(@"SPItem")]) {
                                [btnArr addObject:subV2];
                            }
                        }
                        _bptomeBtn = btnArr[1];
                    }
                }
                
            }
        }
        
    }
    return _pageMenu;
}

#pragma mark --懒加载--
- (NSMutableArray *)selectedMArr{
    
    if (!_selectedMArr) {
        if ([ToLogin isLogin]) {
            //从数据库中获取
            NSString *tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsindustry",TabNameKey]];
            _selectedMArr = [self getArrFromDataWithTablename:tableName];
        }
        else{
            _selectedMArr = [[NSMutableArray alloc] initWithCapacity:0];
        }
    }
    return _selectedMArr;
}

- (NSMutableArray *)selectedProvinceArr{
    
    if (!_selectedProvinceArr) {
        if ([ToLogin isLogin]) {
            //从数据库中获取
            NSString *tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterripoProvince",TabNameKey]];
            _selectedProvinceArr = [self getArrFromDataWithTablename:tableName];
        }
        else{
            _selectedProvinceArr = [[NSMutableArray alloc] initWithCapacity:0];
        }
    }
    return _selectedProvinceArr;
}


- (NSMutableArray *)selectedFlagArr{
    
    if (!_selectedFlagArr) {
        if ([ToLogin isLogin]) {
            //从数据库中获取
            NSString *tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsflag",TabNameKey]];
            _selectedFlagArr = [self getArrFromDataWithTablename:tableName];
        }
        else{
            _selectedFlagArr = [[NSMutableArray alloc] initWithCapacity:0];
        }
    }
    return _selectedFlagArr;
}


@end
