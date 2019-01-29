//
//  NewerBindPhoneController.m
//  qmp_ios
//
//  Created by QMP on 2018/12/11.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "NewerBindPhoneController.h"

@interface NewerBindPhoneController ()
{
    UIView *_bgView;
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
    UIButton *_skipBtn;
    BOOL _newUser;
    UIView *_roleView;
    UIButton *_lastSelBtn;
}
@end

@implementation NewerBindPhoneController

-(void)dealloc{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [QMPEvent beginEvent:@"login_bindphone_timer"];
    [self hideNavigationBarLine];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [QMPEvent endEvent:@"login_bindphone_timer"];
    [self showNavigationBarLine];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
    
    [self addView];
    
    self.title = @"绑定手机号";
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithCustomView:[[UIView alloc]init]];
    self.navigationItem.leftBarButtonItems = @[barItem];
   
    UIButton *skipBtn = [[UIButton alloc]initWithFrame:RIGHTBARBTNFRAME];
    [skipBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [skipBtn setTitleColor:H3COLOR forState:UIControlStateNormal];
    skipBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [skipBtn addTarget:self action:@selector(skipBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:skipBtn];
    
    [QMPEvent event:@"login_bindphone"];
    
    if (!iPad) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)keyboardWillShow:(NSNotification*)notification{
   
    NSDictionary *userInfo = [notification userInfo];
    CGFloat duraion = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];

    if (_companyTf.isFirstResponder || _zhiweiTf.isFirstResponder) {
        NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGFloat keyBoardHeight = value.CGRectValue.size.height;
        
        [UIView animateWithDuration:duraion animations:^{
            _bgView.transform = CGAffineTransformMakeTranslation(0, -keyBoardHeight/4.0);
//            self.view.bottom = keyBoardEndY;
        }];
    }else{
        [UIView animateWithDuration:duraion animations:^{
            _bgView.transform = CGAffineTransformIdentity;
        }];
    }
   
}

- (void)keyboardWillHide:(NSNotification*)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;
    CGFloat duraion = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duraion animations:^{
        _bgView.transform = CGAffineTransformIdentity;
    }];
}


#pragma mark ---UI
- (void)addView{
    _bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_bgView];
    
    _companyTf = [[UITextField alloc]init];
    _companyTf.placeholder = @"所在的公司或机构(选填)";
    _companyTf.textColor = NV_TITLE_COLOR;
    _companyTf.font = [UIFont systemFontOfSize:16];
    _companyTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_companyTf setValue:HTColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    [_bgView addSubview:_companyTf];
    
    UIView *companyTfLine = [[UIView alloc]init];
    companyTfLine.backgroundColor = BORDER_LINE_COLOR;
    [_companyTf addSubview:companyTfLine];
    companyTfLine.tag = 1000;
    
    _zhiweiTf = [[UITextField alloc]init];
    _zhiweiTf.placeholder = @"职位(选填)";
    _zhiweiTf.textColor = NV_TITLE_COLOR;
    _zhiweiTf.font = [UIFont systemFontOfSize:16];
    _zhiweiTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_zhiweiTf setValue:HTColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    [_bgView addSubview:_zhiweiTf];
    
    UIView *zhiweiTfLine = [[UIView alloc]init];
    zhiweiTfLine.backgroundColor = BORDER_LINE_COLOR;
    [_zhiweiTf addSubview:zhiweiTfLine];
    zhiweiTfLine.tag = 1000;
    
    _phoneTf = [[UITextField alloc]init];
    _phoneTf.placeholder = @"输入您本人的手机号";
    _phoneTf.font = [UIFont systemFontOfSize:16];
    _phoneTf.textColor = NV_TITLE_COLOR;
    [_phoneTf setValue:HTColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    _phoneTf.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTf.leftViewMode = UITextFieldViewModeAlways;
    _phoneTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_bgView addSubview:_phoneTf];
    [_phoneTf addTarget:self action:@selector(phoneTfInputChange) forControlEvents:UIControlEventEditingChanged];
    
    
    _codeTf = [[UITextField alloc]init];
    _codeTf.placeholder = @"输入6位验证码";
    _codeTf.textColor = NV_TITLE_COLOR;
    _codeTf.font = [UIFont systemFontOfSize:16];
    _codeTf.keyboardType = UIKeyboardTypeNumberPad;
    _codeTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_codeTf setValue:HTColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    
    [_bgView addSubview:_codeTf];
    [_codeTf addTarget:self action:@selector(codeTfInputChange) forControlEvents:UIControlEventEditingChanged];
    
    
    _secondBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _secondBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_secondBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [_secondBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_secondBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_secondBtn addTarget:self action:@selector(getCodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_secondBtn];
    
    UIButton *bindBtn = [[UIButton alloc]init];
    [bindBtn setTitle:@"确定" forState:UIControlStateNormal];
    [bindBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bindBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    bindBtn.layer.masksToBounds = YES;
    bindBtn.layer.cornerRadius = 22;
    bindBtn.backgroundColor = [RGBBlueColor colorWithAlphaComponent:0.5];
    [_bgView addSubview:bindBtn];
    [bindBtn addTarget:self action:@selector(bindBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _bindBtn = bindBtn;
    
    
    UIView *firstLine = [[UIView alloc]init];
    firstLine.backgroundColor = BORDER_LINE_COLOR;
    [_phoneTf addSubview:firstLine];
    
    UIView *secondLine = [[UIView alloc]init];
    secondLine.backgroundColor = BORDER_LINE_COLOR;
    [_bgView addSubview:secondLine];
    
    // top
    CGFloat top = 60;
    
    //约束
    [_phoneTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(40*ratioWidth);
        make.top.equalTo(self.view).offset(top);
        make.right.equalTo(self.view).offset(-40*ratioWidth-120);
        make.height.equalTo(@(30));
    }];
    
    [_secondBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-40*ratioWidth);
        make.height.equalTo(@(30));
        make.width.equalTo(@(100));
        make.centerY.equalTo(_phoneTf.mas_centerY);
    }];
    
    [firstLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_phoneTf.mas_left);
        make.bottom.equalTo(_phoneTf.mas_bottom).offset(5);
        make.right.equalTo(self.view).offset(-40*ratioWidth);
        make.height.equalTo(@(1));
    }];
    
    [_codeTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_phoneTf.mas_left);
        make.right.equalTo(self.view).offset(-40*ratioWidth);
        make.top.equalTo(_phoneTf.mas_bottom).offset(30);
        make.height.equalTo(_phoneTf.mas_height);
    }];
    
    [secondLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_codeTf.mas_left);
        make.bottom.equalTo(_codeTf.mas_bottom).offset(5);
        make.right.equalTo(_codeTf.mas_right);
        make.height.equalTo(@(1));
    }];
    
    //约束
    [_companyTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(40*ratioWidth);
        make.top.equalTo(_codeTf.mas_bottom).offset(93);
        make.right.equalTo(self.view).offset(-40*ratioWidth);
        make.height.equalTo(@(30));
    }];
    UIView *companyLine = [_companyTf viewWithTag:1000];
    [companyLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_companyTf);
        make.bottom.equalTo(_companyTf).offset(5);
        make.right.equalTo(_companyTf);
        make.height.equalTo(@(1));
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
        make.height.equalTo(@(1));
    }];
    
    
    
    CGFloat btnHeight = iPad ? 50 : 45;
    [bindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(45*ratioWidth);
        make.right.equalTo(self.view).offset(-45*ratioWidth);
        make.height.equalTo(@(btnHeight));
        make.top.equalTo(_zhiweiTf.mas_bottom).offset(58);
    }];
    
    [self createRoleView];
    
    [_bgView addSubview:_roleView];
}

- (void)createRoleView{
    
    UIView *roleView = [[UIView alloc]initWithFrame:CGRectMake(40*ratioWidth, 160, SCREENW-80*ratioWidth, 62)];
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 50, 50)];
    [title labelWithFontSize:16 textColor:H999999];
    title.text = @"角色：";
    [roleView addSubview:title];
    title.tag = 900;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 61, roleView.width, 1)];
    line.backgroundColor = BORDER_LINE_COLOR;
    [roleView addSubview:line];
    
    NSArray *btnTitles = @[@"投资人",@"创业者",@"FA",@"其他"];
    CGFloat width = 56;
    CGFloat height = 28;
    CGFloat left = 50;
    for (int i=0; i<btnTitles.count; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(left+i*(width+8), 10, width, height)];
        [btn setTitleColor:H9COLOR forState:UIControlStateNormal];
        [btn setTitle:btnTitles[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.layer.cornerRadius = height/2.0;
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        btn.layer.borderWidth = 1;
        btn.tag = 1000 + i;
        [roleView addSubview:btn];
        btn.centerY = title.centerY;
        [btn addTarget:self action:@selector(roleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    _roleView = roleView;
}
#pragma mark --Event--
- (void)roleBtnClick:(UIButton*)btn{
    if (_lastSelBtn) {
        [_lastSelBtn setTitleColor:H3COLOR forState:UIControlStateNormal];
        _lastSelBtn.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        _lastSelBtn.backgroundColor = [UIColor whiteColor];
    }else{
        for (UIView *subV in _roleView.subviews) {
            if ([subV isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton*)subV;
                [btn setTitleColor:H3COLOR forState:UIControlStateNormal];
            }
        }
    }
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
    btn.backgroundColor = BLUE_TITLE_COLOR;
    _lastSelBtn = btn;
    UILabel *title = [_roleView viewWithTag:900];
    title.textColor = H3COLOR;
    [self codeTfInputChange];
}

- (void)getCodeBtnClick{
    
    QMPLog(@"%s", __func__);
    if (![_secondBtn.titleLabel.text isEqualToString:@"获取验证码"]) {
        return;
    }
    
    if (![PublicTool checkTel:_phoneTf.text]) {
        return;
    }
    [PublicTool showHudWithView:KEYWindow];
    if (_timer) {
        QMPLog(@"_timv");
        [_secondBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [_secondBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        _totalSecond = 60;
        [_timer invalidate];
        _timer = nil;
    }
    
    //验证手机号
    [AppNetRequest verifyPhoneWithParameter:@{@"tel":_phoneTf.text} completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            
            [self beginDaojishi];
            
            [self getPhoneCode];
            
        }else if(resultData){
            if ([PublicTool isNull:resultData[@"msg"]]) {
                [PublicTool showMsg:@"操作过于频繁"];
            }else{
                [PublicTool showMsg:resultData[@"msg"]];
                
            }
        }
    }];
    [_codeTf becomeFirstResponder];
}

- (void)getPhoneCode{
    
    
    //后台验证码
    [AppNetRequest getVerifyCodeWithParameter:@{@"mobile":_phoneTf.text} completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && resultData[@"code"]) {
            
            
            //            _code = resultData[@"code"];
            
        }else{
            if ([PublicTool isNull:resultData[@"msg"]]) {
                //                [PublicTool showMsg:@"操作过于频繁"];
            }else{
                
                if ( ![resultData[@"msg"] isEqualToString:@"success"]) {
                    
                    [PublicTool showMsg:resultData[@"msg"]];
                }
            }
        }
    }];
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
    
    if (_codeTf.text.length == 6 && _phoneTf.text.length == 11 && _lastSelBtn) {
        
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
    NSDictionary *param = @{@"tel":_phoneTf.text,@"code":_codeTf.text};
    
    [AppNetRequest verifyCodeWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && [PublicTool isNull:resultData[@"msg"]]) {
            [self bindPhoneAction];
            return;
        }else if (resultData && [resultData[@"msg"] isEqualToString:@"验证码过期"]){
            [PublicTool showMsg:@"验证码过期"];
        }else{
            [PublicTool showMsg:@"验证码错误"];
        }
        
        [PublicTool dismissHud:KEYWindow];
        
    }];
    
}


- (void)bindPhoneAction{
    
    NSArray *roles = @[@"投资人",@"创业者",@"FA",@"其他"];
    NSInteger roleType = [roles indexOfObject:_lastSelBtn.titleLabel.text]+1;
    NSString *phone = [_phoneTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary *param = @{@"tel":phone,@"company":[PublicTool isNull:_companyTf.text]?@"":_companyTf.text,@"zhiwei":[PublicTool isNull:_zhiweiTf.text]?@"":_zhiweiTf.text,@"role_type":@(roleType)};
    
    [AppNetRequest userBindPhoneWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData && [PublicTool isNull:resultData[@"msg"]]) {
            [WechatUserInfo shared].bind_flag = @"1";
            [WechatUserInfo shared].phone = phone;
            [PublicTool showMsg:@"绑定成功"];
            
            [self popSelf];
            
        }else{
            [PublicTool showMsg:@"绑定失败"];
        }
        
    }];
    [QMPEvent event:@"login_bindphone_sure"];

}

- (void)skipBtnClick{
    [self popSelf];
    [QMPEvent event:@"login_bindphone_skip"];
}

- (void)popSelf{
    [self.navigationController popToRootViewControllerAnimated:YES];;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
