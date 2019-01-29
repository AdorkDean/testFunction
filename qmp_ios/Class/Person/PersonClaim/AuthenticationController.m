//
//  AuthenticationController.m
//  qmp_ios
//
//  Created by QMP on 2018/3/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "AuthenticationController.h"
#import "EditCell.h"
#import "TextViewCell.h"
#import "MyInfoTableViewCell.h"
#import "TakeImageTool.h"
#import "MyCardTableViewCell.h"
#import "AuthenticaHeaderView.h"
#import "AutheChangePersonController.h"

@interface AuthenticationController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate>
{
    UIImageView *_headerIcon;
    TakeImageTool *_imageTool;
    UITextField *_emailTf;
    UITextField *_codeTf;
    UIButton *_codeBtn;
    UIButton *_submitBtn;
    UIButton *_kefuBtn;
    NSInteger _totalSecond;
    NSTimer *_timer;
    UIImage *_cardImg;
    UIImage *_cardbackImg;
    UIAlertController *_alertV;
}

@property(nonatomic,strong)NSArray *sectionRowArr;
@property(nonatomic,strong)NSDictionary *basicInfoKeyValueDic;

@property(nonatomic,strong)NSMutableDictionary *userInfoDic;
@property(nonatomic,strong)UIImageView *bottomView;
@property(nonatomic,strong)NSMutableArray *rowStateArr;


@end

@implementation AuthenticationController
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    EditCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.valueTf becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"身份认证";
    _imageTool = [[TakeImageTool alloc]init];
    
    [self showHUD];
    
    [self addView];
}


- (void)addView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate  = self;
    self.tableView.dataSource = self;
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 100)];
    self.tableView.tableFooterView = footerView;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.tableView registerClass:[EditCell class] forCellReuseIdentifier:@"EditCellID"];
    
    [self.tableView registerClass:[TextViewCell class] forCellReuseIdentifier:@"TextViewCellID"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MyInfoTableViewCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"MyInfoTableViewCellID"];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    if (self.person) {
        
        AuthenticaHeaderView *headerV = [[BundleTool commonBundle]loadNibNamed:@"AuthenticaHeaderView" owner:nil options:nil].lastObject;
        headerV.height = 90;
        headerV.person = self.person;
        self.tableView.tableHeaderView = headerV;
        
        self.userInfoDic[@"name"] = self.person.name;
//        cyz => 创业者 ；investor => 投资人；FA => FA ；specialist =>专家 ；media =>媒体 ; other => 其他
        self.userInfoDic[@"role"] = [self.person.role containsObject:@"investor"]? @"投资人":([self.person.role containsObject:@"cyz"]?@"创业者":([self.person.role containsObject:@"FA"]?@"FA":@"其他"));
//        self.userInfoDic[@"desc"] = self.person.jieshao?self.person.jieshao:@"";
        
    }else{
        self.navigationItem.leftBarButtonItems = [self createBackButton];
        [self readSaveUserMsg];
    }
    
    [self initTableFooterView];
}

- (NSArray*)createBackButton{
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:LEFTBUTTONFRAME];
    [leftButton setImage:[BundleTool imageNamed:@"left-arrow"] forState:UIControlStateNormal];
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
    [self saveUserMessage];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveUserMessage{
    NSString * keyAuthStr = [NSString stringWithFormat:@"%@authenSaveInfo",[WechatUserInfo shared].unionid];
    [USER_DEFAULTS setValue:self.userInfoDic forKey:keyAuthStr];
    [USER_DEFAULTS synchronize];
}
- (void)readSaveUserMsg{
    NSString * keyAuthStr = [NSString stringWithFormat:@"%@authenSaveInfo",[WechatUserInfo shared].unionid];
    if ([USER_DEFAULTS objectForKey:keyAuthStr]) {
        self.userInfoDic = [NSMutableDictionary dictionaryWithDictionary:[USER_DEFAULTS objectForKey:keyAuthStr]];
        if (_role == PersonRole_Investor) {
//            self.userInfoDic[@"role"] = @"投资者";
        }
        NSString * nameStr = self.searchName?:@"";
        self.userInfoDic[@"name"] = nameStr;

    }else{
        NSString * nameStr = self.searchName?:@"";
        NSString * zhiweiStr = [WechatUserInfo shared].zhiwei;
        NSString * wechatStr = [WechatUserInfo shared].wechat;
        NSString * phoneStr = [WechatUserInfo shared].phone;
        self.userInfoDic[@"name"] = nameStr;
        self.userInfoDic[@"zhiwei"] = zhiweiStr?zhiweiStr:@"";
        self.userInfoDic[@"phone"] = phoneStr?phoneStr:@"";
        self.userInfoDic[@"wechat"] = wechatStr?wechatStr:@"";
        
        if (_role == PersonRole_Investor) {
//            self.userInfoDic[@"role"] = @"投资者";
        }
    }
    [self.tableView reloadData];
}


- (void)initTableFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW,200)];
    footerView.backgroundColor = [UIColor whiteColor];
    
//    _emailTf = [[UITextField alloc]initWithFrame:CGRectMake(40, 45, SCREENW - 80, 30)];
//    _emailTf.placeholder = @"输入您的企业邮箱";
//    _emailTf.font = [UIFont systemFontOfSize:16];
//    _emailTf.clearButtonMode = UITextFieldViewModeWhileEditing;
//    [footerView addSubview:_emailTf];
//
//    //line
//    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(_emailTf.left, _emailTf.bottom, _emailTf.width, 0.5)];
//    line.backgroundColor = LIST_LINE_COLOR;
//    [footerView addSubview:line];
//
//    _codeTf = [[UITextField alloc]initWithFrame:CGRectMake(40, _emailTf.bottom+30, SCREENW - 80 - 100, 30)];
//    _codeTf.placeholder = @"输入6位验证码";
//    _codeTf.font = [UIFont systemFontOfSize:16];
//    _codeTf.clearButtonMode = UITextFieldViewModeWhileEditing;
//    [footerView addSubview:_codeTf];
//
//    _codeBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 40 - 100, 0, 100, 44)];
//    [_codeBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
//    _codeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//    [_codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
//    [_codeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    [footerView addSubview:_codeBtn];
//    _codeBtn.centerY = _codeTf.centerY;
//
//    //line
//    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(_codeTf.left, _codeTf.bottom, _emailTf.width, 0.5)];
//    line1.backgroundColor = LIST_LINE_COLOR;
//    [footerView addSubview:line1];
//
//
//    [_emailTf setValue:HCCOLOR forKeyPath:@"_placeholderLabel.textColor"];
//
//    [_codeTf setValue:HCCOLOR forKeyPath:@"_placeholderLabel.textColor"];
    
    _submitBtn = [[UIButton alloc]initWithFrame:CGRectMake(40, 45,SCREENW-80, 44)];
    [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _submitBtn.backgroundColor = BLUE_TITLE_COLOR;
    _submitBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_submitBtn setTitle:@"提交认证申请" forState:UIControlStateNormal];
    [footerView addSubview:_submitBtn];
    _submitBtn.layer.masksToBounds = YES;
    _submitBtn.layer.cornerRadius = 22.0;
    
    _kefuBtn = [[UIButton alloc]initWithFrame:CGRectMake(40, _submitBtn.bottom+10,SCREENW-80, 44)];
    _kefuBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [footerView addSubview:_kefuBtn];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"遇到问题? 点我进行人工认证"];
    NSRange strRange = {0,[title length]};
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [title addAttribute:NSForegroundColorAttributeName value:H9COLOR range:strRange];
    [_kefuBtn setAttributedTitle:title forState:UIControlStateNormal];
    
    
//    [_codeBtn addTarget:self action:@selector(getCodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_kefuBtn addTarget:self action:@selector(contactKefu) forControlEvents:UIControlEventTouchUpInside];
    
    
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.tableView.tableFooterView = footerView;
}


#pragma mark --Event--
- (void)contactKefu{
    
    [PublicTool contactKefu:@"我在认证身份时遇到问题" reply:kDefaultWel];
}


- (void)getCodeBtnClick{
    
    if (![_codeBtn.titleLabel.text isEqualToString:@"获取验证码"]) {
        return;
    }
    
    if (![PublicTool checkEmail:_emailTf.text]) {
        return;
    }
    
    if (_timer && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
    [PublicTool showHudWithView:KEYWindow];
    
    //请求验证码
    NSString *email = [_emailTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    email = [email stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/userClaimPersonEmail" HTTPBody:@{@"email":email} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            [_codeTf becomeFirstResponder];
            [self beginDaojishi];
            
        }else{
            [PublicTool showMsg:@"验证码获取失败"];
        }
    }];
    
}




- (void)beginDaojishi{
    
    _totalSecond = 60;
    [_codeBtn setTitleColor:H9COLOR forState:UIControlStateNormal];
    [_codeBtn setTitle:@"重新获取(60s)" forState:UIControlStateNormal];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
    
}

- (void)timerEvent{
    
    _totalSecond --;
    if (_totalSecond == 0) {
        [_codeBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [_codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        _totalSecond = 60;
        [_timer invalidate];
        _timer = nil;
        
    }else{
        [_codeBtn setTitle:[NSString stringWithFormat:@"重新获取(%lds)",_totalSecond] forState:UIControlStateNormal];
    }
}
- (void)submitBtnClick{
    
    NSArray *keys = @[@"name",@"role",@"zhiwei",@"wechat",@"company",@"desc",@"email",@"card",@"phone"];
    for (NSString *key in keys) {
        if ([PublicTool isNull:self.userInfoDic[key]]) {
            if ([key isEqualToString:@"card"]) {
                [PublicTool showMsg:@"请上传名片正面"];
            }else{
                [PublicTool showMsg:@"信息不能为空"];
            }
            return;
        }
    }


    [self.view endEditing:YES];
    [PublicTool showHudWithView:KEYWindow];

    NSString *personid = self.person ? self.person.personId : @"";
    NSString *beta = [[WechatUserInfo shared].scope containsString:@"beta"] ? @"1":@"0";

    
    NSString * roleStr = self.userInfoDic[@"role"];
    NSDictionary * roleDic = @{@"创业者":@"cyz", @"投资人":@"investor", @"FA":@"FA", @"专家":@"specialist", @"媒体":@"media", @"其他":@"other"};
    NSArray * roleArr = @[@"创业者", @"投资人", @"FA", @"专家", @"媒体", @"其他"];
    if ([roleArr containsObject:roleStr]) {
        roleStr = roleDic[roleStr];
    }
    
    NSDictionary *dic = @{@"name":self.userInfoDic[@"name"],@"role":roleStr,@"phone":self.userInfoDic[@"phone"],@"wechat":self.userInfoDic[@"wechat"],@"desc":self.userInfoDic[@"desc"],@"u_email":self.userInfoDic[@"email"],@"zhiwei":self.userInfoDic[@"zhiwei"],@"company":self.userInfoDic[@"company"],@"card":[PublicTool isNull:self.userInfoDic[@"card"]]?@"":self.userInfoDic[@"card"],@"cardback":[PublicTool isNull:self.userInfoDic[@"cardback"]]?@"":self.userInfoDic[@"cardback"],@"person_id":personid,@"beta":beta}; //修改公司职位
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"person/userCreateFigure" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
//
        if (resultData) {

            [WechatUserInfo shared].claim_type = @"1";
            [[WechatUserInfo shared] save];

            [PublicTool alertActionWithTitle:@"提交成功" message:@"请耐心等待审核" btnTitle:@"我知道了" action:^{
                //进入信息编辑页
                AutheChangePersonController *changeInfoVC = [[AutheChangePersonController alloc]init];
                changeInfoVC.claim_id = resultData[@"msg"];
                NSDictionary *infoDic = @{@"name":self.userInfoDic[@"name"],@"jieshao":self.userInfoDic[@"desc"],@"icon":[WechatUserInfo shared].headimgurl,@"wechat":self.userInfoDic[@"wechat"],@"email":self.userInfoDic[@"email"],@"phone":self.userInfoDic[@"phone"],@"position":self.userInfoDic[@"zhiwei"],@"company":self.userInfoDic[@"company"],@"work_exp":@[@{@"zhiwu":self.userInfoDic[@"zhiwei"],@"name":self.userInfoDic[@"company"]}]};
                PersonModel *person = [[PersonModel alloc]initWithDictionary:infoDic error:nil];
                changeInfoVC.cachePersonInfo = person;

                if (self.person) {
                    changeInfoVC.persionId = self.person.personId;
                }else{ //创建
                    changeInfoVC.isInvestor = [roleStr containsString:@"investor"];
                }
                [self.navigationController pushViewController:changeInfoVC animated:YES];

            }];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"claimFinish" object:nil];
            [self saveUserMessage];

        }else{
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }

    }];
   
}


- (void)editCellTextChange:(UITextField*)tf{
    
    EditCell *cell = (EditCell*)tf.superview.superview;
    
    [self.userInfoDic setValue:tf.text forKey:self.basicInfoKeyValueDic[cell.keyLabel.text]];
  
}
- (void)showAlertByAction{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"选择人物角色" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * investAction = [UIAlertAction actionWithTitle:@"投资人" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.userInfoDic setValue:@"投资人" forKey:@"role"];
        NSIndexPath * indx = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [alertVC addAction:investAction];
    UIAlertAction * creatorAction = [UIAlertAction actionWithTitle:@"创业者" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.userInfoDic setValue:@"创业者" forKey:@"role"];
        NSIndexPath * indx = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [alertVC addAction:creatorAction];
    UIAlertAction * otherAction = [UIAlertAction actionWithTitle:@"其他" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.userInfoDic setValue:@"其他" forKey:@"role"];
        NSIndexPath * indx = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indx] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [alertVC addAction:otherAction];
    UIAlertAction * cancelAtion = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    [alertVC addAction:cancelAtion];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [self presentViewController:alertVC animated:YES completion:nil];
        
    }else{
        
        [self presentViewController:alertVC animated:YES completion:nil];
        
    }
    
    _alertV = alertVC;
    
    // 增加点击事件
    UIWindow *alertWindow = (UIWindow *)[UIApplication sharedApplication].windows.lastObject;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAlert:)];
    [alertWindow addGestureRecognizer:tap];

}

- (void)hideAlert:(UITapGestureRecognizer*)tap
{
    UIWindow *alertWindow = (UIWindow *)[UIApplication sharedApplication].windows.lastObject;
    [alertWindow removeGestureRecognizer:tap];
    [_alertV dismissViewControllerAnimated:YES completion:nil];
}

- (void)pressMyCardImg{
    
    [_imageTool alertPhotoAction:^(UIImage *image, NSData *imgData) {
        [PublicTool showHudWithView:KEYWindow];
        _cardImg = image;
        [[NetworkManager sharedMgr]uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
            [PublicTool dismissHud:KEYWindow];
            if ([fileUrl containsString:@"http"]) {
                [self.userInfoDic setValue:fileUrl forKey:@"card"];
                [self.tableView reloadData];
            }
        }];
    }];
}

- (void)pressMyCardBackImg{
    
    [_imageTool alertPhotoAction:^(UIImage *image, NSData *imgData) {
        _cardbackImg = image;
        [PublicTool showHudWithView:KEYWindow];
        
        [[NetworkManager sharedMgr]uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
            
            [PublicTool dismissHud:KEYWindow];
            if ([fileUrl containsString:@"http"]) {
                [self.userInfoDic setValue:fileUrl forKey:@"cardback"];
                [self.tableView reloadData];
                
            }
        }];
    }];
}


#pragma mark --UITextFieldDelegate--
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    UITableViewCell *cell = (UITableViewCell*)textField.superview.superview;
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    if (row < 3) {
        row ++;
        EditCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];
        [cell.valueTf becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark --UITextViewDelegate--
- (void)textViewDidChange:(UITextView *)textView{
    
    if(textView.text && textView.text.length > 1000){
        [PublicTool showMsg:@"个人简介字数不能超过1000"];
        textView.text = [textView.text substringWithRange:NSMakeRange(0, 999)];
        return;
    }
    [self.userInfoDic setValue:textView.text forKey:self.basicInfoKeyValueDic[@"个人简介"]];
}


#pragma mark --UITableViewDelegate--
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0)  {
        return 0.1;
    }else if (section == 1){
        return 50;
    }
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 50)];
    
    if (section == 0) {
        headerV.height = 0.1;
    }else if(section == 2){
        headerV.height = 10;

    }else{
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 150, 50)];
        [titleLab labelWithFontSize:14 textColor:H9COLOR];
        [headerV addSubview:titleLab];
        titleLab.text = @"个人简介";
        headerV.backgroundColor = TABLEVIEW_COLOR;
        titleLab.text = [self.sectionRowArr[section] firstObject];
    }
    
    return headerV;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionRowArr.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *sectionTitle = self.sectionRowArr[indexPath.section][0];
    
    if([sectionTitle isEqualToString:@"个人简介"]){
        return 80;
    }else if([sectionTitle isEqualToString:@"名片"]){
        return 120;
    }
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *rows = self.sectionRowArr[section];
    return rows.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        NSString *title  = self.sectionRowArr[indexPath.section][indexPath.row];
        EditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditCellID" forIndexPath:indexPath];
        cell.keyLabel.text = title;
        cell.valueTf.placeholder = [NSString stringWithFormat:@"请输入%@",title];
        NSString *value = self.userInfoDic[self.basicInfoKeyValueDic[title]];
        cell.valueTf.text = [PublicTool isNull: value] ? @"":value;
        [cell.valueTf addTarget:self action:@selector(editCellTextChange:) forControlEvents:UIControlEventEditingChanged];
        cell.valueTf.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([title isEqualToString:@"角色"]) {
            cell.valueTf.enabled = NO;
            [cell.valueTf resignFirstResponder];
        }else{
         
        }
        if ([title isEqualToString:@"微信"]) {
            cell.line.hidden = YES;
        }else{
            cell.line.hidden = NO;
        }
        return cell;
        
    }else if(indexPath.section == 1){
        
        TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCellID" forIndexPath:indexPath];
        cell.textView.delegate = self;
        cell.textView.placehoder = @"填写您的个人简介";
        cell.textView.text = self.userInfoDic[self.basicInfoKeyValueDic[@"个人简介"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if(indexPath.section == 2){
        
        static NSString *imgCellIdentifier = @"MyCardTableViewCell";
        MyCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:imgCellIdentifier];
        if (!cell) {
            cell = [[[BundleTool commonBundle] loadNibNamed:@"MyCardTableViewCell" owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (_cardImg) {
            [cell.imgBtn setImage:_cardImg forState:UIControlStateNormal];
        }
        if(_cardbackImg){
            [cell.backImgBtn setImage:_cardbackImg forState:UIControlStateNormal];
        }
        [cell initData:self.userInfoDic[@"card"] placeImg:_cardImg withBack:self.userInfoDic[@"cardback"] placeBackImg:_cardbackImg];
        [cell.imgBtn addTarget:self action:@selector(pressMyCardImg) forControlEvents:UIControlEventTouchUpInside];
        [cell.backImgBtn addTarget:self action:@selector(pressMyCardBackImg) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selectedTitle  = self.sectionRowArr[indexPath.section][indexPath.row];
    if ([selectedTitle isEqualToString:@"角色"] && self.person) {
//        [self showAlertByAction];
    }else if ([selectedTitle isEqualToString:@"角色"]){
        [self showAlertByAction];
    }else{
        
    }
    QMPLog(@"选中%@",self.userInfoDic[self.basicInfoKeyValueDic[selectedTitle]]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --懒加载--
- (NSMutableDictionary *)userInfoDic{
    
    if (!_userInfoDic) {
        _userInfoDic = [NSMutableDictionary dictionary];
    }
    return _userInfoDic;
}

- (NSMutableArray *)rowStateArr{
    if (!_rowStateArr) {
        _rowStateArr = [NSMutableArray array];
    }
    return _rowStateArr;
}

- (NSArray *)sectionRowArr{
    
    if (!_sectionRowArr) {
        
        _sectionRowArr = @[@[@"姓名",@"角色",@"所在单位",@"职位",@"微信",@"邮箱",@"手机"],@[@"个人简介"],@[@"名片"]];

    }
    return _sectionRowArr;
}


- (NSDictionary *)basicInfoKeyValueDic{
    if (!_basicInfoKeyValueDic) {
        _basicInfoKeyValueDic = @{@"姓名":@"name",@"角色":@"role",@"所在单位":@"company",@"职位":@"zhiwei",@"微信":@"wechat",@"个人简介":@"desc",@"邮箱":@"email",@"手机":@"phone"};
    }
    return _basicInfoKeyValueDic;
}

@end

