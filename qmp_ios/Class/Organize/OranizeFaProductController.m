//
//  OranizeFaProductController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/21.
//  Copyright © 2018年 Molly. All rights reserved.
//  机构在服项目列表

#import "OranizeFaProductController.h"
#import "OrgFaProductModel.h"
#import "FAProductCell.h"

@interface OranizeFaProductController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_dataArr;
}
@end

@implementation OranizeFaProductController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"在服项目";
    _dataArr = [NSMutableArray array];
    
    [self addView];
    
    [self showHUD];
    [self requestData];
    
}

- (void)addView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    self.tableView.mj_header = self.mjHeader;
    
    self.tableView.mj_footer = self.mjFooter;
    
    [self.view addSubview:self.tableView];
    
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FAProductCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"FAProductCellID"];
}



#pragma mark --请求数据--
-(BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.dict];
    [AppNetRequest getJigouFAProductWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        if (resultData && resultData[@"list"] && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                OrgFaProductModel *company = [[OrgFaProductModel alloc]initWithDictionary:dic error:nil];
                [arr addObject:company];
            }
            [_dataArr addObjectsFromArray:arr];
            [self refreshFooter:@[]];
            
            [self.tableView reloadData];
        }
    }];
    return YES;
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
    return 135;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_dataArr.count == 0) {
        
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
        
    }else{
        
        FAProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FAProductCellID" forIndexPath:indexPath];
        cell.faProductM = _dataArr[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){
        return;
    }
    
    OrgFaProductModel *faProductM = [[OrgFaProductModel alloc]init];
    if ([PublicTool isNull:faProductM.detail]) {
        return;
    }
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:faProductM.detail]];
}
@end
