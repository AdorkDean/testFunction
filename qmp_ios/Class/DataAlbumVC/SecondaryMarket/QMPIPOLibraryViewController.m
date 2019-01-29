//
//  QMPIPOLibraryViewController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/9/5.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPIPOLibraryViewController.h"
#import "SmarketEventModel.h"
#import "IPOEventCell.h"
#import "QMPIPOLibraryCell.h"
#import "QMPIPOLibraryFilterView.h"
@interface QMPIPOLibraryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *ipoData;
@property (nonatomic, strong) QMPIPOLibraryFilterView *filterView;

@end

@implementation QMPIPOLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView];
    
    [self showHUD];
    [self requestData];
}
- (void)showFilterView {

    [self.filterView show];
    __weak typeof(self) weakSelf = self;
    self.filterView.confirmButtonClick = ^(NSArray *filterSections) {
//        NSLog(@"%zd", [weakSelf.filterView filterPlace]);
        [weakSelf.tableView.mj_header beginRefreshing];
    };
}
- (QMPIPOLibraryFilterView *)filterView {
    if (!_filterView) {
        _filterView = [[QMPIPOLibraryFilterView alloc] init];
        _filterView.frame = CGRectMake(0, 0, SCREENW, SCREENH);
    }
    return _filterView;
}
- (void)initTableView {
    if (self.tableView) {
        return;
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IPOEventCell" bundle:nil] forCellReuseIdentifier:@"IPOEventCellID"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.tableView];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.estimatedRowHeight = 76;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
}
#pragma mark - Data
- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    NSMutableDictionary *reqDict = [NSMutableDictionary dictionaryWithDictionary:@{@"page":@(self.currentPage),@"num":@(self.numPerPage)}];
    
    if (self.ipoData.count > 0) {
        NSString *debug = [self.mjHeader isRefreshing] ? @"1" : @"0";
        [reqDict setObject:debug forKey:@"debug"];
    }
    
    
    BOOL flag = NO;
//    if ([self.filterView filteBoard].count > 0) {
//        [reqDict setObject:[self handleArrToStr:[self.filterView filteBoard]] forKey:@"stock"];
//        flag = YES;
//    }
    if ([self.filterView filterPlace].count > 0) {
        [reqDict setObject:[self handleArrToStr:[self.filterView filterPlace]] forKey:@"stock"];
        flag = YES;
    }
    if ([self.filterView filterTags].count > 0) {
        [reqDict setObject:[self handleArrToStr:[self.filterView filterTags]] forKey:@"hangye"];
        flag = YES;
    }
    
    self.filterFlag = flag;
    if (self.didFiltered) {
        self.didFiltered(flag);
    }
    
    [AppNetRequest getSmarketEventWithParameter:reqDict completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.mjHeader endRefreshing];
        [self.mjFooter endRefreshing];
        
        if (resultData) {
            
            NSDictionary *dict = resultData;
            NSArray *arr = dict[@"list"];
            
            if (self.currentPage == 1) {
                [self.ipoData removeAllObjects];
            }
            
            for (NSDictionary *dic in arr) {
                
                NSError *error = nil;
                SmarketEventModel *eventModel = [[SmarketEventModel alloc]initWithDictionary:dic error:&error];
                [self.ipoData addObject:eventModel];
            }
            
//            self.filterBtn.enabled = YES;
//            [self showFilterBtn];
            
            [self.tableView reloadData];
            
            [self refreshFooter:arr];
            
//            isFilter = NO;
        }
    }];
    
    
    
    return YES;
}
#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ipoData.count ? self.ipoData.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.ipoData.count == 0) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
    
    SmarketEventModel *marketModel = self.ipoData[indexPath.row];
    
    QMPIPOLibraryCell *cell = [QMPIPOLibraryCell ipoLibraryCellWithTableView:tableView];
    cell.ipoModel = marketModel;
    return cell;
    
//    IPOEventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IPOEventCellID" forIndexPath:indexPath];
//    cell.smarketModel = marketModel;
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.ipoData.count == 0) {
        return SCREENH;
    }
    return UITableViewAutomaticDimension;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    if (self.ipoData.count == 0) {
        return;
    }
    
    SmarketEventModel *marketModel = self.ipoData[indexPath.row];
    NSDictionary *param = [PublicTool toGetDictFromStr:marketModel.detail];
    [[AppPageSkipTool shared] appPageSkipToProductDetail:param];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    QMPIPOLibraryTableHeaderView *view = [[QMPIPOLibraryTableHeaderView alloc] init];
    view.frame = CGRectMake(0, 0, SCREENW, 40);
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
#pragma mark - Getter
- (NSMutableArray *)ipoData {
    if (!_ipoData) {
        _ipoData = [NSMutableArray array];
    }
    return _ipoData;
}
- (NSString *)handleArrToStr:(NSArray *)selectedMArr{
    NSString *hangye = @"";
    
    for (int i = 0; i < selectedMArr.count; i++) {
        if (i == 0) {
            hangye = selectedMArr[0];
        }else{
            hangye = [NSString stringWithFormat:@"%@|%@",hangye,selectedMArr[i]];
        }
    }
    
    return hangye;
}
@end
