//
//  JigouResultController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "JigouResultController.h"
#import "SearchJigouModel.h"
#import "SearchJigouCell.h"
#import "GetMd5Str.h"
#import "CreateOrgnizeViewController.h"
#import "TitleAndBtnBottomView.h"
#import "SearchOrganize.h"
#import "SearchOrganizeCell.h"

@interface JigouResultController () <UITableViewDataSource, UITableViewDelegate,CustomAlertViewDelegate> {
    NSString *_totalCount;
}
@property (nonatomic, strong) TitleAndBtnBottomView *createJigouView;
@end

@implementation JigouResultController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _totalCount = @"0";
    [self initTableView];
    
    self.currentPage = 1;
    self.numPerPage = 20;
    [self requestData];
}

- (void)initTableView {
    self.tableView.frame = CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight-45-kScreenBottomHeight);
    [self.tableView registerClass:[SearchJigouCell class] forCellReuseIdentifier:@"SearchJigouCellID"];
    [self.view addSubview:self.createJigouView];
}

#pragma mark - LoadData
- (BOOL)requestData {
    if (![super requestData]) {
        return NO;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    NSString *w = [self.keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 注意考虑特殊字符
    [dic setValue:w forKey:@"keywords"];
    
    [dic setValue:@"2" forKey:@"type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    if (self.dataArr.count == 0) {
        [self showHUD];
    }
    
    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        NSMutableArray *arr = [NSMutableArray array];

        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            
            
            if (self.currentPage == 1) {
                _totalCount = resultData[@"count"];
            }

            for (NSDictionary *dic in resultData[@"list"]) {
                SearchOrganize *jigou = [[SearchOrganize alloc]init];
                [jigou setValuesForKeysWithDictionary:dic];
                [arr addObject:jigou];
            }
            if (self.currentPage == 1) {
                [self.dataArr removeAllObjects];
            }
            
            [self.dataArr addObjectsFromArray:arr];
            
        }else{
            if (self.currentPage == 1) {
                _totalCount = @"0";
            }
        }
        
        [self refreshFooter:arr];

        if (self.currentPage == 1) {
            if (self.dataArr.count == 0) {
                self.tableView.height = (SCREENH - kScreenTopHeight - 45);
                self.createJigouView.hidden = YES;
            }else{
                self.tableView.height = (SCREENH - kScreenBottomHeight - kScreenTopHeight - 45);
                self.createJigouView.hidden = NO;
            }
        }
        
        [self.tableView reloadData];


    }];

    return YES;
}

- (void)feedbackSuccessHandle {
    self.feedbackBtn.selected = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event
- (void)createJigouBtnClick {
    CreateOrgnizeViewController *createOrgVC = [[CreateOrgnizeViewController alloc] init];
    [self.navigationController pushViewController:createOrgVC animated:YES];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArr.count == 0) { // 无搜索数据
        return 1;
    }
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArr.count == 0) {
        NSString *title = REQUEST_DATA_NULL;
        HomeInfoTableViewCell *cell = [self nodataCellWithInfo:title tableView:tableView];
        [cell.createBtn setTitle:@"全网搜索" forState:UIControlStateNormal];
        cell.createBtn.hidden = NO;
        [cell.createBtn addTarget:self action:@selector(baiduBtnClick) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }

    SearchOrganizeCell *cell = [SearchOrganizeCell searchOrganizeCellWithTableView:tableView];
    cell.organize = self.dataArr[indexPath.row];
    cell.bottomLineView.hidden = indexPath.row + 1 == self.dataArr.count;
    cell.iconLabel.backgroundColor = RANDOM_COLORARR[indexPath.row % 6];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArr.count == 0) { // 无搜索数据
        return SCREENH - kScreenTopHeight - 90;
    }
    SearchOrganize *organize = self.dataArr[indexPath.row];
    if ([organize needShowReason]) {
        return 93;
    }
    return 76;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 55)];
    sectionView.backgroundColor = TABLEVIEW_COLOR;
    
    UIView *_headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, SCREENW, 45)];//表头
    _headerView.backgroundColor = [UIColor whiteColor];
    [sectionView addSubview:_headerView];
    
    UILabel *headerLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 200, 45)];
    headerLab.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:headerLab];
    headerLab.font = [UIFont systemFontOfSize:14];
    headerLab.textColor = H9COLOR;
    NSString *headerStr = [NSString stringWithFormat:@"机构(%@)",_totalCount];
    headerLab.text = headerStr;
    [_headerView addSubview:headerLab];
    if (self.dataArr.count > 0) {
        UIButton *baiduBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        baiduBtn.frame = CGRectMake(SCREENW-135,0, 72, 45);
        baiduBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        baiduBtn.tag = 100;
        [baiduBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [baiduBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [baiduBtn setTitle:@"全网搜索" forState:UIControlStateNormal];
        [baiduBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [baiduBtn addTarget:self action:@selector(baiduBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:baiduBtn];
    }
    
    
    self.feedbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.feedbackBtn.frame = CGRectMake(SCREENW-50-17,0, 50, 45);
    self.feedbackBtn.tag = 100;
    [self.feedbackBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [self.feedbackBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self.feedbackBtn setTitle:@"反馈" forState:UIControlStateNormal];
    [self.feedbackBtn setTitle:@"已反馈" forState:UIControlStateSelected];
    [self.feedbackBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.feedbackBtn addTarget:self action:@selector(feedbackAlertView1) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:self.feedbackBtn];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 54.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [sectionView addSubview:line];
    
    return sectionView;
}

#pragma mark - EVENT
- (void)feedbackAlertView1{
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"有机构",@"有机构联系方式",@"有机构官网",@"有机构投资案例", @"有机构新闻报道",nil];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:@{@"module":@"搜索列表详情",@"title":@"搜索"}];
    [infoDic setValue:@"人工信息完善" forKey:@"type"];
    [infoDic setValue:@"急" forKey:@"c4"];
    [infoDic setValue:self.keyword forKey:@"c1"];
    [infoDic setValue:self.keyword forKey:@"company"];
    
    CustomAlertView *alertV = [[CustomAlertView alloc]initWithAlertViewHeight:arr frame:CGRectZero WithAlertViewHeight:10 infoDic:infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
    alertV.delegate = self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataArr.count == 0) return ;
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    SearchJigouModel * model = self.dataArr[indexPath.row];
    NSDictionary *urlDict = [PublicTool toGetDictFromStr:model.detail];
    [[AppPageSkipTool shared] appPageSkipToJigouDetail:urlDict];
    [QMPEvent event:@"search_jigou_cellClick"];
}
#pragma mark - Getter
- (TitleAndBtnBottomView *)createJigouView {
    if (!_createJigouView) {
        __weak typeof(self) weakSelf = self;
        _createJigouView = [TitleAndBtnBottomView titleAndBtnViewWithFrame:CGRectMake(0, SCREENH-kScreenBottomHeight-kScreenTopHeight-45, SCREENW, kScreenBottomHeight) Title:@"没有找到机构?" buttonTitle:@"联系客服创建" btnClick:^{
            [weakSelf kefuBtnClick:nil];
        }];
    }
    return _createJigouView;
}
#pragma mark - util
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
@end
