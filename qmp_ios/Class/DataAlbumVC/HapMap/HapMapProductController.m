//
//  HapMapProductController.m
//  qmp_ios
//
//  Created by QMP on 2017/11/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "HapMapProductController.h"
#import "ProductListCell.h"
#import "StarProductsModel.h"

@interface HapMapProductController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_productArr;
}
@end

@implementation HapMapProductController


- (void)viewDidLoad {
    [super viewDidLoad];
    _productArr = [NSMutableArray array];
    self.title = self.tagStr;
    self.currentPage = 1;
    self.numPerPage = 20;
    [self setUI];
    [self showHUD];
    [self requestData];
}

- (void)setUI{
    
    CGFloat height = self.fromLingyu ? SCREENH - kScreenTopHeight  : SCREENH-kScreenTopHeight - 44;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW,height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.mj_header = self.mjHeader;
    [self.tableView registerNib:[UINib nibWithNibName:@"ProductListCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"ProductListCellID"];
}

- (BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    
    if (self.fromLingyu) {
        NSDictionary *dic = @{@"tag":self.tagStr?self.tagStr:@"", @"num":@(self.numPerPage),@"page":@(self.currentPage),@"orderby":@"2",@"client_type":@"ios",@"debug":self.tableView.mj_header.isRefreshing ? @"1":@"0"};

        
        [AppNetRequest getProOfLingyuWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
            if (resultData && [resultData isKindOfClass:[NSDictionary class]] && resultData[@"startup_company"] && resultData[@"startup_company"][@"list"]) { //项目列表
                NSMutableArray *arr = [NSMutableArray array];
                if (self.currentPage == 1) {
                    [_productArr removeAllObjects];
                }
                for (NSDictionary *dic in resultData[@"startup_company"][@"list"]) {
                    StarProductsModel *productM = [[StarProductsModel alloc]initWithDictionary:dic error:nil];
                    productM.curlunci = productM.lunci;
                    [arr addObject:productM];
                }
                [_productArr addObjectsFromArray:arr];
                [self refreshFooter:arr];
            }
            
            [self.tableView reloadData];
            
        }];
        
    }else{
        
        NSDictionary *dic = @{@"tag":self.tagStr?self.tagStr:@"", @"num":@(self.numPerPage),@"curpage":@(self.currentPage)};
        
        if ([self.tableView.mj_header isRefreshing]) {
            dic = @{@"tag":self.tagStr?self.tagStr:@"", @"num":@(self.numPerPage),@"curpage":@(self.currentPage),@"debug":@"1"};
        }
        
        [AppNetRequest getProductByTagWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
            if (resultData && [resultData isKindOfClass:[NSDictionary class]] && resultData[@"list"]) { //项目列表
                NSMutableArray *arr = [NSMutableArray array];
                if (self.currentPage == 1) {
                    [_productArr removeAllObjects];
                }
                for (NSDictionary *dic in resultData[@"list"]) {
                    StarProductsModel *productM = [[StarProductsModel alloc]initWithDictionary:dic error:nil];
                    [arr addObject:productM];
                }
                [_productArr addObjectsFromArray:arr];
                [self refreshFooter:arr];
            }
            
            [self.tableView reloadData];
            
        }];
    }
    return YES;
}


#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.1f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
        return 0.1;
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
    if (_productArr.count == 0 ) {
        return 1;
    }
    else{
        return _productArr.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_productArr.count == 0) {
        
        CGFloat height = self.fromLingyu ? SCREENH - kScreenTopHeight  : SCREENH-kScreenTopHeight - 44;
        return height;
    }
    return 80;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_productArr.count == 0) {
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
        
    }else{
        
        ProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductListCellID" forIndexPath:indexPath];        
        StarProductsModel *model = _productArr[indexPath.row];
        cell.productM = model;
        cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
        NSLog(@"row -------%ld--lunci--------%@--",indexPath.row,model.lunci);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_productArr.count == 0) {
        return;
    }else{
        StarProductsModel *model = _productArr[indexPath.row];
        NSDictionary *urlDict = [NSDictionary dictionaryWithDictionary:[PublicTool toGetDictFromStr:model.detail]];
        [[AppPageSkipTool shared] appPageSkipToProductDetail:urlDict];
    }
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
