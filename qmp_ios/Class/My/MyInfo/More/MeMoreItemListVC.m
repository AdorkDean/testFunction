//
//  MeMoreItemListVC.m
//  qmp_ios
//
//  Created by QMP on 2018/5/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MeMoreItemListVC.h"

#import "TagsManagerViewController.h"
#import "CollectionListViewController.h"
#import "InvoiceListViewController.h"
#import "MyActivityListViewController.h"
#import "SettingTableViewCell.h"
#import "MeDocumentManagerVC.h"
#import "BPMgrController.h"
#import "CardListController.h"

@interface MeMoreItemListVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray * dataSourceArr;
@end

@implementation MeMoreItemListVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"工作台";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:@"SettingTableViewCellMoreItemCellID"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSourceArr count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SettingTableViewCellMoreItemCellID" forIndexPath:indexPath];
    NSDictionary *rowDict = self.dataSourceArr[indexPath.row];
    
    cell.titleLab.text = rowDict[@"title"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.leftImageV.image = [UIImage imageNamed:rowDict[@"icon"]];
    cell.lineView.hidden = (indexPath.row+1 == self.dataSourceArr.count);
    cell.redPointView.hidden = YES;
    cell.keyRedView.hidden = YES;
    
    if ([rowDict[@"title"] isEqualToString:@"BP管理"]) { //BP管理
        if ([WechatUserInfo shared].bp_count.integerValue) {
            cell.keyRedView.hidden = NO;
            [self.tabBarController.tabBar showBadgeOnItemIndex:3];
        }else{
            cell.keyRedView.hidden = YES;
            [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
        }
        
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * bgVw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 10)];
    bgVw.backgroundColor = TABLEVIEW_COLOR;
    return bgVw;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    NSString * selectIndexActionStr = self.dataSourceArr[indexPath.row][@"action"];
    SEL actionMethod = NSSelectorFromString(selectIndexActionStr);
    ((void (*)(id, SEL))[self methodForSelector:actionMethod])(self, actionMethod);
}

// 进入专辑管理
- (void)enterAlbums{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    TagsManagerViewController *albumsVC = [[TagsManagerViewController alloc] init];
    albumsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:albumsVC animated:YES];
}

- (void)enterMyNote{
    
    MyActivityListViewController *noteVC = [[MyActivityListViewController alloc] init];
    noteVC.type = MyActivityListViewControllerTypeNote;
    [self.navigationController pushViewController:noteVC animated:YES];
}

// 进入BP管理
- (void)enterMyBP {
    
    BPMgrController *bpVC = [[BPMgrController alloc]init];
    [self.navigationController pushViewController:bpVC animated:NO];
}
// 进入文档管理
- (void)enterMyDocument {
    
    MeDocumentManagerVC *downloadVC = [[MeDocumentManagerVC alloc]init];
    [self.navigationController pushViewController:downloadVC animated:YES];
    [QMPEvent event:@"me_tab_downCellClick"];
}

- (void)enterCard{
    CardListController *cardVC = [[CardListController alloc]init];
    
    [self.navigationController pushViewController:cardVC animated:YES];
}

// 进入网页收藏
- (void)enterWebCollectList {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    //网页收藏
    CollectionListViewController *inVC = [[CollectionListViewController alloc] init];
    inVC.hidesBottomBarWhenPushed = YES;
    inVC.navigationItem.title = @"网页收藏";
    [self.navigationController pushViewController:inVC animated:YES];
    [QMPEvent event:@"me_tab_newsClick"];
}
// 进入发票抬头
- (void)enterMyInvoice{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    //发票抬头
    InvoiceListViewController *inVC = [[InvoiceListViewController alloc] init];
    inVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:inVC animated:YES];
    [QMPEvent event:@"me_tab_receiptClick"];
}


- (NSMutableArray *)dataSourceArr{
    if (_dataSourceArr == nil) {
        _dataSourceArr = [[NSMutableArray alloc] initWithArray:@[
                                                                 @{@"title":@"BP管理", @"icon":@"me_bp",@"action":@"enterMyBP",},
                                                                 @{@"title":@"我的报告", @"icon":@"me_document",@"action":@"enterMyDocument",},
                                                                 @{@"title":@"我的笔记",@"icon":@"me_note",@"action":@"enterMyNote",@"extra":@"..."},
                                                                 @{@"title":@"我的专辑", @"icon":@"me_squareMgr", @"action":@"enterAlbums", @"extra":@"..."},
                                                                 @{@"title":@"上传名片", @"icon":@"me_card", @"action":@"enterCard", @"extra":@"..."},
                                                                 @{@"title":@"我的新闻", @"icon":@"me_webPage", @"action":@"enterWebCollectList", @"extra":@"..."},
                                                                 @{@"title":@"发票抬头", @"icon":@"me_invoce", @"action":@"enterMyInvoice", @"extra":@"..."},
                                                                 ]];
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
