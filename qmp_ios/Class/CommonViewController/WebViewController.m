

#import "WebViewController.h"
#import "WXApi.h"

#import "ShowInfo.h"
#import "ManagerHud.h"
#import "Reachability.h"

#import "TestNetWorkReached.h"
#import "ShareTo.h"
#import "LrdOutputView.h"//右上更多选项菜单

//融资日报
#define RONGZIRIBAO_BASE @"http://wx.qimingpian.com/cb/dailyrz.html"
//融资周报
#define RONGZIZHOUBAO_NEWS @"http://wx.qimingpian.com/cb/dailyrz.html?order=week"
//#define RONGZIZHOUBAO_NEWS   @"http://wx.qimingpian.com/cb/dailyrz.html?time=2018.4.2&order=week"

@interface WebViewController ()<UIWebViewDelegate,LrdOutputViewDelegate,ShareDelegate>
{
    UIWebView *_webView;
    NSString *_shareTitle;//分享的title
    NSString *_shareDesc;//描述
    NSString *_shareTimeline;//融资日报 朋友圈
    UIButton *leftButton;
    CGRect _webViewFrame;
    ManagerHud *_hudTool;
}
@property (nonatomic,strong) ShareTo *shareToTool;
@property (nonatomic, strong) LrdOutputView *outputView;//导航条右上角菜单
@property (nonatomic, strong) NSArray *moreOptionsArr;//更多选项
@end

@implementation WebViewController
#define DEBUG_LOG FALSE

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _titleLabStr;
    [self buildWebViewUI];//搭建webView
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _shareTitle = @"";//分享的title
    _shareDesc = @"";//描述
    _shareTimeline = @"";//融资日报 朋友圈
}

//搭建导航条 按钮
-(void)buildRightBarButtonItem{
    
    if (![PublicTool isNull:_titleLabStr]&&([_titleLabStr isEqualToString:@"融资周报"])) {
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = RIGHTNVSPACE;
        UIButton * moreBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
        [moreBtn setImage:[BundleTool imageNamed:@"moreOptions"] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(moreOptions:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreBtn];
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,moreItem];
    }
    
    //融资新闻
    if (![PublicTool isNull:_titleLabStr]&&([_titleLabStr isEqualToString:@"融资日报"])) {
        
        UIButton * weekBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 6, 44, 44)];
        [weekBtn setTitle:@"周报" forState:UIControlStateNormal];
        [weekBtn setTitleColor:NV_OTHERTITLE_COLOR forState:UIControlStateNormal];
        //        weekBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
        weekBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        
        [weekBtn addTarget:self action:@selector(enterRongzizhoubao:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * weekItem = [[UIBarButtonItem alloc] initWithCustomView:weekBtn];
        
        UIButton * moreBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
        [moreBtn setImage:[BundleTool imageNamed:@"moreOptions"] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(moreOptions:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreBtn];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = RIGHTNVSPACE;
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,moreItem,weekItem];
    }
}

- (void)moreOptions:(UIButton *)sender{
    
    CGFloat x = SCREENW - 10;
    CGFloat y = kScreenTopHeight + 10;
    
    //更多选项数据源
    
    if ((![PublicTool isNull:_titleLabStr]&&[_titleLabStr isEqualToString:@"融资日报"])||(![PublicTool isNull:_titleLabStr]&&[_titleLabStr isEqualToString:@"融资周报"])) {
        LrdCellModel *shareModel = [[LrdCellModel alloc] initWithTitle:@"分享" imageName:@"web_share"];
        LrdCellModel *captureScreenModel = [[LrdCellModel alloc] initWithTitle:@"截图分享" imageName:@"captureScreen_more1"];
        LrdCellModel *refreshModel = [[LrdCellModel alloc] initWithTitle:@"刷新" imageName:@"update_more"];
        _moreOptionsArr = @[shareModel,captureScreenModel,refreshModel];
    }
    
    _outputView = [[LrdOutputView alloc] initWithDataArray:_moreOptionsArr origin:CGPointMake(x, y) width:165 height:44 direction:kLrdOutputViewDirectionRight ofAction:@"moreOptions" hasImg:YES];
    
    _outputView.delegate = self;
    _outputView.dismissOperation = ^(){
        //设置成nil，以防内存泄露
        _outputView = nil;
    };
    [_outputView pop];
}
#pragma mark - LrdOutputViewDelegate
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
            
        case 0:{
            [self rongziShare];
            break;
        }
        case 1:{
            _printscreenImage = nil;
            if ([_titleLabStr isEqualToString:@"融资日报"]) {
                [QMPEvent event:@"trz_ribao_screen_share"];
            }else if ([_titleLabStr isEqualToString:@"融资周报"]){
                [QMPEvent event:@"trz_zhoubao_screen_share"];
            }
            [self buildPrintscreenView];
            break;
        }
        case 2:{
            if ([_titleLabStr isEqualToString:@"融资日报"]) {
                [QMPEvent event:@"trz_ribao_refresh"];
            }else if ([_titleLabStr isEqualToString:@"融资周报"]){
                [QMPEvent event:@"trz_zhoubao_refresh"];
            }
            [self refreshPage];
            break;
        }
        default:
            break;
    }
}
#pragma mark - 搭建截图view
- (void)buildPrintscreenView{
    
    if (!_printscreenImage) {
        _webViewFrame = _webView.frame;
        _printscreenImage = [self getCapture:_webView];
        [_webView setFrame:_webViewFrame];
    }
    [self sharePrintScreen];
}

- (void)sharePrintScreen{
    
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        if (_printscreenImage) {
            _printscreenImage = nil;
        }
        return;
    }else{
        [self.shareToTool shareDetailImage:_printscreenImage];
//        [self.shareToTool shareImgToOtherApp:_printscreenImage];
    }
}
#pragma mark - ShareDelegate
- (void)shareSuccess{
    _printscreenImage = nil;
    [ShowInfo showInfoOnView:self.view withInfo:@"分享成功"];
    if ([_titleLabStr isEqualToString:@"融资日报"]) {
    }else if ([_titleLabStr isEqualToString:@"融资周报"]){
    }
}

- (void)shareFaild{
    _printscreenImage = nil;
    [ShowInfo showInfoOnView:self.view withInfo:@"分享取消"];
}

- (UIImage*)getCapture{
    
    CGFloat totalHeight = _webView.scrollView.contentSize.height;
    NSMutableArray *imgArr = [NSMutableArray array];
    NSUInteger totalCount = ceilf(totalHeight/_webView.height);
    for (int i = 0; i < totalCount; i++) {
        [_webView.scrollView setContentOffset:CGPointMake(0, i*_webView.height)];
        if (i == totalCount - 1) {
            UIGraphicsBeginImageContext(CGSizeMake(SCREENW, totalHeight - i*_webView.height));
            CGContextRef context = UIGraphicsGetCurrentContext();
            [_webView.layer renderInContext:context];
        }else{
            UIGraphicsBeginImageContext(_webView.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [_webView.layer renderInContext:context];
        }
        
        UIImage *togetherImage = UIGraphicsGetImageFromCurrentImageContext();
        [imgArr addObject:togetherImage];
        UIGraphicsEndImageContext();

    }
    
    return [self combineImage:imgArr];
    
}

- (UIImage*)combineImage:(NSArray*)imageArr{
    
    UIImage *image = imageArr[0];
    for (int i = 0; i<imageArr.count; i++) {
        if (imageArr.count == 1) {
            image = imageArr[0];
        }else{
            UIImage *bottomImg = imageArr[i+1];
            CGFloat width = image.size.width;
            CGFloat height = image.size.height + bottomImg.size.height;
            CGSize offScreenHeight = CGSizeMake(width, height);
            UIGraphicsBeginImageContextWithOptions(offScreenHeight,NO,0);//scale
            CGRect rect = CGRectMake(0, 0, width, image.size.height);
            [image drawInRect:rect];
            rect.origin.y += image.size.height;
            CGRect rect1 = CGRectMake(0, rect.origin.y, image.size.width, bottomImg.size.height);
            [bottomImg drawInRect:rect1];
            UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            image = img;

        }
        if (i == imageArr.count-2) {
            break;
        }
    }
    
    return image;
}

- (UIImage*)getCapture:(UIView *)view
{
    UIImage *pngImg = nil;
    CGFloat max, scale = 1.0;
    CGSize viewSize = [view bounds].size;
    UIImage *image2 = [BundleTool imageNamed:@"QuickMark"];
    
    // 获取全屏的Size，包含可见部分和不可见部分(滚动部分)
    CGSize size = [view sizeThatFits:CGSizeZero];
    
    max = (viewSize.width > viewSize.height) ? viewSize.width : viewSize.height;
    if( max > 960 )
    {
        scale = 960/max;
    }
    CGFloat imgH = SCREENW/1125 *591;
    CGSize newSize = CGSizeMake(size.width, size.height+imgH);

    if (size.height < 15000) {  //截图过长的内存问题
        UIGraphicsBeginImageContextWithOptions(newSize,view.opaque,0);//scale

    }else{
        UIGraphicsBeginImageContext(newSize);

    }
    [view setFrame: CGRectMake(0, 0, size.width, size.height)];
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    pngImg =UIGraphicsGetImageFromCurrentImageContext();
    [image2 drawInRect:CGRectMake(0, size.height, SCREENW, imgH)];
    UIImage *togetherImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    pngImg = togetherImage;
    return pngImg;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *desc = @"";
    if (error == nil) {
        desc = @"保存相册成功";
    }else{
        desc = @"保存相册失败";
    }
    NSLog(@"-------%@---------", desc);
    
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:desc delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alertView show];
}

-(void)dealloc{
    if (_webView.isLoading) {
        [_webView stopLoading];
    }
    [_webView loadHTMLString:@"" baseURL:nil];
    [_webView stopLoading];
    [_webView setDelegate:nil];
    [_webView removeFromSuperview];
    
    //移除所有监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 更改webview的ua
-(void)updataUserAgent{
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newAgent = [oldAgent stringByAppendingString:@" qmp_ios_v1.0"];
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}

#pragma mark - 融资周报
- (void)enterRongzizhoubao:(UIButton *)sender{
    
    [QMPEvent event:@"trz_ribao_zhoubao_click"];
    
    WebViewController *VC = [[WebViewController alloc]init];
    VC.url = RONGZIZHOUBAO_NEWS;
    VC.titleLabStr = @"融资周报";
    VC.hidesBottomBarWhenPushed = YES;//
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 搭建webView
-(void)buildWebViewUI{
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newAgent = [oldAgent stringByAppendingString:@" qmp_ios"];
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-20-44)];
    _webView.delegate = self;
    
    //设置自动适配屏幕比例
    _webView.scalesPageToFit = YES;
    
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    //加载内容,loadHTMLString用于加载带有标签式的字符串,loadRequest用于加载网址
    if (_url) {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
        
        _hudTool = [[ManagerHud alloc] init];
        [_hudTool addHud:self.view];
    }
    [self.view addSubview:_webView];
    _webView.scrollView.backgroundColor = [UIColor whiteColor];
    _webView.scrollView.mj_header = self.mjHeader;
}

-(void)pullDown{
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
}
#pragma mark - webView的回调
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    [self buildRightBarButtonItem];
    
    //当网页视图被指示载入内容而得到通知。应当返回YES，这样会进行加载。通过导航类型参数可以得到请求发起的原因
    NSURL *requestURL =[request URL];
    NSString *urlStr = [requestURL absoluteString];
    if (navigationType == UIWebViewNavigationTypeReload) {
        return YES;//刷新
    }
    if (([[requestURL scheme] isEqualToString: @"http"]||[[requestURL scheme] isEqualToString: @"https"]||[ [requestURL scheme] isEqualToString: @"mailto"])) {
        
        //判断是否是点击以及点击哪个
        if (![PublicTool isNull:urlStr]) {  //(navigationType == UIWebViewNavigationTypeOther)&&
            
            NSString *str1 = [NSString stringWithFormat:@"%@",@"1.1.1.1/"];//判断是不是h5页内跳转
            NSString *str2 = [NSString stringWithFormat:@"%@",@"iostype=shareinfo"];
            NSString *str3 = [NSString stringWithFormat:@"%@",@"iostype=detailcom"];
            NSString *str4 = [NSString stringWithFormat:@"%@",@"iostype=detailorg"];
            NSString *str5 = [NSString stringWithFormat:@"%@",@"detailorg"];
            NSString *str6 = [NSString stringWithFormat:@"%@",@"detailcom"];
            
            if((([urlStr rangeOfString:str1].location!=NSNotFound)&&([urlStr rangeOfString:str2].location!=NSNotFound))||(([urlStr rangeOfString:str1].location!=NSNotFound)&&([urlStr rangeOfString:str3].location!=NSNotFound))||(([urlStr rangeOfString:str1].location!=NSNotFound)&&([urlStr rangeOfString:str4].location!=NSNotFound))||(([urlStr rangeOfString:str1].location!=NSNotFound)&&([urlStr rangeOfString:str5].location!=NSNotFound))||(([urlStr rangeOfString:str1].location!=NSNotFound)&&([urlStr rangeOfString:str6].location!=NSNotFound))){  //跳到详情页
                
                //判断 是否已经微信登录
                BOOL isLogin = [ToLogin isLogin];
                
                //分享 字符串有@"shareinfo"
                if ([urlStr rangeOfString:str2].location!=NSNotFound) {
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithCapacity:0];
                        NSString *maskStr =@"?";
                        NSArray *arr1 = [urlStr componentsSeparatedByString:maskStr]; //从字符A中分隔成2个元素的数组
                        maskStr = @"&";
                        NSArray *arr2 = [arr1[1] componentsSeparatedByString:maskStr];
                        maskStr = @"=";
                        for (NSString *tmpStr in arr2) {
                            
                            NSArray *arr3 = [tmpStr componentsSeparatedByString:maskStr];
                            [mdict setValue:arr3[1] forKey:arr3[0]];
                        }
                        NSString *tmp1 = mdict[@"title"];
                        NSString *titleStr = [tmp1 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        _shareTitle = [NSString stringWithString:titleStr];
                        NSString *tmp2 = mdict[@"desc"];
                        NSString *descStr = [tmp2 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        _shareDesc = [NSString stringWithString:descStr];
                        
                    });
                }
                
                if (isLogin) { //已登录 跳到详情页
                    
                    //融资周报
                    if (![PublicTool isNull:_titleLabStr]&&([_titleLabStr isEqualToString:@"融资周报"])) {
                        
                        
                        //公司 字符串里有@"detailcom"
                        if ([urlStr rangeOfString:str3].location!=NSNotFound) {
                            
                            [self enterCompany:urlStr];//进入某公司详情
                            return NO;
                        }
                        //机构 字符串有@"detailorg"
                        if ([urlStr rangeOfString:str4].location!=NSNotFound) {
                            
                            [self enterJigou:urlStr];//进入机构详情
                            return NO;
                        }
                        
                        if ([urlStr rangeOfString:str2].location!=NSNotFound) {
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithCapacity:0];
                                NSString *maskStr =@"?";
                                NSArray *arr1 = [urlStr componentsSeparatedByString:maskStr]; //从字符A中分隔成2个元素的数组
                                maskStr = @"&";
                                NSArray *arr2 = [arr1[1] componentsSeparatedByString:maskStr];
                                maskStr = @"=";
                                for (NSString *tmpStr in arr2) {
                                    
                                    NSArray *arr3 = [tmpStr componentsSeparatedByString:maskStr];
                                    [mdict setValue:arr3[1] forKey:arr3[0]];
                                }
                                NSString *tmp1 = mdict[@"title"];
                                NSString *titleStr = [tmp1 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                _shareTitle = [NSString stringWithString:titleStr];
                                NSString *tmp2 = mdict[@"desc"];
                                NSString *descStr = [tmp2 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                _shareDesc = [NSString stringWithString:descStr];
                                NSString *tmp3 = mdict[@"timeline"];
                                NSString *timelineStr = [tmp3 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                _shareTimeline = [NSString stringWithString:timelineStr];
                                
                                NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
                                [tempDic setValue:_shareTitle forKey:@"titleSessionStr"];
                                [tempDic setValue:_shareTimeline forKey:@"titleTimelineStr"];
                                [tempDic setValue:_shareDesc forKey:@"detailStr"];
                                [[NSUserDefaults standardUserDefaults] setObject:tempDic forKey:@"融资周报分享"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                            });
                            return NO;
                        }
                    }
                    
                    //融资新闻
                    if (![PublicTool isNull:_titleLabStr]&&[_titleLabStr isEqualToString:@"融资日报"]) {
                        
                        //分享 字符串有@"shareinfo"
                        if ([urlStr rangeOfString:str2].location!=NSNotFound) {
                            NSLog(@"========融资新闻:%@",urlStr);
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithCapacity:0];
                                NSString *maskStr =@"?";
                                NSArray *arr1 = [urlStr componentsSeparatedByString:maskStr]; //从字符A中分隔成2个元素的数组
                                maskStr = @"&";
                                NSArray *arr2 = [arr1[1] componentsSeparatedByString:maskStr];
                                maskStr = @"=";
                                for (NSString *tmpStr in arr2) {
                                    
                                    NSArray *arr3 = [tmpStr componentsSeparatedByString:maskStr];
                                    [mdict setValue:arr3[1] forKey:arr3[0]];
                                }
                                NSString *tmp1 = mdict[@"title"];
                                NSString *titleStr = [tmp1 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                _shareTitle = [NSString stringWithString:titleStr];
                                NSString *tmp2 = mdict[@"desc"];
                                NSString *descStr = [tmp2 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                _shareDesc = [NSString stringWithString:descStr];
                                NSString *tmp3 = mdict[@"timeline"];
                                NSString *timelineStr = [tmp3 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                _shareTimeline = [NSString stringWithString:timelineStr];
                                
                                NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
                                [tempDic setValue:_shareTitle forKey:@"titleSessionStr"];
                                [tempDic setValue:_shareTimeline forKey:@"titleTimelineStr"];
                                [tempDic setValue:_shareDesc forKey:@"detailStr"];
                                [[NSUserDefaults standardUserDefaults] setObject:tempDic forKey:@"融资日报分享"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                            });
                            return NO;
                        }
                        //公司 字符串里有@""
                        if ([urlStr rangeOfString:str3].location!=NSNotFound) {
                            
                            [self enterCompany:urlStr];//进入某公司详情
                            return NO;
                        }
                        //机构 字符串有@""
                        if ([urlStr rangeOfString:str4].location!=NSNotFound) {
                            
                            [self enterJigou:urlStr];//进入机构详情
                            return NO;
                        }
                    }
                }else{ //未登录 提示用户登录
                    NSLog(@"用户未登录,需要登录--%s",__FUNCTION__);
                    //                    [self setupAlertController];//不弹提示了
                    
                    if (([urlStr rangeOfString:str1].location!=NSNotFound)&&([urlStr rangeOfString:str2].location!=NSNotFound)) {
                        return NO;
                    }
                    
                    if (![WXApi isWXAppInstalled]) { //检查微信是否已被用户安装,微信已安装返回YES
                        //                        [_toLoginTool setupWXAlert:self];//弹出安装微信弹出框
                    }else{
                        //判断网络连接状态
                        if ([TestNetWorkReached networkIsReached:self]) {
                            [ToLogin enterLoginPage:self];//进入登录页
                        }
                    }
                    //登录成功提示..
                }
            }else
                return YES;
        }else
            return NO;
    }else
        return NO;
    
    return NO;
}

- (ShareTo *)shareToTool{
    
    if (!_shareToTool) {
        _shareToTool = [[ShareTo alloc] init];
        _shareToTool.delegate = self;
    }
    return _shareToTool;
}
#pragma mark - 分享
-(void)rongziShare{
    
    if (![TestNetWorkReached networkIsReached:self]) {
        
        return;
    }else{
        if (![WXApi isWXAppInstalled]) { //检查微信是否已被用户安装,微信已安装返回YES
            //没安装则提示
            //            [_toLoginTool setupWXAlert:self];//弹出提示框
            return;
        }else{
            
            if ([_titleLabStr isEqualToString:@"融资周报"]) {
                //融资周报分享
                [QMPEvent event:@"trz_zhoubao_share"];

                NSDictionary *shareDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"融资周报分享"];
                NSString *titleSessionStr = [shareDic objectForKey:@"titleSessionStr"];
                NSString* titleTimelineStr = [shareDic objectForKey:@"titleTimelineStr"];
                NSString *detailStr = [shareDic objectForKey:@"detailStr"];
                
                [self.shareToTool shareToOtherApp:detailStr aTitleSessionStr:titleSessionStr aTitleTimelineStr:titleTimelineStr aIcon:[BundleTool imageNamed:@"share_ribao"] aOpenUrl:_url onViewController:self shareResult:^(BOOL shareSuccess) {
                    if (shareSuccess) {
                        NSString *type = @"融资周报分享";
                        NSDictionary *dict = @{@"type" : type};
                    }
                }];
                
                
            }
            
            if ([_titleLabStr isEqualToString:@"融资日报"]) {
                [QMPEvent event:@"trz_ribao_share"];
                //融资日报分享
                NSDictionary *shareDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"融资日报分享"];
                NSString *titleSessionStr = [shareDic objectForKey:@"titleSessionStr"];
                NSString* titleTimelineStr = [shareDic objectForKey:@"titleTimelineStr"];
                NSString *detailStr = [shareDic objectForKey:@"detailStr"];
                
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img.798youxi.com/product/upload/57d4167d97eef.png"]];
                UIImage *img = [UIImage imageWithData:data];
                [self.shareToTool shareToOtherApp:detailStr aTitleSessionStr:titleSessionStr aTitleTimelineStr:titleTimelineStr aIcon:img aOpenUrl:_url onViewController:self shareResult:^(BOOL shareSuccess) {
                    if (shareSuccess) {
                        //umeng统计 融资新闻分享
                        NSString *type = @"融资日报分享";
                        
                        NSDictionary *dict = @{@"type" : type};
                    }
                }];
                
            }
        }
    }
}

#pragma mark - 设置弹出提示语
- (void)setupAlertController {
    //ios8之前
    if (IOS_VERSION<8.0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请先微信登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先微信登录" preferredStyle:UIAlertControllerStyleAlert];
        NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
        NSString *otherButtonTitle = NSLocalizedString(@"确定", nil);
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //点击确定按钮
            if (![WXApi isWXAppInstalled]) { //检查微信是否已被用户安装,微信已安装返回YES
                //                [_toLoginTool setupWXAlert:self];//弹出安装微信弹出框
            }else{
                //判断网络连接状态
                if (![TestNetWorkReached networkIsReached:self]) {
                    return;
                }else{
                    [ToLogin enterLoginPage:self];//进入登录页
                }
            }
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:otherAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
//用户点击确定按钮
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ((long)buttonIndex == 1) {
        if (![WXApi isWXAppInstalled]) { //检查微信是否已被用户安装,微信已安装返回YES
            //            [_toLoginTool setupWXAlert:self];//弹出安装微信弹出框
        }else{
            //判断网络连接状态
            if (![TestNetWorkReached networkIsReached:self]) {
                return;
            }else{
                [ToLogin  enterLoginPage:self];//进入登录页
            }
        }
    }
}

#pragma mark - 请求加载中发生错误
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    //当在请求加载中发生错误时，得到通知。会提供一个NSSError对象，以标识所发生错误类型。
    if (_hudTool) {
        [_hudTool removeHud];
    }
    [self.mjHeader endRefreshing];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.mjHeader endRefreshing];
    
    if (_hudTool) {
        [_hudTool removeHud];
    }
}

#pragma mark - 进入某公司详情
-(void)enterCompany:(NSString *)urlStr{
    
    /* 国内
     http://wx.qimingpian.com/detailcom.html?src=magic&ticket=%E6%89%AC%E5%B7%9E%E5%B8%82%E7%99%BE%E4%BF%A1%E7%BC%98%E5%8C%BB%E8%8D%AF%E8%BF%9E%E9%94%81%E6%9C%89%E9%99%90%E5%85%AC%E5%8F%B8&id=e3c384fe8a4fec0591d972835e99ba0d&p=%E6%89%AC%E5%B7%9E%E7%99%BE%E4%BF%A1%E7%BC%98&subtb=r
     */
    /* 国外
     hrttp://wx.qimingpian.com/detailcom.html?src=magic&ticket=Nestor&id=044b3ea607f31852a2cc291bce9af90c&p=Nestor&subtb=r
     */
    //提取 src ticket id p
    NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *maskStr =@"?";
    NSArray *arr1 = [urlStr componentsSeparatedByString:maskStr]; //从字符A中分隔成2个元素的数组
    maskStr = @"&";
    NSArray *arr2 = [arr1[1] componentsSeparatedByString:maskStr];
    maskStr = @"=";
    for (NSString *tmpStr in arr2) {
        
        NSArray *arr3 = [tmpStr componentsSeparatedByString:maskStr];
        [mdict setValue:arr3[1] forKey:arr3[0]];
    }
    
    NSDictionary *urlDict = [NSDictionary dictionaryWithDictionary:mdict];
//    ProductDetailsController *detailVC = [[ProductDetailsController alloc]init];
//    detailVC.urlDict = urlDict;//传过去url参数
//    detailVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:detailVC animated:YES];
}
#pragma mark - 进入机构详情
-(void)enterJigou:(NSString *)urlStr{
    
    //提取 ticket id
//    NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithCapacity:0];
//    NSString *maskStr =@"?";
//    NSArray *arr1 = [urlStr componentsSeparatedByString:maskStr]; //从字符A中分隔成2个元素的数组
//    maskStr = @"&";
//    NSArray *arr2 = [arr1[1] componentsSeparatedByString:maskStr];
//    maskStr = @"=";
//    for (NSString *tmpStr in arr2) {
//
//        NSArray *arr3 = [tmpStr componentsSeparatedByString:maskStr];
//        [mdict setObject:arr3[1] forKey:arr3[0]];
//    }
//
//    NSDictionary *urlDict = [NSDictionary dictionaryWithDictionary:mdict];
//    OrganizeDetailViewController *jigouDetailVC = [[OrganizeDetailViewController alloc]init];
//    jigouDetailVC.urlDict = urlDict;//传过去url参数
//
//    //显示导航条
//    self.navigationController.navigationBarHidden = NO;
//    //修改 "< 返回" 按钮
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        jigouDetailVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:jigouDetailVC animated:YES];
//    });
}

#pragma mark - 刷新页面
-(void)refreshPage{
    //    js方法名＋参数
    NSString* jsCode = [NSString stringWithFormat:@"qmpUpdate('%@')",@""];
    //调用html页面的js方法
    [_webView stringByEvaluatingJavaScriptFromString:jsCode];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
