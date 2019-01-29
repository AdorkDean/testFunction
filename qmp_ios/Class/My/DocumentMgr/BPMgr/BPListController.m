//
//  BPListController.m
//  qmp_ios
//
//  Created by QMP on 2017/11/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "BPListController.h"
#import "MainNavViewController.h"
#import "ReportListNewCell.h"
#import "FileWebViewController.h"
#import "DownloadView.h"

#import "FileItem.h"
#import "OpenDocument.h"
 
#import "BPMgrController.h"
#import "BPMeReceivedCell.h"

#import "ManagerAlertView.h"
#import "CreateBPProjectViewController.h"
#import "SearchCompanyModel.h"
#import "BPDeliverStatusVC.h"

@interface BPListController () <UITableViewDelegate, UITableViewDataSource,
DownloadViewDelegate, OpenDocumentDelegate, UISearchBarDelegate,
UIScrollViewDelegate, BPMeReceivedCellDelegate,
ManagerAlertDelegate>

{
    NSInteger _currentPage;
    NSInteger _num;
    NSInteger _searchCurrentPage;
    NSInteger _searchNum;
    NSDateFormatter *_dateFormat;
    NSInteger _currentRow;
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

@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) NSString *tableName;


@property (strong, nonatomic) ManagerHud *hudTool;
@property (strong, nonatomic) GetSizeWithText *sizeTool;
@property (strong, nonatomic) OpenDocument *openPDFTool;
@property (nonatomic, strong) NSString *current_phone;

@property (nonatomic, weak) ManagerAlertView *alertView;

@property (nonatomic, strong) UIView *bottomBgVw;
@property (nonatomic, strong) UIButton * bpStatusBtn;
@end

@implementation BPListController

-(void)setIsToMe:(BOOL)isToMe{
    _isToMe = isToMe;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self toSetLocalData];
//    [self keyboardManager];
    
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(receiveDownloadSuccess:) name:NOTIFI_PDFDOWNSUCCESS object:nil];
    [notiCenter addObserver:self selector:@selector(receiveDownloadFail:) name:NOTIFI_PDFDOWNFAIL object:nil];

    [notiCenter addObserver:self selector:@selector(refreshPdfList:) name:@"collectPdfSuccess" object:nil];

    
    self.currentPage = 1;
    self.numPerPage = 20;
    _searchCurrentPage = 1;
    _searchNum = self.numPerPage;
    
    [self showHUD];
    [self requestBPLsitData:self.currentPage ofNum:self.numPerPage];
    _dateFormat = [[NSDateFormatter alloc]init];
    [_dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
    pdfModel.collectFlag = @"禁止收藏";
    FileItem *file = [[FileItem alloc] init];
    file.fileName = pdfModel.name;
    file.fileUrl = pdfModel.pdfUrl;
    file.fileId = pdfModel.reportId;
    
    FileWebViewController *webVC = [[FileWebViewController alloc] init];
    webVC.fileItem = file;
    webVC.reportModel = pdfModel;
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
        if (self.isSearch) {
            [self.searchArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ReportModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.reportId isEqualToString:report.reportId]) {
                    [self.searchArr removeObject:obj];
                }
                
            }];
            
        }
        
        [self.tableData enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ReportModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.reportId isEqualToString:report.reportId]) {
                [self.tableData removeObject:obj];
            }
            
        }];
        
        [self.tableView reloadData];
        
    }else   if(report.collectFlag.integerValue == 1){
        
        if (self.isSearch) {
            BOOL haveReport = NO;
            for (ReportModel *reportM in self.searchArr) {
                if ([reportM.reportId isEqualToString:report.reportId]) {
                    haveReport = YES;
                }
            }
            if (!haveReport) {
                [self.searchArr insertObject:report atIndex:0];
            }
            
        }
        
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
//        if ([newPdfModel.pdfUrl isEqualToString:pdfModel.pdfUrl]) {
        if ([newPdfModel.reportId isEqualToString:pdfModel.reportId]) {
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
    
    if (self.isSearch) {
        if ([self.mySearchBar.text isEqualToString:@""]) {
            return 0;
        }
        return (self.searchArr.count == 0 ? 1 : self.searchArr.count+1);
        
    }else{
        
        return (self.tableData.count == 0 ? 1 : self.tableData.count+1);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isSearch) {
        
        if ([self.mySearchBar.text isEqualToString:@""]) {
            return 0;
        }
        if (self.searchArr.count > 0 ) {
            if (indexPath.row == self.searchArr.count) {
                return 80;
            }
            
            
            ReportModel *report = self.searchArr[indexPath.row];
            if (self.isToMe) {
//                return [tableView fd_heightForCellWithIdentifier:@"BPToMeCellID" configuration:^(BPToMeCell *cell) {
//                    [cell refreshUI:report];
//                }];
                if (report.product_info.product.length > 0) { // 关联了项目
                    return kBPMeReceivedCellHeight + 20;
                }
                return kBPMeReceivedCellHeight;
            }else{
                return [tableView fd_heightForCellWithIdentifier:@"ReportListNewCellID" configuration:^(ReportListNewCell *cell) {
                    cell.report = report;
                }];
            }
        
        }else{
            return SCREENH - kScreenTopHeight-45;
        }
    }else{
        
        if (self.tableData.count > 0 ) {
            if (indexPath.row == self.tableData.count) {
                return 80;
            }
            ReportModel *report = self.tableData[indexPath.row];
            if (self.isToMe) {
//                return [tableView fd_heightForCellWithIdentifier:@"BPToMeCellID" configuration:^(BPToMeCell *cell) {
//                    [cell refreshUI:report];
//                }];
                
                if (report.product_info.product.length > 0) { // 关联了项目
                    return kBPMeReceivedCellHeight + 20;
                }
                
                return kBPMeReceivedCellHeight;
            }else{
                return [tableView fd_heightForCellWithIdentifier:@"ReportListNewCellID" configuration:^(ReportListNewCell *cell) {
                    cell.report = report;
                }];
            }
            
        }else{
            return SCREENH - kScreenTopHeight;
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((self.tableData.count == 0 && !self.isSearch ) || (self.searchArr.count == 0 && self.isSearch)) {
        
        NSString *title = _isSearch ? REQUEST_SEARCH_NULL : (self.isToMe ? REQUEST_DATA_NULL:@"您还没有自己的BP文档\n请点击右上角进行上传");
        if (!self.isSearch && self.isToMe && [WechatUserInfo shared].claim_type.integerValue != 2) {
            title = @"成为官方人物，认证投资人,可以收到更多优质BP";
        }
        return [self nodataCellWithInfo:title tableView:tableView];

    } else{
        if (indexPath.row == (self.isSearch ? self.searchArr.count : self.tableData.count)) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellID"];
            }
            cell.backgroundColor = TABLEVIEW_COLOR;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        ReportModel *reportModel = self.isSearch ? self.searchArr[indexPath.row] : self.tableData[indexPath.row];
        
        if (self.isToMe) {
//            BPToMeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BPToMeCellID" forIndexPath:indexPath];
//            cell.keyWord = _isSearch ? self.mySearchBar.text : nil;
//            [cell refreshUI:reportModel];
//            //未读icon
//            [self refreshNoReadOfCell:cell reportM:reportModel];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
            BPMeReceivedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BPMeReceivedCellID"];
            cell.model = reportModel;
            cell.favorButton.tag = 900 + indexPath.row;
            [cell.favorButton addTarget:self action:@selector(favorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.lineView.hidden = (indexPath.row+1 == (self.isSearch ? self.searchArr.count : self.tableData.count));
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            
//            [cell.contentView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDeleteBP:)]];
            objc_setAssociatedObject(cell.contentView, [@"cellModel" UTF8String], reportModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            return cell;
        }
        
        ReportListNewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportListNewCellID" forIndexPath:indexPath];
        cell.keyWord = _isSearch ? self.mySearchBar.text : nil;
        cell.report = reportModel;
        if (!reportModel.isDownload) {
            cell.downIcon.hidden = YES;
            cell.sourceLabel.hidden = YES;
        }else{
            cell.downIcon.hidden = NO;
            cell.sourceLabel.hidden = NO;
            cell.sourceLabel.text = @"已下载";
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDeleteBP:)]];
        objc_setAssociatedObject(cell.contentView, [@"cellModel" UTF8String], reportModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return cell;
    }
}
- (void)longPressDeleteBP:(UILongPressGestureRecognizer *)tap{
    UIView * tapVw = tap.view;
    //    if (tap.state == UIGestureRecognizerStateEnded) {}
    ReportModel * rptModel = (ReportModel *)objc_getAssociatedObject(tapVw, [@"cellModel" UTF8String]);
    NSInteger selectRowInt = [self.tableData indexOfObject:rptModel];
    
    NSString * topTitle = rptModel.name;

//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
//        popPresenter.sourceView = self.view;
//        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
//        [self presentViewController:alertVC animated:YES completion:nil];
//    } else {
//        [self presentViewController:alertVC animated:YES completion:^{
//        }];
//    }
    
    [PublicTool alertActionWithTitle:topTitle message:nil leftTitle:@"删除该文档" rightTitle:@"取消" leftAction:^{
        [self deleteBpbyModel:rptModel deleteIndex:selectRowInt];
    } rightAction:^{
        
    }];
}
#pragma mark 长按删除BP
- (void)deleteBpbyModel:(ReportModel *)pdfModel deleteIndex:(NSInteger)index{
    
    NSDictionary *param = @{@"id":pdfModel.reportId};
    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/workBpDelete" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            if ([resultData[@"msg"] isEqualToString:@"success"]) {
                [ShowInfo showInfoOnView:self.view withInfo:@"删除成功"];
                
                NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:pdfModel.name];
                [PublicTool deleteFileForPath:filePath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableData removeObject:pdfModel];
                    if (self.tableData.count == 0) {
                        [self.tableView reloadData];
                    }else{
                        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    }
                });
            }else{
                [ShowInfo showInfoOnView:self.view withInfo:@"删除失败"];
            }
        }else{
            [ShowInfo showInfoOnView:self.view withInfo:@"删除失败"];
        }
    }];
}

- (void)favorButtonClick:(UIButton*)btn{
    
    NSInteger index = btn.tag - 900;
    
    if (_currentRow != index) {
        ReportModel *reportModel = self.isSearch ? self.searchArr[_currentRow] : self.tableData[_currentRow];
        reportModel.showOptionView = 0;

    }
    ReportModel *reportModel = self.isSearch ? self.searchArr[index] : self.tableData[index];
    reportModel.showOptionView = 1 - reportModel.showOptionView;
    _currentRow = index;
    [self.tableView reloadData];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}
    if (_isToMe) {
        return;
    }
    
    if ((self.tableData.count >0 && !self.isSearch ) || (self.searchArr.count > 0 && self.isSearch)){
        
        if (indexPath.row == (self.isSearch ? self.searchArr.count : self.tableData.count)) {
            return;
        }
        
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
            if (![reportModel.fileExt isEqualToString:@"pdf"]) {
                FileItem *file = [[FileItem alloc] init];
                file.fileName= reportModel.name;
                file.fileUrl = reportModel.pdfUrl;
                file.fileId = reportModel.reportId;
                FileWebViewController * webVc = [[FileWebViewController alloc] init];
                webVc.fileItem = file;
                webVc.reportModel = reportModel;
                [self.navigationController pushViewController:webVc animated:YES];
                return;
            }
            
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
            webVC.reportModel = reportModel;
            [self.navigationController pushViewController:webVC animated:YES];
            
        }
    }
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
        [self requestBPLsitData:_searchCurrentPage ofNum:_searchNum];
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
    [self requestBPLsitData:_searchCurrentPage ofNum:_searchNum];
}

#pragma mark - 获取BP列表
- (void)requestBPLsitData:(NSInteger)currentPage ofNum:(NSInteger)num{
    
    if (self.isToMe) {
        [self requestBPToMe];
    }else{
        [self requestBP];
    }
    
}

- (void)requestBPToMe{
    self.info = @"";
    
    if([TestNetWorkReached networkIsReachedNoAlert]){
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"page":@(self.currentPage),@"num":@(self.numPerPage),@"keyword":[PublicTool isNull:self.mySearchBar.text]?@"":self.mySearchBar.text}];
        if (self.selectedMArr.count) {
            [dic setValue:[self.selectedMArr componentsJoinedByString:@"|"] forKey:@"tags"];
        }
        if (self.selectedProvinceArr.count) {
            [dic setValue:[self.selectedProvinceArr componentsJoinedByString:@"|"] forKey:@"provinces"];
        }
        if (self.selectedFlagArr.count > 0) {
            // flag');//1：未标记 2：感兴趣 0：不感兴趣
            NSMutableArray *arr = [NSMutableArray array];
            for (NSString *str in self.selectedFlagArr) {
                NSNumber *num;
                if ([str isEqualToString:@"未标记"]) {
                    num = @(1);
                } else if ([str isEqualToString:@"感兴趣"]) {
                    num = @(2);
                } else { // 不感兴趣
                    num = @(0);
                }
                [arr addObject:num];
            }
            
            [dic setValue:[arr componentsJoinedByString:@"|"] forKey:@"flag"];
        }
        
        [AppNetRequest getBPToMeListWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
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

- (void)requestBP{
    self.info = @"";
    
    if([TestNetWorkReached networkIsReachedNoAlert]){
        NSDictionary *dic = @{@"page":@(self.currentPage),@"num":@(self.numPerPage),@"keyword":[PublicTool isNull:self.mySearchBar.text]?@"":self.mySearchBar.text};
        
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
    
    NSMutableArray *pdfUrlMArr = [[DBHelper shared] toGetPdfFromLocal:_tableName fDataBase:_db];
    
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
//        reportModel.collectFlag = @"1";  //BP默认收藏
        reportModel.collectFlag = @"禁止收藏";  //BP默认收藏
        reportModel.report_source = @"上传";
        if (![PublicTool isNull:[dataDict objectForKey:@"interest_flag"]]) { //感兴趣否
            reportModel.interest_flag = [[dataDict objectForKey:@"interest_flag"] integerValue];

        }
        //投递人
        reportModel.send_nickname = dataDict[@"send_nickname"];
        reportModel.send_unionids = dataDict[@"send_unionids"];
        reportModel.send_user_company = dataDict[@"send_user_company"];
        reportModel.send_user_job = dataDict[@"send_user_job"];
        reportModel.send_user_phone = dataDict[@"send_user_phone"];
        reportModel.send_person_id = dataDict[@"send_person_id"];
        reportModel.browse_status = dataDict[@"browse_status"];
        if (dataDict[@"product_info"]) {
            reportModel.product_info = [[SearchCompanyModel alloc]init];
            [reportModel.product_info setValuesForKeysWithDictionary:dataDict[@"product_info"] ];
        }
//        reportModel.pdfUrl = @"http://test.api.qimingpian.com/h/workBpAddWatermark?F=KsBLwU3CTr7yOva99I3mXcgfQ8upOeBiNqjoqWnBLfOM%2Bxu657xepYD72Zmfov8N507iG0ZpgujzaMDC1aSGww%3D%3D";

        NSString *fileExtension;
        NSArray *arr = [[reportModel.pdfUrl lastPathComponent] componentsSeparatedByString:@"."];
        if (arr.count) {
            fileExtension = [arr lastObject];
        }
        reportModel.pdfType = [dataDict objectForKey:@"filetype"];;
        reportModel.fileExt = fileExtension ? [fileExtension lowercaseString] : @"";

        reportModel.from = BP;
        reportModel.isDownload = [pdfUrlMArr containsObject:reportModel.name];

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
    [self.tableView registerClass:[ReportListNewCell class] forCellReuseIdentifier:@"ReportListNewCellID"];
    [self.tableView registerClass:[BPMeReceivedCell class] forCellReuseIdentifier:@"BPMeReceivedCellID"];

    [self.view addSubview:self.tableView];
    if (!_isToMe) {
        self.tableView.frame = CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight - kScreenBottomHeight);
        [self.view addSubview:self.bottomBgVw];
    }
    
    CGFloat height = 44.f;
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, height)];
    _tableHeaderView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.tableHeaderView = _tableHeaderView;
    
//    UIView *footerView = [[UIView alloc] init];
//    footerView.frame = CGRectMake(0, 0, SCREENW, 80);
//    footerView.backgroundColor = TABLEVIEW_COLOR;
//    self.tableView.tableFooterView = footerView;
    
    _mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(7, 0, SCREENW-14, height)];
    [_mySearchBar setBackgroundImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_mySearchBar.size]];
    //    _mySearchBar.backgroundImage = [UIImage imageNamed:@"nav-lightgray"];
    //设置背景色
    [_mySearchBar setBackgroundColor:TABLEVIEW_COLOR];
    [_mySearchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_borderTab"] forState:UIControlStateNormal];
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
    
    if (_isToMe) {
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewClick)];
        [self.tableView addGestureRecognizer:tapGest];
//
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
    }
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

- (void)tableViewClick {
    
    if (_isToMe) {
        if (self.isSearch) {
            if (_currentRow != -1 && (_currentRow < self.searchArr.count)) {
                ReportModel *reportModel = self.searchArr[_currentRow];
                reportModel.showOptionView = 0;
                [self.tableView reloadData];
            }
            
        }else{
            if (_currentRow != -1 && (_currentRow < self.tableData.count)) {
                ReportModel *reportModel = self.tableData[_currentRow];
                reportModel.showOptionView = 0;
                [self.tableView reloadData];
            }
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
        [self requestBPLsitData:_searchCurrentPage ofNum:_searchNum];
        
    }else{
        self.currentPage = 1;
        [self requestBPLsitData:self.currentPage ofNum:self.numPerPage];
        
    }
}
- (void)pullUp{
    if (_isSearch) {
        _searchCurrentPage++;
        [self requestBPLsitData:_searchCurrentPage ofNum:_searchNum];
        
    }else{
        self.currentPage ++;
        [self requestBPLsitData:self.currentPage ofNum:self.numPerPage];
        
    }
    
}

- (void)requestDownloadDocument:(ReportModel *)pdfModel{
    
    NSString *key = pdfModel.reportId;
    DownloadView *downloadAlertV = [self.downloadVMDict objectForKey:key];
    
    if (downloadAlertV){
        //隐藏过,没有下载完
        downloadAlertV.isShow = YES;
    }else{   //之前未下载
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


- (void)toSetLocalData{
    _db = [[DBHelper shared] toGetDB];
    _tableName = PDFTABLENAME;
}

#pragma mark - BPMeReceivedCellDelegate
- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell projectButtonClick:(NSString *)project {
    if (project.length <= 0) return;
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:project]];

}

- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell favorButtonClick:(UIButton *)button {
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    _currentRow = row;
}
-(void)bpMeReceivedCell:(BPMeReceivedCell *)cell refreshTableView:(ReportModel *)model{
    [self.tableView reloadData];
}

- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell lookBPButtonClick:(UIButton *)button {
        
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
       return;
    }
    
    //跳转,请求分组列表
    ReportModel *reportModel = cell.model;
    
    if (reportModel.browse_status.integerValue == 2) { //未查看 - > 已查看
        NSDictionary *dic = @{@"id":reportModel.reportId,@"flag":@"1"};
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"bpDeliver/UpdateBpUnreadflag" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            QMPLog(@"BP已读---%@",resultData);
            reportModel.browse_status = @"0";
            [WechatUserInfo shared].bp_count =  [WechatUserInfo shared].bp_count.integerValue > 1 ? [NSString stringWithFormat:@"%ld",[WechatUserInfo shared].bp_count.integerValue-1]:@"";
            [[WechatUserInfo shared] save];
        }];
    }
    
    reportModel.collectFlag = @"禁止收藏";
    if (![reportModel.fileExt isEqualToString:@"pdf"]) {
        FileItem *file = [[FileItem alloc] init];
        file.fileName = reportModel.name;
        file.fileUrl = reportModel.pdfUrl;
        file.fileId = reportModel.reportId;
        
        FileWebViewController *webVC = [[FileWebViewController alloc] init];
        webVC.fileItem = file;
        webVC.reportModel = reportModel;
        //            webVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webVC animated:YES];
        return;
    }
    
    if (reportModel.pdfUrl.length) {
        if (self.isToMe) {
            reportModel.collectFlag = @"禁止收藏";
        }else{
//            reportModel.collectFlag = @"1";
        }
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
        webVC.fileItem = file;webVC.reportModel =reportModel;
        [self.navigationController pushViewController:webVC animated:YES];
        
    }
    
    
}

- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell caontactButtonClick:(NSString *)phone {
    self.current_phone = phone;
    [PublicTool dealPhone:phone];
}
- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell sourceUserClick:(ReportModel *)model {
    if (model.send_person_id.length > 0 ) {
        [[AppPageSkipTool shared] appPageSkipToPersonDetail:model.send_person_id];

    } else {
        if (model.send_unionids.length > 0) {
            [[AppPageSkipTool shared] appPageSkipToUserDetail:model.send_unionids];

        }
    }
}
- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell editBPButtonClick:(UIButton *)button {
    
    ReportModel *model = cell.model;
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"修改BP名称" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setNeedsStatusBarAppearanceUpdate];
        
        ManagerAlertView *alertView = [ManagerAlertView initFrame];
        [alertView initViewWithTitle:@"修改BP名称"];
        alertView.action = @"addAlbumToSelf";
        alertView.delegata = self;
        alertView.currentVC = self;
        alertView.oldType = [self getFileTypeWithName:model.name];// model.name
        alertView.nameTextField.text = [model.name substringToIndex:model.name.length-alertView.oldType.length];
        alertView.bpID = model.reportId;
        [KEYWindow addSubview:alertView];
        self.alertView = alertView;
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self setNeedsStatusBarAppearanceUpdate];
    }];
    //去除 关联项目
//    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
        
    }else{
        
        [self.navigationController presentViewController:alertController animated:YES
                                              completion:nil];
    }
    
}
- (void)addAlbumToSelf:(NSString *)newName {
    
    if (![newName hasSuffix:self.alertView.oldType]) {
        newName = [newName stringByAppendingString:self.alertView.oldType];
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:self.alertView.bpID forKey:@"id"];
    [param setValue:newName forKey:@"bp_name"];
    [param setValue:@"edit" forKey:@"type"];
    [param setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
    
    [self.alertView removeFromSuperview];
    
    
    [PublicTool showHudWithView:KEYWindow];
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/editReceivedBp" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        if (resultData) {
            [self.tableView.mj_header beginRefreshing];
            [PublicTool showMsg:@"修改成功"];
        }else{
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
    
}

#pragma mark - 懒加载

- (NSMutableDictionary *)downloadVMDict{
    
    if (!_downloadVMDict) {
//        _downloadVMDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        _downloadVMDict = [[NSMutableDictionary alloc] init];
    }
    return _downloadVMDict;
}
-(NSMutableArray *)searchArr{
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
- (NSString *)getFileTypeWithName:(NSString *)fileName {
    NSString* regexStr=@"\\.([^\\.]*?)$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray * matches = [regex matchesInString:fileName options:0 range:NSMakeRange(0, [fileName length])];
    if (matches.count > 0) {
        NSTextCheckingResult *match = [matches lastObject];
        return [fileName substringWithRange:match.range];
    }
    return @"";
}
- (UIButton *)bpStatusBtn{
    if (_bpStatusBtn == nil) {
        _bpStatusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bpStatusBtn.frame = CGRectMake(60, 0, SCREENW - 120, 49);
        [_bpStatusBtn setTitle:@"BP投递记录" forState:UIControlStateNormal];
        [_bpStatusBtn setImage:[UIImage imageNamed:@"my_bp_deliverStatus"] forState:UIControlStateNormal];
        _bpStatusBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_bpStatusBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [_bpStatusBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        [_bpStatusBtn addTarget:self action:@selector(jumpBPStatusVC:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bpStatusBtn;
}
- (UIView *)bottomBgVw{
    if (_bottomBgVw == nil) {
        _bottomBgVw = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENH - kScreenTopHeight - kScreenBottomHeight, SCREENW, kScreenBottomHeight)];
        _bottomBgVw.backgroundColor = [UIColor whiteColor];
        _bottomBgVw.layer.shadowColor = H9COLOR.CGColor;
        _bottomBgVw.layer.shadowRadius = 1;
        _bottomBgVw.layer.shadowOpacity = 0.3;
        _bottomBgVw.layer.shadowOffset= CGSizeMake(1, 1);
        [_bottomBgVw addSubview:self.bpStatusBtn];
    }
    return _bottomBgVw;
}
- (NSMutableArray *)tableData{
    if (_tableData == nil) {
        _tableData = [NSMutableArray array];
    }
    return _tableData;
}
- (void)jumpBPStatusVC:(UIButton *)btn{
    BPDeliverStatusVC * vc = [[BPDeliverStatusVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
