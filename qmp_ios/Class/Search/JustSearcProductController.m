//
//  JustSearcProductController.m
//  qmp_ios
//
//  Created by QMP on 2018/10/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "JustSearcProductController.h"
#import "IPOCompanyCell.h"
#import "SearchPersonCell.h"
#import "GetMd5Str.h"

@interface JustSearcProductController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    
    NSDate *_inputDate;
}
@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UISearchBar *mySearchBar;

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, strong) NSMutableArray *productData;
@property (nonatomic, copy) NSString *count;

@property (nonatomic, assign) BOOL showKey;
@property (nonatomic, strong) NSMutableArray *keyArr;

@end
@implementation JustSearcProductController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"搜索项目";
    self.count = @"";
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
    [_mySearchBar setSearchFieldBackgroundImage:[BundleTool imageNamed:@"search_borderTab"] forState:UIControlStateNormal];
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
    
    [_mySearchBar becomeFirstResponder];
    
    
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
        self.showKey = NO;
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
    
    if (self.productData.count == 0) {
        [PublicTool showHudWithView:KEYWindow];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    [dic setValue:w forKey:@"keywords"];
    
    [dic setValue:@"1" forKey:@"type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    
    
    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        
        NSMutableArray *companyMArr = [[NSMutableArray alloc] init];

        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            
            self.tableView.backgroundColor = TABLEVIEW_COLOR;
            self.count = resultData[@"count"];
           
            NSDictionary *dataMDict = resultData;
            
            for (NSDictionary *subDic in dataMDict[@"list"]) {
                SearchCompanyModel * model = [[SearchCompanyModel alloc]init];
                [model setValuesForKeysWithDictionary:subDic];
                [companyMArr addObject:model];
            }
        }
        if (self.currentPage == 1) {
            [self.productData removeAllObjects];
        }
        [self.productData addObjectsFromArray:companyMArr];
        [self refreshFooter:companyMArr];
        [self.tableView reloadData];
        
    }];
    
    return YES;
}

#pragma mark - 关键词联想
- (void)searchDetailWithKey:(NSString *)key{
    self.showKey = YES;
    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"l/wdptips" HTTPBody:@{@"w":key} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        
        if (resultData && [resultData isKindOfClass:[NSArray class]]) {
            self.keyArr = [NSMutableArray arrayWithArray:resultData];
            if (self.showKey) {
                [self.tableView reloadData];
            }
            
            self.mjFooter.stateLabel.hidden = YES;
            
        }else{
            
            self.showKey = NO;
        }
        
        [self.tableView.mj_header endRefreshing];
        
    }];
    
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.showKey ? 1 : (self.productData.count ? 1: ([PublicTool isNull:self.mySearchBar.text] ? 0 : 1));
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.showKey) {
        return self.keyArr.count;
    }
    return self.productData.count ? self.productData.count:1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showKey) {
        static NSString *cellIdentifier = @"keyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = self.keyArr[indexPath.row];
        UIView *line = [cell.contentView viewWithTag:2000];
        if (!line) {
            line = [[UIView alloc]initWithFrame:CGRectMake(0,50-0.5, SCREENW, 0.5)];
            line.backgroundColor = LIST_LINE_COLOR;
            [cell.contentView addSubview:line];
            line.tag = 2000;
        }
        return cell;
    }
    
    if(self.productData.count) {
        static NSString *ID2 = @"IPOCompanyCell";
        IPOCompanyCell *cell =  [tableView dequeueReusableCellWithIdentifier:ID2];
        if (!cell) {
            cell = [[IPOCompanyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID2];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        SearchCompanyModel * model = self.productData[indexPath.row];
        [cell refreshUI:model];
        cell.iconBgColor = RANDOM_COLORARR[indexPath.row % 6];
        if (@available(iOS 8.2, *)) {
            cell.productLab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        }else{
            cell.productLab.font = [UIFont systemFontOfSize:15];
        }
        return cell;
    }
    
    NSString *title = REQUEST_DATA_NULL;
    HomeInfoTableViewCell *cell = [self nodataCellWithInfo:title tableView:tableView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showKey) {
        return 50;
    }
    if (self.productData.count == 0) {
        return tableView.height;
    }
    return 77;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.showKey) {
        return 0.00001;
    }
    NSArray *arr = [self sectionDataWithSection:section];
    return arr.count > 0 ? 45 : 0.00001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.showKey) {
        return [UIView new];
    }

    NSArray *arr = [self sectionDataWithSection:section];
    if (arr.count == 0) {
        return [UIView new];
    }
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, SCREENW, 45);
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(16, 0, 200, 45);
    label.textColor = H9COLOR;
    label.font = [UIFont systemFontOfSize:13];
    label.text = [NSString stringWithFormat:@"项目（%@）", self.count];
    [view addSubview:label];

    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake(0, 44.5, SCREENW, 0.5);
    line.backgroundColor = LIST_LINE_COLOR;
    [view addSubview:line];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.mySearchBar resignFirstResponder];
    if (self.showKey) {
        self.showKey = NO;
        NSString *str = self.keyArr[indexPath.row];
        self.mySearchBar.text = str;
        if (![PublicTool isNull:str]) {
            [self.keyArr removeAllObjects];
            [self.tableView reloadData];
            self.keyword = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self.mySearchBar resignFirstResponder];
            [self requestData];
        }
        return;
    }
    if (self.productData.count == 0) {
        return;
    }
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:[self.productData[indexPath.row] detail]]];
}
- (NSArray *)sectionDataWithSection:(NSInteger)section {
    
    return self.productData;
}

#pragma mark - Getter
- (NSMutableArray *)productData {
    if (!_productData) {
        _productData = [NSMutableArray array];
    }
    return _productData;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    
    if([PublicTool isNull:searchText]){
        self.showKey = NO;
        self.keyArr = [NSMutableArray array];
        self.productData = nil;
        [self.tableView reloadData];
    }
    else{
        
        if ([TestNetWorkReached networkIsReached:self]) {
            if (_inputDate) {
                NSTimeInterval second = [[NSDate date] timeIntervalSinceDate:_inputDate];
                if (second <0.5) {
                    return;
                }
            }
            QMPLog(@"搜索关键字--------%@",searchText);
            _inputDate = [NSDate date];
            [self searchDetailWithKey:searchText];
        }
    }
    
}

@end
