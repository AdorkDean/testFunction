//
//  CompanyIcpListViewController.m
//  qmp_ios
//
//  Created by molly on 2017/4/18.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "CompanyIcpListViewController.h"
#import "NewsWebViewController.h"
#import "CompanyIcpTableViewCell.h"
#import "CompanyIcpModel.h"
#import "URLModel.h"
#import <objc/runtime.h>

@interface CompanyIcpListViewController ()<UITableViewDelegate,UITableViewDataSource>
@end

@implementation CompanyIcpListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"备案信息";
    [self initTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 130.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //备案信息
    
    CompanyIcpModel *icp = self.tableData[indexPath.row];
    
    static NSString *cellIdentifier = @"CompanyIcpTableViewCell";
    CompanyIcpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[CompanyIcpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell initData:icp];
    
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWebUrl:)];
    cell.moneyLab.userInteractionEnabled = YES;
    [cell.moneyLab addGestureRecognizer:tap];
    objc_setAssociatedObject(tap, "webUrl",icp.web_site , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return cell;

}

- (void)tapWebUrl:(UITapGestureRecognizer *)tap{
    
    URLModel *urlModel = [[URLModel alloc] init];
    urlModel.url = (NSString *)objc_getAssociatedObject(tap, "webUrl");
    
    if (urlModel.url&&![urlModel.url isEqualToString:@""]) {
        
        NewsWebViewController *webView = [[NewsWebViewController alloc] init];
        webView.urlModel = urlModel;
        webView.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:webView animated:YES];
    }
}

#pragma mark - public
- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.view addSubview:self.tableView];
    
}

@end
