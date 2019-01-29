//
//  SearchDetailViewController.m
//  QiMingPian
//
//  Created by qimingpian08 on 16/4/28.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "SearchDetailViewController.h"
#import "RegisterInfoViewController.h"
#import "FeedbackDetailViewControlerViewController.h"
#import "NewsWebViewController.h"
#import "CustomAlertView.h"
#import "SearchJigouCell.h"
#import "SearchRegistCell.h"
#import "IPOCompanyCell.h"
#import "SearchJgAndCNotFoundTableViewCell.h"

#import "SearchJigouModel.h"
#import "SearchCompanyModel.h"
#import "URLModel.h"
#import "SearchProRegisterModel.h"


#import "GetMd5Str.h"
#import <IQKeyboardManager.h>
#import <objc/runtime.h>
#import "SearchhistoryCell.h"

@interface SearchDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NewsWebViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>
{
    BOOL showHistory;//是否显示搜索历史
    BOOL showKey;   //搜索到关键字
    UIView *_headerView;//吐槽 headerview
    
    BOOL  _enterBeginSearch;  //进入根据searchString是否为空，判断是否是带着搜索参数进入的
    BOOL _firstEnter;
    
}


@property (strong, nonatomic) UITextField *searchTf;

@property (strong, nonatomic) UIButton *feedbackBtn;
@property (strong, nonatomic) UIView *tableFooterView;
@property (strong, nonatomic) MJRefreshAutoNormalFooter *footer;

@property(nonatomic,strong) NSMutableArray * companysModelMArr;//存公司model
@property(nonatomic,strong) NSMutableArray * jigousModelMArr;//存机构model
@property(nonatomic,strong) NSMutableArray * registModelMArr;//存机构model

@property (strong, nonatomic) NSMutableArray *localArr;//本地存放的历史记录
@property (strong, nonatomic) NSMutableArray *keyArr;//联想的关键词

@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) NSString *tableName;

@property (strong, nonatomic) NSURLSessionDataTask *task;//当前页面只有一个搜索请求在进行
@property (strong, nonatomic) AlertInfo *alertTool;
@property (strong, nonatomic) AlertInfo *alertInfoTool;
@property (strong, nonatomic) ManagerHud *hudTool;

@end

@implementation SearchDetailViewController
#define DEBUG_LOG FALSE
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [_searchTf resignFirstResponder];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _enterBeginSearch = self.searchString ? YES:NO;
    showHistory = YES;
    _firstEnter = YES;
    
    if (_enterBeginSearch) {
        showKey = YES;

    }
    [self keyboardManager];
    
    [self buildRightBarButtonItem];
    
    [self initDB];
    [self initTableView];
    
    [self getLocalHistory];
    [self handleFooterWhenSetLocal];
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(updateFeedbackBtnStatus) name:@"searchDetailAll" object:nil];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    if (_firstEnter && !_enterBeginSearch) {
        [_searchTf becomeFirstResponder];
        _firstEnter = NO;
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
    
    if (_enterBeginSearch) {
        _searchTf.text = self.searchString;
        [self requestSearch:_searchTf.text];
        
        _enterBeginSearch = NO;
    }
    
}


-(void)dealloc{
    
    [_db close];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)pressGoToTianyancha:(UIButton *)sender{
    URLModel *urlModel = [[URLModel alloc]init];
    urlModel.url = [NSString stringWithFormat:@"http://m.tianyancha.com/search?key=%@",[_searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
    webView.fromVC = @"tianyancha";
    [self.navigationController pushViewController:webView animated:YES];
}

#pragma mark - FeedbackResultDelegate

- (void)FeedbackResultSuccess{
    [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
}
#pragma mark - 关键词联想
- (void)searchDetailWithKey:(NSString *)key{
    showKey = YES;
    QMPLog(@"--------搜索关键字--------%@",key);

    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"l/wdptips" HTTPBody:@{@"w":key} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self handleFooterWhenSetLocal];
       
        if (resultData && [resultData isKindOfClass:[NSArray class]]) {
           
            self.keyArr = [NSMutableArray arrayWithArray:resultData];

            if (showKey) {
                [self.tableView reloadData];
                QMPLog(@"搜索关键字==结果-----%@",key);
            }
            
        }else{
            
            showKey = NO;
        }

        [self.tableView.mj_header endRefreshing];
    }];
    
}
#pragma mark - 请求搜索
- (void)requestSearch:(NSString *)searchStr{
    showKey = NO;
    [_searchTf resignFirstResponder];
    
    if (searchStr.length < 1) {
        [_alertInfoTool alertWithMessage:@"搜索内容为空" aTitle:@"提示" inController:self.navigationController];
    }else{
        
        [self storeKeywords:searchStr];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:_searchDict];
        
        NSString *w = [searchStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//注意考虑特殊字符
        NSString *ticket = [NSString stringWithFormat:@"%@%@",APPKEY,searchStr];
        NSString *md5 = [[GetMd5Str md5:ticket] lowercaseString];
        [dic setValue:w forKey:@"w"];
        [dic setValue:md5 forKey:@"ticket"];
        
        self.searchString = searchStr;
        self.searchDict = dic;
        if (showHistory) {
            showHistory = NO;
        }
        
        [self.hudTool addBackgroundViewWithHud:self.view];
        [self requestData:dic];
    }
}

-(BOOL)requestData:(NSMutableDictionary *)dic{
    if (![TestNetWorkReached networkIsReached:self]) {
        
        return NO;
    }else{
        
        [self.tableView.mj_footer resetNoMoreData];
        NSString * const ABOUT_UNIONID = @"75ea5a05f89784a16fcaa51fdc81f051";
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dic];
        [dict setValue:@"qmp_ios" forKey:@"ptype"];
        [dict setValue:[NSString stringWithFormat:@"%@",VERSION] forKey:@"version"];
        NSString *unionid = [[NSUserDefaults standardUserDefaults] objectForKey:@"unionid"];
        BOOL isLogin = [ToLogin isLogin];
        if ([PublicTool isNull:unionid]||!isLogin) { //未登录
            unionid = ABOUT_UNIONID;//qmp
        }
        [dict setValue:[NSString stringWithFormat:@"%@",unionid] forKey:@"unionid"];
        [dict setValue:@"1" forKey:@"tyc_flag"];

        
        NSString *key = self.searchString;
        if (![PublicTool isNull:key] && ![_searchTf.text isEqualToString:@""]) {
            _searchTf.text = key;
        }
        
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"s/wdp4" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [self.hudTool removeHudWithBackground];
            
            _feedbackBtn.selected = NO;
            _feedbackBtn.userInteractionEnabled = YES;
            if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
                self.tableView.backgroundColor = TABLEVIEW_COLOR;
                
                NSDictionary *dataMDict = resultData;
                
                //companys
                NSMutableArray *companyMArr = [[NSMutableArray alloc] init];
                for (NSDictionary * subDic in dataMDict[@"companys"]) {
                    
                    SearchCompanyModel * model = [[SearchCompanyModel alloc]init];
                    [model setValuesForKeysWithDictionary:subDic];
                    [companyMArr addObject:model];
                }
                self.companysModelMArr = companyMArr;
                
                //jigous
                NSMutableArray *organizeMArr = [[NSMutableArray alloc] init];
                for (NSDictionary * subDic in dataMDict[@"jigous"]) {
                    
                    SearchJigouModel* model = [[SearchJigouModel alloc]init];
                    [model setValuesForKeysWithDictionary:subDic];
                    [organizeMArr addObject:model];
                }
                self.jigousModelMArr = organizeMArr;
                if (dataMDict[@"tyc"] && dataMDict[@"tyc"][@"list"]) {
                    [self.registModelMArr removeAllObjects];
                    for (NSDictionary *dic in dataMDict[@"tyc"][@"list"]) {
                        SearchProRegisterModel *registM = [[SearchProRegisterModel alloc]initWithDictionary:dic error:nil];
                        
                        [self.registModelMArr addObject:registM];
                    }
                }
            }
            
            _task = nil;
            self.tableView.tableFooterView = nil;
            
            [self.tableView.mj_header endRefreshing];
            self.mjFooter.stateLabel.hidden = NO;
            
            if (( self.jigousModelMArr.count > 0 || self.companysModelMArr.count > 0 || self.registModelMArr.count)) {
                //有搜索结果
                if (!self.tableView.mj_footer) {
                    self.tableView.mj_footer = self.mjFooter;
                }
                
                [self.tableView.mj_footer endRefreshing];
            }
            else{
                //没有搜索结果时
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            showKey = NO;
            [self.tableView reloadData];
        }];
    }
    return YES;
}

#pragma mark - UITableView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
   
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44, SCREENW, 1)];
    line.backgroundColor = LIST_LINE_COLOR;
    
    if (showKey) {
       return nil;
    }
    else{
        
        if (showHistory) {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 45.f)];

            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, SCREENW-16, 45.f)];
            headerLabel.textAlignment = NSTextAlignmentLeft;
            headerLabel.font = [UIFont systemFontOfSize:15.f];
            headerLabel.textColor = H9COLOR;
            [headerView addSubview:headerLabel];
            if (self.localArr.count > 0) {
                headerLabel.text = @"历史记录";
                UIButton *delBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 40, 5, 35, 35)];
                [delBtn setImage:[BundleTool imageNamed:@"searchDelhistory"] forState:UIControlStateNormal];
                [delBtn setContentMode:UIViewContentModeCenter];
                [delBtn addTarget:self action:@selector(pressDelBtn:) forControlEvents:UIControlEventTouchUpInside];
                [headerView addSubview:delBtn];
            }
            else{
                headerLabel.text = @"";
            }
            if (self.tableView.tableHeaderView!=nil) {
                self.tableView.sectionHeaderHeight = 0;
                self.tableView.tableHeaderView = nil;
            }
            headerView.backgroundColor = [UIColor whiteColor];
            return headerView;
        }else{
            
            //添加表头 提示文字
            if (self.companysModelMArr.count>0||self.jigousModelMArr.count>0|| self.registModelMArr.count) {
                
                _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];//表头
                _headerView.backgroundColor = [UIColor whiteColor];
                [_headerView addSubview:line];

                
                
                
                UILabel *headerLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 200, 45)];
                headerLab.backgroundColor = [UIColor clearColor];
                [_headerView addSubview:headerLab];
                headerLab.font = [UIFont systemFontOfSize:14];
                headerLab.textColor = H9COLOR;
                NSString *numStr = nil;
                NSString *numStr1 = nil;
                NSString *numStr2 = nil;

                NSString *headerStr = nil;

                numStr = [NSString stringWithFormat:@"%lu",(unsigned long)self.jigousModelMArr.count];
                numStr1 = [NSString stringWithFormat:@"%lu",(unsigned long)self.companysModelMArr.count];
                numStr2 = [NSString stringWithFormat:@"%ld",self.registModelMArr.count];
                if (self.jigousModelMArr.count && self.companysModelMArr.count) {
                    headerStr = (section == 0) ? [NSString stringWithFormat:@"投资机构 (%@)",numStr]:[NSString stringWithFormat:@"项目 (%@)",numStr1];

                }else if(self.jigousModelMArr.count){
                    headerStr =  [NSString stringWithFormat:@"投资机构 (%@)",numStr];
                }else if(self.companysModelMArr.count){
                    headerStr = [NSString stringWithFormat:@"项目 (%@)",numStr1];
                }else if(self.registModelMArr.count){
                    headerStr = [NSString stringWithFormat:@"共%@条结果",numStr2];

                }
                    
                headerLab.text = headerStr;
                headerLab.font = [UIFont systemFontOfSize:14];
                
                headerLab.text = headerStr;
                if(section == 0){
                    _feedbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    _feedbackBtn.frame = CGRectMake(SCREENW-97,0, 80, 45);
                    _feedbackBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                    _feedbackBtn.tag = 100;
                    [_feedbackBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
                    [_feedbackBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
                    [_feedbackBtn setTitle:@"无理想结果" forState:UIControlStateNormal];
                    [_feedbackBtn setTitle:@"已收到您的反馈" forState:UIControlStateSelected];
                    [_feedbackBtn addTarget:self action:@selector(feedbackAlertView1:) forControlEvents:UIControlEventTouchUpInside];//immediateFeedbackUs:  //feedbackDetail:
                    [_headerView addSubview:_feedbackBtn];
                    [_headerView addSubview:headerLab];
                    
                }
                
                if (_feedbackBtn.state == UIControlStateSelected) {
                    _feedbackBtn.layer.borderColor = [UIColor blackColor].CGColor;
                }else{
                    _feedbackBtn.layer.borderColor = RGB(211, 66, 53, 1).CGColor;
                }
                return _headerView;
            }
            else{
                return nil;
            }
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    

    if (showHistory || showKey) {
        return 0.1f;
    }else{
        
        return 10;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (showKey) {
        return 0.1f;
    }
    else{
    
        if (showHistory) {
            if (self.localArr.count > 0) {
                return 45.f;
            }
            else{
                return 0.1f;
            }
        }else{
            if (self.jigousModelMArr.count == 0 && self.companysModelMArr.count == 0&&self.registModelMArr.count == 0) { //没有数据(用户没输入或输入了但没有找到相应数据)
                return 0.1f;
            }else{
                if (self.jigousModelMArr.count && self.companysModelMArr.count) {
                    return 45;
                }else if (section == 0 && self.jigousModelMArr.count > 0 ) {
                    return 45;
                }else if (section == 0 && self.companysModelMArr.count > 0 ) {
                    return 45;
                }else if(section == 0 && self.registModelMArr.count > 0){
                    return 45;
                }
                
                return 0.1f;
            }
        }

    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (showHistory || showKey) {
        return 1;
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

    if (showKey) {
    
        return self.keyArr.count;

    }else{
    
        if (showHistory) {
            //如果是搜索历史
            return 1;
           
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

    if (showKey) { //搜索机构或公司
        return 64;
        
    }else{
    
        if (showHistory) { //显示搜索历史
            if (self.localArr.count > 0) {
                return SCREENH - kScreenTopHeight;
            }
            else{
                return SCREENH - kScreenTopHeight;
            }
        }else{ //搜索
            if (self.jigousModelMArr.count == 0 && self.companysModelMArr.count == 0 &&self.registModelMArr.count == 0 && indexPath.section == 0) {
                return SCREENH - 44 - 20;  //未搜索到
            }
            else{
                if (self.jigousModelMArr.count != 0) {
                    //jigou 不为0
                    
                    if (indexPath.section == 0) {
                        return 100;
                    }else if (self.companysModelMArr.count != 0) {
                        if (indexPath.section == 1) {
                            SearchCompanyModel *com = self.companysModelMArr[indexPath.row];
                            if (com.allipo.count > 1) {
                                return 100;
                            }else{
                                return 76;
                            }
                        }
                    }
                    
                }else  if (self.companysModelMArr.count != 0) {
                    //jigou 为0 但company不为0
                    SearchCompanyModel *com = self.companysModelMArr[indexPath.row];
                    if (com.allipo.count > 1) {
                        return 100;
                    }else{
                        return 76;
                    }
                    
                }else if(self.registModelMArr.count){
                    return 126;
                }
                return 76.f;
                
            }
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (showKey && self.keyArr.count>0) { //显示搜索结果
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
            if (self.localArr.count > 0) {
                static NSString *cellIdentifier = @"historyCell";
                SearchhistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (!cell) {
                    cell = [[SearchhistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.historyArr = _localArr;
                __weak typeof(self) weakSelf = self;
                cell.selectedIndex = ^(NSInteger index) {
                    if ([ToLogin canEnterDeep]) {
                        NSString *keyword = _localArr[index];
                        _searchTf.text = keyword;
                        [weakSelf requestSearch:keyword];
                    }else{
                        [ToLogin accessEnterDeep];
                    }
                   
                };
                return cell;
            }
            else{
                key = @"暂无搜索历史,请使用上方搜索栏进行搜索";
            }
            
        }else{
            
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            if (self.jigousModelMArr.count == 0 && self.companysModelMArr.count == 0 &&self.registModelMArr.count == 0 && indexPath.section == 0) {  //没有数据(用户没输入或输入了但没有找到相应数据)
                //没有搜到jigou和company
                SearchJgAndCNotFoundTableViewCell* cell = [[SearchJgAndCNotFoundTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil andVC:self andSearchStr:_searchString];
                NSString * tempStr = [NSString stringWithFormat:@"没有符合\"%@\"的搜索结果,你可以:",_searchString];//你可以:
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:tempStr];
                NSRange range = {5,_searchString.length};
                //设置字号
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:range];
                [cell.strLab1 setTextColor:RGB(60, 59, 65, 1)];
                //设置文字颜色
                [str addAttribute:NSForegroundColorAttributeName value:RGB(202, 68, 61, 1) range:range];
                cell.strLab1.attributedText = str;
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
                
            }else{
                //jigou company不全为0
                
                if (self.jigousModelMArr.count>0 && indexPath.section == 0) {
                    
                    static NSString *ID1 = @"SearchJigouCell";
                    SearchJigouCell *cell = [tableView dequeueReusableCellWithIdentifier:ID1];
                    if (!cell) {
                        cell = [[SearchJigouCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID1];
                    }
                    SearchJigouModel * model = self.jigousModelMArr[indexPath.row];
                    [cell refreshUI:model];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    if (indexPath.row+1 == self.jigousModelMArr.count) {
                        cell.lineV.hidden = YES;
                    }else{
                        cell.lineV.hidden = NO;
                    }
                    return cell;
                    
                }else if (self.companysModelMArr.count > 0) {
                    
                    static NSString *ID2 = @"IPOCompanyCell";
                    IPOCompanyCell *cell =  [tableView dequeueReusableCellWithIdentifier:ID2];
                    if (!cell) {
                        cell = [[IPOCompanyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID2];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    SearchCompanyModel * model = self.companysModelMArr[indexPath.row];
                    [cell refreshUI:model];
                    if (indexPath.row+1 == self.companysModelMArr.count) {
                        cell.bottomLine.hidden = YES;
                    }else{
                        cell.bottomLine.hidden = NO;
                    }
                    return cell;
                }else if(self.registModelMArr.count){
                    SearchRegistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchRegistCellID" forIndexPath:indexPath];
                    cell.keyWord = self.searchTf.text;

                    cell.registModel = self.registModelMArr[indexPath.row];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }
            }
        }
        
        NSString *title = key;
        return [self nodataCellWithInfo:title tableView:tableView];

    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}
    
    [_searchTf resignFirstResponder];
    
    if (showKey && self.keyArr.count>0) {
        
        [self requestSearch:self.keyArr[indexPath.row]];
    }
    else{
    
        BOOL isLogin = [ToLogin canEnterDeep];
        if (isLogin) {
            
            if (![TestNetWorkReached networkIsReached:self]) {
                
                return;
                
            }else{
                
                if (!showHistory) {
                    //判断indexPath得cell是不是SearchJigouCell
                    if ([[self.tableView cellForRowAtIndexPath:indexPath] class] == [SearchJigouCell class]) {
                        
                        SearchJigouModel * model = self.jigousModelMArr[indexPath.row];
                        NSDictionary *urlDict = [self toGetDictFromStr:model.detail];
                        [[AppPageSkipTool shared] appPageSkipToJigouDetail:urlDict];

                        
                    }else if ([[self.tableView cellForRowAtIndexPath:indexPath] class] == [IPOCompanyCell class]){
                       
                        SearchCompanyModel * model = self.companysModelMArr[indexPath.row];
                        
                        NSDictionary *urlDict = [self toGetDictFromStr:model.detail];
                        [[AppPageSkipTool shared] appPageSkipToProductDetail:urlDict];

                    } else if ([[self.tableView cellForRowAtIndexPath:indexPath] class] == [SearchRegistCell class]){
                        SearchProRegisterModel * model = self.registModelMArr[indexPath.row];
                        
                        NSDictionary *urlDict = [self toGetDictFromStr:model.detail];
                        RegisterInfoViewController *registerDetailVC = [[RegisterInfoViewController alloc]init];
                        NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:urlDict];
                        [mdic removeObjectForKey:@"id"];
                        [mdic removeObjectForKey:@"p"];
                        registerDetailVC.urlDict = mdic;
                        registerDetailVC.companyName = model.company;
                        [self.navigationController pushViewController:registerDetailVC animated:YES];
                        return;
                    }
                }
            }
            
        }else{
            NSLog(@"用户未登录,需要登录--%s",__FUNCTION__);
            [ToLogin accessEnterDeep];            
        }
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
- (void)textFieldDidChange:(UITextField*)tf{
    
    NSString *searchText = _searchTf.text;
    
    if([PublicTool isNull:searchText]){
        
        showKey = NO;
        
        if (_task) {
            [_task cancel];
            _task = nil;
            [self.hudTool removeHudWithBackground];
        }
        
        showHistory = YES;
        [self getLocalHistory];
        [self handleFooterWhenSetLocal];
    }
    else{
        
        if ([TestNetWorkReached networkIsReached:self]) {
            
            QMPLog(@"搜索关键字--------%@",searchText);
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
            
            [localMArr addObject: [rs stringForColumn:@"keywords"]];
        }
        
        self.localArr = localMArr;
        
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
        
        [self.localArr removeObject:keywords];
    }
    else{
        
        //删除多个
        delSql = [NSString stringWithFormat:@"delete from '%@'",_tableName];
        [self.localArr removeAllObjects];
    }
    
    [_db executeUpdate:delSql];
    
    [self handleFooterWhenSetLocal];
}


- (void)searchBaidu:(UIButton *)sender{
    URLModel *urlModel = [[URLModel alloc]init];
    urlModel.url = [NSString stringWithFormat:@"https://m.baidu.com/s?word=%@",[_searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //跳转到WebView
    NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
    webView.hidesBottomBarWhenPushed = YES;
    webView.delegate = self;
    [self.navigationController pushViewController:webView animated:YES];
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
    
    self.searchTf = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, view.width, 29)];
    self.searchTf.backgroundColor = HTColorFromRGB(0xf1f1f1);
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
    _searchTf.layer.cornerRadius = 4;
    _searchTf.clearButtonMode = UITextFieldViewModeAlways;
    [view addSubview:self.searchTf];
    _searchTf.delegate = self;
    _searchTf.font = [UIFont systemFontOfSize:14];
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
        NSString *delSql = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE keywords='%@'",_tableName,keyword];
        if ([_db executeUpdate:delSql]) {
            
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'(keywords,version) values('%@','%@')",_tableName,keyword,VERSION];
            [_db executeUpdate:insertSql];
        }
    }
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

    [self.tableView registerNib:[UINib nibWithNibName:@"SearchRegistCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"SearchRegistCellID"];
}



- (void)pullUp{

    if (!showKey) {
        //搜索状态 && 有搜索结果
        if (!showHistory &&( self.jigousModelMArr.count > 0 || self.companysModelMArr.count > 0 || self.registModelMArr.count)) {
            
            NSArray *vcArr = self.childViewControllers;
            for (UIViewController *vc in vcArr) {
                if ([vc isKindOfClass:[FeedbackDetailViewControlerViewController class]]) {
                    [vc removeFromParentViewController];
                }
            }
            FeedbackDetailViewControlerViewController *feedback = [[FeedbackDetailViewControlerViewController alloc]init];
            feedback.searchStr = _searchString;
            feedback.resultCount = self.jigousModelMArr.count + self.companysModelMArr.count+self.registModelMArr.count;
            feedback.title = @"反馈";
            __weak typeof(self) weakSelf = self;
//            feedback.beginEdit = ^{
//                weakSelf.tableView.contentOffset = CGPointMake(0, weakSelf.tableView.contentSize.height-(SCREENH -  kScreenTopHeight - 60.f));
//            };
            feedback.from = @"搜索未命中";
            feedback.view.frame = CGRectMake(0, 0, SCREENW, SCREENH -  kScreenTopHeight - 60.f);
            self.tableView.tableFooterView = feedback.view;
            
            [self addChildViewController:feedback];
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            self.mjFooter.stateLabel.hidden = NO;
            
        }
        else{
            self.mjFooter.stateLabel.hidden = NO;
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }
}

- (void)feedbackAlertView1:(UIButton *)sender{
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
      
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"百度一下",@"天眼一下",@"反馈:无理想结果", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
        [actionSheet showInView:self.view];
    }
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

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    URLModel *urlModel = [[URLModel alloc]init];
    switch (buttonIndex) {
        case 0:{
//            [actionSheet dismissWithClickedButtonIndex:<#(NSInteger)#> animated:<#(BOOL)#>];
            
            urlModel.url = [NSString stringWithFormat:@"https://m.baidu.com/s?word=%@",[_searchTf.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
            webView.fromVC = @"baidu";
            [self.navigationController pushViewController:webView animated:YES];
            break;
        }
        case 1:{
            urlModel.url = [NSString stringWithFormat:@"http://m.tianyancha.com/search?key=%@",[_searchTf.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
            webView.fromVC = @"tianyancha";
            [self.navigationController pushViewController:webView animated:YES];
            break;
        }
        case 2:
            [self feedbackAlertView2:nil];
            break;
            
        default:
            break;
    }
}

- (void)feedbackAlertView2:(UIButton *)sender{
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        [mDict setValue:@"搜索结果" forKey:@"type"];
        [mDict setValue:@"急" forKey:@"c4"];
        [mDict setValue:_searchTf.text forKey:@"c1"];
        [mDict setValue:[NSString stringWithFormat:@"%lu",self.companysModelMArr.count+self.jigousModelMArr.count] forKey:@"c2"];
        [mDict setValue:_searchTf.text forKey:@"company"];
        [mDict setValue:_searchTf.text forKey:@"product"];
        [mDict setValue:@"搜索结果不满意" forKey:@"desc"];

        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/editcommonfeedback" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
        }];
       
        [ShowInfo showInfoOnView:KEYWindow withInfo:@"感谢您的反馈"];
    }
}
#pragma mark - 反馈
-(void)feedbackDetail:(UIButton *)sender{
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        
        CGRect frame = self.view.frame;
        CGFloat height = 65;
        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息
        int moduleNum = 0;
        [infoDic setValue:@"搜索列表详情" forKey:@"module"];
        [infoDic setValue:_searchTf.text forKey:@"company"];
        [infoDic setValue:[NSString stringWithFormat:@"%lu",self.companysModelMArr.count+self.jigousModelMArr.count] forKey:@"num"];
        if (self.companysModelMArr.count<1&&self.jigousModelMArr.count<1) {
            [infoDic setValue:@"急" forKey:@"c4"];
        }else{
            [infoDic setValue:@"" forKey:@"c4"];
        }
        if (![PublicTool isNull:_searchTf.text]) {
            [infoDic setValue:_searchTf.text forKey:@"product"];
        }else{
            [infoDic setValue:@"" forKey:@"product"];
        }
        
        [mArr addObject:@"没搜到项目"];
        [mArr addObject:@"没搜到投资机构"];
        [mArr addObject:@"排序不合理"];
        [mArr addObject:@"找起来费劲"];
        [mArr addObject:@"结果显示重复"];
        
        if (mArr.count>0) {
            //                        height+=((mArr.count+1)/2*40+(mArr.count-1)/2*5);//40是选项按钮高度,间隙为5
            height += ((mArr.count-1)/2+1)*35 + 55.f;
        }
        
        [self feedbackAlertView:mArr frame:frame WithAlertViewHeight:height moduleDic:infoDic moduleNum:moduleNum];
    }
}
/**
 *  弹出反馈视图
 *
 *  @param mArr   反馈的内容选项
 *  @param frame  反馈弹窗位置 //暂时未用到
 *  @param height 弹窗高度
 *  @param module 反馈所属模块 company,product,module
 */
- (void)feedbackAlertView:(NSMutableArray *)mArr frame:(CGRect)frame WithAlertViewHeight:(CGFloat)height moduleDic:(NSDictionary *)infoDic moduleNum:(int)num{
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:frame WithAlertViewHeight:height infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:num isFeeds:NO];
}



- (void)updateFeedbackBtnStatus{
    _feedbackBtn.selected = YES;
    _feedbackBtn.userInteractionEnabled = NO;//不能重复反馈
    _feedbackBtn.frame = CGRectMake(SCREENW-120,12.5, 110, 25);
    _feedbackBtn.layer.borderColor = [UIColor blackColor].CGColor;
}
//立即反馈
- (void)immediateFeedbackUs:(UIButton *)sender{
    
    FeedbackDetailViewControlerViewController *feedback = [[FeedbackDetailViewControlerViewController alloc]init];
    feedback.searchStr = _searchTf.text;
    feedback.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:feedback animated:YES];
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


- (AlertInfo *)alertInfoTool{
    
    if (!_alertInfoTool) {
        _alertInfoTool = [[AlertInfo alloc] init];
    }
    return _alertInfoTool;
}

-(NSMutableArray *)companysModelMArr{
    if (!_companysModelMArr) {
        _companysModelMArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _companysModelMArr;
}
-(NSMutableArray *)jigousModelMArr{
    if (!_jigousModelMArr) {
        _jigousModelMArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _jigousModelMArr;
}

-(NSMutableArray *)registModelMArr{
    if (!_registModelMArr) {
        _registModelMArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _registModelMArr;
}

- (AlertInfo *)alertTool{
    
    if (!_alertTool) {
        _alertTool = [[AlertInfo alloc] init];
    }
    return _alertTool;
}


- (ManagerHud *)hudTool{
    
    if (!_hudTool) {
        _hudTool = [[ManagerHud alloc] init];
    }
    return _hudTool;
}

- (NSMutableArray *)keyArr{

    if (!_keyArr) {
        _keyArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _keyArr;
}


@end
