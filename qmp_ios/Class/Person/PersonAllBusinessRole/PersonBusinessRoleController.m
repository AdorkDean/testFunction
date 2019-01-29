//
//  PersonBusinessRoleController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonBusinessRoleController.h"
#import "PersonBusinessRoleCell.h"
#import "PersonRoleModel.h"
#import "RegisterInfoViewController.h"
#import "PersonBusinessRoleCell.h"

@interface PersonBusinessRoleController () <UITableViewDataSource, UITableViewDelegate, PersonBusinessRoleCellDelegate>

@end

@implementation PersonBusinessRoleController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, self.view.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(2, 0, 0, 0);
    
    self.tableView.estimatedRowHeight = 90;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.height = self.view.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.datas.count == 0) {
        return 1;
    }
    return self.datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.datas.count == 0) {
        return [self nodataCellWithInfo:@"没有数据" tableView:tableView];
    }
    PersonBusinessRoleCell *roleCell = [PersonBusinessRoleCell cellWithTableView:tableView];
    PersonRoleModel *roleM = self.datas[indexPath.row];
    roleCell.model = roleM;
    roleCell.avatarLabel.backgroundColor = RANDOM_COLORARR[indexPath.row % 6];

    roleCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return roleCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.datas.count == 0) {
        return SCREENH-kScreenTopHeight-kPageMenuH;
    }
    return UITableViewAutomaticDimension;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.datas.count == 0) return;
    PersonRoleModel *model = self.datas[indexPath.row];
    RegisterInfoViewController *registerDetailVC = [[RegisterInfoViewController alloc]init];
    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:[PublicTool toGetDictFromStr:model.detail]];
    [mdic removeObjectForKey:@"id"];
    [mdic removeObjectForKey:@"p"];
    registerDetailVC.urlDict = mdic;
    registerDetailVC.companyName = model.company.length > 0 ? model.company: @"";
    [self.navigationController pushViewController:registerDetailVC animated:YES];
}
- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}
- (void)personBusinessRoleCellAvatarClick:(PersonRoleModel *)personRole {
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:personRole.detail]];
}
@end
