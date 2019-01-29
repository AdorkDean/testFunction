//
//  InfoAlertView.m
//  qmp_ios
//
//  Created by Molly on 16/9/6.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "InfoAlertView.h"

@interface InfoAlertView()

@property (strong, nonatomic) UIView *alertView;
@property (strong, nonatomic) UIButton *confirmBtn;
@property (strong, nonatomic) NSString *action;

@end

@implementation InfoAlertView

+(instancetype)initFrame{
    
    InfoAlertView *alertView = [[InfoAlertView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    
    return alertView;
}

- (void)initViewWithTitle:(NSString *)title withInfo:(NSString *)info withLeftBtnTitle:(NSString *)leftTitle withRightBtnTitle:(NSString *)rightTitle onAction:(NSString *)action withCenter:(CGPoint )centerPoint withInfoLblH:(CGFloat)infoLblH{

    for (UIView *subV in [KEYWindow subviews]) {
        if ([subV isKindOfClass:[self class]] || [subV isKindOfClass:NSClassFromString(@"InfoWithoutConfirmAlertView")]) {
            [subV removeFromSuperview];
        }
    }
    
    self.action = action;
    
    UIView *backgroudView = [[UIView alloc] initWithFrame:self.frame];
    [backgroudView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
    [self addSubview:backgroudView];
    
    self.alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 250, 157 + infoLblH - 30.f)];
    self.alertView.center = centerPoint;
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 10.f;
    self.alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.alertView];
    
    CGFloat width = self.alertView.frame.size.width;
    CGFloat height = self.alertView.frame.size.height;
    CGFloat lblH = 20.f;
    CGFloat margin = 10.f;
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, width, lblH)];
    titleLbl.text = title;
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [self.alertView addSubview:titleLbl];
    
    UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(margin, titleLbl.frame.origin.y + titleLbl.frame.size.height + 25 , width - 2 * margin, infoLblH)];
    infoLbl.text = info;
    infoLbl.textColor = [UIColor blackColor];
    infoLbl.textAlignment = NSTextAlignmentCenter;
    infoLbl.font = [UIFont systemFontOfSize:15.f];
    infoLbl.numberOfLines = 0;
    infoLbl.lineBreakMode = NSLineBreakByWordWrapping;
    [self.alertView addSubview:infoLbl];
    
    UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, infoLbl.frame.origin.y + infoLblH + 14, width, 1)];
    rowView.backgroundColor = RGB(244, 244, 244, 1);
    [self.alertView addSubview:rowView];
    
    CGFloat btnY = rowView.frame.origin.y + rowView.frame.size.height;
    CGFloat btnH = height - btnY;
    CGFloat btnW = width / 2;
    
    
    UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake( 0, btnY, btnW - 0.5, btnH)];
    [cancleBtn addTarget:self action:@selector(pressCancleBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitle:leftTitle forState:UIControlStateNormal];
    [cancleBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [self.alertView addSubview:cancleBtn];
    
    self.confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnW + 0.5, btnY, btnW - 1, btnH)];
    [self.confirmBtn addTarget:self action:@selector(pressConfitmBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmBtn setTitle:rightTitle forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [self.alertView addSubview:self.confirmBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(btnW - 1, btnY, 1, btnH)];
    lineView.backgroundColor = RGB(244, 244, 244, 1);
    [self.alertView addSubview:lineView];

}
- (void)initViewWithTitle:(NSString *)title withInfo:(NSString *)info withLeftBtnTitle:(NSString *)leftTitle withRightBtnTitle:(NSString *)rightTitle onAction:(NSString *)action{
    
    [self initViewWithTitle:title withInfo:info withLeftBtnTitle:leftTitle withRightBtnTitle:rightTitle onAction:action withCenter:CGPointMake(SCREENW / 2, 160.f) withInfoLblH:30.f];
    
}

- (void)initCloseBtnView{
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.alertView.frame.origin.x + self.alertView.frame.size.width - 32, self.alertView.frame.origin.y + 2, 30, 30)];
    closeBtn.layer.masksToBounds = YES;
    closeBtn.layer.cornerRadius = 15.f;
    [closeBtn setBackgroundColor:[UIColor whiteColor]];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"group-close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(pressCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    
}

- (void)initViewWithTitle:(NSString *)title withInfo:(NSString *)info{
    
    [self initViewWithTitle:title withInfo:info withLeftBtnTitle:@"取消" withRightBtnTitle:@"确定" onAction:@"removeGroupInfo"];
}

- (void)pressCloseBtn:(UIButton *)sender{
   
    //剪切板清空
    [[NSUserDefaults standardUserDefaults] setValue:[UIPasteboard generalPasteboard].string forKey:@"Clipboard"];
//    [UIPasteboard generalPasteboard].string = @"";
    [self removeFromSuperview];
}

- (void)pressCancleBtn:(UIButton *)sender{
    if ([self.action isEqualToString:@"removeGroupInfo"]) {
        [self removeFromSuperview];
    }
    if ([self.action isEqualToString:@"collectUrl"]) {
        
         [self removeFromSuperview];
        
        if ([self.delegate respondsToSelector:@selector(openUrl)]) {
            [self.delegate openUrl];
        }
        if ([self.delegate respondsToSelector:@selector(infoAlertViewOpenUrl:)]) {
            [self.delegate infoAlertViewOpenUrl:self];
        }
    }
    //剪切板清空
//    [UIPasteboard generalPasteboard].string = @"";
}

- (void)pressConfitmBtn:(UIButton *)sender{
    
    if ([self.action isEqualToString:@"removeGroupInfo"]) {
        if ([self.delegate respondsToSelector:@selector(confirmRemoveAllGroup:)]) {
            [self.delegate confirmRemoveAllGroup:self];
        }
    }
    
    if ([self.action isEqualToString:@"collectUrl"]) {
        
        if ([self.delegate respondsToSelector:@selector(confirmCollectUrl)]) {
            [self.delegate confirmCollectUrl];
        }
        if ([self.delegate respondsToSelector:@selector(infoAlertViewCollectUrl:)]) {
            [self.delegate infoAlertViewCollectUrl:self];
        }
    }
    //剪切板清空
//    [UIPasteboard generalPasteboard].string = @"";
}
@end
