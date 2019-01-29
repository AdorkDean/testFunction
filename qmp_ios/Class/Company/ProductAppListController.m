//
//  ProductAppListController.m
//  qmp_ios
//
//  Created by QMP on 2018/9/19.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductAppListController.h"
#import "ProductAppListCell.h"
#import "ProductAppDataViewController.h"

@interface ProductAppListController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ProductAppListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"App数据";
    [self setUI];
}

- (void)setUI{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    [self.view addSubview:self.tableView];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}



#pragma mark --UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.appArr.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
   
    return 110;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.appArr.count ? self.appArr.count:1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.appArr.count == 0) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
        
    }
    
    ProductAppListCell *cell = [ProductAppListCell cellWithTableView:tableView];
    
    cell.appInfo = self.appArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.appArr.count == 0) {
        return;
    }
    
    NSDictionary *dict = self.appArr[indexPath.row];
    ProductAppDataViewController *vc = [[ProductAppDataViewController alloc] init];
    vc.appID = dict[@"app_id"];
    vc.appName = dict[@"app_name"];
    vc.appStoreScore = dict[@"score"];
    vc.andirodDownCount = dict[@"downloads"];
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
}


@end
