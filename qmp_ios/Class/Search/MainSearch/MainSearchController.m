//
//  MainSearchController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MainSearchController.h"
#import "MainResultController.h"
#import "SearchhistoryCell.h"
#import <IQKeyboardManager.h>

@interface MainSearchController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextFieldDelegate>
{
    BOOL showHistory;//是否显示搜索历史
    
    UIView *_headerView;//吐槽 headerview
    BOOL _firstEnter;
    NSDate *_inputDate;
}


@property (strong, nonatomic) UITextField *searchTf;
@property (assign, nonatomic) BOOL showKey;   //搜索到关键字
@property (strong, nonatomic) UIButton *feedbackBtn;
@property (strong, nonatomic) UIView *tableFooterView;

@property (nonatomic,copy)NSString *searchString;//搜索内容
@property (nonatomic,strong)NSDictionary *searchDict;//搜索内容的参数


@property(nonatomic,strong) NSMutableArray * companysModelMArr;//存公司model
@property(nonatomic,strong) NSMutableArray * jigousModelMArr;//存机构model
@property(nonatomic,strong) NSMutableArray * registModelMArr;//存工商model

@property (strong, nonatomic) NSMutableArray *historyArr;//本地存放的历史记录
@property (strong, nonatomic) NSMutableArray *keyArr;//联想的关键词

@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) NSString *tableName;

@property (strong, nonatomic) NSURLSessionDataTask *task;//当前页面只有一个搜索请求在进行
@property (strong, nonatomic) ManagerHud *hudTool;
//搜索结果
@property (strong, nonatomic) MainResultController *resultContorller;

//为了获取cell高度
@property (strong, nonatomic) SearchhistoryCell *historySCell;//火爆cell
@property (strong, nonatomic) UICollectionView *historySCellCollecV;
@property (strong, nonatomic) NSMutableArray *hotArr;
@property (strong, nonatomic) NSMutableArray *hotIconArr;


@end

@implementation MainSearchController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_firstEnter) {
        [_searchTf becomeFirstResponder];
        _firstEnter = NO;
    }
    self.historySCellCollecV.width = SCREENW;
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideNavigationBarLine];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.searchTf resignFirstResponder];
    [self showNavigationBarLine];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.historySCellCollecV = self.historySCell.collectionView;
    
    [self.view addSubview:self.historySCellCollecV];
    
    
    showHistory = YES;
    _firstEnter = YES;
    
    [self keyboardManager];
    
    [self buildRightBarButtonItem];
    
    [self initDB];
    [self initTableView];
    [self showHUD];
    
    
    [self getLocalHistory];
    self.historySCellCollecV.width = SCREENW;
    self.historySCell.historyArr = self.historyArr;
    
    //请求火爆项目
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"search/getSearchHotWord" HTTPBody:@{@"type":@"product"} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        //关注的项目
        [self hideHUD];
        
        [self.hotArr removeAllObjects];
        [self.hotIconArr removeAllObjects];
        self.historySCellCollecV.width = SCREENW;
        
        if (resultData  && [resultData isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary *dic in resultData) {
                [self.hotArr addObject:dic[@"keyword"]];
                if ([dic[@"is_hot"] integerValue] == 1) {
                    [self.hotIconArr addObject:dic[@"keyword"]];
                }
            }
            

            [self.tableView reloadData];

//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5), dispatch_get_main_queue(), ^{
//                [self.tableView reloadData];
//
//            });
        }
        QMPLog(@"-----");
    }];
    
    [self handleFooterWhenSetLocal];
    
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}


-(void)dealloc{
    
    [_db close];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 关键词联想
- (void)searchDetailWithKey:(NSString *)key{
    self.showKey = YES;
    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"l/wdptips" HTTPBody:@{@"w":key} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self handleFooterWhenSetLocal];
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
#pragma mark - 请求搜索
- (void)requestSearch:(NSString *)searchStr{
    
    if (!self.resultContorller.view.superview) {

        [self.view addSubview:self.resultContorller.view];

    }
    self.showKey = NO;
    [_searchTf resignFirstResponder];
    
    if (searchStr.length < 1) {
        [PublicTool showMsg:@"搜索内容为空"];
        return;
    }else{
        if (![self.hotArr containsObject:searchStr]) {
            [self storeKeywords:searchStr];
            [self getLocalHistory];
        }
        self.resultContorller.keyword = searchStr;
        
    }
}



#pragma mark - UITableView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44, SCREENW, 1)];
    line.backgroundColor = LIST_LINE_COLOR;
    
    if (self.showKey) {
        return nil;
    }else{
        
        if (showHistory) {
            
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 45.f)];
            
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 10, SCREENW-16, 35.f)];
            headerLabel.textAlignment = NSTextAlignmentLeft;
            headerLabel.font = [UIFont systemFontOfSize:13.f];
            headerLabel.textColor = COLOR737782;
            [headerView addSubview:headerLabel];
            if (section == 0 && self.historyArr.count > 0) {
                headerView.height = 35;
                headerLabel.centerY = headerView.height/2.0+1;
                headerLabel.text = @"历史记录";
                UIButton *delBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 50, 0, 35, 35)];
                [delBtn setImage:[UIImage imageNamed:@"searchDelhistory"] forState:UIControlStateNormal];
                [delBtn setContentMode:UIViewContentModeCenter];
                [delBtn addTarget:self action:@selector(pressDelBtn:) forControlEvents:UIControlEventTouchUpInside];
                [delBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
                [headerView addSubview:delBtn];
                delBtn.centerY = headerLabel.centerY;
            }else if (section == 1 && self.hotArr.count > 0) {
                headerLabel.text = @"热门搜索";
            }else{
                headerLabel.text = @"";
            }
            if (self.tableView.tableHeaderView!=nil) {
                self.tableView.sectionHeaderHeight = 0;
                self.tableView.tableHeaderView = nil;
            }
            headerView.backgroundColor = [UIColor whiteColor];
            return headerView;
        }
    }
    return [[UIView alloc]init];
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    
    if (showHistory || self.showKey) {
        return 0.1f;
    }else{
        
        return 10;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (self.showKey) {
        return 0.1f;
    }else{
        
        if (showHistory) {
            if (section == 0 && self.historyArr.count > 0) {
                return 35.f;
            }else if (section == 1 && self.hotArr.count > 0) {
                return 45.f;
            }else{
                return 0.1f;
            }
        }
        
    }
    return 0.1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (showHistory || self.showKey) {
        if (self.showKey) {
            return 1;
        }
        
        return 2;
    }
    else{
        if (self.jigousModelMArr.count == 0 && self.companysModelMArr.count == 0) { //没有数据(用户没输入或输入了但没有找到相应数据)
            return 1;
        }else if (self.jigousModelMArr.count > 0 || self.companysModelMArr.count > 0) {
            
            if (self.jigousModelMArr.count > 0 && self.companysModelMArr.count > 0) {
                return 2;
            }
            else{
                return 1;
            }
        }else{
            return 1;
        }
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.showKey) {
        
        return self.keyArr.count;
        
    }else{
        
        if (showHistory) {
            //如果是搜索历史
            return section == 0 ? (self.historyArr.count?1:0):(self.hotArr.count?1:0);
            
        }else{
            //如果不是搜索历史
            if (self.jigousModelMArr.count == 0 && self.companysModelMArr.count == 0 &&self.registModelMArr.count == 0 && section == 0) {
                //没有数据(用户没输入或输入了但没有找到相应数据) notfoundcell
                return 1;
                
            }else{
                if (self.jigousModelMArr.count != 0) {
                    //jigou 不为0
                    
                    if (section == 0) {
                        return self.jigousModelMArr.count;
                    }else if (self.companysModelMArr.count != 0) {
                        return self.companysModelMArr.count;
                    }
                    else{
                        return 0;
                    }
                    
                }else  if (self.companysModelMArr.count != 0) {
                    //jigou 为0 但company不为0
                    return self.companysModelMArr.count;
                }else{
                    if (self.registModelMArr.count) {
                        return self.registModelMArr.count;
                    }else{
                        //三者都为0
                        return 1;
                    }
                    
                }
            }
        }
        
    }
    
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.showKey) { //搜索机构或公司
        return 64;
        
    }else{
        
        if (showHistory) { //显示搜索历史
            if (indexPath.section == 1) {
                CGFloat rowHeight = SCREENH - kScreenTopHeight - self.historySCellCollecV.contentSize.height - 50;

                return 200;

                
            }else{
                
                if (self.historySCellCollecV.contentSize.height) {
                    return self.historySCellCollecV.contentSize.height + 10;
                }
            }
            
            return 0.0;
        }
    }
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.showKey && self.keyArr.count>0) { //显示搜索结果
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.separatorInset = UIEdgeInsetsZero;
        static NSString *cellIdentifier = @"keyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = self.keyArr[indexPath.row];
        
        return cell;
        
    }else{
        
        NSString *key = @"";
        if (showHistory) {
            
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.tableView.separatorInset = UIEdgeInsetsZero;
            
            if (indexPath.section == 1  && self.hotArr.count) {
                static NSString *cellIdentifier = @"historySCellID";
                SearchhistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (!cell) {
                    cell = [[SearchhistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.hotArr = self.hotIconArr;
                cell.historyArr = _hotArr;
                __weak typeof(self) weakSelf = self;
                cell.selectedIndex = ^(NSInteger index) {
                    NSString *keyword = weakSelf.hotArr[index];
                    weakSelf.searchTf.text = keyword;
                    [weakSelf requestSearch:keyword];
                    [QMPEvent event:@"search_hotClick"];
                };
                return cell;
                
            }else if (indexPath.section == 0 && self.historyArr.count > 0) {
                
                static NSString *cellIdentifier = @"historyCell";
                SearchhistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (!cell) {
                    cell = [[SearchhistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.historyArr = _historyArr;
                __weak typeof(self) weakSelf = self;
                cell.selectedIndex = ^(NSInteger index) {
                    NSString *keyword = weakSelf.historyArr[index];
                    weakSelf.searchTf.text = keyword;
                    [weakSelf requestSearch:keyword];
                    [QMPEvent event:@"search_historyClick"];
                };
                return cell;
                
            }else{
                key = indexPath.section == 1 ? @"暂无搜索历史,请使用上方搜索栏进行搜索":@"";
            }
        }
        NSString *title = key;
        return [self nodataCellWithInfo:title tableView:tableView];
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}
    
    [_searchTf resignFirstResponder];
    
    if (self.showKey && self.keyArr.count>0 && (indexPath.row < self.keyArr.count)) {
        self.searchTf.text = self.keyArr[indexPath.row];
        [self requestSearch:self.keyArr[indexPath.row]];
    }
}
/**
 *  tableView滑动触发的事件
 *
 *  @param scrollView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_searchTf resignFirstResponder];
}

#pragma mark - UITextFieldDelegate  实时搜索
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [QMPEvent event:@"search_inputView_click"];
}
- (void)textFieldDidChange:(UITextField*)tf{
    
    NSString *searchText = _searchTf.text;
    
    if([PublicTool isNull:searchText]){
        [self.resultContorller resetPosition];
        [self.resultContorller.view removeFromSuperview];
        
        self.showKey = NO;
        
        if (_task) {
            [_task cancel];
            _task = nil;
            [self.hudTool removeHudWithBackground];
        }
        
        showHistory = YES;
        [self handleFooterWhenSetLocal];
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


/**
 初始化数据库相关信息
 */
- (void)initDB{
    
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [docsdir stringByAppendingPathComponent:@"user.sqlite"];
    _db = [FMDatabase databaseWithPath:dbPath];
    _tableName = @"NewSearchHistory";
}
/**
 从本地数据库中获取搜索历史
 */
- (void)getLocalHistory{
    
    if ([_db open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from '%@' order by searchid desc",_tableName];
        FMResultSet *rs = [_db executeQuery:sql];
        
        NSMutableArray *localMArr = [[NSMutableArray alloc] initWithCapacity:0];
        while ([rs next]) {
            NSString *word = [rs stringForColumn:@"keywords"];
            if (![self.hotArr containsObject:word]) {
                [localMArr addObject: word];
            }
        }
        self.historyArr = localMArr;
        self.historySCell.historyArr = self.historyArr;
        [self.historySCellCollecV reloadData];
    }
}

/**
 点击删除全部按钮
 @param sender
 */
- (void)pressDelBtn:(UIButton *)sender{
    
    [PublicTool alertActionWithTitle:@"提示" message:@"您确定要删除所有搜索历史吗?"  cancleAction:^{
        
    } sureAction:^{
        [self delAllHistory:nil];
        
    }];
}

/**
 删除数据库中搜索历史
 
 @param keywords
 */
- (void)delAllHistory:(NSString *)keywords{
    
    NSString *delSql = @"";
    if (keywords) {
        //删除单个
        delSql = [NSString stringWithFormat:@"delete from '%@' where keywords='%@'",_tableName,keywords];
        
        [self.historyArr removeObject:keywords];
    }
    else{
        
        //删除多个
        delSql = [NSString stringWithFormat:@"delete from '%@'",_tableName];
        [self.historyArr removeAllObjects];
    }
    
    [_db executeUpdate:delSql];
    
    [self handleFooterWhenSetLocal];
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
    //CGRectMake(10, kScreenTopHeight-32-6, SCREENW-10-10, 32);
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW - 78, 44)];
    
    self.searchTf = [[UITextField alloc]initWithFrame:CGRectMake(0, 6, view.width, 32)];
    self.searchTf.backgroundColor = H568COLOR;
    UIImageView *leftImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 35, self.searchTf.frame.size.height)];
    leftImg.image = [UIImage imageNamed:@"search"];
    leftImg.contentMode = UIViewContentModeCenter;
    _searchTf.returnKeyType = UIReturnKeySearch;
    _searchTf.leftView = leftImg;
    _searchTf.leftViewMode = UITextFieldViewModeAlways;
    _searchTf.placeholder = @"项目、机构、人物、新闻、公司、报告";
    [_searchTf setValue:H9COLOR forKeyPath:@"_placeholderLabel.textColor"];
    
    _searchTf.tintColor = [UIColor blackColor];
    _searchTf.layer.masksToBounds = YES;
    _searchTf.layer.cornerRadius = 4;
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

/**
 将搜索关键字存储到本地
 */
- (void)storeKeywords:(NSString *)keyword{
    
    if ([_db open]) {
        
        if (self.historyArr.count > 20) {
            for (int i = 20; i<self.historyArr.count; i++) {
                NSString *delSql = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE keywords='%@'",_tableName,self.historyArr[i]];
                [_db executeUpdate:delSql];
            }
        }        
        
        NSString *delSql = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE keywords='%@'",_tableName,keyword];
        if ([_db executeUpdate:delSql]) {
            
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'(keywords,version) values('%@','%@')",_tableName,keyword,VERSION];
            [_db executeUpdate:insertSql];
        }
    }
    [self getLocalHistory];
}


- (void)initTableView{
    
    //tableView
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchRegistCell" bundle:nil] forCellReuseIdentifier:@"SearchRegistCellID"];
    
    self.resultContorller = [[MainResultController alloc]init];
    self.resultContorller.view.frame = CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight);
    [self addChildViewController:self.resultContorller];
    
}

- (void)pullUp{
    
}


/**
 将字符串转换成可以跳转到详情页的dict
 
 @param tempStr
 @return
 */
- (NSMutableDictionary *)toGetDictFromStr:(NSString *)tempStr{
    
    NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *maskStr =@"?";
    NSArray *arr1 = [tempStr componentsSeparatedByString:maskStr]; //从字符A中分隔成2个元素的数组
    maskStr = @"&";
    NSArray *arr2 = [arr1[1] componentsSeparatedByString:maskStr];
    maskStr = @"=";
    for (NSString *tmpStr in arr2) {
        
        NSArray *arr3 = [tmpStr componentsSeparatedByString:maskStr];
        [mdict setValue:arr3[1] forKey:arr3[0]];
    }
    
    return mdict;
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
        _keyArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _keyArr;
}

- (NSMutableArray *)hotArr{
    
    if (!_hotArr) {
        _hotArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _hotArr;
}

- (NSMutableArray *)hotIconArr{
    
    if (!_hotIconArr) {
        _hotIconArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _hotIconArr;
}
- (SearchhistoryCell*)historySCell{
    if (!_historySCell) {
        _historySCell = [[SearchhistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"attentCellID"];
        _historySCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _historySCell.frame = CGRectMake(0, 0, SCREENW, 50);
    }
    return _historySCell;
}

@end
