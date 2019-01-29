//
//  CreateProController.m
//  qmp_ios
//
//  Created by QMP on 2018/3/29.
//  Copyright © 2018年 Molly. All rights reserved.
//  创建项目-表单

#import "CreateProController.h"
#import "MyInfoTableViewCell.h"
#import "TakeImageTool.h"
#import "OnePickerView.h"
#import "TextViewTableViewCell.h"
#import "EditCell.h"
#import "HMTextView.h"
#import "ReportModel.h"
#import "BPDeliverController.h"
#import "TextViewTableViewCell.h"
#import "FormEditTableViewCell.h"
#import "CreateProducrUserInfoController.h"
#import "SingleSelectionView.h"


@interface CreateProController () <UITableViewDelegate, UITableViewDataSource,
UITextViewDelegate, FormEditTableViewCellDelegate> {
    TakeImageTool *_imgTool;
}
@property (nonatomic, strong) NSMutableDictionary *cellValueDic;
@property (nonatomic, strong) NSDictionary *keyValueDic;
@property (nonatomic, strong) NSMutableArray *hangyes;
@property (nonatomic, strong) NSMutableArray *provinces;
@property (nonatomic, strong) NSArray *tableConfigs;

@property (nonatomic, strong) ReportModel *report;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, weak) UIImageView *logoView;
@end

@implementation CreateProController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imgTool = [[TakeImageTool alloc] init];
    [self.cellValueDic setValue:self.productName forKey:@"product"];
    [self.cellValueDic setValue:[WechatUserInfo shared].phone forKey:@"phone"];
    [self.cellValueDic setValue:[WechatUserInfo shared].nickname forKey:@"name"];

    [self initTableView];
    
    [self requestHangye];
    
    self.navigationItem.title = @"填写项目信息";
    
}

- (void)cancelBtnClick{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyInfoTableViewCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"MyInfoTableViewCellID"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    [self.tableView registerClass:[EditCell class] forCellReuseIdentifier:@"EditCellID"];
    [self.tableView registerClass:[TextViewTableViewCell class] forCellReuseIdentifier:@"TextViewTableViewCellID"];
    [self.tableView registerClass:[FormEditTableViewCell class] forCellReuseIdentifier:@"FormEditTableViewCellID"];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    // tableheader
    self.tableView.tableHeaderView = self.headerView;
    
    UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 100)];
    UIButton *submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 30, 220, 40)];
    submitBtn.layer.masksToBounds = YES;
    submitBtn.layer.cornerRadius = 20;
    submitBtn.backgroundColor = BLUE_BG_COLOR;
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [submitBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(footerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [footerV addSubview:submitBtn];
    submitBtn.centerX = footerV.width/2.0;
    self.tableView.tableFooterView = footerV;

}


- (void)logoClick{
    __weak typeof(self) weakSelf = self;
    [_imgTool alertPhotoAction:^(UIImage *image, NSData *imgData) {
        weakSelf.logoView.image = image;
        
        [PublicTool showHudWithView:KEYWindow];
        [[NetworkManager sharedMgr]uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
            [PublicTool dismissHud:KEYWindow];
            if ([fileUrl containsString:@"http"]) {
                [weakSelf.cellValueDic setValue:fileUrl forKey:@"icon"];
            }
        }];
    }];
}

- (void)footerButtonClick:(UIButton *)button {
    
    NSArray *bitianArr1 = @[@"项目名称",@"一句话介绍",@"地区",@"行业领域"];
    
    for (NSString *title in bitianArr1) {
        NSString *key = self.keyValueDic[title];
        if ([PublicTool isNull:self.cellValueDic[key]]) {
            [PublicTool showMsg:[NSString stringWithFormat:@"请填写 %@",title]];
            return;
        }
    }
    
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.cellValueDic];
    if (self.report) {
        [param setValue:self.report.name forKey:@"bp_name"];
        if (self.report.isMy) {
            [param setValue:self.report.reportId forKey:@"bp_file_id"];
        } else {
            [param setValue:self.report.fileid forKey:@"bp_file_id"];
        }
        [param setValue:self.report.pdfUrl forKey:@"bp"];
    }
    
    CreateProducrUserInfoController *vc = [[CreateProducrUserInfoController alloc] init];
    vc.productInfo = param;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)requestHangye {
    
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


#pragma mark --UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    }
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc]init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc]init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableConfigs count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    
    if ([cellClass isEqualToString:@"MyInfoTableViewCell"]) {
        MyInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyInfoTableViewCellID" forIndexPath:indexPath];
        cell.keyLbl.attributedText = attText;
        cell.valueLbl.text = self.cellValueDic[key];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.rightImgV setImage:[BundleTool imageNamed:@"leftarrow_gray"]];

        if ([title isEqualToString:@"商业计划书"]) {
            if (self.report) {
                [cell.rightImgV setImage:[BundleTool imageNamed:@"cha_icon"]];
                cell.valueLbl.text = self.report.name;
                cell.rightImgV.userInteractionEnabled = YES;
            } else {
                [cell.rightImgV setImage:[BundleTool imageNamed:@"leftarrow_gray"]];
                cell.valueLbl.text = @"仅自己可见和投递使用";
                cell.rightImgV.userInteractionEnabled = NO;
            }
        }
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BPDeleteClick)];
        [cell.rightImgV addGestureRecognizer:tapGest];
        cell.lineV.hidden = (self.tableConfigs.count == indexPath.row+1);
        return cell;
        
    } else if ([cellClass isEqualToString:@"EditCell"]) {
        
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

- (void)BPDeleteClick {
    self.report = nil;
    [self.tableView reloadData];
}


- (void)textFieldChange:(UITextField*)tf {
    
    EditCell *cell =  (EditCell*)tf.superview.superview;
    NSString *title = cell.keyLabel.attributedText.string;
    title = [title stringByReplacingOccurrencesOfString:@"*" withString:@""];
    title = [title stringByReplacingOccurrencesOfString:@" " withString:@""];

    [self.cellValueDic setValue:tf.text forKey:self.keyValueDic[title]];
    
}

-(void)textViewDidChange:(UITextView *)textView {
    
    HMTextView *hmTV = (HMTextView*)textView;
    if([hmTV.cellKey isEqualToString:@"yewu"]){
        if (textView.text.length > 30) {
            [PublicTool showMsg:@"30字以内"];
            textView.text = [textView.text substringToIndex:30];
        }
        [self.cellValueDic setValue:textView.text forKey:@"yewu"];
        
    }else  if([hmTV.cellKey isEqualToString:@"miaoshu"]){
        if (textView.text.length > 500) {
            [PublicTool showMsg:@"500字以内"];
            textView.text = [textView.text substringToIndex:30];
        }
        [self.cellValueDic setValue:textView.text forKey:@"miaoshu"];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *row = self.tableConfigs[indexPath.row];
    NSString *title = row[@"title"];
    if ([title isEqualToString:@"行业领域"]) {
        if (self.hangyes.count == 0) {
            return;
        }
        __weak typeof(self) weakSelf = self;
        SingleSelectionView *selectView = [[SingleSelectionView alloc]initWithTitle:@"选择行业" selectionTitles:self.hangyes selectedTitle:self.cellValueDic[self.keyValueDic[title]] selectedEvent:^(NSString *selectedStr) {
            [weakSelf.cellValueDic setValue:selectedStr forKey:self.keyValueDic[title]];
            [weakSelf.tableView reloadData];
        }];
    }else if ([title isEqualToString:@"商业计划书"]) {
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
    }else if([title isEqualToString:@"职位"]){
        
    }else if([title isEqualToString:@"地区"]){
        __weak typeof(self) weakSelf = self;
        SingleSelectionView *selectView = [[SingleSelectionView alloc]initWithTitle:@"选择地区" selectionTitles:self.provinces selectedTitle:self.cellValueDic[self.keyValueDic[title]] selectedEvent:^(NSString *selectedStr) {
            [weakSelf.cellValueDic setValue:selectedStr forKey:self.keyValueDic[title]];
            [weakSelf.tableView reloadData];
        }];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[EditCell class]]) {
        EditCell *eCell = (EditCell *)cell;
        [eCell.valueTf becomeFirstResponder];
    } else if ([cell isKindOfClass:[TextViewTableViewCell class]]) {
        TextViewTableViewCell *eCell = (TextViewTableViewCell *)cell;
        [eCell.textView becomeFirstResponder];
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
                                @{@"title":@"项目名称", @"key":@"product", @"placeholder":@"", @"cell":@"EditCell"},
                                @{@"title":@"公司名称", @"key":@"company", @"placeholder":@"", @"cell":@"EditCell"},
                                @{@"title":@"公司官网", @"key":@"gw_link", @"placeholder":@"", @"cell":@"EditCell"},
                                @{@"title":@"一句话介绍", @"key":@"yewu", @"placeholder":@"例：在线教育平台，30字以内", @"cell":@"TextViewTableViewCell"},
                                @{@"title":@"简介", @"key":@"miaoshu", @"placeholder":@"500字以内", @"cell":@"TextViewTableViewCell"},
                                @{@"title":@"地区", @"key":@"province", @"cell":@"MyInfoTableViewCell", @"valueTip":@""},
                                @{@"title":@"行业领域", @"key":@"hangye1", @"placeholder":@"", @"cell":@"MyInfoTableViewCell"},
                                @{@"title":@"商业计划书", @"key":@"商业计划书", @"placeholder":@"仅自己可见和投递使用", @"cell":@"MyInfoTableViewCell"},
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


- (NSMutableArray *)provinces {
    if (!_provinces) {
        _provinces = [NSMutableArray array];
        NSArray *provinceArr = [NSArray arrayWithContentsOfFile:[[BundleTool commonBundle]pathForResource:@"ProvinceFilter" ofType:@"plist"]];
        for (NSDictionary *dic in provinceArr) {
            [_provinces addObject:dic[@"name"]];
        }
    }
    return _provinces;
}

-(NSMutableArray *)hangyes{
    
    if (!_hangyes) {
        _hangyes = [NSMutableArray array];
    }
    return _hangyes;
}

-(NSMutableDictionary *)cellValueDic{
    if (!_cellValueDic) {
        _cellValueDic = [NSMutableDictionary dictionary];
    }
    return _cellValueDic;
}

- (UIView *)headerView {
    if (!_headerView) {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 80)];
        UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(17, (80-55)/2.0, 55, 55)];
        logoView.layer.masksToBounds = YES;
        logoView.layer.cornerRadius = 5;
        logoView.layer.borderWidth = 0.5;
        logoView.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        logoView.image = [BundleTool imageNamed:PROICON_DEFAULT];
        [headerView addSubview:logoView];
        logoView.userInteractionEnabled = YES;
        [logoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoClick)]];
        self.logoView = logoView;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(logoView.right+12, (80-14)/2.0, SCREENW, 14)];
        [label labelWithFontSize:12 textColor:H5COLOR];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:@"上传清晰的项目Logo"];
        label.attributedText = text;
        [headerView addSubview:label];
        
        _headerView = headerView;
    }
    return _headerView;
}

@end
