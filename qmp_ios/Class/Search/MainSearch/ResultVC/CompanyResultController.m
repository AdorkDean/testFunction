//
//  CompanyResultController.m
//  qmp_ios
//
//  Created by QMP on 2018/7/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CompanyResultController.h"
#import "SearchProRegisterModel.h"
#import "SearchRegistCell.h"
#import "GetMd5Str.h"
#import "RegisterInfoViewController.h"

@interface CompanyResultController ()<UITableViewDataSource,UITableViewDelegate,CustomAlertViewDelegate>
{
    NSString *_totalCount;
}
@end

@implementation CompanyResultController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _totalCount = @"0";
    [self initTableView];
    
    self.currentPage = 1;
    self.numPerPage = 20;
    [self requestData];
}


- (void)initTableView{
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchRegistCell" bundle:nil] forCellReuseIdentifier:@"SearchRegistCellID"];
}




-(BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    NSString *w = [self.keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 注意考虑特殊字符
    [dic setValue:w forKey:@"keywords"];
    
    [dic setValue:@"4" forKey:@"type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    if (self.dataArr.count == 0) {
        [self showHUD];
    }
    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
//
        NSMutableArray *arr = [NSMutableArray array];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]&& [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            if (self.currentPage == 1) {
                _totalCount = resultData[@"count"];
            }
            /* @"faren": @"company_faren", @"open_time":@"qy_time",@"regCapital":@"province"*/
            for (NSDictionary *dic in resultData[@"list"]) {
                SearchProRegisterModel *product = [[SearchProRegisterModel alloc]initWithDictionary:dic error:nil];
                product.faren = dic[@"company_faren"];
                product.regCapital = dic[@"province"];
                product.open_time = dic[@"qy_time"];
                product.qy_ziben = dic[@"qy_ziben"];
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
        
        [self refreshFooter:@[]];
        [self.tableView reloadData];

    }];
    
    return YES;
}

- (void)feedbackSuccessHandle{
    self.feedbackBtn.selected = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 55.0f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (self.dataArr.count == 0) {
        return 0.1f;
    }
    else{
        
        return 0.1;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
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
    NSString *headerStr = [NSString stringWithFormat:@"公司(%@)",_totalCount.integerValue>20?@(20):_totalCount];
    headerLab.text = headerStr;
    [_headerView addSubview:headerLab];
    if (self.dataArr.count > 0) {
        UIButton *baiduBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        baiduBtn.frame = CGRectMake(SCREENW-135,0, 72, 45);
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
    [self.feedbackBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.feedbackBtn setTitle:@"反馈" forState:UIControlStateNormal];
    [self.feedbackBtn setTitle:@"已反馈" forState:UIControlStateSelected];
    [self.feedbackBtn addTarget:self action:@selector(feedbackAlertView1) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:self.feedbackBtn];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 54.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [sectionView addSubview:line];
    
    return sectionView;
}
#pragma mark - EVENT
- (void)feedbackAlertView1{
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"有公司",@"有法人",@"注册信息有误", nil];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:@{@"module":@"搜索列表详情",@"title":@"搜索"}];
    [infoDic setValue:@"人工信息完善" forKey:@"type"];
    [infoDic setValue:@"急" forKey:@"c4"];
    [infoDic setValue:self.keyword forKey:@"c1"];
    [infoDic setValue:self.keyword forKey:@"company"];
    
    CustomAlertView *alertV = [[CustomAlertView alloc]initWithAlertViewHeight:arr frame:CGRectZero WithAlertViewHeight:10 infoDic:infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
    alertV.delegate = self;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.dataArr.count == 0) {
        return 1;
    } else{
        return self.dataArr.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        
        return SCREENH - kScreenTopHeight - 90;  //未搜索到
    }
    return 99;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        
        NSString *title = REQUEST_DATA_NULL;
        HomeInfoTableViewCell *cell = [self nodataCellWithInfo:title tableView:tableView];
        [cell.createBtn setTitle:@"全网搜索" forState:UIControlStateNormal];
        cell.createBtn.hidden = NO;
        [cell.createBtn addTarget:self action:@selector(baiduBtnClick) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    }else{
       
        SearchRegistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchRegistCellID" forIndexPath:indexPath];
        cell.keyWord = self.keyword;
        cell.registModel = self.dataArr[indexPath.row];
        cell.nameIconColor = RANDOM_COLORARR[indexPath.row % 6];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        return;
    }
    
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    SearchProRegisterModel * model = self.dataArr[indexPath.row];
    
    NSDictionary *urlDict = [PublicTool toGetDictFromStr:model.detail];
    RegisterInfoViewController *registerDetailVC = [[RegisterInfoViewController alloc]init];
    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:urlDict];
    [mdic removeObjectForKey:@"id"];
    [mdic removeObjectForKey:@"p"];
    registerDetailVC.urlDict = mdic;
    registerDetailVC.companyName = model.company;
    [self.navigationController pushViewController:registerDetailVC animated:YES];
    
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}


@end
