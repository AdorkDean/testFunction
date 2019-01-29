//
//  EditInfoViewController.m
//  qmp_ios
//
//  Created by molly on 2017/3/20.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "EditInfoViewController.h"

#import "HMTextView.h"

@interface EditInfoViewController ()<UITextViewDelegate>

@property (strong, nonatomic) HMTextView *textView;
@property (strong, nonatomic) UILabel *placeholderLab;
@property (strong, nonatomic) NSDictionary *keyDict;
@property (nonatomic, strong) NSString *placeholderStr;

@end

@implementation EditInfoViewController
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TABLEVIEW_COLOR;
    [self buildRightBarButtonItem];
    self.title = (_key ? _key : @"");

    [self buildView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEditing)];
    [self.view addGestureRecognizer:tap];
}

- (void)endEditing{
    [self.view endEditing:YES];
}

- (void)buildRightBarButtonItem{
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(confirmEditInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
   
}

- (void)buildView{

    CGFloat margin = 10.f;
    CGFloat vH = [self.key isEqualToString:@"简介"] ? 160.f : 104.f;
    
    UIView *supTextView = [[UIView alloc]initWithFrame:CGRectMake(0,0, SCREENW , vH)];
    supTextView.backgroundColor = [UIColor whiteColor];
//    supTextView.layer.borderWidth = 0.5f;
//    supTextView.layer.borderColor = RGB(210, 209, 215, 1).CGColor;
    [self.view addSubview:supTextView];
    
    
    self.textView = [[HMTextView alloc]initWithFrame:CGRectMake(margin, margin, supTextView.frame.size.width-margin*2, vH - margin)];
    self.textView.placehoderColor = HCCOLOR;
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.scrollEnabled = YES;
    self.textView.text = _value ? _value : @"";
    [supTextView addSubview:self.textView];
    
    self.textView.placehoder = @"填写详细信息";

}


#pragma mark - 请求修改信息
- (void)confirmEditInfo{
    
    if (self.sureBtnClick) {
        self.sureBtnClick(self.textView.text);
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([TestNetWorkReached networkIsReached:self]) {
        NSString *key = self.keyDict[_key];
        NSString *value = _textView.text;
        
        if ([value isEqualToString:@""]) {
            //如果全部删除后,点击保存,默认是上次保存的结果
            [self.navigationController popViewControllerAnimated:YES];

        }else{
            [PublicTool showHudWithView:KEYWindow];
            [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/addupduserinfo" HTTPBody:@{@"field":key?:@"",@"value":value?:@"",@"id":_userid} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                NSString *status = [NSString stringWithFormat:@"%@",resultData[@"status"]];
                
                if ([status isEqualToString:@"0"]) {
                    [PublicTool dismissHud:KEYWindow];
                    //修改成功了
                    //push过去,同时弹窗
                    [self.navigationController popViewControllerAnimated:YES];
                    if ([self.delegate respondsToSelector:@selector(updateInfoSuccess:withKey:)]) {
                        [self.delegate updateInfoSuccess:value withKey:key];
                    }
                }else{
                    [self hideHUD];
                }
            }];

        }
    }else{
        [self hideHUD];
    }
}
#pragma mark -懒加载
- (NSDictionary *)keyDict{
    
    if (!_keyDict) {
        _keyDict = @{@"头像":@"headimgurl",@"姓名":@"nickname",@"简介":@"desc",@"所在公司/机构":@"company",@"职位":@"zhiwei",@"手机":@"phone",@"微信":@"wechat",@"邮箱":@"email",@"我的名片":@"card"};
    }
    return _keyDict;
}

@end
