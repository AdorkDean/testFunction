//
//  PostSelectRelateViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/6/30.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PostSelectRelateViewController.h"
#import "SearchPerson.h"
#import "SearchJigouModel.h"
#import "SearchJigouCell.h"
#import "IPOCompanyCell.h"
#import "SearchPersonCell.h"
#import "GetMd5Str.h"

@interface PostSelectRelateViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    
    NSDate *_inputDate;
}
@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UISearchBar *mySearchBar;


@property (nonatomic, copy) NSString *keyword;

@property (nonatomic, strong) NSMutableArray *sectionTitles;
@property (nonatomic, strong) NSMutableArray *productData;
@property (nonatomic, strong) NSMutableArray *organizeData;
@property (nonatomic, strong) NSMutableArray *personData;

@property (nonatomic, strong) NSMutableDictionary *exploredDict;

@property (nonatomic, assign) BOOL showKey;
@property (nonatomic, strong) NSMutableArray *keyArr;
@end
@implementation PostSelectRelateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [IQKeyboardManager sharedManager].enable = NO;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
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
    self.tableView.delegate  = self;
    self.tableView.dataSource = self;
    self.tableView.mj_footer = self.mjFooter;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
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

    
    [PublicTool showHudWithView:KEYWindow];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    [dic setValue:w forKey:@"keywords"];
    
    [dic setValue:@"" forKey:@"type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    
    
    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
//        _resultCount = @"";
        
        self.productData =  nil;
        self.personData = nil;
        self.organizeData = nil;
        self.sectionTitles = nil;
        
        
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            
            self.tableView.backgroundColor = TABLEVIEW_COLOR;
            
            NSArray *order = resultData[@"order"];
            
            
            NSDictionary *dataMDict = resultData;
            
            NSMutableArray *companyMArr = [[NSMutableArray alloc] init];
            for (NSDictionary *subDic in dataMDict[@"product"][@"list"]) {
                SearchCompanyModel * model = [[SearchCompanyModel alloc]init];
                [model setValuesForKeysWithDictionary:subDic];
                [companyMArr addObject:model];
            }
            [self.productData addObjectsFromArray:companyMArr];
            
            
            NSMutableArray *organizeMArr = [[NSMutableArray alloc] init];
            for (NSDictionary *subDic in dataMDict[@"institution"][@"list"]) {
                SearchJigouModel *model = [[SearchJigouModel alloc]init];
                [model setValuesForKeysWithDictionary:subDic];
                [organizeMArr addObject:model];
            }
            [self.organizeData addObjectsFromArray:organizeMArr];
            
            
            NSMutableArray *personMArr = [[NSMutableArray alloc] init];
            for (NSDictionary *subDic in dataMDict[@"person"][@"list"]) {
                SearchPerson *person = [[SearchPerson alloc]initWithDictionary:subDic error:nil];
                [personMArr addObject:person];
            }
            [self.personData addObjectsFromArray:personMArr];
            
            //无数据 再处理工商
            _sectionTitles = [NSMutableArray array];
            for (NSString *section in order) {
                if ([section isEqualToString:@"product"]) {
                    if (self.productData.count) {
                        [_sectionTitles addObject:@"项目"];
                    }
                } else if ([section isEqualToString:@"person"]) {
                    if (self.personData.count) {
                        [_sectionTitles addObject:@"人物"];
                    }
                } else if ([section isEqualToString:@"institution"]) {
                    if (self.organizeData.count) {
                        [_sectionTitles addObject:@"机构"];
                    }
                }
            }
        }
        
//        [self initTableHeaderView];
        [self refreshFooter:@[]];
        [self.tableView reloadData];
        
    }];
    
    return YES;
}
- (void)sectionFooterLabelTap:(UITapGestureRecognizer *)tapGest {
    NSInteger index = tapGest.view.tag;
    NSString *sectionTitle = self.sectionTitles[index];
    BOOL explored = [self exploredStatusWithSection:index];
    [self.exploredDict setValue:@(!explored) forKey:sectionTitle];
    [self.tableView reloadData];
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
    if (self.showKey) {
        return 1;
    }
    return self.sectionTitles.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.showKey) {
        return MIN(5, self.keyArr.count);
    }
    if (self.organizeData.count == 0 && self.productData.count == 0 && self.personData.count == 0) {
        return 1;
    }
    NSArray *arr = [self sectionDataWithSection:section];
    BOOL explored = [self exploredStatusWithSection:section];
    if (explored) {
        return arr.count;
    }
    return MIN(arr.count, 5);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showKey) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
        static NSString *cellIdentifier = @"keyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = self.keyArr[indexPath.row];
        UIView *line = [cell.contentView viewWithTag:2000];
        if (!line) {
            line = [[UIView alloc]initWithFrame:CGRectMake(17,50-0.5, SCREENW-34, 0.5)];
            line.backgroundColor = LIST_LINE_COLOR;
            [cell.contentView addSubview:line];
            line.tag = 2000;
        }
        return cell;
    }
    
    NSString *sectionTitle = self.sectionTitles[indexPath.section];
    if ([sectionTitle isEqualToString:@"机构"]) {
        SearchJigouCell *cell = [SearchJigouCell searchJigouCellWithTableView:tableView];
        SearchJigouModel *model = self.organizeData[indexPath.row];
        [cell refreshUI:model];
        if (@available(iOS 8.2, *)) {
            cell.jigou_nameLab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        }else{
            cell.jigou_nameLab.font = [UIFont systemFontOfSize:15];
        }
        cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
        return cell;
    } else if ([sectionTitle isEqualToString:@"项目"]) {
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
        
    }else if ([sectionTitle isEqualToString:@"人物"]) {
        static NSString *ID2 = @"SearchPersonCellID";
        
        SearchPersonCell *cell =  [tableView dequeueReusableCellWithIdentifier:ID2];
        if (!cell) {
            cell = (SearchPersonCell *)[[BundleTool commonBundle]loadNibNamed:@"SearchPersonCell" owner:nil options:nil].lastObject;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        SearchPerson * model = self.personData[indexPath.row];
        cell.person2 = model;
        cell.nametitColor = RANDOM_COLORARR[indexPath.row%6];
        
       
        cell.claimBtn.hidden = YES;
        
        if (cell.person.claim_type.integerValue == 2) {
            cell.renzhengIcon.hidden = NO;
        }else{
            cell.renzhengIcon.hidden = YES;
        }
        cell.nameLab = RANDOM_COLORARR[indexPath.row % 6];
        cell.renzhengIcon.hidden = YES; //HT注：去掉主搜索中的“综合”人物 V 标签
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
    if (self.organizeData.count == 0 && self.productData.count == 0 && self.personData.count == 0) {
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
    NSString *sectionTitle = self.sectionTitles[section];
    NSArray *arr = [self sectionDataWithSection:section];
    
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, SCREENW, 45);
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(16, 0, 200, 45);
    label.textColor = H9COLOR;
    label.font = [UIFont systemFontOfSize:13];
    label.text = [NSString stringWithFormat:@"%@（%zd）", sectionTitle, arr.count];
    [view addSubview:label];
    
    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake(0, 44.5, SCREENW, 0.5);
    line.backgroundColor = LIST_LINE_COLOR;
    [view addSubview:line];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.showKey) {
        return 0.00001;
    }
    NSArray *arr = [self sectionDataWithSection:section];
    if (arr == 0) {
        return 0.00001;
    }
    return arr.count > 5 ? 55 : 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.showKey) {
        return [UIView new];
    }
    NSArray *arr = [self sectionDataWithSection:section];
    if (arr.count == 0) {
        return [[UIView alloc] init];
    }
    
    if (arr.count <= 5) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, SCREENW, 10);
        view.backgroundColor = TABLEVIEW_COLOR;
        return view;
    }
    
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, SCREENW, 55);
    view.backgroundColor = TABLEVIEW_COLOR;
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, SCREENW, 45);
    label.textColor = BLUE_TITLE_COLOR;
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor whiteColor];
    label.text = @"查看全部";
    [view addSubview:label];
    
    BOOL explored = [self exploredStatusWithSection:section];
    label.text = explored ? @"收起" : @"查看全部";
    
    label.tag = section;
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionFooterLabelTap:)];
    [label addGestureRecognizer:tapGest];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showKey) {
        self.showKey = NO;
        NSString *str = self.keyArr[indexPath.row];
        self.mySearchBar.text = str;
        if (![PublicTool isNull:str]) {
            self.keyword = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self.mySearchBar resignFirstResponder];
            [self requestData];
        }
        return;
    }
    if (self.organizeData.count == 0 && self.productData.count == 0 && self.personData.count == 0) {
        return;
    }
    NSString *sectionTitle = self.sectionTitles[indexPath.section];
    NSArray *arr = [self sectionDataWithSection:indexPath.section];
    if (self.didSelectedObject) {
        self.didSelectedObject(arr[indexPath.row], sectionTitle);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSArray *)sectionDataWithSection:(NSInteger)section {
    NSString *sectionTitle = self.sectionTitles[section];
    if ([sectionTitle isEqualToString:@"项目"]) {
        return self.productData;
    }
    if ([sectionTitle isEqualToString:@"机构"]) {
        return self.organizeData;
    }
    return self.personData;
}
- (BOOL)exploredStatusWithSection:(NSInteger)section {
    NSString *sectionTitle = self.sectionTitles[section];
    return [self.exploredDict[sectionTitle] boolValue];
}
#pragma mark - Getter
- (NSMutableDictionary *)exploredDict {
    if (!_exploredDict) {
        _exploredDict = [NSMutableDictionary dictionaryWithDictionary:@{@"项目":@(0),@"机构":@(0),@"人物":@(0)}];
    }
    return _exploredDict;
}
- (NSMutableArray *)sectionTitles {
    if (!_sectionTitles) {
        _sectionTitles = [NSMutableArray array];
    }
    return _sectionTitles;
}
- (NSMutableArray *)productData {
    if (!_productData) {
        _productData = [NSMutableArray array];
    }
    return _productData;
}
- (NSMutableArray *)organizeData {
    if (!_organizeData) {
        _organizeData = [NSMutableArray array];
    }
    return _organizeData;
}
- (NSMutableArray *)personData {
    if (!_personData) {
        _personData = [NSMutableArray array];
    }
    return _personData;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    
    if([PublicTool isNull:searchText]){
        self.showKey = NO;
        self.keyArr = [NSMutableArray array];
        self.productData = nil;
        self.organizeData = nil;
        self.personData = nil;
        _sectionTitles = nil;
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
