//
//  SearchPersonVC.m
//  qmp_ios
//
//  Created by QMP on 2018/2/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SearchPersonVC.h"
#import "GetMd5Str.h"
#import "PersonModel.h"
#import "SearchPersonVC.h"
#import "SearchPersonNoDataCell.h"
#import "PersonDetailsController.h"
#import "AuthenticationController.h"
#import "MySearchPersonCellByXib.h"

#import "AutheChangePersonController.h"

#define FOOTHEIGHT  62
#define BOTTOMHEIGHT (isiPhoneX ? 83:72)

@interface SearchPersonVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,CustomAlertViewDelegate>
{
    NSString *_totalCount;
    NSInteger _searchCurrentPage;
    BOOL _default;
}

@property (strong, nonatomic)UIView *tableHeaderView;
@property (strong, nonatomic)UIView *bottomV;
@property (strong, nonatomic)UIView *footerView;

@property (assign, nonatomic) BOOL isSearch;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UIButton *cancleSearchBtn;
@property (strong, nonatomic) NSMutableArray *searchArr;

@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) UIButton *feedbackBtn;



@end

@implementation SearchPersonVC

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.keyword) {
        if (!self.isSearch) {
            _default = YES;
            self.isSearch = YES;
            CGRect frame = self.mySearchBar.frame;
            frame.size.width = SCREENW - 58;
            self.mySearchBar.frame = frame;
            self.mySearchBar.text = self.keyword;
            self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
            [self.tableView reloadData];
            [self requestData];
            self.keyword = nil;

            [self.tableHeaderView addSubview:self.cancleSearchBtn];
            
           
        }
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TABLEVIEW_COLOR;
    [self initTableView];
    _searchCurrentPage = 1;
    self.currentPage = 1;
    self.numPerPage = 20;
    
    self.title = @"认证官方人物";
    if ([PublicTool isNull:self.keyword]) {
        self.keyword = [WechatUserInfo shared].nickname;
    }
}


- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate  = self;
    self.tableView.dataSource = self;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MySearchPersonCellByXib" bundle:nil] forCellReuseIdentifier:@"MySearchPersonCellByXibID"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchPersonNoDataCell" bundle:nil] forCellReuseIdentifier:@"SearchPersonNoDataCellID"];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
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
    NSString * str = @"搜索人物名称、机构";

    
    tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    tf.font = [UIFont systemFontOfSize:14];
    
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

- (void)setBottomView{
    
    if (self.dataArr.count) {
        self.tableView.height = SCREENH - kScreenTopHeight - BOTTOMHEIGHT;
        [self.view addSubview:self.bottomV];
    }else{
        if (self.bottomV.superview) {
            [self.bottomV removeFromSuperview];
        }
        self.tableView.height = SCREENH - kScreenTopHeight;
    }
}
- (UIView *)bottomV{
    if (_bottomV == nil) {
        _bottomV  = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH - kScreenTopHeight - BOTTOMHEIGHT, SCREENW, BOTTOMHEIGHT)];
        _bottomV.backgroundColor = [UIColor whiteColor];
        UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 220, 32)];
        [createBtn setTitle:@"没有找到我，直接创建官方人物" forState:UIControlStateNormal];
        createBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [createBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        createBtn.layer.masksToBounds = YES;
        createBtn.layer.cornerRadius = 16;
        createBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
        createBtn.layer.borderWidth = 0.5;
        createBtn.center = CGPointMake(SCREENW/2.0, _bottomV.height/2.0);
        [createBtn addTarget:self action:@selector(createPersonAlert) forControlEvents:UIControlEventTouchUpInside];

        [_bottomV addSubview:createBtn];
    }
    return _bottomV;
}

- (void)setTableFooterView{
    
    //tableFooterView
    _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, FOOTHEIGHT)];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"遇到问题？点我进行人工服务"];
    NSRange strRange = {0,[title length]};
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [title addAttribute:NSForegroundColorAttributeName value:H9COLOR range:strRange];
    UIButton *kefuBtn = [[UIButton alloc]initWithFrame:CGRectMake(19, 0, SCREENW-38, 40)];
    kefuBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [kefuBtn setAttributedTitle:title forState:UIControlStateNormal];
    [kefuBtn addTarget:self action:@selector(kefuBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:kefuBtn];
    kefuBtn.centerY = _footerView.height/2.0;
    
    self.tableView.tableFooterView = _footerView;
    
    if (self.dataArr.count) {
        _footerView.backgroundColor = TABLEVIEW_COLOR;
    }else{
        _footerView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)kefuBtnClick{
    
    [PublicTool contactKefu:kBePersonText reply:kDefaultWel];
}

/**
 点击取消搜索
 
 @param sender
 */
- (void)pressCancleSearchBtn:(UIButton *)sender{
    [self cancleSearch];
}

- (void)cancleSearch{
    
    self.isSearch = NO;
    [self.searchArr removeAllObjects];
    
    [self.mySearchBar resignFirstResponder];
    CGRect frame = self.mySearchBar.frame;
    frame.size.width = SCREENW-14;
    self.mySearchBar.frame = frame;
    self.mySearchBar.text = @"";
    _searchCurrentPage = 1;
    [self.cancleSearchBtn removeFromSuperview];
    [self refreshFooter:self.dataArr];
    [self.tableView reloadData];
    
}

-(BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    
    if (!self.tableView.mj_header.isRefreshing && !self.tableView.mj_footer.isRefreshing) {
        [PublicTool showHudWithView:KEYWindow];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    NSString *w = [_mySearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 注意考虑特殊字符
    [dic setValue:w forKey:@"keywords"];
    
    [dic setValue:@"3" forKey:@"type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    
    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        _default = NO;
        [PublicTool dismissHud:KEYWindow];
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            if (self.currentPage == 1) {
                _totalCount = resultData[@"count"];
            }
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                SearchPerson *person = [[SearchPerson alloc]initWithDictionary:dic error:nil];
                PersonModel *personM = [[PersonModel alloc]init];
                personM.personId = person.personId;
                personM.name = person.name;
                personM.claim_type = person.claim_type;
                personM.usercode = person.usercode;
                personM.work_exp = person.zhiwei;
                personM.icon = person.icon;
                personM.role = person.role;
                [arr addObject:personM];
            }
            if (self.currentPage == 1) {
                [self.dataArr removeAllObjects];
            }
            
            [self.dataArr addObjectsFromArray:arr];
            [self.tableView reloadData];
            
            if (self.currentPage == 1 && arr.count < self.numPerPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [self refreshFooter:arr];                
            }
//            [self setTableFooterView];
            [self setBottomView];
            
        }
        
    }];
    return YES;
}
#pragma mark 投资人搜索
- (void)searchInvestorData{
    NSDictionary *dic = @{@"page":@(_searchCurrentPage),@"num":@(self.numPerPage),@"keywords":_mySearchBar.text, @"op_flag":@(0)};
    if (_searchCurrentPage == 1 && !self.tableView.mj_header.isRefreshing) {
        [PublicTool showHudWithView:KEYWindow];
    }
    self.tableView.mj_header = nil;
    [AppNetRequest getPersonListWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && resultData[@"list"]) {
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                PersonModel *person = [[PersonModel alloc]initWithDictionary:dic error:nil];
                [arr addObject:person];
            }
            if (_searchCurrentPage == 1) {
                [self.dataArr removeAllObjects];
                _totalCount = resultData[@"count"];
            }
            _searchCurrentPage ++;
            [self.dataArr addObjectsFromArray:arr];
            [self refreshFooter:arr];
            [self.tableView reloadData];
        }
//        [self setTableFooterView];
        [self setBottomView];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --创建人物
- (void)createPersonAlert{
    
    AuthenticationController *claimVC = [[AuthenticationController alloc]init];
    claimVC.searchName = [_mySearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self.navigationController pushViewController:claimVC animated:YES];
    return;
}


- (void)claimBtnClick:(UIButton *)btn{
    
    PersonModel *person = self.dataArr[btn.tag - 3333];

    if (person.claim_type.integerValue == 2) { //已被认领
        //该人物已认证
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:@{@"module":@"人物信息",@"title":@"人物认证冲突"}];
        if (![PublicTool isNull:person.name]) {
            [infoDic setValue:person.name forKey:@"company"];
        }else{
            [infoDic setValue:@"" forKey:@"company"];
        }
        [infoDic setValue:@"成为官方人物" forKey:@"type"];
        [infoDic setValue:person.personId forKey:@"product"];
        CustomAlertView *alertV = [[CustomAlertView alloc]initWithAlertViewHeight:[NSMutableArray array] frame:CGRectZero WithAlertViewHeight:60 infoDic:infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
        alertV.delegate = self;
        
    }else{
        
        AuthenticationController *authenVC = [[AuthenticationController alloc]init];
        authenVC.person = person;
        [self.navigationController pushViewController:authenVC animated:YES];
    }
    
}

- (void)feedsUploadSuccess{
//    self.feedbackBtn.selected = YES;
//    self.feedbackBtn.userInteractionEnabled = NO;//不能重复反馈
}

#pragma mark - UISearchBar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    _searchCurrentPage = 1;
    
    if (!self.isSearch) {
        self.isSearch = YES;
        CGRect frame = searchBar.frame;
        frame.size.width = SCREENW - 58;
        searchBar.frame = frame;
        
        [self.tableHeaderView addSubview:self.cancleSearchBtn];
        
        self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
    }
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    _searchCurrentPage = 1;
    self.isSearch = YES;
    self.tableView.tableFooterView = nil;

    if ([searchBar.text isEqualToString:@""]) {
        self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
        self.tableView.mj_footer = nil;;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    if (![searchBar.text isEqualToString:@""]) {
        _searchCurrentPage = 1;
        self.isSearch = YES;
        
        [self requestData];
        [self.mySearchBar resignFirstResponder];
    }
}

#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.dataArr.count == 0) {
        return 0.1f;
    }
    return 50.0f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (self.dataArr.count == 0) {
        return 0.1f;
    }
    else{
        
        return 0.1;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.dataArr.count == 0) {
        return [[UIView alloc]init];
    }
    
    UIView *_headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, SCREENW, 50)];//表头
    _headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *headerLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 200, 50)];
    headerLab.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:headerLab];
    headerLab.font = [UIFont systemFontOfSize:14];
    headerLab.textColor = H9COLOR;
    NSString *headerStr = [NSString stringWithFormat:@"共(%@)条搜索结果",_totalCount];
    headerLab.text = headerStr;
    [_headerView addSubview:headerLab];
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 49.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [_headerView addSubview:line];
    
    return _headerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (![PublicTool isNull:self.mySearchBar.text] && self.dataArr.count == 0 && !_default) {
        
        return 1;
        
    }else{
        return self.dataArr.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        return SCREENH - kScreenTopHeight - kScreenBottomHeight ;  //未搜索到
    }
    return 77;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        SearchPersonNoDataCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchPersonNoDataCellID" forIndexPath:indexPath];
        
        [cell.createBtn addTarget:self action:@selector(createPersonAlert) forControlEvents:UIControlEventTouchUpInside];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else{
        
        MySearchPersonCellByXib *cell = [tableView dequeueReusableCellWithIdentifier:@"MySearchPersonCellByXibID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.person = self.dataArr[indexPath.row];
        cell.claimBtn.hidden = NO;
        cell.claimBtn.tag = 3333+indexPath.row;
        [cell.claimBtn addTarget:self action:@selector(claimBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        return;
    }
    
    PersonModel *person = self.dataArr[indexPath.row];
    PersonDetailsController *detailVC = [[PersonDetailsController alloc]init];
    detailVC.persionId = person.personId;
    detailVC.fromClaimReq = YES;
    [self.navigationController pushViewController:detailVC animated:YES];

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

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

#pragma mark 创建投资人

@end


