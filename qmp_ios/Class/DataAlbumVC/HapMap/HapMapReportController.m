//
//  HapMapReportController.m
//  qmp_ios
//
//  Created by QMP on 2017/11/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "HapMapReportController.h"
#import "DownloadView.h"
#import "FileWebViewController.h"
#import "FileItem.h"
#import "ReportListNewCell.h"
#import "ReportModel.h"
#import "OpenDocument.h"


@interface HapMapReportController ()<UITableViewDelegate,UITableViewDataSource,OpenDocumentDelegate,DownloadViewDelegate>
{
    NSMutableArray *_reportArr;
    FMDatabase *_db;
    NSString *_tableName;
}
@property(nonatomic,strong)DBHelper *dbHelper;
@property(nonatomic,strong)ReportListNewCell *reportCell;
@property(nonatomic,strong)NSDateFormatter *dateFormat;
@property(nonatomic,strong)NSMutableDictionary *downloadVMDict;


@end

@implementation HapMapReportController

- (void)viewDidLoad {
    [super viewDidLoad];
    _reportArr = [NSMutableArray array];
    
    [self initTableView];
    
    [self showHUD];
    
    [self toSetLocalData];
    
    self.currentPage = 1;
    self.numPerPage = 30;
    
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

- (void)didReceiveMemoryWarning {
   
    [super didReceiveMemoryWarning];
    
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
    
    [self handleArr:_reportArr withNewPdfModel:newPdfModel];
    
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_reportArr.count == 0) {
        
        return 1;
    }
    else{
        return _reportArr.count;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_reportArr.count == 0) {
        
        return SCREENH - kScreenTopHeight;
    }
    else{
        
        ReportModel *report = _reportArr[indexPath.row];
        return [tableView fd_heightForCellWithIdentifier:@"ReportListNewCell" configuration:^(ReportListNewCell *cell) {
            cell.report = report;
        }];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_reportArr.count == 0) {
        
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
        
    }
    else{
        ReportModel *reportModel = _reportArr[indexPath.row];
        ReportListNewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportListNewCell" forIndexPath:indexPath];
        cell.keyWord = [[self.tagStr componentsSeparatedByString:@"|"] lastObject];
        cell.report = reportModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_reportArr.count == 0){
        return;
    }
    if (![PublicTool userisCliamed]) {
        if ([WechatUserInfo shared].claim_type.integerValue != 1) {
            [QMPEvent event:@"report_noclaim_alert"];
        }
        return;
    }
    
    ReportModel *reportModel = _reportArr[indexPath.row];
    if ([reportModel.fileExt isEqualToString:@""] || [reportModel.fileExt isEqualToString:@"pdf"]) {
        
        OpenDocument *openPDFTool = [[OpenDocument alloc] init];
        openPDFTool.viewController = self;
        openPDFTool.delegate = self;
        
        if (reportModel.name && [openPDFTool downDocumentToBox:reportModel]) {
            
            //本地下载了该文档
            [openPDFTool openDocumentofReportModel:reportModel];

        }
        else{
            
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
            }else{
                
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
#pragma mark - 请求获取pdf列表
- (BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    
    NSString *tag = [[self.tagStr componentsSeparatedByString:@"|"] lastObject];
    NSDictionary *dic = @{@"keywords":tag, @"num":@(self.numPerPage),@"page":@(self.currentPage)};
    if ([self.tableView.mj_header isRefreshing]) {
        dic = @{@"debug":@"1",@"keywords":tag, @"num":@(self.numPerPage),@"page":@(self.currentPage)};
    }
    
    [AppNetRequest getReportByTagWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && resultData[@"list"]) {
            if (self.currentPage == 1) {
                [_reportArr removeAllObjects];
            }
            NSMutableArray *arr = [self handlePdfListDict:resultData];
            [_reportArr addObjectsFromArray:arr];
            [self refreshFooter:arr];
            [self.tableView reloadData];
        }
        
    }];
    return YES;
}

- (NSMutableArray *)handlePdfListDict:(NSDictionary *)dict{
    
    NSMutableArray *pdfUrlMArr = [[DBHelper shared] toGetPdfFromLocal:PDFTABLENAME fDataBase:_db];
    
    NSMutableArray *reportMArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    if ( [dict[@"list"] isKindOfClass:[NSArray class]] && [dict objectForKey:@"list"] ) {
        
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
            reportModel.read_count = [dataDict objectForKey:@"read_count_program"];

            NSString *fileExtension;
            NSArray *arr = [[reportModel.pdfUrl lastPathComponent] componentsSeparatedByString:@"."];
            if (arr.count) {
                fileExtension = [arr lastObject];
            }
            reportModel.pdfType = [dataDict objectForKey:@"filetype"];
            reportModel.fileExt = fileExtension ? [fileExtension lowercaseString] : @"";
            
            reportModel.from = HYBG;
            reportModel.isDownload = [pdfUrlMArr containsObject:reportModel.name];
            [reportMArr addObject:reportModel];
            //            QMPLog(@"%@=====",reportModel.uploadTime);
            
        }
    }
    return reportMArr;
}

#pragma mark - pubic


- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - 44 - kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = self.mjHeader;
    
    [self.tableView registerClass:[ReportListNewCell class] forCellReuseIdentifier:@"ReportListNewCell"];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
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
