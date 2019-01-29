//
//  CreateFinancingProController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/3.
//  Copyright © 2018年 Molly. All rights reserved.
//  发布项目的融资需求-表单

#import "CreateFinancingProController.h"
#import "MyInfoTableViewCell.h"
#import "TakeImageTool.h"
#import "OnePickerView.h"
#import "SearchProRegisterModel.h"
#import "SearchCompanyModel.h"
#import "EditCell.h"
#import "DatePickerView.h"
#import "UploadBPViewController.h"
#import "CompanyDetailModel.h"
#import "BPDeliverController.h"
#import "ReportModel.h"
#import "TextViewTableViewCell.h"
#import "HMTextView.h"
#import "FinanceSearchComController.h"

@interface CreateFinancingProController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate> {
    TakeImageTool *_imgTool;
}
@property(nonatomic,strong)NSArray *placeHolderArr;
@property(nonatomic,strong)NSDictionary *keyValueDic;
@property(nonatomic,strong)NSMutableDictionary *cellValueDic;

@property(nonatomic,strong)NSMutableArray *hangyes;
@property(nonatomic,strong)NSMutableArray *provinces;

@property(nonatomic,strong)NSArray *tableConfigs;

@property(nonatomic,strong)UIView *headerView;
@property(nonatomic,weak)UIImageView *logoView;
@property(nonatomic,weak)UILabel *tipLabel;
@property(nonatomic,weak)UILabel *nameLabel;
@property(nonatomic,weak)UILabel *descLabel;
@property(nonatomic,weak)UILabel *hangye1Label;
@property(nonatomic,weak)UIView *selectProjectView;

@property(nonatomic,strong)UIView *successView;
@property (nonatomic, weak) UIImageView *arrawView;

@property (nonatomic, strong) ReportModel *report;
@end

@implementation CreateFinancingProController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imgTool = [[TakeImageTool alloc]init];
    self.navigationItem.title =  @"我的项目";
    [self.cellValueDic setValue:[WechatUserInfo shared].phone forKey:@"wechat"];
    [self.cellValueDic setValue:[WechatUserInfo shared].nickname forKey:@"name"];

    [self initTableView];
    
    [self requestHangye];
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"MyInfoTableViewCellID"];
    [self.tableView registerClass:[EditCell class] forCellReuseIdentifier:@"EditCellID"];
    [self.tableView registerClass:[TextViewTableViewCell class] forCellReuseIdentifier:@"TextViewTableViewCellID"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.tableView.tableHeaderView = self.headerView;
    //tableheader
    
    self.headerView.userInteractionEnabled = YES;
    if (self.model) {
        self.tipLabel.hidden = YES;
        self.arrawView.hidden =  NO;
        
        if ([self.model isKindOfClass:[SearchCompanyModel class]]) {
            SearchCompanyModel *model = (SearchCompanyModel *)self.model;
            [self.logoView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
            self.nameLabel.text = model.product;
            self.descLabel.text = model.yewu;
            self.hangye1Label.text = model.hangye1;
            
            [self.nameLabel sizeToFit];
            [self.descLabel sizeToFit];
            self.descLabel.width = MIN(self.descLabel.width, SCREENW-self.logoView.right-20);
            [self.hangye1Label sizeToFit];
            self.logoView.hidden = NO;
        } else if ([self.model isKindOfClass:[CompanyDetailModel class]]) {
            CompanyDetailModel *model = (CompanyDetailModel *)self.model;
            [self.logoView sd_setImageWithURL:[NSURL URLWithString:model.company_basic.icon]];
            self.nameLabel.text = model.company_basic.product;
            self.descLabel.text = model.company_basic.yewu;
            self.hangye1Label.text = model.company_basic.hangye1;
            
            [self.nameLabel sizeToFit];
            [self.descLabel sizeToFit];
            self.descLabel.width = MIN(self.descLabel.width, SCREENW-self.logoView.right-20);
            [self.hangye1Label sizeToFit];
            self.logoView.hidden = NO;
        }
    }  else {
        self.nameLabel.text = @"";
        self.descLabel.text = @"";
        self.hangye1Label.text = @"";
        self.logoView.image = [UIImage imageNamed:PROICON_DEFAULT];
        self.arrawView.hidden = YES;
        if (self.isNewProject) {
            self.headerView.height = 80;
            self.tipLabel.hidden = NO;
            self.logoView.hidden = NO;
            self.logoView.frame = CGRectMake(17, (80-55)/2.0, 55, 55);
            self.tipLabel.frame = CGRectMake(17+55+12, (80-14)/2.0, 300, 14);
        } else {
            self.logoView.hidden = YES;
            self.headerView.height = 100;
            self.selectProjectView.hidden = NO;
            
        }
        
    }
    
    UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 100)];
    UIButton *submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 30, 220, 40)];
    submitBtn.layer.masksToBounds = YES;
    submitBtn.layer.cornerRadius = 20;
    submitBtn.backgroundColor = BLUE_BG_COLOR;
    [submitBtn setTitle:@"提交项目信息" forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [footerV addSubview:submitBtn];
    submitBtn.centerX = footerV.width/2.0;
    self.tableView.tableFooterView = footerV;
}

#pragma mark - Event
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

- (void)logoClick{
    if (self.model) return;
    [_imgTool alertPhotoAction:^(UIImage *image, NSData *imgData) {
        self.logoView.image = image;
        
        [[NetworkManager sharedMgr]uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
            if ([fileUrl containsString:@"http"]) {
                [self.cellValueDic setValue:fileUrl forKey:@"icon"];
            }
        }];
    }];
}


- (void)gohomeVC {

    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [QMPEvent event:@"pro_nabar_more_homeClick"];
    
}

- (void)submitBtnClick{
    
    if (self.model) {
        
        if ([self.model isKindOfClass:[SearchCompanyModel class]]) {
            SearchCompanyModel *model = (SearchCompanyModel *)self.model;
            [self.cellValueDic setValue:model.product?model.product:@"" forKey:@"product"];
            [self.cellValueDic setValue:model.icon?model.icon:@"" forKey:@"icon"];
            [self.cellValueDic setValue:model.productId?model.productId:@"" forKey:@"product_id"];
            [self.cellValueDic setValue:model.yewu?model.yewu:@"" forKey:@"desc"];
            [self.cellValueDic setValue:model.hangye1?model.hangye1:@"" forKey:@"lingyu"];
            [self.cellValueDic setValue:model.company?model.company:@"" forKey:@"company"];
            [self.cellValueDic setValue:model.desc?model.desc:@"" forKey:@"jieshao"];
        }
        
    }
    
    if (!self.selectProjectView.hidden) {
        [PublicTool showMsg:@"请选择项目"];
        return;
    }
    
    if (![PublicTool checkTel:self.cellValueDic[@"wechat"]]) {
        return;
    }
    
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.cellValueDic];
    [param setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
    
    
    NSString *money = param[@"fan_amount"];
    if (money.length > 0) {
        if (![money hasSuffix:@"万"]) {
            [param setValue:[NSString stringWithFormat:@"%@万", money] forKey:@"fan_amount"];
        }
    }
    
    NSString *expire_time = param[@"expire_time"];
    if (expire_time.length > 0) {
        if (![expire_time hasSuffix:@"00:00:00"]) {
            expire_time = [expire_time stringByAppendingString:@" 00:00:00"];
            [param setValue:expire_time forKey:@"expire_time"];
        }
    }
    
    if (![self checkParams]) return;

    if (self.report) {
        
        [param setValue:self.report.name forKey:@"bp_name"];
        if (self.report.isMy) {
            [param setValue:self.report.reportId forKey:@"bp_file_id"];
        } else {
            [param setValue:self.report.fileid forKey:@"bp_file_id"];
        }
        [param setValue:self.report.pdfUrl forKey:@"bp"];
   
    }else{
        [PublicTool showMsg:@"请上传商业计划书"];
        return;
    }
    
    
    [PublicTool showHudWithView:KEYWindow];
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/financeNeedsRelease" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        if (resultData) {
            [PublicTool showMsg:@"创建成功"];
            [self.view addSubview:self.successView];
        } else {
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
}

- (void)editCellTextChange:(UITextField *)textfield {
    
    UIView *v = textfield.superview;
    EditCell *cell = (EditCell *)(v.superview);
    NSString *title = cell.keyLabel.attributedText.string;
    title = [title stringByReplacingOccurrencesOfString:@"*" withString:@""];
    title = [title stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSString *key = self.keyValueDic[title];
    
    if ([key isEqualToString:@"fan_scale"]) {
        if (textfield.text.length > 0 && ![self isNum:textfield.text]) {
            textfield.text = @"";
            [PublicTool showMsg:@"请输入数字"];
        }
        if ([textfield.text integerValue] < 0 || [textfield.text integerValue] > 100) {
            textfield.text = @"";
            [PublicTool showMsg:@"比例在1-100之间"];
        }
    }else if ([key isEqualToString:@"fan_amount"]) {
        if (textfield.text.length > 0 && ![self isNum:textfield.text]) {
            textfield.text = @"";
            [PublicTool showMsg:@"请输入数字"];
        }
    }
    [self.cellValueDic setValue:textfield.text forKey:key];
}
- (void)searchProject {
    if (self.isNewProject) {
        return;
    }
    FinanceSearchComController * finSearchVC = [[FinanceSearchComController alloc] init];
    [self.navigationController pushViewController:finSearchVC animated:YES];
    return;
    
}
- (void)updateUIWithModel:(id)model {
    self.selectProjectView.hidden = YES;
    [self.tableView removeFromSuperview];
    
    if (model) {
        self.model = model;
        self.isNewProject = NO;
        [self initTableView];
    } else {
        self.isNewProject = YES;
        [self initTableView];
    }
}
#pragma mark - NetWork
- (void)requestHangye{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"1" forKey:@"filter_type"];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/showuserhangye" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            [self.hangyes removeAllObjects];
            for (NSDictionary *dic in resultData[@"data"]) {
                [self.hangyes addObject:dic[@"name"]];
            }
        }
    }];
    
}
#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(HMTextView *)textView {
    
    NSString *key = textView.cellKey;
    if ([key isEqualToString:@"bright_spot"] && textView.text.length > 5000) {
        [PublicTool showMsg:@"5000字以内"];
        textView.text = [textView.text substringToIndex:5000];
        return;
    }
    
    if ([key isEqualToString:@"jieshao"] && textView.text.length > 500) {
        [PublicTool showMsg:@"500字以内"];
        textView.text = [textView.text substringToIndex:500];
        return;
    }
    
   if ([key isEqualToString:@"desc"] && textView.text.length > 30) {
        [PublicTool showMsg:@"30字以内"];
        textView.text = [textView.text substringToIndex:30];
        return;
    }
    
    [self.cellValueDic setValue:textView.text forKey:textView.cellKey];
}

#pragma mark --UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return  self.tableConfigs.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *sectionConfigs = self.tableConfigs[indexPath.section];
    NSDictionary *config = sectionConfigs[indexPath.row];
    if ([config[@"key"] isEqualToString:@"card"]) {
        return 100;
    }
    if ([config[@"cellClass"] isEqualToString:@"TextViewTableViewCell"]) {
        if ([config[@"placeholder"] isEqualToString:@"一句话介绍"]) {
            return 120;
        }
        return kTextViewTableViewCellHeight;
    }
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.tableConfigs.count-1) {
        return 89;
    }
    if (section == 0) {
        return 0.1;
    }
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.tableConfigs.count-1) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, SCREENW, 89);
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(15, 35, SCREENW-30, 36);
        label.numberOfLines = 0;
        label.textColor = HTColorFromRGB(0x333333);
        label.font = [UIFont boldSystemFontOfSize:12];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:@"*为保证投资人能够快速联系上您，工作人员需核实您的联系方式，请认真填写以下信息"];
        [text addAttributes:@{NSForegroundColorAttributeName:RED_TEXTCOLOR} range:NSMakeRange(0, 1)];
        label.attributedText = text;
        [view addSubview:label];
        return view;
    }
    return [UIView new];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *sectionConfigs = self.tableConfigs[section];
    return sectionConfigs.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *sectionConfigs = self.tableConfigs[indexPath.section];
    NSDictionary *config = sectionConfigs[indexPath.row];
    NSString *title = config[@"placeholder"];
    NSArray *bitianArr;
    if (self.selectProjectView.hidden && !self.model) {
        bitianArr = @[@"项目名称",@"行业领域",@"一句话介绍",@"简介",@"地区",@"融资轮次",@"融资币种",@"融资金额（万）",@"出让股份（%）",@"商业计划书",@"服务截止时间",@"融资亮点",@"姓名",@"职位",@"手机号",@"名片或执照"];
    }else{
        bitianArr = @[];
    }
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:title];
    if ([bitianArr containsObject:title]) {
        attText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"*%@",title]];
        [attText addAttributes:@{NSForegroundColorAttributeName:RED_TEXTCOLOR} range:NSMakeRange(0, 1)];
    }else{
        attText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@",title]];
    }
    
    NSString *className = config[@"cellClass"];
    if ([className isEqualToString:@"MyInfoTableViewCell"]) {
        MyInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyInfoTableViewCellID" forIndexPath:indexPath];
        cell.keyLbl.attributedText = attText;
        cell.valueLbl.text = self.cellValueDic[config[@"key"]];
        [cell.rightImgV setImage:[UIImage imageNamed:@"leftarrow_gray"]];

        if ([config[@"key"] isEqualToString:@"fan_bp"]) {
            if (self.report) {
                [cell.rightImgV setImage:[UIImage imageNamed:@"cha_icon"]];
                cell.valueLbl.text = self.report.name;
                cell.rightImgV.userInteractionEnabled = YES;
            } else {
                [cell.rightImgV setImage:[UIImage imageNamed:@"leftarrow_gray"]];
                cell.valueLbl.text = @"仅自己可见和投递使用";
                cell.rightImgV.userInteractionEnabled = NO;
            }
        }
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bpDeleteClick)];
        [cell.rightImgV addGestureRecognizer:tapGest];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else  if ([className isEqualToString:@"EditCell"]) {
        EditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditCellID"];
        cell.keyLabel.attributedText = attText;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.valueTf.placeholder = config[@"valueTip"];
        cell.valueTf.text = self.cellValueDic[config[@"key"]];
        [cell.valueTf addTarget:self action:@selector(editCellTextChange:) forControlEvents:UIControlEventEditingChanged];
        return cell;
    } else if ([className isEqualToString:@"TextViewTableViewCell"]) {
        TextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewTableViewCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.keyLabel.attributedText = attText;
        cell.textView.placehoder = config[@"valueTip"];
        cell.textView.delegate = self;
        cell.textView.cellKey =  config[@"key"];
        cell.textView.layer.borderWidth = 0.0;
        cell.textView.text = self.cellValueDic[config[@"key"]];
        cell.lineView.hidden = (indexPath.row+1 == sectionConfigs.count);
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLab = [cell.contentView viewWithTag:900];
        if (!titleLab) {
            titleLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 120, 40)];
            titleLab.font = [UIFont systemFontOfSize:14];
            titleLab.numberOfLines = 1;
            titleLab.textColor = NV_TITLE_COLOR;
            titleLab.attributedText = attText;
            [cell.contentView addSubview:titleLab];
            titleLab.tag = 900;
        }
        
        UILabel *desLab = [cell.contentView viewWithTag:999];
        if (!desLab) {
            desLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 40, SCREENW-34-120 - 20, 45)];
            desLab.font = [UIFont systemFontOfSize:14];
            desLab.numberOfLines = 2;
            desLab.attributedText = [config[@"valueTip"] stringWithParagraphlineSpeace:4 textColor:H9COLOR textFont:[UIFont systemFontOfSize:14]];
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
        
        return cell;
    }
}
- (void)bpDeleteClick {
    self.report = nil;
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *sectionConfigs = self.tableConfigs[indexPath.section];
    NSDictionary *config = sectionConfigs[indexPath.row];
    NSString *key = config[@"key"];
    
    __weak typeof(self) weakSelf = self;
    if ([key isEqualToString:@"lingyu"]) {
        OnePickerView *pickerV = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
            [weakSelf.cellValueDic setValue:selectedStr forKey:key];
            [weakSelf.tableView reloadData];
        } dataSource:self.hangyes];
        [pickerV show];
    }else if ([key isEqualToString:@"province"]) {
        OnePickerView *pickerV = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
            [weakSelf.cellValueDic setValue:selectedStr forKey:key];
            [weakSelf.tableView reloadData];
        } dataSource:self.provinces];
        [pickerV show];
        
    } else if ([key isEqualToString:@"lunci"]) {
        NSMutableArray *total = [NSMutableArray arrayWithObjects:@"种子轮",@"天使轮",@"Pre-A轮",@"A轮",@"A+轮",@"Pre-B轮",@"B轮",@"B+轮",@"C轮",@"C+轮",@"D轮～Pre-IPO",nil];
        OnePickerView *pickerV = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
            [weakSelf.cellValueDic setValue:selectedStr forKey:key];
            [weakSelf.tableView reloadData];
        } dataSource:total];
        [pickerV show];
    } else if ([key isEqualToString:@"currency"]) {
        OnePickerView *pickerV = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
            [weakSelf.cellValueDic setValue:selectedStr forKey:key];
            [weakSelf.tableView reloadData];
        } dataSource:@[@"人民币",@"美元"]];
        [pickerV show];
    } else if ([key isEqualToString:@"fan_bp"]) {
//        UploadBPViewController *vc = [[UploadBPViewController alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
        BPDeliverController *selectVC = [[BPDeliverController alloc]init];
        __weak typeof(self) weakSelf = self;
        selectVC.sourceReport = self.report;
        selectVC.selectedBP = ^(ReportModel *report) {
            weakSelf.report = report;
            [weakSelf.tableView reloadData];
        };
        selectVC.isCreateFinanceVC = YES;
        [self.navigationController pushViewController:selectVC animated:YES];
        return;
    } else if ([key isEqualToString:@"position"]){
        OnePickerView *pickerV = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
            [weakSelf.cellValueDic setValue:selectedStr forKey:key];
            [weakSelf.tableView reloadData];
        } dataSource:@[@"创始人", @"联合创始人", @"其他"]];
        [pickerV show];
    } else if ([key isEqualToString:@"expire_time"]){
        SLDatePickerView *datePicker = [[SLDatePickerView alloc]initDatePackerWithResponse:^(NSString *date) {
            [weakSelf.cellValueDic setValue:date forKey:key];
            [weakSelf.tableView reloadData];
        }];
        [datePicker show];
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[EditCell class]]) {
        EditCell *eCell = (EditCell *)cell;
        [eCell.valueTf becomeFirstResponder];
    }

}
#pragma mark - Util
- (NSString *)placeHolderWithKey:(NSString *)key {
    for (NSArray *arr in self.tableConfigs) {
        for (NSDictionary *dict in arr) {
            if ([dict[@"key"] isEqualToString:key]) {
                return dict[@"placeholder"];
            }
        }
    }
    return key;
}
- (BOOL)checkParams {
    
    NSArray *arr = @[@"product",@"lunci",@"currency",@"fan_amount",@"fan_scale",@"expire_time",@"bright_spot",@"name",@"position",@"wechat",@"card"];
    
    if (!self.model) {
        arr = @[@"product",@"desc",@"province",@"lingyu",@"jieshao",@"lunci",@"currency",@"fan_amount",@"fan_scale",@"expire_time",@"bright_spot",
                @"name",@"position",@"wechat",@"card"];
    }
    if (self.cellValueDic.allKeys.count <= 0) {
        [PublicTool showMsg:@"请填写相关信息"];
        return NO;
    }
    for (NSString *key in arr) {
        if([PublicTool isNull:self.cellValueDic[key]]) {
            [PublicTool showMsg:[NSString stringWithFormat:@"请填写 %@", [self placeHolderWithKey:key]]];
            return NO;
        }
    }
    return YES;
}
#pragma mark  --懒加载--
- (NSArray *)tableConfigs {
    return [self updateTableConfigs];
}
- (NSArray *)updateTableConfigs {
    
    NSArray *section1 = @[
                          @{@"placeholder":@"项目名称", @"key":@"product", @"cellClass":@"EditCell", @"valueTip":@""},
                          @{@"placeholder":@"公司名称", @"key":@"company", @"cellClass":@"EditCell", @"valueTip":@""},
                          @{@"placeholder":@"公司官网", @"key":@"gw_link", @"cellClass":@"EditCell", @"valueTip":@""},
                          @{@"placeholder":@"一句话介绍", @"key":@"desc", @"cellClass":@"TextViewTableViewCell", @"valueTip":@"例：在线教育平台,30字以内"},
                          @{@"placeholder":@"地区", @"key":@"province", @"cellClass":@"MyInfoTableViewCell", @"valueTip":@""},
                          @{@"placeholder":@"行业领域", @"key":@"lingyu", @"cellClass":@"MyInfoTableViewCell", @"valueTip":@""},
                          @{@"placeholder":@"简介", @"key":@"jieshao", @"cellClass":@"TextViewTableViewCell", @"valueTip":@"请输入您的公司或项目简介，500字以内"},
                          ];
    NSArray *section2 = @[
                          @{@"placeholder":@"融资轮次", @"key":@"lunci", @"cellClass":@"MyInfoTableViewCell", @"valueTip":@""},
                          @{@"placeholder":@"融资币种", @"key":@"currency", @"cellClass":@"MyInfoTableViewCell", @"valueTip":@""},
                          @{@"placeholder":@"融资金额（万）", @"key":@"fan_amount", @"cellClass":@"EditCell", @"valueTip":@"请输入数字金额"},
                          @{@"placeholder":@"出让股份（%）", @"key":@"fan_scale", @"cellClass":@"EditCell", @"valueTip":@"请输入100以内的数字"},
                          @{@"placeholder":@"商业计划书", @"key":@"fan_bp", @"cellClass":@"MyInfoTableViewCell", @"valueTip":@"仅自己可见和投递使用"},
                          @{@"placeholder":@"服务截止时间", @"key":@"expire_time", @"cellClass":@"MyInfoTableViewCell", @"valueTip":@""},
                          @{@"placeholder":@"融资亮点", @"key":@"bright_spot", @"cellClass":@"TextViewTableViewCell", @"valueTip":@"请输入您的项目亮点和优势，5000字以内"},
                          ];
    NSArray *section3 = @[
                          @{@"placeholder":@"姓名", @"key":@"name", @"cellClass":@"EditCell", @"valueTip":@""},
                          @{@"placeholder":@"手机号", @"key":@"wechat", @"cellClass":@"EditCell", @"valueTip":@""},
                          @{@"placeholder":@"职位", @"key":@"position", @"cellClass":@"MyInfoTableViewCell", @"valueTip":@""},
                          @{@"placeholder":@"名片或执照", @"key":@"card", @"cellClass":@"UITableViewCell", @"valueTip":@"上传名片或执照，可认领项目\n进行管理和发布融资需求"},
                          ];
    NSArray *tableConfigs;
    if (self.model) {
        tableConfigs = @[section2, section3];
    } else {
        if (self.isNewProject) {
            tableConfigs = @[section1, section2, section3];
        } else {
            tableConfigs = @[section2, section3];
        }
    }
    return tableConfigs;
}
- (BOOL)isNum:(NSString *)checkedNumString {
    NSString* number=@"^[0-9]+([.]{0,1}[0-9]+){0,1}$";
    if ([checkedNumString hasSuffix:@"."]) {
        checkedNumString = [checkedNumString substringToIndex:checkedNumString.length-1];
    }
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:checkedNumString];
}



-(NSMutableArray *)hangyes{
    if (!_hangyes) {
        _hangyes = [NSMutableArray array];
    }
    return _hangyes;
}

-(NSDictionary *)keyValueDic{
    if (!_keyValueDic) {
        _keyValueDic = @{@"项目名称":@"product",@"公司名称":@"company",@"公司官网":@"gw_link",@"地区":@"province",@"一句话介绍":@"desc",@"行业领域":@"lingyu",@"姓名":@"name",@"职位":@"position",@"手机号":@"wechat",@"名片或执照":@"card",@"简介":@"jieshao",@"icon":@"icon",@"融资轮次":@"lunci",@"融资币种":@"currency",@"融资金额（万）":@"fan_amount",@"出让股份（%）":@"fan_scale",@"商业计划书":@"fan_bp",@"服务截止时间":@"expire_time",@"融资亮点":@"bright_spot"};
    }
    return _keyValueDic;
}
-(NSMutableDictionary *)cellValueDic{
    if (!_cellValueDic) {
        _cellValueDic = [NSMutableDictionary dictionary];
    }
    return _cellValueDic;
}


- (NSMutableArray *)provinces{
    if (!_provinces) {
        _provinces = [NSMutableArray array];
        NSArray *provinceArr = [NSArray arrayWithContentsOfFile:[nilpathForResource:@"ProvinceFilter" ofType:@"plist"]];
        for (NSDictionary *dic in provinceArr) {
            [_provinces addObject:dic[@"name"]];
        }
    }
    return _provinces;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIView *)headerView {
    if (!_headerView) {
        UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 88)];
        
        // 按照项目存在布局
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(15, 17, 44, 44)];
        imgV.layer.masksToBounds = YES;
        imgV.image = [UIImage imageNamed:PROICON_DEFAULT];
        imgV.layer.cornerRadius = 5;
        imgV.layer.borderWidth = 0.5;
        imgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        [headerV addSubview:imgV];
        imgV.userInteractionEnabled = YES;
        [imgV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(logoClick)]];
        self.logoView = imgV;
        
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 113, SCREENW, 14)];
        [lab labelWithFontSize:12 textColor:H5COLOR];
        lab.textAlignment = NSTextAlignmentLeft;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:@"上传清晰的项目LOGO"];
        lab.attributedText = text;
        [headerV addSubview:lab];
        lab.hidden = YES;
        self.tipLabel = lab;
        
        UIImageView *arrawView1 = [[UIImageView alloc] init];
        arrawView1.frame = CGRectMake(SCREENW-15-8, (100-14)/2.0, 8, 14);
        arrawView1.image = [UIImage imageNamed:@"black_arraw"];
        [headerV addSubview:arrawView1];
        self.arrawView = arrawView1;
        
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(15+44+11, 15, 0, 21);
        nameLabel.font = [UIFont boldSystemFontOfSize:15];
        nameLabel.textColor = HTColorFromRGB(0x272727);
        [headerV addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        UILabel *descLabel = [[UILabel alloc] init];
        descLabel.frame = CGRectMake(15+44+11, 38, 0, 13.5);
        [descLabel labelWithFontSize:13 textColor:HTColorFromRGB(0x9d9fa3)];
        [headerV addSubview:descLabel];
        self.descLabel = descLabel;
        
        UILabel *hangyeLabel = [[UILabel alloc] init];
        hangyeLabel.frame = CGRectMake(15+44+11, 58, 0, 13.5);
        [hangyeLabel labelWithFontSize:13 textColor:HTColorFromRGB(0x63656A)];
        [headerV addSubview:hangyeLabel];
        self.hangye1Label = hangyeLabel;
        
        
        UIView *selectProjectView = [[UIView alloc] init];
        selectProjectView.frame = CGRectMake(0, 0, SCREENW, 100);
        selectProjectView.backgroundColor = RGB(214, 214, 214, 1);
        selectProjectView.hidden = YES;
        [headerV addSubview:selectProjectView];
        self.selectProjectView = selectProjectView;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(15, 0, 200, 100);
        label.font = [UIFont boldSystemFontOfSize:18];
        label.textColor = [UIColor blackColor];
        label.text = @"项目名称";
        [selectProjectView addSubview:label];
        
        UIImageView *arrawView = [[UIImageView alloc] init];
        arrawView.frame = CGRectMake(SCREENW-15-8, (100-14)/2.0, 8, 14);
        arrawView.image = [UIImage imageNamed:@"black_arraw"];
        [selectProjectView addSubview:arrawView];
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchProject)];
        [selectProjectView addGestureRecognizer:tapGest];
        
        
        UITapGestureRecognizer *tapGest2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchProject)];
        [headerV addGestureRecognizer:tapGest2];
        
        _headerView = headerV;
    }
    return _headerView;
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
        label.text = @"融资需求发布成功\n请耐心等待审核";
        
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


@end
