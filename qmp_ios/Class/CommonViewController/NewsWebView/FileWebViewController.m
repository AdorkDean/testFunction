//
//  FileWebViewController.m
//  qmp_ios
//
//  Created by Molly on 2016/11/4.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "FileWebViewController.h"
#import "LrdOutputView.h"
#import "UploadView.h"

#import "ShareTo.h"
#import "GetNowTime.h"

 
 

#define MainColor  UIColorFromRGB(0x1FB5EC)
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface FileWebViewController ()<LrdOutputViewDelegate,WKUIDelegate,WKNavigationDelegate,UploadViewDelegate>

@property (strong, nonatomic)LrdCellModel *collectModel;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UploadView *uploadView;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSURLSessionDataTask *task;

@property (strong, nonatomic) ShareTo *shareToTool;
@property (strong, nonatomic) ManagerHud *infoTool;
@property (strong, nonatomic) GetNowTime *getNowTimeTool;
@property (nonatomic, assign) BOOL isVwLoad;
@end

@implementation FileWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isVwLoad = NO;
    [self buildUI];
    [self loadFile];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.deleage respondsToSelector:@selector(changeNoPdfCollectionStatusByClick:)]) {
        [self.deleage changeNoPdfCollectionStatusByClick:_reportModel];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self clearCaches];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 改变进度条进度

// 如果不添加这个，那么wkwebview跳转不了AppStore
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([webView.URL.absoluteString hasPrefix:@"https://itunes.apple.com"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.myWKWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
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

// 记得取消监听
- (void)dealloc {
    [self.myWKWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark - LrdOutputViewDelegate
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath{
 
    switch (indexPath.row) {
        case 0:{
            [self onShare];
            break;
        }
        case 1:{
            
            if ([_reportModel.collectFlag isEqualToString:@"禁止收藏"] || [PublicTool isNull:self.fileItem.fileId]) {
                [self onOpen];
            }else{
                [self onCollect];
            }
            
            break;
        }
        case 2:{
            [self onOpen];
            break;
        }
        default:
            break;
    }
}


#pragma mark - public
- (void)buildUI{
    
    self.navigationItem.title = self.fileItem.fileName ? [self.fileItem.fileName stringByDeletingPathExtension]:@"";
    
    [self buildRightBarButtonItem];
    [self buildLeftBarButtonItem];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initProgress];
    [self initWKWebView];
}

- (void)buildLeftBarButtonItem{
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:LEFTBUTTONFRAME];
    [leftButton setImage:[BundleTool imageNamed:@"left-arrow"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(pressLeftButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = LEFTNVSPACE;
    if (iOS11_OR_HIGHER) {
        leftButton.width = 30;
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0);
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        self.navigationItem.leftBarButtonItems = @[leftButtonItem];
    }else{
        self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftButtonItem];
        
    }
    
}

- (void)pressLeftButtonItem:(id)sender{
    
    [self goBack];
}

- (void)goBack{
    
    if([self.myWKWebView canGoBack]){
        [self.myWKWebView goBack];
    }
    else{
        
        [self.myWKWebView stopLoading];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void)buildRightBarButtonItem{
    
    UIButton * moreBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
    [moreBtn setImage:[BundleTool imageNamed:@"moreOptions"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreOptions:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = RIGHTNVSPACE;
    
    if (iOS11_OR_HIGHER) {
        
        moreBtn.width = 30;
        moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
        
        self.navigationItem.rightBarButtonItems = @[buttonItem];
        
    }else{
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,moreItem];
    }

}

- (void)moreOptions:(UIButton *)sender{
    CGFloat x = SCREENW - 10;
    CGFloat y = sender.frame.origin.y + sender.bounds.size.height + 30;
    
    LrdCellModel *sharModel = [[LrdCellModel alloc] initWithTitle:@"分享" imageName:@"web_share"];
    LrdCellModel *openModel = [[LrdCellModel alloc] initWithTitle:@"使用Safari打开" imageName:@"safari"];
    NSArray *moreOptionsArr;
    if ([_reportModel.collectFlag isEqualToString:@"禁止收藏"] || [PublicTool isNull:self.fileItem.fileId]) {
        moreOptionsArr  = @[sharModel,openModel];
    }else{
        NSString *titleStr = [_collect_flag_status integerValue] ? @"已收藏":@"收藏";
        NSString *imgStr = [_collect_flag_status integerValue] ? @"web_iscollect":@"collect-url";
        _collectModel = [[LrdCellModel alloc] initWithTitle:titleStr imageName:imgStr];
        moreOptionsArr  = @[sharModel,_collectModel,openModel];
    }
    
    __block LrdOutputView *outputView = [[LrdOutputView alloc] initWithDataArray:moreOptionsArr origin:CGPointMake(x, y) width:200 height:44 direction:kLrdOutputViewDirectionRight hasImg:YES];
    
    outputView.delegate = self;
    outputView.dismissOperation = ^(){
        //设置成nil，以防内存泄露
        outputView = nil;
    };
    [outputView pop];
    
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
    NSString *userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *executableFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    NSString *ua = [NSString stringWithFormat:@"%@/%@/%@",userAgent,executableFile,version];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":ua, @"User-Agent": ua}];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    [configuration setApplicationNameForUserAgent:ua];
    self.myWKWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    self.myWKWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.myWKWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    self.myWKWebView.UIDelegate = self;
    self.myWKWebView.navigationDelegate = self;
    
    [self.view insertSubview:self.myWKWebView belowSubview:self.progressView];
    
}

- (void)clearCaches{
    
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

- (BOOL)hasDocumentOnLoacal:(NSString *)filename{
    
    //判断本地是否存在该文档
    NSString *tmp = [self findFileWithPath:[self getPath] fileName:filename];
    
    if (!tmp) {
        
        return NO;
    }else{
        
        return YES;
    }
}

- (NSString *)getPath{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    return path;
}

- (NSString *)findFileWithPath:(NSString *)path fileName:(NSString *)name{
    
    NSFileManager *filem = [NSFileManager defaultManager];
    if ([filem fileExistsAtPath:path]) {
        
        //获取文件夹下所有文件
        NSArray *fileArr = [filem subpathsAtPath:path];
        for (NSString *fileName in fileArr) {
            if ([fileName isEqualToString:[name lastPathComponent]]) {
                return fileName;
            }
        }
        return nil;
    }
    return nil;
}

- (void)loadFile{
    
    if ([self hasDocumentOnLoacal:self.fileItem.fileName]) {
        self.filePath = [[NSArray arrayWithObjects:NSHomeDirectory(),@"Documents", self.fileItem.fileName,nil] componentsJoinedByString:@"/"];
        
        QMPLog(@"----filePath : %@-------",self.filePath);
        
        NSURL *fileUrl = [NSURL fileURLWithPath:self.filePath];
        
        [self.myWKWebView loadFileURL:fileUrl allowingReadAccessToURL:fileUrl];
    }
    else{
        
        [self.myWKWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.fileItem.fileUrl]]];
    }
}

- (void)onShare{
    if (self.fileItem.fileUrl) {
        
        [self shareURL];
    }
    else{
        
        //如果为空说明直接打开的PPT文件,则在分享前需要先上传
        [self requestUploadFileOnAction:@"share"];
    }
    
}

- (void)onCollect{
    if (self.fileItem.fileUrl) {
        
        [self colletFileUrl];
        
    }
    else{
        
        //如果为空说明直接打开的PPT文件,则在收藏前需要先上传
        [self requestUploadFileOnAction:@"collect"];
    }
    
}

- (void)onOpen{
    if (self.fileItem.fileUrl) {
        
        [self openWithSafari];
    }
    else{
        
        //如果为空说明直接打开的PPT文件,则在打开前需要先上传
        [self requestUploadFileOnAction:@"open"];
    }
    
}

-(void)shareURL{
    
    NSString *titleStr = [NSString stringWithFormat:@"%@",self.fileItem.fileName];
    
    NSString *detailStr = @"看文件就用@企名片";
    
    [self.shareToTool shareToOtherApp:detailStr aTitleSessionStr:titleStr aTitleTimelineStr:titleStr aIcon:[BundleTool imageNamed:@"share_news"] aOpenUrl:self.fileItem.fileUrl onViewController:self shareResult:^(BOOL shareSuccess) {
        if (shareSuccess) {
        }
    }];
    
}

/**
 * 使用Safari打开
 */
- (void)openWithSafari{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.fileItem.fileUrl]];
}

#pragma mark - 请求收藏该文件
- (void)colletFileUrl{
    
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    if ([TestNetWorkReached networkIsReached:self]) {
        
        NSString *path = self.fileItem.fileUrl;
        NSString *type = @"";
        
        if ([path hasSuffix:@".ppt"] || [path hasSuffix:@".pptx"]) {
            type = @"ppt";
        }else if ( [path hasSuffix:@".doc"]|| [path hasSuffix:@".docx"]){
            type = @"doc";
        }else if ( [path hasSuffix:@".xls"]|| [path hasSuffix:@".xlsx"]){
            type = @"excel";
        }else if ( [path hasSuffix:@".txt"]){
            type = @"txt";
        }else if ([path hasSuffix:@".pdf"] || [path hasSuffix:@".PDF"]){
            type = @"pdf";
        }
        
        NSString * collectStr;
        if (_collect_flag_status.integerValue == 1) {
            collectStr = @"0";
        }else if(_collect_flag_status.integerValue == 0){
            collectStr = @"1";
        }else{
            collectStr = @"1";
        }
        NSString *fileType = ![PublicTool isNull:self.fileItem.fileType] ? self.fileItem.fileType : @"selfcloudcollect";
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"l/collectpdf" HTTPBody:@{@"fileid":self.fileItem.fileId?:@"",@"filetype":fileType,@"collect":collectStr,@"fileext":type} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            NSString *infoStr = @"";
            NSString *message = [resultData objectForKey:@"message"];
            if ([message isEqualToString:@"success"]) {
                NSString *repeat = [NSString stringWithFormat:@"%@",[resultData objectForKey:@"repeat"]];
                if ([repeat isEqualToString:@"1"]||[repeat isEqualToString:@"0"]) {
                    infoStr = @"收藏成功";
                    _collect_flag_status = @"1";
                    [self collectThisTarget];
                }else if ([repeat isEqualToString:@"3"]) {
                    infoStr = @"已经收藏";
                    _collect_flag_status = @"1";
                    [self collectThisTarget];
                }else if ([repeat isEqualToString:@"2"]) {//取消收藏
                    _collect_flag_status = @"0";
                    infoStr = @"取消收藏";
                    [self cancelCollectTarget];
                }else{
                    infoStr = @"操作异常,请重试";
                }
            }else{
                infoStr = @"收藏失败,请重试";
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.infoTool showHudOnViewAutoHide:self.view withInfo:infoStr];
            });
            
        }];
    }
}
- (void)cancelCollectTarget{
    _collectModel.title = @"收藏";
    _collectModel.imageName = @"collect";
    _reportModel.collectFlag = @"0";
}
- (void)collectThisTarget{
    _collectModel.title = @"已收藏";
    _collectModel.imageName = @"web_iscollect";
    _reportModel.collectFlag = @"1";
}
#pragma mark - 请求上传 目前逻辑没用
- (void) requestUploadFileOnAction:(NSString *)action{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        
        _uploadView = [UploadView initFrame];
        _uploadView.delegate = self;
        [_uploadView initData];
        [KEYWindow addSubview:_uploadView];

        
        //待验证
        [[NetworkManager sharedMgr] uploadFileWithUrl:@"t/webuploader1" filePath:self.filePath fileName:self.fileItem.fileName fileKey:@"file" params:@{@"upload_type":@"cloud"} progress:^(CGFloat progress) {
            [_uploadView changeProgressWithProgress:progress];
        } completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [_uploadView removeFromSuperview];
            _uploadView = nil;
            
            if (resultData) {
                NSDictionary *dataDict = resultData;
                NSString *uploadStatus = @"";
                uploadStatus = [dataDict objectForKey:@"upload_status"];
                if ([uploadStatus isEqualToString:@"success"]||[uploadStatus isEqualToString:@"repeat"]) {
                    
                    NSDictionary *itemDict = [dataDict objectForKey:@"item"];
                    
                    self.fileItem.fileId =  [itemDict objectForKey:@"id"];
                    self.fileItem.fileUrl = [itemDict objectForKey:@"url"];
                    
                    if ([action isEqualToString:@"collect"]) {
                        [self colletFileUrl];
                    }
                    else if([action isEqualToString:@"share"]){
                        
                        [self shareURL];
                    }
                    else if([action isEqualToString:@"open"]){
                        
                        [self openWithSafari];
                    }
                }
            }
            
        }];
        
    }
}
#pragma mark - UploadViewDelegate
- (void)pressCancleDownLoad{
    [_uploadView removeFromSuperview];
    _uploadView = nil;
    
    [_task cancel];
    _task = nil;
}

#pragma mark - 懒加载
- (ShareTo *)shareToTool{
    
    if (!_shareToTool) {
        _shareToTool = [[ShareTo alloc] init];
    }
    return _shareToTool;
}

- (GetNowTime *)getNowTimeTool{
    
    if (!_getNowTimeTool) {
        _getNowTimeTool = [[GetNowTime alloc] init];
    }
    
    return _getNowTimeTool;
}

- (ManagerHud *)infoTool{
    
    if (!_infoTool) {
        _infoTool = [[ManagerHud alloc] init];
    }
    return _infoTool;
}

@end
