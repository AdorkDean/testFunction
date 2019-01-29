//
//  AllFeedbackViewController.m
//  qmp_ios
//
//  Created by molly on 2017/3/23.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "AllFeedbackViewController.h"
#import "ManagerAlertView.h"

@interface AllFeedbackViewController ()<UITextViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) UIView *plateView;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UILabel *placeholderLab;
@property (strong, nonatomic) UITextField *lianxiTextField;

@end

@implementation AllFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildRightBarButtonItem];
    [self buildTitleView];
    [self buildUI];
    [self keyboardManager];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public
-(void)keyboardManager{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)keyboardHide:(UITapGestureRecognizer*)tap{
    if (tap.view != _textView && tap.view !=_lianxiTextField) {
        [self.view endEditing:NO];
    }
}

- (void)buildRightBarButtonItem{

    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"提交" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [rightBtn setTitleColor:NV_OTHERTITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(pressSubmitFeedbackBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)pressSubmitFeedbackBtn:(UIBarButtonItem *)sender{

    [self requestFeedback];
}

- (void)buildTitleView{

    NSString *title = @"意见反馈";
    if (self.flag) {
        title = @"吐槽/爆料";
    }else if (self.module && [self.module isEqualToString:@"更多相似项目"]){
        title = @"更多相似项目";
    }
    self.title = title;
}

- (void)buildUI{
    
    UIScrollView *mainView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    mainView.contentSize = CGSizeMake(0, SCREENH * 1.0);
    mainView.scrollEnabled = YES;
    [self.view addSubview:mainView];

    CGFloat margin = 10.f;
    CGFloat feedbackY = 0.f;
    CGFloat callW = 50.f;
    CGFloat callH = 20.f;
    CGFloat callVW = SCREENW - margin *2;
    CGFloat feedbackH = 30.f;
    UIView *callView  = [[UIView alloc] init];
    [mainView addSubview:callView];
    
    if (self.flag) {
        //爆料不显示联系电话
        callView.frame = CGRectMake(margin, 0,callVW , feedbackH);
    }
    else{
        callView.frame = CGRectMake(margin, margin,callVW , callH * 2 + feedbackH);
        
        UIFont *infoFont = [UIFont systemFontOfSize:14.f];
        UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, callVW, callH)];
        infoLbl.text = @"您可以直接通过邮箱联系我们!";
        infoLbl.font = infoFont;
        [callView addSubview:infoLbl];
        UILabel *tipLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, callH, 42, callH)];
        tipLbl.text = @"邮箱:";
        tipLbl.textAlignment = NSTextAlignmentLeft;
        tipLbl.font = infoFont;
        [callView addSubview:tipLbl];
        UIButton *emailBtn = [[UIButton alloc] initWithFrame:CGRectMake(tipLbl.frame.origin.x + tipLbl.frame.size.width, callH, 200, callH)];
        [emailBtn setTitle:EMAIL forState:UIControlStateNormal];
        [emailBtn setTitleColor:RGBa(58, 153, 216, 1)  forState:UIControlStateNormal];
        emailBtn.titleLabel.font = infoFont;
        emailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [emailBtn addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEmail)];
        emailBtn.userInteractionEnabled = YES;
        [emailBtn addGestureRecognizer:longPress];
        [callView addSubview:emailBtn];

        UIButton *sendEmailBtn = [[UIButton alloc] initWithFrame:CGRectMake(callVW - callW, callH,callW, callW)];
        [sendEmailBtn setImage:[BundleTool imageNamed:@"feedback_email"] forState:UIControlStateNormal];
        [sendEmailBtn addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
//        [callView addSubview:sendEmailBtn];

        
//        UIFont *infoFont = [UIFont systemFontOfSize:14.f];
//        UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, callVW, callH)];
//        infoLbl.text = @"您可以通过微信或者电话直接联系我们!";
//        infoLbl.font = infoFont;
//        [callView addSubview:infoLbl];
//        UILabel *tipLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, callH, 120, callH)];
//        tipLbl.text = @"CEO微信/手机号：";
//        tipLbl.textAlignment = NSTextAlignmentLeft;
//        tipLbl.font = infoFont;
//        [callView addSubview:tipLbl];
//        UIButton *teleBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, callH, 120, callH)];
//        [teleBtn setTitle:TELE forState:UIControlStateNormal];
//        [teleBtn setTitleColor:RGBa(58, 153, 216, 1)  forState:UIControlStateNormal];
//        teleBtn.titleLabel.font = infoFont;
//        teleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        [teleBtn addTarget:self action:@selector(makeACall) forControlEvents:UIControlEventTouchUpInside];
//        [callView addSubview:teleBtn];
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTele)];
//        teleBtn.userInteractionEnabled = YES;
//        [teleBtn addGestureRecognizer:longPress];
//        UIButton *callBtn = [[UIButton alloc] initWithFrame:CGRectMake(callVW - callW, callH,callW, callW)];
//        [callBtn setImage:[BundleTool imageNamed:@"feedback_call"] forState:UIControlStateNormal];
//        [callBtn addTarget:self action:@selector(makeACall) forControlEvents:UIControlEventTouchUpInside];
//        [callView addSubview:callBtn];
        
        feedbackY = tipLbl.frame.origin.y + tipLbl.frame.size.height;
    }
    
    UILabel *feedbackLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, feedbackY, SCREENW-margin * 2 - callW, feedbackH)];
    feedbackLbl.font = [UIFont systemFontOfSize:14.f];
    feedbackLbl.text = _from;
    feedbackLbl.numberOfLines = 2;
    feedbackLbl.userInteractionEnabled = NO;
    [callView addSubview:feedbackLbl];
    
    CGFloat supTextviewY = callView.frame.origin.y + callView.frame.size.height;
    
    if (_feedbackArr && _feedbackArr.count > 0) {
        
        //如果有可以选择的反馈的模块
        
        UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(callView.frame.origin.x, callView.frame.origin.y + callView.frame.size.height, feedbackLbl.frame.size.width, 20.f)];
        infoLbl.font = [UIFont systemFontOfSize:12.f];
        infoLbl.text = @"请选择需要反馈的模块";
        [mainView addSubview:infoLbl];
        
        NSInteger rowCount = (_feedbackArr.count + 3) / 4;
        CGFloat selectLblH = 25.f;
        CGFloat selectLblHMargin = 5.f;
        UIView *plateView = [[UIView alloc]initWithFrame:CGRectMake(margin, infoLbl.frame.origin.y + infoLbl.frame.size.height + 5, SCREENW - margin * 2, rowCount * selectLblH + (rowCount + 1 ) * selectLblHMargin )];
        plateView.layer.borderWidth = 0.5f;
        plateView.layer.borderColor = RGB(210, 209, 215, 1).CGColor;
        [mainView addSubview:plateView];
        _plateView = plateView;
        
        for (int i=0; i< rowCount; i++) {
            float btnW = (plateView.frame.size.width - 5 * 10) / 4;
            float btnY = i * ( selectLblHMargin + selectLblH ) + selectLblHMargin;
            for (int j = 0; j < 4; j++) {
                float btnX = j * (10 + btnW) + 10;
                if (i >= _feedbackArr.count / 4 && j >= _feedbackArr.count % 4) {
                    break;
                }
                
                NSString *btnTitle = _feedbackArr[i*4+j];
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(btnX, btnY, btnW, selectLblH);
                btn.titleLabel.font = [UIFont systemFontOfSize:13];
                [btn setTitle:btnTitle forState:UIControlStateNormal];
                
                btn.tag = 100 + i*4 + j;
                
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                [btn setBackgroundImage:[self imageWithColor:[UIColor orangeColor]] forState:UIControlStateSelected];
                
                [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                [btn setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                
                [btn addTarget:self action:@selector(changeButtonStatus:) forControlEvents:UIControlEventTouchUpInside];
                
                btn.layer.cornerRadius = 3;
                btn.layer.masksToBounds = YES;
                btn.layer.borderWidth = 0.5f;
                btn.layer.borderColor = [UIColor orangeColor].CGColor;
                [plateView addSubview:btn];
                
                if (_selectedFeedbackArr.count > 0 &&[_selectedFeedbackArr containsObject:btnTitle]) {
                    btn.selected = YES;
                }
            }
        }

        supTextviewY = plateView.frame.origin.y + plateView.frame.size.height + 5;
    }
    
    //下半部分输入框
    UIView *supTextView = [[UIView alloc]initWithFrame:CGRectMake(margin, supTextviewY, SCREENW-20, 140)];
    supTextView.layer.borderWidth = 0.5f;
    supTextView.layer.borderColor = RGB(210, 209, 215, 1).CGColor;
    [mainView addSubview:supTextView];

    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, SCREENW-20, 120)];
    textView.delegate = self;
    textView.font = [UIFont systemFontOfSize:13.f];
    textView.scrollEnabled = YES;
    [supTextView addSubview:textView];
    _textView = textView;
    
    UIButton *clearAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clearAllBtn.frame = CGRectMake(textView.frame.size.width-60, 115, 59, 25);
    [clearAllBtn setTitle:@"清除所有" forState:UIControlStateNormal];
    [clearAllBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [clearAllBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearAllBtn addTarget:self action:@selector(clearAllInfo:) forControlEvents:UIControlEventTouchUpInside];
    clearAllBtn.layer.borderWidth = 0.5f;
    clearAllBtn.layer.borderColor = RGB(210, 209, 215, 1).CGColor;
    clearAllBtn.layer.cornerRadius = 4;
    clearAllBtn.layer.masksToBounds = YES;
    [supTextView addSubview:clearAllBtn];
    
    UILabel *placeholderLab = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, textView.frame.size.width - 5, 20)];
    placeholderLab.enabled = NO;//lable必须设置为不可用
    placeholderLab.backgroundColor = [UIColor clearColor];//clearColor
    placeholderLab.font = [UIFont systemFontOfSize:13];
    [textView addSubview:placeholderLab];
    _placeholderLab = placeholderLab;
    
    [self toSetPlaceholderlblText];

    if (!self.flag) {
        
        //如果不是爆料,则显示输入联系方式
        UILabel *lianxiLbl = [[UILabel alloc] initWithFrame:CGRectMake(supTextView.frame.origin.x , supTextView.frame.origin.y + supTextView.frame.size.height + 20, SCREENW-20, 30)];
        lianxiLbl.text = @"联系方式";
        lianxiLbl.font = [UIFont systemFontOfSize:12];
        lianxiLbl.adjustsFontSizeToFitWidth = YES;
        lianxiLbl.userInteractionEnabled = NO;
        [mainView addSubview:lianxiLbl];

        UITextField *lxTextField = [[UITextField alloc] initWithFrame:CGRectMake(margin, lianxiLbl.frame.origin.y + lianxiLbl.frame.size.height + 5, SCREENW - margin * 2, 40)];
        lxTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
        lxTextField.leftViewMode = UITextFieldViewModeAlways;
        lxTextField.delegate = self;
        lxTextField.font = [UIFont systemFontOfSize:13];
        lxTextField.placeholder = @"手机号/QQ/微信";
        lxTextField.textAlignment = NSTextAlignmentLeft;
        lxTextField.layer.borderWidth = 0.5f;
        lxTextField.layer.borderColor = RGB(210, 209, 215, 1).CGColor;
        [mainView addSubview:lxTextField];
        _lianxiTextField = lxTextField;

    }
    else{
    
        //如果是爆料
        [textView becomeFirstResponder];
    }
}

//  颜色转换为背景图片
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// 更改Button状态
- (void)changeButtonStatus:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
}

- (void)clearAllInfo:(UIButton *)sender{
    
    [_textView becomeFirstResponder];
    _textView.text = @"";
    [self toSetPlaceholderlblText];
}

- (void)toSetPlaceholderlblText{

    NSString *placeholderStr = @"" ;
    if (self.flag) {
        placeholderStr = @"来吐个槽、爆个料吧~";//请在这里填写建议或问题反馈
    }else{
        placeholderStr = @"请在这里填写建议或问题反馈";
        if ([self.module isEqualToString:@"更多相似项目"]) {
            placeholderStr = @"请在这里填写更多相似项目";
        }
    }
    _placeholderLab.text = placeholderStr;
}
//打电话给CEO
- (void)makeACall{
    
    [self.view endEditing:NO];
    
    UIWebView *phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:phoneCallWebView];
    
    NSURL* dialUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", TELE]];
    if ([[UIApplication sharedApplication] canOpenURL:dialUrl])
    {
        if (phoneCallWebView) {
            [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:dialUrl]];
        }
        else{
            [[UIApplication sharedApplication] openURL:dialUrl];
        }
    }
    
}


/**
 发邮件给CEO
 */
- (void)sendEmail{
        NSString *urlStr = @"mailto://service@qimingpian.com?subject=企名片APP反馈&body=1.个人信息：(微信号、微信昵称、姓名、联系电话)<br><br>2.理由：(请简单描述您的需求)<br><br>";
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
}

/**
 长按复制手机号
 */
- (void)longPressTele{
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = TELE;
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}


/**
 长按复制邮箱
 */
- (void)longPressEmail{
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = EMAIL;
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
    
}

- (void)launchAlert:(NSString *)str{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];

    [self presentViewController:alert animated:YES completion:nil];

}
#pragma mark- UITextView的代理方法
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        [self toSetPlaceholderlblText];
    }else{
        _placeholderLab.text = @"";
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (![text isEqualToString:@""]) {
        _placeholderLab.hidden = YES;
    }
    
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1) {
        _placeholderLab.hidden = NO;
    }
    
    return YES;
}

#pragma mark - 请求反馈接口
- (void)requestFeedback{
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        int selectedNum = 0;
        NSString *seletedModule = @"";

        if (_plateView) {
            //如果有选择的框
            for (id btn in [_plateView subviews]) {
                if ([(UIButton *)btn state] == UIControlStateSelected) {
                    selectedNum++;
                    UIButton *button = (UIButton *)btn;
                    if (selectedNum == 1) {
                        seletedModule = button.titleLabel.text;
                        continue;
                    }
                    if (selectedNum > 1) {
                        seletedModule = [NSString stringWithFormat:@"%@|%@",seletedModule,button.titleLabel.text];
                    }
                }
            }
            
        }
        
        if (_textView.text.length<=0) {
            [self launchAlert:@"描述信息为空"];
            return;
        }
        
        NSString *action = @"";
        if ([self.flag isEqualToString:@"1"]) {
            [mDict setValue:_textView.text forKey:@"miaoshu"];
            [mDict setValue:(_oneid ? _oneid : @"") forKey:@"productid"];
            action = @"d/addproductgossip";
            
        }else if([self.flag isEqualToString:@"2"]){
            [mDict setValue:_textView.text forKey:@"miaoshu"];
            [mDict setValue:(_oneid ? _oneid : @"") forKey:@"jigouid"];
            action = @"d/addjigougossip";
        }
        else{
            //首页/我的 /公司整体反馈/机构整体反馈
            
            if (selectedNum > 0) {
                //公司整体反馈/机构整体反馈
                [mDict setValue:seletedModule forKey:@"c3"];
            }
            NSString *email = _lianxiTextField.text;
            [mDict setValue:_textView.text forKey:@"desc"];
            [mDict setValue:_type forKey:@"type"];
            [mDict setValue:(email ? email : @"") forKey:@"contact"];
            [mDict setValue:(_company ? _company :@"") forKey:@"company"];
            [mDict setValue:(_company ? _company :@"") forKey:@"c1"];
            [mDict setValue:(_product ? _product : @"") forKey:@"c2"];
            [mDict setValue:(_product ? _product : @"") forKey:@"product"];

            action = @"h/editcommonfeedback";
        }
        
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:action HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
        }];

        [self.navigationController popViewControllerAnimated:YES];
        
        if ([self.delegate respondsToSelector:@selector(feedbackSuccess)]) {
            [self.delegate feedbackSuccess];
        }

    }
    
}
@end
