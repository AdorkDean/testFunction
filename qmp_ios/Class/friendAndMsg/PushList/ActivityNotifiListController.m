//
//  ActivityNotifiListController.m
//  qmp_ios
//
//  Created by QMP on 2018/9/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ActivityNotifiListController.h"
#import "ActivityNotifiCell.h"
#import "ActivityDetailViewController.h"

@interface ActivityNotifiListController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSMutableArray *listArr;
@end

@implementation ActivityNotifiListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
    self.title = @"互动提醒";
    self.currentPage = 1;
    self.numPerPage = 20;
    [self showHUD];
    [self requestData];
    
    [self refreshUnreadCount];
}

- (void)refreshUnreadCount{
    
    [AppNetRequest updateUnreadCountWithKey:@"activity_notifi_count" type:@"动态互动通知" completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
    }];
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


#pragma mark --Data--
-(BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    //     ActivityNotifiModel 分页
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:QMPActivityNotificationListURL HTTPBody:@{@"page":@(self.currentPage),@"num":@(self.numPerPage)} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (resultData && resultData[@"list"] && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            if (self.currentPage == 1) {
                [self.listArr removeAllObjects];
            }

            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                ActivityNotifiModel *model = [[ActivityNotifiModel alloc]init];
                [model setValuesForKeysWithDictionary:dic];
                [arr addObject:model];
            }
            if (self.currentPage == 1) {
                [self.listArr removeAllObjects];
            }
            [self.listArr addObjectsFromArray:arr];
            [self refreshFooter:arr];
            [self.tableView reloadData];
        }
        
    }];
    
    return YES;
}

#pragma mark --UITableViewDelegate--
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 11;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.listArr.count == 0) {
        return SCREENH-kScreenTopHeight;
    }
    ActivityNotifiModel *model = self.listArr[indexPath.row];
    return model.totalHeight;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listArr.count ? : 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.listArr.count == 0) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
        
    }
    ActivityNotifiCell *cell = [ActivityNotifiCell cellWithTableView:tableView];
    cell.activityNofiModel = self.listArr[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.listArr.count == 0) {
        return;
        
    }
    ActivityNotifiModel *model = self.listArr[indexPath.row];
    if (![PublicTool isNull:model.activity[@"id"]] && ![PublicTool isNull:model.activity[@"ticket"]]) { //跳动态
        ActivityDetailViewController *detailVC = [[ActivityDetailViewController alloc]init];
        detailVC.activityTicket = model.activity[@"ticket"];
        detailVC.activityID = model.activity[@"id"];
        [self.navigationController pushViewController:detailVC animated:YES];

    }
}


#pragma mark --懒加载--
-(NSMutableArray *)listArr{
    if (!_listArr) {
        _listArr = [NSMutableArray array];
    }
    return _listArr;
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
