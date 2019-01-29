//
//  SearchBindProController.m
//  qmp_ios
//
//  Created by QMP on 2017/12/29.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "SearchBindProController.h"
#import "SearchCompanyTableViewCell.h"
#import "GetMd5Str.h"
#import "GetNowTime.h"
#import "SearchhistoryCell.h"
#import <UICollectionViewLeftAlignedLayout.h>

#define HISTORY_SEARCH @"search_history"

@interface SearchBindProController()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UITextField *_searchTf;
}
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *headerLab;
@property (strong, nonatomic) GetNowTime *timeTool;

@property (strong, nonatomic) NSArray *productArr;

@property (strong, nonatomic) NSMutableArray *historyArr;//本地存放的历史记录
@property (strong, nonatomic) NSMutableArray *attentionArr;//关注的项目列表

//为了获取高度
@property (strong, nonatomic) SearchhistoryCell *historyCell;//历史cell
@property (strong, nonatomic) SearchhistoryCell *attentCell;//关注cell
@property (strong, nonatomic) UICollectionView *historyCollecV; //
@property (strong, nonatomic) UICollectionView *attentCollecV;

@end

@implementation SearchBindProController



- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.historyCollecV = self.historyCell.collectionView;
    self.attentCollecV = self.attentCell.collectionView;
    
    self.numPerPage = 10;
    [self.view addSubview:self.historyCollecV];
    [self.view addSubview:self.attentCollecV];

    self.historyArr = [NSMutableArray array];
    self.attentionArr = [NSMutableArray array];
    
    [self buildRightBarButtonItem];
    [self initTableView];
    [self keyboardManager];

    //历史记录和关注项目
    if ([USER_DEFAULTS valueForKey:HISTORY_SEARCH]) {
        NSString *historyStr = [USER_DEFAULTS valueForKey:HISTORY_SEARCH];
        self.historyArr = [NSMutableArray arrayWithArray:[historyStr componentsSeparatedByString:@"|"]];
        self.historyCell.historyArr = self.historyArr;
    }
    
    [AppNetRequest getUserFollowListWithParam:@{@"type":@"product"} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && [resultData[@"msg"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in resultData[@"msg"]) {
                [self.attentionArr addObject:dic[@"project"]];
            }
            self.attentCell.historyArr = self.attentionArr;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }

    }];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_searchTf becomeFirstResponder];
    
    self.historyCollecV.width = SCREENW;
    self.attentCollecV.width = SCREENW;
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [_searchTf resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if ([PublicTool isNull:_searchTf.text]) {
        return section == 0 ? (self.historyArr.count ? 45:0.1):(self.attentionArr.count?45:0.1);
    }
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    if (![PublicTool isNull:_searchTf.text]) {
        return line;
    }
    if (section == 0) {
        if (self.historyArr.count) {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 45.f)];
            
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, SCREENW-16, 45.f)];
            headerLabel.textAlignment = NSTextAlignmentLeft;
            headerLabel.font = [UIFont systemFontOfSize:13.f];
            headerLabel.textColor = H9COLOR;
            [headerView addSubview:headerLabel];
            headerLabel.text = @"历史记录";
            UIButton *delBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 50, 5, 35, 35)];
            [delBtn setImage:[BundleTool imageNamed:@"searchDelhistory"] forState:UIControlStateNormal];
            [delBtn setContentMode:UIViewContentModeCenter];
            [delBtn addTarget:self action:@selector(pressDelBtn:) forControlEvents:UIControlEventTouchUpInside];
            [delBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            [headerView addSubview:delBtn];
            headerView.backgroundColor = [UIColor whiteColor];
            return headerView;
            
        }
    }else if(section == 1){
        if (self.attentionArr.count) {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 45.f)];
            
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, SCREENW-16, 45.f)];
            headerLabel.textAlignment = NSTextAlignmentLeft;
            headerLabel.font = [UIFont systemFontOfSize:13.f];
            headerLabel.textColor = H9COLOR;
            [headerView addSubview:headerLabel];
            headerLabel.text = @"我的关注";
            headerView.backgroundColor = [UIColor whiteColor];
            return headerView;
        }
    }
   
    return [[UIView alloc]init];
}
//删除搜索历史
- (void)pressDelBtn:(UIButton *)sender{
    
    [PublicTool alertActionWithTitle:@"提示" message:@"您确定要删除所有搜索历史吗?"  cancleAction:^{
        
    } sureAction:^{
        [USER_DEFAULTS setValue:nil forKey:HISTORY_SEARCH];
        [USER_DEFAULTS synchronize];
        [self.historyArr removeAllObjects];
        [self.tableView reloadData];
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([PublicTool isNull:_searchTf.text]) {
        return 2;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([PublicTool isNull:_searchTf.text]) {
        return section == 0 ? (self.historyArr.count?1:0):(self.attentionArr.count?1:0);
    }
    
    if (self.productArr && self.productArr.count > 0) {
        return self.productArr.count;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([PublicTool isNull:_searchTf.text]) {
        if (indexPath.section == 0) {
            if (self.historyCollecV.contentSize.height) {
                return self.historyCollecV.contentSize.height+10;
            }
        }else{
            if (self.attentCollecV.contentSize.height) {
                return self.attentCollecV.contentSize.height + 30;
            }

        }
        return 0.0;
    }
    
    if (self.productArr && self.productArr.count > 0) {
        return 75.f;
    }
    return SCREENH - kScreenTopHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([PublicTool isNull:_searchTf.text]) {
        if (indexPath.section == 0) { //历史记录
            static NSString *cellIdentifier = @"historyCell";
            SearchhistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[SearchhistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.historyArr = _historyArr;
            __weak typeof(self) weakSelf = self;
            cell.selectedIndex = ^(NSInteger index) {
                NSString *keyword = _historyArr[index];
                _searchTf.text = keyword;
                [weakSelf requestSearchList];
                [weakSelf saveSearchToHistory:keyword];
            };
            return cell;
        }else if(indexPath.section == 1){ //关注的
            static NSString *cellIdentifier = @"historyCell";
            SearchhistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[SearchhistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.historyArr = self.attentionArr;
            __weak typeof(self) weakSelf = self;
            cell.selectedIndex = ^(NSInteger index) {
                NSString *keyword = _attentionArr[index];
                _searchTf.text = keyword;
                [weakSelf requestSearchList];
                //加入到搜索历史
                [weakSelf saveSearchToHistory:keyword];
            };
            return cell;
        }
        
    }


    if (self.productArr && self.productArr.count > 0) {

        SearchCompanyTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"SearchCompanyTableViewCellID" forIndexPath:indexPath];
       
        SearchCompanyModel * model = self.productArr[indexPath.row];
        [cell refreshUI:model];
        return cell;
    }else{
        
        NSString *title = REQUEST_SEARCH_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.productArr && self.productArr.count > 0) {
        SearchCompanyModel *searchModel = self.productArr[indexPath.row];

        self.selectedProduct(searchModel);
        [self saveSearchToHistory:searchModel.product];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)saveSearchToHistory:(NSString*)searchStr{
    //存储搜索的项目
    if (![PublicTool isNull:searchStr]){
        if (![self.historyArr containsObject:searchStr]) { //新加字段
            
            [self.historyArr insertObject:searchStr atIndex:0];
        }else{ //调整顺序
            [self.historyArr removeObject:searchStr];
            [self.historyArr insertObject:searchStr atIndex:0];
        }
        //如果大于15 删掉
        if (self.historyArr.count > 15) {
            [self.historyArr removeObjectsInRange:NSMakeRange(15, self.historyArr.count-15)];
        }
        [USER_DEFAULTS setValue:[self.historyArr componentsJoinedByString:@"|"] forKey:HISTORY_SEARCH];
        [USER_DEFAULTS synchronize];
        self.historyCell.historyArr = self.historyArr;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}
- (void)textFieldDidChange:(UITextField*)tf{
    
    NSString *searchText = _searchTf.text;
    
    if ([searchText isEqualToString:@""]) {
        
        self.productArr = nil;
        [self.tableView reloadData];
    }else{
        [self requestSearchList];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *searchText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (searchText.length == 0) {
        return NO; //搜索内容为空
    }
    [self requestSearchList];
    
    return YES;
    
}


#pragma mark - 请求搜索
- (void)requestSearchList{
    [self requestSearchProduct];

}

// s/wdp5
- (void)requestSearchProduct{
    
    NSString *searchStr = _searchTf.text;
    NSString *w = [searchStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//注意考虑特殊字符
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    [dic setValue:w forKey:@"keywords"];
    
    [dic setValue:@"1" forKey:@"type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        NSMutableArray *productMArr = [[NSMutableArray alloc] initWithCapacity:0];
        
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            
            NSArray *companyArr = [resultData objectForKey:@"list"];
            for (NSDictionary *companyDict in companyArr) {
                SearchCompanyModel *companyModel = [[SearchCompanyModel alloc] init];
                
                [companyModel setValuesForKeysWithDictionary:companyDict];
                [productMArr addObject:companyModel];
            }
        }
        
        self.productArr = productMArr;
        [self.tableView reloadData];
        
    }];
}


#pragma mark - public
- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight - 50.f) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[SearchCompanyTableViewCell class] forCellReuseIdentifier:@"SearchCompanyTableViewCellID"];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
}

- (void)buildRightBarButtonItem{
    
    self.navigationItem.leftBarButtonItems = nil;
    UIButton *cancelbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [cancelbtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelbtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
    cancelbtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelbtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [cancelbtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelbtn];
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW - 78, 44)];
    
    _searchTf = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, view.width, 29)];
    _searchTf.backgroundColor = HTColorFromRGB(0xf5f5f5);
    UIImageView *leftImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 35, _searchTf.frame.size.height)];
    leftImg.image = [BundleTool imageNamed:@"search"];
    leftImg.contentMode = UIViewContentModeCenter;
    _searchTf.returnKeyType = UIReturnKeySearch;
    _searchTf.leftView = leftImg;
    _searchTf.leftViewMode = UITextFieldViewModeAlways;
    _searchTf.placeholder = @"搜索要关联的项目";
    _searchTf.layer.masksToBounds = YES;
    _searchTf.layer.cornerRadius = 4;
    _searchTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [view addSubview:_searchTf];
    _searchTf.delegate = self;
    _searchTf.font = [UIFont systemFontOfSize:14];
    _searchTf.centerY = view.centerY;
    [_searchTf setValue:H9COLOR forKeyPath:@"_placeholderLabel.textColor"];
    
    _searchTf.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:view];
    [_searchTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
}
- (void)popViewController{
    [_searchTf resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)keyboardManager{
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




- (void)pressAddProductBtn:(UIButton *)sender{
    
    
}


#pragma mark - 懒加载
- (GetNowTime *)timeTool{
    
    if (!_timeTool) {
        _timeTool = [[GetNowTime alloc] init];
    }
    return _timeTool;
}

- (SearchhistoryCell*)historyCell{
    if (!_historyCell) {
        _historyCell = [[SearchhistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"historyCellId"];
        _historyCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _historyCell.frame = CGRectMake(0, 0, SCREENW, 50);
    }
    return _historyCell;
}
- (SearchhistoryCell*)attentCell{
    if (!_attentCell) {
        _attentCell = [[SearchhistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"attentCellID"];
        _attentCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _attentCell.frame = CGRectMake(0, 0, SCREENW, 50);
    }
    return _attentCell;
}


@end
