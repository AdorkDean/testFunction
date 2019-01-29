//
//  CreateProducrUserInfoController.m
//  qmp_ios
//
//  Created by QMP on 2018/3/29.
//  Copyright © 2018年 Molly. All rights reserved.
//  创建项目-表单

#import "CreateProducrUserInfoController.h"
#import "MyInfoTableViewCell.h"
#import "TakeImageTool.h"
#import "OnePickerView.h"
#import "TextViewTableViewCell.h"
#import "EditCell.h"
#import "HMTextView.h"
#import "ReportModel.h"
#import "TextViewTableViewCell.h"
#import "FormEditTableViewCell.h"


@interface CreateProducrUserInfoController () <UITableViewDelegate, UITableViewDataSource,
UITextViewDelegate, FormEditTableViewCellDelegate> {
    TakeImageTool *_imgTool;
}

@property (nonatomic, strong) NSMutableDictionary *cellValueDic;
@property (nonatomic, strong) NSDictionary *keyValueDic;
@property (nonatomic, strong) NSArray *tableConfigs;

@property (nonatomic, strong) UIView *successView;
@property (nonatomic, strong) NSString *reason;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, weak) UIImageView *logoView;
@property (nonatomic, strong) UIView *headerViewPage2;
@end

@implementation CreateProducrUserInfoController
- (void)viewDidLoad {
    [super viewDidLoad];
    _imgTool = [[TakeImageTool alloc] init];
    [self.cellValueDic setValue:[WechatUserInfo shared].phone forKey:@"phone"];
    [self.cellValueDic setValue:[WechatUserInfo shared].nickname forKey:@"name"];

    [self initTableView];
    
    self.navigationItem.title = @"填写个人信息";
}

- (void)cancelBtnClick{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"MyInfoTableViewCellID"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    [self.tableView registerClass:[EditCell class] forCellReuseIdentifier:@"EditCellID"];
    [self.tableView registerClass:[TextViewTableViewCell class] forCellReuseIdentifier:@"TextViewTableViewCellID"];
    [self.tableView registerClass:[FormEditTableViewCell class] forCellReuseIdentifier:@"FormEditTableViewCellID"];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    // tableheader
    self.tableView.tableHeaderView = self.headerView;
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 100)];
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(17, 30, 220, 40)];
    submitButton.layer.masksToBounds = YES;
    submitButton.layer.cornerRadius = 20;
    submitButton.backgroundColor = BLUE_BG_COLOR;
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:submitButton];
    submitButton.centerX = footerView.width / 2.0;
    self.tableView.tableFooterView = footerView;
}
- (void)submitButtonClick {
    NSArray *bitianArr = @[@"姓名",@"职位",@"手机号"];

    for (NSString *title in bitianArr) {
        NSString *key = self.keyValueDic[title];
        if ([PublicTool isNull:self.cellValueDic[key]]) {
            [PublicTool showMsg:[NSString stringWithFormat:@"请填写 %@",title]];
            return;
        }
    }

    if (![PublicTool checkTel:self.cellValueDic[@"phone"]]) {
        return;
    }

    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.cellValueDic];
    [param setValuesForKeysWithDictionary:self.productInfo];

    NSString *reason = param[@"claim_reason"]?:@"";
    [param setValue:[reason stringByAppendingString:self.reason?:@""] forKey:@"claim_reason"];


    [param setValue:@"5" forKey:@"source"]; //5、搜索结果页
    [param setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
    
    QMPLog(@"%@", param);

    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/userCreateProduct" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            if ([resultData[@"msg"] isEqualToString:@"success"]) {
                [PublicTool showMsg:@"提交成功，请耐心等待审核"];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                [PublicTool showMsg:resultData[@"msg"]];
            }

        }else{
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
}

#pragma mark --UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableConfigs.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSDictionary *row = self.tableConfigs[indexPath.row];
    NSString *title = row[@"title"];
    if ([title isEqualToString:@"一句话介绍"]) {
        return 86;
    }else if([self.keyValueDic[title] isEqualToString:@"card"]){
        return 100;
    }else if ([title isEqualToString:@"简介"]) {
        return 100;
    }else if ([title isEqualToString:@"职位"]) {
        return 80;
    }else if ([title isEqualToString:@"认领理由"]) {
        return 160;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *row = self.tableConfigs[indexPath.row];
    NSString *key = row[@"key"];
    NSString *title = row[@"title"];
    NSString *cellClass = row[@"cell"];
    //必填
    NSArray *bitianArr = @[@"项目名称",@"行业领域",@"一句话介绍",@"姓名",@"职位",@"手机号",@"地区"];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:title];
    if ([bitianArr containsObject:title]) {
        attText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"*%@",title]];
        [attText addAttributes:@{NSForegroundColorAttributeName:RED_TEXTCOLOR} range:NSMakeRange(0, 1)];
    }else{
        attText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@",title]];
    }
    
    if ([cellClass isEqualToString:@"EditCell"]) {
        
        EditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditCellID" forIndexPath:indexPath];
        cell.keyLabel.attributedText = attText;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.valueTf.placeholder = row[@"placeholder"];
        cell.valueTf.text = self.cellValueDic[key];
        [cell.valueTf addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
        return cell;
        
    } else if([cellClass isEqualToString:@"TextViewTableViewCell"]){
        
        TextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewTableViewCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.keyLabel.attributedText = attText;
        cell.textView.placehoder = row[@"placeholder"];
        cell.textView.delegate = self;
        cell.textView.cellKey =  key;
        cell.textView.text = self.cellValueDic[key];
        cell.textView.layer.borderWidth = 0.0;
        cell.lineView.hidden = NO;
        return cell;
        
    } else if ([cellClass isEqualToString:@"FormEditTableViewCell"]) {
        if ([key isEqualToString:@"position"]) {
            FormEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FormEditTableViewCellID"];
            cell.isMultiSelection = NO;
            cell.keyLabel.attributedText = attText;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.valueTf.text = self.cellValueDic[key];
            [cell.valueTf addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
            
            int i = 0;
            for (NSString *title in @[@"创始成员",@"市场商务",@"融资顾问", @"外部人员"]) {
                UIButton *button = cell.selectsView.subviews[i];
                [button setTitle:title forState:UIControlStateNormal];
                i++;
            }
            cell.valueTf.userInteractionEnabled = NO;
            cell.delegate = self;
            cell.line.hidden = NO;
            return cell;
        } else {
            FormEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FormEditTableViewCellID"];
            cell.isMultiSelection = YES;
            cell.keyLabel.attributedText = attText;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.valueTf.text = self.cellValueDic[key];
            [cell.valueTf addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
            
            int i = 0;
            for (NSString *title in @[@"发布融资",@"管理项目",@"市场推广",@"品牌运营"]) {
                UIButton *button = cell.selectsView.subviews[i];
                [button setTitle:title forState:UIControlStateNormal];
                i++;
            }
            cell.textView.placehoder = @"更多理由";
            cell.textView.delegate = self;
            cell.valueTf.userInteractionEnabled = NO;
            cell.delegate = self;
            cell.line.hidden = YES;
            return cell;
        }
    } else{ //
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLab = [cell.contentView viewWithTag:900];
        if (!titleLab) {
            titleLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 120, 40)];
            titleLab.font = [UIFont systemFontOfSize:14];
            titleLab.numberOfLines = 1;
            titleLab.text = @"名片或执照";
            titleLab.textColor = NV_TITLE_COLOR;
            [cell.contentView addSubview:titleLab];
            titleLab.tag = 900;
        }
        
        UILabel *desLab = [cell.contentView viewWithTag:999];
        if (!desLab) {
            desLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 40, SCREENW-34-120 - 20, 45)];
            desLab.font = [UIFont systemFontOfSize:14];
            desLab.numberOfLines = 2;
            desLab.attributedText = [row[@"placeholder"] stringWithParagraphlineSpeace:4 textColor:H9COLOR textFont:[UIFont systemFontOfSize:14]];
            desLab.textColor = H9COLOR;
            [cell.contentView addSubview:desLab];
            desLab.tag = 999;
        }
        
        UIButton *label = [cell.contentView viewWithTag:1000];
        if (!label) {
            label = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW-120-17, 10, 120, 80)];
            label.titleLabel.font = [UIFont systemFontOfSize:12];
            label.titleLabel.numberOfLines = 2;
            label.titleLabel.textAlignment = NSTextAlignmentCenter;
            [label setTitle:@"仅支持jpg、png\n小于5M" forState:UIControlStateNormal];
            [label setTitleColor:HCCOLOR forState:UIControlStateNormal];
            
            [label addTarget:self action:@selector(zhizhaoCellClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:label];
            label.tag = 1000;
            label.layer.borderWidth = 0.5;
            label.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        }
        
        UIImageView *line = [cell.contentView viewWithTag:10022];
        if (!line) {
            line = [[UIImageView alloc] initWithFrame:CGRectMake(17, 99.5, SCREENW, 0.5)];
            line.backgroundColor = LIST_LINE_COLOR;
            [cell.contentView addSubview:line];
        }
        
        return cell;
    
    }

}

- (void)zhizhaoCellClick:(UIButton *)button {
    
    __weak typeof(button) weakButton = button;
    [_imgTool alertPhotoAction:^(UIImage *image, NSData *imgData) {
        [weakButton setTitle:@"" forState:UIControlStateNormal];
        [weakButton setBackgroundImage:image forState:UIControlStateNormal];
        [PublicTool showHudWithView:KEYWindow];
        [[NetworkManager sharedMgr]uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
            [PublicTool dismissHud:KEYWindow];
            if ([fileUrl containsString:@"http"]) {
                [self.cellValueDic setValue:fileUrl forKey:@"card"];
            }
        }];
    }];
}




- (void)textFieldChange:(UITextField*)tf{
    
    EditCell *cell =  (EditCell*)tf.superview.superview;
    NSString *title = cell.keyLabel.attributedText.string;
    title = [title stringByReplacingOccurrencesOfString:@"*" withString:@""];
    title = [title stringByReplacingOccurrencesOfString:@" " withString:@""];

    [self.cellValueDic setValue:tf.text forKey:self.keyValueDic[title]];
    
}

-(void)textViewDidChange:(UITextView *)textView{
    
    HMTextView *hmTV = (HMTextView*)textView;
    if([hmTV.cellKey isEqualToString:@"claim_reason"]){
        if (textView.text.length > 50) {
            [PublicTool showMsg:@"50字以内"];
            textView.text = [textView.text substringToIndex:50];
        }
        self.reason = textView.text;
    }
   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[EditCell class]]) {
        EditCell *eCell = (EditCell *)cell;
        [eCell.valueTf becomeFirstResponder];
    }
}
#pragma mark - FormEditTableViewCellDelegate
- (void)formEditTableViewCell:(FormEditTableViewCell *)cell buttonClick:(UIButton *)button {
    [self textFieldChange:cell.valueTf];
}
#pragma mark  --懒加载--
- (NSArray *)tableConfigs {
    if (!_tableConfigs) {
        _tableConfigs =  @[
                                @{@"title":@"姓名", @"key":@"name", @"placeholder":@"",@"cell":@"EditCell"},
                                @{@"title":@"手机号", @"key":@"phone", @"placeholder":@"",@"cell":@"EditCell"},
                                @{@"title":@"职位", @"key":@"position",@"placeholder":@"", @"cell":@"FormEditTableViewCell"},
                                @{@"title":@"名片或执照", @"key":@"card", @"placeholder":@"上传名片或执照，可认领项目\n进行管理和发布融资需求",@"cell":@"UITableViewCell"},
                                @{@"title":@"认领理由", @"key":@"claim_reason",@"placeholder":@"更多理由", @"cell":@"FormEditTableViewCell"},
                                ];
    }
    return _tableConfigs;
}


- (NSDictionary *)keyValueDic{
    if (!_keyValueDic) {
        _keyValueDic = @{@"项目名称":@"product",@"公司名称":@"company",@"公司官网":@"gw_link",@"地区":@"province",@"一句话介绍":@"yewu",@"行业领域":@"hangye1",@"姓名":@"name",@"职位":@"position",@"手机号":@"phone",@"名片或执照":@"card",@"简介":@"miaoshu",@"icon":@"icon",@"认领理由":@"claim_reason"};
    }
    return _keyValueDic;
}

- (NSMutableDictionary *)cellValueDic{
    if (!_cellValueDic) {
        _cellValueDic = [NSMutableDictionary dictionary];
    }
    return _cellValueDic;
}


- (UIView *)successView {
    if (!_successView) {
        _successView = [[UIView alloc] initWithFrame:self.view.bounds];
        _successView.backgroundColor = TABLEVIEW_COLOR;
        
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = HTColorFromRGB(0x666666);
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"项目提交成功\n请耐心等待审核";
        
        label.frame = CGRectMake(0, 200, SCREENW, 42);
        [_successView addSubview:label];
        
        UIButton *submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, SCREENH-40-40-kScreenTopHeight, 220, 40)];
        submitBtn.layer.masksToBounds = YES;
        submitBtn.layer.cornerRadius = 20;
        submitBtn.backgroundColor = BLUE_BG_COLOR;
        [submitBtn setTitle:@"返回首页" forState:UIControlStateNormal];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        submitBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [submitBtn addTarget:self action:@selector(gohomeVC) forControlEvents:UIControlEventTouchUpInside];
        [_successView addSubview:submitBtn];
        submitBtn.centerX = SCREENW/2.0;
    }
    return _successView;
}


- (void)gohomeVC {
    
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [QMPEvent event:@"pro_nabar_more_homeClick"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 60)];
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(17, 0, SCREENW-34, 60);
        label.font = [UIFont systemFontOfSize:12];
        label.text = @"为保证投资人能够快速的联系上您，工作人员需核实您的联系方式，请认证填写以下信息";
        label.numberOfLines = 0;
        [_headerView addSubview:label];
    }
    return _headerView;
}

@end
