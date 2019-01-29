//
//  FinanceSearchComController.m
//  qmp_ios
//
//  Created by QMP on 2018/5/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "FinanceSearchComController.h"
#import "SearchCompanyModel.h"
#import "IPOCompanyCell.h"
#import "SearchJigouModel.h"
#import "GetMd5Str.h"
#import "SearchProRegisterModel.h"
#import "SearchRegistCell.h"
#import "FinancialInfoSubmitVC.h"
#import "ProductInfoSubmitVC.h"
#import "TitleAndBtnBottomView.h"

#define FOOTHEIGHT  62

@interface FinanceSearchComController()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    
    NSString *_totalCount;
    SearchCompanyModel *_company;
}

@property (strong, nonatomic)UIView *tableHeaderView;
@property (strong, nonatomic)UITableViewCell *noResultView;
@property (strong,nonatomic)UIView *footerView;
@property (assign, nonatomic) BOOL isSearch;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UIButton *cancleSearchBtn;
@property(nonatomic,strong)NSMutableArray *dataArr;

@property (nonatomic, strong) TitleAndBtnBottomView * bottomVw;

@end

@implementation FinanceSearchComController

- (void)createFinanceButtonClick{
    [self createProduct];
}

- (TitleAndBtnBottomView *)bottomVw{
    if (_bottomVw == nil) {
        __weak typeof(self) weakSelf = self;
        _bottomVw = [TitleAndBtnBottomView titleAndBtnViewWithFrame:CGRectMake(0, SCREENH-kScreenBottomHeight-kScreenTopHeight, SCREENW, kScreenBottomHeight) Title:@"没有找到项目?" buttonTitle:@"创建项目" btnClick:^{
            [weakSelf createFinanceButtonClick];
        }];
    }
    return _bottomVw;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.mySearchBar becomeFirstResponder];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = TABLEVIEW_COLOR;
    self.dataArr = [NSMutableArray array];
    self.title = @"选择项目";
    _totalCount = @"0";
    [self initTableView];
    self.numPerPage = 10;
    self.tableView.frame = CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight - kScreenBottomHeight);
    [self.view addSubview:self.bottomVw];
    self.bottomVw.hidden = YES;
    
    self.currentPage = 1;
    self.numPerPage = 20;
    
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
    NSString *str = @"请输入项目名称";
    tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    tf.font = [UIFont systemFontOfSize:14];
    
    //    _mySearchBar.placeholder = @"搜索报告关键词";
    _mySearchBar.delegate = self;
    [_tableHeaderView addSubview:_mySearchBar];
    
    CGFloat width = 60.f;
    _cancleSearchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, height)];
    [_cancleSearchBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_cancleSearchBtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
    _cancleSearchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_cancleSearchBtn addTarget:self action:@selector(pressConfirmSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
    _cancleSearchBtn.frame = CGRectMake(SCREENW - width-1, (_tableHeaderView.frame.size.height - height)/2, width, height);
    
    //底部线条
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _tableHeaderView.height - 0.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [_tableHeaderView addSubview:line];
    
    self.tableView.tableHeaderView = _tableHeaderView;
    
    [self.tableView registerClass:[IPOCompanyCell class] forCellReuseIdentifier:@"IPOCompanyCellID"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchRegistCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"SearchRegistCellID"];
    
}


- (void)setTableFooterView{
    
    //tableFooterView
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, FOOTHEIGHT)];
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"没有找到项目，创建项目发布"];
        NSRange strRange = {0,[title length]};
        [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
        [title addAttribute:NSForegroundColorAttributeName value: BLUE_TITLE_COLOR range:strRange];
        UIButton *kefuBtn = [[UIButton alloc]initWithFrame:CGRectMake(19, 0, SCREENW-38, 40)];
        kefuBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [kefuBtn setAttributedTitle:title forState:UIControlStateNormal];
        [kefuBtn addTarget:self action:@selector(kefuBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:kefuBtn];
        kefuBtn.centerY = _footerView.height/2.0;
    }
    
    
    if (self.dataArr.count == 0) {
        self.tableView.tableFooterView = nil;
    }else{
        self.tableView.tableFooterView = _footerView;
    }
    self.tableView.tableFooterView = _footerView;

}


-(BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    if (self.currentPage == 1) {
        [PublicTool showHudWithView:KEYWindow];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    NSString *w = [self.keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 注意考虑特殊字符
    [dic setValue:w forKey:@"keywords"];
    
    [dic setValue:@"1" forKey:@"type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    
    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        [PublicTool dismissHud:KEYWindow];
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        self.bottomVw.hidden = NO;
        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            if (self.currentPage == 1) {
                _totalCount = resultData[@"count"];
            }
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                SearchCompanyModel *product = [[SearchCompanyModel alloc]init];
                [product setValuesForKeysWithDictionary:dic];
                [arr addObject:product];
            }
            if (self.currentPage == 1) {
                [self.dataArr removeAllObjects];
            }
            [self refreshFooter:arr];
            
            [self.dataArr addObjectsFromArray:arr];
            [self.tableView reloadData];
            
        }else if (resultData && [resultData[@"jigous"] isKindOfClass:[NSArray class]]) {
            if (self.currentPage == 1) {
                _totalCount = resultData[@"jigous_count"];
            }
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"jigous"]) {
                SearchJigouModel *jigou = [[SearchJigouModel alloc]init];
                [jigou setValuesForKeysWithDictionary:dic];
                [arr addObject:jigou];
            }
            if (self.currentPage == 1) {
                [self.dataArr removeAllObjects];
            }
            
            [self.dataArr addObjectsFromArray:arr];
            [self.tableView reloadData];
            [self refreshFooter:arr];
        }
    }];
    return YES;
}

#pragma mark --Event--
- (void)noResultBtnClick{
    
    [self createProduct];

}

- (void)kefuBtnClick{
    
    [self createProduct];
}


//创建项目----
- (void)createProduct{
    [USER_DEFAULTS setValue:nil forKey:@"FinancialInfo"]; //融资需求 和 个人信息 清空
    [USER_DEFAULTS setValue:nil forKey:@"PersonInfo"];
    [USER_DEFAULTS synchronize];
    
    ProductInfoSubmitVC *productInfo = [[ProductInfoSubmitVC alloc]init];
    productInfo.productName = _mySearchBar.text;
    [self.navigationController pushViewController:productInfo animated:YES];
}


/**
 点击取消搜索
 
 @param sender
 */
- (void)pressCancleSearchBtn:(UIButton *)sender{
    [self cancleSearch];
}
- (void)pressConfirmSearchBtn:(UIButton *)sender {
    if (![self.mySearchBar.text isEqualToString:@""]) {
        self.currentPage = 1;
        self.isSearch = YES;
        self.keyword = self.mySearchBar.text;
        [self requestData];
        [self.mySearchBar resignFirstResponder];
    }
}

- (void)cancleSearch{
    
    self.isSearch = NO;
    [self.dataArr removeAllObjects];
    
    [self.mySearchBar resignFirstResponder];
    CGRect frame = self.mySearchBar.frame;
    frame.size.width = SCREENW-14;
    self.mySearchBar.frame = frame;
    self.mySearchBar.text = @"";
    self.currentPage = 1;
    [self.cancleSearchBtn removeFromSuperview];
    [self refreshFooter:self.dataArr];
    [self.tableView reloadData];
    
}

#pragma mark - UISearchBar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    self.currentPage = 1;
    
    if (!self.isSearch) {
        self.isSearch = YES;
        CGRect frame = searchBar.frame;
        frame.size.width = SCREENW - 58;
        searchBar.frame = frame;
        
        [self.tableHeaderView addSubview:self.cancleSearchBtn];
        
        self.dataArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
    }
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    self.currentPage = 1;
    self.isSearch = YES;
    
    if ([searchBar.text isEqualToString:@""]) {
        self.dataArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
        self.tableView.mj_footer = nil;;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    if (![searchBar.text isEqualToString:@""]) {
        self.currentPage = 1;
        self.isSearch = YES;
        self.keyword = searchBar.text;
        [self requestData];
        [self.mySearchBar resignFirstResponder];
    }
}


#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.dataArr.count) {
        return 45.0f;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.dataArr.count == 0) {
        return [[UIView alloc]init];
    }
    UIView *_headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];//表头
    _headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *headerLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 200, 45)];
    headerLab.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:headerLab];
    headerLab.font = [UIFont systemFontOfSize:14];
    headerLab.textColor = H9COLOR;
    NSString *title = @"公司";
    NSString *headerStr = [NSString stringWithFormat:@"选择您所在的%@",title];
    headerLab.text = headerStr;
    [_headerView addSubview:headerLab];
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44.5, SCREENW, 0.5)];
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
    
    if (self.dataArr.count == 0) {
        if ([PublicTool isNull:self.mySearchBar.text]) {
            return 0;
        }else{
            return 1;
        }
        return 0;

    } else{
        return self.dataArr.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        
        return SCREENH - kScreenTopHeight - kScreenBottomHeight;  //未搜索到
    }
    if ([self.dataArr[0] isKindOfClass:[SearchCompanyModel class]]) {
        SearchCompanyModel *com = self.dataArr[indexPath.row];
        if (com.allipo.count > 1) {
            return 100;
        }else{
            return 76;
        }
    }else  if ([self.dataArr[0] isKindOfClass:[SearchProRegisterModel class]]) {
        return 122;
    }
    
    return 76;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        if (![PublicTool isNull:self.mySearchBar.text]) {
            return [self nodataCellWithInfo:@"搜索无结果" tableView:tableView];
        }
        NSString *searchText = [self.mySearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        UITableViewCell *cell = self.noResultView;
        UIButton *btn = [cell viewWithTag:1000];
        if (![PublicTool isNull:searchText]) { //填充选择
            
            NSString *string = [NSString stringWithFormat:@"未找到，填入\"%@\"",searchText];
            NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:string];
            [attText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR,NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(6, string.length-6)];
            [btn setAttributedTitle:attText forState:UIControlStateNormal];
            
        }else{
            [btn setAttributedTitle:nil forState:UIControlStateNormal];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else{
        if ([self.dataArr[0] isKindOfClass:[SearchCompanyModel class]]) {
            IPOCompanyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IPOCompanyCellID" forIndexPath:indexPath];
            [cell refreshUI:self.dataArr[indexPath.row]];
            cell.iconBgColor = RANDOM_COLORARR[indexPath.row % 6];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        NSArray *color = @[HTColorFromRGB(0xedd794),HTColorFromRGB(0xceaf96),HTColorFromRGB(0xa1dae5),HTColorFromRGB(0xeea8a8),HTColorFromRGB(0x8cceb9),HTColorFromRGB(0xa7c6f2)];
        SearchRegistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchRegistCellID" forIndexPath:indexPath];
        cell.keyWord = self.keyword;
        cell.registModel = self.dataArr[indexPath.row];
        
        cell.nameIconColor = color[indexPath.row % 6];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataArr.count == 0) {
        return;
    }
    SearchCompanyModel *model = (SearchCompanyModel *)self.dataArr[indexPath.row];
    //发布融资需求
    [USER_DEFAULTS setValue:nil forKey:@"FinancialInfo"]; //融资需求 和 个人信息 清空
    [USER_DEFAULTS setValue:nil forKey:@"PersonInfo"];

    [USER_DEFAULTS synchronize];

    FinancialInfoSubmitVC *financialInfoVC = [[FinancialInfoSubmitVC alloc]init];
    financialInfoVC.model = model;
    [self.navigationController pushViewController:financialInfoVC animated:YES];
    
}

#pragma mark --懒加载--
- (UITableViewCell *)noResultView{
    if (!_noResultView) {
        _noResultView = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noResultViewID"];
        UIButton *noResultBtn = [[UIButton alloc]initWithFrame:CGRectMake(17, 15, SCREENW-34, 44)];
        noResultBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [noResultBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [noResultBtn addTarget:self action:@selector(noResultBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_noResultView addSubview:noResultBtn];
        noResultBtn.tag = 1000;
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"没有找到项目，创建项目发布"];
        NSRange strRange = {0,[title length]};
        [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
        [title addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:strRange];
        UIButton *kefuBtn = [[UIButton alloc]initWithFrame:CGRectMake(19, 102, SCREENW-38, 40)];
        kefuBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [kefuBtn setAttributedTitle:title forState:UIControlStateNormal];
        [kefuBtn addTarget:self action:@selector(kefuBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_noResultView addSubview:kefuBtn];
        kefuBtn.top = SCREENH - kScreenTopHeight - 44 - 80;
        
    }
    return _noResultView;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}


@end
