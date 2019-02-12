//
//
//  qmp_ios_v2.0
//
//  Created by Molly on 16/9/2.
//  Copyright © 2016年 Molly. All rights reserved.
//
#import "ReportController.h"
#import "HangyanReportCell.h"
#import "OpenDocument.h"
#import "DownloadView.h"
#import "FileWebViewController.h"
#import "FileItem.h"
#import "ReportModel.h"
#import "DownloadTool.h"
#import "JKEncrypt.h"
#import "RzEventFilterView.h"
#import "IndustryItem.h"
#import "DataHandle.h"

#define CellReuserId @"ReportListCell"
@interface ReportController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,OpenDocumentDelegate,DownloadViewDelegate,DataHandleDelegate,changeNoPdfCollectionStatusDelegate, RzEventFilterViewDelegate>{
    
    NSInteger _searchCurrentPage;
    JKEncrypt *_encodeTool;
    UIButton *_filterBtn;
}

@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UIButton *cancleSearchBtn;

@property (strong, nonatomic) NSMutableArray *reportArr;
@property (strong, nonatomic) NSMutableArray *searchArr;
@property (assign, nonatomic) BOOL isSearch;
@property (strong, nonatomic) NSMutableDictionary *downloadVMDict;

@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) NSString *tableName;

@property (strong, nonatomic) NSDateFormatter *dateFormat;
@property (strong, nonatomic) MJRefreshAutoNormalFooter *footer;
@property (strong, nonatomic) UIView *firstView;


@property (strong, nonatomic) GetSizeWithText *sizeTool;
@property (strong, nonatomic) ManagerHud *hudTool;
@property(nonatomic,strong)  HangyanReportCell *reportCell;
@property(nonatomic,strong) NSIndexPath * selectedIndexPath;
@property (nonatomic, strong) RzEventFilterView *filterView;
@property (nonatomic, strong) NSMutableArray *filterData;
@property (nonatomic, strong) NSMutableArray *industryArr;
@property (nonatomic, strong) NSMutableArray *selectedMArr;
@property (nonatomic, strong) NSMutableArray *oldLyselectedMArr;
@property (strong, nonatomic) NSString *tableName2;
@end

@implementation ReportController
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [IQKeyboardManager sharedManager].enable = NO;
    [QMPEvent beginEvent:@"trz_report_timer"];

}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [self.view endEditing:YES];
    [QMPEvent endEvent:@"trz_report_timer"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"行研报告";
    _tableName2 = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsindustry",@"report"]];
    [self initTableView];
    _encodeTool = [[JKEncrypt alloc]init];
    _db = [[DBHelper shared] toGetDB];
    [_db open];
    
    [self showHUD];
    
    [self keyboardManager];
    
    [self toSetLocalData];
    [self getLocalIndustryData];
    
    _searchCurrentPage = 1;
    self.currentPage = 1;
    self.numPerPage = 40;
    [self requestPdfList:self.currentPage ofNum:self.numPerPage];
    [self rightBarbutton];
    
    
    
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(receiveDownloadSuccess:) name:NOTIFI_PDFDOWNSUCCESS object:nil];
    [notiCenter addObserver:self selector:@selector(receiveDownloadFail:) name:NOTIFI_PDFDOWNFAIL object:nil];

    [notiCenter addObserver:self selector:@selector(receiveRemoveReportListSearchNotification) name:@"removeReportListSearch" object:nil];
    [notiCenter addObserver:self selector:@selector(receiveCleanDownloadPdfList:) name:@"cleanDownloadPdfList" object:nil];
    [notiCenter addObserver:self selector:@selector(receiveHiddenReportListKeyBoard) name:@"hiddenReportListKeyBoard" object:nil];
}

- (void)rightBarbutton{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setImage:[UIImage imageNamed:@"bar_setgray"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"bar_setBlue"] forState:UIControlStateSelected];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [rightBtn setTitleColor:NV_OTHERTITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(filterBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    _filterBtn = rightBtn;
    
}
- (void)filterBtnClick {
    self.searchArr = [NSMutableArray array];
    self.isSearch = NO;
    self.mySearchBar.text = @"";
    [self.tableView reloadData];
    
    self.filterView = [RzEventFilterView initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH) withKey:@"report"];
    self.filterView.delegate = self;
    [KEYWindow addSubview:self.filterView];
}
- (void)updateRongziNews:(NSMutableArray *)selectedMArr withEventMArr:(NSMutableArray *)eventMArr lunciMArr:(NSMutableArray *)lunciArr {
    self.selectedMArr = selectedMArr;
    [self.tableView.mj_header beginRefreshing];
    
    [self confirmFilter:selectedMArr];
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
        [QMPEvent event:@"trz_report_searchclick"];
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
//    _filterBtn.hidden = ![PublicTool isNull:self.mySearchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    if (![searchBar.text isEqualToString:@""]) {
        _searchCurrentPage = 1;
        self.isSearch = YES;

        [self requestPdfList:_searchCurrentPage ofNum:self.numPerPage];
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
    }
    else{
        return self.isSearch ? self.searchArr.count : self.reportArr.count;
        
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isSearch && ![self.mySearchBar.text isEqualToString:@""] && self.searchArr.count == 0) {
        
        return SCREENH - kScreenTopHeight - kScreenBottomHeight;
    }
    else{
        
        ReportModel *report = self.isSearch ? self.searchArr[indexPath.row] : self.reportArr[indexPath.row];
        return [tableView fd_heightForCellWithIdentifier:@"HangyanReportCell" configuration:^(HangyanReportCell *cell) {
            cell.report = report;
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isSearch && ![self.mySearchBar.text isEqualToString:@""] && self.searchArr.count == 0) {
        
        NSString *title = self.isSearch ? REQUEST_SEARCH_NULL : REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
        
    }else{
        ReportModel *reportModel = self.isSearch ? self.searchArr[indexPath.row] : self.reportArr[indexPath.row];
        HangyanReportCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HangyanReportCell" forIndexPath:indexPath];
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
    
    if (_isSearch && ![self.mySearchBar.text isEqualToString:@""] && self.searchArr.count == 0){
        
        return;
    }
    if (self.isSearch && [self.mySearchBar.text isEqualToString:@""]) {
        [self cancleSearch];
    }
    else{
       
        [QMPEvent event:@"trz_report_cellclick"];
        
        ReportModel *reportModel = self.isSearch ? self.searchArr[indexPath.row] : self.reportArr[indexPath.row];
//        if ([reportModel.pdfUrl hasSuffix:@".pdf"] || [reportModel.fileExt isEqualToString:@"pdf"]) {
        if ([reportModel.pdfUrl hasSuffix:@".pdf"]) {
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
            webVC.deleage = self;
            _selectedIndexPath = indexPath;
            webVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:webVC animated:YES];
        }
        
        
    }
}
- (void)changeNoPdfCollectionStatusByClick:(ReportModel *)changeModel{
    if (self.isSearch) {
//        [self.searchArr replaceObjectAtIndex:_selectedIndexPath.row withObject:changeModel];
    }else{
//        [self.reportArr replaceObjectAtIndex:_selectedIndexPath.row withObject:changeModel];
    }
    [self.tableView reloadRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
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

#pragma mark - DataHandleDelegate
- (void)pressOKOnDataHandleAlertView{
    
}

#pragma mark - 请求获取pdf列表
- (void)beginSearch:(NSString*)text{
    [self.searchArr removeAllObjects];

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
    [self requestPdfList:_searchCurrentPage ofNum:self.numPerPage];
}


- (void)requestPdfList:(NSInteger )page ofNum:(NSInteger )num{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        
        if ( [self.mySearchBar.text isEqualToString:@""]&&self.searchArr.count > 0) {
            [self.searchArr removeAllObjects];
        }
        
        NSMutableDictionary *searchDict = [NSMutableDictionary dictionaryWithDictionary:@{@"page":[NSString stringWithFormat:@"%ld",(long)page],@"num":[NSString stringWithFormat:@"%ld",(long)num]}];
        [searchDict setObject:@"" forKey:@"sort"];

        ManagerHud *hudTool = [[ManagerHud alloc] init];
        UIView *searchHudView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, SCREENW, SCREENH - kScreenTopHeight - 50.f)];
        if (self.isSearch) {
            [searchDict setValue:self.mySearchBar.text forKey:@"keywords"];
            if (_searchCurrentPage == 1 && ![self.tableView.mj_header isRefreshing]) {
                [hudTool addHud:searchHudView];
                searchHudView.backgroundColor = [UIColor whiteColor];
                [self.view addSubview:searchHudView];
            }
            self.selectedMArr = [NSMutableArray array];
            [self confirmFilter:self.selectedMArr];
        } else {
            if (self.selectedMArr.count > 0) {
                [searchDict setObject:[self handleArrToStr:self.selectedMArr] forKey:@"hangye"];
            } else {
                [searchDict setObject:@"6" forKey:@"sort"];
            }
        }
        _filterBtn.selected = self.selectedMArr.count > 0;
        [AppNetRequest getReportByTagWithParameter:searchDict completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            [hudTool removeHud];
            [searchHudView removeFromSuperview];
            
            if (resultData) {
                
                NSMutableArray *retMArr = [[NSMutableArray alloc] initWithArray:[self handlePdfListDict:resultData]];
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
                
                if (self.isSearch) {
                    //搜索状态下
                    if (_searchCurrentPage == 1) {
                        self.searchArr = retMArr;
                    }else{
                        [self.searchArr addObjectsFromArray:retMArr];
                    }
                    
                }else{
                    //正常状态下包含分页
                    if (self.currentPage == 1) {
                        self.reportArr = retMArr;
                    }else{
                        [self.reportArr addObjectsFromArray:retMArr];
                    }
                }
                [self refreshFooter:retMArr];
            }
            [self.tableView reloadData];
            
        }];
        
    }else{
        
        [self hideHUD];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
    }
}

- (NSMutableArray *)handlePdfListDict:(NSDictionary *)dict{
    
    NSMutableArray *pdfUrlMArr = [[DBHelper shared] toGetPdfFromLocal:_tableName fDataBase:_db];
    
    NSMutableArray *reportMArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dataDict in dict[@"list"]) {
        
        ReportModel *reportModel = [[ReportModel alloc] init];
        [reportModel setValuesForKeysWithDictionary:dataDict];
        reportModel.name = [dataDict objectForKey:@"name"];
        reportModel.reportId = [dataDict objectForKey:@"id"];
        reportModel.read_count = [dataDict objectForKey:@"read_count_program"];

        reportModel.datetime = [dataDict objectForKey:@"update_time"];
        reportModel.pdfUrl = [dataDict objectForKey:@"url"];
        reportModel.size = [dataDict objectForKey:@"size"];
        reportModel.collectFlag = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"collect_flag"]];
        reportModel.remark = @"";
        reportModel.pdfType = [dataDict objectForKey:@"filetype"];
        NSString *fileext = [dataDict objectForKey:@"fileext"];
        reportModel.fileExt = fileext ? [fileext lowercaseString] : @"";
        reportModel.from = HYBG;
        
        reportModel.isDownload = [pdfUrlMArr containsObject:reportModel.name];
        
        [reportMArr addObject:reportModel];
        //            QMPLog(@"%@=====",reportModel.uploadTime);
        QMPLog(@"%@=====",reportModel.update_time);
        
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
    [self.tableView registerClass:[HangyanReportCell class] forCellReuseIdentifier:@"HangyanReportCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
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
    NSString *str = @"搜索报告";
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
        [self requestPdfList:_searchCurrentPage ofNum:self.numPerPage];
    }
    else{
        self.currentPage = 1;
        
        [self requestPdfList:self.currentPage ofNum:self.numPerPage];

    }
}
- (void)pullUp{
    
    if (self.isSearch) {
        _searchCurrentPage ++;
        [self requestPdfList:_searchCurrentPage ofNum:self.numPerPage];
        
    }
    else{
        self.currentPage ++;
        
        [self requestPdfList:self.currentPage ofNum:self.numPerPage];

    }
}


- (void)receiveRemoveReportListSearchNotification{
    if (_isSearch) {
        [self cancleSearch];
    }
    
}

- (void)receiveCleanDownloadPdfList:(NSNotification *)noti{
    
    if (_isSearch) {
        [self handleReportDownloadStatus:self.searchArr];
    }
    
    [self handleReportDownloadStatus:self.reportArr];
    
    [self.tableView reloadData];
    
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


- (void)receiveHiddenReportListKeyBoard{
    
    if (_isSearch) {
        if ([self.mySearchBar.text isEqualToString:@""]) {
            [self cancleSearch];
        }
        else{
            
            [self.mySearchBar resignFirstResponder];
            
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


- (NSDateFormatter *)dateFormat{
    if (!_dateFormat) {
        _dateFormat = [[NSDateFormatter alloc]init];
        [_dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [_dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormat;
}
//- (RzEventFilterView *)filterView {
//    if (!_filterView) {
//        _filterView = [RzEventFilterView initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH) withKey:@"report"];
//        _filterView.delegate = self;
//    }
//    return _filterView;
//}
- (NSString *)handleArrToStr:(NSArray *)selectedMArr{
    NSString *hangye = @"";
    
    for (int i = 0; i < selectedMArr.count; i++) {
        if (i == 0) {
            hangye = selectedMArr[0];
        }else{
            hangye = [NSString stringWithFormat:@"%@|%@",hangye,selectedMArr[i]];
        }
    }
    
    return hangye;
}
- (void)getLocalIndustryData {
    
    _tableName2 = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsindustry",@"report"]];
    
    _db = [[DBHelper shared] toGetDB];
    
    BOOL tableExist = YES;
    
    if ([_db open]) {
        
        if ([[DBHelper shared] isTableOK:_tableName2 ofDataBase:_db]) {
            //如果表存在,直接赋值
            
            //领域
            [self toGetDataFromDbWithTableName:_tableName2 withNowSelectedMArr:self.selectedMArr withNowDataArr:self.industryArr];
            
            
            if (self.industryArr.count > 0) {
                //刷新列表
                [self.tableView reloadData];
                [self.tableView.mj_header beginRefreshing];
                
                self.oldLyselectedMArr = [NSMutableArray arrayWithArray:self.selectedMArr];
                
            }
            
        }else{
            tableExist = NO;
            //如果不存在表,则创建该表
            [self createTable:_tableName2];
            [self.tableView.mj_header beginRefreshing];
        }
    }
    
    if (tableExist == NO || self.industryArr.count == 0){
        
        [self requestIndustry:YES]; //当做首次请求，无数据存在
        
    }else if(tableExist){
        
        [self requestIndustry:NO]; //非首次请求，只判断接口是否有变
        
    }
}
- (void)createTable:(NSString *)tableName{
    
    if (![[DBHelper shared] isTableOK:tableName ofDataBase:_db]) {
        NSString *sql = [NSString stringWithFormat:@"create table if not exists '%@' ('name' text, 'selected' text)",tableName];
        BOOL res = [_db executeUpdate:sql];
    }
}
- (void)requestIndustry:(BOOL)isFirst{
    self.oldLyselectedMArr = [NSMutableArray arrayWithArray:self.selectedMArr];
        
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"1" forKey:@"filter_type"];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/showuserhangye" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        NSString *key = [NSString stringWithFormat:@"%@showUserhangyeHash", @"repost"];
        NSString *oldHash = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        NSString *newHash = [resultData objectForKey:@"hash"];
        
        //判断该接口数据是否变化
        if (oldHash && ![oldHash isEqualToString:@""] &&[oldHash isEqualToString:newHash] && !isFirst) {
            return ;
        }
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:newHash forKey:key];
        [userDefaults synchronize];
        
        NSString *delSql = [NSString stringWithFormat:@"delete from '%@'",_tableName2];
        BOOL delRes = [_db executeUpdate:delSql];

        if (delRes) {
            NSArray * dataArr = [resultData objectForKey:@"data"];
            NSMutableArray *retMArr = [self handelArr:dataArr ToArr:self.selectedMArr ofTableName:_tableName2];
            
            if (isFirst || !oldHash) {
                //保留最开始选中的行业
                self.oldLyselectedMArr = [NSArray arrayWithArray:self.selectedMArr];
                self.industryArr = retMArr;
                [self.tableView reloadData];
            }
        }
        
    }];
}
- (NSMutableArray *)handelArr:(NSArray *)dataArr ToArr:(NSMutableArray *)selectedMArr ofTableName:(NSString *)tableName{
    NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *sql = @"";
    
    if (dataArr.count > 0 ) {
        
        NSDictionary *dataDict = dataArr[0];
        NSString *name = dataDict[@"name"];
        if ([name isEqualToString:@"CN"]) {
            name = @"国内";
        }
        if ([name isEqualToString:@"EN"]) {
            name = @"国外";
        }
        
        
        sql = [NSString stringWithFormat:@"insert into '%@' (name,selected) values('%@','%@')",tableName,name,dataDict[@"selected"]];
        
        if (dataArr.count > 1) {
            for (int i = 1; i < dataArr.count ; i++) {
                NSDictionary *dataDict = dataArr[i];
                NSString *name = dataDict[@"name"];
                if ([name isEqualToString:@"CN"]) {
                    name = @"国内";
                }
                if ([name isEqualToString:@"EN"]) {
                    name = @"国外";
                }
                
                NSString *value = [NSString stringWithFormat:@",('%@','%@')",name,dataDict[@"selected"]];
                sql = [NSString stringWithFormat:@"%@%@",sql,value];
                
            }
        }
    }
    
    NSLog(@"insertSql========%@",sql);
    
    BOOL res = [_db executeUpdate:sql];
    
    if (res) {
        
        [selectedMArr removeAllObjects];
        
        for (NSDictionary *dataDict in dataArr) {
            IndustryItem *item = [[IndustryItem alloc] init];
            [item setValuesForKeysWithDictionary:dataDict];
            NSString *name = item.name;
            if ([name isEqualToString:@"CN"]) {
                name = @"国内";
            }
            if ([name isEqualToString:@"EN"]) {
                name = @"国外";
            }
            
            item.name = name;
            item.selected = @"0";
            
            [retMArr addObject:item];
        }
    }
    
    return retMArr;
}
- (void)toGetDataFromDbWithTableName:(NSString *)tableName withNowSelectedMArr:(NSMutableArray *)nowSelectedMArr withNowDataArr:(NSMutableArray *)nowDataArr{
    
    NSString *querySql = [NSString stringWithFormat:@"select * from '%@'",tableName];
    FMResultSet *rs = [_db executeQuery:querySql];
    [nowDataArr removeAllObjects];
    [nowSelectedMArr removeAllObjects];
    while ([rs next]) {
        
        IndustryItem *item = [[IndustryItem alloc] init];
        item.name = [rs stringForColumn:@"name"];
        item.selected = [rs stringForColumn:@"selected"];
        
        if ([item.selected isEqualToString:@"1"]) {
            [nowSelectedMArr addObject:item.name];
        }
        [nowDataArr addObject:item];
    }
}
- (void)confirmFilter:(NSMutableArray *)selectedMArr {
    
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [docsdir stringByAppendingPathComponent:@"user.sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        
        NSString *values = [self handleArrToSqlStr:selectedMArr];
        [self updateFilterWithTable:[NSString stringWithFormat:@"%@filterrznewsindustry",@"report"] withValues:values onDB:db];
        
    }
    
    [db close];
    db = nil;
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

- (void)updateFilterWithTable:(NSString *)name withValues:(NSString *)values onDB:(FMDatabase *)db{
    
    NSString *tableName = [[DBHelper shared] toGetTablename:name];
    NSString *selectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='1'  WHERE name in (%@)",tableName,values];
    NSString *notSelectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='0'  WHERE name not in (%@)",tableName,values];
    
    QMPLog(@"selectsql ==== %@",selectSql);
    QMPLog(@"notselectsql ==== %@",notSelectSql);
    [db executeUpdate:selectSql];
    [db executeUpdate:notSelectSql];
    
}
- (NSMutableArray *)selectedMArr {
    if (!_selectedMArr) {
        _selectedMArr = [NSMutableArray array];
    }
    return _selectedMArr;
}
- (NSMutableArray *)industryArr {
    if (!_industryArr) {
        _industryArr = [NSMutableArray array];
    }
    return _industryArr;
}
@end

