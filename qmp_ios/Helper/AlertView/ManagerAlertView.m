//
//  ManagerAlertView.m
//  qmp_ios
//
//  Created by Molly on 16/8/20.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "ManagerAlertView.h"


 


#import "TagsItem.h"

@interface ManagerAlertView()<UITextFieldDelegate>

@end

@implementation ManagerAlertView

+ (instancetype)initFrame{

    ManagerAlertView *alertView = [[ManagerAlertView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    return alertView;
}

- (void)initViewWithTitle:(NSString *)title withCancleSelector:(SEL)cancleSelector withConfirmSelector:(SEL)confirmSelector{
    
    UIView *backgroudView = [[UIView alloc] initWithFrame:self.frame];
    [backgroudView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
    [self addSubview:backgroudView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroudView)];
    [backgroudView addGestureRecognizer:tap];
    backgroudView.userInteractionEnabled = YES;
    
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 250, 157)];
    alertView.center = CGPointMake(SCREENW / 2, alertView.center.y);
    alertView.layer.masksToBounds = YES;
    alertView.layer.cornerRadius = 10.f;
    alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:alertView];
    
    CGFloat width = alertView.frame.size.width;
    CGFloat height = alertView.frame.size.height;
    CGFloat lblH = 20.f;
    CGFloat margin = 10.f;
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, width, lblH)];
    titleLbl.text = title;
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:titleLbl];
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(margin, titleLbl.frame.origin.y + titleLbl.frame.size.height + 25 , width - 2 * margin, 30.f)];
    self.nameTextField.font = [UIFont systemFontOfSize:14.f];
    self.nameTextField.textAlignment = NSTextAlignmentLeft;
    self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameTextField.returnKeyType = UIReturnKeyDone;
    self.nameTextField.delegate = self;
    [self.nameTextField becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    [alertView addSubview:self.nameTextField];
    
    UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, self.nameTextField.frame.origin.y + 30.f + 14, width, 1)];
    rowView.backgroundColor = RGB(244, 244, 244, 1);
    [alertView addSubview:rowView];
    
    CGFloat btnY = rowView.frame.origin.y + rowView.frame.size.height;
    CGFloat btnH = height - btnY;
    CGFloat btnW = width / 2;
    
    
    UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake( 0, btnY, btnW - 0.5, btnH)];
    [cancleBtn addTarget:self action:cancleSelector forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [alertView addSubview:cancleBtn];
    
    self.confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnW + 0.5, btnY, btnW - 1, btnH)];
    [self.confirmBtn addTarget:self action:confirmSelector forControlEvents:UIControlEventTouchUpInside];
    [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [alertView addSubview:self.confirmBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(btnW - 1, btnY, 1, btnH)];
    lineView.backgroundColor = RGB(244, 244, 244, 1);
    [alertView addSubview:lineView];
    
//    if([title isEqualToString:@"添加分组"]){
    
        self.confirmBtn.enabled = NO;
//    }
    if ([title containsString:@"修改BP名称"]) {
        self.confirmBtn.enabled = YES;
    }
}

- (void)initViewWithTitle:(NSString *)title withConfirmSelector:(SEL)confirmSelector{

    [self initViewWithTitle:title withCancleSelector:@selector(pressCancleBtnOnlyCloseView:) withConfirmSelector:confirmSelector];
}
- (void)initViewWithTitle:(NSString *)title{
    
    [self initViewWithTitle:title withCancleSelector:@selector(pressCancleBtn:) withConfirmSelector:@selector(pressConfitmBtn:)];
}

- (void)tapBackgroudView{

    [self removeFromSuperview];
}

- (void)initViewWithFolder:(NSString *)folder aTitle:(NSString *)title{

    [self initViewWithTitle:title];
    self.nameTextField.text = folder;
    [self.nameArr removeObject:folder];
}

- (void)pressCancleBtn:(UIButton *)sender{

    [self removeFromSuperview];
    
    if (self.action && [self.action isEqualToString:@"addAlbumToSelf"]) {
        if ([self.delegata respondsToSelector:@selector(cancleCollectAlbumToSelf)]) {
            [self.delegata cancleCollectAlbumToSelf];
        }
    }
    else{
        if(self.tagItem.tag_id){
            if ([self.delegata respondsToSelector:@selector(pressCancleChangeName)]) {
                [self.delegata pressCancleChangeName];
            }
        }
    }
}

- (void)pressCancleBtnOnlyCloseView:(UIButton *)sender{
    
    [self removeFromSuperview];
}

- (void)pressConfitmBtn:(UIButton *)sender{

    if ([self.nameTextField.text isEqualToString:@"加更多"] || [self.nameTextField.text isEqualToString:@"加收起"]) {
        [PublicTool showMsg:@"输入内容无效"];
        return;
    }
    
    if (self.nameTextField.text.length < 2) {
        [PublicTool showMsg:@"输入内容无效"];
        return;
    }
    
    
    if (self.action && [self.action isEqualToString:@"addAlbumToSelf"]) {
        if ([self.delegata respondsToSelector:@selector(addAlbumToSelf:)]) {
            [self.delegata addAlbumToSelf:self.nameTextField.text];
        }
        if ([self.delegata respondsToSelector:@selector(managerAlertView:addTag:)]) {
            [self.delegata managerAlertView:self addTag:self.nameTextField.text];
        }
    }
    else{
    
        if (self.tagItem.tag_id) {
            [self requestChangeName];

        }
        else{
            [self requestCreateFolder];

        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(![textField.text isEqualToString:@""]) {
        [self pressConfitmBtn:nil];
        return YES;
    }
    else{
        
        return NO;
    }
}

- (void)textDidChange{
    
    if ([self.nameTextField.text isEqualToString:@""]) {
    
        [self.confirmBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        self.confirmBtn.enabled = NO;
        
    }else{
        [self.confirmBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        self.confirmBtn.enabled = YES;

    }
}

- (void)pressAddEmailToUser:(UIButton *)sender{
    NSString *email = self.nameTextField.text;
    if (email.length > 0 && ![self validateEmail:email]) {
        [ShowInfo showInfoOnView:KEYWindow withInfo:@"邮箱格式不正确"];
        return;
    }
    else{
        
        [self requestAddEmailToUser:email];
    }
}

- (BOOL)validateEmail:(NSString *)email{
    if (![email isKindOfClass:[NSString class]]) return NO;
    if (email.length ==0) return NO;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL b = [emailTest evaluateWithObject:email];
    return b;
}

#pragma mark - 请求添加eamil
- (void)requestAddEmailToUser:(NSString *)email{
    
    if ([TestNetWorkReached networkIsReachedNoAlert]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dic setValue:email forKey:@"email"];
        
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"wxios/addWxUserinfo" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            if (resultData) {
                [userDefaults setValue:email forKey:@"email"];
                [userDefaults synchronize];
                
                [ShowInfo showInfoOnView:KEYWindow withInfo:@"添加邮箱成功"];
                [self removeFromSuperview];
            }
        }];
    }
}

#pragma mark - 请求修改标签名
- (void)requestChangeName{
    
    if ([TestNetWorkReached networkIsReached:self.currentVC]) {
        NSString *folder = self.nameTextField.text;
        
        if ([self.nameArr containsObject:folder]) {
            
            [ShowInfo showInfoOnView:self withInfo:@"标签名重复"];
        }
        else{
            NSDictionary *param = @{@"tag_id":self.tagItem.tag_id,@"tag":self.nameTextField.text};
            [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/workTagRename" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                if (resultData) {
                    [self removeFromSuperview];
                    
                    TagsItem *tag = [[TagsItem alloc] init];
                    tag.tag = folder;
                    tag.tag_id = self.tagItem.tag_id;
                    tag.product_num = self.tagItem.product_num;
                    
                    if ([self.delegata respondsToSelector:@selector(changeName:)]) {
                        [self.delegata changeName:tag];
                    }
                }
            }];

            
        }
    }
}
#pragma mark - 请求创建新的标签
- (void)requestCreateFolder{
    
    if ([TestNetWorkReached networkIsReached:self.currentVC]) {
        
        NSString *folder = self.nameTextField.text;
        
        if ([self.nameArr containsObject:folder]) {
            
            [ShowInfo showInfoOnView:self withInfo:@"标签已存在"];
        }
        else{
        
            [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/workTagAdd" HTTPBody:@{@"tag":folder} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
                    
                    TagsItem *tag = [[TagsItem alloc] init];
                    [tag setValuesForKeysWithDictionary:resultData];
                    
                    if ([self.delegata respondsToSelector:@selector(createFolder:inId:)]) {
                        [self.delegata createFolder:tag inId:tag.tag_id];
                    }
                    [self removeFromSuperview];
                }
            }];
        }
    }
}
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.nameTextField];
}



@end
