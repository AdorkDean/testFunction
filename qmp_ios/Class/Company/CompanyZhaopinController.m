//
//  CompanyZhaopinController.m
//  qmp_ios
//
//  Created by QMP on 2018/2/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CompanyZhaopinController.h"
#import "ZhaopinModel.h"
#import "CompanyZhaopinCell.h"
#import "ZhaopinDetailController.h"


@interface CompanyZhaopinController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSMutableArray *zhaopinMArr;

@end

@implementation CompanyZhaopinController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.numPerPage = 30;
    self.currentPage = 1;
    
    self.title = @"招聘信息";
    self.zhaopinMArr = [NSMutableArray array];
    [self addView];
    [self showHUD];
    
    [self requestData];
}

- (void)addView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight ) style:UITableViewStyleGrouped];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"CompanyZhaopinCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"CompanyZhaopinCellID"];
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;

    [self.view addSubview:self.tableView];
    
}

#pragma mark --数据--
-(BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.requestDict];
    [param setValue:@(self.currentPage) forKey:@"page"];
    [param setValue:@(self.numPerPage) forKey:@"num"];
    [param setValue:(self.tableView.mj_header.isRefreshing ? @"1" :@"0") forKey:@"debug"];

    NSString *url = self.isProduct?@"CompanyDetail/zhaopin":@"AgencyDetail/agencyRecruitInfo";
    [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:url HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
    
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            if (self.currentPage == 1) {
                [self.zhaopinMArr removeAllObjects];
            }
            for (NSDictionary *zhaopinDic in resultData[@"list"]) {
                ZhaopinModel *zhaopinInfo = [[ZhaopinModel alloc] initWithDictionary:zhaopinDic error:nil];
                [self.zhaopinMArr addObject:zhaopinInfo];
            }
            
            [self refreshFooter:resultData[@"list"]];
            [self.tableView reloadData];
        }
        
    }];
    
    return YES;
}

#pragma mark --UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.zhaopinMArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"CompanyZhaopinCellID";
    CompanyZhaopinCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.model = self.zhaopinMArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.zhaopinMArr.count == 0) {
        return;
    }
    ZhaopinDetailController *detailVC = [[ZhaopinDetailController alloc]init];
    detailVC.zhaopinM = self.zhaopinMArr[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
