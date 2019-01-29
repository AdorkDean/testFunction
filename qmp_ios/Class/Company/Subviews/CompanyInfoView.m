//
//  CompanyInfoView.m
//  qmp_ios
//
//  Created by Molly on 2016/12/16.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CompanyInfoView.h"
#import "GetSizeWithText.h"


@interface CompanyInfoView()

@property(nonatomic,strong)UIButton *arrowBtn;
@property(nonatomic,strong)UIView *bgView;

@end

@implementation CompanyInfoView

+(CompanyInfoView *)instanceCompanyInfoView:(CGRect)frame withInfo:(NSString *)info{
    
    CompanyInfoView *alertView = [[CompanyInfoView alloc] initWithFrame:frame];
    [alertView initView:info];
    return alertView;
    
}


+(CompanyInfoView *)instanceCompanyInfoView:(CGRect)frame withName:(NSString*)productName withInfo:(NSString *)info{
    CompanyInfoView *alertView = [[CompanyInfoView alloc] initWithFrame:frame];
    [alertView initView:productName info:info];
    return alertView;
    
}

//项目的
- (void)initView:(NSString*)productName info:(NSString*)info{
   
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(33*ratioWidth, 98*ratioHeight, self.frame.size.width-65*ratioWidth, self.frame.size.height-267*ratioHeight)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 4;
    [self addSubview:bgView];
    _bgView = bgView;
    
    CGFloat margin = 10.f;
    
    _nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(margin,46*ratioHeight, bgView.width-20, 16.f)];
    _nameLbl.font = [UIFont systemFontOfSize:18];
    _nameLbl.textColor = HTColorFromRGB(0x1d1d1d);
    _nameLbl.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:_nameLbl];
    _nameLbl.centerX = bgView.width/2.0;
    _nameLbl.text = productName;
    
    
    _infoLbl = [[UITextView alloc] initWithFrame:CGRectMake(40*ratioWidth, _nameLbl.bottom+20, bgView.width - 80*ratioWidth, bgView.height - (_nameLbl.bottom+25) - 40*ratioHeight)];
    _infoLbl.editable = NO;
    _infoLbl.font = [UIFont systemFontOfSize:14.f];
    _infoLbl.textColor = HTColorFromRGB(0x555555);
    _infoLbl.showsVerticalScrollIndicator = NO;

    [bgView addSubview:_infoLbl];
    _infoLbl.centerX = bgView.width/2.0;
    NSAttributedString *att = [info stringWithParagraphlineSpeace:9 textColor:_infoLbl.textColor textFont:_infoLbl.font];

    _infoLbl.attributedText = att;
    
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressInfoLbl:)];
    [_infoLbl addGestureRecognizer:longpress];
    _infoLbl.userInteractionEnabled = YES;
    _infoLbl.selectable = NO;
 
    //叉号
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [btn setImage:[UIImage imageNamed:@"teamAlert_cha"] forState:UIControlStateNormal];
    [self addSubview:btn];
    btn.centerX = self.width/2.0;
    btn.bottom = self.height - 61*ratioHeight;
    [btn addTarget:self action:@selector(disappearFromSuperView) forControlEvents:UIControlEventTouchUpInside];
    
    
    _finishEditBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 90, 50)];
    [_finishEditBtn setTitle:@"完成"  forState:UIControlStateNormal];
    [_finishEditBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];

    [bgView addSubview:_finishEditBtn];
    _finishEditBtn.centerX = bgView.width/2.0;
    _finishEditBtn.top = _infoLbl.bottom;
    [_finishEditBtn addTarget:self action:@selector(finishEditBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    _finishEditBtn.hidden = YES;
    
    
    //监听键盘移动
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];  //第三方键盘可以手动收回键盘

}

- (void)initView:(NSString *)info{
    
    self.backgroundColor = [UIColor clearColor];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.8;
    [self addSubview:bgView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToRemoveView:)];
    [bgView addGestureRecognizer:tap];
    bgView.userInteractionEnabled = YES;
    _bgView = bgView;
    
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.font = [UIFont systemFontOfSize:15.f];
    _infoLabel.textColor = [UIColor whiteColor];
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    
    GetSizeWithText *sizeTool = [[GetSizeWithText alloc] init];
    CGFloat h = ceil([sizeTool calculateSize:info withFont:[UIFont systemFontOfSize:15.f] withWidth:SCREENW - 16.f].height);
    CGFloat infoLblY = 44.f;
    CGFloat maxH = SCREENH - infoLblY - 8.f;
    _infoLabel.frame = CGRectMake(8,infoLblY , SCREENW - 16.f, h > maxH ? maxH : h);
    _infoLabel.text = info;
    _infoLabel.numberOfLines = 0;
    _infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _infoLabel.center = bgView.center;
    
    [bgView addSubview:_infoLabel];
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressInfoLbl:)];
    [_infoLabel addGestureRecognizer:longPress];
    _infoLabel.userInteractionEnabled = YES;
    
}

- (void)finishEditBtnClick{
    
    if (self.finishEditClick) {
        self.finishEditClick(self.infoLbl.text);
    }
    [self disappearFromSuperView];
}

- (void)longPressInfoLbl:(UIGestureRecognizer *)press{
    
    UILabel *productLbl = (UILabel *)press.view;
    [self copyInfoWithUrl:productLbl.text];
}
- (void)copyInfoWithUrl:(NSString *)key{
    
    
    NSString *urlStr = self.shortUrlStr;
    if ([urlStr hasPrefix:@"http://"]||[urlStr hasPrefix:@"https://"]) {
        
        [PublicTool storeShortUrlToLocal:urlStr];
        
    }
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [NSString stringWithFormat:@"%@ 来自@企名片%@",key,urlStr];
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:self withInfo:info];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = touches.anyObject;
    if ([touch.view isKindOfClass:[CompanyInfoView class]]) {
        [self disappearFromSuperView];
    }
}


- (void)keyboardWillShow:(NSNotification*)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;
    CGFloat duraion = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duraion animations:^{
        _bgView.bottom = keyBoardEndY;
    }];
    
}

- (void)keyboardWillHide:(NSNotification*)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;
    CGFloat duraion = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duraion animations:^{
        _bgView.top = 98*ratioHeight;
    }];
}

- (void)disappearFromSuperView{
    [self removeFromSuperview];

}
- (void)tapToRemoveView:(UITapGestureRecognizer *)tap{
    
    [self removeFromSuperview];
}

@end
