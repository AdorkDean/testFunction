//
//  RelateCompanyController.m
//  qmp_ios
//
//  Created by QMP on 2018/2/9.
//  Copyright © 2018年 Molly. All rights reserved.
//  机构相关公司列表

#import "FAProductListController.h"
#import "FAProductCell.h"


@interface FAProductListController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation FAProductListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"在服项目";
    
    [self addView];    
}

- (void)addView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    
    self.tableView.estimatedRowHeight = 87;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.1f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (_dataArr.count == 0) {
        return 0.1f;
    }
    else{
        
        return 0.1;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count ? _dataArr.count:1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_dataArr.count == 0)
    {
        return SCREENH - kScreenTopHeight;
    }
    return 87;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_dataArr.count == 0) {
        
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
        
    }else{
        FAProductCell *cell = [FAProductCell cellWithTableView:tableView];
        cell.faProductM = self.dataArr[indexPath.row];
        return cell;
    }
  
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_dataArr.count == 0){return;}
    OrgFaProductModel *faProductM = self.dataArr[indexPath.row];
    if ([PublicTool isNull:faProductM.detail]) {
        return;
    }
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:faProductM.detail]];
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
