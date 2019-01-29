//
//  PersonAllCompanyViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonAllCompanyViewController.h"
#import "PersonBusinessRoleCell.h"
#import "RegisterInfoViewController.h"
#import "PersonRoleModel.h"
#import "PersonModel.h"

@interface PersonAllCompanyViewController () <UITableViewDataSource, UITableViewDelegate, PersonBusinessRoleCellDelegate>
@property (nonatomic, strong) NSMutableArray *companyData;
@end

@implementation PersonAllCompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"所有的公司";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"PersonBusinessRoleCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"PersonBusinessRoleCellID"];
    [self.view addSubview:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(2, 0, 0, 0);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90;
    
    [self loadData];
}
- (void)loadData {
    [self showHUD];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.personModel.uniq_hid forKey:@"uniq_hid"];

    if (self.tableView.mj_header.isRefreshing) {
        [dict setValue:@"1" forKey:@"debug"];
    }
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"person/personRelation" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
           
            NSMutableArray *arr1 = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                PersonRoleModel *person = [[PersonRoleModel alloc] initWithDictionary:dic error:nil];
                [arr1 addObject:person];
            }
            self.companyData = arr1;
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.companyData.count == 0) {
        return 1;
    }
    return self.companyData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.companyData.count == 0) {
        return [self nodataCellWithInfo:@"没有数据" tableView:tableView];
    }
    PersonBusinessRoleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonBusinessRoleCellID"];
    PersonRoleModel *model = self.companyData[indexPath.row];
    cell.model = model;

    cell.companyNameLabel.text = model.qy_name;
    cell.descLabel.text = model.type;
    cell.registerCapitalLabel.text = model.qy_ziben.length > 0 ?[NSString stringWithFormat:@"注册资本 %@", model.qy_ziben] :@"  ";
    cell.tiemLabel.text = [model.qy_start_date stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    [cell.statusButton setTitle:(model.qy_status.length > 2 ? [model.qy_status substringToIndex:2]:model.qy_status) forState:UIControlStateNormal];
    cell.statusButton.hidden = !(model.qy_status.length > 0);
    cell.lineView.hidden = (indexPath.row + 1 == self.companyData.count);
    cell.delegate = self;
    
    cell.avatarLabel.hidden = YES;
    cell.avatarView.hidden = YES;
    NSString *icon = ![PublicTool isNull:model.product] ? model.pro_icon:model.jg_icon;
    if (![PublicTool isNull:icon] && ![icon containsString:@"upload/default"]) {
        cell.avatarView.hidden = NO;
        [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[BundleTool imageNamed:PROICON_DEFAULT]];
    } else {
        cell.avatarLabel.hidden = NO;
        cell.avatarLabel.text = model.qy_name.length > 0 ? [model.qy_name substringToIndex:1]:@"";
        cell.avatarLabel.backgroundColor = RANDOM_COLORARR[indexPath.row % 6];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.companyData.count == 0) {
        return SCREENH-kScreenTopHeight;
    }
    
    return UITableViewAutomaticDimension;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.companyData.count == 0) return;
    PersonRoleModel *model = self.companyData[indexPath.row];
    RegisterInfoViewController *registerDetailVC = [[RegisterInfoViewController alloc]init];
    NSString *detail = model.pro_detail.length ? model.pro_detail:model.jg_detail;
    if ([PublicTool isNull:detail]) {
        return;
    }
    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:[PublicTool toGetDictFromStr:detail]];
    [mdic removeObjectForKey:@"id"];
    [mdic removeObjectForKey:@"p"];
    registerDetailVC.urlDict = mdic;
    registerDetailVC.companyName = model.qy_name.length > 0 ? model.qy_name: @"";
    [self.navigationController pushViewController:registerDetailVC animated:YES];
}
- (void)personBusinessRoleCellAvatarClick:(PersonRoleModel *)personRole {
    NSString *detail = personRole.pro_detail.length ? personRole.pro_detail:personRole.jg_detail;
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:detail]];
}
@end
