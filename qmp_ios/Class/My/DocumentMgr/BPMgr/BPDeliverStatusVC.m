//
//  BPDeliverSatusVC.m
//  qmp_ios
//
//  Created by QMP on 2018/7/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BPDeliverStatusVC.h"
#import "BPDeliverStatusCell.h"
#import "BPDeliverStatusModel.h"

@interface BPDeliverStatusVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray * dataSourceArr;
@end

@implementation BPDeliverStatusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"BP投递记录";
    self.numPerPage = 10;
    self.currentPage = 1;
    [self requestData];
    [self initTableView];
}
- (void)initTableView{
    CGRect iframe = CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight);
    self.tableView = [[UITableView alloc] initWithFrame:iframe style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, CGFLOAT_MIN)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, CGFLOAT_MIN)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}
- (BOOL)requestData{
    if ([super requestData]) {
        [self requtstBPStatusData];
        return YES;
    }
    //请求网络
    return NO;
}
//上拉加载
- (void)pullUp{
    
    self.currentPage++;
    [self requestData];
}

//下拉刷新
- (void)pullDown{
    
    self.currentPage = 1;
    self.mjFooter = nil;
    [self requestData];
}
- (void)requtstBPStatusData{
    
    NSDictionary * mdict = @{@"page":@(self.currentPage), @"page_num":@(self.numPerPage)};
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"bpDeliver/sendBpList" HTTPBody:mdict  completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        if (resultData[@"list"]) {
            NSArray * listArr = [BPDeliverStatusModel arrayOfModelsFromDictionaries:resultData[@"list"] error:nil];
            if (self.currentPage == 1) {
                [self.dataSourceArr removeAllObjects];
                [self.tableView.mj_header endRefreshing];
            }
            [self.dataSourceArr addObjectsFromArray:listArr];
            [self.tableView reloadData];
            [self refreshFooter:listArr];
        }
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArr.count ? self.dataSourceArr.count : 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSourceArr.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    return 105;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSourceArr.count == 0) {
        HomeInfoTableViewCell * noDataCell = [self nodataCellWithInfo:@"暂无投递状态,请投递BP" tableView:tableView];
        return noDataCell;
    }
    BPDeliverStatusCell * cell = [BPDeliverStatusCell defaultInitCellWithTableView:tableView];
    cell.bpstatusModel = self.dataSourceArr[indexPath.row];
    [cell.deliverBtn addTarget:self action:@selector(clickShowAlert:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (void)clickShowAlert:(UIButton *)btn{
    NSString * btnTitle = btn.currentTitle;
    if ([btnTitle isEqualToString:@"已投递"]) {
        [self showAlertController:@"您的BP已投递至对方BP库，请耐心等待"];
    }else if ([btnTitle isEqualToString:@"被查看"]){
        [self showAlertController:@"您的BP已被对方查看，请前往对方主页交换联系方式，以便快速取得联系"];
    }else if ([btnTitle isEqualToString:@"被标记为感兴趣"]){
        [self showAlertController:@"您的BP已被对方标记为感兴趣，请前往对方主页交换联系方式，以便快速取得联系"];
    }else if ([btnTitle isEqualToString:@"被标记为不感兴趣"]){
//        [self showAlertController:@"您的BP已被对方标记为不感兴趣，请前往对方主页交换联系方式，询问原因"];
    }else if ([btnTitle isEqualToString:@"投递失败"]){
        
    }else{}
}
- (void)showAlertController:(NSString *)alertStr{
    [PublicTool alertActionWithTitle:@"说明" message:alertStr btnTitle:@"确定" action:^{}];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSourceArr.count == 0) {
        return;
    }
    //跳转个人详情
    [self enterPersonDetail:indexPath];
}
- (void)enterPersonDetail:(NSIndexPath *)indexPath{
    BPDeliverStatusModel * selectModel = self.dataSourceArr[indexPath.row];
    [[AppPageSkipTool shared] appPageSkipToPersonDetail:selectModel.person_id];

//    PersonDetailsController * personDetaiVC = [[PersonDetailsController alloc] init];
//    personDetaiVC.persionId = selectModel.person_id;
//    [self.navigationController pushViewController:personDetaiVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, CGFLOAT_MIN)];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, CGFLOAT_MIN)];
}
- (NSMutableArray *)dataSourceArr{
    if (_dataSourceArr == nil) {
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
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
