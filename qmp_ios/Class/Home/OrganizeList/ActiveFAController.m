//
//  ActiveJigouController.m
//  qmp_ios
//
//  Created by QMP on 2017/11/9.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "ActiveFAController.h"
#import "ActiveJigouCell.h"
#import "ActiveJigouModel.h"

@interface ActiveFAController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *listArr;       ///< 活跃投资人
@property (nonatomic, strong) NSMutableArray *actionFAMArr;  ///< 活跃FA

@property (nonatomic, strong) UIView  *headerView;
@property (nonatomic, strong) UILabel *yearLabel;
@property (nonatomic, strong) UILabel *countLabel;
@end

@implementation ActiveFAController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [QMPEvent beginEvent:@"trz_jigou_activejigou_timer"];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [QMPEvent endEvent:@"trz_jigou_activejigou_timer"];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentPage = 1;
    self.numPerPage = 12;
    self.navigationItem.title = @"机构动态";
    
    [self initTableView];
    [self showHUD];
    [self requestData];
}
- (void)setIsFA:(BOOL)isFA {
    _isFA = isFA;
    self.countLabel.text = _isFA ? @"单位：例" : @"单位：笔";
    self.yearLabel.text = _isFA ? [NSString stringWithFormat:@"%@年服务概况",[PublicTool currentYear]] : [NSString stringWithFormat:@"%@年投资概况",[PublicTool currentYear]];
}
- (void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ActiveJigouCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"ActiveJigouCellID"];
    self.tableView.mj_header = self.mjHeader;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.headerView addSubview:self.yearLabel];
    [self.headerView addSubview:self.countLabel];
    self.tableView.tableHeaderView = self.headerView;

}

- (BOOL)requestData {
    if (![super requestData]) {
        return NO;
    }
    // 共50条
    NSString *debug = self.tableView.mj_header.isRefreshing ? @"1":@"0";
    NSDictionary * dic = @{@"debug":debug,@"time_interval":[PublicTool currentYear],@"page":@(self.currentPage),@"num":@(self.numPerPage)};
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Institutional/activeFa" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData) {
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                ActiveJigouModel *model = [[ActiveJigouModel alloc]initWithDictionary:dic error:nil];
                [arr addObject:model];
            }
            if (self.currentPage == 1) {
                self.listArr = arr;
            } else {
                [self.listArr addObjectsFromArray:arr];
            }
            [self refreshFooter:arr];
            [self.tableView reloadData];
            
        } else {
            self.currentPage--;
        }
    }];
    return YES;
}

#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.listArr.count?self.listArr.count:1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listArr.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    return 78.5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.listArr.count == 0) {
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
    }
    // 融资中
    static NSString *cellIdentifier = @"ActiveJigouCellID";
    ActiveJigouCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.isFa = _isFA;
    ActiveJigouModel *model = self.listArr[indexPath.row];
    cell.jigouModel = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.listArr.count == 0) {
        return;
    }
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    [QMPEvent event:@"trz_jigou_activejigou_cellclick"];
    
    ActiveJigouModel *jigouM = self.listArr[indexPath.row];
    [[AppPageSkipTool shared] appPageSkipToDetail:jigouM.detail];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.listArr.count == 0) {
        return 0.1f;
    }
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
#pragma mark - Getter
- (NSMutableArray *)actionFAMArr {
    if (_actionFAMArr == nil) {
        _actionFAMArr = [NSMutableArray array];
    }
    return _actionFAMArr;
}
- (UIView *)headerView {
    if (_headerView == nil) {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];
        headerView.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44.5, SCREENW, 0.5)];
        line.backgroundColor = LIST_LINE_COLOR;
        [headerView addSubview:line];
        
        _headerView = headerView;
    }
    return _headerView;
}
- (UILabel *)yearLabel {
    if (_yearLabel == nil) {
        _yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, 120, 45)];
        [_yearLabel labelWithFontSize:14 textColor:H9COLOR];
    }
    return _yearLabel;
}
- (UILabel *)countLabel {
    if (_countLabel == nil) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENW - 17 - 70, 0, 70, 45)];
        [_countLabel labelWithFontSize:14 textColor:H9COLOR];
        _countLabel.textAlignment = NSTextAlignmentRight;
    }
    return _countLabel;
}
@end
