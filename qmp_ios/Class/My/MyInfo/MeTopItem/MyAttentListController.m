//
//  MyAttentListController.m
//  qmp_ios
//
//  Created by QMP on 2018/8/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MyAttentListController.h"
#import "DiscoverListCell.h"
#import "MeTopItemModel.h"
#import "MeProductListCellByXib.h"
#import "QMPThemeDetailViewController.h"
#import "PersonModel.h"

@interface MyAttentListController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_listArr;
    NSString *_type;
}

@end

@implementation MyAttentListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addView];
    
    _listArr = [NSMutableArray array];
    
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
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    [self.view addSubview:self.tableView];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        default:
            break;
    }
}

- (BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    NSDictionary *dic = @{@"type":_type};
    if (self.attentType == AttentType_Person || self.attentType == AttentType_Subject) {
        [AppNetRequest getAttentionListWithParam:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
            NSMutableArray *arr = [NSMutableArray array];
            if (resultData) {
                for (NSDictionary *dic in resultData) {

                    MeTopItemModel *newsM = [[MeTopItemModel alloc]initWithDictionary:dic error:nil];
                    newsM.miaoshu = dic[@"desc"];
                    [arr addObject:newsM];
                }
            }
            if (self.currentPage == 1) {
                [_listArr removeAllObjects];
            }
            
            [_listArr addObjectsFromArray:arr];
            [self refreshFooter:@[]];
            [self.tableView reloadData];
        }];
        return YES;
    }
    [AppNetRequest getUserFollowListWithParam:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        NSMutableArray *arr = [NSMutableArray array];
        if (resultData && resultData[@"msg"]) {
            for (NSDictionary *dic in resultData[@"msg"]) {
                MeTopItemModel *newsM = [[MeTopItemModel alloc]initWithDictionary:dic error:nil];
                [arr addObject:newsM];
            }
        }
        if (self.currentPage == 1) {
            [_listArr removeAllObjects];
        }
        
        [_listArr addObjectsFromArray:arr];

        [self refreshFooter:@[]];
        [self.tableView reloadData];
    }];
    return YES;
    
}


#pragma mark --Event--
- (void)attentBtnClick:(UIButton*)attentBtn{
    
    NSInteger row = attentBtn.tag - 1000;
    MeTopItemModel *model = _listArr[row];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setValue:_type forKey:@"type"];
    [dict setValue:model.project forKey:@"project"];
    [dict setValue:model.attentionId forKey:@"follow_id"];
    if (self.attentType == AttentType_Product || self.attentType == AttentType_Organization) { //项目机构
        NSDictionary *ticketDic = [PublicTool toGetDictFromStr: model.detail];
        [dict setValue:ticketDic[@"ticket"]?:@"" forKey:@"ticket"];
    }else if(self.attentType == AttentType_Subject){ //主题
        [dict setValue:model.ticket forKey:@"ticket"];
    }else{ // 人物
        [dict setValue:model.project_id forKey:@"ticket"];
    }
    if (model.display_flag.integerValue == 1) { //未操作，点击取消关注
        [dict setValue:@"0" forKey:@"work_flow"];
    }else{
        [dict setValue:@"1" forKey:@"work_flow"];
    }
    [self.tableView reloadData];
    
    model.display_flag = dict[@"work_flow"];
    [self.tableView reloadData];

    //新接口  操作关注取关
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"common/commonFocus" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        
        NSString * successStatusStr = resultData[@"msg"];
        
        if ([successStatusStr isEqualToString:@"success"]) {
            [PublicTool showMsg:model.display_flag.integerValue == 0 ? @"取消关注成功":@"关注成功"];
            
        }else{
            [PublicTool showMsg:model.display_flag.integerValue == 0 ? @"取消关注失败":@"关注失败"];
            model.display_flag = [NSString stringWithFormat:@"%zd",1-[dict[@"work_flow"] integerValue]];
            [self.tableView reloadData];
        }
    }];
    
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
    
    return 69;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArr.count ? _listArr.count : 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_listArr.count == 0) {
        
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
    }
    DiscoverListCell *cell = [DiscoverListCell cellWithTableView:tableView recommendType:_attentType attentionModel:_listArr[indexPath.row]];
    cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
    cell.attentBtn.tag = indexPath.row + 1000;
    [cell.attentBtn addTarget:self action:@selector(attentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
    if (self.attentType == AttentType_Person || self.attentType == AttentType_Subject) {
        DiscoverListCell *cell = [DiscoverListCell cellWithTableView:tableView recommendType:_attentType attentionModel:_listArr[indexPath.row]];
        cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
        cell.attentBtn.tag = indexPath.row + 1000;
        [cell.attentBtn addTarget:self action:@selector(attentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else if (self.attentType == AttentType_Product) {
        MeProductListCellByXib *cell = [MeProductListCellByXib cellWithTableView:tableView];
        cell.type = fromMeProductType;
        cell.model = _listArr[indexPath.row];
        cell.attetionBtn.tag = indexPath.row + 1000;
        [cell.attetionBtn addTarget:self action:@selector(attentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }else if (self.attentType == AttentType_Organization) {
        MeProductListCellByXib *cell = [MeProductListCellByXib cellWithTableView:tableView];
        cell.type = fromMeJiGouTyp;
        cell.model = _listArr[indexPath.row];
        cell.attetionBtn.tag = indexPath.row + 1000;
        [cell.attetionBtn addTarget:self action:@selector(attentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    return [[UITableViewCell alloc]init];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_listArr.count == 0) {
        return;
    }
    MeTopItemModel *model =_listArr[indexPath.row];
    if (self.attentType == AttentType_Product || self.attentType == AttentType_Organization) {
        
        [[AppPageSkipTool shared] appPageSkipToDetail:model.detail];
        return;
        
    }else  if (self.attentType == AttentType_Person){
        
        PersonModel *personM = [[PersonModel alloc]init];
        personM.personId = [model.type isEqualToString:@"person"]?model.project_id:@"";
        personM.unionid = [model.type isEqualToString:@"user"]?model.project_id:@"";
        [PublicTool goPersonDetail:personM];
        
    }else  if (self.attentType == AttentType_Subject){
        
        QMPThemeDetailViewController *vc = [[QMPThemeDetailViewController alloc] init];
        vc.ticketID = model.ticket_id;
        vc.ticket = model.ticket;
        [self.navigationController pushViewController:vc animated:YES];

        return;
    }
}


@end
