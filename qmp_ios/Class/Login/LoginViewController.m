//
//  LoginViewController.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/26.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "LoginViewController.h"
#import "WXApi.h"
#import "WechatUserInfo.h"
#import "GetNowTime.h"
#import "GetMd5Str.h"
#import "FactoryUI.h"
#import "PrivatePolicyView.h"

@interface LoginViewController ()<UITextFieldDelegate>
{
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

@implementation LoginViewController
#define DEBUG_LOG FALSE

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideNavigationBarLine];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];//
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([USER_DEFAULTS boolForKey:APPVERSION_CHECKSTATUS]) {
        [PrivatePolicyView showPolicyView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

//登录
- (void)imitateLogin:(UIButton *)sender{
    
    [_nameTextF resignFirstResponder];
    [_passwdTextF resignFirstResponder];
    
    /* 未做手机号检测*/
    if (![PublicTool checkTel:_nameTextF.text]) {
        [self launchAlert:@"手机号不合法"];
        return;
    }
    if ((_passwdTextF.text.length<=0&&sender.tag==300)||(passwdTextF.text.length<=0&&sender.tag==301)) {
        [self launchAlert:@"密码为空"];
        return;
    }
    
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString *unionid = [NSString stringWithFormat:@"%@|%@",_nameTextF.text,_passwdTextF.text];
    
    [mDict setValue:@"qmp_ios" forKey:@"ptype"];
    [mDict setValue:[NSString stringWithFormat:@"%@",VERSION] forKey:@"version"];
    [mDict setValue:unionid forKey:@"unionid"];
    
    ManagerHud *hudTool = [[ManagerHud alloc] init];
    [hudTool addBlackBackgroundViewWithHud:self.view];
    
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"wxiosbeta/basicInfo" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [hudTool removeHudWithBackground];
        
        if (resultData) {
            NSDictionary *dataDic = resultData;
            if ([dataDic isKindOfClass:[NSDictionary class]]) {
                //unionid 和 uuid 都需要返回，app_focus
                
                [self storePersonInfoToUserDefaultWhenLoginSuccess:dataDic];
                
                [[NSNotificationCenter defaultCenter]  postNotificationName:NOTIFI_LOGIN object:nil userInfo:@{@"isLogin":@"YES"}];
            }
            
            if ([KEYWindow.rootViewController isKindOfClass:[UITabBarController class]]) {
                [[PublicTool topViewController].navigationController popToRootViewControllerAnimated:YES];
            }else{
                [[AppPageSkipTool shared] setRootController];
            }
            
        }
    }];
    
}

/**
 登录后将个人信息存储到本地
 */
- (void)storePersonInfoToUserDefaultWhenLoginSuccess:(NSDictionary *)infoDict{
    WechatUserInfo *userModel = [WechatUserInfo shared];
    [userModel setValuesForKeysWithDictionary:infoDict];
    userModel.bind_flag = @"1";
    [userModel save];
    
}

-(void)buildLoginVCUI{
    
    self.view.frame = CGRectMake(0, 0, SCREENW, SCREENH);
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *iconImgV = [[UIImageView alloc]initWithFrame:CGRectMake((SCREENW-90)/2, 20*ratioHeight, 90, 90)];
    [self.view addSubview:iconImgV];
    iconImgV.image = [UIImage imageNamed:@"qmp"];
    
    UILabel *iconDescLab = [[UILabel alloc]initWithFrame:CGRectMake(30, iconImgV.bottom + 25*ratioHeight , SCREENW-60, 25)];
    iconDescLab.text = @"企名片  商业信息服务平台";
    iconDescLab.textColor = HTColorFromRGB(0x555555);
    iconDescLab.textAlignment = NSTextAlignmentCenter;
    iconDescLab.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:iconDescLab];
    
    //审核时候的手机登录
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
    
    
    if ([WXApi isWXAppInstalled]) { //检查微信是否已被用户安装,微信已安装
        //返回YES
        
        if ([USER_DEFAULTS boolForKey:APPVERSION_CHECKSTATUS]) {
            [_accountView addSubview:loginNameImgV];
            [_accountView addSubview:_nameTextF];
            [_accountView addSubview:lineV1];
            [_accountView addSubview:loginPassImgV];
            [_accountView addSubview:_passwdTextF];
            [_accountView addSubview:lineV2];
            [_accountView addSubview:loginBtn];
            [_accountView addSubview:_wechatLoginBtn];
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
        
    }else{
        if ([USER_DEFAULTS boolForKey:APPVERSION_CHECKSTATUS]) {
            [_accountView addSubview:loginNameImgV];
            [_accountView addSubview:_nameTextF];
            [_accountView addSubview:lineV1];
            [_accountView addSubview:loginPassImgV];
            [_accountView addSubview:_passwdTextF];
            [_accountView addSubview:lineV2];
            [_accountView addSubview:loginBtn];
            
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
    [[AppPageSkipTool shared] appPageSkipToBindPhone];
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
    
    if ([WXApi isWXAppInstalled]) {  //用户安装了微信客户端
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setValue:@"1" forKey:@"clickLogin"];
        [userDefaults synchronize];
        
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo,snsapi_base";
        req.state = @"qmp";
        [WXApi sendReq:req];
    }
    else {
        [self setupAlertController]; //弹出提示框
        
    }
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
