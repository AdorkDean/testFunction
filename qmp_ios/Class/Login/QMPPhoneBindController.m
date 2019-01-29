//
//  QMPPhoneBindController.m
//  qmp_ios
//
//  Created by QMP on 2018/11/7.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "QMPPhoneBindController.h"

@interface QMPPhoneBindController ()
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
    UIButton *_skipBtn;
    BOOL _newUser;
}
@end

@implementation QMPPhoneBindController

-(void)dealloc{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!_newUser) {
        [self hideNavigationBarLine];
    }else{
        [QMPEvent beginEvent:@"login_bindphone_timer"];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (!_newUser) {
        [self showNavigationBarLine];
    }else{
        [QMPEvent endEvent:@"login_bindphone_timer"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    //首次登陆
//    if (![WechatUserInfo shared].bind_flag || [WechatUserInfo shared].bind_flag.integerValue == 0) {
//        _newUser = YES;
//        id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
//        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
//        [self.view addGestureRecognizer:pan];
//    }

    _newUser = NO;
    
    [self addView];
    
    if (_newUser) {
        self.title = @"完善个人信息";
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithCustomView:[[UIView alloc]init]];
        self.navigationItem.leftBarButtonItems = @[barItem];
        id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
        [self.view addGestureRecognizer:pan];
        [QMPEvent event:@"login_bindphone"];
    }else{
        self.title = @"绑定手机号";
        self.navigationItem.leftBarButtonItems = [self createBackButton];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
#pragma mark ---UI
- (NSArray*)createBackButton{
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:LEFTBUTTONFRAME];
    [leftButton setImage:[UIImage imageNamed:@"left-arrow"] forState:UIControlStateNormal];
    //    [leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [leftButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)popSelf{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)addView{
    
    //首次登录 需要公司和职位
    if (_newUser) {
        
        // 顶部提示
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 50)];
        label.textAlignment = NSTextAlignmentCenter;
        [label labelWithFontSize:12 textColor:H9COLOR];
        label.text = @"完善个人信息可查看更多内容";
        [self.view addSubview:label];
        
        _companyTf = [[UITextField alloc]init];
        _companyTf.placeholder = @"您所在的公司或机构";
        _companyTf.textColor = NV_TITLE_COLOR;
        _companyTf.font = [UIFont systemFontOfSize:16];
        _companyTf.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_companyTf setValue:HTColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
        [self.view addSubview:_companyTf];
        
        UIView *companyTfLine = [[UIView alloc]init];
        companyTfLine.backgroundColor = BORDER_LINE_COLOR;
        [_companyTf addSubview:companyTfLine];
        companyTfLine.tag = 1000;
        
        _zhiweiTf = [[UITextField alloc]init];
        _zhiweiTf.placeholder = @"您的职位";
        _zhiweiTf.textColor = NV_TITLE_COLOR;
        _zhiweiTf.font = [UIFont systemFontOfSize:16];
        _zhiweiTf.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_zhiweiTf setValue:HTColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
        [self.view addSubview:_zhiweiTf];
        
        UIView *zhiweiTfLine = [[UIView alloc]init];
        zhiweiTfLine.backgroundColor = BORDER_LINE_COLOR;
        [_zhiweiTf addSubview:zhiweiTfLine];
        zhiweiTfLine.tag = 1000;
        
    }
    
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
    [bindBtn setTitle:@"绑定手机" forState:UIControlStateNormal];
    [bindBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bindBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    bindBtn.layer.masksToBounds = YES;
    bindBtn.layer.cornerRadius = 22;
    bindBtn.backgroundColor = [RGBBlueColor colorWithAlphaComponent:0.5];
    [self.view addSubview:bindBtn];
    [bindBtn addTarget:self action:@selector(bindBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _bindBtn = bindBtn;
    
    _skipBtn = [[UIButton alloc]init];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"跳过"];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:H9COLOR range:strRange];
    [_skipBtn setAttributedTitle:str forState:UIControlStateNormal];
    
    _skipBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:_skipBtn];
    [_skipBtn addTarget:self action:@selector(skipBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *firstLine = [[UIView alloc]init];
    firstLine.backgroundColor = BORDER_LINE_COLOR;
    [_phoneTf addSubview:firstLine];
    
    UIView *secondLine = [[UIView alloc]init];
    secondLine.backgroundColor = BORDER_LINE_COLOR;
    [self.view addSubview:secondLine];
    
    // top
    CGFloat top = 122*ratioWidth;
    if (_newUser) {
        //约束
        [_companyTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(40*ratioWidth);
            make.top.equalTo(self.view).offset(80*ratioWidth);
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
        
        top = 100*ratioWidth + 120;
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
    
    [_skipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bindBtn.mas_centerX);
        make.width.equalTo(@(70));
        make.height.equalTo(@(btnHeight));
        make.top.equalTo(bindBtn.mas_bottom);
    }];
    
    if (_newUser) {
        _skipBtn.hidden = NO;
    }else{
        _skipBtn.hidden = YES;
    }
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
    if (_newUser) {
        [QMPEvent event:@"login_bindphone_sure"];
    }
}

- (void)skipBtnClick{
    [self popSelf];
    if (_newUser) {
        [QMPEvent event:@"login_bindphone_skip"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
