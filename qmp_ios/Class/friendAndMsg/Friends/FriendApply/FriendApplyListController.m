//
//  FriendApplyListController.m
//  qmp_ios
//
//  Created by QMP on 2018/2/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "FriendApplyListController.h"
#import "FriendApplyCell.h"
#import "CustomAlertView.h"

@interface FriendApplyListController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_listArr;

}

@end

@implementation FriendApplyListController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.refreshVC) {
        self.refreshVC(NO);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"交换联系方式申请";
    [self addView];
    
    _listArr = [NSMutableArray array];
    
    self.numPerPage = 20;
    self.currentPage = 1;
    [self showHUD];
   
    [self requestData];

    [self refreshUnreadCount];
}

- (void)refreshUnreadCount{
    
    if ([WechatUserInfo shared].apply_count.integerValue) {
        [AppNetRequest updateUnreadCountWithKey:@"apply_count" type:@"交换名片申请" completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
        }];
    }
}


- (void)addView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.tableView registerNib:[UINib nibWithNibName:@"PushListCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"PushListCellID"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    [self.mjFooter setState:MJRefreshStateNoMoreData];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FriendApplyCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"FriendApplyCellID"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [btn setTitle:@"我的名片" forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn addTarget:self action:@selector(enterMyCard) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
}

-(void)pullDown{
    
    [super pullDown];
    [self refreshUnreadCount];
}

- (BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    
    //keyword  会员类型  page、page_num
    NSDictionary *dic = @{@"page":@(self.currentPage),@"page_num":@(self.numPerPage)};
    [AppNetRequest getFriendApplyListWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self hideHUD];
        if (resultData && resultData[@"list"]) {
            
            if (self.currentPage == 1) {
                [_listArr removeAllObjects];
            }
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                [arr addObject:dic];
            }
            [_listArr addObjectsFromArray:arr];
            
            if (self.currentPage == 1 && arr.count) {
                NSDictionary *dic = arr[0];
                NSString *usercode = ![PublicTool isNull:dic[@"usercode"]] ? dic[@"usercode"]:nil;
                [[NSUserDefaults standardUserDefaults]setValue:usercode forKey:@"apply_usercode"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            
            [self refreshFooter:@[]];
            [self.tableView reloadData];
        }
    }];
    return YES;
}

#pragma mark --UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_listArr.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    return 91;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_listArr.count == 0 ) {
    
        return 1;
    }
    return _listArr.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_listArr.count == 0 ) {
        
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
    }
    
    FriendApplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendApplyCellID" forIndexPath:indexPath];
    cell.ignoreBtn.tag = 1000 + indexPath.row;
    cell.passBtn.tag = 2000 + indexPath.row;
    [cell.ignoreBtn addTarget:self action:@selector(ignoreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.passBtn addTarget:self action:@selector(passBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.dic = _listArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_listArr.count == 0) {
        return;
    }
    NSDictionary *dict = _listArr[indexPath.row];
    [[AppPageSkipTool shared] appPageSkipToPersonDetail:dict[@"person_id"]];

}

- (void)enterMyCard{
    
   
}


- (void)ignoreBtnClick:(UIButton*)btn{
    NSDictionary *dic = _listArr[btn.tag - 1000];
    CustomAlertView *alertView = [[CustomAlertView alloc]initWithAlertViewHeight:[NSMutableArray arrayWithArray:@[@"不感兴趣",@"暂无需要"]] frame:CGRectZero WithAlertViewHeight:0 infoDic:@{@"title":@"拒绝理由"} viewcontroller:self moduleNum:0 isFeeds:NO];
    __weak typeof(alertView) weakAlert = alertView;
    __weak typeof(self) weakSelf = self;
    alertView.submitBtnClick = ^{
        __strong typeof(weakAlert) strongAlert = weakAlert;
        NSString *reason = [NSString stringWithFormat:@"%@|%@",[strongAlert toGetSelectText],strongAlert.textview.text];
        [weakSelf dealApply:NO dic:dic reason:reason];
    };
    
}

- (void)passBtnClick:(UIButton*)btn {
    NSDictionary *dic = _listArr[btn.tag - 2000];

    //同意 申请请求    向对方发送消息： 我通过了你的好友验证请求，现在我们可以开始聊天了
    [self dealApply:YES dic:dic reason:@""];
    
}

- (void)dealApply:(BOOL)agree dic:(NSDictionary*)dic reason:(NSString*)reason{
  
    [PublicTool showHudWithView:KEYWindow];
    NSDictionary *param = @{@"action":agree?@"3":@"2",@"usercode":dic[@"usercode"],@"reason":reason};
    [AppNetRequest dealFriendApplyWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        [self hideHUD];
        [PublicTool dismissHud:KEYWindow];

        if ([resultData[@"msg"] isEqualToString:@"success"] ) {
            
            if (agree) {
                
                [PublicTool showMsg:@"交换成功，可以去我的名片中查看" delay:1.2];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addFriendNotification" object:nil];
            }
           
            
            if ([dic[@"usercode"] isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:@"apply_usercode"]] && [dic[@"usercode"] isEqualToString:_listArr[0][@"usercode"]]) {
                if (_listArr.count > 1) { //存第一个的
                    [[NSUserDefaults standardUserDefaults]setValue:_listArr[1][@"usercode"] forKey:@"apply_usercode"];

                }else{ //没有好友申请了
                    [[NSUserDefaults standardUserDefaults]setValue:nil forKey:@"apply_usercode"];

                }
            }
            
            if (self.refreshVC) {
                self.refreshVC(YES);
            }            
            
            [_listArr removeObject:dic];
            [self.tableView reloadData];
            
        }else{
            
            [PublicTool showMsg:resultData[@"message"]];
        }
    }];
    
}

@end

