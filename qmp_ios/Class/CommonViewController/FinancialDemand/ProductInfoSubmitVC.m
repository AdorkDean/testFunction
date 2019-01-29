//
//  ProductInfoSubmitVC.m
//  qmp_ios
//
//  Created by QMP on 2018/5/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductInfoSubmitVC.h"
#import "MyInfoTableViewCell.h"
#import "TakeImageTool.h"
#import "OnePickerView.h"
#import "TextViewTableViewCell.h"
#import "EditCell.h"
#import "HMTextView.h"
#import "TextViewTableViewCell.h"
#import "FinancialInfoSubmitVC.h"
#import "SingleSelectionView.h"


@interface ProductInfoSubmitVC ()<UITableViewDelegate,UITableViewDataSource, UITextViewDelegate>
{
    
    UIImageView *_logo;
    TakeImageTool *_imgTool;
}
@property(nonatomic,strong)NSMutableDictionary *cellValueDic;
@property(nonatomic,strong)NSDictionary *keyValueDic;

@property(nonatomic,strong)NSMutableArray *hangyes;
@property(nonatomic,strong)NSMutableArray *provinces;

@property (nonatomic, strong) NSArray *tableConfigs;
@property(nonatomic,strong)UIView *successView;


@property (nonatomic, strong) NSString *reason;
@end

@implementation ProductInfoSubmitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imgTool = [[TakeImageTool alloc]init];
    [self.cellValueDic setValue:self.productName forKey:@"product"];

    [self buildBarbutton];
    [self initTableView];
    
    [self requestHangye];
    
}



- (void)buildBarbutton{
    
    //    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(17, kScreenTopHeight - 33, 80, 20)];
    //    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    //    [leftButton setTitleColor:H5COLOR forState:UIControlStateNormal];
    //    leftButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    //    [leftButton addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    //    UIButton *btn = [[UIButton alloc]init];
    //    UIBarButtonItem *zhanweiBtnItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    //    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    //    self.navigationItem.leftBarButtonItems = @[item,zhanweiBtnItem];
    
    self.navigationItem.title =  @"填写项目信息";
    
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
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    //tableheader
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 80)];
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(17, (80-55)/2.0, 55, 55)];
    imgV.layer.masksToBounds = YES;
    imgV.layer.cornerRadius = 5;
    imgV.layer.borderWidth = 0.5;
    imgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    [headerV addSubview:imgV];
    imgV.image = [UIImage imageNamed:PROICON_DEFAULT];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(imgV.right+12, (80-14)/2.0, SCREENW, 14)];
    [lab labelWithFontSize:12 textColor:H5COLOR];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:@"上传清晰的项目Logo"];
    lab.attributedText = text;
    [headerV addSubview:lab];
    _logo = imgV;
    self.tableView.tableHeaderView = headerV;
    _logo.userInteractionEnabled = YES;
    [_logo addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(logoClick)]];
    
    UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 100)];
    UIButton *submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 30, 220, 40)];
    submitBtn.layer.masksToBounds = YES;
    submitBtn.layer.cornerRadius = 20;
    submitBtn.backgroundColor = BLUE_BG_COLOR;
    [submitBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [footerV addSubview:submitBtn];
    submitBtn.centerX = footerV.width/2.0;
    self.tableView.tableFooterView = footerV;
    
}


- (void)logoClick{
    
    [_imgTool alertPhotoAction:^(UIImage *image, NSData *imgData) {
        _logo.image = image;
        
        [[NetworkManager sharedMgr]uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
            if ([fileUrl containsString:@"http"]) {
                [self.cellValueDic setValue:fileUrl forKey:@"icon"];
            }
        }];
    }];
}

- (void)submitBtnClick{
    
    NSArray *bitianArr = @[@"项目名称",@"一句话介绍",@"简介",@"地区",@"行业领域"];
    
    for (NSString *title in bitianArr) {
        NSString *key = self.keyValueDic[title];
        if ([PublicTool isNull:self.cellValueDic[key]]) {
            [PublicTool showMsg:[NSString stringWithFormat:@"请填写 %@",title]];
            return;
        }
    }
    
/*@{@"项目名称":@"product",@"公司名称":@"company",@"公司官网":@"gw_link",@"地区":@"province",@"一句话介绍":@"yewu",@"行业领域":@"hangye1"};*/
    SearchCompanyModel *companyM = [[SearchCompanyModel alloc]init];
    companyM.icon = self.cellValueDic[@"icon"];
    companyM.product = self.cellValueDic[@"product"];
    companyM.company = self.cellValueDic[@"company"];
    companyM.gw_link = self.cellValueDic[@"gw_link"];
    companyM.province = self.cellValueDic[@"province"];
    companyM.yewu = self.cellValueDic[@"yewu"];
    companyM.desc = self.cellValueDic[@"desc"];
    companyM.hangye1 = self.cellValueDic[@"hangye1"];

    FinancialInfoSubmitVC *financialInfoVC = [[FinancialInfoSubmitVC alloc]init];
    financialInfoVC.model = companyM;
    financialInfoVC.isNewProject = YES; //来自创建
    [self.navigationController pushViewController:financialInfoVC animated:YES];
    
}


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


#pragma mark --UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return  self.tableConfigs.count;
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
    
    NSDictionary *row = self.tableConfigs[indexPath.section][indexPath.row];
    NSString *title = row[@"title"];
    if ([title isEqualToString:@"一句话介绍"]) {
        return 86;
    }else if ([title isEqualToString:@"简介"]) {
        return 100;
    }
    return 50;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *sectionArr = self.tableConfigs[section];
    return [sectionArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *row = self.tableConfigs[indexPath.section][indexPath.row];
    NSString *key = row[@"key"];
    NSString *title = row[@"title"];
    NSString *cellClass = row[@"cell"];
    //必填
    NSArray *bitianArr = @[@"项目名称",@"行业领域",@"一句话介绍",@"简介",@"地区"];
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
        [cell.rightImgV setImage:[UIImage imageNamed:@"leftarrow_gray"]];
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
        
    }
    return [[UITableViewCell alloc]init];
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
    if([hmTV.cellKey isEqualToString:@"yewu"]){
        if (textView.text.length > 30) {
            [PublicTool showMsg:@"30字以内"];
            textView.text = [textView.text substringToIndex:30];
        }
        [self.cellValueDic setValue:textView.text forKey:@"yewu"];
        
    }else  if([hmTV.cellKey isEqualToString:@"desc"]){
        if (textView.text.length > 500) {
            [PublicTool showMsg:@"500字以内"];
            textView.text = [textView.text substringToIndex:30];
        }
        [self.cellValueDic setValue:textView.text forKey:@"desc"];
    } else  if([hmTV.cellKey isEqualToString:@"claim_reason"]){
        if (textView.text.length > 50) {
            [PublicTool showMsg:@"50字以内"];
            textView.text = [textView.text substringToIndex:50];
        }
        self.reason = textView.text;
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *row = self.tableConfigs[indexPath.section][indexPath.row];
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
    }
}

#pragma mark  --懒加载--
- (NSArray *)tableConfigs {
    
    if (!_tableConfigs) {
        _tableConfigs = @[
                          @[
                              @{@"title":@"项目名称", @"key":@"product", @"placeholder":@"", @"cell":@"EditCell"},
                              @{@"title":@"公司名称", @"key":@"company", @"placeholder":@"", @"cell":@"EditCell"},
                              @{@"title":@"公司官网", @"key":@"gw_link", @"placeholder":@"", @"cell":@"EditCell"},
                              @{@"title":@"一句话介绍", @"key":@"yewu", @"placeholder":@"例：在线教育平台，30字以内", @"cell":@"TextViewTableViewCell"},
                              @{@"title":@"地区", @"key":@"province", @"cell":@"MyInfoTableViewCell", @"valueTip":@""},
                              @{@"title":@"行业领域", @"key":@"hangye1", @"placeholder":@"", @"cell":@"MyInfoTableViewCell"},
                              @{@"title":@"简介", @"key":@"desc", @"placeholder":@"500字以内", @"cell":@"TextViewTableViewCell"}
                            
                              ]
                          ];
    }
    return _tableConfigs;
}

- (NSDictionary *)keyValueDic{
    if (!_keyValueDic) {
        _keyValueDic = @{@"项目名称":@"product",@"公司名称":@"company",@"公司官网":@"gw_link",@"地区":@"province",@"一句话介绍":@"yewu",@"行业领域":@"hangye1",@"简介":@"desc"};
    }
    return _keyValueDic;
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
        [submitBtn setTitle:@"返回" forState:UIControlStateNormal];
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


@end
