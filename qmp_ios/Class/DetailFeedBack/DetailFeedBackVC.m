//
//  DetailFeedBackVC.m
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DetailFeedBackVC.h"
#import "DetailFeedBackHeadVw.h"

#import "DetailFeedBackTxtCell.h"
#import "DetailFeedBackOptionItemCell.h"
#import "DetailNavigationBar.h"
#import "CompanyDetailRongziModel.h"
#import "EducationExpModel.h"
#import "WorkExprienceModel.h"
#import "TagsFrame.h"
#import "CompanyDetailTagsCell.h"
#import "JigouInvestmentsCaseModel.h"
#import "ManagerItem.h"

#define COLUMN_NUM (SCREENW >= 375 ? 4:3)

@interface DetailFeedBackVC ()<UITableViewDelegate, UITableViewDataSource>
// 4.9.0
@property (nonatomic, strong) UITableView * tableVw;
@property (nonatomic, strong) NSArray *tagArr;
@property (nonatomic, strong) NSMutableArray *selectedTagArr;
@property (nonatomic, strong) UIButton *submitBtn;
// 4.9.0


@property (nonatomic, strong) DetailFeedBackHeadVw * headTableVw;
@property (nonatomic, copy) NSString * nameStr;//顶部显示名字
@property (nonatomic, strong) NSDictionary * allTagToBasicDic;
@property (nonatomic, copy) NSString * inputTxtStr;
@property (nonatomic, strong) UIView * firstHeaderView; //一级标签
@property (nonatomic, strong) NSArray * tagFirst; //一级标签
@property (nonatomic, strong) NSMutableDictionary * tagNextTagDic; //次级tag
@property (nonatomic, strong) TagsFrame * tagFrame;
@property (nonatomic, strong) NSMutableArray * selectedTag;
@property (nonatomic, copy)   NSString * selectedKey; //选中的当前key

@end

@implementation DetailFeedBackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tagFrame = [[TagsFrame alloc]init];
    self.tagFrame.tagsArray = self.tagFirst;
    
    [self.view addSubview:self.tableVw];

    UIButton *finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 47, 44)];
    [finishBtn setTitle:@"提交" forState:UIControlStateNormal];
    [finishBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [finishBtn setTitleColor:COLOR2D343A forState:UIControlStateDisabled];

    [finishBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [finishBtn addTarget:self action:@selector(commitMsg:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:finishBtn];
    self.submitBtn = finishBtn;
    
    @weakify(self);
    [RACObserve(self, self.inputTxtStr) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self judgeMsgNotNull];
    }];
   
    
    switch (self.type) {
        case DetailFeedBackTypeProduct:
            self.title = [NSString stringWithFormat:@"%@·项目反馈",self.companyM.company_basic.product];
            [QMPEvent event:@"pro_feedback_click"];
            break;
        case DetailFeedBackTypeOrganize:
            self.title = [NSString stringWithFormat:@"%@·机构反馈",self.organizeInfo.jigou_name];
            [QMPEvent event:@"jigou_feedback_click"];
            break;
        case DetailFeedBackTypePerson:
            self.title = [NSString stringWithFormat:@"%@·人物反馈",self.personM.name];
            [QMPEvent event:@"person_feedback_click"];
            break;
            
        default:
            break;
    }
    [self.tableVw reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showNavigationBarLine];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableVw.backgroundColor = [UIColor whiteColor];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideNavigationBarLine];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak typeof(self) wkSf = self;
    if (indexPath.section == 0) {        
        return [self dequeTagCell];

    }else if (indexPath.section == 1) {
        DetailFeedBackTxtCell * txtCell = [DetailFeedBackTxtCell initTableViewCell:tableView];
        txtCell.calltxtBack = ^(NSString *txt) {
            wkSf.inputTxtStr = txt;
        };
        txtCell.inputTxtVw.text = self.inputTxtStr;
        return txtCell;
    }else{ }
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"systemNoCell" forIndexPath:indexPath];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSInteger row = self.tagArr.count/COLUMN_NUM+(self.tagArr.count%COLUMN_NUM?1:0);
        return  row*(26+9)+17;
    }
    return 160;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];

    UIView * bgVw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 44)];
    bgVw.backgroundColor = [UIColor whiteColor];
    
    UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, SCREENW - 60, 44)];
    [titleLbl labelWithFontSize:16 textColor:COLOR2D343A];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:@"补充说明(选填)"];
    [attText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:H9COLOR} range:NSMakeRange(4, attText.length - 4)];
    titleLbl.attributedText = attText;
    [bgVw addSubview:titleLbl];
    return bgVw;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;

}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, CGFLOAT_MIN)];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

#pragma mark EVENT--
- (void)handleSelectedTag:(NSString*)tag{
   
    if (self.selectedTag.count == 2) {  //选的是第三级
        self.tagFrame.tagsArray = @[];
    }else if (self.selectedTag.count == 1) {  //选的是第二级
        
        NSString *firstTag = self.selectedTag[0];
        //有三级
        if ([firstTag isEqualToString:@"工作经历"] || [firstTag isEqualToString:@"教育经历"] || [firstTag isEqualToString:@"团队成员"] || [firstTag isEqualToString:@"融资历史"] || [firstTag isEqualToString:@"FA案例"] || [firstTag isEqualToString:@"投资案例"]) {
            if ([tag containsString:@"不全"]) { //选的
                self.tagFrame.tagsArray = @[];
            }else{
                self.selectedKey = [NSString stringWithFormat:@"%@1",firstTag];
                self.tagFrame.tagsArray = self.tagNextTagDic[self.selectedKey];
                if ([firstTag isEqualToString:@"融资历史"]) {
                    for (CompanyDetailRongziModel *rongziM in self.rongziHistory) {
                        if ([rongziM.lunci isEqualToString:tag]) {
                            if ( [PublicTool isNull:rongziM.fa]) {
                                self.tagFrame.tagsArray = @[@"轮次不对",@"交易时间不对",@"交易金额不对",@"投资方不对",@"投资方不全",@"FA未录入"];
                            }
                            break;
                        }
                    }
                }
            }
        }else{ //无三级
            self.tagFrame.tagsArray = @[];
        }
    }else{  //选的是第一级
        self.selectedKey = tag;
        self.tagFrame.tagsArray = self.tagNextTagDic[self.selectedKey];
    }
    [self.selectedTag addObject:tag];
    [self.tableVw reloadData];

}

- (void)cancelBtnClick{
    
    if (self.selectedTag.count == 3) {
        self.tagFrame.tagsArray = [NSArray arrayWithArray:self.tagNextTagDic[self.selectedKey]];
    }else if (self.selectedTag.count == 2) {
        self.tagFrame.tagsArray = self.tagNextTagDic[self.selectedTag[0]];
    }else{
        self.tagFrame.tagsArray = self.tagFirst;
    }
    [self.selectedTag removeLastObject];
    [self.tableVw reloadData];
}

- (void)commitMsg:(UIButton *)btn{
 
    if (![self judgeMsgNotNull]) {
        [PublicTool showMsg:@"请填写必要信息"];
        return;
    }
    
    NSMutableDictionary * mdict = [NSMutableDictionary dictionary];
    NSString *descStr = @"";
    if (self.selectedTagArr.count) {//选项判断
        for (UIButton *tagBtn in self.selectedTagArr) {
            descStr = [NSString stringWithFormat:@"%@|%@",descStr,tagBtn.titleLabel.text];
        }
    }
    if (![PublicTool isNull:self.inputTxtStr]) {
        descStr = [NSString stringWithFormat:@"%@|%@",descStr,self.inputTxtStr];
    }
    [mdict setValue:descStr forKey:@"desc"];

    if (self.type == DetailFeedBackTypePerson) {
        [mdict setValue:self.personM.personId forKey:@"product"];
        [mdict setValue:self.personM.name forKey:@"person"];
        [mdict setValue:@"人物信息" forKey:@"type"];

    }else if (self.type == DetailFeedBackTypeProduct){
        [mdict setValue:self.companyM.company_basic.product forKey:@"product"];
        [mdict setValue:self.companyM.company_basic.company forKey:@"company"];
        [mdict setValue:@"基本信息" forKey:@"type"];

    }else{
        [mdict setValue:self.organizeInfo.jigou_name forKey:@"jgname"];
        [mdict setValue:@"机构头部反馈" forKey:@"type"];

    }
    
    btn.enabled = NO;
    btn.selected = YES;
    __weak typeof(self) wkSf = self;
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"feedback/addFeedback" HTTPBody:mdict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (![PublicTool isNull:resultData[@"msg"]]) {
            [PublicTool showMsg:@"反馈成功"];
            [wkSf popSelfVC];
        }else{
            [PublicTool showMsg:@"反馈失败"];
            btn.enabled = YES;
            btn.selected = NO;
        }
    }];
    
//统计
    switch (self.type) {
        case DetailFeedBackTypeProduct:
            [QMPEvent event:@"feedback_product_sure"];
            break;
        case DetailFeedBackTypeOrganize:
            [QMPEvent event:@"feedback_jigou_sure"];
            break;
        case DetailFeedBackTypePerson:
            [QMPEvent event:@"feedback_person_sure"];
            break;
            
        default:
            break;
    }
}

- (void)popSelfVC{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)judgeMsgNotNull{
    
    if ((self.selectedTagArr.count == 0) && [PublicTool isNull:self.inputTxtStr]) {//选项判断
        self.submitBtn.enabled = NO;
        return NO;
    }
//    if (![PublicTool isNull:self.inputTxtStr]) {
//        return NO;
//    }
    self.submitBtn.enabled = YES;
    return YES;
}

- (DetailFeedBackHeadVw *)headTableVw{
    if (_headTableVw == nil) {
        _headTableVw = [DetailFeedBackHeadVw initLoadViewNibFrame:CGRectMake(0, 0, SCREENW, 80) type:(_type == DetailFeedBackTypePerson)?0:(_type == DetailFeedBackTypeProduct)?1:2];
        _headTableVw.imgUrlStr = self.imgUrlStr;
        _headTableVw.detailNameStr = self.nameStr;
    }
    return _headTableVw;
}
- (UITableView *)tableVw{
    if (_tableVw == nil) {
        CGRect tableFame = CGRectMake(0, 0, SCREENW, SCREENH );
        _tableVw  = [[UITableView alloc] initWithFrame:tableFame style:UITableViewStyleGrouped];
        _tableVw.delegate = self;
        _tableVw.dataSource = self;
        _tableVw.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableVw registerClass:[UITableViewCell class] forCellReuseIdentifier:@"systemNoCell"];
//        _tableVw.tableHeaderView = self.headTableVw;
        UIView * footBgVw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 90)];
        footBgVw.backgroundColor = [UIColor whiteColor];
        _tableVw.tableFooterView = footBgVw;
        _tableVw.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableVw.estimatedRowHeight = 180;
        _tableVw.estimatedSectionFooterHeight = 0;
        _tableVw.estimatedSectionHeaderHeight = 0;

    }
    return _tableVw;
}


- (void)setProductName:(NSString *)productName{
    _productName = productName;
    self.nameStr = _productName;
}
- (void)setCompanyName:(NSString *)companyName{
    _companyName = companyName;
//    self.nameStr = _companyName; //公司详情页反馈
}
- (void)setPersonName:(NSString *)personName{
    _personName = personName;
    self.nameStr = _personName;
}
- (void)setJigouName:(NSString *)jigouName{
    _jigouName = jigouName;
    self.nameStr = _jigouName;
}

// 4.9.0
- (void)tagBtnClick:(UIButton*)tagBtn{
    if (!self.selectedTagArr) {
        self.selectedTagArr = [NSMutableArray array];
    }
    if ([self.selectedTagArr containsObject:tagBtn]) {
        tagBtn.selected = NO;
        tagBtn.layer.borderWidth = 0.5;
        [self.selectedTagArr removeObject:tagBtn];
        [self judgeMsgNotNull];
        return;
    }
    
    tagBtn.selected = YES;
    tagBtn.layer.borderWidth = 0.0;
    [self.selectedTagArr addObject:tagBtn];
    [self judgeMsgNotNull];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

#pragma mark --懒加载--


- (NSArray *)tagFirst{
    
    if (!_tagFirst) {
        
        if (self.type == DetailFeedBackTypePerson) {
            _tagFirst = @[@"人物名片",@"人物画像",@"人物介绍",@"工作经历",@"教育经历"];
            if (self.touziArr.count) {
                _tagFirst = @[@"人物名片",@"人物画像",@"人物介绍",@"工作经历",@"教育经历",@"投资案例"];
            }
        }else if (self.type == DetailFeedBackTypeProduct) {
            _tagFirst = @[@"项目名片",@"项目画像",@"项目介绍",@"团队成员",@"融资历史",@"相似项目"];
        }else{
            if (self.faArr.count) {
                _tagFirst = @[@"机构名片",@"机构介绍",@"团队成员",@"FA案例",@"投资案例"];
            }else{
                _tagFirst = @[@"机构名片",@"机构介绍",@"团队成员",@"投资案例"];
            }
        }
    }
    
    return _tagFirst;
}

-(NSMutableDictionary *)tagNextTagDic{
    
    if (!_tagNextTagDic) {
        
        NSMutableArray *rongziTag = [NSMutableArray arrayWithObjects:@"融资轮次不全", nil];
        if (self.rongziHistory.count) {
            for (CompanyDetailRongziModel *rongziM in self.rongziHistory) {
                [rongziTag addObject:rongziM.jieduan];
            }
        }
        
        NSMutableArray *workTag = [NSMutableArray arrayWithObjects:@"工作经历不全", nil];
        if (self.workArr.count) {
            for (ZhiWeiModel *workM in self.workArr) {
                if (workM.name || workM.product) {
                    [workTag addObject:workM.name ? workM.name : (workM.product?:@"")];
                }
            }
        }
        
        NSMutableArray *schoolTag = [NSMutableArray arrayWithObjects:@"教育经历不全", nil];
        if (self.educationArr.count) {
            for (EducationExpModel *schoolM in self.educationArr) {
                [schoolTag addObject:schoolM.school];
            }
        }
        
        NSMutableArray *faTag = [NSMutableArray arrayWithObjects:@"FA案例不全", nil];
        if (self.faArr.count < 16) {
            for (JigouInvestmentsCaseModel *caseM in self.faArr) {
                [faTag addObject:caseM.product];
            }
        }
        
        NSMutableArray *touziTag = [NSMutableArray arrayWithObjects:@"投资案例不全", nil];
        if (self.touziArr.count < 16) {
            for (JigouInvestmentsCaseModel *caseM in self.touziArr) {
                [touziTag addObject:caseM.product];
            }
        }
        
        NSMutableArray *teamTag = [NSMutableArray arrayWithObjects:@"团队成员不全", nil];
        if (self.teamArr.count < 16) {
            for (ManagerItem *manager in self.teamArr) {
                [teamTag addObject:manager.name];
            }
        }
        NSDictionary *dic = @{@"项目名片":@[@"一句话介绍不对",@"邮箱不对",@"地址不对"],
                              @"项目画像":@[@"项目画像不对"],
                              @"项目介绍":@[@"项目介绍不对",@"项目介绍不全"],
                              @"融资历史":rongziTag,
                              @"相似项目":@[@"相似项目不对",@"相似项目不全"],
                              @"团队成员":teamTag,
                              @"机构名片":@[@"联系电话不对",@"邮箱不对",@"地址不对"],
                              @"机构介绍":@[@"机构介绍不对",@"机构介绍不全"],
                              @"FA案例":faTag,
                              @"投资案例":touziTag,
                              @"人物名片":@[@"人物头像不对",@"人物角色不对",@"单位不对",@"职位不对"],
                              @"人物画像":@[@"人物画像不对"],
                              @"人物介绍":@[@"人物介绍不对",@"人物介绍不全"],
                              @"工作经历":workTag,
                              @"教育经历":schoolTag,
                              @"团队成员1":@[@"成员头像不对",@"成员信息不对",@"成员信息不全"],
                              @"融资历史1":@[@"轮次不对",@"交易时间不对",@"交易金额不对",@"投资方不对",@"投资方不全",@"FA不对",@"FA未录入"],
                              @"FA案例1":@[@"案例不对",@"服务时间不对",@"服务轮次不对",@"服务金额不对"],
                              @"投资案例1":@[@"案例不对",@"投资轮次不对",@"投资时间不对",@"投资轮次不对",@"投资金额不对"],
                              @"工作经历1":@[@"工作单位不对",@"工作时间不对",@"工作职位不对",@"在职/离职状态不对"],
                              @"教育经历1":@[@"就读学校不对",@"就读时间不对",@"就读专业不对"],
                              };
        _tagNextTagDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    }
    return _tagNextTagDic;
}

- (NSDictionary *)allTagToBasicDic{
    if (_allTagToBasicDic == nil) {
        if (self.type == DetailFeedBackTypePerson) {
            
            _allTagToBasicDic = @{@"人物名片":@"人物信息",@"人物介绍":@"个人简介",@"人物画像":@"人物画像",@"工作经历":@"工作经历",@"教育经历":@"教育经历"};
        }else if (self.type == DetailFeedBackTypeProduct){
            _allTagToBasicDic = @{@"项目名片":@"基本信息", @"项目画像":@"标签", @"项目介绍":@"基本信息", @"融资历史":@"融资历史", @"团队成员":@"公司团队", @"相似项目":@"相似项目"};
        }else{
            _allTagToBasicDic = @{@"机构名片":@"机构联系方式",@"机构介绍":@"机构头部反馈",@"FA案例":@"FA服务案例",@"投资案例":@"投资案例",@"团队成员":@"投资团队"};
        }
    }
    return _allTagToBasicDic;
}


- (NSMutableArray *)selectedTag{
    if (!_selectedTag) {
        _selectedTag = [NSMutableArray array];
    }
    return _selectedTag;
}

-(UIView *)firstHeaderView{
    if (!_firstHeaderView) {
        
        _firstHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 44)];
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, SCREENW - 34 - 50, 44)];
        [titleLab labelWithFontSize:16 textColor:COLOR2D343A];
        [_firstHeaderView addSubview:titleLab];
        titleLab.numberOfLines = 0;
        titleLab.tag = 1000;
        
        UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 17 - 50, 0, 50, 44)];
        [cancelBtn setImage:[UIImage imageNamed:@"feedback_cancel"] forState:UIControlStateNormal];
        [cancelBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_firstHeaderView addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.tag = 1001;
        cancelBtn.hidden = YES;
        
    }
    return _firstHeaderView;
}

// 4.9.0
-(NSArray *)tagArr{
    if (!_tagArr) {
        if (self.type == DetailFeedBackTypePerson) {
            if ([self.personM.role containsObject:@"investor"]) {
                _tagArr = @[@"基本信息不对",@"人物头像不对",@"人物介绍不对",@"投资案例不对",@"工作经历不对",@"工作经历不全",@"工作职位不对",@"工作单位不对",@"在/离职状态不对",@"教育经历不对",@"其它"];
            }else{
                _tagArr = @[@"基本信息不对",@"人物头像不对",@"人物介绍不对",@"工作经历不对",@"工作经历不全",@"工作职位不对",@"工作单位不对",@"在/离职状态不对",@"教育经历不对",@"其他"];
            }
        }else if (self.type == DetailFeedBackTypeProduct){
            _tagArr = @[@"基本信息不对",@"项目介绍不对",@"项目画像不对",@"公司团队不全",@"成员信息不对",@"融资历史不全",@"融资历史不对",@"融资时间不对",@"融资金额不对",@"相似项目不对",@"其它"];
            
        }else{
            _tagArr = @[@"基本信息不对",@"机构介绍不对",@"投资团队不全",@"成员信息不对",@"投资案例不全",@"投资案例不对",@"FA案例不对",@"FA案例不全",@"其它"];
        }
    }
    return _tagArr;
}

- (UITableViewCell*)dequeTagCell{
    UITableViewCell *cell = [self.tableVw dequeueReusableCellWithIdentifier:@"TagCellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TagCellID"];
        CGFloat left = 16;
        CGFloat top = 15;
        CGFloat width = (SCREENW-left*2-27)/COLUMN_NUM;
        CGFloat height = 26;
        CGFloat edge = 9;
        for (int i=0; i<self.tagArr.count; i++) {
            UIButton *tagBtn = [[UIButton alloc]initWithFrame:CGRectMake(left+(i%COLUMN_NUM)*(width+edge), top+(i/COLUMN_NUM)*(height+edge), width, height)];
            CGFloat titleWidth = [PublicTool widthOfString:self.tagArr[i] height:CGFLOAT_MAX fontSize:12];
            if (width<titleWidth) {
                tagBtn.titleLabel.font = [UIFont systemFontOfSize:10];
            }else{
                tagBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            }
            [tagBtn setTitleColor:H3COLOR forState:UIControlStateNormal];
            [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [tagBtn setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor] andSize:tagBtn.size] forState:UIControlStateNormal];
            [tagBtn setBackgroundImage:[UIImage imageFromColor:BLUE_BG_COLOR andSize:tagBtn.size] forState:UIControlStateSelected];
            tagBtn.layer.cornerRadius = 2;
            tagBtn.layer.masksToBounds = YES;
            tagBtn.layer.borderColor = H999999.CGColor;
            tagBtn.layer.borderWidth = 0.5;
            [tagBtn setTitle:self.tagArr[i] forState:UIControlStateNormal];
            [cell addSubview:tagBtn];
            [tagBtn addTarget:self action:@selector(tagBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
