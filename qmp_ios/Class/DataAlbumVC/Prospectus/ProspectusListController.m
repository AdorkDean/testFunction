//
//  ProspectusListController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/8.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProspectusListController.h"
#import "ReportListNewCell.h"
#import "ProspectusListCell.h"
#import "OpenDocument.h"
#import "DownloadView.h"
#import "FileWebViewController.h"
#import "FileItem.h"
#import "ReportModel.h"
#import "DownloadTool.h"
#import "ProspectusFilterView.h"

#define TabNameKey @"ProspectusList"
@interface ProspectusListController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,OpenDocumentDelegate,DownloadViewDelegate,ProspectusFilterViewDelegate>{
    
    NSInteger _searchCurrentPage;
    BOOL isFilter;
    ProspectusFilterView *_filterV;
}

@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UIButton *cancleSearchBtn;

@property (strong, nonatomic) NSMutableArray *reportArr;
@property (strong, nonatomic) NSMutableArray *searchArr;
@property (strong, nonatomic) NSMutableArray *filtFiledArr;
@property (strong, nonatomic) NSMutableArray *jieduanArr;
@property (strong, nonatomic) NSMutableArray *timeArr;


@property (assign, nonatomic) BOOL isSearch;
@property (strong, nonatomic) NSMutableDictionary *downloadVMDict;

@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) NSString *tableName;

@property (strong, nonatomic) NSDateFormatter *dateFormat;
@property (strong, nonatomic) MJRefreshAutoNormalFooter *footer;
@property (strong, nonatomic) UIView *firstView;

@property (strong, nonatomic) UISearchBar *mySearchBar;


@property (strong, nonatomic) GetSizeWithText *sizeTool;
@property (strong, nonatomic) ManagerHud *hudTool;
@property(nonatomic,strong) ReportListNewCell *reportCell;
@property(nonatomic,strong) UIButton *filterBtn;
@end

@implementation ProspectusListController
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [IQKeyboardManager sharedManager].enable = NO;
    [QMPEvent beginEvent:@"trz_prospectus_timer"];

}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [self.view endEditing:YES];
    [QMPEvent endEvent:@"trz_prospectus_timer"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"招股书";
    
    [self initTableView];
    
    [self showHUD];
    
    [self keyboardManager];
    
    [self toSetLocalData];
    
    _searchCurrentPage = 1;
    self.currentPage = 1;
    self.numPerPage = 20;
    [self requestList:self.currentPage ofNum:self.numPerPage];

    [self buildBarbutton];
    
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(receiveDownloadSuccess:) name:NOTIFI_PDFDOWNSUCCESS object:nil];
    [notiCenter addObserver:self selector:@selector(receiveDownloadFail:) name:NOTIFI_PDFDOWNFAIL object:nil];
}

- (void)buildBarbutton{
    
    NSString *btnImg = @"bar_setgray";
    
    if ( self.filtFiledArr.count > 0 || self.jieduanArr.count>0 || self.timeArr.count > 0) {
        
        btnImg = @"bar_setBlue";
    }
    
    self.filterBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
    [self.filterBtn setImage:[UIImage imageNamed:btnImg] forState:UIControlStateNormal];
    [self.filterBtn setImageEdgeInsets:UIEdgeInsetsMake(3, 0, -3, 0)];
    [self.filterBtn addTarget:self action:@selector(pressNotStoreFilterBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.filterBtn.enabled = YES;
    UIBarButtonItem *filterBarItem = [[UIBarButtonItem alloc]initWithCustomView:self.filterBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = RIGHTNVSPACE;
    if (iOS11_OR_HIGHER) {
        
        self.filterBtn.width = 30;
        self.filterBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:self.filterBtn];
        
        self.navigationItem.rightBarButtonItems = @[buttonItem];
        
        
    }else{
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,filterBarItem];
    }
    
    
}

- (void)pressNotStoreFilterBtn:(UIButton *)sender{
    
    [self cancleSearch];
    
    
    isFilter = YES;
    
    _filterV = [ProspectusFilterView initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH) withKey:TabNameKey];
    ((ProspectusFilterView *)_filterV).delegate = self;
    [KEYWindow addSubview:_filterV];
    [QMPEvent event:@"trz_prospectus_filterclick"];
    
}



- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([_db open]) {
        [_db close];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark --ProspectusFilterView--
-(void)updateRongziNews:(NSMutableArray *)selectedMArr withBanKuaiMArr:(NSMutableArray *)banKuaiMArr timeMArr:(NSMutableArray *)timeMArr{
    
    isFilter = YES;
    self.filtFiledArr = [NSMutableArray arrayWithArray:selectedMArr];
    self.jieduanArr = [NSMutableArray arrayWithArray:banKuaiMArr];
    self.timeArr = [NSMutableArray arrayWithArray:timeMArr];
    //处理筛选项的选中状态
    if ([_db open]) {
        
        NSString *tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsindustry",TabNameKey]];
        NSString *values = [self handleArrToSqlStr:self.filtFiledArr];
        NSString *selectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='1'  WHERE name in (%@)",tableName,values];
        NSString *notSelectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='0'  WHERE name not in (%@)",tableName,values];
        NSLog(@"selectsql ==== %@",selectSql);
        NSLog(@"notselectsql ==== %@",notSelectSql);
        [_db executeUpdate:selectSql];
        [_db executeUpdate:notSelectSql];
        
        
        NSString *eventTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsevent",TabNameKey]];
        NSString *value2 = [self handleArrToSqlStr:self.jieduanArr];
        NSString *selectSql2 = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='1'  WHERE name in (%@)",eventTableName,value2];
        NSString *notSelectSql2 = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='0'  WHERE name not in (%@)",eventTableName,value2];
        NSLog(@"selectsql ==== %@",selectSql2);
        NSLog(@"notselectsql ==== %@",notSelectSql2);
        [_db executeUpdate:selectSql2];
        [_db executeUpdate:notSelectSql2];
        
        NSString *timeTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewstime",TabNameKey]];
        NSString *value3 = [self handleArrToSqlStr:self.timeArr];
        NSString *selectSql3 = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='1'  WHERE name in (%@)",timeTableName,value3];
        NSString *notSelectSql3 = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='0'  WHERE name not in (%@)",timeTableName,value3];
        NSLog(@"selectsql ==== %@",selectSql3);
        NSLog(@"notselectsql ==== %@",notSelectSql3);
        [_db executeUpdate:selectSql3];
        [_db executeUpdate:notSelectSql3];
    }
    
    [_db close];
    
    [self.tableView.mj_header beginRefreshing];
    [self buildBarbutton];
    //刷新时不可筛选
    self.filterBtn.enabled = NO;
    
    [QMPEvent event:@"trz_prospectus_filter_sureclick"];
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
#pragma mark - OpenDocumentDelegate
- (void)downloadPdfUseWWAN:(ReportModel *)reportModel{
    
    [self requestDownloadDocument:reportModel];
}

#pragma mark - DownloadViewDelegate
- (void)receiveDownloadSuccess:(NSNotification *)noti{
    
    NSDictionary *dict = (NSDictionary *)noti.object;
    
    NSString *pdfType = dict[@"from"];
    if ([pdfType isEqualToString:ZGS]) {
        
        ReportModel *model = [[ReportModel alloc] init];
        model.reportId = dict[@"id"];
        model.name = dict[@"title"];
        model.pdfUrl  = dict[@"url"];
        model.collectFlag = dict[@"collect"];
        model.report_date = dict[@"report_date"];
        model.report_source = dict[@"report_source"];
        model.hangye1 = dict[@"hangye1"];
        model.shangshididian = dict[@"shangshididian"];
        model.pdfType = dict[@"type"];
        [self downloadNewPdfSuccess:model];
    }
}


- (void)receiveDownloadFail:(NSNotification *)noti{
    
    ReportModel *pdfModel = (ReportModel *)noti.object;
    
    if ([pdfModel.from isEqualToString:ZGS]) {
        
        FileItem *file = [[FileItem alloc] init];
        file.fileName = pdfModel.name;
        file.fileUrl = pdfModel.pdfUrl;
        file.fileId = pdfModel.reportId;
        
        FileWebViewController *webVC = [[FileWebViewController alloc] init];
        webVC.fileItem = file;
        webVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webVC animated:YES];
    }
    NSString *key = pdfModel.reportId;
    DownloadView *downloadAlertV = [self.downloadVMDict objectForKey:key];
    
    if(downloadAlertV.isShow){
        //如果没有被隐藏,则打开pdf
        [downloadAlertV removeFromSuperview];
    }
    
    if ([[self.downloadVMDict allKeys] containsObject:key]) {
        [self.downloadVMDict removeObjectForKey:key];
    }
}


/**
 隐藏或者直接下载完成后进行的操作
 
 @param newPdfModel
 @param isHidden
 */
- (void)downloadNewPdfSuccess:(ReportModel *)newPdfModel{
    
    [self handleArr:self.searchArr withNewPdfModel:newPdfModel];
    [self handleArr:self.reportArr withNewPdfModel:newPdfModel];
    
    [self.tableView reloadData];
    
    NSString *key = newPdfModel.reportId;
    DownloadView *downloadAlertV = [self.downloadVMDict objectForKey:key];
    
    if(downloadAlertV.isShow){
        //如果没有被隐藏,则打开pdf
        [downloadAlertV removeFromSuperview];
        [self openPDF:newPdfModel];
        
    }
    
    if ([[self.downloadVMDict allKeys] containsObject:key]) {
        [self.downloadVMDict removeObjectForKey:key];
    }
    
}
- (ReportModel *)handleArr:(NSMutableArray *)mArr withNewPdfModel:(ReportModel *)newPdfModel{
    
    ReportModel *pdfModel = nil;
    for (int i = 0 ; i < mArr.count ; i++) {
        pdfModel = mArr[i];
        if ([newPdfModel.pdfUrl isEqualToString:pdfModel.pdfUrl]) {
            pdfModel.isDownload = YES;
            [mArr replaceObjectAtIndex:i withObject:pdfModel];
            break;
        }
    }
    return pdfModel;
}
- (void)openPDF:(ReportModel *)pdfModel{
    OpenDocument *openPDFTool = [[OpenDocument alloc] init];
    openPDFTool.viewController = self;
    [openPDFTool openDocumentofReportModel:pdfModel];
    
}


/**
 隐藏当前下载视图
 
 @param pdfModel
 */
- (void)pressHiddenDownLoad:(ReportModel *)pdfModel{
    
    NSString *key = pdfModel.reportId;
    DownloadView *downloadAlertV = [self.downloadVMDict objectForKey:key];
    downloadAlertV.isShow = NO;
    [self.downloadVMDict setValue:downloadAlertV forKey:key];
}
/**
 取消下载
 
 @param pdfModel
 */
- (void)pressCancleDownLoad:(ReportModel *)pdfModel{
    
    NSString *key = pdfModel.reportId;
    if ([[self.downloadVMDict allKeys] containsObject:key]) {
        [self.downloadVMDict removeObjectForKey:key];
    }
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
        [QMPEvent event:@"trz_prospectus_searchclick"];
        
        self.filterBtn.hidden = YES;
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
        _searchCurrentPage = 1;
        self.isSearch = YES;
        
        [self requestList:_searchCurrentPage ofNum:self.numPerPage];
        [self.mySearchBar resignFirstResponder];
    }
}

#pragma mark - UITableView
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
    
    if (_isSearch && ![self.mySearchBar.text isEqualToString:@""] && self.searchArr.count == 0) {
        
        return 1;
    }else{
        
        return self.isSearch ? self.searchArr.count : self.reportArr.count;

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isSearch && ![self.mySearchBar.text isEqualToString:@""] && self.searchArr.count == 0) {
        
        return SCREENH - kScreenTopHeight - 44;
    }else{
    
        if (self.reportArr.count == 0) {
            return SCREENH - kScreenTopHeight - 44;
        }
        ReportModel *report = self.isSearch ? self.searchArr[indexPath.row] : self.reportArr[indexPath.row];
        return [tableView fd_heightForCellWithIdentifier:@"ProspectusListCellID" configuration:^(ProspectusListCell *cell) {
            cell.report = report;
        }];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((_isSearch && ![self.mySearchBar.text isEqualToString:@""] && self.searchArr.count == 0) || (self.reportArr.count == 0)) {
        NSString *title = _isSearch ? REQUEST_SEARCH_NULL : REQUEST_FILTER_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
        
    }else{
        ReportModel *reportModel = self.isSearch ? self.searchArr[indexPath.row] : self.reportArr[indexPath.row];
        ProspectusListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProspectusListCellID" forIndexPath:indexPath];
        cell.keyWord = _isSearch ? _mySearchBar.text :nil;
        cell.report = reportModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![PublicTool userisCliamed]) {
        if ([WechatUserInfo shared].claim_type.integerValue != 1) {
            [QMPEvent event:@"report_noclaim_alert"];
        }
        return;
    }
    if ((_isSearch && ![self.mySearchBar.text isEqualToString:@""] && self.searchArr.count == 0) || (self.reportArr.count == 0)) {

        return;
    }
    if (self.isSearch && [self.mySearchBar.text isEqualToString:@""]) {
        [self cancleSearch];
    }
    else{
        [QMPEvent event:@"trz_prospectus_cellclick"];
       
        ReportModel *reportModel = self.isSearch ? self.searchArr[indexPath.row] : self.reportArr[indexPath.row];
        if ([reportModel.pdfUrl.pathExtension isEqualToString:@"pdf"] && reportModel.reportId) {
            
            OpenDocument *openPDFTool = [[OpenDocument alloc] init];
            openPDFTool.viewController = self;
            openPDFTool.delegate = self;
            
            if (reportModel.name && [openPDFTool downDocumentToBox:reportModel]) {
                //本地下载了该文档
                [openPDFTool openDocumentofReportModel:reportModel];
            
            }else{
                
                Reachability *reach = [Reachability reachabilityForInternetConnection];
                NetworkStatus status = [reach currentReachabilityStatus];
                if (status == ReachableViaWWAN) {
                    NSString *key = reportModel.reportId;
                    DownloadView *downloadAlertV = [self.downloadVMDict objectForKey:key];
                    
                    if (downloadAlertV){
                        //隐藏过,没有下载完
                        downloadAlertV.isShow = YES;
                        [self.downloadVMDict setValue:downloadAlertV forKey:key];
                        [KEYWindow addSubview:downloadAlertV];
                    }
                    else{
                        //使用数据流量的时候弹窗提醒
                        [openPDFTool launchReachableViaWWANAlert:status ofCurrentVC:self withModel:reportModel];
                    }
                }
                else{
                    
                    [self requestDownloadDocument:reportModel];
                }
            }
            
        }else{
            
            FileItem *file = [[FileItem alloc] init];
            file.fileName = reportModel.name;
            file.fileUrl = reportModel.pdfUrl;
            file.fileId = reportModel.reportId;
            
            FileWebViewController *webVC = [[FileWebViewController alloc] init];
            webVC.fileItem = file;
            webVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:webVC animated:YES];
        }
        
        
    }
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


#pragma mark - 请求获取pdf列表

- (void)requestList:(NSInteger )page ofNum:(NSInteger )num{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        
        if ( [self.mySearchBar.text isEqualToString:@""]&&self.searchArr.count > 0) {
            [self.searchArr removeAllObjects];
        }
        NSString *debug = @"0";
        if ([self.tableView.mj_header isRefreshing]) {
            debug = @"1";
        }
        
        NSMutableDictionary *searchDict = [NSMutableDictionary dictionaryWithDictionary:@{@"page":@(page),@"num":@(num),@"debug":debug}];
        
        ManagerHud *hudTool = [[ManagerHud alloc] init];
        UIView *searchHudView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, SCREENW, SCREENH - kScreenTopHeight - 50.f)];
        
       

        if (self.isSearch) {
            [searchDict setValue:[self.mySearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"keywords"];
            if (_searchCurrentPage == 1 && ![self.tableView.mj_header isRefreshing]) {
                [hudTool addHud:searchHudView];
                searchHudView.backgroundColor = [UIColor whiteColor];
                [self.view addSubview:searchHudView];
            }
        }else{
            //行业
            NSMutableString *hangyeString = [NSMutableString string];
            for (NSString *hangye in self.filtFiledArr) {
                [hangyeString appendFormat:@"%@|",hangye];
            }
            if (hangyeString.length > 1) {
                [hangyeString deleteCharactersInRange:NSMakeRange(hangyeString.length-1, 1)];
            }
            //板块
            NSMutableString *bankuaiString = [NSMutableString string];
            for (NSString *bankuai in self.jieduanArr) {
                [bankuaiString appendFormat:@"%@|",bankuai];
            }
            if (bankuaiString.length > 1) {
                [bankuaiString deleteCharactersInRange:NSMakeRange(bankuaiString.length-1, 1)];
            }
            //时间
            NSMutableString *timeString = [NSMutableString string];
            for (NSString *time in self.timeArr) {
                [timeString appendFormat:@"%@|",time];
            }
            if (timeString.length > 1) {
                [timeString deleteCharactersInRange:NSMakeRange(timeString.length-1, 1)];
            }
            [searchDict setValue:hangyeString forKey:@"hangye"];
            [searchDict setValue:bankuaiString forKey:@"stock"];
            [searchDict setValue:timeString forKey:@"time_interval"];
        }
        
        [AppNetRequest ProspectusListWithParameter:searchDict completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            [searchHudView removeFromSuperview];

            if (resultData && resultData[@"list"]) {
                NSMutableArray *retMArr = [[NSMutableArray alloc] initWithArray:[self handlePdfListDict:resultData[@"list"]]];
                if (self.isSearch) {
                    //搜索状态下
                    if (_searchCurrentPage == 1) {
                        self.searchArr = retMArr;
                    }else{
                        [self.searchArr addObjectsFromArray:retMArr];
                        
                    }
                }
                else{
                    
                    //正常状态下包含分页
                    if (self.currentPage == 1) {
                        self.reportArr = retMArr;
                    }else{
                        [self.reportArr addObjectsFromArray:retMArr];
                    }
                }
                [self refreshFooter:retMArr];
                [self.tableView reloadData];
                
            }
            
            self.filterBtn.enabled = YES;
            isFilter = NO;
       
        }];
        
    }else{

        [self hideHUD];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];

    }
}

- (NSMutableArray *)handlePdfListDict:(NSArray *)arr{
    
    NSMutableArray *pdfUrlMArr = [[DBHelper shared] toGetPdfFromLocal:_tableName fDataBase:_db];
    
    NSMutableArray *reportMArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dataDict in arr) {
            
        ReportModel *reportModel = [[ReportModel alloc] init];
        [reportModel setValuesForKeysWithDictionary:dataDict];
        reportModel.name = [dataDict objectForKey:@"title"];
        reportModel.reportId = [dataDict objectForKey:@"id"];
        reportModel.report_date = [dataDict objectForKey:@"report_time"];
        reportModel.pdfUrl = dataDict[@"link"];
        reportModel.pdfType = dataDict[@"pdf_type"];
        reportModel.collectFlag = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"collect_flag"]];
        reportModel.from = ZGS;
        reportModel.isDownload = [pdfUrlMArr containsObject:reportModel.name];
        [reportMArr addObject:reportModel];
    }
    return reportMArr;
}

#pragma mark - pubic
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
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH  - kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = self.mjHeader;
    
    self.tableView.mj_footer = self.mjFooter;
    [self.tableView registerClass:[ProspectusListCell class] forCellReuseIdentifier:@"ProspectusListCellID"];
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

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
    NSString *str = @"搜索股票代码、简称、公司名";
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

- (void)pullDown{
    
    if(self.isSearch){
        _searchCurrentPage = 1;
        [self requestList:_searchCurrentPage ofNum:self.numPerPage];
    }
    else{
        self.currentPage = 1;
        
        [self requestList:self.currentPage ofNum:self.numPerPage];
        
    }
}
- (void)pullUp{
    
    if (self.isSearch) {
        _searchCurrentPage ++;
        [self requestList:_searchCurrentPage ofNum:self.numPerPage];
        
    }
    else{
        self.currentPage ++;
        
        [self requestList:self.currentPage ofNum:self.numPerPage];
        
    }
}

- (void)handleReportDownloadStatus:(NSMutableArray *)mArr{
    
    NSMutableArray *pdfUrlMArr = [[DBHelper shared] toGetPdfFromLocal:_tableName fDataBase:_db];
    
    for (ReportModel *reportModel in mArr) {
        if ([pdfUrlMArr containsObject:reportModel.name]) {
            reportModel.isDownload = YES;
        }
        else{
            
            reportModel.isDownload = NO;
        }
    }
    
}


/**
 点击取消搜索
 
 @param sender
 */
- (void)pressCancleSearchBtn:(UIButton *)sender{
    [self cancleSearch];
}



- (void)cancleSearch{
    
    self.filterBtn.hidden = NO;
    self.isSearch = NO;
    [self.searchArr removeAllObjects];
    
    [self.mySearchBar resignFirstResponder];
    CGRect frame = self.mySearchBar.frame;
    frame.size.width = SCREENW-14;
    self.mySearchBar.frame = frame;
    self.mySearchBar.text = @"";
    
    [self.cancleSearchBtn removeFromSuperview];
    [self refreshFooter:self.reportArr];
    [self.tableView reloadData];
    
    
}
- (void)requestDownloadDocument:(ReportModel *)pdfModel{
    
    NSString *key = pdfModel.reportId;
    DownloadView *downloadAlertV = [self.downloadVMDict objectForKey:key];
    
    if (downloadAlertV){
        //隐藏过,没有下载完
        downloadAlertV.isShow = YES;
    }
    else{
        
        //之前未下载
        downloadAlertV = [DownloadView initFrame];
        downloadAlertV.delegate = self;
        downloadAlertV.isShow = YES;
        [downloadAlertV initViewWithTitle:@"正在下载" withInfo:@"" withLeftBtnTitle:@"取消" withRightBtnTitle:@"隐藏" withCenter:CGPointMake(SCREENW/2, SCREENH/2) withInfoLblH:40.f ofDocument:pdfModel];
    }
    
    [self.downloadVMDict setValue:downloadAlertV forKey:key];
    
    [KEYWindow addSubview:downloadAlertV];
    
}

- (void)toSetLocalData{
    _db = [[DBHelper shared] toGetDB];
    _tableName = PDFTABLENAME;
}

- (NSMutableArray *)getArrFromDataWithTablename:(NSString *)tablename{
    NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
    FMDatabase *db = [[DBHelper shared] toGetDB];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select name from '%@' where selected='1'",tablename];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            [retMArr addObject:[rs stringForColumn:@"name"]];
        }
    }
    [db close];
    return retMArr;
}

#pragma mark - 懒加载

- (NSMutableDictionary *)downloadVMDict{
    
    if (!_downloadVMDict) {
        _downloadVMDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _downloadVMDict;
}
- (NSMutableArray *)reportArr{
    
    if (!_reportArr) {
        _reportArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _reportArr;
}
- (NSMutableArray *)filtFiledArr{
    
    if (!_filtFiledArr) {
        //从数据库中获取
        NSString *tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsindustry",TabNameKey]];
        _filtFiledArr = [self getArrFromDataWithTablename:tableName];
    }
    return _filtFiledArr;
}

- (NSMutableArray *)jieduanArr{
    
    if (!_jieduanArr) {
        NSString *eventTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsevent",TabNameKey]];
        _jieduanArr = [self getArrFromDataWithTablename:eventTableName];
    }
    return _jieduanArr;
}

- (NSMutableArray *)timeArr{
    
    if (!_timeArr) {
        NSString *timeTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewstime",TabNameKey]];
        _timeArr = [self getArrFromDataWithTablename:timeTableName];
    }
    return _timeArr;
}

- (NSMutableArray *)searchArr{
    
    if (!_searchArr) {
        _searchArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _searchArr;
}


- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}

- (ManagerHud *)hudTool{
    
    if(!_hudTool){
        _hudTool = [[ManagerHud alloc] init];
    }
    return _hudTool;
}



-(ReportListNewCell *)reportCell{
    
    if (!_reportCell) {
        _reportCell = [[ReportListNewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ReportListNewCell"];
    }
    return _reportCell;
}
- (NSDateFormatter *)dateFormat{
    if (!_dateFormat) {
        _dateFormat = [[NSDateFormatter alloc]init];
        [_dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [_dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormat;
}


@end
