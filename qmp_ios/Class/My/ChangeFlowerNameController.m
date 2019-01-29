//
//  ChangeFlowerNameController.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/24.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "ChangeFlowerNameController.h"

@interface ChangeFlowerNameController ()
@property(nonatomic,strong)UIView *nameScanView;
@property(nonatomic,strong)UILabel *nameLab;
@property(nonatomic,strong)UIButton *changeBtn;

@property(nonatomic,strong)UIView *nameEditView;
@property(nonatomic,strong)UILabel *feedLab;
@property(nonatomic,strong)UITextField *nameTf;
@property(nonatomic,strong)UIButton *cancleBtn;
@property(nonatomic,strong)UIButton *submitBtn;


@property(nonatomic,copy)NSString *editExplainStr;
@end

@implementation ChangeFlowerNameController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的花名";
    [self addViews];
}

- (void)addViews{
    
    [self.view addSubview:self.nameScanView];
    
    UIButton *titleBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 218, 120, 20)];
    [titleBtn setTitleColor:H6COLOR forState:UIControlStateNormal];
    titleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [titleBtn setImage:[BundleTool imageNamed:@"set_tip"] forState:UIControlStateNormal];
    [titleBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:4];
    [titleBtn setTitle:@"花名编辑说明" forState:UIControlStateNormal];
    [self.view addSubview:titleBtn];
    
    UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(17, titleBtn.bottom+5, SCREENW-40, 100)];
    [tipLab labelWithFontSize:13 textColor:H999999];
    tipLab.numberOfLines = 0;
    [self.view addSubview:tipLab];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:self.editExplainStr];
    NSMutableParagraphStyle *parag = [[NSMutableParagraphStyle alloc]init];
    parag.lineSpacing = 4;
    [attText addAttributes:@{NSParagraphStyleAttributeName:parag,NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:H6COLOR} range:NSMakeRange(0, attText.length)];
    tipLab.attributedText = attText;
}

- (void)changeBtnClick{
    
    [PublicTool showHudWithView:KEYWindow];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"flower/checkFlowerState" HTTPBody:@{} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];

        if ([resultData[@"state"] integerValue] == 1) {
            [PublicTool alertActionWithTitle:@"提示" message:@"花名一个月只能修改一次\n请谨慎修改" btnTitle:@"我知道了" action:^{
                [self.nameTf becomeFirstResponder];
            }];
            [self.view addSubview:self.nameEditView];

        }else{
            [PublicTool alertActionWithTitle:@"提示" message:@"花名一个月只能修改一次\n您暂时还不能修改" btnTitle:@"我知道了" action:nil];
        }
    }];
}
- (void)cancelBtnClick{
    [self.nameEditView removeFromSuperview];
}

- (void)submitBtnClick{
    NSString *newName = [_nameTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([[WechatUserInfo shared].flower_name isEqualToString:newName]) {
        [PublicTool showMsg:@"不可与旧花名一致"];
        return;
    }
    
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"flower/updateUserFlowername" HTTPBody:@{@"flower_name":newName} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            [PublicTool showMsg:@"修改成功"];
            [WechatUserInfo shared].flower_name = newName;
            [[WechatUserInfo shared] save];
            self.nameLab.text = newName;
            [self.nameEditView removeFromSuperview];
        }
    }];
}

- (void)nameChanged:(UITextField*)nameTf{ // 2-8个汉字 字母 数字组合
    NSString *name = [_nameTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSString *regular = @"[\u4e00-\u9fa5a-zA-Z0-9]{2,8}";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regular options:NSRegularExpressionCaseInsensitive error:nil];

    NSTextCheckingResult *firstMatch=[expression firstMatchInString:name options:0 range:NSMakeRange(0, name.length)];
    if (firstMatch.range.length != name.length || name.length == 0) {
        self.feedLab.textColor = RED_TEXTCOLOR;
        self.submitBtn.enabled = NO;
    }else{
        self.feedLab.textColor = H999999;
        self.submitBtn.enabled = YES;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark --懒加载--
-(UIView *)nameScanView{
    if (!_nameScanView) {
        _nameScanView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 218)];
        _nameScanView.backgroundColor = [UIColor whiteColor];
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 45, 240, 35)];
        self.nameLab.text = [WechatUserInfo shared].flower_name;
        self.nameLab.font = [UIFont systemFontOfSize:28];
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        [_nameScanView addSubview:self.nameLab];
        self.nameLab.centerX = SCREENW/2.0;
        
        self.changeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.nameLab.bottom+15, 80, 25)];
        self.changeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        self.changeBtn.layer.cornerRadius = 12.5;
        self.changeBtn.layer.masksToBounds = YES;
        self.changeBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
        self.changeBtn.layer.borderWidth = 1;
        [self.changeBtn setTitle:@"修改花名" forState:UIControlStateNormal];
        [self.changeBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [_nameScanView addSubview:self.changeBtn];
        self.changeBtn.centerX = SCREENW/2.0;
        [self.changeBtn addTarget:self action:@selector(changeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nameScanView;
}

-(UIView *)nameEditView{
    if (!_nameEditView) {
        _nameEditView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 218)];
        _nameEditView.backgroundColor = [UIColor whiteColor];

        self.nameTf = [[UITextField alloc]initWithFrame:CGRectMake(0, 35, 240, 49)];
        self.nameTf.text = [WechatUserInfo shared].flower_name;
        self.nameTf.font = [UIFont systemFontOfSize:19];
        self.nameTf.textAlignment = NSTextAlignmentCenter;
        [_nameEditView addSubview:self.nameTf];
        self.nameTf.centerX = SCREENW/2.0;
        [self.nameTf addTarget:self action:@selector(nameChanged:) forControlEvents:UIControlEventEditingChanged];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.nameTf.bottom, 250, 1)];
        line.backgroundColor = H999999;
        [_nameEditView addSubview:line];
        line.centerX = SCREENW/2.0;
        
        self.feedLab = [[UILabel alloc]initWithFrame:CGRectMake(0, line.bottom+5, SCREENW, 13)];
        [self.feedLab labelWithFontSize:12 textColor:H999999];
        self.feedLab.textAlignment = NSTextAlignmentCenter;
        self.feedLab.text = @"支持2至8个字长度的汉字、字母和数字组合";
        [_nameEditView addSubview:self.feedLab];
        
        self.cancleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.feedLab.bottom+26, 80, 25)];
        self.cancleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        self.cancleBtn.layer.cornerRadius = 12.5;
        self.cancleBtn.layer.masksToBounds = YES;
        self.cancleBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
        self.cancleBtn.layer.borderWidth = 1;
        [self.cancleBtn setTitle:@"取消修改" forState:UIControlStateNormal];
        [self.cancleBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [_nameEditView addSubview:self.cancleBtn];
        self.cancleBtn.right = SCREENW/2.0-15;
        [self.cancleBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        self.submitBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.feedLab.bottom+26, 80, 25)];
        self.submitBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        self.submitBtn.layer.cornerRadius = 12.5;
        self.submitBtn.layer.masksToBounds = YES;
        self.submitBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
        self.submitBtn.layer.borderWidth = 1;
        [self.submitBtn setTitle:@"提交花名" forState:UIControlStateNormal];
        [self.submitBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [_nameEditView addSubview:self.submitBtn];
        self.submitBtn.left = SCREENW/2.0+15;
        [self.submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _nameEditView;
}

-(NSString *)editExplainStr{
    if (!_editExplainStr) {
        _editExplainStr = @"• 请勿直接使用公众人物姓名或者具体公司、职位的词组，如“马云”/“企名片CEO”等\n• 请勿使用任何广告相关的词组\n• 请勿直接（不加任何修饰地）使用常见城市名词\n• 请遵循国家法律法规，文明用词。";
    }
    return _editExplainStr;
}

@end
