//
//  JointInvestmentViewController.m
//  qmp_ios
//
//  Created by qimingpian10 on 2016/11/30.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "JointInvestmentListController.h"
#import "JointInvestmentDetailViewController.h"
#import "CombineTableViewCell.h"
#import "OrganizeCombineItem.h"
#import "TestNetWorkReached.h"

#import <UIImageView+WebCache.h>


#define FEEDBACKBUTTONFRAME CGRectMake(8, 11.5, 20, 21)

@interface JointInvestmentListController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSMutableArray *jointInvestmentMdata;


@end

@implementation JointInvestmentListController



- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.model.name;
    [self initTableView];
    
    self.currentPage = 1;
    self.numPerPage = 20;

    [self showHUD];
    [self requestData];
}


- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = RGBa(240,239,245,1);
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//设置cell的分割线为无
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    
    [self.view addSubview:self.tableView];
}


- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    NSString *url;
    if (self.investType == InvestType_Together) {
        url = @"AgencyDetail/agencyCombineList";
    }else  if (self.investType == InvestType_Join) {
        url = @"AgencyDetail/agencyTogetherList";
    }
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithDictionary:self.urlDict];
    [requestDict setValue:self.tableView.mj_header.isRefreshing ? @"1":@"" forKey:@"debug"];
    [requestDict setValue:@(self.currentPage) forKey:@"page"];
    [requestDict setValue:@(self.numPerPage) forKey:@"num"];

    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:url HTTPBody:requestDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *dataMArr = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (NSDictionary *dataDict in resultData[@"list"]) {
                OrganizeCombineItem *model = [[OrganizeCombineItem alloc] init];
                [model setValuesForKeysWithDictionary:dataDict];
                [dataMArr addObject:model];
            }
            if (self.currentPage == 1) {
                self.jointInvestmentMdata = dataMArr;
            }else{
                [self.jointInvestmentMdata addObjectsFromArray:dataMArr];
            }
            [self refreshFooter:@[]];
        }
        
        [self.tableView reloadData];
    }];
    return YES;
}

#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 45.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 45.f)];
    headView.backgroundColor = TABLEVIEW_COLOR;
   
    
    UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, 100, 45)];
    infoLbl.font = [UIFont systemFontOfSize:13.f];
    infoLbl.text = [NSString stringWithFormat:@"%@机构",self.investType == InvestType_Together ? @"合投":@"参投"];
    infoLbl.textColor = H9COLOR;
    infoLbl.textAlignment = NSTextAlignmentLeft;
    [headView addSubview:infoLbl];

    
    CGFloat lblW = 100.f;
    UILabel *timeLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREENW - lblW - 16,0, lblW, 45.f)];
    timeLbl.textAlignment = NSTextAlignmentRight;
    timeLbl.text = self.investType == InvestType_Together ? @"合投次数" : @"参投项目";
    timeLbl.textColor = H9COLOR;
    timeLbl.font = [UIFont systemFontOfSize:13.f];
    [headView addSubview:timeLbl];
    
    return headView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1f;
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _jointInvestmentMdata.count?:1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _jointInvestmentMdata.count?60.f:tableView.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_jointInvestmentMdata.count == 0) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
    OrganizeCombineItem *item = self.jointInvestmentMdata[indexPath.row];
    
    CombineTableViewCell *cell = [CombineTableViewCell cellWithTableView:tableView];
    [cell initData:item];
    cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
    cell.lineView.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_jointInvestmentMdata.count == 0) {
        return;
    }

    OrganizeCombineItem* model = self.jointInvestmentMdata[indexPath.row];
    JointInvestmentDetailViewController *JointInvestmentDetail = [[JointInvestmentDetailViewController alloc]init];
    
    JointInvestmentDetail.model1 = self.model;
    JointInvestmentDetail.model2 = model;
    JointInvestmentDetail.title = (self.investType == InvestType_Together)?@"合投机构":@"参投机构";
    JointInvestmentDetail.action = (self.investType == InvestType_Together) ? @"AgencyDetail/agencyCombineCase470" : @"AgencyDetail/agencyTogetherCase";
    [self.navigationController pushViewController:JointInvestmentDetail animated:YES];
}

#pragma mark - 懒加载
- (NSMutableArray *)jointInvestmentMdata{
    if (!_jointInvestmentMdata) {
        _jointInvestmentMdata = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _jointInvestmentMdata;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
