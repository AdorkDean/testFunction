//
//  BPSelectController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BPSelectController.h"
#import "BPSelectCell.h"
#import "FileWebViewController.h"

#import "FileItem.h"
 

@interface BPSelectController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIScrollViewDelegate>

{
    NSInteger _currentPage;
    NSInteger _num;
    NSInteger _searchCurrentPage;
    NSInteger _searchNum;
}


@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UIButton *cancleSearchBtn;
@property (strong, nonatomic) NSMutableArray *searchArr;
@property (assign, nonatomic) BOOL isSearch;

@property (strong, nonatomic) UIView *noCollectionView;
@property (strong, nonatomic) UILabel *infoLbl;

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSMutableDictionary *downloadVMDict;


@end

@implementation BPSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"选择BP";
    [self initTableView];
    
    [self keyboardManager];
  
    
    self.currentPage = 1;
    self.numPerPage = 20;
    _searchCurrentPage = 1;
    _searchNum = self.numPerPage;
    
    [self showHUD];
    [self requestGetCollectPdfLsit:self.currentPage ofNum:self.numPerPage];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - tableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.isSearch) {
        if ([self.mySearchBar.text isEqualToString:@""]) {
            return 0;
        }
        return (self.searchArr.count == 0 ? 1 : self.searchArr.count);
        
    }else{
        return (self.tableData.count == 0 ? 1 : self.tableData.count);
        
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UILabel *titleLabel = [[UILabel alloc]init];
    [titleLabel labelWithFontSize:15 textColor:NV_TITLE_COLOR];
    titleLabel.numberOfLines = 2;
    
    if (self.isSearch) {
        if ([self.mySearchBar.text isEqualToString:@""]) {
            return 0;
        }
        if (self.searchArr.count == 0) {
            return SCREENH - kScreenTopHeight;
        }
        if (self.searchArr.count > 0 ) {
            ReportModel *report = self.searchArr[indexPath.row];
            CGRect rect = [report.name boundingRectWithSize:CGSizeMake((SCREENW - 69), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
            CGFloat height = titleLabel.font.lineHeight;
            CGFloat rows = rect.size.height / height;
            
            if (rows >= 2.0) {
                return 88;
            }else{
                return 61;
            }
            
        }
       
    }else{
        
        if (self.tableData.count == 0 ) {
            return SCREENH - kScreenTopHeight;
        }
        ReportModel *report = self.tableData[indexPath.row];
        NSString *title;
        if (!self.isToMe) {
            title = report.name;
        }else{
            title = [NSString stringWithFormat:@"%@ %@", report.name, [PublicTool isNull:report.product]?@"":[NSString stringWithFormat:@"-%@", report.product]];
        }
        CGRect rect = [title boundingRectWithSize:CGSizeMake((SCREENW - 69), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
        CGFloat height = titleLabel.font.lineHeight;
        CGFloat rows = rect.size.height / height;
        
        if (rows >= 2.0) {
            return 88;
        }else{
            return 61;
        }
        
    }
    return 0.1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((self.tableData.count == 0 && !self.isSearch ) || (self.searchArr.count == 0 && self.isSearch)) {
        
        NSString *title = self.isSearch ? REQUEST_SEARCH_NULL : (self.isToMe ? REQUEST_DATA_NULL:@"您还没有自己的BP文档\n请点击右上角进行上传");
        return [self nodataCellWithInfo:title tableView:tableView];
    }
    else{
        
        ReportModel *reportModel = self.isSearch ? self.searchArr[indexPath.row] : self.tableData[indexPath.row];
        
        BPSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BPSelectCellID" forIndexPath:indexPath];
        if (_isToMe) {
            cell.isMyBP = YES;
        }else{
            cell.isMyBP = NO;
        }
        
        cell.keyWord = _isSearch ? self.mySearchBar.text : nil;
        cell.report = reportModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.selecctBtn.userInteractionEnabled = NO;
        
        return cell;
    }
}


- (void)clearSelectedReportState{
    if (_isSearch) {
        
        [self clearSelected:self.searchArr];
    }else{
        [self clearSelected:self.tableData];
    }
    [self.tableView reloadData];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}
    if ((self.tableData.count >0 && !self.isSearch ) || (self.searchArr.count > 0 && self.isSearch)){
        
        if (_isSearch) {
            
            ReportModel *report = self.searchArr[indexPath.row];
//            if (report.send_status.integerValue == 2) {
//                return;
//            }
//            
            [self clearSelected:self.searchArr];
            if (self.clearSelectedReport) {
                self.clearSelectedReport();
            }
            report.selected = YES;
            self.selectedReport(report);
            
        }else{
            
            ReportModel *report = self.tableData[indexPath.row];
//
//            if (report.send_status.integerValue == 2) {
//                return;
//            }
            [self clearSelected:self.tableData];
            if (self.clearSelectedReport) {
                self.clearSelectedReport();
            }
            report.selected = YES;
            self.selectedReport(report);
            
        }
        [self.tableView reloadData];
    }    
}
- (void)clearSelected:(NSMutableArray*)dataArr{
    
    [dataArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ReportModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = NO;
    }];
}

#pragma mark - UISearchBar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    self.mjFooter.stateLabel.hidden = YES;
    
    _searchCurrentPage = 1;
    
    if (!self.isSearch) {
        
        [self clearSelected:self.tableData];
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
    
    if (self.tableView.mj_footer.state == MJRefreshStateNoMoreData) {
        [self.tableView.mj_footer resetNoMoreData];
    }
    if ([searchBar.text isEqualToString:@""]) {
        self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    if (![searchBar.text isEqualToString:@""]) {
        _searchCurrentPage = 1;
        _isSearch = YES;
        [self requestGetCollectPdfLsit:_searchCurrentPage ofNum:_searchNum];
        [self.mySearchBar resignFirstResponder];
    }
}



#pragma mark - 请求获取列表
- (void)beginSearch:(NSString*)text{
    
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
    _searchNum = 20;
    [self requestGetCollectPdfLsit:_searchCurrentPage ofNum:_searchNum];
}

- (void)disAppear{  //左右切换
    
    if (self.mySearchBar.text.length == 0 && self.isSearch) {
        [self cancleSearch];
    }
}

#pragma mark - 请求BP列表
- (void)requestGetCollectPdfLsit:(NSInteger)currentPage ofNum:(NSInteger)num{
    
    if (self.isToMe) {
        [self requestBPToMe];
    }else{
        [self requestBP];
    }
    
}

- (void)requestBPToMe{
    
    self.info = @"";
    
    if([TestNetWorkReached networkIsReachedNoAlert]){
        NSDictionary *dic = @{@"page":@(self.currentPage),@"num":@(self.numPerPage),@"keyword":[PublicTool isNull:self.mySearchBar.text]?@"":self.mySearchBar.text,@"personid":self.personId?self.personId:@""};
        
        [AppNetRequest getBPToMeListWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            [self hideHUD];
            
            NSMutableArray *retMArr = [[NSMutableArray alloc] initWithArray:[self handlePdfListDict:resultData]];
            
            [self dealData:retMArr];
            QMPLog(@"MY BP:%@", retMArr);
            [self.tableView reloadData];
            [self refreshFooter:retMArr];
        }];
        
    }else{
        
        self.info = @"请检查网络连接设置";
        [self.tableView reloadData];
        
        [self hideHUD];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
    }
}

- (void)requestBP{
    
    self.info = @"";
    
    if([TestNetWorkReached networkIsReachedNoAlert]){
        NSDictionary *dic = @{@"page":@(self.currentPage),@"num":@(self.numPerPage),@"keyword":[PublicTool isNull:self.mySearchBar.text]?@"":self.mySearchBar.text,@"personid":self.personId?self.personId:@""};
        
        [AppNetRequest getBPListWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            [self hideHUD];
            
            NSMutableArray *retMArr = [[NSMutableArray alloc] initWithArray:[self handlePdfListDict:resultData]];
            
            [self dealData:retMArr];
            [self.tableView reloadData];
            [self refreshFooter:retMArr];
        }];
    }else{
        
        self.info = @"请检查网络连接设置";
        [self.tableView reloadData];
        
        [self hideHUD];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
    }
}

- (void)dealData:(NSMutableArray*)array{
    if (self.isSearch) {
        if (_searchCurrentPage == 1) {
            self.searchArr = array;
        }
        else{
            
            for (ReportModel *reportModel in array) {
                if ([self.sourceReport.pdfUrl isEqualToString:reportModel.pdfUrl]) {
                    reportModel.selected = YES;
                    self.selectedReport(reportModel);
                }
                [self.searchArr addObject:reportModel];
            }
        }
        [self refreshFooter:array];
        
        if (self.searchArr.count == 0) {
            self.info = @"暂无相关信息,请换个关键词试试";
        }
        
    }else{
        if (self.currentPage == 1) {
            self.tableData = array;
        }
        else{
            
            for (ReportModel *reportModel in array) {
                
                [self.tableData addObject:reportModel];
            }
        }
        [self refreshFooter:array];
        
        if (self.tableData.count == 0) {
            self.info = @"暂无文档";
        }
    }
    
}


- (NSMutableArray *)handlePdfListDict:(NSDictionary *)dict{
    
    
    NSMutableArray *reportMArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *dataArr ;
    if (dict && dict[@"list"]&& [dict[@"list"] isKindOfClass:[NSArray class]]) {
        dataArr  = [dict objectForKey:@"list"];
        
    }else{
        dataArr = @[];
    }
    
    for (NSDictionary *dataDict in dataArr) {
        
        ReportModel *reportModel = [[ReportModel alloc] init];
        reportModel.isBP = @"1";
        reportModel.name = [dataDict objectForKey:@"bp_name"];
        reportModel.reportId = [dataDict objectForKey:@"id"];
        reportModel.fileid = [dataDict objectForKey:@"fileid"];
        reportModel.datetime = [dataDict objectForKey:@"create_time"];
        reportModel.pdfUrl = [dataDict objectForKey:@"bp_link"];
        reportModel.size = [dataDict objectForKey:@"bp_size"];
        reportModel.collectFlag = @"1";  //BP默认收藏
        reportModel.report_source = @"上传";
        
        reportModel.product = [dataDict objectForKey:@"product"];
        reportModel.icon = [dataDict objectForKey:@"icon"];
        reportModel.send_status = [dataDict objectForKey:@"send_status"]; //2标识可投递

        if ([self.sourceReport.reportId isEqualToString:reportModel.reportId]
            && [self.sourceReport.pdfUrl isEqualToString:reportModel.pdfUrl]) {
            reportModel.selected = YES;
            self.selectedReport(reportModel);
        }
        
        NSString *fileExtension;
        NSArray *arr = [[reportModel.pdfUrl lastPathComponent] componentsSeparatedByString:@"."];
        if (arr.count) {
            fileExtension = [arr lastObject];
        }
        reportModel.pdfType = [dataDict objectForKey:@"filetype"];;
        reportModel.fileExt = fileExtension ? [fileExtension lowercaseString] : @"";
        
        reportModel.from = PDFCOLLECT;
        [reportMArr addObject:reportModel];
    }
    
    return reportMArr;
}



#pragma mark - public
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

- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = self.mjHeader;
    [self.tableView registerClass:[BPSelectCell class] forCellReuseIdentifier:@"BPSelectCellID"];
    [self.view addSubview:self.tableView];
    
    
    CGFloat height = 44.f;
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, height)];
    _tableHeaderView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.tableHeaderView = _tableHeaderView;
    
    _mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(7, 0, SCREENW-14, height)];
    [_mySearchBar setBackgroundImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_mySearchBar.size]];
    //    _mySearchBar.backgroundImage = [BundleTool imageNamed:@"nav-lightgray"];
    //设置背景色
    [_mySearchBar setBackgroundColor:TABLEVIEW_COLOR];
    [_mySearchBar setSearchFieldBackgroundImage:[BundleTool imageNamed:@"search_borderTab"] forState:UIControlStateNormal];
    [_mySearchBar setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
    UITextField *tf = [_mySearchBar valueForKey:@"_searchField"];
    tf.font = [UIFont systemFontOfSize:14];
    NSString *str = @"搜索BP";
    tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    _mySearchBar.delegate = self;
    [_tableHeaderView addSubview:_mySearchBar];
    
    CGFloat width = 60.f;
    _cancleSearchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [_cancleSearchBtn setTitle:@"取消" forState:UIControlStateNormal];
    _cancleSearchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_cancleSearchBtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
    [_cancleSearchBtn addTarget:self action:@selector(pressCancleSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
    _cancleSearchBtn.frame = CGRectMake(SCREENW - width - 1, (_tableHeaderView.frame.size.height - height)/2, width, height);
    
    //底部线条
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _tableHeaderView.height - 0.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [_tableHeaderView addSubview:line];
//    
//    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
//    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
//    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
//    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
//    [rightBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
//    self.navigationItem.rightBarButtonItem = item;
    
}

//- (void)sureBtnClick{
//    BOOL selected = NO;
//    if (_isSearch) {
//        for (ReportModel *report in self.searchArr) {
//            if (report.selected == YES) {
//                selected = YES;
//                self.selectedReport(report);
//                break;
//            }
//        }
//    }else{
//        for (ReportModel *report in self.tableData) {
//            if (report.selected == YES) {
//                selected = YES;
//                self.selectedReport(report);
//                break;
//            }
//        }
//    }
//    
//    if (selected) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }else{
//        [PublicTool showMsg:@"请选择要投递的BP"];
//    }
//}

- (void)pressCancleSearchBtn:(UIButton *)sender{
    [self cancleSearch];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.isSearch && [self.mySearchBar.text isEqualToString:@""]) {
        [self cancleSearch];
    }
    else{
        
        if ([self.mySearchBar isFirstResponder]) {
            [self.mySearchBar resignFirstResponder];
        }
        
    }
}


- (void)cancleSearch{
    
    if (self.tableView.mj_footer.state == MJRefreshStateNoMoreData) {
        [self.tableView.mj_footer resetNoMoreData];
    }
    
    self.isSearch = NO;
    [self.searchArr removeAllObjects];
    
    [self.mySearchBar resignFirstResponder];
    CGRect frame = self.mySearchBar.frame;
    frame.size.width = SCREENW - 14;
    self.mySearchBar.frame = frame;
    self.mySearchBar.text = @"";
    _searchCurrentPage = 1;
    [self.cancleSearchBtn removeFromSuperview];
    
    [self.tableView reloadData];
    [self changeDataFooter:self.tableData];
}


- (void)changeDataFooter:(NSMutableArray *)arr{
    
    if (arr.count < self.numPerPage) {
        
        self.mjFooter.stateLabel.hidden = NO;
        [self.mjFooter endRefreshingWithNoMoreData];
        
    }else{
        self.mjFooter.stateLabel.hidden = YES;
        self.mjFooter.state = MJRefreshStateIdle;
        
    }
}


- (void)pullDown{
    
    self.tableView.mj_footer = nil;
    if (_isSearch) {
        _searchCurrentPage = 1;
        [self requestGetCollectPdfLsit:_searchCurrentPage ofNum:_searchNum];
        
    }else{
        self.currentPage = 1;
        [self requestGetCollectPdfLsit:self.currentPage ofNum:self.numPerPage];
        
    }
}
- (void)pullUp{
    if (_isSearch) {
        _searchCurrentPage++;
        [self requestGetCollectPdfLsit:_searchCurrentPage ofNum:_searchNum];
        
    }else{
        self.currentPage ++;
        [self requestGetCollectPdfLsit:self.currentPage ofNum:self.numPerPage];
        
    }
    
}
#pragma mark - 懒加载

-(NSMutableArray *)searchArr{
    if (!_searchArr) {
        _searchArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _searchArr;
}
- (NSMutableArray *)tableData{
    
    if (!_tableData) {
        _tableData = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _tableData;
}

@end



