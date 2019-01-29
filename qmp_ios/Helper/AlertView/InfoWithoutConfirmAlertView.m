//
//  InfoWithoutConfirmAlertView.m
//  qmp_ios
//
//  Created by molly on 2017/7/20.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "InfoWithoutConfirmAlertView.h"
#import "ShowInfo.h"

@interface InfoWithoutConfirmAlertView()
@property (strong, nonatomic) UIView *alertView;
@property (strong, nonatomic) UIButton *confirmBtn;
@property (strong, nonatomic) NSString *action;
@end
@implementation InfoWithoutConfirmAlertView

+ (instancetype)initFrame{
    
    InfoWithoutConfirmAlertView *alertView = [[InfoWithoutConfirmAlertView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    
    return alertView;
}

- (void)initViewWithTitle:(NSString *)title withInfo:(NSString *)info withLeftBtnTitle:(NSString *)leftTitle onAction:(NSString *)action{
    
    [self initViewWithTitle:title withInfo:info withLeftBtnTitle:leftTitle onAction:action withCenter:CGPointMake(SCREENW / 2, SCREENH/2) withInfoLblH:40.f];
    
}

- (void)initViewWithTitle:(NSString *)title withInfo:(NSString *)info withLeftBtnTitle:(NSString *)leftTitle  onAction:(NSString *)action withCenter:(CGPoint )centerPoint withInfoLblH:(CGFloat)infoLblH{
    
    for (UIView *subV in [KEYWindow subviews]) {
        if ([subV isKindOfClass:[self class]] || [subV isKindOfClass:NSClassFromString(@"InfoAlertView")]) {
            [subV removeFromSuperview];
        }
    }
    
    self.action = action;
    
    UIView *backgroudView = [[UIView alloc] initWithFrame:self.frame];
    [backgroudView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
    [self addSubview:backgroudView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroudView:)];
    backgroudView.userInteractionEnabled = YES;
    [backgroudView addGestureRecognizer:tap];
    
    infoLblH = [PublicTool heightOfString:info width:250-20 font:[UIFont systemFontOfSize:15]];
    CGFloat totalHeight = infoLblH + 122;
    self.alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 250, totalHeight)];
    self.alertView.center = centerPoint;
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 10.f;
    self.alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.alertView];
    
    CGFloat width = self.alertView.frame.size.width;
    CGFloat height = self.alertView.frame.size.height;
    CGFloat lblH = 20.f;
    CGFloat margin = 10.f;
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, width, lblH)];
    titleLbl.text = title;
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [self.alertView addSubview:titleLbl];
    
    UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(margin, titleLbl.frame.origin.y + titleLbl.frame.size.height + 17 , width - 2 * margin, infoLblH)];
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
    CGFloat btnW = width;
    [self initCloseBtnView];
    //
    if ([leftTitle isEqualToString:@"上传"]) {
        UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, btnY, btnW /2, btnH)];
        [leftBtn addTarget:self action:@selector(pressConfitmBtn:) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn setTitle:@"上传到报告" forState:UIControlStateNormal];
        [leftBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        leftBtn.titleLabel.font = [UIFont systemFontOfSize:17.f];
        [self.alertView addSubview:leftBtn];
        
        UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnW /2, btnY, btnW /2, btnH)];
        [rightBtn addTarget:self action:@selector(pressConfitmBtn:) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitle:@"上传到BP" forState:UIControlStateNormal];
        [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17.f];
        [self.alertView addSubview:rightBtn];
    }else{
        self.confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, btnY, btnW - 1, btnH)];
        [self.confirmBtn addTarget:self action:@selector(pressConfitmBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.confirmBtn setTitle:leftTitle forState:UIControlStateNormal];
        [self.confirmBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        self.confirmBtn.titleLabel.font = [UIFont systemFontOfSize:17.f];
        [self.alertView addSubview:self.confirmBtn];
    }
   
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(btnW - 1, btnY, 1, btnH)];
    lineView.backgroundColor = RGB(244, 244, 244, 1);
    [self.alertView addSubview:lineView];
    
}

- (void)initCloseBtnView{
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.alertView.frame.origin.x + self.alertView.frame.size.width - 32, self.alertView.frame.origin.y + 2, 30, 30)];
    closeBtn.layer.masksToBounds = YES;
    closeBtn.layer.cornerRadius = 15.f;
    [closeBtn setBackgroundColor:[UIColor whiteColor]];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"group-close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(tapBackgroudView:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    
}
- (void)tapBackgroudView:(id *)tap{
    if ([self.delegate respondsToSelector:@selector(cancelUpload)]) {
        [self.delegate cancelUpload];
    }
    [self removeFromSuperview];
}

- (void)pressConfitmBtn:(UIButton *)sender{
    
    if (self.dataStr) {
        if ([sender.titleLabel.text isEqualToString:@"上传到报告"] && [self.delegate respondsToSelector:@selector(confirmToChooseWithData:isBP:)]) {
            [self.delegate confirmToChooseWithData:self.dataStr isBP:NO];
            [self removeFromSuperview];
            return;
        }else if ([sender.titleLabel.text isEqualToString:@"上传到BP"] && [self.delegate respondsToSelector:@selector(confirmToChooseWithData:isBP:)]) {
            [self.delegate confirmToChooseWithData:self.dataStr isBP:YES];
            [self removeFromSuperview];

            return;

        }
        if ([self.delegate respondsToSelector:@selector(confirmToChooseWithData:)]) {
            [self.delegate confirmToChooseWithData:self.dataStr];
            [self removeFromSuperview];
            return;

        }
    }else{
        if ([self.delegate respondsToSelector:@selector(confirmToChoose)]) {
            [self.delegate confirmToChoose];
            [self removeFromSuperview];

        }
    }
}

@end
