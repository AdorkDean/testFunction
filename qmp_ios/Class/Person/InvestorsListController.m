//
//  InvestorsListController.m
//  qmp_ios
//
//  Created by QMP on 2017/12/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "InvestorsListController.h"
#import "PersonModel.h"
#import "InvestorListCell.h"
#import "RzEventFilterView.h"
#import "SearchPersonVC.h"
#import "AuthenticationController.h"
#import "CardExchangeListController.h"
#import "PersonsFilterView.h"

#define TabNameKey @"personKu"

@interface InvestorsListController ()<UITableViewDataSource,UITableViewDelegate,PersonsFilterViewDelegate,UISearchBarDelegate>
{
    BOOL isFilter;
    PersonsFilterView *_filterV;
    NSInteger _searchCurrentPage;
}
@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UIButton *cancleSearchBtn;
@property (assign, nonatomic) BOOL isSearch;

@property (nonatomic,strong) NSMutableArray *searchArr;

@property (nonatomic,strong) NSMutableArray *dataArr;
@property (strong, nonatomic) UIView *filterV;//筛选页面
@property (strong, nonatomic) UIButton *filterBtn;//筛选按钮
@property (strong, nonatomic) NSMutableArray *selectedRoleMArr;
@property (strong, nonatomic) NSMutableArray *selectedIndustryMArr;
@property (strong, nonatomic) NSMutableArray *selectedProvinceMArr;

@property (strong, nonatomic) UIView *firstView;
@property (strong, nonatomic) FMDatabase *db;

@property (nonatomic, strong) UIView * searchBelowBgVw;//搜索结果，最底层显示
@end

@implementation InvestorsListController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [QMPEvent beginEvent:@"trz_personlist_timer"];
    self.tableView.backgroundColor = [UIColor whiteColor];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [QMPEvent endEvent:@"trz_personlist_timer"];
    
}
-(void)viewDidDisappear:(BOOL)animated{ //不保存筛选数据
    [super viewDidDisappear:animated];
    if ((self.selectedProvinceMArr.count || self.selectedIndustryMArr.count || self.selectedRoleMArr.count)&& self.navigationController == nil) { //要看实际页面层级关系
        [self updateFiltIndustryArr:[NSMutableArray array] withRoleMArr:[NSMutableArray array]  provinceMArr:[NSMutableArray array]];
    }
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _db = [[DBHelper shared] toGetDB];

    [self buildBarbutton];
    [self initTableView];
    self.title = @"极速找人";
    
    self.currentPage = 1;
    self.numPerPage = 20;
    _searchCurrentPage = 1;

    [self showHUD];
    [self requestData];
    
    [self keyboardManager];

}

- (void)buildBarbutton{
    
    if (_isSearch) {
        UIButton *contactBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        [contactBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [contactBtn setImage:[UIImage imageNamed:@"contact_nabar"] forState:UIControlStateNormal];
        [contactBtn addTarget:self action:@selector(enterMyContact) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *contactBarItem = [[UIBarButtonItem alloc]initWithCustomView:contactBtn];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = RIGHTNVSPACE;
        if (iOS11_OR_HIGHER) {
            self.navigationItem.rightBarButtonItems = @[contactBarItem];
        }else{
            self.navigationItem.rightBarButtonItems = @[ negativeSpacer,contactBarItem];
        }
        return;
    }
    NSString *btnImg = @"bar_setgray";

    if (self.selectedIndustryMArr.count > 0 || self.selectedRoleMArr.count > 0 || self.selectedProvinceMArr.count > 0) {
        
        btnImg = @"bar_setBlue";
    }
    
    self.filterBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
    [self.filterBtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
    [self.filterBtn setImage:[UIImage imageNamed:btnImg] forState:UIControlStateNormal];
    [self.filterBtn addTarget:self action:@selector(pressNotStoreFilterBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.filterBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.filterBtn.enabled = YES;
    
    UIButton *contactBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [contactBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [contactBtn setImage:[UIImage imageNamed:@"contact_nabar"] forState:UIControlStateNormal];
    [contactBtn addTarget:self action:@selector(enterMyContact) forControlEvents:UIControlEventTouchUpInside];

    UIView *rightV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 84, 44)];
    self.filterBtn.frame = CGRectMake(42, 0, 42, 44);
    contactBtn.frame = CGRectMake(0, 0, 42, 44);
    [rightV addSubview:contactBtn];
    [rightV addSubview:self.filterBtn];

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightV];

    if (iOS11_OR_HIGHER) {
        
        self.navigationItem.rightBarButtonItems = @[rightItem];
        
    }else{
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = RIGHTNVSPACE;
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,rightItem];
    }
    

}

- (void)initTableView{
    
    CGFloat tableHeight = SCREENH - kScreenTopHeight;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, tableHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    self.tableView.mj_header = self.mjHeader;
    
    self.tableView.mj_footer = self.mjFooter;
    
    [self.view addSubview:self.tableView];
    
    
    self.tableView.estimatedRowHeight = 74;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"InvestorListCell" bundle:nil] forCellReuseIdentifier:@"InvestorListCellID"];

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
    NSString *str = @"搜索姓名、项目、公司、机构";
    tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    tf.font = [UIFont systemFontOfSize:14];
    
    //    _mySearchBar.placeholder = @"搜索报告关键词";
    _mySearchBar.delegate = self;
    [_tableHeaderView addSubview:_mySearchBar];
    
    CGFloat width = 60.f;
    _cancleSearchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, height)];
    [_cancleSearchBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancleSearchBtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
    _cancleSearchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_cancleSearchBtn addTarget:self action:@selector(pressCancleSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
    _cancleSearchBtn.frame = CGRectMake(SCREENW - width-1, (_tableHeaderView.frame.size.height - height)/2, width, height);
    
    //底部线条
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _tableHeaderView.height - 0.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [_tableHeaderView addSubview:line];
    
    self.tableView.tableHeaderView = _tableHeaderView;
}
#pragma mark 成为投资人
- (void)becomeInvestorBtnClick{
    

    if (_isSearch) { //投资人搜索结果页，直接创建自己，成为官方人物
        
        AuthenticationController  *createVC = [[AuthenticationController alloc]init];
        createVC.searchName = [_mySearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        createVC.role = PersonRole_Investor;
        [self.navigationController pushViewController:createVC animated:YES];

    }else{
        
        SearchPersonVC *searchVC  = [[SearchPersonVC alloc]init];
        searchVC.type = SearchfromTypeInvestor;
        searchVC.keyword = [WechatUserInfo shared].nickname;
        [self.navigationController pushViewController:searchVC animated:YES];
    }
}


- (void)enterMyContact{
    CardExchangeListController *contactVC = [[CardExchangeListController alloc]init];
    [self.navigationController pushViewController:contactVC animated:YES];
}

- (void)beginSearch:(NSString*)text{
//    [self isHiddenInvestorVw:true];
    if (!self.isSearch) {
        
        self.isSearch = YES;
        CGRect frame = self.mySearchBar.frame;
        frame.size.width = SCREENW - 58;
        self.mySearchBar.frame = frame;
        
        [self.tableHeaderView addSubview:self.cancleSearchBtn];
        
        [self.tableView reloadData];
    }

    self.mySearchBar.text = text;
    _searchCurrentPage = 1;
    self.tableView.mj_header = nil;
    [self requestData];
}

- (void)pressCancleSearchBtn:(UIButton *)sender{
    [self cancleSearch];
}

- (void)disAppear{  //左右切换
    
    if (self.mySearchBar.text.length == 0 && self.isSearch) {
        [self cancleSearch];
    }
}

- (void)cancleSearch{
    self.isSearch = NO;
    [self buildBarbutton];
    [self.searchArr removeAllObjects];
    
    [self.mySearchBar resignFirstResponder];
    CGRect frame = self.mySearchBar.frame;
    frame.size.width = SCREENW-14;
    self.mySearchBar.frame = frame;
    self.mySearchBar.text = @"";
    _searchCurrentPage = 1;
    [self.cancleSearchBtn removeFromSuperview];
    self.tableView.mj_header = self.mjHeader;
    [self refreshFooter:self.dataArr];
    [self.tableView reloadData];
//    [self isHiddenInvestorVw:false];
}


-(BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    NSInteger isdebug = [self.tableView.mj_header isRefreshing] ? 1 : 0;
    NSString *industry = @"";
    NSString *role = @"";
    NSString *city =  @"";
    if (self.selectedIndustryMArr.count) {
        industry = [self.selectedIndustryMArr componentsJoinedByString:@"|"];
    }
    if (self.selectedRoleMArr.count) {
        role = [self.selectedRoleMArr componentsJoinedByString:@"|"];
    }
    role = [role stringByReplacingOccurrencesOfString:@"投资人" withString:@"investor"];
    role = [role stringByReplacingOccurrencesOfString:@"创业者" withString:@"cyz"];
    role = [role stringByReplacingOccurrencesOfString:@"其他" withString:@"other"];

    if (self.selectedProvinceMArr.count) {
        city = [self.selectedProvinceMArr componentsJoinedByString:@"|"];
    }
    
    NSDictionary *dic;
    
    if (self.isSearch) {
        dic = @{@"page":@(_searchCurrentPage),@"num":@(self.numPerPage),@"keywords":_mySearchBar.text};
        if (_searchCurrentPage == 1 && !self.tableView.mj_header.isRefreshing) {
            [PublicTool showHudWithView:KEYWindow];
        }
        self.tableView.mj_header = nil;
        
    }else{
        
        dic = @{@"page":@(self.currentPage),@"num":@(self.numPerPage),@"debug":@(isdebug),@"lingyu":industry,@"role":role,@"city":city};
    }
    
    [AppNetRequest getPersonListWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
       
        [PublicTool dismissHud:KEYWindow];

        self.filterBtn.enabled = YES;
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && resultData[@"list"]) {
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                PersonModel *person = [[PersonModel alloc]initWithDictionary:dic error:nil];
                [arr addObject:person];
            }
            if (self.isSearch) {
                if (_searchCurrentPage == 1) {
                    [self.searchArr removeAllObjects];
                }
                _searchCurrentPage ++;
                
                [self.searchArr addObjectsFromArray:arr];
            }else{
                if (self.currentPage == 1) {
                    [self.dataArr removeAllObjects];
                }
                
                [self.dataArr addObjectsFromArray:arr];
            }
            
            [self refreshFooter:arr];

            [self.tableView reloadData];
            isFilter = NO;
        }
    }];
    return YES;
}

-(void)keyboardManager{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.view.userInteractionEnabled = YES;
}

- (void)keyboardHide:(UITapGestureRecognizer *)tap{
    
    if (tap.view != self.mySearchBar) {
        if (self.isSearch && [self.mySearchBar.text isEqualToString:@""]) {
            [self cancleSearch];
        }
        else{
            [self.mySearchBar resignFirstResponder];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RzEventFilterViewDelegate
-(void)updateFiltIndustryArr:(NSMutableArray *)selectedMArr withRoleMArr:(NSMutableArray *)roleMArr provinceMArr:(NSMutableArray *)provinceArr{
    isFilter = YES;
    self.selectedIndustryMArr = [NSMutableArray arrayWithArray:selectedMArr];
    self.selectedProvinceMArr = [NSMutableArray arrayWithArray:provinceArr];
    self.selectedRoleMArr = [NSMutableArray arrayWithArray:roleMArr];

    //处理筛选项的选中状态
    if ([_db open]) {
        
        NSString *tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterindustry",TabNameKey]];
       //行业
        NSString *values = [self handleArrToSqlStr:self.selectedIndustryMArr];
        NSString *selectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='1'  WHERE name in (%@)",tableName,values];
        NSString *notSelectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='0'  WHERE name not in (%@)",tableName,values];
        [_db executeUpdate:selectSql];
        [_db executeUpdate:notSelectSql];
        //角色
         NSString *roleTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterpersonrole",TabNameKey]];
        NSString *rolevalues = [self handleArrToSqlStr:self.selectedRoleMArr];
        NSString *roleselectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='1'  WHERE name in (%@)",roleTableName,rolevalues];
        NSString *rolenotSelectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='0'  WHERE name not in (%@)",roleTableName,rolevalues];
        [_db executeUpdate:roleselectSql];
        [_db executeUpdate:rolenotSelectSql];
        
        //省份
        NSString *provinceTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterprovince",TabNameKey]];
        NSString *provincevalues = [self handleArrToSqlStr:self.selectedProvinceMArr];
        NSString *provinceselectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='1'  WHERE name in (%@)",provinceTableName,provincevalues];
        NSString *provincenotSelectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='0'  WHERE name not in (%@)",provinceTableName,provincevalues];
        [_db executeUpdate:provinceselectSql];
        [_db executeUpdate:provincenotSelectSql];

    }
    
    [_db close];
    
    [self.tableView.mj_header beginRefreshing];
    [self buildBarbutton];
    //刷新时不可筛选
    self.filterBtn.enabled = NO;
    [QMPEvent event:@"trz_person_filter_sureclick"];
}

- (NSString *)handleArrToSqlStr:(NSMutableArray *)selectedMArr{
    
    NSString *values = @"";
    if (selectedMArr.count > 0) {
        values = [NSString stringWithFormat:@"'%@'",selectedMArr[0]];
        
        if (selectedMArr.count > 1) {
            for (int i = 1 ; i < selectedMArr.count; i++) {
                
                values = [NSString stringWithFormat:@"%@,'%@'",values,selectedMArr[i]];
            }
        }
    }
    return values;
}
#pragma mark - UISearchBar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    _searchCurrentPage = 1;
    
    if (!self.isSearch) {
        self.isSearch = YES;
        [self buildBarbutton];
        CGRect frame = searchBar.frame;
        frame.size.width = SCREENW - 58;
        searchBar.frame = frame;
        
        [self.tableHeaderView addSubview:self.cancleSearchBtn];
        
        self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
        
        [QMPEvent event:@"trz_person_searchclick"];
    }
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    _searchCurrentPage = 1;
    self.isSearch = YES;
    
    if ([searchBar.text isEqualToString:@""]) {
        self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
        self.tableView.mj_footer = nil;;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    if (![searchBar.text isEqualToString:@""]) {
        [self beginSearch:searchBar.text];
        [self.mySearchBar resignFirstResponder];
    }
}



#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.1f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
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
    if (_isSearch && ![self.mySearchBar.text isEqualToString:@""] && self.searchArr.count == 0) {
        return 1;
    }else{
        
        return self.isSearch ? self.searchArr.count : self.dataArr.count;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isSearch && ![PublicTool isNull:self.mySearchBar.text] && self.searchArr.count == 0) {
        return tableView.height;
    }else{
        
        if (self.dataArr.count == 0) {
            return tableView.height;
        }
        return UITableViewAutomaticDimension;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((_isSearch && ![self.mySearchBar.text isEqualToString:@""] && self.searchArr.count == 0) || (self.dataArr.count == 0)) {
        NSString *title = _isSearch ? REQUEST_SEARCH_NULL : REQUEST_FILTER_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
        
    }else{
        PersonModel *person = self.isSearch ? self.searchArr[indexPath.row] : self.dataArr[indexPath.row];
        InvestorListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvestorListCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.person = person;
        cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
        return cell;
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isSearch ) {
        if (self.searchArr.count == 0) {
            return;
        }
    }else if(self.dataArr.count == 0){
        return;
    }
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}
    
    PersonModel *person = self.isSearch ? self.searchArr[indexPath.row] : self.dataArr[indexPath.row];
    [[AppPageSkipTool shared] appPageSkipToPersonDetail:person.personId nameLabBgColor:RANDOM_COLORARR[indexPath.row%6]];
    [QMPEvent event:@"trz_person_cellclick"];

}

- (void)pressNotStoreFilterBtn:(UIButton *)sender{
    if (_isSearch) {
        return;
    }
    // 认证限制
    if (![PublicTool userisCliamed]) {
        return;
    }
    
    if ([TestNetWorkReached networkIsReachedAlertOnView:self.view]) {
        
        if (isFilter) {
            isFilter = NO;
            [_filterV removeFromSuperview];
            _filterV = nil;
        }
        else{
           
            isFilter = YES;
            [self cancleSearch];

            _filterV = [PersonsFilterView initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH) withKey:TabNameKey];
            _filterV.delegate = self;
            [KEYWindow addSubview:_filterV];
            [QMPEvent event:@"trz_person_filterclick"];
            
        }
    }
    
}
- (NSMutableArray *)getArrFromDataWithTablename:(NSString *)tablename{
    NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
    if ([_db open]) {
        NSString *sql = [NSString stringWithFormat:@"select name from '%@' where selected='1'",tablename];
        FMResultSet *rs = [_db executeQuery:sql];
        while ([rs next]) {
            [retMArr addObject:[rs stringForColumn:@"name"]];
        }
    }
    [_db close];
    return retMArr;
}


#pragma mark - 懒加载
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _dataArr;
}
- (NSMutableArray *)searchArr{
    if (!_searchArr) {
        _searchArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _searchArr;
}

- (NSMutableArray *)selectedRoleMArr{
    
    if (!_selectedRoleMArr) {
        if ([ToLogin isLogin]) {
            //从数据库中获取
            NSString *tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterpersonrole",TabNameKey]];
            _selectedRoleMArr = [self getArrFromDataWithTablename:tableName];
        }
        else{
            _selectedRoleMArr = [[NSMutableArray alloc] initWithCapacity:0];
        }
    }
    return _selectedRoleMArr;
}
- (NSMutableArray *)selectedIndustryMArr{
    
    if (!_selectedIndustryMArr) {
        if ([ToLogin isLogin]) {
            //从数据库中获取
            NSString *tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterindustry",TabNameKey]];
            _selectedIndustryMArr = [self getArrFromDataWithTablename:tableName];
        }
        else{
            _selectedIndustryMArr = [[NSMutableArray alloc] initWithCapacity:0];
        }
    }
    return _selectedIndustryMArr;
}

- (NSMutableArray *)selectedProvinceMArr{
    
    if (!_selectedProvinceMArr) {
        if ([ToLogin isLogin]) {
            //从数据库中获取
            NSString *tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterprovince",TabNameKey]];
            _selectedProvinceMArr = [self getArrFromDataWithTablename:tableName];
        }
        else{
            _selectedProvinceMArr = [[NSMutableArray alloc] initWithCapacity:0];
        }
    }
    return _selectedProvinceMArr;
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}
- (UIView *)searchBelowBgVw{
    if (_searchBelowBgVw == nil) {
        _searchBelowBgVw  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, (isiPhoneX ? 83:72))];
        _searchBelowBgVw.backgroundColor = [UIColor whiteColor];
        UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 220, 32)];
        [createBtn setTitle:@"没有找到我，直接创建官方人物" forState:UIControlStateNormal];
        createBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [createBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        createBtn.layer.masksToBounds = YES;
        createBtn.layer.cornerRadius = 16;
        createBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
        createBtn.layer.borderWidth = 0.5;
        createBtn.center = CGPointMake(SCREENW/2.0, _searchBelowBgVw.height/2.0);
        [createBtn addTarget:self action:@selector(becomeInvestorBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        [_searchBelowBgVw addSubview:createBtn];
    }
    return _searchBelowBgVw;
}

@end
