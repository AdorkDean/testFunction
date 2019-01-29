//
//  ProductResultController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductResultController.h"
#import "SearchCompanyModel.h"
#import "SearchProRegisterModel.h"
#import "IPOCompanyCell.h"
#import "GetMd5Str.h"
#import "CompanyInvestorsController.h"
#import "CreateProController.h"
#import "TitleAndBtnBottomView.h"
#import "SearchProductCell.h"
#import "SearchProduct.h"

@interface ProductResultController () <UITableViewDataSource, UITableViewDelegate, CustomAlertViewDelegate> {
    NSString *_totalCount;
}

@property (nonatomic, strong) TitleAndBtnBottomView *createProductView;
@end

@implementation ProductResultController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _totalCount = @"0";
    [self initTableView];
    
    self.currentPage = 1;
    self.numPerPage = 20;
    [self requestData];
    [self.view addSubview:self.createProductView];
}


- (void)initTableView {
    [self.tableView registerClass:[IPOCompanyCell class] forCellReuseIdentifier:@"IPOCompanyCellID"];
    
//    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight-45) style:UITableViewStyleGrouped];
    self.tableView.frame = CGRectMake(0, 0, SCREENW, SCREENH - kScreenBottomHeight - kScreenTopHeight - 45);
}

- (BOOL)requestData {
    
    if (![super requestData]) {
        return NO;
    }
   
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    NSString *w = [self.keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 注意考虑特殊字符
    [dic setValue:w forKey:@"keywords"];
    
    [dic setValue:@"1" forKey:@"type"];
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
                SearchProduct *product = [[SearchProduct alloc]init];
                [product setValuesForKeysWithDictionary:dic];
                [arr addObject:product];
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
                self.createProductView.hidden = YES;
            }else{
                self.tableView.height = (SCREENH - kScreenBottomHeight - kScreenTopHeight - 45);
                self.createProductView.hidden = NO;
            }
        }
        [self.tableView reloadData];

    }];

    return YES;
}

- (void)feedbackSuccessHandle {
    self.feedbackBtn.selected = YES;
}


#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001;
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
    NSString *headerStr = [NSString stringWithFormat:@"项目(%@)",_totalCount];
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
    self.feedbackBtn.frame = CGRectMake(SCREENW-67,0, 50, 45);
    self.feedbackBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
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
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArr.count == 0) {
        return 1;
    }
    return self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArr.count == 0) {
        return SCREENH - kScreenTopHeight - 90;  //未搜索到
    }
    SearchProduct *product = self.dataArr[indexPath.row];
    if ([product needShowReason]) {
        return 93;
    }
    return 76;
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
    
    SearchProductCell *cell = [SearchProductCell searchProductCellWithTableView:tableView];
    cell.product = self.dataArr[indexPath.row];
    cell.iconLabel.backgroundColor = RANDOM_COLORARR[indexPath.row % 6];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArr.count == 0) {
        return;
    }
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    SearchProduct *product = self.dataArr[indexPath.row];
    NSDictionary *urlDict = [PublicTool toGetDictFromStr:product.detail];
    [[AppPageSkipTool shared] appPageSkipToProductDetail:urlDict];
    [QMPEvent event:@"search_product_cellClick"];
}

#pragma mark - EVEN
- (void)feedbackAlertView1 {
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"有项目",@"有项目联系方式",@"有项目官网",@"有项目新闻报道", @"有项目招聘信息", nil];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:@{@"module":@"搜索列表详情",@"title":@"搜索"}];
    [infoDic setValue:@"人工信息完善" forKey:@"type"];
    [infoDic setValue:@"急" forKey:@"c4"];
    [infoDic setValue:self.keyword forKey:@"c1"];
    [infoDic setValue:self.keyword forKey:@"company"];
    
    CustomAlertView *alertV = [[CustomAlertView alloc]initWithAlertViewHeight:arr frame:CGRectZero WithAlertViewHeight:10 infoDic:infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
    alertV.delegate = self;
}
#pragma mark - Getter
- (TitleAndBtnBottomView *)createProductView {
    if (!_createProductView) {
        __weak typeof(self) weakSelf = self;
        _createProductView = [TitleAndBtnBottomView titleAndBtnViewWithFrame:CGRectMake(0, SCREENH-kScreenBottomHeight-kScreenTopHeight-45, SCREENW, kScreenBottomHeight) Title:@"没有找到项目?" buttonTitle:@"联系客服创建" btnClick:^{
            [weakSelf kefuBtnClick:nil];
        }];
    }
    return _createProductView;
}

- (void)createProductBtnClick{
    CreateProController *prodVC = [[CreateProController alloc]init];
    prodVC.productName = self.keyword;
    [self.navigationController pushViewController:prodVC animated:YES];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
@end
