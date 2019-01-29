//
//  RelateCompanyController.m
//  qmp_ios
//
//  Created by QMP on 2018/2/9.
//  Copyright © 2018年 Molly. All rights reserved.
//  机构相关公司列表

#import "RelateCompanyController.h"
#import "RelateCompanyModel.h"
#import "RelateCompanyCell.h"
#import "RegisterInfoViewController.h"

@interface RelateCompanyController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_dataArr;
}
@end

@implementation RelateCompanyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"相关公司";
    _dataArr = [NSMutableArray array];
    
    [self addView];
    [self showHUD];
    [self requestData];
    
}

- (void)addView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    self.tableView.mj_header = self.mjHeader;
    
    self.tableView.mj_footer = self.mjFooter;
    
    [self.view addSubview:self.tableView];
    
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RelateCompanyCell" bundle:nil] forCellReuseIdentifier:@"RelateCompanyCellID"];
}



#pragma mark --请求数据--
-(BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.dict];
    [dic setValue:self.tableView.mj_header.isRefreshing ? @"1":@"0" forKey:@"debug"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];

    [AppNetRequest getRelateCompanyWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData) {
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                RelateCompanyModel *company = [[RelateCompanyModel alloc]initWithDictionary:dic error:nil];
                [arr addObject:company];
            }
            if (self.currentPage == 1) {
                [_dataArr removeAllObjects];
            }
            [_dataArr addObjectsFromArray:arr];
            [self refreshFooter:arr];
            
            [self.tableView reloadData];
        }
    }];
    return YES;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.1f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (_dataArr.count == 0) {
        return 0.1f;
    }
    else{
        
        return 0.1;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count ? _dataArr.count:1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_dataArr.count == 0)
    {
        return SCREENH - kScreenTopHeight;
    }
    return 76;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_dataArr.count == 0) {
        
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
        
    }else{
        NSArray *color = @[HTColorFromRGB(0xedd794),HTColorFromRGB(0xceaf96),HTColorFromRGB(0xa1dae5),HTColorFromRGB(0xeea8a8),HTColorFromRGB(0x8cceb9),HTColorFromRGB(0xa7c6f2)];
        
        
        RelateCompanyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RelateCompanyCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setCompanyName:[_dataArr[indexPath.row]company] titleBgColor:color[indexPath.row%6]];
        return cell;
    }
  
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_dataArr.count == 0){return;}
    RelateCompanyModel *company = _dataArr[indexPath.row];
    if (![PublicTool isNull:company.detail]) {
        NSDictionary *dic = [PublicTool toGetDictFromStr:company.detail];
        
        RegisterInfoViewController *registerDetailVC = [[RegisterInfoViewController alloc]init];
        NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [mdic removeObjectForKey:@"id"];
        [mdic removeObjectForKey:@"p"];
        registerDetailVC.urlDict = mdic;
        registerDetailVC.companyName = company.company;
        
        [self.navigationController pushViewController:registerDetailVC animated:YES];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
