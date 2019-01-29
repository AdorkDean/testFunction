//
//  AlbumSearchController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/10/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "AlbumSearchController.h"
#import "AlbumMultiRowListCell.h"
#import "OneSquareListViewController.h"
#import "AlbumListCell.h"
#import "GroupModel.h"

@interface AlbumSearchController() <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate> {
    
    NSDate *_inputDate;
}
@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UISearchBar *mySearchBar;

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, strong) NSMutableArray *searchArr;
@property (nonatomic, copy) NSString *count;


@end

@implementation AlbumSearchController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_mySearchBar becomeFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"搜索专辑";
    [self setupViews];
    
}

- (void)setupViews {
    CGFloat height = 44;
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, height)];
    _tableHeaderView.backgroundColor = TABLEVIEW_COLOR;
    
    _mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(7, 0, SCREENW-14, height)];
    
    [_mySearchBar setBackgroundImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_mySearchBar.bounds.size]];
    
    //设置背景色
    [_mySearchBar setBackgroundColor:TABLEVIEW_COLOR];
    [_mySearchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_borderTab"] forState:UIControlStateNormal];
    [_mySearchBar setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
    UITextField *tf = [_mySearchBar valueForKey:@"_searchField"];
    NSString *str = @"输入关键词搜索";
    tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    tf.font = [UIFont systemFontOfSize:14];
    //    tf.delegate = self;
    
    //    _mySearchBar.placeholder = @"搜索报告关键词";
    _mySearchBar.delegate = self;
    [_tableHeaderView addSubview:_mySearchBar];
    
    
    //底部线条
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _tableHeaderView.height - 0.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [_tableHeaderView addSubview:line];
    
    [self.view addSubview:_tableHeaderView];
    
    
    
    //tableView
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, height, SCREENW, SCREENH - kScreenTopHeight-height) style:UITableViewStyleGrouped];
    
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if (![PublicTool isNull:searchBar.text]) {
        self.keyword = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self.mySearchBar resignFirstResponder];
        [self requestData];
    }
}
- (BOOL)requestData {
    if (![super requestData]) {
        return NO;
    }
    
    NSString *w = [self.keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//注意考虑特殊字符
    if ([PublicTool isNull:w]) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        [self hideHUD];
        
        return NO;
    }
    
    if (self.searchArr.count == 0) {
        [PublicTool showHudWithView:KEYWindow];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    [dic setValue:w forKey:@"keywords"];
    
//    [dic setValue:@"1" forKey:@"type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"album/getAlbumLists" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
    
//    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        
        NSMutableArray *companyMArr = [[NSMutableArray alloc] init];
        
        if (resultData && [resultData isKindOfClass:[NSArray class]]) {
            
            self.tableView.backgroundColor = TABLEVIEW_COLOR;
//            self.count = resultData[@"count"];
            
//            NSDictionary *dataMDict = resultData;
            
            for (NSDictionary *subDic in resultData) {
                GroupModel *model = [[GroupModel alloc]initWithDictionary:subDic error:nil];
                [companyMArr addObject:model];
            }
        }
        if (self.currentPage == 1) {
            [self.searchArr removeAllObjects];
        }
        [self.searchArr addObjectsFromArray:companyMArr];
        [self refreshFooter:companyMArr];
        [self.tableView reloadData];
        
    }];
    
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([PublicTool isNull:self.mySearchBar.text]) {
        return 0;
    }
    return self.searchArr.count ? self.searchArr.count:1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if(self.searchArr.count) {
//        AlbumMultiRowListCell *cell = [AlbumMultiRowListCell cellWithTableView:tableView];
//        cell.keyword =  _mySearchBar.text;
//        return cell;
        
        AlbumListCell *cell = [AlbumListCell cellWithTableView:tableView];
        cell.groupM = self.searchArr[indexPath.row];
        return cell;
    }
    
    NSString *title = REQUEST_DATA_NULL;
    HomeInfoTableViewCell *cell = [self nodataCellWithInfo:title tableView:tableView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (self.searchArr.count == 0) {
        return tableView.height;
    }
    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.mySearchBar resignFirstResponder];
    if (self.searchArr.count == 0) {
        return;
    }
    
    OneSquareListViewController *listVC = [[OneSquareListViewController alloc] init];
    listVC.groupModel = self.searchArr[indexPath.row];
    listVC.action = @"ManagerSquare";
    [self.navigationController pushViewController:listVC animated:YES];
}

#pragma mark - Getter
- (NSMutableArray *)searchArr {
    if (!_searchArr) {
        _searchArr = [NSMutableArray array];
    }
    return _searchArr;
}

@end
