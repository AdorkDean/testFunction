//
//  NewsWebViewController.m
//  qmp_ios
//
//  Created by Molly on 16/9/11.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "NewsWebViewController.h"
#import "MainNavViewController.h"
#import "LrdOutputView.h"
#import "DownloadView.h"
#import "InsetsLabel.h"

#import "GetNowTime.h"
#import "OpenDocument.h"

#import "GetMd5Str.h"
#import "NoInterestView.h"

#define MainColor  UIColorFromRGB(0x1FB5EC)
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface NewsWebViewController ()<LrdOutputViewDelegate, WKUIDelegate,
WKNavigationDelegate, DownloadViewDelegate, OpenDocumentDelegate> {
    
    NSTimer *timer;
    FMDatabase *_db;
    
    NSInteger _oldNum;
    BOOL _hasClose;
    
    NSString *_tableName;
    NSString *dbPath;
    UIView *_companyView;
    
    NSString *_collectId;
}

@property (strong, nonatomic) UIView *openFailView;
@property (nonatomic, strong) UIView *openPDFView;
@property(nonatomic,strong)NoInterestView *alertV;

@property (strong, nonatomic) NSArray *moreOptionsArr;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIView *alertView;
@property (strong, nonatomic) UIButton *openPdfBtn;
@property (strong, nonatomic) DownloadView *downloadAlertV;

@property (copy, nonatomic) NSString *action;
@property (strong, nonatomic) NSArray *notEncodeArr;

@property (strong, nonatomic) GetNowTime *getNowTimeTool;
@property (strong, nonatomic) ManagerHud *parseHudTool;
@property (strong, nonatomic) AlertInfo *alertTool;
@property (strong, nonatomic) GetNowTime *timeTool;
@property (strong, nonatomic) OpenDocument *openPDFTool;

@end

@implementation NewsWebViewController

- (instancetype)initWithUrlModel:(URLModel *)urlModel withAction:(NSString *)action{
    
    if (self = [super init] ) {
        
        URLModel *selectModel = [[URLModel alloc] init];
        selectModel.url = urlModel.url;
        selectModel.urlId = urlModel.urlId;
        selectModel.title = urlModel.title;
        selectModel.collect_time = urlModel.collect_time;
        selectModel.isRead = urlModel.isRead;
        selectModel.isCollect = urlModel.isCollect;
        selectModel.isRecommend = urlModel.isRecommend;
        selectModel.type = urlModel.type;
        
        self.urlModel = selectModel;
        
        self.oldUrlModel = urlModel;
        self.action = action;
    }
    return self;
}
- (instancetype)initWithUrlModel:(URLModel *)urlModel{
    if (self = [super init] ) {
        self.urlModel = urlModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _oldNum = 0;
    if (self.urlModel && ![self.urlModel.url containsString:@"http"] && ![self.urlModel.url containsString:@"https"]) {
        self.urlModel.url = [NSString stringWithFormat:@"http://%@",self.urlModel.url];
    }
    
    [self loadURL];

    [self setupViews];
    
    [self initProgress];
    
    [self initInfoLbl];
    
    [self judgeUrlType];
    
    
    [self toSetLocalData];
    [self buildLeftBarButtonItem];
    if (![self.urlModel.title isEqualToString:@"百度一下"]) {
        [self buildRightBarButtonItem];
    }
    [self requestIsCollectOfUrl:self.urlModel.url];
    
    if (self.requestDic) {
        [self requestProductDetail];
    }
}
- (void)requestProductDetail {
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:self.requestDic];
    
    if ([PublicTool isNull:mDict[@"ticket"]] || [PublicTool isNull:mDict[@"id"]]) {
        return;
    }
    [AppNetRequest getCompanyDetailWithParameter:mDict completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *basic = resultData[@"company_basic"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:basic[@"product"] forKey:@"company"];
            [dict setObject:basic[@"lunci"] forKey:@"lunci"];
            [dict setObject:basic[@"icon"] forKey:@"icon"];
            [dict setObject:basic[@"yewu"] forKey:@"yewu"];
            
            NSString *detail = [NSString stringWithFormat:@"http://qimignpian.com/detailcom?id=%@&ticket=%@", self.requestDic[@"id"], self.requestDic[@"ticket"]];
            [dict setObject:detail forKey:@"detail"];
            self.companyDic = dict;
            self.webView.height = self.view.height - 64;
            [self initCompanyView];  // 带有公司信息需要初始化底部的公司信息 View
            
        }
    }];
}
- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    [self clearCaches];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    if (_webView) {
        [_webView stopLoading];
        _webView.UIDelegate = nil;
        _webView.navigationDelegate = nil;
        [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
   
}

- (void)setupViews {
    [self.view addSubview:self.webView];
    if (self.companyDic) {
        self.webView.height = self.view.height - 64;
        [self initCompanyView];  // 带有公司信息需要初始化底部的公司信息 View
    }
    
    
}
#pragma mark - LrdOutputViewDgelegate
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
//        case 0:{
//            [self shareURL];
//            break;
//        }
        case 0:{ //收藏或取消收藏
            if (![PublicTool isNull:_collectId]) {
                [self requestCancelCollectofUrlId:_collectId ofUrl:self.urlModel.url];
            }else{
                [self requestCollectURL];
            }
            break;
        }
        case 1:{
            [self feedbackItemClick];
            break;
        }
        case 2:{
            [self openWithSafari];
            break;
        }
        case 3:{
            [self judgePdfDownloadAndOpenPDF:self.urlModel];
            break;
        }
        default:
            break;
    }
}
#pragma mark - public
- (void)toSetLocalData{
    
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    dbPath = [docsdir stringByAppendingPathComponent:@"user.sqlite"];
    _tableName = @"urlpdflist";
    _db = [[DBHelper shared] toGetDB];
}



- (void)initInfoLbl{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    view.backgroundColor = [UIColor whiteColor];
    view.hidden = YES;
    [self.view addSubview:view];
    self.openFailView = view;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width - 20 * 2, self.view.frame.size.height - 400)];
    lbl.textColor = [UIColor lightGrayColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = @"该网页无法打开";
    [view addSubview:lbl];
}

- (void)clearCaches {
    
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Caches/WebKit"];
    [self delCaches:cookiesFolderPath];
}

- (void)delCaches:(NSString *)path{
    
    NSFileManager *fileM = [NSFileManager defaultManager];
    
    if ([fileM fileExistsAtPath:path]) {
        //文件存在 删除
        //获取所有文件
        NSArray *fileArray = [fileM subpathsAtPath:path];
        for (NSString *fileName in fileArray) {
            //可以过滤掉不想删除的文件格式
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            //删除
            [fileM removeItemAtPath:filePath error:nil];
        }
    }
}
- (void)buildLeftBarButtonItem{
    
    CGFloat btnW = 36.f;

    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    [leftButton setImage:[BundleTool imageNamed:@"left-arrow"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(pressLeftButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = LEFTNVSPACE;

    
    if (_hasClose) {
        
        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,btnW, 44)];
        [closeBtn setImage:[BundleTool imageNamed:@"web_close"] forState:UIControlStateNormal];
        closeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [closeBtn addTarget:self action:@selector(pressCloseBtn:) forControlEvents:
         UIControlEventTouchUpInside];
        
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        UIBarButtonItem *closeBtnItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
        
        if (iOS11_OR_HIGHER) {
            
            leftButton.width = 30;
            leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0);
            leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            closeBtn.width = 30;
            closeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0);
            UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
            self.navigationItem.leftBarButtonItems = @[buttonItem,closeItem];
            
        }else{
            
            self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftButtonItem,closeBtnItem];
        }
    }else{
        
        if (iOS11_OR_HIGHER) {
            //        leftButton.width = 30;
            leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
            //        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            
            self.navigationItem.leftBarButtonItems = @[leftButtonItem];
        }else{
            UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftButtonItem];
        }
    }
    
}

- (void)pressCloseBtn:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pressLeftButtonItem:(id)sender{
    
    NSInteger leftBtnCount;
    if (iOS11_OR_HIGHER) {
        leftBtnCount = self.navigationItem.leftBarButtonItems.count;
    }else{
        leftBtnCount = self.navigationItem.leftBarButtonItems.count-1;
    }
    if (self.webView.canGoBack && leftBtnCount > 1) {
        [self.webView goBack];
        //        [self changeCloseBtnStatus];
        
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)popToPre{
    
    if(![self.webView canGoBack]){
        
        [self.webView stopLoading];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void)goBack{
    
    if([self.webView canGoBack] ){
        //可以向前,同时没有显示该网页无法打开
        [self.webView goBack];
        
    }
    else if(![self.webView canGoBack]){
        
        //不能再向前,同时没有显示该网页暂时无法打开
        [self.webView stopLoading];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}
- (void)shareBtnClick {
    [self shareURL];
}
- (void)buildRightBarButtonItem{
    
    UIButton * moreBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
    [moreBtn setImage:[BundleTool imageNamed:@"moreOptions"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreOptions:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreBtn];
    
    UIButton * shareBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
    [shareBtn setImage:[BundleTool imageNamed:@"detail_share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * shareItem = [[UIBarButtonItem alloc]initWithCustomView:shareBtn];
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = RIGHTNVSPACE;
    if (iOS11_OR_HIGHER) {
        
        moreBtn.width = 30;
        moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
        
        shareBtn.width = 30;
        shareBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *buttonItem1 = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
        
        self.navigationItem.rightBarButtonItems = @[buttonItem, buttonItem1];
        
    }else{
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer, moreItem, shareItem];
    }
    
}

- (void)moreOptions:(UIButton *)sender{
    
    CGFloat x = SCREENW - 10;
    CGFloat y = kScreenTopHeight + 10;
    
//    LrdCellModel *sharModel = [[LrdCellModel alloc] initWithTitle:@"分享" imageName:@"web_share"];
    //是否已收藏
    NSString *title = [PublicTool isNull:_collectId] ? @"收藏":@"已收藏";
    NSString *img = [PublicTool isNull:_collectId] ? @"collect-url":@"web_iscollect";

    LrdCellModel *collectModel = [[LrdCellModel alloc] initWithTitle:title imageName:img];
    
    LrdCellModel *feedBackModel = [[LrdCellModel alloc] initWithTitle:@"反馈" imageName:@"web_feedback"];
    LrdCellModel *openModel = [[LrdCellModel alloc] initWithTitle:@"Safari打开" imageName:@"safari"];
    LrdCellModel *pdfModel = [[LrdCellModel alloc] initWithTitle:@"pdf阅读器" imageName:@"open-pdf"];
    
    NSArray *moreOptionsArr  = nil;
    if (self.urlModel.type && [self.urlModel.type isEqualToString:@"pdf"]) {
        moreOptionsArr = @[collectModel,feedBackModel,openModel,pdfModel];
    }else{
        moreOptionsArr = @[collectModel,feedBackModel,openModel];
    }
    
    __block LrdOutputView *outputView = [[LrdOutputView alloc] initWithDataArray:moreOptionsArr origin:CGPointMake(x, y) width:142 height:44 direction:kLrdOutputViewDirectionRight hasImg:YES];
    
    outputView.delegate = self;

    [outputView pop];
    
}

-(void)shareURL{
    
    NSString *titleStr = [NSString stringWithFormat:@"%@",!self.urlModel.title?@"":self.urlModel.title];
    NSString *detailStr = @"消息快人一步";
    
    if (![PublicTool isNull:self.companyDic[@"yewu"]]) {
        detailStr = self.companyDic[@"yewu"];
    }
    NSString *copyString = [NSString stringWithFormat:@"%@%@来自@企名片",detailStr,self.urlModel.url];
    [self.shareToTool shareWithDetailStr:detailStr sessionTitle:titleStr timelineTitle:titleStr copyString:copyString aIcon:[BundleTool imageNamed:@"87"] aOpenUrl:self.urlModel.url onViewController:self shareResult:^(BOOL shareSuccess) {
        
    }];
}

/**
 * 复制链接到粘贴板
 */
- (void)parseUrl{
    [UIPasteboard generalPasteboard].string = self.urlModel.url;
    
    [ShowInfo showInfoOnView:self.view withInfo:@"复制成功"];
    
}
- (void)feedbackItemClick {
    __weak typeof(self) weakSelf = self;
    _alertV = [[NoInterestView alloc] initWithAlertViewTitles:@[@"链接失效",@"内容关联错误"] viewcontroller:self];
    _alertV.titleLabel.text = @"新闻资讯反馈";
    _alertV.textview.placehoder = @"请在此填写线索、问题或者意见";
    _alertV.submitBtnClick = ^(NSString *liyou, NSString *detail){
        NSString *action = @"h/editcommonfeedback";
        
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        if ([weakSelf.feedbackFlag isEqualToString:@"项目"]) {
//            NSDictionary *dic = @{@"company":urlModel.product,@"lunci":urlModel.lunci?urlModel.lunci:@"",@"icon":urlModel.icon?urlModel.icon:@"",@"yewu":urlModel.yewu?urlModel.yewu:@"",@"detail":urlModel.detail};
//            self.companyDic = dic;
            [mDict setValue:weakSelf.company[@"product"] forKey:@"product"];
            [mDict setValue:weakSelf.company[@"company"] forKey:@"company"];
            
        } else if ([weakSelf.feedbackFlag isEqualToString:@"机构"]) {
            
            [mDict setValue:weakSelf.jigou[@"name"] forKey:@"jgname"];
        } else if ([weakSelf.feedbackFlag isEqualToString:@"人物"]) {
            
            [mDict setValue:weakSelf.person[@"id"] forKey:@"c3"]; // p_id
            [mDict setValue:weakSelf.person[@"name"] forKey:@"c4"]; // p_name
        }
        
        [mDict setValue:weakSelf.urlModel.title?:@"" forKey:@"c1"];
        [mDict setValue:weakSelf.urlModel.url?:@"" forKey:@"c2"];
        [mDict setValue:@"新闻资讯" forKey:@"type"];
        
        [mDict setValue:[NSString stringWithFormat:@"%@ %@",liyou, detail] forKey:@"desc"];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:action HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            if (resultData) {
                NSString *status = [resultData objectForKey:@"message"];
                if ([@"success" compare:status] == NSOrderedSame) {
                    [PublicTool showMsg:@"感谢您的反馈"];
                }
            }else{
                [PublicTool showMsg:@"反馈失败，请重试"];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];
    };
}
/**
 * 使用Safari打开
 */
- (void)openWithSafari{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlModel.url]];
}

- (void)initProgress{
    // 进度条
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0.1, self.view.frame.size.width, 0)];
    progressView.tintColor = MainColor;
    progressView.trackTintColor = [UIColor whiteColor];
    
    [self.view addSubview:progressView];
    
    self.progressView = progressView;
}

- (void)initWKWebView{
    [self.view addSubview:self.webView];
    if (self.companyDic) {
        self.webView.height = self.view.height - 64;
        
        [self initCompanyView];  // 带有公司信息需要初始化底部的公司信息 View
    }
}

- (void)initCompanyView{
    
    UIView *companyView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH-kScreenTopHeight - 64, SCREENW, 64)];
    companyView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *enterCompanyTag = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterCompany)];
    [companyView addGestureRecognizer:enterCompanyTag];
    
    [self.view addSubview:companyView];
    _companyView = companyView;
    
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(17, 12, 40, 40)];
    [imgV sd_setImageWithURL:[NSURL URLWithString:self.companyDic[@"icon"]] placeholderImage:[BundleTool imageNamed:PROICON_DEFAULT]];
    [companyView addSubview:imgV];
    imgV.layer.masksToBounds = YES;
    imgV.layer.cornerRadius = 3;
    imgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    imgV.layer.borderWidth = 0.5;
   
    CGFloat lunciWidth = [PublicTool widthOfString:self.companyDic[@"lunci"] height:CGFLOAT_MAX fontSize:12];

    
    CGFloat width = [PublicTool widthOfString:self.companyDic[@"company"] height:CGFLOAT_MAX fontSize:16];
    CGFloat nameMaxWidth = SCREENW - 72 - 115 - 25 - lunciWidth;
    if (width > nameMaxWidth) {
        width = nameMaxWidth;
    }
    
    UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(65, 14, width, 19)];
    if (@available(iOS 8.2, *)) {
        nameLab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    }else{
        nameLab.font = [UIFont systemFontOfSize:15];
    }
    nameLab.textColor = BLUE_TITLE_COLOR;
    nameLab.text = self.companyDic[@"company"];
    [companyView addSubview:nameLab];
    
    if (![PublicTool isNull:self.companyDic[@"lunci"]]) {
        InsetsLabel *lunciLab = [[InsetsLabel alloc]initWithFrame:CGRectMake(nameLab.right+6, 15, lunciWidth+10, 14)];
        [lunciLab labelWithFontSize:10 textColor:BLUE_TITLE_COLOR cornerRadius:2];
        lunciLab.backgroundColor = LABEL_BG_COLOR;
        lunciLab.text = self.companyDic[@"lunci"];
        lunciLab.centerY = nameLab.centerY;
        [companyView addSubview:lunciLab];
    }
   
    
    UILabel *yewuLab = [[UILabel alloc]initWithFrame:CGRectMake(65, 34, SCREENW-72-115, 17)];
    [yewuLab labelWithFontSize:13 textColor:H6COLOR];
    yewuLab.text = self.companyDic[@"yewu"];
    [companyView addSubview:yewuLab];

    companyView.layer.shadowColor = H9COLOR.CGColor;//shadowColor阴影颜色
    companyView.layer.shadowOpacity = 0.2;//阴影透明度，默认0
    companyView.layer.shadowRadius = 3;//阴影半径，默认3
    companyView.layer.shadowOffset = CGSizeMake(0,0);
    
    //联系创始人
    UILabel *contactLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREENW-17-100, companyView.height/2.0-15,100, 30)];
    contactLab.layer.masksToBounds = YES;
    contactLab.layer.cornerRadius = 15;
    contactLab.backgroundColor = BLUE_TITLE_COLOR;
    [contactLab labelWithFontSize:14 textColor:[UIColor whiteColor]];
    contactLab.text = @"查看项目";
    contactLab.textAlignment = NSTextAlignmentCenter;
    [companyView addSubview:contactLab];

}


- (void)enterCompany{
    
    NSDictionary *urlDict = [PublicTool toGetDictFromStr:self.companyDic[@"detail"]];
    [[AppPageSkipTool shared] appPageSkipToProductDetail:urlDict];
}

- (void)loadURL{
    
    if ([self.urlModel.url hasPrefix:@"http://"]||[self.urlModel.url hasPrefix:@"https://"]) {
        
        NSString *urlStr = [self.urlModel.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (self.fromVC && [self.notEncodeArr containsObject:self.fromVC]) {
            urlStr = self.urlModel.url;
        }
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
        
    }
}

- (void)judgeUrlType{
    
    //    NSString *urlStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)self.urlModel.url, NULL, NULL,  kCFStringEncodingUTF8 ));
    NSString *urlStr = [self.urlModel.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (self.fromVC && [self.notEncodeArr containsObject:self.fromVC]) {
        urlStr = self.urlModel.url;
    }
    if (self.urlModel.urlId && [PublicTool isNull:self.urlModel.type]) {
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:urlStr HTTPBody:nil completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            NSHTTPURLResponse * response = (NSHTTPURLResponse *)dataTask.response;
            NSDictionary * allHeaderDic = response.allHeaderFields;
            NSString *contentType = [allHeaderDic objectForKey:@"Content-Type"];
            if (contentType) {
                BOOL isPdf = [contentType isEqualToString:@"application/pdf"] ? YES :NO;
                
                NSString *type = isPdf ? @"pdf" : @"url";
                [self requestFlagReadUrlofReadStatus:@"1" ofType:type];
            }
        }];
    }
}


- (void)showAlertView{
    [self.view addSubview:self.openPDFView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.openPDFView) {
            [self.openPDFView removeFromSuperview];
        }
    });
}
#pragma mark - Event
- (void)pressOpenPDFButton:(UIButton *)sender {
    [self.openPDFView removeFromSuperview];
    [self judgePdfDownloadAndOpenPDF:self.urlModel];
}
- (void)judgePdfDownloadAndOpenPDF:(URLModel *)urlModel {
    
    NSString *name = [self pdfNameFormDBWithUrl:urlModel.url];
    
    ReportModel *reportModel = [[ReportModel alloc] init];
    reportModel.pdfUrl = urlModel.url;
    reportModel.pdfType = @"";
    reportModel.reportId = @"";
    reportModel.collectFlag = @"0";
    reportModel.fromUrl = YES;
    reportModel.name = name ? name : @"";
    
    OpenDocument *openPDFTool = [[OpenDocument alloc] init];
    openPDFTool.viewController = self;
    openPDFTool.delegate = self;
    
    if (reportModel.name && [openPDFTool downDocumentToBox:reportModel]) { //本地下载了该文档
        [openPDFTool openDocumentofReportModel:reportModel];
    } else {
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        NetworkStatus status = [reach currentReachabilityStatus];
        if (status == ReachableViaWWAN) { // 数据流量
            if (_downloadAlertV) { // 已经开始下载
                _downloadAlertV.isShow = YES;
                [KEYWindow addSubview:_downloadAlertV];
            } else {
                // 未下载弹窗提醒
                [openPDFTool launchReachableViaWWANAlert:status ofCurrentVC:self withModel:reportModel];
            }
        } else {
            [self requestDownloadDocument:reportModel];
        }
    }
}
- (NSString *)pdfNameFormDBWithUrl:(NSString *)url {
    NSString *name = nil;
    if (!_tableName || ![_db open]) {
        return name;
    }
    
    NSString *sql = [NSString stringWithFormat:@"select name from %@ where url='%@'", _tableName, url];
    FMResultSet *rs = [_db executeQuery:sql];
    while ([rs next]) {
        name = [rs stringForColumn:@"name"];
    }
    [_db close];
    return name;
}

- (void)requestDownloadDocument:(ReportModel *)pdfModel{
    
    _downloadAlertV = [DownloadView initFrame];
    _downloadAlertV.delegate = self;
    _downloadAlertV.fromUrl = YES;
    _downloadAlertV.isShow = YES;
    
    [_downloadAlertV initViewWithTitle:@"正在下载" withInfo:@"" withLeftBtnTitle:@"取消" withRightBtnTitle:@"隐藏" withCenter:CGPointMake(SCREENW/2, SCREENH/2) withInfoLblH:40.f ofDocument:pdfModel];
    
    [KEYWindow addSubview:_downloadAlertV];
}

#pragma mark - DownloadViewDelegate
- (void)downloadNewPdfSuccess:(ReportModel *)newPdfModel {
    
    if(_downloadAlertV.isShow){
        // 如果没有被隐藏,则打开pdf
        [self.downloadAlertV removeFromSuperview];
        [self openPDF:newPdfModel];
    }
    self.downloadAlertV = nil;
}

- (void)pressHiddenDownLoad:(ReportModel *)pdfModel {
    
    _downloadAlertV.isShow = NO;
}
- (void)openPDF:(ReportModel *)pdfModel {
    OpenDocument *openPDFTool = [[OpenDocument alloc] init];
    openPDFTool.viewController = self;
    [openPDFTool openDocumentofReportModel:pdfModel];
}
- (void)downloadPdfFromUrlSuccess:(ReportModel *)pdfModel {
    [self.downloadAlertV removeFromSuperview];
    self.downloadAlertV = nil;
    [self openPDF:pdfModel];
}

- (void)requestIsCollectOfUrl:(NSString*)webUrl{
    
    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"d/returnFlagBycollectedClipboard" HTTPBody:@{@"url":self.urlModel.url} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && resultData[@"urlid"]) {
            _collectId = resultData[@"urlid"];
        }
        
    }];
}
#pragma mark --取消收藏url--
- (void)requestCancelCollectofUrlId:(NSString *)urlId ofUrl:(NSString *)urlStr{
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/uncollectClipboard" HTTPBody:@{@"id":urlId} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if ([resultData[@"status"] integerValue] == 0) {
            _collectId = nil;
            [PublicTool showMsg:@"取消收藏成功"];
        }else{
            [PublicTool showMsg:@"取消收藏失败"];
        }
    }];
}

#pragma mark - 请求标记已读/未读接口 并 添加链接的类型
/**
 *  请求标记已读/未读接口
 *
 *  @param indexpath
 *  @param isRead
 */
- (void)requestFlagReadUrlofReadStatus:(NSString *)isRead ofType:(NSString *)type{
    self.urlModel.type = type;
    if ([PublicTool isNull:self.urlModel.urlId]) {
        return;
    }
    if ([TestNetWorkReached networkIsReached:self]) {
        
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/readcollectClipboard" HTTPBody:@{@"isread":isRead,@"id":self.urlModel.urlId,@"type":type} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            if ([resultData[@"status"] integerValue] == 0) {
                if ([self.delegate respondsToSelector:@selector(changeCollectUrlTypeToPdfSuccess:)]) {
                    [self.delegate changeCollectUrlTypeToPdfSuccess:self.urlModel];
                }
            }else{
                
            }
        }];
    }
}

#pragma mark - 请求收藏链接
- (void)requestCollectURL{
    
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    [self requestCollectUrlSuccess:YES];
    
}

- (void)requestCollectUrlSuccess:(BOOL)collect{
    
    NSString *title = self.urlModel.title ? self.urlModel.title : @"";
    
    NSDictionary * parametersDic  = @{@"url":[self.urlModel.url  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"title":title,@"time":self.getNowTimeTool.getDayWithHour,@"isread":@"1"};
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/collectClipboard" HTTPBody:parametersDic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            NSDictionary *dict = resultData;
            NSInteger exist = [dict[@"exist"] integerValue];
            _collectId = dict[@"id"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *infoStr = @"";
                
                if (exist == 0) {
                    infoStr = @"收藏成功";
                    self.urlModel.isCollect = @"1";
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"collectUrlFromNewsWebView" object:self.urlModel];
                }else{
                    infoStr = @"您已收藏过该链接";
                }
                
                [ShowInfo showInfoOnView:self.view withInfo:infoStr];
            });
        }
    }];
}


#pragma mark - OpenDocumentDelegate
- (void)downloadPdfUseWWAN:(ReportModel *)reportModel{
    [self requestDownloadDocument:reportModel];
}

#pragma mark - wkWebView

/**
 >=ios9 WKwebview支持https 信任证书
ios8 自建证书的https链接,不执行该方法
 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
        
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
    
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    QMPLog(@"========start=========");
    self.urlModel.url = webView.URL.absoluteString;
}

//当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    QMPLog(@"========commit=========");
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    QMPLog(@"========fail=========");
    if (error.code==NSURLErrorCancelled) {
        return;
    }
    self.openFailView.hidden = NO;
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {

    if (webView.canGoBack && !_hasClose) {
        _hasClose = YES;
        [self buildLeftBarButtonItem];
    }else{
        _hasClose = NO;
        [self buildLeftBarButtonItem];
    }
    
    if (![PublicTool isNull:webView.title]) {
        self.title = webView.title;
        self.urlModel.title = self.title;
        [self updateTitles];
    }
    //获取不到再执行
    if ([PublicTool isNull:webView.title]) {
        NSString *titleJS = @"document.title";
        
        if ([webView.URL.absoluteString containsString:@"toutiao.com"]) {
            titleJS = @"document.getElementsByClassName('article__title')[0].innerHTML";
        }
        if ([webView.URL.absoluteString containsString:@"mp.weixin.qq.com"]) {
            titleJS = @"document.getElementsByClassName('rich_media_title_ios')[0].innerHTML";
        }
        
        [self.webView evaluateJavaScript:titleJS completionHandler:^(id  retStr, NSError *  error) {
            QMPLog(@"==%@==",retStr);
            if (![PublicTool isNull:retStr]) {
                self.title = (NSString *)retStr;
                
                [self updateTitles];
            }
        }];
    }
    
    
    if (self.action && [self.action isEqualToString:@"urlHistory"]) {
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *openMArr  = [NSMutableArray arrayWithArray:[userDefault objectForKey:@"pasteUrlMArr"]];
        
        for (int i = 0 ; i < openMArr.count;i ++){
            NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithDictionary:openMArr[i]];
            if ([[dataDict objectForKey:@"url"] isEqualToString:self.urlModel.url]) {
                if ([self.urlModel.title isEqualToString:@""]) {
                    
                    [dataDict setValue:self.title forKey:@"title"];
                    [openMArr replaceObjectAtIndex:i withObject:dataDict];
                    
                    [userDefault setObject:openMArr forKey:@"pasteUrlMArr"];
                    [userDefault synchronize];
                    
                    if ([self.delegate respondsToSelector:@selector(changeTitleOfHistory:)]) {
                        [self.delegate changeTitleOfHistory:dataDict];
                    }
                }
            }
        }
    }
    
    
    [self.webView evaluateJavaScript:@"window.location.href" completionHandler:^(id retStr, NSError * _Nullable error) {
        
        NSString *newUrl = (NSString *)retStr;
        if(newUrl && ![newUrl isEqualToString:@""] && ![self.urlModel.url isEqualToString:newUrl]){
            
            URLModel *newUrlModel = [[URLModel alloc] init];
            newUrlModel.title = self.title;
            newUrlModel.url = newUrl;
            self.urlModel = newUrlModel;
        }
        
    }];
    
    //---同花顺查看财务数据,去除多余广告和底部footer molly 170204
    NSString *url = webView.URL.absoluteString;
    if([url hasPrefix:@"http://m.10jqka.com.cn/stockpage/"]){
        //财务信息首页
        
        NSString *jsStr = @"document.getElementsByClassName('hexm-top')[0].style.display='none';document.getElementsByClassName('myad-head')[0].style.display='none';document.getElementById('tohome').style.display='none';document.getElementsByClassName('footer')[0].style.display = 'none';document.getElementsByClassName('main-content')[0].getElementsByTagName('img')[0].style.display = 'none';if(document.getElementById('tj_lungu')){document.getElementById('tj_lungu').parentNode.style.display = 'none';}";
        
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id  retStr, NSError *  error) {
            NSLog(@"==%@==",retStr);
            
        }];
        
    }else if([url hasPrefix:@"http://m.10jqka.com.cn/sn/"]){
        //单条公告新闻
        
        NSString *jsStr = @"var obj = document.getElementsByClassName('main')[0];document.body.innerHTML = '';document.body.appendChild(obj);document.getElementsByClassName('home')[0].style.display = 'none';document.getElementsByClassName('support')[0].style.display = 'none';";
        
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id  retStr, NSError *  error) {
            NSLog(@"==%@==",retStr);
            
        }];
    }else if([url hasPrefix:@"http://m.10jqka.com.cn/"]){
        // 单条新闻
        NSString *jsStr = @"var obj = document.getElementsByClassName('main')[0];if(obj){document.body.innerHTML = '';document.body.appendChild(obj);}var obj1 = document.getElementsByClassName('home')[0];if(obj1){obj1.style.display = 'none';}var obj2 = document.getElementsByClassName('support')[0];if(obj2){obj2.style.display = 'none';}var obj3 = document.getElementsByClassName('page-article')[0];if(obj3){document.body.innerHTML = '';document.body.appendChild(obj3);}";
        
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id  retStr, NSError *  error) {
            NSLog(@"==%@==",retStr);
            
            
        }];
    }else if ([webView.URL.absoluteString containsString:@"pencilnews"]) {
        NSString *jsStr = @"document.getElementsByClassName('_2ZL9y')[0].style.display='none';document.getElementsByClassName('R1uj-')[0].style.display='none'}";
        //        document.getElementById('comment-area').style.display='none';
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id  retStr, NSError *  error) {
            NSLog(@"==%@==",retStr);
        }];
    }

    
    //---该网页暂时无法打开 molly 170204
    self.openFailView.hidden = YES;
    //该网页暂时无法打开 molly 170204 ---
    
    if ([self.urlModel.type isEqualToString:@"pdf"]) {
        [self showAlertView];
    }
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)updateTitles{
    
    if (self.title && self.title.length) {
        self.urlModel.title = self.title;
    }
    
    if (self.urlModel.urlId  && self.urlModel.title) {
        
        NSString *type = self.urlModel.type;
        BOOL isOtherType = [type hasSuffix:@".ppt"] || [type hasSuffix:@".pptx"]|| [type hasSuffix:@".doc"]|| [type hasSuffix:@".docx"]|| [type hasSuffix:@".xls"]|| [type hasSuffix:@".xlsx"]||[type hasPrefix:@".txt"];
        
        if(![PublicTool isNull:self.title] && [ToLogin isLogin] && !isOtherType){
            [self requestUploadTitle:self.title ofUrlId:self.urlModel.urlId];
            
            if ([self.delegate respondsToSelector:@selector(getUrlTitleWithOldModel:)]) {
                self.oldUrlModel.title = self.title;
                [self.delegate getUrlTitleWithOldModel:self.oldUrlModel];
            }
        }
    }
}
#pragma mark - 请求补全标题
- (void)requestUploadTitle:(NSString *)title ofUrlId:(NSString *)urlId{
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/updatecollectTitle" HTTPBody:@{@"id":urlId,@"title":title} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
    }];
}
#pragma mark - 改变进度条进度
// 如果不添加这个，那么wkwebview跳转不了AppStore
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *url = webView.URL.absoluteString;
    
    if ([url hasPrefix:@"https://itunes.apple.com"] || [url hasPrefix:@"itmss://itunes.apple.com/"] || [url hasPrefix:@"itms-apps://itunes.apple.com/"]||[url hasPrefix:@"itms-appss://itunes.apple.com/"]||[url hasPrefix:@"snssdk141://"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
   
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
       
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}

#pragma mark - Getter
- (WKWebView *)webView {
    if (!_webView) {
        _webView =[[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, self.view.height)];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _webView.allowsBackForwardNavigationGestures = YES;// 浏览器内左右滑动,前进后退页面
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _webView;
}
- (UIView *)openFailView {
    if (!_openFailView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
        view.backgroundColor = [UIColor whiteColor];
        view.hidden = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0,
                                                                   self.view.frame.size.width - 20 * 2, self.view.frame.size.height - 400)];
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"该网页无法打开";
        [view addSubview:label];
        
        _openFailView = view;
    }
    return _openFailView;
}
- (UIView *)openPDFView {
    if (!_openPDFView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(-1, 0, SCREENW + 2, 44.f)];
        view.backgroundColor = RGB(255, 241, 220, 1);
        view.layer.masksToBounds = YES;
        [view.layer setBorderColor:RGB(255, 227, 184, 1).CGColor];
        [view.layer setBorderWidth:1.f];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,SCREENW, 44.f)];
        button.center = view.center;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:@"使用\"pdf阅读器\"打开" forState:UIControlStateNormal];
        [button setTitleColor:RGBa(58, 153, 216, 1) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(pressOpenPDFButton:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        _openPDFView = view;
    }
    return _openPDFView;
}
- (ShareTo *)shareToTool {
    if (!_shareToTool) {
        _shareToTool = [[ShareTo alloc] init];
    }
    return _shareToTool;
}
- (GetNowTime *)getNowTimeTool {
    if (!_getNowTimeTool) {
        _getNowTimeTool = [[GetNowTime alloc] init];
    }
    return _getNowTimeTool;
}
- (ManagerHud *)parseHudTool {
    if (!_parseHudTool) {
        _parseHudTool = [[ManagerHud alloc] init];
    }
    return _parseHudTool;
}

- (AlertInfo *)alertTool {
    if (!_alertTool) {
        _alertTool = [[AlertInfo alloc] init];
    }
    return _alertTool;
}
- (GetNowTime *)timeTool {
    if (!_timeTool) {
        _timeTool = [[GetNowTime alloc] init];
    }
    return _timeTool;
}
- (OpenDocument *)openPDFTool {
    if (!_openPDFTool) {
        _openPDFTool = [[OpenDocument alloc] init];
        _openPDFTool.viewController = self;
    }
    return _openPDFTool;
}
- (NSArray *)notEncodeArr {
    if (!_notEncodeArr) {
        _notEncodeArr = @[@"tianyancha",@"baidu"];
    }
    return _notEncodeArr;
}

@end
