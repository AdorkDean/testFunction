//
//  CompanyProductionViewController.m
//  qmp_ios
//
//  Created by molly on 2017/6/9.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "CompanyProductionViewController.h"
#import "CompanyDetailSimilarCell.h"
#import "SearchCompanyModel.h"

@interface CompanyProductionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *product;
@end

@implementation CompanyProductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView];
    self.title = @"公司业务";
    [self showHUD];
    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.tableData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //相似项目
    static NSString *cellIdentifier = @"SimilarCell";
    CompanyDetailSimilarCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[CompanyDetailSimilarCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.moreBtn.hidden = YES;
    SearchCompanyModel *model = self.tableData[indexPath.row];;
    
    [cell refreshUI:model];
    cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SearchCompanyModel *model = self.tableData[indexPath.row];
    [self enterCompanyDetail:model];
    
    [QMPEvent event:@"pro_product_cellClick"];
}

#pragma mark - 请求业务线信息
- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    NSDictionary *dic = @{@"debug":(self.tableView.mj_header.isRefreshing?@"1":@"0"),@"ticket":self.companyTicket?:@"",@"page":@(self.currentPage),@"num":@(self.numPerPage)};
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"CompanyDetail/companyBusiness" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && [resultData isKindOfClass:[NSArray class]]) {
            NSMutableArray *productMArr = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *productDict in resultData) {
                SearchCompanyModel *manager = [[SearchCompanyModel alloc] init];
                [manager setValuesForKeysWithDictionary:productDict];
                [productMArr addObject:manager];
            }
            if (self.currentPage == 1) {
                [self.tableData removeAllObjects];
            }
            [self.tableData addObjectsFromArray:productMArr];
            [self refreshFooter:productMArr];
        }
        [self.tableView reloadData];
        
    }];
    return YES;

}

#pragma mark - public
- (void)initTableView{

    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStylePlain];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableview];
    self.tableView = tableview;
    tableview.mj_header = self.mjHeader;
}


- (void)enterCompanyDetail:(SearchCompanyModel *)model{

    NSString *detail = model.detail;
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:detail]];
}
#pragma mark - 懒加载
- (NSMutableArray *)tableData{

    if (!_tableData) {
        _tableData = [[NSMutableArray alloc] init];
    }
    return _tableData;
}
@end
