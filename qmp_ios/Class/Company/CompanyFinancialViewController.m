//
//  CompanyFinancialViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/5/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CompanyFinancialViewController.h"
#import "CompanyFinancialHeaderView.h"
#import "FileWebViewController.h"
#import "DownloadView.h"
#import "OpenDocument.h"
#import "CustomAlertView.h"


@interface CompanyFinancialViewController ()<UITableViewDelegate, UITableViewDataSource,OpenDocumentDelegate,DownloadViewDelegate>
@property (nonatomic, strong) CompanyFinancialHeaderView *headerView;
@property (nonatomic, strong) NSMutableDictionary *downloadVMDict;
@end

@implementation CompanyFinancialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"融资需求";
    [self initTableView];
    
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"反馈" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(feedback) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)initTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.contentInset = UIEdgeInsetsMake(12, 0, 12, 0);
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableHeaderView.backgroundColor = [UIColor whiteColor];
    
    self.headerView.needModel = self.needModel;
    
    
    [self.headerView.contactButton addTarget:self action:@selector(contactButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView.bpButton addTarget:self action:@selector(bpButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    if (self.needModel.bright_spot.length) {
        self.headerView.height = self.headerView.advantageLabel.bottom+15;
    } else {
        self.headerView.height = self.headerView.advantageLabel.bottom;
    }

}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.needModel.bright_spot.length) {
        self.headerView.height = self.headerView.advantageLabel.bottom+15;
    } else {
        self.headerView.height = self.headerView.advantageLabel.bottom;
    }
}

- (void)contactButtonClick:(UIButton *)button {
    
    if ([PublicTool isNull:self.needModel.sponsor_phone]) {
        [PublicTool showMsg:@"暂无联系方式"];
        return;
    }
    [PublicTool dealPhone:self.needModel.sponsor_phone];
}

- (void)bpButtonClick:(UIButton*)bpBtn{
    if (![PublicTool userisCliamed]) {
        return;
    }
    /*
     进行判断，url 无，进行弹窗处理
     */
    if ([PublicTool isNull:self.needModel.bp]) {
        [PublicTool showMsg:@"暂无BP"];
        return;
    }
    
    
    FileItem *file = [[FileItem alloc] init];
    file.fileName = [PublicTool isNull:self.needModel.bp_name]?@"":self.needModel.bp_name;
    file.fileUrl = self.needModel.bp;
    FileWebViewController *webVC = [[FileWebViewController alloc] init];
    webVC.fileItem = file;
    //            webVC.hidesBottomBarWhenPushed = YES;
    ReportModel * rtmodel = [[ReportModel alloc] init];
    rtmodel.collectFlag = @"禁止收藏";
    webVC.reportModel = rtmodel;
    [self.navigationController pushViewController:webVC animated:YES];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID" forIndexPath:indexPath];
    return cell;
}
- (CompanyFinancialHeaderView *)headerView {
    if (!_headerView) {
        CompanyFinancialHeaderView *view = [nil loadNibNamed:@"CompanyFinancialHeaderView" owner:nil options:nil].lastObject;
        _headerView = view;
    }
    return _headerView;
}
- (NSMutableDictionary *)downloadVMDict{
    
    if (!_downloadVMDict) {
        _downloadVMDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _downloadVMDict;
}
- (BOOL)prefersStatusBarHidden{
    return NO;
}
- (void)feedbackAlertView:(NSMutableArray *)mArr frame:(CGRect)frame WithAlertViewHeight:(CGFloat)height moduleDic:(NSDictionary *)infoDic moduleNum:(NSInteger)num{
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:frame WithAlertViewHeight:height infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:num isFeeds:NO];
}
- (void)feedback {
   
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息

    if (![PublicTool isNull:self.companyDetail.company_basic.product]) {
        [infoDic setValue:self.companyDetail.company_basic.product forKey:@"product"];
    }else{
        [infoDic setValue:@"" forKey:@"product"];
    }
    if (![PublicTool isNull:self.companyDetail.company_basic.company]) {
        [infoDic setValue:self.companyDetail.company_basic.company forKey:@"company"];
    }else{
        [infoDic setValue:@"" forKey:@"company"];
    }

    [infoDic setValue:@"融资需求" forKey:@"module"];
    [infoDic setValue:@"融资需求" forKey:@"title"];
    [mArr addObject:@"融资轮次不对"];[mArr addObject:@"融资金额不对"];
    [mArr addObject:@"融资比例不对"];[mArr addObject:@"联系人不对"];
    [mArr addObject:@"联系方式不对"];[mArr addObject:@"BP不对"];
    [self feedbackAlertView:mArr frame:CGRectZero WithAlertViewHeight:0 moduleDic:infoDic moduleNum:0];
}
- (void)downloadPdfUseWWAN:(ReportModel *)reportModel {
    
}
@end
