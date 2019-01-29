//
//  CreateOrgnizeViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/24.
//  Copyright © 2018年 Molly. All rights reserved.
//  创建机构-表单

#import "CreateOrgnizeViewController.h"
#import "EditCell.h"
#import "MyInfoTableViewCell.h"
#import "TakeImageTool.h"
#import "DatePickerView.h"
#import "HMTextView.h"
#import "OnePickerView.h"
#import "TextViewTableViewCell.h"
#import "TouziLingyuController.h"
#import "MultiSelectView.h"


@interface CreateOrgnizeViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate> {
    TakeImageTool *_imgTool;
}
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, weak) UIImageView *logoView;
@property (nonatomic, weak) UILabel *tipLabel;

@property (nonatomic, strong) NSArray *tableConfigs;
@property (nonatomic, strong) NSArray *tableConfigsPage2;
@property (nonatomic, strong) NSMutableDictionary *cellParamDict;

@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, assign) NSInteger page;
@end

@implementation CreateOrgnizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"创建机构";
    _imgTool = [[TakeImageTool alloc] init];
    
    [self initTableView];
    
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
    
    self.navigationItem.leftBarButtonItems = [self createBackButton:@""];
}

- (NSArray*)createBackButton:(NSString *)title {
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:LEFTBUTTONFRAME];
    if (title.length  > 1) {
        leftButton.width = 64;
        [leftButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        leftButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [leftButton setTitle:title forState:UIControlStateNormal];
    } else {
        leftButton.frame = LEFTBUTTONFRAME;
        [leftButton setImage:[BundleTool imageNamed:@"left-arrow"] forState:UIControlStateNormal];
    }
    [leftButton addTarget:self action:@selector(navBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)initTableView {
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyInfoTableViewCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"MyInfoTableViewCellID"];
    [self.tableView registerClass:[EditCell class] forCellReuseIdentifier:@"EditCellID"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    [self.tableView registerClass:[TextViewTableViewCell class] forCellReuseIdentifier:@"TextViewTableViewCellID"];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.tableHeaderView = self.headerView;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 100)];
    [view addSubview:self.nextButton];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(SCREENW-100-30, 6, 100, 12);
    label.attributedText = [self fixCellTitleShow:@"* 为必填项"];
    label.font = [UIFont boldSystemFontOfSize:12];
    label.textAlignment = NSTextAlignmentRight;
    [view addSubview:label];
    
    self.tableView.tableFooterView = view;
}

#pragma mark - Event
- (void)logoClick {
    [_imgTool alertPhotoAction:^(UIImage *image, NSData *imgData) {
        self.logoView.image = image;
        [PublicTool showHudWithView:self.view];
        [[NetworkManager sharedMgr]uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
            if ([fileUrl containsString:@"http"]) {
                [self.cellParamDict setValue:fileUrl forKey:@"icon"];
            }
            [PublicTool dismissHud:self.view];
        }];
    }];
}
- (void)editCellTextChange:(UITextField *)textField {
    UIView *v = textField.superview;
    EditCell *cell = (EditCell *)(v.superview);
    NSString *key = [self keyWithCellTitle:cell.keyLabel.text];
    
    [self.cellParamDict setValue:textField.text forKey:key];
}
- (void)navBackButtonClick {
    if (self.page == 1) {
        self.page = 0;
        [self.tableView reloadData];
        self.tableView.tableHeaderView = self.headerView;
        [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        
        self.navigationItem.leftBarButtonItems = [self createBackButton:@""];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)nextButtonClick:(UIButton *)button {
    if ([button.currentTitle isEqualToString:@"下一步"]) {
        NSArray *mustKey = @[@"name",@"jieshao",@"found_year",@"country",@"area",@"jg_type",@"zb_type"];
        for (NSString *key in mustKey) {
            if ([self.cellParamDict.allKeys containsObject:key]) {
                NSString *str = self.cellParamDict[key];
                if (str.length > 0) {
                    continue;
                }
            }
            NSString *str = [self cellTitleWithKey:key];
            if ([str hasPrefix:@"*"]) {
                str = [str substringFromIndex:1];
            }
            [PublicTool showMsg:[NSString stringWithFormat:@"请填写 %@", str]];
            return;
        }
        
        self.page = 1;
        [self.tableView reloadData];
        UIView *view = [UIView new];
        view.frame = CGRectMake(0, 0, SCREENW, 12);
        self.tableView.tableHeaderView = view;
        
        [self.tableView layoutIfNeeded];
        [self.tableView setContentOffset:CGPointZero animated:YES];
        [self.nextButton setTitle:@"提交机构信息" forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItems = [self createBackButton:@"上一步"];
        return;
    }
    NSArray *mustKey = @[@"name",@"jieshao",@"found_year",@"area",@"jg_type",@"zb_type",
                         @"tz_jieduan",@"money_type",@"tz_lunci",@"lingyu"];
    for (NSString *key in mustKey) {
        if ([self.cellParamDict.allKeys containsObject:key]) {
            NSString *str = self.cellParamDict[key];
            if (str.length > 0) {
                continue;
            }
        }
        NSString *str = [self cellTitleWithKey:key];
        if ([str hasPrefix:@"*"]) {
            str = [str substringFromIndex:1];
        }
        [PublicTool showMsg:[NSString stringWithFormat:@"请填写 %@", str]];
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.cellParamDict];
    [param setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"/s/userCreateJigou" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            [PublicTool showMsg:@"创建成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
    
}
#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(HMTextView *)textView {
    if (textView.text.length > 500) {
        [PublicTool showMsg:@"500字以内"];
        textView.text = [textView.text substringToIndex:500];
    }
    [self.cellParamDict setValue:textView.text forKey:textView.cellKey];
}
#pragma mark - UITableView
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return [self tableConfigsWithPage:self.page].count;
//    return self.tableConfigs.count;
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rows = [self tableConfigsWithPage:self.page];
    return rows.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *rows = [self tableConfigsWithPage:self.page];
    NSDictionary *row = rows[indexPath.row];
    NSString *cellClass = row[@"cell"];
    if ([cellClass isEqualToString:@"MyInfoTableViewCell"]) {
        MyInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyInfoTableViewCellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.keyLbl.attributedText = [self fixCellTitleShow:row[@"title"]];
        cell.valueLbl.text = self.cellParamDict[row[@"key"]];
        cell.lineV.hidden = (indexPath.row+1 == rows.count);
        return cell;
    } else if ([cellClass isEqualToString:@"EditCell"]) {
        EditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditCellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.valueTf.placeholder = row[@"placeholder"];
        cell.valueTf.text = self.cellParamDict[row[@"key"]];
        cell.keyLabel.attributedText = [self fixCellTitleShow:row[@"title"]];
        [cell.valueTf addTarget:self action:@selector(editCellTextChange:) forControlEvents:UIControlEventEditingChanged];
        cell.line.hidden = (indexPath.row+1 == rows.count);
        return cell;
    } else if ([cellClass isEqualToString:@"TextViewTableViewCell"]) {
        TextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewTableViewCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.keyLabel.attributedText = [self fixCellTitleShow:row[@"title"]];
        cell.textView.placehoder = row[@"placeholder"];
        cell.textView.delegate = self;
        cell.textView.cellKey =  row[@"key"];
        cell.textView.layer.borderWidth = 0.0;
        cell.lineView.hidden = (indexPath.row+1 == rows.count);
        cell.textView.text = self.cellParamDict[row[@"key"]];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID"];
        
        HMTextView *textView = [cell.contentView viewWithTag:1008];
        if (!textView) {
            textView = [[HMTextView alloc] init];
            textView.frame = CGRectMake(17, 0, SCREENW-34, 120);
            textView.tag = 1008;
            textView.layer.borderColor = [BORDER_LINE_COLOR CGColor];
            [cell.contentView addSubview:textView];
        }
        textView.text = self.cellParamDict[row[@"key"]];
        textView.placehoder = @"500字以内";
        textView.delegate = self;
        textView.cellKey = row[@"key"];
        
        UIImageView *line = [cell.contentView viewWithTag:1007];
        if (!line) {
            line = [[UIImageView alloc] init];
            line.frame = CGRectMake(17, 119.5, SCREENW-17, 0.5);
            line.backgroundColor = LIST_LINE_COLOR;
            [cell.contentView addSubview:line];
        }
        line.hidden = (indexPath.row+1 == rows.count);
        
        return cell;
    }
    
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *rows = [self tableConfigsWithPage:self.page];
    NSDictionary *row = rows[indexPath.row];
    NSString *title = row[@"title"];
    if ([title containsString:@"简介"]||[title containsString:@"LP背景"]||[title containsString:@"GP背景"]) {
        return 140;
    }
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *rows = [self tableConfigsWithPage:self.page];
    NSDictionary *row = rows[indexPath.row];
    NSString *key = row[@"key"];

    __weak typeof(self) weakSelf = self;
    if ([key containsString:@"found_year"]) { // 成立年份
        DatePickerView *datePicker = [[DatePickerView alloc] initDatePackerWithNumColoum:@"1" response:^(NSString *date) {
            [weakSelf.cellParamDict setValue:date forKey:key];
            [weakSelf.tableView reloadData];
        }];        
        [datePicker show];
    } else if ([key containsString:@"country"]) { // 国家
        OnePickerView *pickerV = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
            [weakSelf.cellParamDict setValue:selectedStr forKey:key];
            [weakSelf.tableView reloadData];
        } dataSource:@[@"国内", @"国外"]];
        [pickerV show];
    } else if ([key containsString:@"jg_type"]) { // 机构类型
        NSArray *selectedArr;

        if ([self.cellParamDict[key] containsString:@"|"]) {
            selectedArr = [self.cellParamDict[key] componentsSeparatedByString:@"|"];
        }else{
            selectedArr = [PublicTool isNull:self.cellParamDict[key]] ? @[]: @[self.cellParamDict[key]];
        }
        MultiSelectView *selectV = [[MultiSelectView alloc]initWithSelectionArr:@[@"天使投资人",@"天使投资机构",@"VC",@"PE",@"FA",@"知名企业",@"券商银行",@"FoF",@"其他"] selectedArr:selectedArr confirmSelect:^(NSString *selectedString) {
            [weakSelf.cellParamDict setValue:selectedString forKey:key];
            [weakSelf.tableView reloadData];
        }];
        [KEYWindow addSubview:selectV];
//        OnePickerView *pickerV = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
//            [weakSelf.cellParamDict setValue:selectedStr forKey:key];
//            [weakSelf.tableView reloadData];
//        } dataSource:@[@"天使投资人",@"天使投资机构",@"VC",@"PE",@"FA",@"知名企业",@"券商银行",@"FoF",@"其他"]];
//        [pickerV show];
    } else if ([key containsString:@"zb_type"]) { // 资本类型
        NSArray *selectedArr;
        
        if ([self.cellParamDict[key] containsString:@"|"]) {
            selectedArr = [self.cellParamDict[key] componentsSeparatedByString:@"|"];
        }else{
            selectedArr = [PublicTool isNull:self.cellParamDict[key]] ? @[]: @[self.cellParamDict[key]];
        }
        MultiSelectView *selectV = [[MultiSelectView alloc]initWithSelectionArr:@[@"本土",@"外资", @"合资"] selectedArr:selectedArr confirmSelect:^(NSString *selectedString) {
            [weakSelf.cellParamDict setValue:selectedString forKey:key];
            [weakSelf.tableView reloadData];
        }];
        [KEYWindow addSubview:selectV];
       
    } else if ([key containsString:@"tz_jieduan"]) { // 投资阶段
        NSArray *selectedArr;
        
        if ([self.cellParamDict[key] containsString:@"|"]) {
            selectedArr = [self.cellParamDict[key] componentsSeparatedByString:@"|"];
        }else{
            selectedArr = [PublicTool isNull:self.cellParamDict[key]] ? @[]: @[self.cellParamDict[key]];
        }
        MultiSelectView *selectV = [[MultiSelectView alloc]initWithSelectionArr:@[@"种子期",@"初创期",@"成长期",@"成熟期"] selectedArr:selectedArr confirmSelect:^(NSString *selectedString) {
            [weakSelf.cellParamDict setValue:selectedString forKey:key];
            [weakSelf.tableView reloadData];
        }];
        [KEYWindow addSubview:selectV];
//        OnePickerView *pickerV = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
//            [weakSelf.cellParamDict setValue:selectedStr forKey:key];
//            [weakSelf.tableView reloadData];
//        } dataSource:@[@"种子期",@"初创期",@"成长期",@"成熟期"]];
//        [pickerV show];
    } else if ([key containsString:@"money_type"]) { // 币种
        NSArray *selectedArr;
        
        if ([self.cellParamDict[key] containsString:@"|"]) {
            selectedArr = [self.cellParamDict[key] componentsSeparatedByString:@"|"];
        }else{
            selectedArr = [PublicTool isNull:self.cellParamDict[key]] ? @[]: @[self.cellParamDict[key]];
        }
        MultiSelectView *selectV = [[MultiSelectView alloc]initWithSelectionArr:@[@"人民币",@"美元"] selectedArr:selectedArr confirmSelect:^(NSString *selectedString) {
            [weakSelf.cellParamDict setValue:selectedString forKey:key];
            [weakSelf.tableView reloadData];
        }];
        [KEYWindow addSubview:selectV];
//        OnePickerView *pickerV = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
//            [weakSelf.cellParamDict setValue:selectedStr forKey:key];
//            [weakSelf.tableView reloadData];
//        } dataSource:@[@"人民币",@"美元"]];
//        [pickerV show];
    } else if ([key containsString:@"tz_lunci"]) { // 投资轮次
        NSArray *selectedArr;
        
        if ([self.cellParamDict[key] containsString:@"|"]) {
            selectedArr = [self.cellParamDict[key] componentsSeparatedByString:@"|"];
        }else{
            selectedArr = [PublicTool isNull:self.cellParamDict[key]] ? @[]: @[self.cellParamDict[key]];
        }
        MultiSelectView *selectV = [[MultiSelectView alloc]initWithSelectionArr:@[@"种子轮",@"天使轮",@"Pre-A轮",@"A轮",@"A+轮",@"B轮",@"B+轮",@"C轮",@"C轮及以后",@"收购", @"战略投资"] selectedArr:selectedArr confirmSelect:^(NSString *selectedString) {
            [weakSelf.cellParamDict setValue:selectedString forKey:key];
            [weakSelf.tableView reloadData];
        }];
        [KEYWindow addSubview:selectV];
//        OnePickerView *pickerV = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
//            [weakSelf.cellParamDict setValue:selectedStr forKey:key];
//            [weakSelf.tableView reloadData];
//        } dataSource:@[@"种子轮",@"天使轮",@"Pre-A轮",@"A轮",@"A+轮",@"B轮",@"B+轮",@"C轮",@"C轮及以后",@"收购", @"战略投资"]];
//        [pickerV show];
    } else if ([key containsString:@"lingyu"]) { // 投资领域
        
        TouziLingyuController *lingyuVC = [[TouziLingyuController alloc]init];
        NSString *lingyu = (NSString*)self.cellParamDict[@"lingyu"];
        lingyuVC.originalLingyu = lingyu;
        __weak typeof(self) weakSelf = self;
        lingyuVC.selectedLingyu = ^(NSString *lingyuStr) {
            [weakSelf.cellParamDict setValue:lingyuStr forKey:key];
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:lingyuVC animated:YES];
//
//        OnePickerView *pickerV = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
//            [weakSelf.cellParamDict setValue:selectedStr forKey:key];
//            [weakSelf.tableView reloadData];
//        } dataSource:[self lingyu]];
//        [pickerV show];
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[EditCell class]]) {
        EditCell *eCell = (EditCell *)cell;
        [eCell.valueTf becomeFirstResponder];
    }

}
#pragma mark - Getter
- (UIView *)headerView {
    if (!_headerView) {
        CGFloat headerViewHeigth = 80;
        CGFloat headerIconHeight = 55;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, headerViewHeigth)];
        
        UIImageView *logoView = [[UIImageView alloc] init];
        logoView.frame = CGRectMake(17, (headerViewHeigth-headerIconHeight)/2.0, headerIconHeight, headerIconHeight);
        logoView.layer.masksToBounds = YES;
        logoView.image = [BundleTool imageNamed:PROICON_DEFAULT];
        logoView.layer.cornerRadius = 5;
        logoView.layer.borderWidth = 0.5;
        logoView.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        [headerView addSubview:logoView];
        
        logoView.userInteractionEnabled = YES;
        [logoView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(logoClick)]];
        self.logoView = logoView;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(17+headerIconHeight+12, (headerViewHeigth-14)/2.0, SCREENW, 14)];
        [label labelWithFontSize:12 textColor:H5COLOR];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:@"上传清晰的logo"];
        label.attributedText = text;
        [headerView addSubview:label];
        self.tipLabel = label;

        _headerView = headerView;
    }
    return _headerView;
}
- (NSMutableDictionary *)cellParamDict {
    if (!_cellParamDict) {
        _cellParamDict = [NSMutableDictionary dictionary];
    }
    return _cellParamDict;
}
- (NSArray *)tableConfigsWithPage:(NSInteger)page {
    if (page==0) {
        return self.tableConfigs;
    }
    return self.tableConfigsPage2;
}
/*
 1）LOGO（选填）
 2）机构名称（10字以内）
 3）机构简介（500字以内）
 4）官网地址（选填）
 5）成立年份（底部弹框选择）
 6）国家（底部弹框选择：国内／国外）
 7）总部地区（自定义输入）
 8）机构类型（底部弹框选择：天使投资人／天使投资机构／VC/PE/FA／知名企业／券商银     行／FoF／其他）
 9）资本类型（底部弹框选择：本土／外资／合资）*/
- (NSArray *)tableConfigs {
    if (!_tableConfigs) {
        _tableConfigs = @[
                              @{@"title":@"*机构名称", @"placeholder":@"", @"key":@"name", @"other":@"",@"cell":@"EditCell"},
                              @{@"title":@"*简介", @"placeholder":@"500字以内", @"key":@"jieshao", @"other":@"",@"cell":@"TextViewTableViewCell"},
                              @{@"title":@"官网地址",  @"placeholder":@"", @"key":@"gw_link", @"other":@"",@"cell":@"EditCell"},
                              @{@"title":@"*成立年份", @"placeholder":@"", @"key":@"found_year", @"other":@"",@"cell":@"MyInfoTableViewCell"},
                              @{@"title":@"*国家",     @"placeholder":@"", @"key":@"country", @"other":@"",@"cell":@"MyInfoTableViewCell"},
                              @{@"title":@"*总部地区", @"placeholder":@"", @"key":@"area", @"other":@"",@"cell":@"EditCell"},
                              @{@"title":@"*机构类型", @"placeholder":@"", @"key":@"jg_type", @"other":@"",@"cell":@"MyInfoTableViewCell"},
                              @{@"title":@"*资本类型", @"placeholder":@"", @"key":@"zb_type", @"other":@"",@"cell":@"MyInfoTableViewCell"},
                           
                          ];
    }
    return _tableConfigs;
}
/*
 1）投资阶段（底部弹框选择：种子期／初创期／成长期／成熟期）
 2）币种（底部弹框选择：人民币／美元）
 3）投资轮次（底部弹框选择：种子轮／天使轮／Pre-A轮／A轮／A+轮／B轮／B+轮／C轮／C轮及以后／收购／战略投资）
 4）投资领域（底部弹框选择：金融／电子商务／文化娱乐／人工智能／企业服务／大数据／VR/AR／医疗健康／房产家居／汽车交通／体育健身／教育培训／旅游户外／生活服务／食品饮料／餐饮业／消费升级／先进制造／物联网／硬件／社交社区／游戏／工具软件／生产制造／服装纺织／物流运输／农业／建筑／环保／能源／电力／批发零售／区块链）
 5）投资额度（选填，自定义输入，万元／万美元）
 6）管理基金数量（选填，自定义输入）
 7）管理资本量（选填，自定义输入）
 8）LP背景（选填，自定义输入）
 9）GP背景（选填，自定义输入）
 */
- (NSArray *)tableConfigsPage2 {
    if (!_tableConfigsPage2) {
        _tableConfigsPage2 = @[
                               
                                    @{@"title":@"*投资阶段",@"placeholder":@"", @"key":@"tz_jieduan", @"other":@"",@"cell":@"MyInfoTableViewCell"},
                                    @{@"title":@"*币种",@"placeholder":@"", @"key":@"money_type", @"other":@"",@"cell":@"MyInfoTableViewCell"},
                                    @{@"title":@"*投资轮次",@"placeholder":@"", @"key":@"tz_lunci", @"other":@"",@"cell":@"MyInfoTableViewCell"},
                                    @{@"title":@"*投资领域",@"placeholder":@"", @"key":@"lingyu", @"other":@"",@"cell":@"MyInfoTableViewCell"},
                                    @{@"title":@"投资额度",@"placeholder":@"数字或数字区间值，例:100-200万", @"key":@"tz_money", @"other":@"",@"cell":@"EditCell"},
                                    @{@"title":@"管理基金数量",@"placeholder":@"", @"key":@"jijin_count", @"other":@"",@"cell":@"EditCell"},
                                    @{@"title":@"管理资本量",@"placeholder":@"", @"key":@"money_count", @"other":@"",@"cell":@"EditCell"},
                               
                                   @{@"title":@"LP背景",@"placeholder":@"", @"key":@"lp_background", @"other":@"",@"cell":@"TextViewTableViewCell"},
                                
                                   @{@"title":@"GP背景",@"placeholder":@"", @"key":@"gp_background", @"other":@"",@"cell":@"TextViewTableViewCell"},
                                
                               ];
    }
    return _tableConfigsPage2;
}
- (UIButton *)nextButton {
    if (!_nextButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((SCREENW-220)/2.0, 30, 220, 40);
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 20;
        button.backgroundColor = BLUE_BG_COLOR;
        [button setTitle:@"下一步" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [button addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _nextButton = button;
    }
    return _nextButton;
}
- (NSArray *)lingyu {
    return @[@"金融",@"电子商务",@"文化娱乐",@"人工智能",@"企业服务",@"大数据",@"VR",@"AR",@"医疗健康",@"房产家居",@"汽车交通",@"体育健身",@"教育培训",@"旅游户外",@"生活服务",@"食品饮料",@"餐饮业",@"消费升级",@"先进制造",@"物联网",@"硬件",@"社交社区",@"游戏",@"工具软件",@"生产制造",@"服装纺织",@"物流运输",@"农业",@"建筑",@"环保",@"能源",@"电力",@"批发零售",@"区块链"];
}
#pragma mark - Util
- (NSAttributedString *)fixCellTitleShow:(NSString *)str {
    NSMutableAttributedString *maStr = [[NSMutableAttributedString alloc] initWithString:str];
    if ([str hasPrefix:@"*"]) {
        [maStr setAttributes:@{NSForegroundColorAttributeName: RED_DARKCOLOR} range:NSMakeRange(0, 1)];
    } else {
        [maStr insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
    }
    return maStr;
}
- (NSString *)keyWithCellTitle:(NSString *)title {
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *configs = [self tableConfigsWithPage:self.page];
    for (NSDictionary *dict in configs) {
            if ([dict[@"title"] isEqualToString:title]) {
                return dict[@"key"];
            }
        
    }
    return @"other";
}
- (NSString *)cellTitleWithKey:(NSString *)key {
    NSArray *configs = [self tableConfigsWithPage:self.page];
    for (NSDictionary *dict in configs) {
            if ([dict[@"key"] isEqualToString:key]) {
                return dict[@"title"];
            }
        
    }
    return @"other";
}
@end
