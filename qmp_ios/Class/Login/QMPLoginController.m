//
//  QMPLoginController.m
//  qmp_ios
//
//  Created by QMP on 2018/11/7.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "QMPLoginController.h"
#import "AppDelegate.h"
#import <CommonLibrary/WechatUserInfo.h>
#import "QMPPhoneLoginController.h"
#import <CommonLibrary/PrivatePolicyView.h>

@interface QMPLoginController ()<UITextFieldDelegate>
{
    AppDelegate *_appDelegate;
    UIView *_accountView;
    UITextField *_nameTextF;
    UITextField *_passwdTextF;
    UIView *registerV;
    UITextField* nameTextF;
    UITextField* passwdTextF;
    UITextField* passwdTextF1;
}

@property (strong, nonatomic) GetNowTime *getNowTimeTool;

@property (strong,nonatomic) UIButton *wechatLoginBtn;
@property (strong,nonatomic) UIView *wechatLoginView;
@property (strong,nonatomic) UIButton *phoneLoginBtn;

@end

@implementation QMPLoginController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideNavigationBarLine];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];//
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    BOOL flag = [[NSUserDefaults standardUserDefaults] boolForKey:APPVERSION_CHECKSTATUS];
    if (flag) {
        [PrivatePolicyView showPolicyView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self buildLoginVCUI];
    
}



-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self showNavigationBarLine];
}

-(void)dismiss{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc{
    //移除所有监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark ---UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //textField关闭键盘
    [textField resignFirstResponder];
    //方法二
    //    [self.view endEditing:NO];//结束编辑 当前view不能编辑，它上边的子控件也不能编辑。
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //    [textField becomeFirstResponder];
    return YES;
}
#pragma mark - 警告框
-(void)launchAlert:(NSString *)str {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}
//登录 或 注册
- (void)imitateLogin:(UIButton *)sender{
    
    if (sender.tag == 300) {
        [_nameTextF resignFirstResponder];
        [_passwdTextF resignFirstResponder];
    }
    if (sender.tag == 301) {
        [nameTextF resignFirstResponder];
        [passwdTextF resignFirstResponder];
        [passwdTextF1 resignFirstResponder];
    }
    
    if ((_nameTextF.text.length<=0&&sender.tag==300)||(nameTextF.text.length<=0&&sender.tag==301)) {
        [self launchAlert:@"账号为空"];
        return;
    }
    /* 未做手机号检测*/
    if ((![PublicTool isMobileNumber:_nameTextF.text]&&sender.tag==300)||(![PublicTool isMobileNumber:nameTextF.text]&&sender.tag==301)) {
        [self launchAlert:@"手机号不合法"];
        return;
    }
    if ((_passwdTextF.text.length<=0&&sender.tag==300)||(passwdTextF.text.length<=0&&sender.tag==301)) {
        [self launchAlert:@"密码为空"];
        return;
    }
    if (sender.tag == 301) {
        if (passwdTextF1.text.length<=0) {
            [self launchAlert:@"重复密码为空"];
            return;
        }
        if (![passwdTextF.text isEqualToString:passwdTextF1.text]) {
            [self launchAlert:@"两次输入密码不一致"];
            return;
        }
    }
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString *unionid = nil;
    if (sender.tag == 300) {
        unionid = [NSString stringWithFormat:@"%@|%@",_nameTextF.text,_passwdTextF.text];
    }
    if (sender.tag == 301) {
        unionid = [NSString stringWithFormat:@"%@|%@",nameTextF.text,passwdTextF.text];
    }
    [mDict setValue:@"qmp_ios" forKey:@"ptype"];
    [mDict setValue:[NSString stringWithFormat:@"%@",VERSION] forKey:@"version"];
    [mDict setValue:unionid forKey:@"unionid"];
    
    [PublicTool showHudWithView:KEYWindow];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"wxiosbeta/basicInfo" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        if (resultData) {
            NSDictionary *dataDic = resultData;
            if ([dataDic isKindOfClass:[NSDictionary class]]) {
                //如果获取到了用户信息,则认为用户成功登陆 (因为没有跳转微信,所以需要把unionid添加进来)
                
                [self storePersonInfoToUserDefaultWhenLoginSuccess:dataDic];
                
                [[NSNotificationCenter defaultCenter]  postNotificationName:NOTIFI_LOGIN object:nil userInfo:@{@"isLogin":@"YES"}];
                
            }
            [self dismiss];
        }
    }];
    
}

/**
 登录后将个人信息存储到本地
 */
- (void)storePersonInfoToUserDefaultWhenLoginSuccess:(NSDictionary *)infoDict{
    NSString *dayCountStr = [NSString stringWithFormat:@"%d",(int)([infoDict[@"jifen"] integerValue] /10)];
    WechatUserInfo *userModel = [WechatUserInfo shared];
    [userModel setValuesForKeysWithDictionary:infoDict];
    [userModel save];
    
}

- (void)goRegister:(UIButton *)sender{
    
    registerV = [[UIView alloc]initWithFrame:self.view.frame];
    registerV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:registerV];
    [self.view bringSubviewToFront:registerV];
    
    UIImageView *loginNameImgV = [[UIImageView alloc]initWithFrame:CGRectMake(30, 100, 30, 29)];
    loginNameImgV.image = [UIImage imageNamed:@"loginPhone"];
    [registerV addSubview:loginNameImgV];
    
    nameTextF = [[UITextField alloc]initWithFrame:CGRectMake(loginNameImgV.frame.origin.x+loginNameImgV.frame.size.width+5, loginNameImgV.frame.origin.y, _accountView.frame.size.width-5-(loginNameImgV.frame.size.width+loginNameImgV.frame.origin.x)-60, loginNameImgV.frame.size.height)];
    nameTextF.delegate = self;
    nameTextF.font = [UIFont systemFontOfSize:13];
    nameTextF.placeholder = @"请填写您的手机号";
    nameTextF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    //设置显示模式为永远显示(默认不显示)
    nameTextF.leftViewMode = UITextFieldViewModeAlways;
    nameTextF.textAlignment = NSTextAlignmentLeft;
    [registerV addSubview:nameTextF];
    
    UIView *lineV1 = [[UIView alloc]initWithFrame:CGRectMake(loginNameImgV.frame.origin.x, loginNameImgV.frame.origin.y+loginNameImgV.frame.size.height+1, SCREENW-60, 1)];
    lineV1.backgroundColor = [UIColor lightGrayColor];
    [registerV addSubview:lineV1];
    
    UIImageView *loginPassImgV = [[UIImageView alloc]initWithFrame:CGRectMake(loginNameImgV.frame.origin.x, loginNameImgV.frame.origin.y+loginNameImgV.frame.size.height+10, 30, 29)];
    loginPassImgV.image = [UIImage imageNamed:@"loginPass"];
    [registerV addSubview:loginPassImgV];
    
    passwdTextF = [[UITextField alloc]initWithFrame:CGRectMake(_nameTextF.frame.origin.x, loginPassImgV.frame.origin.y, _nameTextF.frame.size.width, _nameTextF.frame.size.height)];
    passwdTextF.secureTextEntry = YES;
    passwdTextF.delegate = self;
    passwdTextF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    //设置显示模式为永远显示(默认不显示)
    passwdTextF.leftViewMode = UITextFieldViewModeAlways;
    passwdTextF.font = [UIFont systemFontOfSize:13];
    passwdTextF.placeholder = @"请填写密码";
    passwdTextF.textAlignment = NSTextAlignmentLeft;
    [registerV addSubview:passwdTextF];
    
    UIView *lineV2 = [[UIView alloc]initWithFrame:CGRectMake(loginPassImgV.frame.origin.x, loginPassImgV.frame.origin.y+loginPassImgV.frame.size.height+1, SCREENW-60, 1)];
    lineV2.backgroundColor = [UIColor lightGrayColor];
    [registerV addSubview:lineV2];
    
    UIImageView *loginPassAgainImgV = [[UIImageView alloc]initWithFrame:CGRectMake(loginNameImgV.frame.origin.x, loginPassImgV.frame.origin.y+loginPassImgV.frame.size.height+10, 30, 29)];
    loginPassAgainImgV.image = [UIImage imageNamed:@"loginPass"];
    [registerV addSubview:loginPassAgainImgV];
    
    passwdTextF1 = [[UITextField alloc]initWithFrame:CGRectMake(_nameTextF.frame.origin.x, loginPassAgainImgV.frame.origin.y, _nameTextF.frame.size.width, _nameTextF.frame.size.height)];
    passwdTextF1.secureTextEntry = YES;
    passwdTextF1.delegate = self;
    passwdTextF1.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    //设置显示模式为永远显示(默认不显示)
    passwdTextF1.leftViewMode = UITextFieldViewModeAlways;
    passwdTextF1.font = [UIFont systemFontOfSize:13];
    passwdTextF1.placeholder = @"请重复密码";
    passwdTextF1.textAlignment = NSTextAlignmentLeft;
    [registerV addSubview:passwdTextF1];
    
    UIView *lineV3 = [[UIView alloc]initWithFrame:CGRectMake(loginPassAgainImgV.frame.origin.x, loginPassAgainImgV.frame.origin.y+loginPassAgainImgV.frame.size.height+1, SCREENW-60, 1)];
    lineV3.backgroundColor = [UIColor lightGrayColor];
    [registerV addSubview:lineV3];
    
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake(50, loginPassAgainImgV.frame.size.height+loginPassAgainImgV.frame.origin.y+100, SCREENW-100, 50);
    registerBtn.backgroundColor = RGB(103, 155, 253, 1);
    registerBtn.tag = 301;
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [registerBtn.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [registerBtn addTarget:self action:@selector(imitateLogin:) forControlEvents:UIControlEventTouchUpInside];
    registerBtn.layer.cornerRadius = 5;
    registerBtn.layer.masksToBounds = YES;
    registerBtn.layer.borderWidth = 1;
    registerBtn.layer.borderColor = RGBLineGray.CGColor;
    [registerV addSubview:registerBtn];
    
    //取消 错号
    UIButton* cancelWechatRegisterBtn = [FactoryUI createButtonWithFrame:CGRectMake((SCREENW-30)/2, SCREENH-80, 30, 30) title:@"" titleColor:[UIColor blackColor] imageName:@"" backgroundImageName:@"close2" target:self selector:@selector(cancelWechatRegister:)];
    
    [registerV addSubview:cancelWechatRegisterBtn];
}
-(void)cancelWechatRegister:(UIButton *)sender{
    
    [registerV removeFromSuperview];
}
-(void)buildLoginVCUI{
    
    self.view.frame = CGRectMake(0, 0, SCREENW, SCREENH);
    self.view.backgroundColor = [UIColor whiteColor];
    //    //取消 错号
    //    _cancelWechatLoginBtn = [FactoryUI createButtonWithFrame:CGRectMake(SCREENW - 57, 17, 44, 44) title:@"" titleColor:[UIColor blackColor] imageName:@"" backgroundImageName:@"" target:self selector:@selector(cancelWechatLogin:)];
    //    [_cancelWechatLoginBtn.imageView setFrame:CGRectMake(20, 20, 20, 20)];
    //    [_cancelWechatLoginBtn setImage:[UIImage imageNamed:@"loginclose"] forState:UIControlStateNormal];
    //
    //    [self.view addSubview:_cancelWechatLoginBtn];
    
    UIImageView *iconImgV = [[UIImageView alloc]initWithFrame:CGRectMake((SCREENW-90)/2, 20*ratioHeight, 90, 90)];
    [self.view addSubview:iconImgV];
    iconImgV.image = [UIImage imageNamed:@"qmp"];
    
    UILabel *iconDescLab = [[UILabel alloc]initWithFrame:CGRectMake(30, iconImgV.bottom + 25*ratioHeight , SCREENW-60, 25)];
    iconDescLab.text = @"企名片  更好用";
    iconDescLab.textColor = HTColorFromRGB(0x555555);
    iconDescLab.textAlignment = NSTextAlignmentCenter;
    iconDescLab.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:iconDescLab];
    
    _accountView = [[UIView alloc]initWithFrame:CGRectMake(0, iconDescLab.bottom+35*ratioHeight, SCREENW, SCREENH-(iconDescLab.bottom+50*ratioHeight))];
    [self.view addSubview:_accountView];
    
    UIImageView *mapImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 193*ratioHeight)];
    mapImgV.image = [UIImage imageNamed:@"login_map"];
    
    UIImageView *loginNameImgV = [[UIImageView alloc]initWithFrame:CGRectMake(30, 0, 30, 29)];
    loginNameImgV.image = [UIImage imageNamed:@"loginPhone"];
    
    _nameTextF = [[UITextField alloc]initWithFrame:CGRectMake(loginNameImgV.frame.origin.x+loginNameImgV.frame.size.width+5, loginNameImgV.frame.origin.y, _accountView.frame.size.width-5-(loginNameImgV.frame.size.width+loginNameImgV.frame.origin.x)-60, loginNameImgV.frame.size.height)];
    _nameTextF.delegate = self;
    _nameTextF.font = [UIFont systemFontOfSize:16];
    _nameTextF.placeholder = @"手机号";
    _nameTextF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    //设置显示模式为永远显示(默认不显示)
    _nameTextF.leftViewMode = UITextFieldViewModeAlways;
    _nameTextF.textAlignment = NSTextAlignmentLeft;
    
    UIView *lineV1 = [[UIView alloc]initWithFrame:CGRectMake(loginNameImgV.frame.origin.x, loginNameImgV.frame.origin.y+loginNameImgV.frame.size.height+1, SCREENW-60, 1)];
    lineV1.backgroundColor = [UIColor lightGrayColor];
    
    UIImageView *loginPassImgV = [[UIImageView alloc]initWithFrame:CGRectMake(loginNameImgV.frame.origin.x, loginNameImgV.frame.origin.y+loginNameImgV.frame.size.height+10, 30, 29)];
    
    loginPassImgV.image = [UIImage imageNamed:@"loginPass"];
    
    _passwdTextF = [[UITextField alloc]initWithFrame:CGRectMake(_nameTextF.frame.origin.x, loginPassImgV.frame.origin.y, _nameTextF.frame.size.width, _nameTextF.frame.size.height)];
    _passwdTextF.secureTextEntry = YES;
    _passwdTextF.delegate = self;
    _passwdTextF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    //设置显示模式为永远显示(默认不显示)
    _passwdTextF.leftViewMode = UITextFieldViewModeAlways;
    _passwdTextF.font = [UIFont systemFontOfSize:16];
    _passwdTextF.placeholder = @"密码";
    _passwdTextF.textAlignment = NSTextAlignmentLeft;
    
    UIView *lineV2 = [[UIView alloc]initWithFrame:CGRectMake(loginPassImgV.frame.origin.x, loginPassImgV.frame.origin.y+loginPassImgV.frame.size.height+1, SCREENW-60, 1)];
    lineV2.backgroundColor = [UIColor lightGrayColor];
    
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(30, loginPassImgV.frame.size.height+loginPassImgV.frame.origin.y+50, SCREENW-60, 40);
    loginBtn.backgroundColor = RGB(22, 153, 154, 1);
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    loginBtn.tag = 300;
    [loginBtn addTarget:self action:@selector(imitateLogin:) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.layer.cornerRadius = 5;
    loginBtn.layer.masksToBounds = YES;
    loginBtn.layer.borderWidth = 1;
    loginBtn.layer.borderColor = RGBLineGray.CGColor;
    
    _wechatLoginBtn = [FactoryUI createButtonWithFrame:CGRectMake(loginBtn.frame.origin.x,loginBtn.frame.origin.y+loginBtn.frame.size.height+10, loginBtn.frame.size.width, loginBtn.frame.size.height) title:@"微信登录" titleColor:[UIColor whiteColor] imageName:@"" backgroundImageName:@"" target:self selector:@selector(wechatlogin:)];
    [_wechatLoginBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    _wechatLoginBtn.backgroundColor = RGB(134, 217, 82, 1);
    _wechatLoginBtn.layer.cornerRadius = 5;
    _wechatLoginBtn.layer.masksToBounds = YES;
    _wechatLoginBtn.layer.borderWidth = 1;
    _wechatLoginBtn.layer.borderColor = RGBLineGray.CGColor;
    
    _phoneLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _phoneLoginBtn.frame = CGRectMake(30, _wechatLoginBtn.bottom+24, SCREENW-60, 40);
    NSAttributedString *atitle = [[NSAttributedString alloc] initWithString:@"手机验证码登录(已注册用户)"
                                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                              NSForegroundColorAttributeName:HTColorFromRGB(0xa2a4a8),
                                                                              NSUnderlineStyleAttributeName: @YES,
                                                                              }];
    [_phoneLoginBtn addTarget:self action:@selector(phoneLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_phoneLoginBtn setAttributedTitle:atitle forState:UIControlStateNormal];
    
    //注册
    UIButton *registerBtn  = [FactoryUI createButtonWithFrame:CGRectMake(loginBtn.frame.origin.x,_wechatLoginBtn.frame.origin.y+_wechatLoginBtn.frame.size.height+10, loginBtn.frame.size.width, loginBtn.frame.size.height) title:@"快速注册" titleColor:[UIColor whiteColor] imageName:@"" backgroundImageName:@"" target:self selector:@selector(goRegister:)];
    [registerBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    registerBtn.backgroundColor = RGB(103, 155, 253, 1);
    registerBtn.layer.cornerRadius = 5;
    registerBtn.layer.masksToBounds = YES;
    registerBtn.layer.borderWidth = 1;
    registerBtn.layer.borderColor = RGBLineGray.CGColor;
    
    BOOL flag = [[NSUserDefaults standardUserDefaults] boolForKey:APPVERSION_CHECKSTATUS];
    //返回YES
    
    if (flag) {
        [_accountView addSubview:loginNameImgV];
        [_accountView addSubview:_nameTextF];
        [_accountView addSubview:lineV1];
        [_accountView addSubview:loginPassImgV];
        [_accountView addSubview:_passwdTextF];
        [_accountView addSubview:lineV2];
        [_accountView addSubview:loginBtn];
        [_accountView addSubview:_wechatLoginBtn];
        [_accountView addSubview:registerBtn];
    }else{
        
        [_wechatLoginBtn setFrame:CGRectMake(48*ratioWidth,mapImgV.bottom + 20*ratioWidth, SCREENW - 48*ratioWidth*2, 48*ratioWidth)];
        _wechatLoginBtn.backgroundColor = RGBBlueColor;
        _wechatLoginBtn.layer.cornerRadius = 22*ratioWidth;
        [_wechatLoginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _wechatLoginBtn.layer.borderColor = RGBBlueColor.CGColor;
        _wechatLoginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_accountView addSubview:_wechatLoginBtn];
        [_accountView addSubview:mapImgV];
        
        _phoneLoginBtn.top = _wechatLoginBtn.bottom+24;
        [_accountView addSubview:_phoneLoginBtn];
    }
    
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


- (void)phoneLoginBtnClick:(UIButton *)button {
    QMPPhoneLoginController *phoneLoginVC = [[QMPPhoneLoginController alloc] init];
    [self.navigationController pushViewController:phoneLoginVC animated:YES];
}
- (void)cancelWechatLogin:(id)sender {
    
    if (![self.action isEqualToString:@"appDelegate"]) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }
    
}

- (void)wechatlogin:(id)sender {
    
    [self weixinLogin];
    
}
#pragma mark - 微信登录
-(void)weixinLogin{
    
    [[QMPWechatEvent shared] loginWechat];
}
#pragma mark - 设置弹出提示语
- (void)setupAlertController {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请先安装微信客户端" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:actionConfirm];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (GetNowTime *)getNowTimeTool{
    
    if (!_getNowTimeTool) {
        _getNowTimeTool = [[GetNowTime alloc] init];
    }
    
    return _getNowTimeTool;
}


@end
