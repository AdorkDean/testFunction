//
//  PrivatePolicyView.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/10/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PrivatePolicyView.h"

@interface PrivatePolicyView()<WKNavigationDelegate>
{
    WKWebView *_webView;
}
@end


@implementation PrivatePolicyView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addViews];
    }
    return self;
}

+ (void)showPolicyView{
    PrivatePolicyView *view = [[PrivatePolicyView alloc]initWithFrame:KEYWindow.bounds];
    [KEYWindow addSubview:view];
}

- (void)addViews{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _webView = [[WKWebView alloc]initWithFrame:CGRectMake(30, 98, SCREENW - 60, SCREENH - 260)];
    _webView.layer.cornerRadius = 4;
    _webView.layer.masksToBounds = YES;
    _webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 25, 0);
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    _webView.navigationDelegate = self;
    _webView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_webView];
    NSString *urlStr = @"http://wx.qimingpian.com/policyqmp.html?f=qmpapp";
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, _webView.bottom+53, 45, 45)];
    [closeBtn setImage:[UIImage imageNamed:@"close_whitebg"] forState:UIControlStateNormal];
    [self addSubview:closeBtn];
    closeBtn.centerX = SCREENW/2.0;
    [closeBtn addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
}



#pragma mark --
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //修改字体大小 300%
    [ webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '85%'" completionHandler:nil];
    
    //修改字体颜色  #9098b8
    [ webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= '#737782'" completionHandler:nil];
    
}


@end
