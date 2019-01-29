//
//  ReportResultController.m
//  qmp_ios
//
//  Created by QMP on 2018/3/21.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ReportResultController.h"
#import "ReportModel.h"
#import "ReportListNewCell.h"
#import "OpenDocument.h"
#import "DownloadView.h"
#import "FileWebViewController.h"
#import "FileItem.h"
#import "ReportModel.h"
#import "DownloadTool.h"

@interface ReportResultController ()<UITableViewDataSource,UITableViewDelegate,OpenDocumentDelegate,DownloadViewDelegate,CustomAlertViewDelegate, changeNoPdfCollectionStatusDelegate>
{
    
    NSString *_totalCount;
}

@property (strong, nonatomic) NSMutableDictionary *downloadVMDict;
@property (strong, nonatomic) NSIndexPath * selectedIndexPath;
@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) NSString *tableName;

@end

@implementation ReportResultController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _totalCount = @"0";
    [self initTableView];
    
    [self toSetLocalData];
    self.currentPage = 1;
    self.numPerPage = 20;
    
    [self requestData];
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(receiveDownloadSuccess:) name:NOTIFI_PDFDOWNSUCCESS object:nil];
    [notiCenter addObserver:self selector:@selector(receiveDownloadFail:) name:NOTIFI_PDFDOWNFAIL object:nil];

}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([_db open]) {
        [_db close];
    }
}

- (void)initTableView{
    
    [self.tableView registerClass:[ReportListNewCell class] forCellReuseIdentifier:@"ReportListNewCellID"];
}


- (void)toSetLocalData{
    _db = [[DBHelper shared] toGetDB];
    _tableName = PDFTABLENAME;
}


-(BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    
    if (self.dataArr.count == 0) {
        [self showHUD];
    }
    
    NSDictionary *dic = @{@"keywords":self.keyword, @"num":@(self.numPerPage),@"page":@(self.currentPage)};
    
    [AppNetRequest getReportByTagWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        NSMutableArray *arr = [self handlePdfListDict:resultData];

        if (resultData && resultData[@"list"]) {
            _totalCount = resultData[@"count"];
            if (self.currentPage == 1) {
                [self.dataArr removeAllObjects];
            }
            [self.dataArr addObjectsFromArray:arr];
        }else{
            if (self.currentPage == 1) {
                _totalCount = @"0";
            }
        }
        
        [self refreshFooter:arr];
        
        [self.tableView reloadData];
    }];
   
    return YES;
}


- (NSMutableArray *)handlePdfListDict:(NSDictionary *)dict{
    
    NSMutableArray *pdfUrlMArr = [[DBHelper shared] toGetPdfFromLocal:_tableName fDataBase:_db];
    
    NSMutableArray *reportMArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    if ([dict[@"list"] isKindOfClass:[NSArray class]] && [dict objectForKey:@"list"] ) {
        
        NSArray *dataArr = [dict objectForKey:@"list"];
        for (NSDictionary *dataDict in dataArr) {
            
            ReportModel *reportModel = [[ReportModel alloc] init];
            [reportModel setValuesForKeysWithDictionary:dataDict];
            reportModel.name = [dataDict objectForKey:@"name"];
            reportModel.reportId = [dataDict objectForKey:@"id"];
            reportModel.datetime = [dataDict objectForKey:@"update_time"];
            reportModel.pdfUrl = [dataDict objectForKey:@"url"];
            reportModel.size = [dataDict objectForKey:@"size"];
            reportModel.collectFlag = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"collect_flag"]];
            reportModel.remark = @"";
            
            NSString *fileExtension;
            NSArray *arr = [[reportModel.pdfUrl lastPathComponent] componentsSeparatedByString:@"."];
            if (arr.count) {
                fileExtension = [arr lastObject];
            }
            reportModel.pdfType = @"";
            reportModel.fileExt = fileExtension ? [fileExtension lowercaseString] : @"";
            
            reportModel.from = HYBG;
            reportModel.isDownload = [pdfUrlMArr containsObject:reportModel.name];
            [reportMArr addObject:reportModel];
            //            QMPLog(@"%@=====",reportModel.uploadTime);
            
        }
    }
    return reportMArr;
}



- (void)feedbackSuccessHandle{
    self.feedbackBtn.selected = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - OpenDocumentDelegate
- (void)downloadPdfUseWWAN:(ReportModel *)reportModel{
    
    [self requestDownloadDocument:reportModel];
}

#pragma mark - DownloadViewDelegate

- (void)receiveDownloadSuccess:(NSNotification *)noti{
    
    NSDictionary *dict = (NSDictionary *)noti.object;
    
    NSString *pdfType = dict[@"from"];
    if ([pdfType isEqualToString:HYBG]) {
        
        ReportModel *model = [[ReportModel alloc] init];
        model.reportId = dict[@"id"];
        model.name = dict[@"title"];
        model.pdfUrl  = dict[@"url"];
        model.collectFlag = dict[@"collect"];
        model.report_date = dict[@"report_date"];
        model.report_source = dict[@"report_source"];
        
        [self downloadNewPdfSuccess:model];
    }
}

- (void)receiveDownloadFail:(NSNotification *)noti{
    
    ReportModel *pdfModel = (ReportModel *)noti.object;
    
    if ([pdfModel.from isEqualToString:HYBG]) {
        
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
    
    [self handleArr:self.dataArr withNewPdfModel:newPdfModel];
    
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
    [QMPEvent event:@"trz_down_hiddenBtnClick"];
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

#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 55.0f;
    
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
    
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 55)];
    sectionView.backgroundColor = TABLEVIEW_COLOR;
    
    UIView *_headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, SCREENW, 45)];//表头
    _headerView.backgroundColor = [UIColor whiteColor];
    [sectionView addSubview:_headerView];
    
    UILabel *headerLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 200, 45)];
    headerLab.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:headerLab];
    headerLab.font = [UIFont systemFontOfSize:14];
    headerLab.textColor = H9COLOR;
    NSString *headerStr = [NSString stringWithFormat:@"报告(%@)",_totalCount.integerValue>200?@"200+":_totalCount];
    headerLab.text = headerStr;
    [_headerView addSubview:headerLab];
    if (self.dataArr.count > 0) {
        UIButton *baiduBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        baiduBtn.frame = CGRectMake(SCREENW-135,0, 72, 45);
        baiduBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        baiduBtn.tag = 100;
        [baiduBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [baiduBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [baiduBtn setTitle:@"全网搜索" forState:UIControlStateNormal];
        [baiduBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [baiduBtn addTarget:self action:@selector(baiduBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:baiduBtn];
    }
    
    self.feedbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.feedbackBtn.frame = CGRectMake(SCREENW-67,0, 50, 45);
    self.feedbackBtn.tag = 100;
    [self.feedbackBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [self.feedbackBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self.feedbackBtn setTitle:@"反馈" forState:UIControlStateNormal];
    [self.feedbackBtn setTitle:@"已反馈" forState:UIControlStateSelected];
    [self.feedbackBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.feedbackBtn addTarget:self action:@selector(feedbackAlertView1) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:self.feedbackBtn];
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 54.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [sectionView addSubview:line];
    
    return sectionView;
}
#pragma mark - EVENT

- (void)feedbackAlertView1{
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"报告不全",@"报告质量差", nil];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:@{@"module":@"搜索列表详情",@"title":@"搜索"}];
    [infoDic setValue:@"人工信息完善" forKey:@"type"];
    [infoDic setValue:@"急" forKey:@"c4"];
    [infoDic setValue:self.keyword forKey:@"c1"];
    [infoDic setValue:self.keyword forKey:@"company"];
    
    CustomAlertView *alertV = [[CustomAlertView alloc]initWithAlertViewHeight:arr frame:CGRectZero WithAlertViewHeight:10 infoDic:infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
    alertV.delegate = self;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.dataArr.count == 0) {
        return 1;
    } else{
        return self.dataArr.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        
        return SCREENH - kScreenTopHeight - 90;  //未搜索到
    }
    
    ReportModel *report = self.dataArr[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:@"ReportListNewCellID" configuration:^(ReportListNewCell *cell) {
        cell.report = report;
    }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        
        NSString *title = REQUEST_DATA_NULL;
        HomeInfoTableViewCell *cell = [self nodataCellWithInfo:title tableView:tableView];
        [cell.createBtn setTitle:@"全网搜索" forState:UIControlStateNormal];
        cell.createBtn.hidden = NO;
        [cell.createBtn addTarget:self action:@selector(baiduBtnClick) forControlEvents:UIControlEventTouchUpInside];
        return cell;
       
    }else{
        ReportModel *reportModel = self.dataArr[indexPath.row];
        ReportListNewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportListNewCellID" forIndexPath:indexPath];
        cell.keyWord = self.keyword;
        cell.report = reportModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataArr.count == 0) {
        return;
    }
    
    if (![PublicTool userisCliamed]) {
        if ([WechatUserInfo shared].claim_type.integerValue != 1) {
            [QMPEvent event:@"report_noclaim_alert"];
        }
        return;
    }
    
    [QMPEvent event:@"search_report_cellclick"];
    
    ReportModel *reportModel = self.dataArr[indexPath.row];
//    if ([reportModel.pdfUrl hasSuffix:@".pdf"] || [reportModel.fileExt isEqualToString:@"pdf"]) {
    if ([reportModel.pdfUrl hasSuffix:@".pdf"]) {
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
        _selectedIndexPath = indexPath;
        FileWebViewController *webVC = [[FileWebViewController alloc] init];
        webVC.fileItem = file;
        webVC.deleage = self;
        webVC.collect_flag_status = reportModel.collectFlag;
        webVC.reportModel= reportModel;
        webVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}
- (void)changeNoPdfCollectionStatusByClick:(ReportModel *)changeModel{
    [self.tableView reloadRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
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

#pragma mark --懒加载-

- (NSMutableDictionary *)downloadVMDict{
    
    if (!_downloadVMDict) {
        _downloadVMDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _downloadVMDict;
}



-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

@end
