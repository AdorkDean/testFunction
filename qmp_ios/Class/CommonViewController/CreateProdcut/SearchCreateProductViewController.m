//
//  SearchCreateProductViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/5/30.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SearchCreateProductViewController.h"
#import "GetMd5Str.h"
#import "IPOCompanyCell.h"
#import "CreateProController.h"
#import "CreateProductViewController.h"

@interface SearchCreateProductViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, strong) NSMutableArray *productData;
@property (nonatomic, weak) UIButton *confirmButton;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *headerView;


@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UIButton *cancleSearchBtn;
@end

@implementation SearchCreateProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"创建项目";
    
    [self initTableView];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([PublicTool isNull:self.mySearchBar.text]) {
        [self.mySearchBar becomeFirstResponder];
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
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.tableView registerClass:[IPOCompanyCell class] forCellReuseIdentifier:@"IPOCompanyCellID"];

    CGFloat height = 44;
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, height)];
    _tableHeaderView.backgroundColor = TABLEVIEW_COLOR;
    
    _mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(7, 0, SCREENW-58, height)];
    
    [_mySearchBar setBackgroundImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_mySearchBar.bounds.size]];
    
    //设置背景色
    [_mySearchBar setBackgroundColor:TABLEVIEW_COLOR];
    [_mySearchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_borderTab"] forState:UIControlStateNormal];
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
    [_cancleSearchBtn addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _cancleSearchBtn.frame = CGRectMake(SCREENW - width-1, (_tableHeaderView.frame.size.height - height)/2, width, height);
    [_tableHeaderView addSubview:_cancleSearchBtn];
    
    //底部线条
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _tableHeaderView.height - 0.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [_tableHeaderView addSubview:line];
    
    self.tableView.tableHeaderView = _tableHeaderView;
    
    [self.view addSubview:self.footerView];
    self.footerView.hidden = YES;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.footerView.height, 0);
    
}
- (void)textFieldTextChange:(UITextField *)textField {
    self.confirmButton.userInteractionEnabled = textField.text.length > 0;
    self.confirmButton.backgroundColor = textField.text.length > 0 ? BLUE_TITLE_COLOR:HTColorFromRGB(0xB1B5BD);
}
- (void)confirmButtonClick:(UIButton *)button {
    if (![self.mySearchBar.text isEqualToString:@""]) {
        self.keyword = self.mySearchBar.text;
        self.currentPage = 1;
        [self requestData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)continueButtonClick {
    [self.view endEditing:YES];
    CreateProController *vc = [[CreateProController alloc] init];
    vc.productName = self.keyword?:@"";
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)cancelButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (![searchBar.text isEqualToString:@""]) {
        self.currentPage = 1;
        self.keyword = searchBar.text;
        [self requestData];
        [self.mySearchBar resignFirstResponder];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(BOOL)requestData {
    
    if (![super requestData]) {
        return NO;
    }
    
    [PublicTool showHudWithView:KEYWindow];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    NSString *w = [self.keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 注意考虑特殊字符
    [dic setValue:w forKey:@"keywords"];
    
    [dic setValue:@"1" forKey:@"type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    
    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
    
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData && [resultData isKindOfClass:[NSDictionary class]] && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            NSArray *data = resultData[@"list"];
            if (data.count > 0) {
                NSMutableArray *arr = [NSMutableArray array];
                for (NSDictionary *dic in data) {
                    SearchCompanyModel *product = [[SearchCompanyModel alloc]init];
                    [product setValuesForKeysWithDictionary:dic];
                    [arr addObject:product];
                }
                if (self.currentPage == 1) {
                    [self.productData removeAllObjects];
                }
                
                [self.productData addObjectsFromArray:arr];
                
                [self.tableView reloadData];

                self.confirmButton.hidden = YES;
                [self.view endEditing:YES];
                self.footerView.hidden = NO;
            } else {
                [self.view endEditing:YES];
                self.footerView.hidden = YES;
                self.productData = nil;
                [self.tableView reloadData];
                CreateProController *vc = [[CreateProController alloc] init];
                vc.productName = self.keyword?:@"";
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        }
    }];
    
    
    
    return YES;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.productData.count > 0) {
        return self.productData.count;
    }
    if ([PublicTool isNull:self.mySearchBar.text]) {
        return 0;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.productData.count == 0) {
        return SCREENH - kScreenTopHeight - kScreenBottomHeight;  //未搜索到
    }
    return 77;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.productData.count == 0) {
        HomeInfoTableViewCell *cell = [self nodataCellWithInfo:@"暂无数据" tableView:tableView];
        cell.createBtn.hidden = NO;
        [cell.createBtn setTitle:@"去创建" forState:UIControlStateNormal];
        [cell.createBtn addTarget:self action:@selector(continueButtonClick) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    IPOCompanyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IPOCompanyCellID" forIndexPath:indexPath];
    [cell refreshUI:self.productData[indexPath.row]];
    cell.iconBgColor = RANDOM_COLORARR[indexPath.row % 6];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){
        return;
    }
    SearchCompanyModel *product = self.productData[indexPath.row];
//    ProductDetailsController *vc = [[ProductDetailsController alloc] init];
//    vc.urlDict = [PublicTool toGetDictFromStr:product.detail];
//    [self.navigationController pushViewController:vc animated:YES];
}
- (NSMutableArray *)productData {
    if (!_productData) {
        _productData = [NSMutableArray array];
    }
    return _productData;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENH-kScreenTopHeight-120, SCREENW, 120)];
        footerView.backgroundColor = TABLEVIEW_COLOR;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, 20, SCREENW, 20);
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = NV_TITLE_COLOR;
        label.text = @"已存在以上项目，是否继续创建？";
        label.textAlignment = NSTextAlignmentCenter;
        [footerView addSubview:label];
        
        UIButton *cancelButton = [[UIButton alloc] init];
        cancelButton.frame = CGRectMake((SCREENW-240)/3.0, 60, 120, 40);
        cancelButton.backgroundColor = HTColorFromRGB(0xB1B5BD);
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        cancelButton.layer.masksToBounds = YES;
        cancelButton.layer.cornerRadius = 20;
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:cancelButton];
        
        UIButton *continueButton = [[UIButton alloc] init];
        continueButton.frame = CGRectMake(cancelButton.right+(SCREENW-240)/3.0, 60, 120, 40);
        continueButton.backgroundColor = BLUE_BG_COLOR;
        [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        continueButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        continueButton.layer.masksToBounds = YES;
        continueButton.layer.cornerRadius = 20;
        [continueButton setTitle:@"继续创建" forState:UIControlStateNormal];
        [continueButton addTarget:self action:@selector(continueButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:continueButton];
        
        _footerView = footerView;
    }
    return _footerView;
}
- (UIView *)headerView {
    if (!_headerView) {
        CGFloat height = 44 + 12 + 40 + 10;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, height)];
        headerView.backgroundColor = TABLEVIEW_COLOR;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(17, 12, SCREENW-34, 32)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 4;
        view.layer.borderColor = [BORDER_LINE_COLOR CGColor];
        view.layer.borderWidth = 1.0;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, SCREENW-34-20-60, 32)];
        textField.font = [UIFont systemFontOfSize:14];
        textField.placeholder = @"输入项目名称";
        [textField addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [view addSubview:textField];
        [headerView addSubview:view];
        self.textField = textField;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(textField.right, 0, 60, 32)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:button];
        button.userInteractionEnabled = NO;
        
        self.confirmButton = button;
        _headerView = headerView;
    }
    return _headerView;
}
@end
