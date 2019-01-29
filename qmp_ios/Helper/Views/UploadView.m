//
//  UploadView.m
//  qmp_ios
//
//  Created by Molly on 2017/1/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "UploadView.h"
@interface UploadView()

@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UILabel *progressLbl;
@property (strong, nonatomic) UIView *hudView;

@end
@implementation UploadView

+(instancetype)initFrame{
    
    UploadView *alertView = [[UploadView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    [alertView initView];
   
    return alertView;
}
+ (instancetype)initFrameWithInfo:(NSString *)info{
    
    UploadView *alertView = [[UploadView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    [alertView initViewWithInfo:info];
    
    return alertView;
}

- (void)initViewWithInfo:(NSString *)info{
    
    UIView *backgroudView = [[UIView alloc] initWithFrame:self.frame];
    [backgroudView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
    [self addSubview:backgroudView];
    
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 250, 160)];
    alertView.center = CGPointMake(SCREENW/2, SCREENH/2);
    alertView.layer.masksToBounds = YES;
    alertView.layer.cornerRadius = 10.f;
    alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:alertView];
    
    CGFloat width = alertView.frame.size.width;
    CGFloat height = alertView.frame.size.height;
    
    CGFloat margin = 10.f;
    UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(margin, 17 , width - 2 * margin, 40.f)];
    infoLbl.text = info;
    infoLbl.textColor = [UIColor blackColor];
    infoLbl.textAlignment = NSTextAlignmentCenter;
    infoLbl.font = [UIFont systemFontOfSize:15.f];
    infoLbl.numberOfLines = 0;
    infoLbl.lineBreakMode = NSLineBreakByWordWrapping;
    [alertView addSubview:infoLbl];

    CGFloat hudW = 200.f;
    UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake((width - hudW)/2, infoLbl.top + infoLbl.height + 8, hudW, 50)];
    hudView.backgroundColor  = [UIColor clearColor];
    [alertView addSubview:hudView];
    self.hudView = hudView;
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.hudView.frame.size.width, 3)];
    self.progressView.layer.borderColor = RGBa(58, 153, 216, 1).CGColor;
    self.progressView.layer.borderWidth = 0.5f;
    self.progressView.tintColor = RGBa(58, 153, 216, 1);
    self.progressView.trackTintColor = [UIColor whiteColor];
    [self.hudView addSubview:self.progressView];
    
    self.progressLbl = [[UILabel alloc] initWithFrame: CGRectMake(0, 13, self.hudView.frame.size.width, 20.f)];
    self.progressLbl.textColor = [UIColor grayColor];
    self.progressLbl.textAlignment = NSTextAlignmentCenter;
    self.progressLbl.font = [UIFont systemFontOfSize:16.f];
    [self.hudView addSubview:self.progressLbl];
    
    UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, self.hudView.frame.origin.y + self.hudView.frame.size.height, width, 1)];
    rowView.backgroundColor = RGB(244, 244, 244, 1);
    [alertView addSubview:rowView];
    
    CGFloat btnY = rowView.frame.origin.y + rowView.frame.size.height;
    CGFloat btnH = height - btnY;
    CGFloat btnW = width ;
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake( 0, btnY, btnW , btnH)];
    [leftBtn addTarget:self action:@selector(pressleftBtn:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitle:@"隐藏到后台" forState:UIControlStateNormal];
    [leftBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [alertView addSubview:leftBtn];
    
}
- (void)initView{

    UIView *backgroudView = [[UIView alloc] initWithFrame:self.frame];
    [backgroudView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
    [self addSubview:backgroudView];
    
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 250, 160)];
    alertView.center = CGPointMake(SCREENW/2, SCREENH/2);
    alertView.layer.masksToBounds = YES;
    alertView.layer.cornerRadius = 10.f;
    alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:alertView];
    
    CGFloat width = alertView.frame.size.width;
    CGFloat height = alertView.frame.size.height;
    CGFloat hudW = 200.f;
    UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake((width - hudW)/2, 20, hudW, 53)];
    hudView.backgroundColor  = [UIColor clearColor];
    [alertView addSubview:hudView];
    self.hudView = hudView;
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.hudView.frame.size.width, 3)];
    self.progressView.layer.borderColor = RGBa(58, 153, 216, 1).CGColor;
    self.progressView.layer.borderWidth = 0.5f;
    self.progressView.tintColor = RGBa(58, 153, 216, 1);
    self.progressView.trackTintColor = [UIColor whiteColor];
    [self.hudView addSubview:self.progressView];
    
    self.progressLbl = [[UILabel alloc] initWithFrame: CGRectMake(0, 13, self.hudView.frame.size.width, 20.f)];
    self.progressLbl.textColor = [UIColor grayColor];
    self.progressLbl.textAlignment = NSTextAlignmentCenter;
    self.progressLbl.font = [UIFont systemFontOfSize:16.f];
    [self.hudView addSubview:self.progressLbl];
    
    UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, self.hudView.frame.origin.y + self.hudView.frame.size.height, width, 1)];
    rowView.backgroundColor = RGB(244, 244, 244, 1);
    [alertView addSubview:rowView];
    
    CGFloat btnY = rowView.frame.origin.y + rowView.frame.size.height;
    CGFloat btnH = height - btnY;
    CGFloat btnW = width ;
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake( 0, btnY, btnW , btnH)];
    [leftBtn addTarget:self action:@selector(pressleftBtn:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [alertView addSubview:leftBtn];

}

- (void)pressleftBtn:(UIButton *)sender{
    
    [self removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(pressCancleDownLoad)]) {
        [self.delegate pressCancleDownLoad];
    }
}

- (void)initData{

    [self.progressView setProgress:0 animated:NO];
    self.progressLbl.text = @"正在加载...";
}
- (void)changeProgressWithProgress:(CGFloat)progressNum{

    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger num =[[NSString stringWithFormat:@"%.0f",progressNum*100] integerValue];

        [self.progressView setProgress:progressNum animated:YES];
        self.progressLbl.text = [NSString stringWithFormat:@"%ld %%",(long)num];
        
    });
}
@end
