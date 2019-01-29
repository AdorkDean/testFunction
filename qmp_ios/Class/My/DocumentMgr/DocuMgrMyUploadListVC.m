//
//  PdfListViewController.m
//  QimingpianSearch
//
//  Created by Molly on 16/8/16.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "DocuMgrMyUploadListVC.h"
#import "MeDocumentCell.h"
#import "FileWebViewController.h"
#import "DownloadView.h"

#import "FileItem.h"
#import "OpenDocument.h"

 
#import "MeDocumentListModel.h"

@interface DocuMgrMyUploadListVC ()<UITableViewDelegate,UITableViewDataSource,DownloadViewDelegate,OpenDocumentDelegate,UISearchBarDelegate,UIScrollViewDelegate>
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

@property (strong, nonatomic) ManagerHud *hudTool;

@property (strong, nonatomic) UIView *noCollectionView;
@property (strong, nonatomic) UILabel *infoLbl;

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSMutableDictionary *downloadVMDict;

@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) NSString *tableName;


@property (strong, nonatomic) GetSizeWithText *sizeTool;
@property (strong, nonatomic) OpenDocument *openPDFTool;

@end

@implementation DocuMgrMyUploadListVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.title = @"文档管理";
    [self initTableView];
    [self toSetLocalData];
    
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(receiveDownloadSuccess:) name:NOTIFI_PDFDOWNSUCCESS object:nil];
    [notiCenter addObserver:self selector:@selector(receiveDownloadFail:) name:NOTIFI_PDFDOWNFAIL object:nil];

    [notiCenter addObserver:self selector:@selector(refreshPdfList:) name:@"collectPdfSuccess" object:nil];
    
    [self keyboardManager];

    
    self.currentPage = 1;
    self.numPerPage = 20;
    _searchNum = self.numPerPage;
    _searchCurrentPage = 1;
    
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

#pragma mark - OpenDocumentDelegate
- (void)downloadPdfUseWWAN:(ReportModel *)reportModel{
    
    [self requestDownloadDocument:reportModel];

}


#pragma mark - UISearchBar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    self.mjFooter.stateLabel.hidden = YES;
    
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


#pragma mark - DownloadViewDelegate
- (void)receiveDownloadSuccess:(NSNotification *)noti{
    
    NSDictionary *dict = (NSDictionary *)noti.object;
    
    ReportModel *model = [[ReportModel alloc] init];
    model.reportId = dict[@"id"];
    model.name = dict[@"title"];
    model.pdfUrl  = dict[@"url"];
    model.collectFlag = dict[@"collect"];
    model.report_date = dict[@"report_date"];
    model.report_source = dict[@"report_source"];
    [self downloadNewPdfSuccess:model];

}

- (void)receiveDownloadFail:(NSNotification *)noti{
    
    ReportModel *pdfModel = (ReportModel *)noti.object;
    pdfModel.collectFlag = @"禁止收藏";
    FileItem *file = [[FileItem alloc] init];
    file.fileName = pdfModel.name;
    file.fileUrl = pdfModel.pdfUrl;
    file.fileId = pdfModel.reportId;
    
    FileWebViewController *webVC = [[FileWebViewController alloc] init];
    webVC.fileItem = file;
    webVC.hidesBottomBarWhenPushed = YES;
    webVC.reportModel = pdfModel;
    [self.navigationController pushViewController:webVC animated:YES];
    
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


- (void)refreshPdfList:(NSNotification*)tf{
    self.currentPage = 1;
    [self.tableView.mj_header beginRefreshing];
//
//    ReportModel *report = tf.object;
//    if(report.collectFlag.integerValue == 0){
//        if (self.isSearch) {
//            [self.searchArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ReportModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if ([obj.reportId isEqualToString:report.reportId]) {
//                    [self.searchArr removeObject:obj];
//                }
//
//            }];
//
//        }
//
//        [self.tableData enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ReportModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj.reportId isEqualToString:report.reportId]) {
//                [self.tableData removeObject:obj];
//            }
//
//        }];
//
//        [self.tableView reloadData];
//
//    }else   if(report.collectFlag.integerValue == 1){
//
//        if (self.isSearch) {
//            BOOL haveReport = NO;
//            for (ReportModel *reportM in self.searchArr) {
//                if ([reportM.reportId isEqualToString:report.reportId]) {
//                    haveReport = YES;
//                }
//            }
//            if (!haveReport) {
//                [self.searchArr insertObject:report atIndex:0];
//            }
//
//        }
//
//        BOOL haveReport = NO;
//        for (ReportModel *reportM in self.tableData) {
//            if ([reportM.reportId isEqualToString:report.reportId]) {
//                haveReport = YES;
//            }
//        }
//        if (!haveReport) {
//            [self.tableData insertObject:report atIndex:0];
//        }
//        [self.tableView reloadData];
//
//    }

    
}

/**
 隐藏或者直接下载完成后进行的操作
 
 @param newPdfModel
 @param isHidden
 */
- (void)downloadNewPdfSuccess:(ReportModel *)newPdfModel{
    for (int i = 0 ; i < self.tableData.count ; i++) {
        ReportModel *pdfModel = self.tableData[i];
        if ([newPdfModel.pdfUrl isEqualToString:pdfModel.pdfUrl]) {
            pdfModel.isDownload = YES;
            [self.tableData replaceObjectAtIndex:i withObject:pdfModel];
            newPdfModel = pdfModel;

            break;
        }
    }
   
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
    if (self.isSearch) {
        if ([self.mySearchBar.text isEqualToString:@""]) {
            return 0;
        }
        if (self.searchArr.count > 0 ) {
            ReportModel *report = self.searchArr[indexPath.row];
            return [tableView fd_heightForCellWithIdentifier:@"MeDocumentCellID" configuration:^(MeDocumentCell *cell) {
                cell.report = report;
            }];
            
        }
        else{
            return SCREENH - kScreenTopHeight;
        }
    }else{
        if (self.tableData.count > 0 ) {
            ReportModel *report = self.tableData[indexPath.row];
            return [tableView fd_heightForCellWithIdentifier:@"MeDocumentCellID" configuration:^(MeDocumentCell *cell) {
                cell.report = report;
            }];
            
        }
        else{
            return SCREENH - kScreenTopHeight;
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((self.tableData.count == 0 && !self.isSearch ) || (self.searchArr.count == 0 && self.isSearch)) {
        
        NSString *title = _isSearch ? REQUEST_SEARCH_NULL : REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
    }
    else{
        
        ReportModel *reportModel = self.isSearch ? self.searchArr[indexPath.row] : self.tableData[indexPath.row];
        
        MeDocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeDocumentCellID" forIndexPath:indexPath];
        cell.showSource = NO;
        cell.report = reportModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
       
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}
    if ((self.tableData.count >0 && !self.isSearch ) || (self.searchArr.count > 0 && self.isSearch)){
       
        //判断网络连接状态
        if (![TestNetWorkReached networkIsReached:self]) {
            return;
        }
        
        //跳转,请求分组列表
        ReportModel *reportModel = self.isSearch ? self.searchArr[indexPath.row] : self.tableData[indexPath.row];
        reportModel.collectFlag = @"禁止收藏";
        if (reportModel.pdfUrl.length) {
            
//            reportModel.collectFlag = @"1";
            OpenDocument *openPDFTool = [[OpenDocument alloc] init];
            openPDFTool.viewController = self;
            openPDFTool.delegate = self;
            
            if (reportModel.name && [openPDFTool downDocumentToBox:reportModel]) {
                
                if ([reportModel.fileExt isEqualToString:@"pdf"]) {
                    //本地下载了该文档
                    [openPDFTool openDocumentofReportModel:reportModel];
                    
                }else{
                    FileItem *file = [[FileItem alloc] init];
                    file.fileName = reportModel.name;
                    file.fileUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:reportModel.name];
                    file.fileId = reportModel.reportId;
                    
                    FileWebViewController *webVC = [[FileWebViewController alloc] init];
                    webVC.fileItem = file;
                    webVC.collect_flag_status = reportModel.collectFlag;
                    webVC.reportModel = reportModel;
                    [self.navigationController pushViewController:webVC animated:YES];
                }
                
            }else{
                //需要下载
                if (![TestNetWorkReached networkIsReachedNoAlert]) {
                    [ShowInfo showInfoOnView:self.view withInfo:@"网络不可用"];
                    
                    return;
                }
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
        }
        else{
            
            FileItem *file = [[FileItem alloc] init];
            file.fileName = reportModel.name;
            file.fileUrl = reportModel.pdfUrl;
            file.fileId = reportModel.reportId;
            
            FileWebViewController *webVC = [[FileWebViewController alloc] init];
            webVC.fileItem = file;
            webVC.reportModel = reportModel;
            //            webVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:webVC animated:YES];
            
        }
    }
    
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
    
    if ((self.tableData.count == 0 && !self.isSearch ) || (self.searchArr.count == 0 && self.isSearch)){
        return NO;
    }
    
    return YES;
}


-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ReportModel *report;
    if (self.isSearch) {
        report = self.searchArr[indexPath.row];
    }else{
        report = self.tableData[indexPath.row];
    }
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"取消收藏" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self requestCancleCollectPdf:report];
    }];
    
    action.backgroundColor = RED_TEXTCOLOR;
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    return configuration;
}


-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    ReportModel *report;
    if (self.isSearch) {
        report = self.searchArr[indexPath.row];
    }else{
        report = self.tableData[indexPath.row];
    }
    
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消收藏" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self requestCancleCollectPdf:report];

    }];
    action.backgroundColor = RED_TEXTCOLOR;
    return @[action];
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


#pragma mark - 请求获取收藏的pdf列表
- (void)requestGetCollectPdfLsit:(NSInteger)currentPage ofNum:(NSInteger)num{
    
    self.info = @"";
    
    if([TestNetWorkReached networkIsReachedNoAlert]){
        NSDictionary *param = @{@"page":[NSString stringWithFormat:@"%ld",(long)self.currentPage],@"num":[NSString stringWithFormat:@"%ld",(long)self.numPerPage],@"keyword":[PublicTool isNull:_mySearchBar.text] ? @"":_mySearchBar.text, @"type":@"2"};
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"l/getCollectedDownFiles" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            
            if (resultData[@"msg"][@"list"]) {
               NSArray * dataArr = [MeDocumentListModel arrayOfModelsFromDictionaries:resultData[@"msg"][@"list"] error:nil];
                NSMutableArray *retMArr = [[NSMutableArray alloc] initWithArray:[self handleDocumentModleToReportModel:dataArr]];
                [self dealData:retMArr];
                [self.tableView reloadData];
                [self hideHUD];
            }
        }];
    }else{
    
        self.info = @"请检查网络连接设置";
        [self.tableView reloadData];
        
        [self hideHUD];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];

    }
}
- (void)getMyUploadList{
    
}

- (void)dealData:(NSMutableArray*)array{
    if (self.isSearch) {
        if (_searchCurrentPage == 1) {
            self.searchArr = array;
        }else{
            for (ReportModel *reportModel in array) {
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

-(void)refreshFooter:(NSArray *)arr{
    self.tableView.mj_footer = self.mjFooter;
    
    if (arr.count == 0 || arr.count < self.numPerPage) {
        
        self.mjFooter.stateLabel.hidden = NO;
        self.mjFooter.state = MJRefreshStateNoMoreData;
        [self.mjFooter endRefreshingWithNoMoreData];
        
        
    }else{
        self.mjFooter.stateLabel.hidden = YES;
        self.mjFooter.state = MJRefreshStateIdle;
    }
}
- (NSMutableArray *)handleDocumentModleToReportModel:(NSArray *)documentArr{
    
    NSMutableArray *pdfUrlMArr = [[DBHelper shared] toGetPdfFromLocal:_tableName fDataBase:_db];
    NSMutableArray *reportMArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (MeDocumentListModel * model in documentArr) {
        
        ReportModel *reportModel = [[ReportModel alloc] init];
        reportModel.name = model.name;
        reportModel.reportId = model.ID;
        reportModel.datetime = model.datetime;
        reportModel.pdfUrl = model.url;
        reportModel.collectFlag = model.collect_flag;
        reportModel.recommandFlag = model.open_flag;
        
        reportModel.size = model.size;
        reportModel.report_source = model.source;
        reportModel.remark = @"";
        reportModel.pdfType = model.filetype;
        NSString *fileExt = model.fileext;
        reportModel.fileExt = fileExt ? [fileExt lowercaseString] : @"";
        
        reportModel.from = HYBG;
        
        reportModel.isDownload = [pdfUrlMArr containsObject:reportModel.name];
        
        [reportMArr addObject:reportModel];
    }
    return reportMArr;
}
- (NSMutableArray *)handlePdfListDict:(NSDictionary *)dict{
    
    NSMutableArray *pdfUrlMArr = [[DBHelper shared] toGetPdfFromLocal:_tableName fDataBase:_db];

    NSMutableArray *reportMArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    if ([dict[@"message"] isEqualToString:@"success"] && dict[@"data"] && [dict[@"data"] isKindOfClass:[NSArray class]]) {
        
        NSArray *dataArr = [dict objectForKey:@"data"];
        for (NSDictionary *dataDict in dataArr) {
            
            ReportModel *reportModel = [[ReportModel alloc] init];
            reportModel.name = [dataDict objectForKey:@"name"];
            reportModel.reportId = [dataDict objectForKey:@"id"];
            reportModel.datetime = [dataDict objectForKey:@"datetime"];
            reportModel.pdfUrl = [dataDict objectForKey:@"url"];
            reportModel.collectFlag = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"collect_flag"]];
            reportModel.recommandFlag = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"open_flag"]];
            reportModel.size = [dataDict objectForKey:@"size"];
            reportModel.report_source = [dataDict objectForKey:@"source"];
            reportModel.remark = @"";
            reportModel.pdfType = [dataDict objectForKey:@"filetype"];
            NSString *fileExt = [dataDict objectForKey:@"fileext"];
            reportModel.fileExt = fileExt ? [fileExt lowercaseString] : @"";

            reportModel.from = HYBG;

            reportModel.isDownload = [pdfUrlMArr containsObject:reportModel.name];
            
            [reportMArr addObject:reportModel];
        }
    }
    return reportMArr;
}

#pragma mark - 取消收藏pdf
- (void)requestCancleCollectPdf:(ReportModel *)pdfModel{
    
    NSDictionary *param = @{@"ptype":@"qmp_ios",@"version":VERSION,@"unionid":[[NSUserDefaults standardUserDefaults] objectForKey:@"unionid"],@"fileid":pdfModel.reportId,@"pdftype":pdfModel.pdfType ? pdfModel.pdfType : @"",@"collect":@"0"};
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"l/collectpdf" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
       
        if (resultData && [resultData[@"message"] isEqualToString:@"success"]) {
            if (self.isSearch) {
                [self.searchArr removeObject:pdfModel];
                if (!self.searchArr || self.searchArr.count == 0) {
                    self.info = REQUEST_SEARCH_NULL;
                }
                
            }
            
            [self.tableData removeObject:pdfModel];
            if (!self.tableData || self.tableData.count == 0) {
                self.info = @"暂无收藏";
            }
            
            
            NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:pdfModel.name];
            [PublicTool deleteFileForPath:filePath];
            
            [self.tableView reloadData];
            [ShowInfo showInfoOnView:self.view withInfo:@"取消收藏成功"];
        }else{
            [ShowInfo showInfoOnView:self.view withInfo:@"取消收藏失败"];
        }
    }];
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
    [self.tableView registerClass:[MeDocumentCell class] forCellReuseIdentifier:@"MeDocumentCellID"];
    [self.view addSubview:self.tableView];
    
    CGFloat height = 44.f;

    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, height)];
    _tableHeaderView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.tableHeaderView = _tableHeaderView;
    
    _mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(7, 0, SCREENW-14, height)];
    [_mySearchBar setBackgroundImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_mySearchBar.size]];
    //    _mySearchBar.backgroundImage = [UIImage imageNamed:@"nav-lightgray"];
    //设置背景色
    [_mySearchBar setBackgroundColor:TABLEVIEW_COLOR];
    [_mySearchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_borderTab"] forState:UIControlStateNormal];
    [_mySearchBar setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
    UITextField *tf = [_mySearchBar valueForKey:@"_searchField"];
    tf.font = [UIFont systemFontOfSize:14];
    NSString *str = @"搜索报告、文档";
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


}

- (void)pressCancleSearchBtn:(UIButton *)sender{
    [self cancleSearch];
}

- (void)disAppear{  //左右切换
    
    if (self.mySearchBar.text.length == 0 && self.isSearch) {
        [self cancleSearch];
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



- (void)cancleSearch{
    
    
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
        self.mjFooter.state = MJRefreshStateNoMoreData;
        
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
#pragma mark - 懒加载

- (NSMutableDictionary *)downloadVMDict{
    
    if (!_downloadVMDict) {
        _downloadVMDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _downloadVMDict;
}
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

- (ManagerHud *)hudTool{
    
    if(!_hudTool){
        _hudTool = [[ManagerHud alloc] init];
    }
    return _hudTool;
}

- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}

- (UIView *)noCollectionView{
    
    if (!_noCollectionView) {
        _noCollectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 36)];
        self.infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 20, SCREENW - 32, 20)];
        self.infoLbl.backgroundColor = [UIColor clearColor];
        [_noCollectionView addSubview:self.infoLbl];
    }
    return _noCollectionView;
}

- (OpenDocument *)openPDFTool{
    
    if (!_openPDFTool) {
        _openPDFTool = [[OpenDocument alloc] init];
        _openPDFTool.viewController = self;
    }
    
    return _openPDFTool;
}



@end
