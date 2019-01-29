//
//  CompanyReportListViewController.m
//  qmp_ios
//
//  Created by Molly on 2016/12/16.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CompanyReportListViewController.h"
#import "MainNavViewController.h"
#import "CompanyReportTableViewCell.h"
#import "DownloadView.h"

#import "FileItem.h"
#import "OpenDocument.h"
#import "CompanyDetailNewThirdModel.h"
#import "FileWebViewController.h"

@interface CompanyReportListViewController ()<UITableViewDelegate,UITableViewDataSource,DownloadViewDelegate,OpenDocumentDelegate,UISearchBarDelegate>{
    
    NSInteger _currentPage;
    NSInteger _num;
    NSInteger _searchNowPage;
    BOOL  _isSearching;
    
}

@property (strong, nonatomic) NSMutableDictionary *downloadVMDict;

@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) NSString *tableName;


@property (strong, nonatomic) GetSizeWithText *sizeTool;
@property (strong, nonatomic) OpenDocument *openPDFTool;
@property (nonatomic,strong) UIView *searchBgView;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) UIButton *cancleBtn;
@property (strong, nonatomic) NSMutableArray *searchData;
@property (nonatomic,strong) UITapGestureRecognizer *tapCancelSearch;

@end

@implementation CompanyReportListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isSearching = NO;
    _searchNowPage = 1;
    _currentPage = 1;
    _num = 40;
    _tableData = [NSMutableArray array];
    [self initTableView];
    self.title = [PublicTool isNull:self.title] ? @"公司公告":self.title;

    [self toSetLocalData];
    [self showHUD];
    [self requestReportList];
    
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(receiveDownloadSuccess:) name:NOTIFI_PDFDOWNSUCCESS object:nil];
    [notiCenter addObserver:self selector:@selector(receiveDownloadFail:) name:NOTIFI_PDFDOWNFAIL object:nil];
}


#pragma mark - OpenDocumentDelegate
- (void)downloadPdfUseWWAN:(ReportModel *)reportModel{
    
    [self requestDownloadDocument:reportModel];
    
}

#pragma mark - DownloadViewDelegate
- (void)receiveDownloadFail:(NSNotification *)noti{
    
    ReportModel *pdfModel = (ReportModel *)noti.object;
    
    if ([pdfModel.from isEqualToString:HYBG]) {
        
        FileItem *file = [[FileItem alloc] init];
        file.fileName = pdfModel.name;
        file.fileUrl = pdfModel.pdfUrl;
        file.fileId = pdfModel.reportId;
        
        FileWebViewController *webVC = [[FileWebViewController alloc] init];
        webVC.fileItem = file;
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

- (void)receiveDownloadSuccess:(NSNotification *)noti{
    
    NSDictionary *dict = (NSDictionary *)noti.object;
    
    NSString *pdfType = dict[@"from"];
    if ([pdfType isEqualToString:HYBG]) {
        
        ReportModel *model = [[ReportModel alloc] init];
        model.reportId = dict[@"id"];
        model.name = dict[@"title"];
        model.pdfUrl  = dict[@"url"];
        model.collectFlag = dict[@"collect"];

        [self downloadNewPdfSuccess:model];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isSearching && _searchBar.text.length > 0&& _searchData.count == 0)  {
        [self.tableView removeGestureRecognizer:self.tapCancelSearch];

        return 1;
    }
    
    [self.tableView removeGestureRecognizer:self.tapCancelSearch];

    if (_isSearching) {
       
        return self.searchData.count ? : 1;
    }else{

        return self.tableData.count ? : 1;

    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   if (_isSearching && _searchBar.text.length > 0&& _searchData.count == 0) {
        
        return SCREENH - kScreenTopHeight - 50;
    }
    
    ReportModel *reportModel ;
    if (_isSearching) {
        if (_searchData.count == 0) {
            return SCREENH - kScreenTopHeight;
        }
        reportModel = _searchData[indexPath.row];
    }else{
        if (_tableData.count == 0) {
            return SCREENH - kScreenTopHeight;
        }
        reportModel = _tableData[indexPath.row];
    }
    
    return [tableView fd_heightForCellWithIdentifier:@"CompanyReportTableViewCellID" configuration:^(CompanyReportTableViewCell *cell) {
        [cell initData:reportModel];
    }];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isSearching && _searchBar.text.length > 0&& _searchData.count == 0) { //正在搜索
        NSString *title = _isSearching ? REQUEST_SEARCH_NULL : REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
        
    }else {
        if (_isSearching) {
            if (_searchData.count == 0) {
               return  [self nodataCellWithInfo:REQUEST_SEARCH_NULL tableView:tableView];
            }
        }else{
            if (_tableData.count == 0) {
                return  [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
            }
        }
        //公司公告
        static NSString *cellIdentifier = @"CompanyReportTableViewCellID";
        CompanyReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        ReportModel *model;
        if (_isSearching) {
            model = self.searchData[indexPath.row];
        }else{
            model = _tableData[indexPath.row];
        }
        [cell initData:model];
        return cell;

    }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isSearching && self.searchData.count == 0) {
        return;
    }
    if (![PublicTool userisCliamed]) {
        if ([WechatUserInfo shared].claim_type.integerValue != 1) {
            [QMPEvent event:@"report_noclaim_alert"];
        }
        return;
    }
    
    if ([TestNetWorkReached networkIsReachedNoAlert]) {
        
        ReportModel *reportModel;
        if (_isSearching) {
            reportModel = self.searchData[indexPath.row];
        }else{
            reportModel = self.tableData[indexPath.row];
        }
        
        if ([reportModel.pdfUrl hasSuffix:@".pdf"]) {
            OpenDocument *openPDFTool = [[OpenDocument alloc] init];
            openPDFTool.viewController = self;
            openPDFTool.delegate = self;
            reportModel.collectFlag = @"禁止收藏";
            if (reportModel.name && [openPDFTool downDocumentToBox:reportModel]) {
                
                //本地下载了该文档
                [openPDFTool openDocumentofReportModel:reportModel];
            }else{
                
                Reachability *reach = [Reachability reachabilityForInternetConnection];
                NetworkStatus status = [reach currentReachabilityStatus];
                if (status == ReachableViaWWAN) {
                    //使用数据流量的时候弹窗提醒
                    [openPDFTool launchReachableViaWWANAlert:status ofCurrentVC:self withModel:reportModel];
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
            webVC.collect_flag_status = reportModel.collectFlag;
            webVC.reportModel = reportModel;
            [self.navigationController pushViewController:webVC animated:YES];
        }
        
        [QMPEvent event:@"pro_gonggao_cellClick"];
    }
}

#pragma mark - 请求公告列表
- (void)requestReportList{
    
    if (!self.searchBar.text) {
        self.searchBar.text = @"";
    }
    if ([TestNetWorkReached networkIsReached:self]) {
        NSMutableDictionary *params ;
        if (_isSearching) {
            params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(_searchNowPage),@"page",@(_num),@"num",@"all",@"type",self.company ? self.company : @"",@"company",self.searchBar.text ,@"keyword",self.status,@"status",nil];
        }else{
          params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(_currentPage),@"page",@(_num),@"num",@"all",@"type",self.company ? self.company : @"",@"company",self.status,@"status",nil];
        }
        
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/getAllAshareinfo" HTTPBody:params completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [self.tableView.mj_header endRefreshing];
            [self hideHUD];
            if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
                //公司公告
                NSMutableArray *reportMArr = [[NSMutableArray alloc] initWithCapacity:0];
                NSMutableArray *localMArr = [[DBHelper shared] toGetPdfFromLocal:_tableName fDataBase:_db];
                NSArray *reports = resultData[@"reports"];
                for (NSDictionary *reportDict in reports) {
                    CompanyDetailNewThirdModel *report = [[CompanyDetailNewThirdModel alloc]init];
                    [report setValuesForKeysWithDictionary:reportDict];
                    
                    ReportModel *model = [[ReportModel alloc] init];
                    model.reportId = report.pdf_id;
                    model.name = report.title;
                    model.size = reportDict[@"size"];
                    model.datetime = [NSString stringWithFormat:@"%@",report.time];
                    model.pdfUrl = report.file;
                    model.pdfType = report.pdf_type;
                    model.collectFlag = [NSString stringWithFormat:@"%@",report.is_collect];
                    model.isNewThird = (report.category &&( [report.category isEqualToString:@"公开转让说明书"] || [report.category isEqualToString:@"招股说明书"]));
                    model.from = HYBG;
                    model.isDownload = [localMArr containsObject:model.name];
                    [reportMArr addObject:model];
                }
                if (_isSearching) {
                    if (_searchNowPage == 1) {
                        [self.searchData removeAllObjects];
                    }
                }else{
                    if (_currentPage == 1) {
                        
                        [self.tableData removeAllObjects];
                    }
                }
                
                if (reportMArr.count > 0) {
                    for (ReportModel *reportModel in reportMArr) {
                        if (_isSearching) {
                            [self.searchData addObject:reportModel];
                        }else{
                            [self.tableData  addObject:reportModel];
                        }
                    }
                    [self.tableView.mj_footer endRefreshing];
                }
                [self setMj_footer];
            }
            
            [self.tableView reloadData];
            
        }];
        
    }else{
        
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        [self hideHUD];
    }
}

- (void)setMj_footer{


    if (_isSearching) {
        if (self.searchData.count %_num ==  0) {
            self.mjFooter.state = MJRefreshStateIdle;

            self.mjFooter.stateLabel.hidden = YES;
            
        }else{
            self.mjFooter.stateLabel.hidden = NO;
            [self.tableView.mj_footer endRefreshingWithNoMoreData];

        }
    }else{
        if (self.tableData.count %_num ==  0) {
            self.mjFooter.state = MJRefreshStateIdle;

            self.mjFooter.stateLabel.hidden = YES;
        }else{
            self.mjFooter.stateLabel.hidden = NO;
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            
        }
    }
}

#pragma mark --UISearchBarDelegate---

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{

    _isSearching = YES;
    self.cancleBtn.hidden = NO;
    CGRect frame = self.searchBar.frame;
    frame.size.width = SCREENW - 58;
    self.searchBar.frame = frame;

    if (!_searchBar.text || _searchBar.text.length == 0) {
        [_searchData removeAllObjects];
        [self.tableView reloadData];
        [self setMj_footer];

        [self.tableView addGestureRecognizer:self.tapCancelSearch];
    }
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] > 20) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"字数不能超过20" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:alertAction];
        [self presentViewController:alertController animated:NO completion:nil];
        [_searchBar setText:[searchText substringToIndex:20]];
    }
    
    if (!_searchBar.text || _searchBar.text.length == 0) {
        [_searchData removeAllObjects];
        [self.tableView reloadData];
        [self setMj_footer];
        [self.tableView addGestureRecognizer:self.tapCancelSearch];
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    _currentPage = 1;
    [self requestReportList];
    
    [self.searchBar resignFirstResponder];
    
}

- (void)searchResignFirseResponder{
    _isSearching = NO;
    _searchBar.text = @"";
    
    [self.searchBar resignFirstResponder];
    CGRect frame = self.searchBar.frame;
    frame.size.width = SCREENW-14;
    self.searchBar.frame = frame;
    self.cancleBtn.hidden = YES;

    
    [self.tableView reloadData];


}
- (void)cancleBtnTouched
{
    [self searchResignFirseResponder];
}

- (void)tabelViewTapGesture{
    
    if (_isSearching && self.searchData.count == 0) {
        [self searchResignFirseResponder];
        
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_isSearching && (_searchBar.text.length == 0 || !_searchBar.text)) {
        [self searchResignFirseResponder];

    }else if(_isSearching && _searchBar.text.length >0 && self.searchData.count){
        [self.searchBar resignFirstResponder];
    }

}

#pragma mark - public

- (void)initTableView{
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.mj_header = self.mjHeader;
    
    self.tableView.mj_footer = self.mjFooter;
    
    self.tableView.tableHeaderView = self.searchBgView;
    
    [self.tableView registerClass:[CompanyReportTableViewCell class] forCellReuseIdentifier:@"CompanyReportTableViewCellID"];


}

- (void)pullDown{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        if (_isSearching) {
            _searchNowPage = 1;
        }else{
            _currentPage = 1;
        }
        [self requestReportList];
    }else{
        [self.tableView.mj_header endRefreshing];
    }
}

- (void)pullUp{

    if ([TestNetWorkReached networkIsReached:self]) {
        if (_isSearching) {
            if (self.searchData.count == 0) {
                _searchNowPage = 1;
            }
            else{
                _searchNowPage ++;
            }
        }else{
            if (self.tableData.count == 0) {
                _currentPage = 1;
            }
            else{
                _currentPage ++;
            }        }
        
        [self requestReportList];
    }
    else{
        [self.tableView.mj_footer endRefreshing];
    }

}
- (void)toSetLocalData{
    _db = [[DBHelper shared] toGetDB];
    _tableName = PDFTABLENAME;
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

#pragma mark - 懒加载
- (UIView *)searchBgView
{
    if (!_searchBgView) {
        CGFloat height = 44;
        _searchBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 44)];
        _searchBgView.backgroundColor = self.tableView.backgroundColor;
    
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(7, 0, SCREENW-14, height)];
        [_searchBar setBackgroundImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_searchBar.size]];
        //    _mySearchBar.backgroundImage = [UIImage imageNamed:@"nav-lightgray"];
        //设置背景色
        [_searchBar setBackgroundColor:TABLEVIEW_COLOR];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_borderBg"] forState:UIControlStateNormal];
        [_searchBar setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
        UITextField *tf = [_searchBar valueForKey:@"_searchField"];
        tf.font = [UIFont systemFontOfSize:14];
        NSString *str = @"搜索公司公告关键字";
        tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        
        _searchBar.delegate = self;
        
        CGFloat width = 60.f;
        _cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - width - 1, 0, width, height)];
        [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancleBtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
        [_cancleBtn addTarget:self action:@selector(cancleBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        //底部线条
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, SCREENW, 0.5)];
        line.backgroundColor = HTColorFromRGB(0xd2d2d2);
        [_searchBgView addSubview:_cancleBtn];

        [_searchBgView addSubview:_searchBar];
        [_searchBgView addSubview:line];

        
    }
    return _searchBgView;
}


- (NSMutableArray *)searchData{
    if (!_searchData) {
        _searchData = [NSMutableArray array];
    }
    return _searchData;
}
- (UITapGestureRecognizer *)tapCancelSearch{
    if (!_tapCancelSearch) {
        _tapCancelSearch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tabelViewTapGesture)];
    }
    return _tapCancelSearch;
}

- (NSMutableDictionary *)downloadVMDict{
    
    if (!_downloadVMDict) {
        _downloadVMDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _downloadVMDict;
}

- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}

- (OpenDocument *)openPDFTool{
    
    if (!_openPDFTool) {
        _openPDFTool = [[OpenDocument alloc] init];
        _openPDFTool.viewController = self;
    }
    
    return _openPDFTool;
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
