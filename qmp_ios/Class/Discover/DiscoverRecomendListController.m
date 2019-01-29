//
//  DiscoverRecomendListController.m
//  qmp_ios
//
//  Created by QMP on 2018/8/14.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DiscoverRecomendListController.h"
#import "DiscoverListCell.h"
#import "ActivityModel.h"
#import "QMPThemeDetailViewController.h"
#import "UIButton+Indicator.h"

@interface DiscoverRecomendListController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSString *_type;
}
@property(nonatomic,assign)BOOL haveRequest;
@property(nonatomic,strong)NSMutableArray *listArr;
@end

@implementation DiscoverRecomendListController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.haveRequest && self.listArr.count == 0) {
        [self requestData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addView];
    
    self.numPerPage = 30;
    self.currentPage = 1;
    if (self.tableView.contentOffset.y < (kHeaderViewH+kPageMenuH)) {
        [self showHUDAtTop:kScreenTopHeight];
    }else{
        [self showHUD];
    }
    [self requestData];
}

- (void)addView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight - kScreenBottomHeight- 44)
                                                  style:UITableViewStylePlain];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.layer.masksToBounds = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    [self.view addSubview:self.tableView];
//
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 75;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
}

- (void)setAttentType:(AttentType)attentType{
    _attentType = attentType;
    switch (attentType) {
        case AttentType_Product:
            _type = @"product";
            break;
        case AttentType_Organization:
            _type = @"jigou";
            break;
        case AttentType_Person:
            _type = @"person";
            break;
        case AttentType_Subject:
            _type = @"theme";
            break;
        case AttentType_Hot:
            _type = @"hot";
            break;
            
        default:
            break;
    }
}


- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    NSDictionary *dic = @{@"num":@(self.numPerPage),@"page":@(self.currentPage),@"project_type":_type?:@""};
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/suggestFollow" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        NSMutableArray *arr = [NSMutableArray array];
        
        if (resultData && resultData[@"list"]) {
            for (NSDictionary *dic in resultData[@"list"]) {
                [arr addObject:[NSMutableDictionary dictionaryWithDictionary:dic]];
            }
        }
        
        if (self.currentPage == 1) {
            [self.listArr removeAllObjects];
        }
        
        [self.listArr addObjectsFromArray:arr];
        [self refreshFooter:arr];
        [self.tableView reloadData];
        
        if (self.currentPage == 1) {
            self.refreshComplated();
        }
        self.haveRequest = YES;
    }];
    

    return YES;
}


#pragma mark --Event--
- (void)attentBtnClick:(UIButton*)attentBtn{
    
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    [attentBtn showIndicator];
    NSInteger row = attentBtn.tag - 1000;
    NSMutableDictionary *dic = self.listArr[row];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setValue:dic[@"project_type"] forKey:@"type"];
    [dict setValue:dic[@"name"] forKey:@"project"];
    [dict setValue:[PublicTool isNull:dic[@"uuid"]]?dic[@"ticket"]:dic[@"uuid"] forKey:@"ticket"];
    if ([dic[@"work_flow"]integerValue] == 1) { //未操作，点击取消关注
        [dict setValue:@"0" forKey:@"work_flow"];
    }else{
        [dict setValue:@"1" forKey:@"work_flow"];
    }
    
    [dic setValue:dict[@"work_flow"] forKey:@"work_flow"];
//    [self.tableView reloadData];

    [AppNetRequest attentFunctionWithParam:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [attentBtn hideIndicator];
        NSString * successStatusStr = resultData[@"msg"];
        
        if ([successStatusStr isEqualToString:@"success"]) {
            [PublicTool showMsg:[dic[@"work_flow"]integerValue] == 0 ? @"取消关注成功":@"关注成功"];
            if ([dic[@"work_flow"] integerValue] == 1) {
                [QMPEvent event:@"discover_focus_click" label:dic[@"project_type"]];
            }
            [self.tableView reloadData];
        }else{
            [PublicTool showMsg:[dic[@"work_flow"]integerValue] == 0 ? @"取消关注失败":@"关注失败"];
            [dic setValue:[NSString stringWithFormat:@"%zd",1-[dict[@"work_flow"]integerValue]] forKey:@"work_flow"];
            [self.tableView reloadData];
        }
        //启动上面功能，需注释👇 2 行代码 ，刷新行的状态，不进行删除
    }];
    //关注
    if ([dict[@"work_flow"] integerValue] == 1) {
        switch (self.attentType) {
            case AttentType_Person:
                [QMPEvent event:@"tab_discover_personFocus_click"];
                break;
            case AttentType_Product:
                [QMPEvent event:@"tab_discover_proFocus_click"];
                break;
            case AttentType_Organization:
                [QMPEvent event:@"tab_discover_jigouFocus_click"];
                break;
            case AttentType_Subject:
                [QMPEvent event:@"tab_discover_themeFocus_click"];
                break;
                
            default:
                break;
        }
    }
    
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
    
    if (self.listArr.count == 0) {
        return SCREENH - kScreenTopHeight - kScreenBottomHeight;
    }
    
    return 75;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listArr.count ? self.listArr.count : 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.listArr.count == 0) {
        
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
    }

    DiscoverListCell *cell = [DiscoverListCell cellWithTableView:tableView recommendType:_attentType dataDic:self.listArr[indexPath.row]];
    cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
    cell.attentBtn.tag = indexPath.row + 1000;
    [cell.attentBtn addTarget:self action:@selector(attentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    if (self.listArr.count == 0) {
        return;
    }
    NSDictionary *dic = self.listArr[indexPath.row];
    if ([dic[@"project_type"] containsString:@"product"] || [dic[@"project_type"] containsString:@"jigou"]) {
        
        [[AppPageSkipTool shared] appPageSkipToDetail:dic[@"detail_link"]];
        return;
        
    }else if([dic[@"project_type"] containsString:@"person"]){
        NSString *personid = dic[@"id"];
        PersonModel *personM = [[PersonModel alloc]init];
        personM.personId = personid;
        [PublicTool goPersonDetail:personM];
        
    }else if([dic[@"project_type"] containsString:@"theme"]){ //uuid（ticket）
        QMPThemeDetailViewController *vc = [[QMPThemeDetailViewController alloc] init];
        vc.ticketID = dic[@"ticket_id"];
        vc.ticket = dic[@"ticket"];
        [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
        return;
    }
}

#pragma mark --懒加载--
-(NSMutableArray *)listArr{
    if (!_listArr) {
        _listArr = [NSMutableArray array];
    }
    return _listArr;
}
@end
