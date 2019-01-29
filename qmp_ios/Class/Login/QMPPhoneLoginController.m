//
//  QMPPhoneLoginController.m
//  qmp_ios
//
//  Created by QMP on 2018/11/7.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "QMPPhoneLoginController.h"
#import "AppDelegate.h"
#import "PrivatePolicyView.h"
#import "QMPLoginController.h"

@interface QMPPhoneLoginController ()
{
    UITextField *_companyTf;
    UITextField *_zhiweiTf;
    UITextField *_phoneTf;
    UITextField *_codeTf;
    UIButton *_secondBtn;
    NSTimer *_timer;
    NSInteger _totalSecond;
    UIButton *_bindBtn;
    NSString *_code;
    UITextField *_recommentPeopleTf;
}
@end

@implementation QMPPhoneLoginController

-(void)dealloc{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addView];
    self.title = @"手机号登录";
    self.navigationItem.leftBarButtonItems = [self createBackButton];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideNavigationBarLine];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self showNavigationBarLine];
}

#pragma mark ---UI
- (NSArray*)createBackButton{
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:LEFTBUTTONFRAME];
    [leftButton setImage:[UIImage imageNamed:@"left-arrow"] forState:UIControlStateNormal];
    //    [leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [leftButton addTarget:self action:@selector(backItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = LEFTNVSPACE;
    if (iOS11_OR_HIGHER) {
        leftButton.width = 30;
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0);
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        return @[leftButtonItem];
    }
    return @[negativeSpacer,leftButtonItem];
}
- (void)backItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)popSelf{
    
    QMPLoginController *loginVC = nil;
    for (UIViewController *vc in self.navigationController.childViewControllers) {
        if ([vc isKindOfClass:[QMPLoginController class]]) {
            loginVC = (QMPLoginController*)vc;
            break;
        }
    }
    
    if (loginVC) {
        
        UIViewController *lastVC = self.navigationController.childViewControllers[[self.navigationController.childViewControllers indexOfObject:loginVC]-1];
        [self.navigationController popToViewController:lastVC animated:YES];
        
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)addView{
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 20)];
    UILabel *lab = [[UILabel alloc] init];
    [lab labelWithFontSize:16 textColor:NV_TITLE_COLOR];
    lab.text = @"+86";
    [leftView addSubview:lab];
    UIImageView *verticalLine = [[UIImageView alloc]init];
    verticalLine.image = [UIImage imageNamed:@"line_shu"];
    [leftView addSubview:verticalLine];
    
    
    _phoneTf = [[UITextField alloc]init];
    _phoneTf.placeholder = @"输入您本人的手机号";
    _phoneTf.font = [UIFont systemFontOfSize:16];
    _phoneTf.textColor = NV_TITLE_COLOR;
    [_phoneTf setValue:HTColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    _phoneTf.leftView = leftView;
    _phoneTf.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTf.leftViewMode = UITextFieldViewModeAlways;
    _phoneTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_phoneTf];
    [_phoneTf addTarget:self action:@selector(phoneTfInputChange) forControlEvents:UIControlEventEditingChanged];
    
    
    
    _codeTf = [[UITextField alloc]init];
    _codeTf.placeholder = @"输入6位验证码";
    _codeTf.textColor = NV_TITLE_COLOR;
    _codeTf.font = [UIFont systemFontOfSize:16];
    _codeTf.keyboardType = UIKeyboardTypeNumberPad;
    _codeTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_codeTf setValue:HTColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.view addSubview:_codeTf];
    [_codeTf addTarget:self action:@selector(codeTfInputChange) forControlEvents:UIControlEventEditingChanged];
    
    
    _secondBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _secondBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_secondBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [_secondBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_secondBtn addTarget:self action:@selector(getCodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_secondBtn];
    
    UIButton *bindBtn = [[UIButton alloc]init];
    [bindBtn setTitle:@"登录" forState:UIControlStateNormal];
    [bindBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bindBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    bindBtn.layer.masksToBounds = YES;
    bindBtn.layer.cornerRadius = 22;
    bindBtn.backgroundColor = [RGBBlueColor colorWithAlphaComponent:0.5];
    [self.view addSubview:bindBtn];
    [bindBtn addTarget:self action:@selector(bindBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _bindBtn = bindBtn;
    
    UIView *firstLine = [[UIView alloc]init];
    firstLine.backgroundColor = BORDER_LINE_COLOR;
    [_phoneTf addSubview:firstLine];
    
    UIView *secondLine = [[UIView alloc]init];
    secondLine.backgroundColor = BORDER_LINE_COLOR;
    [self.view addSubview:secondLine];
    
    // top
    CGFloat top = 122*ratioWidth;
    if (![WechatUserInfo shared].bind_flag || [WechatUserInfo shared].bind_flag.integerValue == 0) {
        //约束
        [_companyTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(40*ratioWidth);
            make.top.equalTo(self.view).offset(100*ratioWidth);
            make.right.equalTo(self.view).offset(-40*ratioWidth);
            make.height.equalTo(@(30));
        }];
        UIView *companyLine = [_companyTf viewWithTag:1000];
        [companyLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_companyTf);
            make.bottom.equalTo(_companyTf).offset(5);
            make.right.equalTo(_companyTf);
            make.height.equalTo(@(0.5));
        }];
        
        //约束
        [_zhiweiTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(40*ratioWidth);
            make.top.equalTo(_companyTf.mas_bottom).offset(30);
            make.right.equalTo(self.view).offset(-40*ratioWidth);
            make.height.equalTo(@(30));
        }];
        UIView *zhiweiLine = [_zhiweiTf viewWithTag:1000];
        [zhiweiLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_zhiweiTf);
            make.bottom.equalTo(_zhiweiTf).offset(5);
            make.right.equalTo(_zhiweiTf);
            make.height.equalTo(@(0.5));
        }];
        
        top = 100*ratioWidth ;
    }
    
    //约束
    [_phoneTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(40*ratioWidth);
        make.top.equalTo(self.view).offset(top);
        make.right.equalTo(self.view).offset(-40*ratioWidth);
        make.height.equalTo(@(30));
    }];
    
    
    
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(leftView);
        make.width.equalTo(@(30));
        make.height.equalTo(leftView);
    }];
    
    [verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lab.mas_right).offset(10);
        make.top.equalTo(lab.mas_top);
        make.bottom.equalTo(lab.mas_bottom);
        make.width.equalTo(@(0.5));
        
    }];
    
    [firstLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_phoneTf.mas_left);
        make.bottom.equalTo(_phoneTf.mas_bottom).offset(5);
        make.right.equalTo(_phoneTf.mas_right);
        make.height.equalTo(@(0.5));
    }];
    
    [_codeTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_phoneTf.mas_left);
        make.right.equalTo(_phoneTf.mas_right).offset(-120);
        make.top.equalTo(_phoneTf.mas_bottom).offset(30);
        make.height.equalTo(_phoneTf.mas_height);
    }];
    
    [_secondBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_phoneTf.mas_right);
        make.height.equalTo(@(30));
        make.width.equalTo(@(100));
        make.centerY.equalTo(_codeTf.mas_centerY);
    }];
    
    [secondLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_codeTf.mas_left);
        make.bottom.equalTo(_codeTf.mas_bottom).offset(5);
        make.right.equalTo(_phoneTf.mas_right);
        make.height.equalTo(@(0.5));
    }];
    
    
    CGFloat btnHeight = iPad ? 50 : 43*ratioWidth;
    [bindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_phoneTf.mas_left);
        make.right.equalTo(_phoneTf.mas_right);
        make.height.equalTo(@(btnHeight));
        make.top.equalTo(secondLine.mas_bottom).offset(58);
    }];
    
    //隐私协议
    UIButton *policyBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, SCREENH - 50 - kScreenTopHeight, 200, 44)];
    policyBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:@"登录即表示您已同意隐私协议"];
    [attStr addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:NSMakeRange(9, 4)];
    [attStr addAttributes:@{NSForegroundColorAttributeName:H9COLOR} range:NSMakeRange(0, 9)];
    [policyBtn setAttributedTitle:attStr forState:UIControlStateNormal];
    [policyBtn addTarget:self action:@selector(popPolicy) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:policyBtn];
    policyBtn.centerX = SCREENW/2.0;
}

- (void)popPolicy{
    [PrivatePolicyView showPolicyView];
}

#pragma mark --Event--
- (void)getCodeBtnClick{
    
    QMPLog(@"%s", __func__);
    if (![_secondBtn.titleLabel.text isEqualToString:@"获取验证码"]) {
        return;
    }
    
    if (![PublicTool checkTel:_phoneTf.text]) {
        return;
    }
    if (_timer) {
        QMPLog(@"_timv");
        [_secondBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [_secondBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        _totalSecond = 60;
        [_timer invalidate];
        _timer = nil;
    }
    
    [self beginDaojishi];
    [_codeTf becomeFirstResponder];
    [self getPhoneCode];
    
}

- (void)getPhoneCode{
    //后台验证码
    [AppNetRequest getVerifyCodeWithParameter:@{@"mobile":_phoneTf.text} completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData[@"status"] integerValue] == 0) {
            
        }else{
            if ([PublicTool isNull:resultData[@"message"]]) {
                [PublicTool showMsg:@"操作过于频繁"];
            }else{
                [PublicTool showMsg:resultData[@"message"]];
            }
        }
    }];
    [_codeTf becomeFirstResponder];
}


- (void)beginDaojishi{
    
    _totalSecond = 60;
    [_secondBtn setTitleColor:H9COLOR forState:UIControlStateNormal];
    [_secondBtn setTitle:@"重新获取(60s)" forState:UIControlStateNormal];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
    
}

- (void)timerEvent{
    
    _totalSecond --;
    if (_totalSecond == 0) {
        [_secondBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [_secondBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        _totalSecond = 60;
        [_timer invalidate];
        _timer = nil;
        
    }else{
        [_secondBtn setTitle:[NSString stringWithFormat:@"重新获取(%lds)",_totalSecond] forState:UIControlStateNormal];
    }
}

- (void)codeTfInputChange{
    
    _codeTf.text = [_codeTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (_codeTf.text.length == 6 && _phoneTf.text.length == 11) {
        
        _bindBtn.enabled = YES;
        _bindBtn.backgroundColor = RGBBlueColor;
        
    }else{
        _bindBtn.enabled = NO;
        _bindBtn.backgroundColor = [RGBBlueColor colorWithAlphaComponent:0.5];
    }
}

- (void)phoneTfInputChange{
    _phoneTf.text = [_phoneTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (_codeTf.text.length == 6 && _phoneTf.text.length == 11) {
        
        _bindBtn.enabled = YES;
        _bindBtn.backgroundColor = RGBBlueColor;
        
        
    }else{
        _bindBtn.enabled = NO;
        _bindBtn.backgroundColor = [RGBBlueColor colorWithAlphaComponent:0.5];
        
    }
}

- (void)recommendTfInputChange{
    _recommentPeopleTf.text = [_recommentPeopleTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)bindBtnClick{
    
    if (![PublicTool checkTel:_phoneTf.text]) {
        return;
    }
    if (![PublicTool checkVerifyCode:_codeTf.text]) {
        return;
    }
    
    //请求后台
    [PublicTool showHudWithView:KEYWindow];
    NSString *phone = [_phoneTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *code = [_codeTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    code = [code stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSDictionary *param = @{@"mobile":phone,@"code":code};
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"login/phone" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData) {
            
            NSNumber *bind_flag = resultData[@"bind_flag"];
            if (bind_flag.integerValue != 1) { //新用户，微信未登陆过
                [PublicTool showMsg:@"您还未注册，请用微信登录"];
                return;
                
            }else if (![PublicTool isNull:resultData[@"uuid"]]) {
                
                NSString *unionid = resultData[@"unionid"]; //需要返回 unionid
                [WechatUserInfo shared].unionid = unionid;
                [PublicTool showMsg:@"登录成功"];
                AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [appDelegate getUserInfo:resultData[@"uuid"]]; //获取用户的最新数据
                
            }else {
                
                [PublicTool showMsg:resultData[@"msg"]];
            }
            
        } else {
            [PublicTool showMsg:@"验证码错误"];
        }
        
    }];
    
}

- (NSInteger)getNowTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    NSInteger timeSp = [[NSNumber numberWithDouble:[datenow timeIntervalSince1970]] integerValue];
    return timeSp;
}

- (void)bindPhoneAction{
    
    NSString *phone = [_phoneTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary *param = @{@"tel":phone,@"company":[PublicTool isNull:_companyTf.text]?@"":_companyTf.text,@"zhiwei":[PublicTool isNull:_zhiweiTf.text]?@"":_zhiweiTf.text};
    
    
    [AppNetRequest userBindPhoneWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData && [PublicTool isNull:resultData[@"msg"]]) {
            [WechatUserInfo shared].bind_flag = @"1";
            [WechatUserInfo shared].phone = phone;
            [PublicTool showMsg:@"绑定成功"];
            if (self.submitPhone) {
                self.submitPhone(phone);
            }
            
            [self popSelf];
            
        }else{
            [PublicTool showMsg:@"绑定失败"];
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
