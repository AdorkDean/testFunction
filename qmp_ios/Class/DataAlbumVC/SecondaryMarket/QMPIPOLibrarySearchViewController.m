//
//  QMPIPOLibrarySearchViewController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/10/9.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "QMPIPOLibrarySearchViewController.h"

#import "SearchhistoryCell.h"
#import "IQKeyboardManager.h"
#import "IPOModel.h"
#import "QMPIPOLibraryCell.h"
#import "SmarketEventModel.h"

@interface QMPIPOLibrarySearchViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UIView *_headerView;//吐槽 headerview
    BOOL _firstEnter;
}


@property (strong, nonatomic) UITextField *searchTf;

@property (strong, nonatomic) UIButton *feedbackBtn;
@property (strong, nonatomic) UIView *tableFooterView;

@property (nonatomic,copy)NSString *searchString;//搜索内容
@property (nonatomic,strong)NSDictionary *searchDict;//搜索内容的参数


@property (strong, nonatomic) NSMutableArray *keyArr;//联想的关键词
@property (strong, nonatomic) NSMutableArray *dataArr;//联想的关键词

@property (strong, nonatomic) NSURLSessionDataTask *task;//当前页面只有一个搜索请求在进行
@property (strong, nonatomic) ManagerHud *hudTool;

@end

@implementation QMPIPOLibrarySearchViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_firstEnter) {
        
        [_searchTf becomeFirstResponder];
        _firstEnter = NO;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    [self hideNavigationBarLine];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.searchTf resignFirstResponder];
    //    [self showNavigationBarLine];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _firstEnter = YES;
    self.currentPage = 1;
    self.numPerPage = 20;
    [self keyboardManager];
    
    [self buildRightBarButtonItem];
    
    [self initTableView];
    
    [self handleFooterWhenSetLocal];
    
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - 请求搜索
- (void)requestSearch:(NSString *)searchStr{
    
    [_searchTf resignFirstResponder];
    
    if (searchStr.length < 1) {
        [PublicTool showMsg:@"搜索内容为空"];
        return;
    }else{
        
        _searchString = searchStr;
        self.currentPage = 1;
        [self requestIPO:searchStr];
    }
}


- (void)requestIPO:(NSString*)searchStr{

    NSMutableDictionary *reqDict = [NSMutableDictionary dictionaryWithDictionary:@{@"keywords":searchStr?:@"",@"page":@(self.currentPage),@"num":@(self.numPerPage)}];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"SMarket/smarketList" HTTPBody:reqDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.mjHeader endRefreshing];
        [self.mjFooter endRefreshing];
        
        if (resultData) {
            
            NSDictionary *dict = resultData;
            NSArray *arr = dict[@"list"];
            
            if (self.currentPage == 1) {
                [self.dataArr removeAllObjects];
            }
            
            for (NSDictionary *dic in arr) {
                
                NSError *error = nil;
                SmarketEventModel *eventModel = [[SmarketEventModel alloc]initWithDictionary:dic error:&error];
                [self.dataArr addObject:eventModel];
            }

            [self.tableView reloadData];
            
            [self refreshFooter:arr];

        }
    }];
}
#pragma mark - UITableView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    if (self.dataArr.count == 0) {
        return [[UIView alloc]init];
    }else{
        QMPIPOLibraryTableHeaderView *view = [[QMPIPOLibraryTableHeaderView alloc] init];
        view.frame = CGRectMake(0, 0, SCREENW, 40);
        return view;
        
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1f;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.dataArr.count){
        return 40;
    }
    return 0.1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count ? self.dataArr.count:1;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.dataArr.count ? UITableViewAutomaticDimension:tableView.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        if (self.searchString) {
            return [self nodataCellWithInfo:@"无数据" tableView:tableView];
        }else{
            HomeInfoTableViewCell *cell = [self nodataCellWithInfo:@"" tableView:tableView];
            cell.iconImgView.hidden = YES;
            return cell;
        }
    }else{
        SmarketEventModel *marketModel = self.dataArr[indexPath.row];
        
        QMPIPOLibraryCell *cell = [QMPIPOLibraryCell ipoLibraryCellWithTableView:tableView];
        cell.ipoModel = marketModel;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_searchTf resignFirstResponder];
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}
    
    if (indexPath.row >= self.dataArr.count) {
        return;
    }
    SmarketEventModel *marketModel = self.dataArr[indexPath.row];
    NSDictionary *param = [PublicTool toGetDictFromStr:marketModel.detail];
    [[AppPageSkipTool shared] appPageSkipToProductDetail:param];
    
}



-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_searchTf resignFirstResponder];
}

#pragma mark - UITextFieldDelegate  实时搜索
-(void)textFieldDidBeginEditing:(UITextField *)textField{

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSLog(@"结束编辑-----");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *searchText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (searchText.length == 0) {
        return NO; //搜索内容为空
    }
    [self requestSearch:textField.text];
    
    return YES;
    
}

#pragma mark - public
- (void)keyboardManager{
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.view.userInteractionEnabled = YES;
}

- (void)keyboardHide:(UITapGestureRecognizer *)tap{
    
    if (tap.view != _searchTf) {
        [_searchTf resignFirstResponder];
    }
}

- (void)buildRightBarButtonItem{
    
    self.navigationItem.leftBarButtonItems = nil;
    UIButton *cancelbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [cancelbtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelbtn setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
    cancelbtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelbtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [cancelbtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelbtn];
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW - 78, 44)];
    
    self.searchTf = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, view.width, 27)];
    self.searchTf.backgroundColor = HTColorFromRGB(0xf5f5f5);
    UIImageView *leftImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 35, self.searchTf.frame.size.height)];
    leftImg.image = [BundleTool imageNamed:@"search"];
    leftImg.contentMode = UIViewContentModeCenter;
    _searchTf.returnKeyType = UIReturnKeySearch;
    _searchTf.leftView = leftImg;
    _searchTf.leftViewMode = UITextFieldViewModeAlways;
    _searchTf.placeholder = @"项目、投资机构、团队等";
    [_searchTf setValue:H9COLOR forKeyPath:@"_placeholderLabel.textColor"];
    
    _searchTf.tintColor = [UIColor blackColor];
    _searchTf.layer.masksToBounds = YES;
    _searchTf.layer.cornerRadius = 13.5;
    _searchTf.clearButtonMode = UITextFieldViewModeAlways;
    [view addSubview:self.searchTf];
    _searchTf.delegate = self;
    _searchTf.font = [UIFont systemFontOfSize:13];
    _searchTf.centerY = view.centerY;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:view];
    [_searchTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
}


- (void)popViewController{
    [self.searchTf resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidChange:(UITextField*)tf{
    
}


- (void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    
    [self.tableView registerClass:[QMPIPOLibraryTableHeaderView class] forHeaderFooterViewReuseIdentifier:@"QMPIPOLibraryTableHeaderViewID"];
    
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(45, 0, 0, 0);
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.estimatedRowHeight = 76;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;

}

-(void)pullUp{
    self.currentPage ++;
    [self requestIPO:_searchString];
}

/**
 显示本地搜索时,设置footer
 */
- (void)handleFooterWhenSetLocal{
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView scrollsToTop];
    
    [self.tableView reloadData];
    self.mjFooter.state = MJRefreshStateNoMoreData;
    self.mjFooter.stateLabel.hidden = NO;
    self.tableView.tableFooterView = nil;
}



- (NSMutableArray *)keyArr{
    
    if (!_keyArr) {
        _keyArr = [NSMutableArray array];
    }
    return _keyArr;
}

- (NSMutableArray *)dataArr{
    
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end

