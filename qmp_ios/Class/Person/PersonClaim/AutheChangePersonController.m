//
//  UnautherizedPersonController.m
//  qmp_ios
//
//  Created by QMP on 2018/3/30.
//  Copyright © 2018年 Molly. All rights reserved.
// 未认证的库里的人物

#import "AutheChangePersonController.h"
#import "PersonModel.h"
#import "CompanyBasicInfoTableViewCell.h"
#import "InvestorTzCaseCell.h"
#import "JobExpriencesCell.h"
#import "NewsTableViewCell.h"
#import "CompanyDetailTagsCell.h"
#import "EducationCell.h"
#import "CompanyInfoView.h"
#import "TagsFrame.h"
#import "GetSizeWithText.h"
#import "CustomAlertView.h"
#import "NoInfoCell.h"
#import "PersonHeaderView.h"
#import "EditExprienceController.h"
#import "SearchComController.h"
#import "SearchCompanyModel.h"
#import "SearchProRegisterModel.h"
#import "ZhuTouJieduanController.h"
#import "TouziLingyuController.h"
#import "EditInfoViewController.h"
#import "BasicInfoChangeController.h"

@interface AutheChangePersonController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    BOOL _isEditing;
}

@property(nonatomic,strong)NSMutableArray *secTitleArr;
@property(nonatomic,strong)PersonModel *person;
@property(nonatomic,strong)NSMutableDictionary *personBasicInfo; //基本数据信息

@property (nonatomic, strong)TagsFrame *tzlyFrame;//投资领域的frame
@property (nonatomic, strong)TagsFrame *jtjdFrame;//主投阶段的frame
@property (nonatomic, strong)UIButton *editBarButton;//主投阶段的frame
@property (nonatomic, strong)UIView *showAlertMessageBgVw;

@end

@implementation AutheChangePersonController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //更新基本信息
    if (self.personBasicInfo && self.person) {
        for (NSString *key in self.personBasicInfo.allKeys) {
            NSString *value = self.personBasicInfo[key];
            if (![PublicTool isNull:value]) {
                if ([key isEqualToString:@"nickname"]) {
                    [self.person setValue:value forKey:@"name"];
                }else if ([key isEqualToString:@"zhiwei"]) {
                    [self.person setValue:value forKey:@"position"];
                }else if ([key isEqualToString:@"headimgurl"]) {
                    [self.person setValue:value forKey:@"icon"];
                }else{
                    [self.person setValue:value forKey:key];
                }
            }
            
        }
        [(PersonHeaderView*)self.tableView.tableHeaderView setPerson:self.person];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑个人信息";
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
    
    [self rightBarbutton];

    if (![PublicTool isNull:self.persionId]) {
        [self showHUD];
        [self requestData];
        
    }else{
        self.person = self.cachePersonInfo;
        [self extractBasicInfo];
        [self setUI];
    }
   
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUI{
    
    if (!self.tableView) {
        [self.view addSubview:self.showAlertMessageBgVw];
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.showAlertMessageBgVw.height, SCREENW, SCREENH-kScreenTopHeight-self.showAlertMessageBgVw.height) style:UITableViewStyleGrouped];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview:self.tableView];
        [self.tableView registerClass:[CompanyBasicInfoTableViewCell class] forCellReuseIdentifier:@"jianjieCellID"];
        [self.tableView registerNib:[UINib nibWithNibName:@"InvestorTzCaseCell" bundle:nil] forCellReuseIdentifier:@"InvestorTzCaseCellID"];
        [self.tableView registerClass:[NewsTableViewCell class] forCellReuseIdentifier:@"NewsTableViewCellID"];
        [self.tableView registerClass:[EducationCell class] forCellReuseIdentifier:@"JobExpriencesCellID"];
        [self.tableView registerClass:[EducationCell class] forCellReuseIdentifier:@"EducationCellID"];

        [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"headerView"];
        [self.tableView registerClass:[NoInfoCell class] forCellReuseIdentifier:@"NoInfoCellID"];
        
        //下一步
        //footerView
        UIView *tableFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 146)];
        UIButton *nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(19, 30, SCREENW-38, 40)];
        nextBtn.layer.masksToBounds = YES;
        nextBtn.layer.cornerRadius = 20;
        nextBtn.backgroundColor = BLUE_BG_COLOR;
        [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nextBtn setTitle:@"保存" forState:UIControlStateNormal];
        nextBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [tableFooter addSubview:nextBtn];
        [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"遇到问题？点我进行人工服务"];
        NSRange strRange = {0,[title length]};
        [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
        [title addAttribute:NSForegroundColorAttributeName value:H9COLOR range:strRange];
        UIButton *kefuBtn = [[UIButton alloc]initWithFrame:CGRectMake(19, 102, SCREENW-38, 40)];
        kefuBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [kefuBtn setAttributedTitle:title forState:UIControlStateNormal];
        [kefuBtn addTarget:self action:@selector(kefuBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [tableFooter addSubview:kefuBtn];
        
        self.tableView.tableFooterView = tableFooter;
        
        
        
    }
    
    PersonHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"PersonHeaderView" owner:nil options:nil].lastObject;
    headerView.height = 222;
    headerView.person = self.person;
    headerView.editBtn.hidden = YES;
    [headerView.editBtn addTarget:self action:@selector(editBasicInfo:) forControlEvents:UIControlEventTouchUpInside];
    headerView.noseeContactBtn.hidden = YES;
    headerView.friendShipBtn.hidden = YES;
    
    self.tableView.tableHeaderView = headerView;
    [self.tableView reloadData];
    
    
    if (!self.person) {
        return;
    }
    
    PersonHeaderView *headerV = (PersonHeaderView*)self.tableView.tableHeaderView;
    headerV.contactNoSeeView.hidden = YES;
    headerV.contactInfoView.hidden = YES;
    headerV.height = 112;
    
    self.tableView.tableHeaderView = headerV;
}

- (void)rightBarbutton{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitle:@"跳过" forState:UIControlStateNormal];
    [btn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn addTarget:self action:@selector(popToOtherVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc]initWithCustomView:[UIView new]],[[UIBarButtonItem alloc]initWithCustomView:[UIView new]]];
}

- (void)nextBtnClick{
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.person.personId,@"personid", nil];

    //基本信息
    NSArray *propertyKey;
    if (!_isInvestor) {
        propertyKey = @[@"nickname",@"zhiwei",@"company",@"desc"];
    }else{
        propertyKey = @[@"nickname",@"zhiwei",@"company",@"desc",@"jieduan",@"lingyu"];
    }
    
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self.person class], &count);
    NSMutableArray *propertyNames = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        [propertyNames addObject:propertyName];
    }
    free(properties);
    
    for (NSString *key in propertyKey) {

        if ([key isEqualToString:@"nickname"]) {
            [paramDic setValue:[PublicTool isNull:self.person.name]?@"":self.person.name forKey:key];
            
        }else if ([key isEqualToString:@"zhiwei"]) {
            [paramDic setValue:[PublicTool isNull:self.person.position]?@"":self.person.position forKey:key];
            
        }else if ([key isEqualToString:@"desc"]) {
            [paramDic setValue:[PublicTool isNull:self.person.jieshao]?@"":self.person.jieshao forKey:key];
            
        }else  if ([propertyNames containsObject:key]) {
            if ([[self.person valueForKey:key] isKindOfClass:[NSString class]] && ![PublicTool isNull:[self.person valueForKey:key]]){
                [paramDic setValue:[self.person valueForKey:key] forKey:key];
            }
        }
        
    }
    
    [paramDic setValue:self.person.icon forKey:@"headimgurl"];
    
    //工作经历
    NSMutableArray *workArr = [NSMutableArray array];
    for (ZhiWeiModel *workExperience in self.person.work_exp) {
        NSDictionary *dic = @{@"id":[PublicTool isNull:workExperience.zhiweiId] ? @"":workExperience.zhiweiId,@"company":[PublicTool isNull:workExperience.name] ? @"":workExperience.name,@"zhiwei":workExperience.zhiwu,@"start_time":[PublicTool isNull:workExperience.start_time]?@"":workExperience.start_time,@"end_time":[PublicTool isNull:workExperience.end_time]?@"":workExperience.end_time,@"desc":[PublicTool isNull:workExperience.desc]?@"":workExperience.desc,@"type":[PublicTool isNull:workExperience.type] ? @"company":workExperience.type};
        [workArr addObject:dic];
    }
    
    NSData *workData = [NSJSONSerialization dataWithJSONObject:workArr options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonArr = [[NSString alloc]initWithData:workData encoding:NSUTF8StringEncoding];
    [paramDic setValue:jsonArr forKey:@"user_work_experience"];
    
    //教育经历
    NSMutableArray *schoolArr = [NSMutableArray array];
    for (EducationExpModel *schoolExperience in self.person.edu_exp) {
        NSDictionary *dic = @{@"school":schoolExperience.school,@"zhuanye":schoolExperience.major,@"xueli":schoolExperience.xueli,@"start_time":[PublicTool isNull:schoolExperience.start_time]?@"":schoolExperience.start_time,@"end_time":[PublicTool isNull:schoolExperience.end_time]?@"":schoolExperience.end_time,@"desc":[PublicTool isNull:schoolExperience.desc]?@"":schoolExperience.desc,@"id":[PublicTool isNull:schoolExperience.educationId]?@"":schoolExperience.educationId};
        [schoolArr addObject:dic];
    }
    
    NSData *schoolData = [NSJSONSerialization dataWithJSONObject:schoolArr options:NSJSONWritingPrettyPrinted error:nil];
    [paramDic setValue:[[NSString alloc]initWithData:schoolData encoding:NSUTF8StringEncoding] forKey:@"user_education"];
    
    //投资案例
    if (_isInvestor) {
        NSMutableArray *tzanliArr = [NSMutableArray array];
        for (PersonTouziModel *company in self.person.tzanli1) {
            NSDictionary *dic = @{@"product":company.product,@"tzLunci":[PublicTool isNull:company.tzlunci]?@"":company.tzlunci,@"hangye1":![PublicTool isNull:company.hangye] ?company.hangye:@"",@"icon":[PublicTool isNull:company.icon]?@"":company.icon};
            [tzanliArr addObject:dic];
        }
        NSData *tzData = [NSJSONSerialization dataWithJSONObject:tzanliArr options:NSJSONWritingPrettyPrinted error:nil];
        [paramDic setValue:[[NSString alloc]initWithData:tzData encoding:NSUTF8StringEncoding] forKey:@"tzanli"];
    }

    [paramDic setValue:@"1" forKey:@"op_flag"];
    [paramDic setValue:self.claim_id?:@"" forKey:@"claim_id"];

    [paramDic setValue:self.person.personId?:@"" forKey:@"personid"];
    
    [PublicTool showHudWithView:KEYWindow];
    
    [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:@"personOperate/preEditPersonInfo" HTTPBody:paramDic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
       
        [PublicTool dismissHud:KEYWindow];
        
        [self popToOtherVC];
    }];
    
}



- (void)popToOtherVC{
    //返回到
    //从个人名片进入的
    for (BaseViewController *childVC in self.navigationController.childViewControllers) {
        if ([childVC isKindOfClass:NSClassFromString(@"BecomeOfficialPersonVC")]) {
            
            [WechatUserInfo shared].claim_type = @"1";
            NSInteger index = [self.navigationController.childViewControllers indexOfObject:childVC];
            
            [self.navigationController popToViewController:self.navigationController.childViewControllers[index-1] animated:YES];
            return;
        }
    }

    //从个人名片进入的
    for (BaseViewController *childVC in self.navigationController.childViewControllers) {
        if ([childVC isKindOfClass:NSClassFromString(@"UnauthPeresonPageController")]) {
            
            [WechatUserInfo shared].claim_type = @"1";
            NSInteger index = [self.navigationController.childViewControllers indexOfObject:childVC];
            
            [self.navigationController popToViewController:self.navigationController.childViewControllers[index] animated:YES];
            
            return;
        }
    }
    
    //从人物详情页进入的
    for (BaseViewController *childVC in self.navigationController.childViewControllers) {
        if ([childVC isKindOfClass:NSClassFromString(@"PersonDetailsController")]) {
            
            [WechatUserInfo shared].claim_type = @"1";
            NSInteger index = [self.navigationController.childViewControllers indexOfObject:childVC];
            [self.navigationController popToViewController:self.navigationController.childViewControllers[index] animated:YES];
            
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)kefuBtnClick{
    
    [PublicTool contactKefu:kBePersonText reply:@"您好，请问您有什么问题？"];
}


//修改头部数据
- (void)editBasicInfo:(UIButton*)btn{
    
    BasicInfoChangeController *editBasicIntoVC = [[BasicInfoChangeController alloc]init];
    editBasicIntoVC.person = self.person;
    editBasicIntoVC.personInfo = self.personBasicInfo;
    [self.navigationController pushViewController:editBasicIntoVC animated:YES];
    
}

- (void)changeInfoWithTitle:(NSString*)sectionTitle{
    
    if([sectionTitle isEqualToString:@"个人简介"]){
        
        [self updatePersonJieshao];
        
    }else if([sectionTitle isEqualToString:@"投资领域"]){
        [self updateTouZiLingyu];
    }else if([sectionTitle isEqualToString:@"主投阶段"]){
        [self updateZhuToujieduan];
        
    }else if([sectionTitle isEqualToString:@"投资案例"]){
        [self addTouziAnli];
        
    }else if([sectionTitle isEqualToString:@"工作经历"]){
        [self addWorkExperience];
        
    }else if([sectionTitle isEqualToString:@"教育经历"]){
        [self addEducationExperience];
    }
}

- (void)updatePersonJieshao{
    EditInfoViewController *editInfo = [[EditInfoViewController alloc]init];
    editInfo.key = @"个人简介";
    editInfo.value = self.person.jieshao;
    __weak typeof(self) weakSelf = self;
    editInfo.sureBtnClick = ^(NSString *value) {
        weakSelf.person.jieshao = value;
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:editInfo animated:YES];
}

- (void)updateTouZiLingyu{
    TouziLingyuController *lingyuVC = [[TouziLingyuController alloc]init];
    NSString *lingyu = (NSString*)self.person.lingyu;
    lingyuVC.originalLingyu = lingyu;
    __weak typeof(self) weakSelf = self;
    lingyuVC.selectedLingyu = ^(NSString *lingyuStr) {
        weakSelf.person.lingyu = lingyuStr;
        _tzlyFrame = [weakSelf getHeightFromArr:[(NSString*)weakSelf.person.lingyu componentsSeparatedByString:@"|"]];
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:lingyuVC animated:YES];
}

- (void)updateZhuToujieduan{
    ZhuTouJieduanController *jieduanVC = [[ZhuTouJieduanController alloc]init];
    jieduanVC.originalJieduan = (NSString*)self.person.jieduan;
    __weak typeof(self) weakSelf = self;
    jieduanVC.selectedJieDuan = ^(NSString *jieduanStr) {
        weakSelf.person.jieduan = jieduanStr;
        _jtjdFrame = [weakSelf getHeightFromArr:[(NSString*)weakSelf.person.jieduan componentsSeparatedByString:@"|"]];
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:jieduanVC animated:YES];
}

- (void)touziLiDeleteBtnClick:(UIButton*)btn{
    
    NSInteger row = btn.tag - 5000;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.person.tzanli1];
    PersonTouziModel *touzi = self.person.tzanli1[row];
    [arr removeObject:touzi];
    NSMutableString *touziStr = [NSMutableString string];
   
    for (PersonTouziModel *touzM in arr) {
        [touziStr appendFormat:@"%@|",touzM.product];
    }
    self.person.tzanli = touziStr;
   
    self.person.tzanli1 = (NSArray*)arr;
    [self.tableView reloadData];
    QMPLog(@"删除投资案例------%ld",row);
}



- (void)addBtnClick:(UIButton*)btn{
    
    switch (btn.tag - 1000) {
        case 0:{
            [self updatePersonJieshao];
        }
            break;
        case 1:{
            [self updateTouZiLingyu];
        }
            break;
        case 2:{
            QMPLog(@"主投阶段");
            [self updateZhuToujieduan];
        }
            break;
        default:
            break;
    }
    
    NSInteger index = btn.tag - 1000;
    if (index == 4) { //添加工作经历
        [self addWorkExperience];
        
    }else if(index == 5){ //添加教育经历
        [self addEducationExperience];
    }else if(index == 3){ //投资案例
        [self addTouziAnli];
    }
}

- (void)addEducationExperience{
    
    EditExprienceController *editVC = [[EditExprienceController alloc]init];
    editVC.fromView = FromView_PersonDetail;
    editVC.isJob = NO;
    __weak typeof(self) weakSelf = self;
    editVC.saveInfoSuccess = ^(id newExperienceM) {
        NSMutableArray *schoolArr = [NSMutableArray arrayWithArray:weakSelf.person.edu_exp];
        [schoolArr addObject:newExperienceM];
        weakSelf.person.edu_exp = (NSArray*)schoolArr;
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:editVC animated:YES];
    
}

- (void)addWorkExperience{
    
    EditExprienceController *editVC = [[EditExprienceController alloc]init];
    editVC.fromView = FromView_PersonDetail;
    editVC.isJob = YES;
    __weak typeof(self) weakSelf = self;
    editVC.saveInfoSuccess = ^(id newExperienceM) {
        NSMutableArray *zhiweiArr = [NSMutableArray arrayWithArray:weakSelf.person.work_exp];
        [zhiweiArr addObject:newExperienceM];
        weakSelf.person.work_exp = (NSArray*)zhiweiArr;
        [weakSelf.tableView reloadData];    };
    [self.navigationController pushViewController:editVC animated:YES];
}

#warning --投资案例咋存
- (void)addTouziAnli{
    
    SearchComController *searchComVC = [[SearchComController alloc]init];
    searchComVC.isCompany = YES;
    searchComVC.isTouziCase = YES;
    __weak typeof(self) weakSelf = self;
    
    searchComVC.didSelected = ^(id selectedObject) {
        
        PersonTouziModel *model = [[PersonTouziModel alloc]init];
        if ([selectedObject isKindOfClass:[SearchCompanyModel class]]) {
            
            SearchCompanyModel *company = selectedObject;
            model.product = company.product;
            model.icon = company.icon;
            model.yewu = company.yewu;
            model.hangye = company.hangye1;
            model.tzlunci = company.tzLunci;
            
        }else if([selectedObject isKindOfClass:[NSString class]]){
            model.product = selectedObject;
            
        }else if([selectedObject isKindOfClass:[SearchProRegisterModel class]]){
            SearchProRegisterModel *registM = selectedObject;
            model.product = registM.company;
        }
        if (![PublicTool isNull:model.product]) {
            NSMutableString *touziStr = [NSMutableString string];
            for (PersonTouziModel *touzM in weakSelf.person.tzanli1) {
                [touziStr appendFormat:@"%@|",touzM.product];
            }
            [touziStr appendString:model.product];
            weakSelf.person.tzanli = touziStr;
            NSMutableArray *tzanliArr = [NSMutableArray arrayWithArray:self.person.tzanli1];
            [tzanliArr insertObject:model atIndex:0];
            weakSelf.person.tzanli1 = (NSArray*)tzanliArr;
            [weakSelf.tableView reloadData];
            
        }
        
    };
    [self.navigationController pushViewController:searchComVC animated:YES];
}

- (void)clickCloseTarget{
    [self.showAlertMessageBgVw removeFromSuperview];
    self.tableView.top = 0;
    self.tableView.height = SCREENH - kScreenTopHeight;
    [self.tableView reloadData];
}

#pragma mark --数据请求

- (BOOL)requestData{
    
    if ([super requestData]) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.persionId,@"person_id", nil];
        
        [AppNetRequest personDetailWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [PublicTool dismissHud:KEYWindow];
            
            [self hideHUD];
            
            if (resultData && [resultData[@"list"] isKindOfClass:[NSDictionary class]]) {
                PersonModel *person = [[PersonModel alloc]initWithDictionary:resultData[@"list"] error:nil];
                person.personId = self.persionId;
                _isInvestor = [person.role containsObject:@"investor"]?YES:NO;
                for (ZhiWeiModel *zhiwei in person.work_exp) {
                    zhiwei.old_type = zhiwei.type; //记录工作经历 旧的type
                    zhiwei.name = zhiwei.company ? : zhiwei.product;
                }
                self.person = person;
                if (self.cachePersonInfo) {
                    self.person.name = self.cachePersonInfo.name;
                    self.person.wechat = self.cachePersonInfo.wechat;
                    self.person.email = self.cachePersonInfo.email;
                    self.person.phone = self.cachePersonInfo.phone;
                }
                [self extractBasicInfo]; //抽取基本信息
                
            }
            
            [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"person/personInvestInfo" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                
                if (resultData && [resultData[@"list"] isKindOfClass:[NSDictionary class]]) {
                    
                    NSMutableArray *arr = [NSMutableArray array];
                    for (NSDictionary *dic in resultData[@"list"][@"tzanli"]) {
                        [arr addObject:[[PersonTouziModel alloc]initWithDictionary:dic error:nil]];
                    }
                    if (self.person) {
                        self.person.tzanli1 = [NSArray arrayWithArray:arr];
                        self.person.lingyu = resultData[@"list"][@"lingyu"];
                        self.person.jieduan = resultData[@"list"][@"jieduan"];
                        _tzlyFrame = [self getHeightFromArr:[(NSString*)self.person.lingyu componentsSeparatedByString:@"|"]];
                        _jtjdFrame = [self getHeightFromArr:[(NSString*)self.person.jieduan componentsSeparatedByString:@"|"]];
                        
                    }
                }
                [self setUI];

            }];
        }];
    }
    
    
   
    
    return YES;
}

- (void)extractBasicInfo{
    
    self.personBasicInfo = [NSMutableDictionary dictionary];
    
    [self.personBasicInfo setValue:self.person.personId?:@"" forKey:@"personId"];
    [self.personBasicInfo setValue:self.person.name forKey:@"nickname"];
    [self.personBasicInfo setValue:self.person.company forKey:@"company"];
    [self.personBasicInfo setValue:self.person.position forKey:@"zhiwei"];
    [self.personBasicInfo setValue:self.person.icon forKey:@"headimgurl"];
    
}



- (TagsFrame *)getHeightFromArr:(NSArray *)tagsArr{
    
    TagsFrame *frame = [[TagsFrame alloc] init];
    if (tagsArr.count == 0 || (tagsArr.count == 1 &&[tagsArr[0] length] == 0)) {
        frame.areasArray = @[];
        return frame;
    }
    
    if (tagsArr.count>0) {
        
        frame.areasArray = tagsArr;
        
    }
    return frame;
}

- (void)feedbackDetail:(UIButton*)sender{
    
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        NSString *sectionTitle;
        if (sender.tag != 10011) {
            sectionTitle = [(UILabel*)[sender.superview viewWithTag:9000] text];
            
        }
        
        [self changeInfoWithTitle:sectionTitle];

    }
}


#pragma mark --UITableViewDelegate--

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.secTitleArr.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:{
            return 1;
        }
            break;
        case 1:
        {
            return _tzlyFrame.areasArray.count?1:(_isInvestor?1:0);
        }
            break;
        case 2:{
            return _jtjdFrame.areasArray.count?1:(_isInvestor?1:0);
            
        }
            break;
        case 3:{
            if ( _isInvestor) {
                return self.person.tzanli1.count ? self.person.tzanli1.count:1;
            }else{
                return 0;
            }

        }
            break;
        case 4:{
            
            return self.person.work_exp.count?self.person.work_exp.count:1;
        }
            break;
        case 5:{
            
            return self.person.edu_exp.count?self.person.edu_exp.count:1;
        }
            break;

        default:
            return 0;
            break;
    }
    
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
            return 55;
            break;
        case 1:
        {
            if (!_isInvestor) {
                return 0;
            }
            return _tzlyFrame.areasArray.count?55:(_isInvestor?55:0.1);
        }
            break;
        case 2:{
            if (!_isInvestor) {
                return 0;
            }
            return _jtjdFrame.areasArray.count?55:(_isInvestor?55:0.1);
            
        }
            break;
        case 3:{
            if (!_isInvestor) {
                return 0;
            }
            return self.person.tzanli1.count ? 55:(_isInvestor?55:0.1);
        }
            break;
        case 4:{
            
            return 55;
        }
            break;
        case 5:{
            
            return 55;
        }
            break;
    
        default:
            return 0.1;
            break;
    }
    
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    
    UIView *headV = [headerView viewWithTag:900];
    if (!headV) {
        headV = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREENW, 45)];
        headV.tag = 900;
        [headerView addSubview:headV];
        
        //    if (dataArr.count > 0) {
        headV.backgroundColor = [UIColor whiteColor];
        
        CGFloat top = 16;
        UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(17, top, 2, 14)];
        lineV.backgroundColor = BLUE_TITLE_COLOR;
        [headV addSubview:lineV];
        
        UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(25, 12, 100, 21)];
        infoLbl.font = [UIFont systemFontOfSize:15.f];
        infoLbl.text = self.secTitleArr[section];
        infoLbl.textColor = HTColorFromRGB(0x1d1d1d);
        infoLbl.tag = 9000;
        infoLbl.textAlignment = NSTextAlignmentLeft;
        [headV addSubview:infoLbl];
        
        UIButton *feedBackBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 52 - 17, 0,52, 45)];
        [feedBackBtn setTitle:@"反馈" forState:UIControlStateNormal];
        feedBackBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [feedBackBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        feedBackBtn.tag = 9001;
        feedBackBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [feedBackBtn addTarget:self action:@selector(feedbackDetail:) forControlEvents:UIControlEventTouchUpInside];
        [headV addSubview:feedBackBtn];
        
        //底线
        UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0,44, headV.width, 1)];
        bottomLine.backgroundColor = LIST_LINE_COLOR;
        [headV addSubview:bottomLine];
    }
    
    UIButton *feedBackBtn = [headV viewWithTag:9001];
    feedBackBtn.hidden = NO;
    
    NSString *feedbackTitle = @"";
   
    switch (section) {
        case 0: //简介
            feedbackTitle = [PublicTool isNull:self.person.jieshao]?@"":@"修改";
            break;
        case 1: //投资领域
            feedbackTitle = [PublicTool isNull:(NSString*)self.person.lingyu]?@"":@"修改";
            break;
        case 2: //投资阶段
            feedbackTitle = [PublicTool isNull:(NSString*)self.person.jieduan]?@"":@"修改";
            break;
        case 3: //案例
            feedbackTitle = self.person.tzanli1.count == 0?@"":@"添加";
            break;
        case 4: //工作
            feedbackTitle = self.person.work_exp.count == 0?@"":@"添加";
            break;
        case 5: //教育
            feedbackTitle = self.person.edu_exp.count == 0?@"":@"添加";
            break;
        default:
            break;
    }
   
    
    [feedBackBtn setTitle:feedbackTitle forState:UIControlStateNormal];
    
    
    UILabel *label = [headV viewWithTag:9000];
    label.text = self.secTitleArr[section];
    
    switch (section) {
        case 0:
            return headerView;
            break;
        case 1:
        {
            return _tzlyFrame.areasArray.count?headerView:(_isInvestor?headerView:[[UIView alloc]init]);
        }
            break;
        case 2:{
            return _jtjdFrame.areasArray.count?headerView:(_isInvestor?headerView:[[UIView alloc]init]);
            
        }
            break;
        case 3:{
            
            return self.person.tzanli1.count ? headerView:(_isInvestor?headerView:[[UIView alloc]init]);
        }
            break;
        case 4:{
            
            return  headerView;
        }
            break;
        case 5:{
            
            return  headerView;
        }
            break;
        default:
            return [[UIView alloc]init];
            break;
    }
    
    return [[UIView alloc]init];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
   
    return 0.1;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0: {//简介
            NSString *dec =  _person.jieshao;
            if ([PublicTool isNull:dec]) {
                return 64;
            }
            UIFont *jianjieFont = [UIFont systemFontOfSize:14.f];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            [style setLineBreakMode:NSLineBreakByWordWrapping];
            [style setLineSpacing:6.f];
            NSDictionary *attribute = @{NSFontAttributeName:jianjieFont,NSParagraphStyleAttributeName:style};
            CGFloat jianjieW = SCREENW - 17 * 2;
            CGFloat jianjieH = ceil([GetSizeWithText calculateSize:dec withDict:attribute withWidth:jianjieW].height);
            
            return jianjieH + 35;
        }
            break;
            
        case 1:{
            return _tzlyFrame.areasArray.count ? _tzlyFrame.tagsHeight+10:64;
        }
            break;
        case 2:{
            return _jtjdFrame.areasArray.count ? _jtjdFrame.tagsHeight+10:64;
        }
            break;
        case 3:{
            
            return self.person.tzanli1.count ? 78:74;
        }
            break;
        case 4:{
            return self.person.work_exp.count ? 96:64;

        }
            break;
        case 5:{
            
            return self.person.edu_exp.count ? 96:64;
        }
            break;
    
        default:
            return 0;
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0: {//简介
            if([PublicTool isNull:self.person.jieshao]){
                NoInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoInfoCellID" forIndexPath:indexPath];
                cell.isMy = YES;
                cell.btnText = @"个人简介";
                cell.addBtn.tag = 1000;
                [cell.addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            CompanyBasicInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"jianjieCellID" forIndexPath:indexPath];
            [cell initDataWithKey:@"描述" withValue:self.person.jieshao];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.infoLbl.userInteractionEnabled = YES;

            return  cell;
        }
            break;
            
        case 1:
        {
            if(_tzlyFrame.areasArray.count == 0){
                NoInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoInfoCellID" forIndexPath:indexPath];
                cell.isMy = YES;
                cell.btnText = @"投资领域";
                cell.addBtn.tag = 1001;
                [cell.addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            //投资领域
            CompanyDetailTagsCell *cell = [CompanyDetailTagsCell cellWithTableView:tableView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            
            [cell refreshPersonUI:_tzlyFrame.areasArray andTagsFrame:_tzlyFrame];
    
            return cell;
            
        }
            break;
        case 2:{
            if(_jtjdFrame.areasArray.count == 0){
                NoInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoInfoCellID" forIndexPath:indexPath];
                cell.isMy = YES;
                cell.btnText = @"主投阶段";
                cell.addBtn.tag = 1002;
                [cell.addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            //主投阶段
            CompanyDetailTagsCell *cell = [CompanyDetailTagsCell cellWithTableView:tableView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            
            [cell refreshPersonUI:_jtjdFrame.areasArray andTagsFrame:_jtjdFrame];
            
            return cell;
        }
            break;
        case 3:{
            if(self.person.tzanli1.count == 0 && _isInvestor){
                NoInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoInfoCellID" forIndexPath:indexPath];
                cell.isMy = YES;
                cell.btnText = @"投资案例";
                cell.addBtn.tag = 1000 + 3;
                [cell.addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            InvestorTzCaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvestorTzCaseCellID" forIndexPath:indexPath];
            cell.tzCaseM = self.person.tzanli1[indexPath.row];
            cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
            cell.deleteBtn.hidden = NO;
            cell.deleteBtn.tag = indexPath.row + 5000;
            [cell.deleteBtn addTarget:self action:@selector(touziLiDeleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        case 4:{
            
            if(self.person.work_exp.count == 0){
                NoInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoInfoCellID" forIndexPath:indexPath];
                cell.isMy = YES;
                cell.btnText = @"工作经历";
                cell.addBtn.tag = 1004;
                [cell.addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            EducationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JobExpriencesCellID" forIndexPath:indexPath];
            cell.exprienceM = self.person.work_exp[indexPath.row];
            cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
            cell.editBtn.hidden = NO;
            cell.editBtn.userInteractionEnabled = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        case 5:{
            if(self.person.edu_exp.count == 0){
                NoInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoInfoCellID" forIndexPath:indexPath];
                cell.isMy = YES;
                cell.btnText = @"教育经历";
                cell.addBtn.tag = 1005;
                [cell.addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            EducationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EducationCellID" forIndexPath:indexPath];
            cell.educationM = self.person.edu_exp[indexPath.row];
            cell.degreeColor = RANDOM_COLORARR[indexPath.row%6];
            cell.editBtn.hidden = NO;
            cell.editBtn.userInteractionEnabled = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;

        default:
            return 0;
            break;
    }
    return 0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.section) {
        
        case 4:{  //工作经历
            if (self.person.work_exp.count == 0 || [cell isKindOfClass:[NoInfoCell class]]) {
                return;
            }
            ZhiWeiModel *experience = self.person.work_exp[indexPath.row];
            EditExprienceController *editInfoVC = [[EditExprienceController alloc]init];
            editInfoVC.isJob = YES;
            editInfoVC.fromView = FromView_PersonDetail;
            editInfoVC.experienceM = experience;
            __weak typeof(self) weakSelf = self;
            editInfoVC.saveInfoSuccess = ^(id newExperienceM) {
                
                if ([weakSelf.person.work_exp containsObject:newExperienceM]) {
                    [newExperienceM setValue:[newExperienceM valueForKey:@"name"] forKey:@"product"];
                    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.person.work_exp];
                    [arr replaceObjectAtIndex:[arr indexOfObject:newExperienceM] withObject:newExperienceM];
                    weakSelf.person.work_exp = (NSArray*)arr;
                    [weakSelf.tableView reloadData];
                }
            };
            editInfoVC.delInfoSuccess = ^(id newExperienceM) {
                
                if ([weakSelf.person.work_exp containsObject:newExperienceM]) {
                    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.person.work_exp];
                    [arr removeObject:newExperienceM];
                    weakSelf.person.work_exp = (NSArray*)arr;
                    [weakSelf.tableView reloadData];
                }
            };
            [self.navigationController pushViewController:editInfoVC animated:YES];
        }
            break;
            
        case 5:{ //教育经历
            if (self.person.edu_exp.count == 0 || [cell isKindOfClass:[NoInfoCell class]]) {
                return;
            }
            EducationExpModel *experience = self.person.edu_exp[indexPath.row];
            EditExprienceController *editInfoVC = [[EditExprienceController alloc]init];
            editInfoVC.isJob = NO;
            editInfoVC.fromView = FromView_PersonDetail;
            editInfoVC.experienceM = experience;
            __weak typeof(self) weakSelf = self;
            editInfoVC.saveInfoSuccess = ^(id newExperienceM) {
                
                if ([weakSelf.person.edu_exp containsObject:newExperienceM]) {
                    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.person.edu_exp];
                    [arr replaceObjectAtIndex:[arr indexOfObject:newExperienceM] withObject:newExperienceM];
                    weakSelf.person.edu_exp = (NSArray*)arr;
                    [weakSelf.tableView reloadData];
                }
            };
            editInfoVC.delInfoSuccess = ^(id newExperienceM) {
                
                if ([weakSelf.person.edu_exp containsObject:newExperienceM]) {
                    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.person.edu_exp];
                    [arr removeObject:newExperienceM];
                    weakSelf.person.edu_exp = (NSArray*)arr;
                    [weakSelf.tableView reloadData];
                }
            };
            [self.navigationController pushViewController:editInfoVC animated:YES];
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark --懒加载

- (NSMutableArray *)secTitleArr{
    if (!_secTitleArr) {
        _secTitleArr = [NSMutableArray arrayWithObjects:@"个人简介",@"投资领域",@"主投阶段",@"投资案例",@"工作经历",@"教育经历",nil];
    }
    return _secTitleArr;
}

- (UIView *)showAlertMessageBgVw{
    if (_showAlertMessageBgVw == nil) {
        _showAlertMessageBgVw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 35)];
        _showAlertMessageBgVw.backgroundColor = [UIColor colorWithRed:213/255.0 green:232/255.0 blue:255/255.0 alpha:1/1.0];
        
        UILabel * msgLbl = [[UILabel alloc] initWithFrame:CGRectMake(17, 4,SCREENW-17-53, 28)];
        msgLbl.textColor =  [UIColor colorWithRed:13/255.0 green:125/255.0 blue:255/255.0 alpha:1/1.0];
        msgLbl.text = @"已提交认证！可提前编辑个人信息，待审核通过后生效！";
        msgLbl.font = [UIFont systemFontOfSize:12];
        [_showAlertMessageBgVw addSubview:msgLbl];
        
        UIButton * clickCancelBtn= [UIButton buttonWithType:UIButtonTypeCustom];
        clickCancelBtn.frame = CGRectMake(SCREENW - 40 - 10, 0, 40, 35);
        [clickCancelBtn setImage:[UIImage imageNamed:@"my_close"] forState:UIControlStateNormal];
        [clickCancelBtn addTarget:self action:@selector(clickCloseTarget) forControlEvents:UIControlEventTouchUpInside];
        [_showAlertMessageBgVw addSubview:clickCancelBtn];
    }
    return _showAlertMessageBgVw;
}

@end
