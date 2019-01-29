//
//  BPDownController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BPDownController.h"
#import "ReportListNewCell.h"
#import "FileWebViewController.h"
#import "DownloadView.h"

#import "FileItem.h"
#import "OpenDocument.h"

 


@interface BPDownController ()<UITableViewDelegate,UITableViewDataSource,DownloadViewDelegate,OpenDocumentDelegate>
@property (strong, nonatomic) UIView *bottomView;
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

@implementation BPDownController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self toSetLocalData];
    
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(receiveDownloadSuccess:) name:NOTIFI_PDFDOWNSUCCESS object:nil];
    [notiCenter addObserver:self selector:@selector(receiveDownloadFail:) name:NOTIFI_PDFDOWNFAIL object:nil];

    [notiCenter addObserver:self selector:@selector(refreshPdfList:) name:@"collectPdfSuccess" object:nil];

    [self showHUD];
    [self.view addSubview:self.bottomView];

    [self readLocalDownloadedBPList:self.currentPage ofNum:self.numPerPage];
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
    FileItem *file = [[FileItem alloc] init];
    file.fileName = pdfModel.name;
    file.fileUrl = pdfModel.pdfUrl;
    file.fileId = pdfModel.reportId;
    
    FileWebViewController *webVC = [[FileWebViewController alloc] init];
    webVC.fileItem = file;
    webVC.hidesBottomBarWhenPushed = YES;
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
    return;
    ReportModel *report = tf.object;
    if(report.collectFlag.integerValue == 0){
        
        [self.tableData enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ReportModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.reportId isEqualToString:report.reportId]) {
                [self.tableData removeObject:obj];
            }
            
        }];
        
        [self.tableView reloadData];
        
    }else   if(report.collectFlag.integerValue == 1){
        
        BOOL haveReport = NO;
        for (ReportModel *reportM in self.tableData) {
            if ([reportM.reportId isEqualToString:report.reportId]) {
                haveReport = YES;
            }
        }
        if (!haveReport) {
            [self.tableData insertObject:report atIndex:0];
        }
        [self.tableView reloadData];
        
    }
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
            [self.tableView reloadData];
            newPdfModel = pdfModel;
            
            break;
        }
    }
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
    
    return (self.tableData.count == 0 ? 1 : self.tableData.count);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableData.count > 0 ) {
        ReportModel *report = self.tableData[indexPath.row];
        return [tableView fd_heightForCellWithIdentifier:@"ReportListNewCellID" configuration:^(ReportListNewCell *cell) {
            cell.report = report;
        }];
        
    }
    else{
        return SCREENH;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableData.count == 0) {
        
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
    }
    else{
        
        ReportModel *reportModel = self.tableData[indexPath.row];
        
        ReportListNewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportListNewCellID" forIndexPath:indexPath];
        [cell refreshUI:reportModel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCellTarget:)]];
        return cell;
    }
}
#pragma mark 删除本地单条BP
- (void)longPressCellTarget:(UILongPressGestureRecognizer *)lpg{
    UIView * cellContentView = lpg.view;
    ReportListNewCell * pressCell = (ReportListNewCell *)cellContentView.superview;
    if (pressCell && [pressCell isKindOfClass:[ReportListNewCell class]]) {
        NSIndexPath * selectIndexPath = [self.tableView indexPathForCell:pressCell];
        ReportModel * model = [self.tableData objectAtIndex:selectIndexPath.row];
        
        [PublicTool alertActionWithTitle:model.name message:nil leftTitle:@"取消" rightTitle:@"删除该文档" leftAction:^{

        } rightAction:^{
            [self deleteLocalData:model deleteIndex:selectIndexPath];
        }];
    }
}
- (void)deleteLocalData:(ReportModel *)rptModel deleteIndex:(NSIndexPath *)indexPath{
    //删除记录
   BOOL isSuccess =  [[DBHelper shared] deleteLocalTableName:_tableName fDataBase:_db conditionStr:[NSString stringWithFormat:@"id = '%@' OR name = '%@'", rptModel.reportId, rptModel.name]];
    if (isSuccess) {
        //删除本地文件
        NSString * BPFilePathStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:rptModel.name];
        [PublicTool deleteFileForPath:BPFilePathStr];
        //删除数据、视图
        [self.tableData removeObject:rptModel];
        if (self.tableData.count == 0) {
            [self.tableView reloadData];
            self.bottomView.hidden = YES;
        }else{
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        [PublicTool showMsg:@"本地删除成功"];
    }else{
        [PublicTool showMsg:@"本地删除失败"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableData.count == 0) return;
    if ( self.tableData.count >0 ){
        
        //跳转,请求分组列表
        ReportModel *reportModel = self.tableData[indexPath.row];
        reportModel.collectFlag = @"禁止收藏";
        if (reportModel.pdfUrl.length) {
            
//            reportModel.collectFlag = @"1";
            OpenDocument *openPDFTool = [[OpenDocument alloc] init];
            openPDFTool.viewController = self;
            openPDFTool.delegate = self;
            
            if (reportModel.name && [openPDFTool downDocumentToBox:reportModel]) {
                
                if ([reportModel.pdfUrl hasSuffix:@".pdf"]) {
                    //本地下载了该文档
                    [openPDFTool openDocumentofReportModel:reportModel];
                    
                }else{
                    FileItem *file = [[FileItem alloc] init];
                    file.fileName = reportModel.name;
                    file.fileUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:reportModel.name];
                    file.fileId = reportModel.reportId;
                    
                    FileWebViewController *webVC = [[FileWebViewController alloc] init];
                    webVC.fileItem = file;
                    webVC.reportModel = reportModel;
                    //            webVC.hidesBottomBarWhenPushed = YES;
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
            [self.navigationController pushViewController:webVC animated:YES];
            
        }
    }
    
}


#pragma mark - 请求获取本地下载BP列表
- (void)readLocalDownloadedBPList:(NSInteger)currentPage ofNum:(NSInteger)num{
    //
    NSMutableArray *reportMArr = [[DBHelper shared] toGetPdfArrFromLocal:_tableName fDataBase:_db conditionStr:[NSString stringWithFormat:@"come = '%@'",BP]];
    if ([self.tableData count]) {
        [self.tableData removeAllObjects];
    }
    self.tableData = reportMArr;
    
    [self initBottomView];
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
    [self hideHUD];
}

- (void)dealData:(NSMutableArray*)array{
    
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


#pragma mark - 取消收藏pdf
- (void)requestCancleCollectPdf:(ReportModel *)pdfModel{

    NSDictionary *param = @{@"ptype":@"qmp_ios",@"version":VERSION,@"unionid":[[NSUserDefaults standardUserDefaults] objectForKey:@"unionid"],@"fileid":pdfModel.reportId,@"pdftype":pdfModel.pdfType ? pdfModel.pdfType : @"",@"collect":@"0"};
    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"l/collectpdf" HTTPBody:param  completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableData removeObject:pdfModel];
                if (!self.tableData || self.tableData.count == 0) {
                    self.info = @"暂无收藏";
                }
                NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:pdfModel.name];
                [PublicTool deleteFileForPath:filePath];
                
                [self.tableView reloadData];
                [ShowInfo showInfoOnView:self.view withInfo:@"取消收藏成功"];
            });
        }
    }];

}
- (void)pullDown{
    self.currentPage = 1;
    [self readLocalDownloadedBPList:self.currentPage ofNum:self.numPerPage];
}
#pragma mark - public

- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = self.mjHeader;
//    self.tableView.mj_footer = self.mjFooter;
    [self.tableView registerClass:[ReportListNewCell class] forCellReuseIdentifier:@"ReportListNewCellID"];
    [self.view addSubview:self.tableView];
    
}
- (UIView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH - kScreenTopHeight - kScreenBottomHeight, SCREENW, kScreenBottomHeight)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        _bottomView.layer.shadowColor = H9COLOR.CGColor;//shadowColor阴影颜色
        _bottomView.layer.shadowOpacity = 0.1;//阴影透明度，默认0
        _bottomView.layer.shadowRadius = 3;//阴影半径，默认3
        _bottomView.layer.shadowOffset = CGSizeMake(0,0);
        
        UIButton *deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW, kScreenBottomHeight)];
        [deleteBtn setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
        [deleteBtn setTitle:@"清空BP" forState:UIControlStateNormal];
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [deleteBtn setImage:[BundleTool imageNamed:@"del_downIcon"] forState:UIControlStateNormal];
        [deleteBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        [_bottomView addSubview:deleteBtn];
        [deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomView;
}

- (void)initBottomView{
    if (self.tableData.count == 0) {
        self.bottomView.hidden = YES;
        return ;
    }else{
        self.bottomView.hidden = NO;
        if (![self.bottomView isDescendantOfView:self.view]) {
            [self.view addSubview:self.bottomView];
        }
        self.tableView.height = SCREENH - kScreenBottomHeight - kScreenTopHeight;
    }
}

#pragma mark --清空报告--
- (void)deleteBtnClick{
    
    [PublicTool alertActionWithTitle:@"提示" message:@"清空后需要重新下载,确定清空" leftTitle:@"取消" rightTitle:@"清空" leftAction:^{
        
    } rightAction:^{
        [PublicTool showHudWithView:KEYWindow];
        NSString *delCondition = [NSString stringWithFormat:@"come = '%@'",BP];
        [[DBHelper shared] deleteLocal:_tableName fDataBase:self.db conditionStr:delCondition];
        
        for (ReportModel *report in self.tableData) {
            
            NSString *path = [DocumentDirectory stringByAppendingPathComponent:report.name];
            NSFileManager *fileM = [NSFileManager defaultManager];
            
            if ([fileM fileExistsAtPath:path]) {
                
                [fileM removeItemAtPath:path error:nil];
            }
        }
        
        [self.tableData removeAllObjects];
        [PublicTool showMsg:@"删除成功"];
        [self.bottomView removeFromSuperview];
        self.tableView.height = SCREENH - kScreenTopHeight;
        [self.tableView reloadData];
        [PublicTool dismissHud:KEYWindow];
    }];
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

- (void)receiveQuitLoginNotification:(NSNotification *)notification{
    
    NSString *receiveStr = (NSString *)[notification object];
    if ([receiveStr isEqualToString:@"0"]) {
        self.currentPage = 1;
        
        self.tableData = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
    }
}

- (void)receiveLoginNotification:(NSNotification *)notification{
    
    BOOL isLogin = [ToLogin isLogin];
    
    if (isLogin) {
        self.currentPage = 1;
        [self readLocalDownloadedBPList:self.currentPage ofNum:self.numPerPage];
    }
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

- (NSMutableArray *)tableData{
    
    if (!_tableData) {
        _tableData = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _tableData;
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

