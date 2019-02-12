//
//  BaseWebViewController.m
//  qmp_ios
//
//  Created by Molly on 16/9/11.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "BaseWebViewController.h"
#import "ReportModel.h"
#import "GetNowTime.h"
#import "AlertInfo.h"

#define MainColor  UIColorFromRGB(0x1FB5EC)
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface BaseWebViewController ()<WKUIDelegate,WKNavigationDelegate>{

    BOOL _showNotOpen;

}

@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIView *infoView;
@property (weak, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UIButton *backBtn;

@property (strong, nonatomic) AlertInfo *alertTool;
@property (strong, nonatomic) GetNowTime *timeTool;

@end

@implementation BaseWebViewController

- (instancetype)initWithUrlModel:(URLModel *)urlModel{
    if (self = [super init] ) {
        self.urlModel = urlModel;
    }
    return self;
}
- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    [self clearCaches];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initProgress];

    [self initWKWebView];
    
    [self loadURL];
    [self initInfoLbl];
    [self addBottomViewButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
#pragma mark - 
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
    QMPLog(@"========start=========");
    _showNotOpen = NO;
    
    dispatch_queue_t otherQueue = dispatch_queue_create("getNowStatus", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(otherQueue, ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:webView.URL];
        NSHTTPURLResponse *response = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        QMPLog(@"  code :%ld",(long)response.statusCode);
        if (response.statusCode == 0){
            _showNotOpen = YES;
            QMPLog(@"========start: 0=========");
        }
        else if (response.statusCode == 404){
            // 这里处理 404 代码
            QMPLog(@"========start: 404=========");
        } else if (response.statusCode == 403) {
            // 这里处理 403 代码
        } else {
            
            //post请求
            QMPLog(@"========start: post success =========");
            
            //        [webView loadData:data MIMEType:@"text/html" textEncodingName:@"NSUTF8StringEncoding" baseURL:];
       }
        
    });
    
    [self.hudTool removeHud];
    
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    QMPLog(@"========fail=========");
    //--该网页暂时无法打开 molly 170204
    self.infoView.hidden = !_showNotOpen;
    //该网页暂时无法打开 molly 170204 ---
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
    if([self.feedbackFlag isEqualToString:@"1"]&&[self.myWKWebView canGoBack]){
        self.bottomView.hidden = NO;
    }else if ([self.feedbackFlag isEqualToString:@"1"]&&![self.myWKWebView canGoBack]){
        self.bottomView.hidden = YES;
    }

    self.infoView.hidden = YES;

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

#pragma mark - public
- (void)initProgress{
    // 进度条
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0.1, self.view.frame.size.width, 0)];
    progressView.tintColor = MainColor;
    progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:progressView];
    self.progressView = progressView;
}
- (void)initInfoLbl{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    view.backgroundColor = [UIColor whiteColor];
    view.hidden = YES;
    [self.view addSubview:view];
    self.infoView = view;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width - 20 * 2, self.view.frame.size.height - 400)];
    lbl.textColor = [UIColor lightGrayColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = @"该网页无法打开";
    [view addSubview:lbl];
}

- (void)clearCaches{
    
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Caches/WebKit"];
    [self delCaches:cookiesFolderPath];
    
}
- (void)delCaches:(NSString *)path{
    
    NSFileManager *fileM = [NSFileManager defaultManager];
    
    if ([fileM fileExistsAtPath:path]) {
        //path文件存在 删除
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

- (void)initWKWebView{
    //appDelegate里设置ua就可以了
    self.myWKWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    
    self.myWKWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.myWKWebView.allowsBackForwardNavigationGestures = YES;// 浏览器内左右滑动,前进后退页面
    
    [self.myWKWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    self.myWKWebView.UIDelegate = self;
    self.myWKWebView.navigationDelegate = self;
    
    //    [self.view addSubview:self.myWKWebView];
    [self.view insertSubview:self.myWKWebView belowSubview:self.progressView];
    
}

- (void)addBottomViewButtons {
    
    // 添加按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button setBackgroundImage:[UIImage imageNamed:@"backback"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:249 / 255.0 green:102 / 255.0 blue:129 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [button addTarget:self action:@selector(onBottomButtonsClicled:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:button];
    self.backBtn = button;
    
    self.bottomView.hidden = YES;
}

- (void)onBottomButtonsClicled:(UIButton *)sender {
    [self goBack];
}

- (void)loadURL{
    
    if ([self.urlModel.url hasPrefix:@"http://"]||[self.urlModel.url hasPrefix:@"https://"]) {
        
        [self.myWKWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlModel.url]]];
        
        [self.hudTool addHud:self.view];
    }else{
        
    }
}

- (void)popToPre{
    
    if(![self.myWKWebView canGoBack]){
        
        [self.myWKWebView stopLoading];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void)goBack{
    
    
    if(_showNotOpen){
        
        self.infoView.hidden = YES;
        _showNotOpen = NO;
        
    }
    if([self.myWKWebView canGoBack] ){
        //可以向前,同时没有显示该网页无法打开
        [self.myWKWebView goBack];
        
    }
    else if(![self.myWKWebView canGoBack]){
        
        //不能再向前,同时没有显示该网页暂时无法打开
        [self.myWKWebView stopLoading];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}

#pragma mark - 懒加载
- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, SCREENH-44-kScreenTopHeight-40-40, kScreenTopHeight, 44)];
        //        view.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        [self.view addSubview:view];
        _bottomView = view;
    }
    return _bottomView;
}

- (ManagerHud *)hudTool{

    if (!_hudTool) {
        _hudTool = [[ManagerHud alloc] init];
    }
    return _hudTool;
}

- (AlertInfo *)alertTool{

    if (!_alertTool) {
        _alertTool = [[AlertInfo alloc] init];
    }
    return _alertTool;
}


- (GetNowTime *)timeTool{

    if (!_timeTool) {
        _timeTool = [[GetNowTime alloc] init];
    }
    return _timeTool;
}
@end
