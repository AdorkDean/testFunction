//
//  ActiveJigouController.m
//  qmp_ios
//
//  Created by QMP on 2017/11/9.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "ActiveJigouController.h"
#import "ActiveJigouCell.h"
#import "ActiveJigouModel.h"

@interface ActiveJigouController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic,strong) NSMutableArray *listArr;
@end

@implementation ActiveJigouController

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
- (void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"ActiveJigouCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"ActiveJigouCellID"];
    
    self.tableView.mj_header = self.mjHeader;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    //tablehead
    UIView *headV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];
    headV.backgroundColor = [UIColor whiteColor];
    
    UILabel *yearLabel = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 120, 45)];
    [yearLabel labelWithFontSize:14 textColor:H9COLOR];
    yearLabel.text = [NSString stringWithFormat:@"%@年投资概况",[PublicTool currentYear]];
    [headV addSubview:yearLabel];
    
    UILabel *countL = [[UILabel alloc]initWithFrame:CGRectMake(SCREENW - 17 - 70, 0, 70, 45)];
    [countL labelWithFontSize:14 textColor:H9COLOR];
    countL.textAlignment = NSTextAlignmentRight;
    countL.text = @"单位：笔";
    [headV addSubview:countL];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [headV addSubview:line];
    
    self.tableView.tableHeaderView = headV;
    self.tableView.tableHeaderView.backgroundColor = [UIColor whiteColor];
    
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}

- (BOOL)requestData {
    if (![super requestData]) {
        return NO;
    }
    
    NSString *debug = self.tableView.mj_header.isRefreshing ? @"1":@"0";
        
    NSDictionary *dic = @{@"debug":debug,@"time_interval":[PublicTool currentYear],@"page":@(self.currentPage),@"num":@(self.numPerPage)};
        
        [AppNetRequest getActiveJigouListWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
            if (resultData && resultData[@"list"]) {
                NSMutableArray *arr = [NSMutableArray array];
                for (NSDictionary *dic in resultData[@"list"]) {
                    ActiveJigouModel *model = [[ActiveJigouModel alloc]initWithDictionary:dic error:nil];
                    [arr addObject:model];
                }
                
                if (self.currentPage == 1) {
                    self.listArr = arr;
                }else{
                    [self.listArr addObjectsFromArray:arr];
                }
                [self refreshFooter:arr];
                [self.tableView reloadData];
                
            }else{
                self.currentPage --;
            }
        }];
    
    
    return YES;
}





#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArr.count ? self.listArr.count : 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listArr.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    return 78.5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listArr.count == 0) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
    // 融资中
    static NSString *cellIdentifier = @"ActiveJigouCellID";
    ActiveJigouCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.jigouModel = self.listArr[indexPath.row];
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
    ActiveJigouModel *jigouM = self.listArr[indexPath.row];
    NSDictionary *urlDic = [PublicTool toGetDictFromStr:jigouM.detail];
    [[AppPageSkipTool shared] appPageSkipToJigouDetail:urlDic];
    [QMPEvent event:@"trz_jigou_activejigou_cellclick"];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
@end
