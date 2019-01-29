//
//  EditReceiptController.m
//  qmp_ios
//
//  Created by QMP on 2017/9/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "EditReceiptController.h"
#import "HMTextView.h"
#import "OneInvoiceViewController.h"
#import <objc/runtime.h>
@interface EditReceiptController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
{
    UITableView *_tableView;
    BOOL _isAddNew;
    NSArray *_titleArr;
    NSString *_stateText;
}

@end

@implementation EditReceiptController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBTableViewBackgroud;
    self.title = @"编辑发票";
    
    _titleArr =@[@"单位名称",@"税号",@"单位地址",@"公司电话",@"开户银行",@"银行账号",@"收件人",@"手机号码",@"收件地址"];
    if (!self.item) {
        _isAddNew = YES;
        self.title = @"添加发票";

    }
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [rightBtn setTitleColor:NV_OTHERTITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(finishBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = RGBTableViewBackgroud;
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ReceiptCell"];
    [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"HeaderView"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    if (!self.item) {
        self.item = [[InvoiceItem alloc]init];
    }
}



#pragma mark ----EVENT
- (void)finishBtnClick{
    [self.view endEditing:YES];
    
    if ([PublicTool isNull:self.item.company]) {
        [ShowInfo showInfoOnView:self.view withInfo:@"单位名称不能为空"];
        return;
    }
    
    if (_isAddNew) {
        [self requestAddInvoice];
    }else{
        [self requestUpdateInvoice];
 
    }
    
}

//自动填充
- (void)pressFillBtn{
    if (self.item.company.length == 0 || !self.item.company) {
        [ShowInfo showInfoOnView:self.view withInfo:@"单位名称不能为空"];
        return;
    }
    
    [self.view endEditing:YES];
    [self requstFill: self.item.company];
}



#pragma mark --Request---
#pragma mark - 请求自动填充的接口
- (void)requstFill:(NSString *)name{
    
    ManagerHud *requstHud = [[ManagerHud alloc] init];
    [requstHud addBlackBackgroundViewWithHud:self.view withCenter:CGPointMake(self.view.centerX, self.view.centerY - 150.f)];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/getQyNo" HTTPBody:@{@"name":name}  completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            NSDictionary *dic = resultData;
            if ([PublicTool isNull:dic[@"code"]] && [PublicTool isNull:dic[@"address"]]) {
                _stateText = @"未匹配到单位名称";
            }else{
                _stateText = @"";
                //填充税号 单位地址
                self.item.code = dic[@"code"];
                self.item.address = dic[@"address"];
            }
        }else if (error){
            _stateText = @"自动匹配失败";
        }else{
            _stateText = @"未匹配到单位名称";
        }
        [requstHud removeHudWithBackground];
        [_tableView reloadData];
    }];
    
}

#pragma mark - 请求修改某个发票抬头
- (void)requestUpdateInvoice{
    
    u_int count = 0;
    objc_property_t *properties  =class_copyPropertyList([InvoiceItem class], &count);
    
    for (int i = 0 ;i<count;i++) {
        
        const char* propertyStr =property_getName(properties[i]);
        //此步骤把c语言的字符串转换为OC的NSString
        NSString *propertyName = [NSString stringWithUTF8String: propertyStr];
        if (![self.item valueForKey:propertyName]) {
            [self.item setValue:@"" forKey:propertyName];
        }
        
    }
    
    
    [PublicTool showHudWithView:self.view];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.item.invoice_id,@"id",nil];
    [dic setValue:self.item.company forKey:@"company"];
    [dic setValue:self.item.code forKey:@"code"];
    [dic setValue:self.item.address forKey:@"address"];
    [dic setValue:self.item.tel forKey:@"tel"];
    [dic setValue:self.item.bank forKey:@"bank"];
    [dic setValue:self.item.account forKey:@"account"];
    
    [dic setValue:self.item.receiver forKey:@"receiver"];
    [dic setValue:self.item.receiver_ads forKey:@"receiver_ads"];
    [dic setValue:self.item.receiver_tel forKey:@"receiver_tel"];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"l/updateOneInvoice" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        NSNumber *status = (NSNumber *)resultData[@"status"];

        [PublicTool dismissHud:self.view];
        if ([status isEqual:@0]) {
            self.refreshReceipt(self.item);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
#pragma mark - 请求添加某个发票抬头
- (void)requestAddInvoice{
    
    u_int count = 0;
    objc_property_t *properties  =class_copyPropertyList([InvoiceItem class], &count);
    
    for (int i = 0 ;i<count;i++) {
        
        const char* propertyStr =property_getName(properties[i]);
        //此步骤把c语言的字符串转换为OC的NSString
        NSString *propertyName = [NSString stringWithUTF8String: propertyStr];
        if (![self.item valueForKey:propertyName]) {
            [self.item setValue:@"" forKey:propertyName];
        }
        
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.item.company,@"company", nil];
    [dic setValue:self.item.code forKey:@"code"];
    [dic setValue:self.item.address forKey:@"address"];
    [dic setValue:self.item.tel forKey:@"tel"];
    [dic setValue:self.item.bank forKey:@"bank"];
    [dic setValue:self.item.account forKey:@"account"];

    [dic setValue:self.item.receiver forKey:@"receiver"];
    [dic setValue:self.item.receiver_ads forKey:@"receiver_ads"];
    [dic setValue:self.item.receiver_tel forKey:@"receiver_tel"];
   
    [PublicTool showHudWithView:self.view];

    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"l/addOneInvoice" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:self.view];
        if (resultData) {
            NSDictionary *data = resultData;
            InvoiceItem *item = [[InvoiceItem alloc] init];
            [item setValuesForKeysWithDictionary:data];
            self.addReceipt(item);
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];

//    RequestUrlItem *request = [[RequestUrlItem alloc] initDictWithParamsDic:dic onAction:@"l/addOneInvoice"];
//    NetworkingManager *manager = [[NetworkingManager alloc] init];
//    [manager asyncPostTaskWithRequestUrlItem:request withSuccessCallBack:^(NSDictionary *resultDic) {
//
//        [PublicTool dismissHud:self.view];
//
//        NSNumber *status = (NSNumber *)resultDic[@"status"];
//        if ([status isEqual:@0]) {
//
//            NSDictionary *data = resultDic[@"data"];
//            InvoiceItem *item = [[InvoiceItem alloc] init];
//            [item setValuesForKeysWithDictionary:data];
//            self.addReceipt(item);
//
//            [self.navigationController popViewControllerAnimated:YES];
////            __weak typeof(self) weakSelf = self;
////            OneInvoiceViewController *oneVC = [[OneInvoiceViewController alloc] initWithItem:item];
////            oneVC.updateInvoiceSuccess = ^(InvoiceItem *invoiceItem) {
////                weakSelf.item = invoiceItem;
////                [_tableView reloadData];
////
////            };
////            [self.navigationController pushViewController:oneVC animated:YES];
//
//        }
//
//    } andFaildCallBack:^(id response) {
//        [PublicTool dismissHud:self.view];
//
//    }];
    
}

#pragma mark --UITabelViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _titleArr.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2 || indexPath.section == 8) {
        return 70;
    }
    return 35;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"HeaderView"];
    
    UILabel *label = [headerView viewWithTag:1001];
    if (!label) {
        label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 80, 35)];
        label.font = [UIFont systemFontOfSize:14];
        label.tag = 1001;
        [headerView addSubview:label];
    }
    
    label.text = _titleArr[section];

    UIButton *rightBtn = [headerView viewWithTag:1002];
    if (!rightBtn) {
        rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 15 - 70, 0, 70, 35)];
        rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        rightBtn.tag = 1002;
        [rightBtn setTitle:@"自动填充" forState:UIControlStateNormal];
        [headerView addSubview:rightBtn];
        [rightBtn addTarget:self action:@selector(pressFillBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //税号填充提示label
    UILabel *stateL = [headerView viewWithTag:1003];
    if (!stateL) {
        stateL = [[UILabel alloc]initWithFrame:CGRectMake(80, 0, 100, 35)];
        stateL.font = [UIFont systemFontOfSize:12];
        stateL.tag = 1003;
        [headerView addSubview:stateL];
        stateL.textColor = RED_TEXTCOLOR;
    }
    if (section == 1 && _stateText.length) {
        stateL.hidden = NO;
        stateL.text = _stateText;
    }else{
        stateL.hidden = YES;
    }
    
    
    if ([label.text isEqualToString:@"税号"]) {
        rightBtn.hidden = NO;
    }else{
        rightBtn.hidden = YES;

    }
    return headerView;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiptCell" forIndexPath:indexPath];
    cell.backgroundColor = tableView.backgroundColor;
    
    HMTextView *textView = [cell viewWithTag:1000];
    if (!textView) {
        textView = [[HMTextView alloc]initWithFrame:CGRectMake(10, 0, cell.width - 20, cell.height)];
        textView.tag = 1000;
        [cell addSubview:textView];
        textView.backgroundColor = [UIColor whiteColor];
        textView.font = [UIFont systemFontOfSize:14];
        textView.contentMode = UIViewContentModeCenter;
        textView.returnKeyType = UIReturnKeyNext;
    }
    textView.delegate = self;
   
    switch (indexPath.section) {
        case 0:
            textView.placehoder = @"单位名称(必填)";
            textView.text = self.item.company;
            break;
        case 1:
            textView.placehoder = @"15-20字";
            textView.text = self.item.code;
            break;
        case 2:
            textView.placehoder = @"收票单位注册地址";
            textView.text = self.item.address;
            break;
        case 3:
            textView.placehoder = @"输入公司电话号码";
            textView.text = self.item.tel;
            break;
        case 4:
            textView.placehoder = @"收票单位开户银行";
            textView.text = self.item.bank;
            break;
        case 5:
            textView.placehoder = @"收票单位银行账号";
            textView.text = self.item.account;
            break;
        case 6:
            textView.placehoder = @"收件人";
            textView.text = self.item.receiver;
            break;
        case 7:
            textView.placehoder = @"收件人手机号码";
            textView.text = self.item.receiver_tel;
            break;
        case 8:
            textView.placehoder = @"收件地址";
            textView.text = self.item.receiver_ads;
            break;
        default:
            break;
    }
    
    
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark --UITextViewDelegate---
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    return YES;
}



- (void)textViewDidEndEditing:(UITextView *)textView{
    

    [self recordInputText:textView];
}

- (void)recordInputText:(UITextView*)textView{
    
    UITableViewCell *cell = (UITableViewCell*)textView.superview;
    NSInteger section = [_tableView indexPathForCell:cell].section;

    switch ( section) {
        case 0:
            self.item.company = textView.text;
            break;
        case 1:
            self.item.code = textView.text;
            break;
        case 2:
            self.item.address = textView.text;
            break;
        case 3:
            self.item.tel = textView.text;
            break;
        case 4:
            self.item.bank = textView.text;
            break;
        case 5:
            self.item.account = textView.text;
            break;
        case 6:
            self.item.receiver = textView.text;
            break;
        case 7:
            self.item.receiver_tel = textView.text;
            break;
        case 8:
            self.item.receiver_ads = textView.text;
            break;
            
        default:
            break;
    }

    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) { //下一步
        UITableViewCell *cell = (UITableViewCell*)textView.superview;
        NSInteger section = [_tableView indexPathForCell:cell].section;
        if (section == 8) {
            return YES;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section+1];
        UITableViewCell *nextCell = [_tableView cellForRowAtIndexPath:indexPath];
        UITextView *textV = [nextCell viewWithTag:1000];
        [textV becomeFirstResponder];
        return NO;

    }
    
    [self recordInputText:textView];

    
    return YES;
}




@end
