//
//  FeedbackDetailViewControlerViewController.m
//  qmp_ios
//
//  Created by qimingpian10 on 2016/11/7.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "FeedbackDetailViewControlerViewController.h"

#import "InputTextview.h"
#import "TestNetWorkReached.h"
#import "FactoryUI.h"
#import "HMTextView.h"

@interface FeedbackDetailViewControlerViewController ()<UITextFieldDelegate,UITextViewDelegate>
{
    UIView *_plateView;//反馈的板块
}
@property (nonatomic,strong)UILabel *searchLab;
@property (nonatomic,strong)UILabel *searchT;
@property (nonatomic,strong)UILabel *clueLab;
@property (nonatomic,strong)UITextView *clueTV;
@property(nonatomic,strong) HMTextView *textview;
@property(nonatomic,strong) UIButton *subitBtn;


@end

@implementation FeedbackDetailViewControlerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TABLEVIEW_COLOR;
    [self buildFeedbackDetailUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
}

//键盘管理
-(void)keyboardManager{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    if (tap.view != self.searchT&&tap.view !=self.clueTV && tap.view != self.textview) {
        [self.view endEditing:NO];
    }
}

- (void)keyboardWillShow{
    
    if (self.beginEdit) {
        self.beginEdit();
    }
}
- (void)buildFeedbackDetailUI{
    
    self.navigationItem.title = @"人工完善信息";
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"提交" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [rightBtn setTitleColor:NV_OTHERTITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(submitFeedback:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
    UIView *topBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 34)];
    topBgView.backgroundColor = TABLEVIEW_COLOR;
    [self.view addSubview:topBgView];
    
    self.searchLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 2, SCREENW-30, 20)];
    [self.searchLab labelWithFontSize:14 textColor:H5COLOR];
    self.searchLab.text = [NSString stringWithFormat:@"“%@”搜索反馈",self.searchStr];
    [topBgView addSubview:_searchLab];
    
    
    _plateView = [[UIView alloc]initWithFrame:CGRectMake(0, topBgView.bottom, SCREENW, 60)];
    [self.view addSubview:_plateView];
    _plateView.backgroundColor = [UIColor whiteColor];
    
    NSArray *titleArr = @[@"有官网",@"有新闻报道",@"有招聘信息",@"有产品"];
    for (int i=0; i<titleArr.count; i++) {
        float btnW = (_plateView.frame.size.width-3*13-2*17)/4;
        float btnH = 30;
        float btnY = 5;
        float btnX = i*(13+btnW)+17;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        btn.tag = 100+i;
        [btn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateSelected];
        [btn setTitleColor:H5COLOR forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(changeButtonStatus:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 2;
        btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = 0.5f;
        btn.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        [_plateView addSubview:btn];
        btn.centerY = _plateView.height/2.0;
    }
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(17, _plateView.bottom-0.5, SCREENW-34, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [_plateView addSubview:line];
    
    [self addInputViewWithWidth:SCREENW withY: _plateView.bottom+1];
    
   
    
    if ([self.from isEqualToString:@"搜索未命中"]) {
        UIButton *feedbackBtn = [FactoryUI createButtonWithFrame:CGRectMake(25, _plateView.bottom+120, SCREENW-50, 43) title:@"提交反馈" titleColor:nil imageName:@"" backgroundImageName:@"" target:nil selector:nil];//170
        [feedbackBtn addTarget:self action:@selector(submitFeedback:) forControlEvents:UIControlEventTouchUpInside];
        [feedbackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [feedbackBtn setBackgroundImage:[UIImage imageFromColor:RGBBlueColor andSize:feedbackBtn.size] forState:UIControlStateNormal];
        [feedbackBtn setBackgroundImage:[UIImage imageFromColor:HTColorFromRGB(0xdbdbdb) andSize:feedbackBtn.size] forState:UIControlStateDisabled];
//        feedbackBtn.enabled = NO;
        
        [feedbackBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        feedbackBtn.layer.cornerRadius = 21;
        feedbackBtn.layer.masksToBounds = YES;
        [self.view addSubview:feedbackBtn];
        self.subitBtn = feedbackBtn;
    }
    

    [self keyboardManager];
}

/**增加更多反馈的输入框*/
- (void)addInputViewWithWidth:(CGFloat)width withY:(CGFloat)y{
    CGFloat margin = 10.f;
    CGFloat h = 95.f;
    UIView *inputView = [[UIView alloc]initWithFrame:CGRectMake(0, y, SCREENW, h)];
    inputView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:inputView];
    
    self.textview = [[HMTextView alloc]initWithFrame:CGRectMake(margin, 0 , width - margin * 2, h)];
    self.textview.placehoder = @"请在此填写线索、问题或者意见反馈";
    [inputView addSubview:self.textview];
    self.textview.backgroundColor = [UIColor whiteColor];
//    InputTextview *inputView = [[InputTextview alloc] initWithFrame:CGRectMake(margin, y , width - margin * 2, h)];
//    self.textview = inputView.textView;
//    inputView.layer.borderWidth = 0;
//    [self.view addSubview:inputView];
//    inputView.backgroundColor = [UIColor whiteColor];

}

- (void)changeButtonStatus:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected) {
        button.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
    }else{
        button.layer.borderColor = BORDER_LINE_COLOR.CGColor;

    }
}
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchT resignFirstResponder];
    return YES;
}
#pragma mark - UITextViewDelegate
//- (void)textViewDidEndEditing:(UITextView *)textView
//{
//    if(textView.text.length < 1){
//        textView.text = @"例:公司的行业,描述,业务,官网微信公众号等能帮助我们更快更精准完善相关信息";
//        textView.textColor = [UIColor grayColor];
//    }
//}
//
//
//- (void)textViewDidBeginEditing:(UITextView *)textView{
//    if([textView.text isEqualToString:@"例:公司的行业,描述,业务,官网微信公众号等能帮助我们更快更精准完善相关信息"]){
//        textView.text=@"";
//        textView.textColor=[UIColor blackColor];
//    }
//
//}


//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
//        //在这里做你响应return键的代码
//        [textView resignFirstResponder];
//        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
//    }
//    return YES;
//}
#pragma mark - 警告框
-(void)launchAlert:(NSString *)str{
    
    [PublicTool alertActionWithTitle:nil message:str btnTitle:@"确定" action:^{
        
    }];
    
}
#pragma mark - 点击了提交按钮
-(void)submitFeedback:(UIButton *)sender{
    QMPLog(@"点击了提交按钮");
   
   
    BOOL btnSelected = NO;
    for (id btn in [_plateView subviews]) {
        
        if (![btn isKindOfClass:[UIButton class]]) {
            continue;
        }
        if ([(UIButton *)btn state] == UIControlStateSelected) {
            btnSelected = YES;
        }
    }
    
    if ((self.searchT.text.length + self.textview.text.length) == 0 && !btnSelected) {
        [self launchAlert:@"请填写反馈信息"];
        return;
    }
    
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [mDict setValue:@"人工信息完善" forKey:@"type"];
        [mDict setValue:@"急" forKey:@"c4"];
        [mDict setValue:self.textview.text forKey:@"c3"];
        [mDict setValue:[NSString stringWithFormat:@"%ld",(long)(self.resultCount ? self.resultCount : 0)] forKey:@"c2"];
        [mDict setValue:self.searchStr forKey:@"c1"];
        
        NSMutableString *desc = [NSMutableString string];
        int selectedNum = 0;
        for (id btn in [_plateView subviews]) {
            
            if (![btn isKindOfClass:[UIButton class]]) {
                continue;
            }
            if ([(UIButton *)btn state] == UIControlStateSelected) {
                selectedNum++;
                UIButton *button = (UIButton *)btn;
                if (selectedNum == 1) {
                    
                    [desc appendFormat:@"%@",button.titleLabel.text];
                    continue;
                }
                if (selectedNum > 1) {
                    
                    [desc appendFormat:@"|%@",button.titleLabel.text];
                }
            }
        }
        [mDict setValue:[NSString stringWithFormat:@"用户：%@",desc] forKey:@"desc"];
        
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/editcommonfeedback" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
        }];

        [ShowInfo showInfoOnView:KEYWindow withInfo:@"感谢您的反馈"];
        NSArray *subTagBtnsArr = [_plateView subviews];
        for (int i = 0; i<subTagBtnsArr.count; i++) {
           
            UIButton *tagsBtn = subTagBtnsArr[i];
            if (![tagsBtn isKindOfClass:[UIButton class]]) {
                continue;
            }
            tagsBtn.userInteractionEnabled = NO;
            [tagsBtn setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateSelected];
            [tagsBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
            [tagsBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            tagsBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        }
        [sender setTitle:@"已提交反馈" forState:UIControlStateNormal];
        self.textview.userInteractionEnabled = NO;
        self.searchT.userInteractionEnabled = NO;
        
        self.subitBtn.userInteractionEnabled = NO;
        [self.subitBtn setBackgroundImage:[UIImage imageFromColor:HTColorFromRGB(0xdbdbdb) andSize: self.subitBtn.size] forState:UIControlStateNormal];
    }
}
@end
