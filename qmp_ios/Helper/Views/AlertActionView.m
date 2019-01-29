//
//  AlertActionView.m
//  qmp_ios
//
//  Created by QMP on 2018/1/18.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "AlertActionView.h"

@interface AlertActionView()
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *messageLab;
@property (weak, nonatomic) IBOutlet UILabel *tipInfoLab;


@property(nonatomic,copy)SureBtnActin sureBtnAction;
@property(nonatomic,copy)CancelBtnActin cancelBtnActin;


@end

@implementation AlertActionView

-(instancetype)initWithMessage:(NSString*)message tipInfo:(NSString*)tipInfo sureBtnAction:(SureBtnActin)sureBtnAcion{
    
    AlertActionView *alertV = [[BundleTool commonBundle]loadNibNamed:@"AlertActionView" owner:nil options:nil].lastObject;
    alertV.frame = [UIScreen mainScreen].bounds;
    alertV.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    alertV.bgView.layer.masksToBounds = YES;
    alertV.bgView.layer.cornerRadius = 10;
    alertV.sureBtnAction = sureBtnAcion;
    alertV.messageLab.text = message;
    alertV.tipInfoLab.text = tipInfo;
    alertV.closeBtn.hidden = YES;
    return alertV;
    
}

-(instancetype)initWithMessage:(NSString*)message tipInfo:(NSString*)tipInfo cancelTitle:(NSString*)cancelTitle  sureBtnTitle:(NSString*)sureBtnTitle  cancelBtnAction:(CancelBtnActin)cancelBtnAction sureBtnAction:(SureBtnActin)sureBtnAcion{
    
    AlertActionView *alertV = [[BundleTool commonBundle]loadNibNamed:@"AlertActionView" owner:nil options:nil].lastObject;
    alertV.frame = [UIScreen mainScreen].bounds;
    alertV.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    alertV.bgView.layer.masksToBounds = YES;
    alertV.bgView.layer.cornerRadius = 10;
    [alertV.sureBtn setTitle:sureBtnTitle forState:UIControlStateNormal];
    [alertV.cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];
    alertV.cancelBtnActin = cancelBtnAction;
    alertV.sureBtnAction = sureBtnAcion;
    alertV.messageLab.text = message;
    alertV.tipInfoLab.text = tipInfo;
    alertV.closeBtn.hidden = YES;

    return alertV;
    
}

+ (void)alertViewWithMessage:(NSString*)message tipInfo:(NSString*)tipInfo sureBtnAction:(SureBtnActin)sureBtnAcion{

    AlertActionView *alertV = [[AlertActionView alloc]initWithMessage:message tipInfo:tipInfo sureBtnAction:sureBtnAcion];
    alertV.closeBtn.hidden = YES;
    for (UIView *subV in KEYWindow.subviews) {
        if ([subV isKindOfClass:[AlertActionView class]]) {
            [subV removeFromSuperview];
        }
    }
    [KEYWindow addSubview:alertV];
}

//投递BP
+ (void)alertViewWithMessage:(NSAttributedString*)message tipInfo:(NSAttributedString*)tipInfo sureBtnAction:(SureBtnActin)sureBtnAcion sureBtnEnabled:(BOOL)sureBtnEnabled{
    
    
    AlertActionView *alertV = [[BundleTool commonBundle]loadNibNamed:@"AlertActionView" owner:nil options:nil].lastObject;
    alertV.frame = [UIScreen mainScreen].bounds;
    alertV.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    alertV.bgView.layer.masksToBounds = YES;
    alertV.bgView.layer.cornerRadius = 10;
    alertV.sureBtnAction = sureBtnAcion;
    alertV.messageLab.attributedText = message;
    alertV.tipInfoLab.attributedText = tipInfo;
    [alertV.sureBtn setTitle:@"继续投递" forState:UIControlStateNormal];
    alertV.sureBtn.enabled = sureBtnEnabled;
    alertV.closeBtn.hidden = YES;

    for (UIView *subV in KEYWindow.subviews) {
        if ([subV isKindOfClass:[AlertActionView class]]) {
            [subV removeFromSuperview];
        }
    }
    [KEYWindow addSubview:alertV];

    
}

//投递BP
+ (void)alertViewWithMessage:(NSAttributedString*)message tipInfo:(NSAttributedString*)tipInfo  cancelBtnAction:(CancelBtnActin)cancelBtnAction sureBtnAction:(SureBtnActin)sureBtnAcion sureBtnEnabled:(BOOL)sureBtnEnabled{
    
    AlertActionView *alertV = [[BundleTool commonBundle]loadNibNamed:@"AlertActionView" owner:nil options:nil].lastObject;
    alertV.frame = [UIScreen mainScreen].bounds;
    alertV.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    alertV.bgView.layer.masksToBounds = YES;
    alertV.bgView.layer.cornerRadius = 10;
    alertV.cancelBtnActin  = cancelBtnAction;
    alertV.sureBtnAction = sureBtnAcion;
    alertV.messageLab.attributedText = message;
    alertV.tipInfoLab.attributedText = tipInfo;
    [alertV.sureBtn setTitle:@"继续投递" forState:UIControlStateNormal];
    alertV.sureBtn.enabled = sureBtnEnabled;
    alertV.closeBtn.hidden = YES;
    
    for (UIView *subV in KEYWindow.subviews) {
        if ([subV isKindOfClass:[AlertActionView class]]) {
            [subV removeFromSuperview];
        }
    }
    [KEYWindow addSubview:alertV];
}

//委托联系
+ (void)alertViewWithMessage:(NSString*)message tipInfo:(NSString*)tipInfo cancelTitle:(NSString*)cancelTitle sureBtnTitle:(NSString*)sureBtnTitle  sureBtnEnabled:(BOOL)sureBtnEnabled cancelBtnAction:(CancelBtnActin)cancelBtnAction sureBtnAction:(SureBtnActin)sureBtnAcion{
    
    AlertActionView *alertV = [[AlertActionView alloc]initWithMessage:message tipInfo:tipInfo sureBtnAction:sureBtnAcion];
    alertV.frame = [UIScreen mainScreen].bounds;
    alertV.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    alertV.bgView.layer.masksToBounds = YES;
    alertV.bgView.layer.cornerRadius = 10;
    alertV.cancelBtnActin = cancelBtnAction;
    alertV.sureBtnAction = sureBtnAcion;
    alertV.messageLab.text = message;
    alertV.tipInfoLab.text = tipInfo;
    [alertV.cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];
    [alertV.sureBtn setTitle:sureBtnTitle forState:UIControlStateNormal];
    alertV.sureBtn.enabled = sureBtnEnabled;
    
    if ([cancelTitle isEqualToString:@"认证"] && sureBtnEnabled == NO) {
        //认证审核中  认证也不可点击
        if ([WechatUserInfo shared].claim_type.integerValue == 3) { //审核中 认证不可点击
            alertV.cancelBtn.enabled = NO;
        }
        alertV.closeBtn.hidden = NO;
    }else{
        alertV.closeBtn.hidden = YES;
    }
    
    for (UIView *subV in KEYWindow.subviews) {
        if ([subV isKindOfClass:[AlertActionView class]]) {
            [subV removeFromSuperview];
        }
    }
    [KEYWindow addSubview:alertV];
    
    
}



- (IBAction)cancelBtnClick:(id)sender {
    if (self.cancelBtnActin) {
        self.cancelBtnActin();
    }
    [self removeFromSuperview];
}
- (IBAction)contactBtnclick:(id)sender {
    if (self.sureBtnAction) {
        self.sureBtnAction();
    }
    [self removeFromSuperview];
}
- (IBAction)closeBtnClick:(id)sender {
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [touches.anyObject locationInView:self.bgView];
    if (point.x<0 || point.y<0) {
        [self removeFromSuperview];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
