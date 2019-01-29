//
//  PersonDetailsController.m
//  qmp_ios
//
//  Created by QMP on 2018/6/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonDetailsController.h"
#import "NewsWebViewController.h"
#import "PersonModel.h"
#import "InvestorTzCaseCell.h"
#import "JobExpriencesCell.h"
#import "NewsTableViewCell.h"
#import "EducationCell.h"
#import "PersonBusinessRoleCell.h"
#import "CompanyInfoView.h"
#import "CustomAlertView.h"
#import "NoInfoCell.h"
#import "LrdOutputView.h"
#import "GetProductsFromTagsViewController.h"
#import "AuthenticationController.h"
#import "SchoolPersonController.h"
#import "TagsFrame.h"
#import "CompanyTagsCell.h"
#import "ManagerAlertView.h"
#import "WinExperienceCell.h"
#import "EditWinExpeController.h"
#import "MyInfoTableViewCell.h"
#import "AlertActionView.h"
#import "PersonHeadView.h"
#import "EditBasicInfoController.h"
#import "ExperienceModel.h"
#import "NoCommentCell.h"
#import "PersonDetailViewModel.h"
#import "PersonRoleModel.h"
#import "CommonIntroduceCell.h"
#import "DetailTagsCell.h"
#import "PersonTzPreferenceCell.h"
#import "CommonTableVwSecHeadVw.h"
#import "OrganizeInvestCaseTableCell.h"
#import "DetailNavigationBar.h"
#import "NoCommontInfoCell.h"
#import "DetailFeedBackVC.h"
#import "DynamicRelateCell.h"
#import "PersonInvestCaseTableViewCell.h"
#import "BecomeOfficialPersonVC.h"
#import "HYNoticeView.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "RegisterInfoViewController.h"
#import "ProductContactsController.h"


@interface PersonDetailsController ()<UITableViewDelegate,UITableViewDataSource,LrdOutputViewDelegate,ManagerAlertDelegate,UIScrollViewDelegate, SPPageMenuDelegate>
{
    CGFloat originalOffSetY;
    UIView *_bottomView;
    UIButton *_editBtn;

    UIButton *_renlingBtn;
    UIButton *_chatBtn;//交换联系方式
    UIButton *_attentionBtn;//关注
    UIButton *_feedbackBtn;//反馈
    UIButton *_kefuBtn;//客服

    BOOL _isEditing;
    UIImage *_printscreenImage;
    LrdOutputView *_outputView;
    ManagerAlertView *_alertView;
    BOOL _showWinExperience;
}

@property(nonatomic,copy)NSString *shortOrLongFlag;
@property(nonatomic,strong)NSMutableArray *secTitleArr;
@property(nonatomic,strong)NSMutableArray *originalSecTitleArr;
 @property(nonatomic,strong)NSArray *moreOptionsArr;
@property (nonatomic, strong)UIButton *editBarButton;//
@property (nonatomic, strong) PersonHeadView * personHeadVw;
@property(nonatomic,strong)DetailNavigationBar *nabar;
@property (nonatomic, strong) PersonDetailViewModel *viewModel;
@property (nonatomic, assign) BOOL fromEditBasicInfo;
@property (nonatomic, assign)BOOL isInvestor; //此人是投资者
@end

@implementation PersonDetailsController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [QMPEvent endEvent:@"person_pageTimer"];
    [IQKeyboardManager sharedManager].enable = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //更新基本信息
    if (self.viewModel.personBasicInfo && self.viewModel.person && self.fromEditBasicInfo) {
        [self requestData];
    }
    [QMPEvent beginEvent:@"person_pageTimer"];
    self.tableView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0];
    
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.isMy) { //允许编辑
        _isEditing = YES;
        [USER_DEFAULTS setBool:YES forKey:isEditedMyInfo];
        [USER_DEFAULTS synchronize];
    }
    [self initTableView];

    [self requestData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(claimFinish) name:@"claimFinish" object:nil];
    [QMPEvent event:@"person_detail_enter"];
}

-(void)dealloc{
    NSLog(@"__%s__", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshData{
 
    PersonHeadView *headerView = [[PersonHeadView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 165+15 + kScreenTopHeight)];
    headerView.iconLabColor = self.nameLabColor;
    [headerView.editBtn addTarget:self action:@selector(editBasicInfo:) forControlEvents:UIControlEventTouchUpInside];
    _personHeadVw = headerView;
    headerView.editBtn.hidden = !_isEditing;
    headerView.iconImgV.userInteractionEnabled = YES;
    [headerView.iconImgV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPersonIcon)]];
    _personHeadVw = headerView;
    _personHeadVw.isMy = self.isMy;
    _personHeadVw.viewModel = self.viewModel;
    _personHeadVw.person = self.viewModel.person;
    self.tableView.tableHeaderView = headerView;
    
    _bottomView.hidden = NO;
    
    if (self.isMy) {
        UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.1)];
        footerV.backgroundColor = [UIColor whiteColor];
        footerV.height = kScreenBottomHeight;
        self.tableView.tableFooterView = footerV;
        [self.tableView reloadData];
        return;
    }
    
    [self refreshButtonsLayout];

}

- (void)refreshFooter{
    if (self.tableView.tableFooterView) {
        return;
    }
    //如果section count过少，为了不显示出底部图片，用tableFooter
    if (self.tableView.contentSize.height-kScreenTopHeight < (DetailBgImageHeight)) {
        
        UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.1)];
        footerV.backgroundColor = [UIColor whiteColor];
        CGFloat height  = (DetailBgImageHeight - self.tableView.contentSize.height+kScreenTopHeight);
        height = height<kScreenBottomHeight*2 ? kScreenBottomHeight*2:height;
        footerV.height = height;
        self.tableView.tableFooterView = footerV;
        
    }else{
        
        UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.1)];
        footerV.backgroundColor = [UIColor whiteColor];
        footerV.height = kScreenBottomHeight;
        self.tableView.tableFooterView = footerV;
    }
}


- (void)initTableView{
 
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kScreenTopHeight, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped
                      ];
    self.tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    if (self.isMy) {
        self.tableView.mj_header = self.mjHeader;
        self.mjHeader.gifView.hidden = YES;
    }
    [self.tableView registerNib:[UINib nibWithNibName:@"InvestorTzCaseCell" bundle:nil] forCellReuseIdentifier:@"InvestorTzCaseCellID"];
    [self.tableView registerNib:[UINib nibWithNibName:@"JobExpriencesCell" bundle:nil] forCellReuseIdentifier:@"JobExpriencesCellID"];
    [self.tableView registerNib:[UINib nibWithNibName:@"JobExpriencesCell" bundle:nil] forCellReuseIdentifier:@"EduExpriencesCellID"];
    [self.tableView registerNib:[UINib nibWithNibName:@"JobExpriencesCell" bundle:nil] forCellReuseIdentifier:@"WinExpriencesCellID"];
    [self.tableView registerClass:[NewsTableViewCell class] forCellReuseIdentifier:@"NewsTableViewCellID"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"headerView"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NoCommentCell" bundle:nil] forCellReuseIdentifier:@"noCommentCellID"];
    
    self.viewModel.scrollView = self.tableView;
    
    self.tableView.estimatedRowHeight = 90;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH - kScreenBottomHeight, SCREENW, kScreenBottomHeight)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bottomView];
    _bottomView.hidden = YES;

    if(!self.isMy){
        
        CGFloat btnHeight = 49;
        
        CGFloat leftWidth = SCREENW*23/73;
        CGFloat width = (SCREENW - leftWidth)/2.0;
        
        UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, leftWidth, btnHeight)];
        leftView.backgroundColor = [UIColor whiteColor];
        [_bottomView addSubview:leftView];
        
        _kefuBtn = [[UIButton alloc]initWithFrame:CGRectMake(8, 0,(leftWidth - 16)/2.0, btnHeight)];
        [_kefuBtn setTitle:@"客服" forState:UIControlStateNormal];
        [_kefuBtn setImage:[UIImage imageNamed:@"detail_kefu_icon"] forState:UIControlStateNormal];
        [_kefuBtn setTitleColor:H6COLOR forState:UIControlStateNormal];
        _kefuBtn.titleLabel.font = [UIFont systemFontOfSize:9];
        [_kefuBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:0];
        [_kefuBtn addTarget:self action:@selector(kefuBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:_kefuBtn];
        
        _feedbackBtn = [[UIButton alloc]initWithFrame:CGRectMake(_kefuBtn.right, 0, (leftWidth - 16)/2.0, btnHeight)];
        [_feedbackBtn setTitle:@"反馈" forState:UIControlStateNormal];
        [_feedbackBtn setImage:[UIImage imageNamed:@"detail_feedback_icon"] forState:UIControlStateNormal];
        [_feedbackBtn setTitleColor:H6COLOR forState:UIControlStateNormal];
        _feedbackBtn.titleLabel.font = [UIFont systemFontOfSize:9];
        _feedbackBtn.backgroundColor = [UIColor whiteColor];
        [_feedbackBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:0];
        [_feedbackBtn addTarget:self action:@selector(jumpDetailFeedBackVC) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:_feedbackBtn];
        
        //交换联系方式
        _chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftWidth, 0, width, btnHeight)];
        _chatBtn.backgroundColor = HTColorFromRGB(0x2292F9);
        [_chatBtn setTitle:@"立即联系" forState:UIControlStateNormal];
        [_chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if (@available(iOS 8.2, *)) {
            _chatBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        } else {
            _chatBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        }
        [_chatBtn addTarget:self action:@selector(chatBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_chatBtn];
        
        
        _attentionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _attentionBtn.frame = CGRectMake(_chatBtn.right, 0, SCREENW-_chatBtn.right, btnHeight);
        _attentionBtn.backgroundColor = BLUE_TITLE_COLOR;
        [_attentionBtn buttonWithTitle:@"关注" image:@"workflow_add" titleColor:[UIColor whiteColor] fontSize:15];
        [_attentionBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:8];
        [_attentionBtn setTitle:@"已关注" forState:UIControlStateSelected];
        if (@available(iOS 8.2, *)) {
            _attentionBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        } else {
            _attentionBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        }        
        [_attentionBtn setImage:[UIImage imageNamed:@"workflow_have"] forState:UIControlStateSelected];
        _attentionBtn.rac_command = self.viewModel.updateAttentStatusCommand;
        [_bottomView addSubview:_attentionBtn];
        
        //线
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, leftWidth, 0.5)];
        topLine.backgroundColor = LINE_COLOR;
        topLine.tag = 1000;
        [_bottomView addSubview:topLine];
    }
    
    __weak typeof(self) weakSelf = self;
    if (self.isMy) {
        DetailNavigationBar *topBar = [DetailNavigationBar detailTopBarWithShareClick:^{
            [weakSelf sharePersonWithCard:YES];
        }];
        [self.view addSubview:topBar];
        _nabar = topBar;
    }else{
        DetailNavigationBar *topBar = [DetailNavigationBar detailTopBarWithRightMenuArr:self.moreOptionsArr shareEvent:^{
            [weakSelf sharePersonWithCard:NO];
        } moreClick:^{
            [weakSelf pressRightButtonItem:nil];
        }];
        [self.view addSubview:topBar];
        _nabar = topBar;
    }
   
    
    PersonHeadView *headerView = [[PersonHeadView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 150)];
    self.tableView.tableHeaderView = headerView;
    [self.tableView reloadData];
    
}

- (void)tapPersonIcon{
    if ([PublicTool isNull:self.viewModel.person.icon]) {
        return;
    }
    
    MJPhoto *mjphoto = [[MJPhoto alloc] init];
    mjphoto.srcImageView = _personHeadVw.iconImgV; // 来源于哪个UIImageView
    mjphoto.srcView = _personHeadVw.iconImgV;
    NSString *photo = self.viewModel.person.icon;
    if ([photo isKindOfClass:[NSString class]]) {
        mjphoto.url = [NSURL URLWithString:photo]; // 图片路径
    }else if ([photo isKindOfClass:[NSDictionary class]]) {
        mjphoto.url = [NSURL URLWithString:[(NSDictionary*)photo valueForKey:@"url"]]; // 图片路径
    }

    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.photos = @[mjphoto]; // 设置所有的图片
    browser.barStyle = [UIApplication sharedApplication].statusBarStyle;
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    [browser show];
}

- (void)refreshButtonsLayout{
    
    if (!self.viewModel.person) {
        return;
    }
    
    if (self.isMy) {
        return;
    }
    _editBtn.hidden = YES;
    
    if (!self.tableView) {
        return;
    }
    //0、非认领用户 1、是好友关系 2、用户添加了人物好友，已申请 3、人物添加了用户， 同意添加 4、不是好友  5、非认证 交换中
    BOOL canClaim = NO;
    if(self.viewModel.person.claim_type.integerValue == 2){
        canClaim = NO;
    }else if ((self.viewModel.person.claim_type.integerValue == 0||self.viewModel.person.claim_type.integerValue == 3) && ([WechatUserInfo shared].claim_type.integerValue == 0 || [WechatUserInfo shared].claim_type.integerValue == 3)) {
        
        canClaim = YES;
        [self.personHeadVw.editBtn setTitle:@"认领" forState:UIControlStateNormal];
        [self.personHeadVw.editBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        
        self.personHeadVw.editBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
        self.personHeadVw.editBtn.layer.borderWidth = 0.5;
        self.personHeadVw.editBtn.layer.cornerRadius = 2;
        self.personHeadVw.editBtn.clipsToBounds = NO;

        self.personHeadVw.editBtn.hidden = NO;
    }
    //客服、反馈、私信、关注、
//    [self changeBottomBtnFrame:@[@[_feedbackBtn], @[_chatBtn,_attentionBtn]]];
    
    
    [self refreshBottomBtn];
    
    if (canClaim && self.fromClaimReq) { //从认证过来，只显示认证(如果可认证的话)
        //不显示 底部认领
        _renlingBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW, kShortBottomHeight)];
        [_renlingBtn setTitle:@"认证为ta" forState:UIControlStateNormal];
        [_renlingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _renlingBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _renlingBtn.backgroundColor = BLUE_BG_COLOR;
        
        [_renlingBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:8];
        [_renlingBtn addTarget:self action:@selector(renlingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (!_renlingBtn.superview) {
            [_bottomView addSubview:_renlingBtn];
        }
        [_bottomView bringSubviewToFront:_renlingBtn];
    }
}


- (void)refreshBottomBtn{
    if (self.isMy) {
        return;
    }
    _attentionBtn.selected = self.viewModel.status_Info.focus_status == 1 ? YES:NO;
}



- (void)renlingBtnClick:(UIButton*)btn{
    
    AuthenticationController *claimPerson = [[AuthenticationController alloc]init];
    claimPerson.role = [self.viewModel.person.role containsObject:@"investor"] ? PersonRole_Investor:PersonRole_Creator;
    claimPerson.person = self.viewModel.person;
    [self.navigationController pushViewController:claimPerson animated:YES];
    
}

- (void)claimFinish{
    
    self.viewModel.person.claim_type = @"1";
    [self refreshButtonsLayout];
}

#pragma mark --Event--
- (void)chatBtnClick{
    if ([[WechatUserInfo shared].person_id isEqualToString:self.persionId]) {
        [PublicTool showMsg:@"您不能联系自己"];
        return;
    }
    if ([WechatUserInfo shared].claim_type.integerValue == 2){
        if (self.viewModel.person.claim_type.integerValue == 2) { //去私信
            [[AppPageSkipTool shared] appPageSkipToChatView:[NSString stringWithFormat:@"%@",self.viewModel.person.usercode]];
            return ;
            
        }else{ //对方未入驻，直接委托联系
            //委托状态
            if (self.viewModel.person.entrust_state.integerValue == 1) {
                [self requestContactLeftCount];
            }else if(self.viewModel.person.entrust_state.integerValue == 2){ //委托成功
                ProductContactsController *contactVC = [[ProductContactsController alloc]init];
                [self.navigationController pushViewController:contactVC animated:YES];
            }else if(self.viewModel.person.entrust_state.integerValue == 3){  //今日已委托
                [PublicTool alertActionWithTitle:@"提示" message:@"今日已帮您委托联系该用户，请耐心等待短信通知" btnTitle:@"知道了" action:nil];
            }
        }
        
    }else{
        [PublicTool userisCliamed];
    }
    
    [QMPEvent event:@"person_chat_click"];
   
}

- (void)requestContactLeftCount{
    
    //请求剩余次数
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"f/getUserAuthCount" HTTPBody:@{} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData) {
            
            NSString *leftCount = resultData[@"left_entrust_count"];
            NSString *message;
            BOOL haveChance = leftCount.integerValue > 0;
            
            if (!leftCount || leftCount.intValue == 0) {
                message = @"快速联系该用户，试试委托联系(今日还剩0次机会)";
            }else{
                message = [NSString stringWithFormat:@"快速联系该用户，试试委托联系(今日还剩%@次机会)",leftCount];
            }
            
            if (haveChance) {
                [PublicTool alertActionWithTitle:@"提示" message:message leftTitle:@"取消" rightTitle:@"委托联系" leftAction:^{
                    
                } rightAction:^{
                    [self contactInfo];
                }];
            }else{
                [PublicTool alertActionWithTitle:@"提示" message:message leftTitle:@"知道了" rightTitle:@"委托联系" leftActionClick:^{
                    
                } rightActionClick:^{
                    
                } leftEnable:YES rightEnable:NO];
            }
            
        }else{
            
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
}

- (void)contactInfo{
    if ([PublicTool isNull:self.persionId]) {
        return;
    }
    [PublicTool showHudWithView:KEYWindow];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Entrust/getPersonContact" HTTPBody:@{@"person_id":self.persionId} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        [PublicTool dismissHud:KEYWindow];

        if (resultData && resultData[@"left_count"]) {
            self.viewModel.person.entrust_state = @(3);
            [PublicTool alertActionWithTitle:@"委托成功" message:@"委托结果稍后通过短信通知您，您也可以在[我的][委托联系]中查看委托结果" btnTitle:@"我知道了" action:nil];
            
        }else if(resultData[@"msg"]){
            [PublicTool showMsg:resultData[@"msg"]];
        }

    }];
}

- (void)sharePersonWithCard:(BOOL)cardShare{
    
    NSString *name = [PublicTool isNull:self.viewModel.person.name] ? @"-":self.viewModel.person.name;
    
    if (self.viewModel.person.ename.length && ![self.viewModel.person.name containsString:@"("] && ![self.viewModel.person.name containsString:@"（"]) {
        name = [NSString stringWithFormat:@"%@(%@)",self.viewModel.person.name,self.viewModel.person.ename];
    }
    
    ZhiWeiModel *zhiwei;
    NSString *com;
    NSString *zhiwu;
    if (self.viewModel.person.work_exp.count) {
        zhiwei = self.viewModel.person.work_exp[0];
        com = zhiwei.name;
        zhiwu = zhiwei.zhiwu;
    }
    
    NSString *descrip = [NSString stringWithFormat:@"%@·%@",com,zhiwu];
    NSString *timeSessionStr = [NSString stringWithFormat:@"%@",name];
    NSString *timeLineStr = [NSString stringWithFormat:@"%@-%@",com,zhiwu];
    if (!cardShare) {
        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"share/addUserShareLog" HTTPBody:@{@"project_id":self.viewModel.person.ticket,@"project_type":@"person"} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            if (![PublicTool isNull:resultData[@"url_short"]]) {
                NSString *copyString = [NSString stringWithFormat:@"%@:%@%@来自@企名片",name,descrip,resultData[@"url_short"]];
                [[[ShareTo alloc]init] shareWithDetailStr:descrip sessionTitle:timeSessionStr timelineTitle:timeLineStr copyString:copyString aIcon:self.viewModel.person.icon aOpenUrl:resultData[@"url_short"] onViewController:self shareResult:^(BOOL shareSuccess) {
                    
                }];
            }
        }];
    }else{

        [[[ShareTo alloc]init]shareToWechat:descrip aTitleSessionStr:timeSessionStr aTitleTimelineStr:timeLineStr aIcon:self.viewModel.person.icon aOpenUrl:self.viewModel.person.user_url shareResult:^(BOOL shareSuccess) {
            
        }];
        
    }
   
   
    [QMPEvent event:@"person_shareClick"];
    
}

- (void)screenLongCut{
    
    self.shortOrLongFlag = @"long";
    _printscreenImage = [PublicTool  getLongCaptureImage:self.tableView];
    [self.shareTool shareDetailImage:_printscreenImage];
}

/**
 *  rightButtonItem
 */
- (void)pressRightButtonItem:(id)sender{
    
    CGFloat x = SCREENW - 13;
    CGFloat y = kScreenTopHeight + 10;
    
    _outputView = [[LrdOutputView alloc] initWithDataArray:_moreOptionsArr origin:CGPointMake(x, y) viewLeftBottomLocation:CGPointMake(x, y) width:125 height:44 screenH:SCREENH direction:kLrdOutputViewDirectionRight ofAction:@"moreOptions" hasImg:YES];
    
    _outputView.delegate = self;
    [_outputView pop];
    
}



#pragma mark - LrdOutputViewDelegate 代理方法
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.view endEditing:YES];
    switch (indexPath.row) {
        case 0:{
            [self screenLongCut];
            break;
        }
//        case 1:{
//            [self kefuBtnClick];
//        }
//            break;

        case 1:{
            //回首页
            self.tabBarController.selectedIndex = 0;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}
- (void)jumpDetailFeedBackVC{
    DetailFeedBackVC *detailVC = [[DetailFeedBackVC alloc]init];
    detailVC.type = DetailFeedBackTypePerson;
    detailVC.personM = self.viewModel.person;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)changeBottomBtnFrame:(NSArray *)showBtnArr{
    NSArray * noColorBtnArr = [showBtnArr firstObject];
    NSArray * colorBtnArr = [showBtnArr lastObject];
    //1 50% //2 50% //3 70
    CGFloat colorTotalW = SCREENW/4.0*3;
   
    for (int i = 0; i < noColorBtnArr.count; i ++) {
        UIButton * btn = noColorBtnArr[i];
        btn.frame = CGRectMake(i * (SCREENW - colorTotalW)/noColorBtnArr.count, 0, (SCREENW - colorTotalW)/noColorBtnArr.count, 49);
    }
    [_bottomView viewWithTag:1000].width = (SCREENW - colorTotalW)/noColorBtnArr.count;
    for (int indx = 0; indx < colorBtnArr.count; indx ++) {
        UIButton * colorBtn = colorBtnArr[indx];
        colorBtn.frame = CGRectMake((SCREENW - colorTotalW) + indx * (colorTotalW / colorBtnArr.count), 0, colorTotalW / colorBtnArr.count, 49);
    }
    for (UIButton *btn in noColorBtnArr) {
        [btn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:0];
    }
    
}

// 导航编辑按钮
- (void)editBtnClick:(UIButton*)editBtn{
    
    if ([editBtn.titleLabel.text containsString:@"编辑"]) {
        [self.secTitleArr removeObject:@"人物新闻"];
        [self.secTitleArr removeObject:@"商业关系"];
        [self.secTitleArr removeObject:@"服务案例"];
        [editBtn setTitle:@"完成" forState:UIControlStateNormal];
        self.tableView.mj_header = nil;
    }else{
        self.secTitleArr = [NSMutableArray arrayWithArray:self.originalSecTitleArr];
        [editBtn setTitle:@"编辑个人主页" forState:UIControlStateNormal];
        self.tableView.mj_header = self.mjHeader;
    }
    
    _isEditing = !_isEditing;
    PersonHeadView *headerV = (PersonHeadView*)self.personHeadVw;
    headerV.editBtn.hidden = !_isEditing;
    [self.tableView reloadData];
}

//修改头部数据
- (void)editBasicInfo:(UIButton*)btn{
    if ([btn.currentTitle containsString:@"认领"]) {
        [self renlingBtnClick:btn];
        return;
    }
    EditBasicInfoController *editBasicIntoVC = [[EditBasicInfoController alloc]init];
    editBasicIntoVC.person = self.viewModel.person;
    editBasicIntoVC.personInfo = self.viewModel.personBasicInfo;
    [self.navigationController pushViewController:editBasicIntoVC animated:YES];
    self.fromEditBasicInfo = YES;
    
}

- (void)kefuBtnClick{
    
    NSString *text = [NSString stringWithFormat:@"%@正在浏览人物【%@】时，进入客服",[WechatUserInfo shared].nickname,self.viewModel.person.name];
    [PublicTool contactKefuMSG:text reply:kDefaultWel delMsg:YES];
    
    [QMPEvent event:@"person_kefu_click"];
}

#pragma mark --数据请求
- (BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    
    @weakify(self);
    [self.viewModel.requestFinishSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);

        if (!self.viewModel.person) {
            return;
        }
        
        self.fromEditBasicInfo = NO;
        
        if ([self.viewModel.person.role containsObject:@"investor"]) {
            self.isInvestor = YES;
        }
        [self setRightSectionTitles];
        if (!self.viewModel.person) {
            [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            return;
        }
        [self refreshData];
       
        [self refreshBottomBtn];
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
        [self refreshFooter];
        
        if ( ![USER_DEFAULTS boolForKey:@"CHAT_INFO"] && !self.isMy) {
            HYNoticeView *noticeTop = [[HYNoticeView alloc] initWithFrame:CGRectMake(_chatBtn.left+_chatBtn.width/2.0-80, _bottomView.top-40, 160, 40) text:@"私信内可交换联系方式" bgColor:H3COLOR textColor:[UIColor whiteColor] position:HYNoticeViewPositionBottom];
            [noticeTop showType:HYNoticeTypeTestTop inView:self.view after:0 duration:0.2 options:UIViewAnimationOptionCurveEaseInOut];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [HYNoticeView hideNoticeInView:self.view];
            });
            [USER_DEFAULTS setValue:@(YES) forKey:@"CHAT_INFO"];
            [USER_DEFAULTS synchronize];
        }
//
//        if ( ![USER_DEFAULTS boolForKey:@"CHAT_CONTACT"] && !self.isMy) {
//
//            HYNoticeView *contactTop = [[HYNoticeView alloc] initWithFrame:CGRectMake(_kefuBtn.left+_kefuBtn.width/2.0-30, _bottomView.top-40, 120, 40) text:@"客服中可委托联系" bgColor:H3COLOR textColor:[UIColor whiteColor] position:HYNoticeViewPositionBottomLeft];
//            [contactTop showType:HYNoticeTypeTestTop inView:self.view after:0 duration:0.2 options:UIViewAnimationOptionCurveEaseInOut];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [HYNoticeView hideNoticeInView:self.view];
//                if ( ![USER_DEFAULTS boolForKey:@"CHAT_INFO"] && !self.isMy) {
//                    HYNoticeView *noticeTop = [[HYNoticeView alloc] initWithFrame:CGRectMake(_chatBtn.left+_chatBtn.width/2.0-80, _bottomView.top-40, 160, 40) text:@"私信内可交换联系方式" bgColor:H3COLOR textColor:[UIColor whiteColor] position:HYNoticeViewPositionBottom];
//                    [noticeTop showType:HYNoticeTypeTestTop inView:self.view after:0 duration:0.2 options:UIViewAnimationOptionCurveEaseInOut];
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [HYNoticeView hideNoticeInView:self.view];
//                    });
//                    [USER_DEFAULTS setValue:@(YES) forKey:@"CHAT_INFO"];
//                    [USER_DEFAULTS synchronize];
//                }
//            });
//            [USER_DEFAULTS setValue:@(YES) forKey:@"CHAT_CONTACT"];
//            [USER_DEFAULTS synchronize];
//        }
    
    }];
    return YES;
}

- (void)setRightSectionTitles{
    
    [self.secTitleArr removeAllObjects];
    
    //用户分享
    [self.secTitleArr addObject:@"用户分享"];
    
    //自我介绍
    [self.secTitleArr addObject:@"自我介绍"];


    //投资
    if (self.isMy) {
        if (_isInvestor) {
            [self.secTitleArr addObject:@"投资领域"];
            [self.secTitleArr addObject:@"主投阶段"];
        }
    }else{
        
        if (self.viewModel.tzlyFrame.tagsArray.count) {
            [self.secTitleArr addObject:@"投资领域"];
        }
        if(self.viewModel.jtjdFrame.tagsArray.count){
            [self.secTitleArr addObject:@"主投阶段"];
        }
    }
    
    //投资案例
    if (self.viewModel.person.tzanli1.count || (self.isMy&&_isInvestor)) {
        [self.secTitleArr addObject:@"投资案例"];
    }
    
    if (self.viewModel.person.faanli.count) {
        [self.secTitleArr addObject:@"服务案例"];
    }
    
    //工作经历
    if (self.viewModel.person.work_exp.count || self.isMy) {
        [self.secTitleArr addObject:@"工作经历"];
    }
    //教育经历
    if (self.viewModel.person.edu_exp.count || self.isMy) {
        [self.secTitleArr addObject:@"教育经历"];
    }
    
    //获奖经历
    if (self.viewModel.person.win_experience.count || self.isMy) {
        [self.secTitleArr addObject:@"获奖经历"];
    }
    
    //商业关系
    if (self.viewModel.allCompany.count) {
        [self.secTitleArr addObject:@"商业关系"];
    }
    
    //人物新闻
    if (self.viewModel.person.person_news.count) {
        [self.secTitleArr addObject:@"人物新闻"];
    }
    self.originalSecTitleArr = [NSMutableArray arrayWithArray:self.secTitleArr];

}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.secTitleArr.count?:1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.secTitleArr.count == 0) {
        return 1;
    }
    NSString *sectionTitle = self.secTitleArr[section];
    if ([sectionTitle containsString:@"用户分享"]){
        return self.isMy ? 1 : (self.viewModel.commentLayouts.count ? 1 : 1);
    }else if ([sectionTitle isEqualToString:@"自我介绍"]) {
        if (![PublicTool isNull:self.viewModel.person.jieshao]) {
            return 1;
        }
        return self.isMy ? 1:0;
    } else if ([sectionTitle isEqualToString:@"人物画像"]) {
        return 1;
    } else if ([sectionTitle isEqualToString:@"商业关系"]) {
        return MIN(3,self.viewModel.allCompany.count);
    } else if ([sectionTitle isEqualToString:@"投资领域"]) {
        return 1;
    }else  if ([sectionTitle isEqualToString:@"主投阶段"]) {
        return 1;
    }else if ([sectionTitle isEqualToString:@"投资案例"]) {
        if (_isEditing) {
            return MAX(self.viewModel.person.tzanli1.count,(_isInvestor?1:0));
        }else{
            return self.viewModel.person.tzanli1.count ? 1:(self.isMy&&_isInvestor?1:0);
        }
        
    }else if ([sectionTitle isEqualToString:@"服务案例"]) {
        return self.viewModel.person.faanli.count ? 1:0;

    }else if ([sectionTitle isEqualToString:@"工作经历"]) {
        return self.viewModel.person.work_exp.count?self.viewModel.person.work_exp.count:(self.isMy?1:0);
    } else if ([sectionTitle isEqualToString:@"教育经历"]) {
        return self.viewModel.person.edu_exp.count?self.viewModel.person.edu_exp.count:(self.isMy?1:0);
    } else if ([sectionTitle isEqualToString:@"获奖经历"]) {
        if (_isEditing) {
            return MAX(self.viewModel.person.win_experience.count,1);
        }else{
            if( self.viewModel.person.win_experience.count > 3){
                return 3;
            }else{
                return self.viewModel.person.win_experience.count ? self.viewModel.person.win_experience.count:(self.isMy?1:0);
            }
        }
    } else if ([sectionTitle isEqualToString:@"人物新闻"]) {
        return self.viewModel.person.person_news.count > 3 ? 3:self.viewModel.person.person_news.count;
    } else {
        return 0;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.secTitleArr.count == 0) {
        return 0.01;
    }
    if (section == 0) {
        return 45;
    }
    return HEADERHEIGHT;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.secTitleArr.count == 0) {
        return [[UIView alloc]init];
    }
    NSString *title = self.secTitleArr[section];
    NSString *rightTitle = @"";
    if (_isEditing) {
        rightTitle = @"编辑";
    }    
    __weak typeof(self) weakSelf = self;
    if ([title containsString:@"用户分享"] || [title containsString:@"投资案例"]|| [title containsString:@"服务案例"] || [title containsString:@"新闻"] || [title containsString:@"商业关系"]) {
        if (!_isEditing) {
            if ([title containsString:@"用户分享"]) {
                rightTitle = self.viewModel.status_Info.comment_count > 0 ? [NSString stringWithFormat:@"全部(%ld)",self.viewModel.status_Info.comment_count]:@"";
                if (self.viewModel.status_Info.comment_count > 0) {
                    CommonTableVwSecHeadVw *commentHeader = [[CommonTableVwSecHeadVw alloc]initlbltitle:title leftBtnTitle:@"发布" btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
                        [weakSelf.viewModel.sectionHeaderBtnCommand execute:@{@"title":title,@"type":@"all"}];

                    } leftBtnClick:^{
                        [weakSelf.viewModel.publishCommentCommand execute:nil];
                    }];
                    return commentHeader;
                }
            }else if ([title containsString:@"投资案例"]) {
                if (self.viewModel.person.tzanli1.count > 3) {
                    rightTitle = [NSString stringWithFormat:@"全部(%ld)",self.viewModel.person.tzanli1.count];
                }
            }else if ([title containsString:@"服务案例"]) {
                if (self.viewModel.person.faanli.count > 3) {
                    rightTitle = [NSString stringWithFormat:@"全部(%ld)",self.viewModel.person.faanli.count];
                }
            }else if ([title containsString:@"新闻"]) {
                if (self.viewModel.person.person_news.count > 3) {
                    rightTitle = [NSString stringWithFormat:@"全部(%ld)",self.viewModel.person.person_news.count];
                }
            }else if ([title containsString:@"商业关系"]) {
                rightTitle = [NSString stringWithFormat:@"全部(%ld)",self.viewModel.allCompanyCount];
            }
        }else{
          if ([title containsString:@"投资案例"]) {
              rightTitle = self.viewModel.person.tzanli1.count ? @"添加":@"";
          }else{
              rightTitle = @"";
          }
        }

        NSString *type = _isEditing && rightTitle.length ? @"edit":(rightTitle.length ? @"all":nil);

        if (section == 0) {
            return [[CommonTableVwSecHeadVw alloc]initlbltitle:title btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
                [weakSelf.viewModel.sectionHeaderBtnCommand execute:@{@"title":title,@"type":type}];
            }];
        }
        
       
        return [[CommonTableVwSecHeadVw alloc]initlbltitle:title btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
           
            [weakSelf.viewModel.sectionHeaderBtnCommand execute:@{@"title":title,@"type":type}];
        }];
    }
    
    if([title isEqualToString:@"工作经历"] || [title isEqualToString:@"教育经历"] || [title isEqualToString:@"获奖经历"] ){
        if (_isEditing) {
            if ([title isEqualToString:@"工作经历"]) {
                rightTitle = self.viewModel.person.work_exp.count ? @"添加":@"";
            }else if ([title isEqualToString:@"教育经历"]) {
                rightTitle = self.viewModel.person.edu_exp.count ? @"添加":@"";
            }else if ([title isEqualToString:@"获奖经历"]) {
                rightTitle = self.viewModel.person.win_experience.count ? @"添加":@"";
            }
        }else{
            if ([title isEqualToString:@"获奖经历"] && self.viewModel.person.win_experience.count>3) {
                rightTitle = [NSString stringWithFormat:@"全部(%ld)",self.viewModel.person.win_experience.count];
            }else{
                rightTitle = @"";
            }
        }
        
        NSString *type = _isEditing && rightTitle.length ? @"edit":@"";

        return [[CommonTableVwSecHeadVw alloc]initlbltitle:title btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
            [weakSelf.viewModel.sectionHeaderBtnCommand execute:@{@"title":title,@"type":type}];
        }];
    }
    
    if([title isEqualToString:@"人物新闻"] || [title isEqualToString:@"人物画像"] || [title isEqualToString:@"商业关系"]){
        rightTitle = @"";
        return [[CommonTableVwSecHeadVw alloc]initlbltitle:title btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
            
        }];
    }
    
    if([title isEqualToString:@"自我介绍"] || [title isEqualToString:@"投资领域"] || [title isEqualToString:@"主投阶段"]){
        if (_isEditing) {
            rightTitle= @"编辑";
            if ([title isEqualToString:@"投资领域"]) {
                rightTitle = self.viewModel.tzlyFrame.tagsArray.count ? @"编辑":@"";
            }else if([title isEqualToString:@"主投阶段"]){
                rightTitle = self.viewModel.jtjdFrame.tagsArray.count ? @"编辑":@"";
            }
        }else{
            rightTitle = @"";
        }
        if (section == 0) {
            return [[CommonTableVwSecHeadVw alloc]initlbltitle:title btnTitle:rightTitle height:44 callBack:^(NSString *sectionTitle) {
                [[weakSelf.viewModel.sectionHeaderBtnCommand execute:@{@"title":title,@"type":@"edit"}] subscribeNext:^(id  _Nullable x) {
                    
                    [weakSelf.tableView reloadData];
                }];;
            }];
        }
        return [[CommonTableVwSecHeadVw alloc]initlbltitle:title btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
            [[weakSelf.viewModel.sectionHeaderBtnCommand execute:@{@"title":title,@"type":@"edit"}] subscribeNext:^(id  _Nullable x) {
                [weakSelf.tableView reloadData];
            }];;
        }];
    }

    return [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *whiteV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.1)];
    whiteV.backgroundColor = [UIColor whiteColor];
    return whiteV;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.secTitleArr.count == 0) {
        return SCREENW *3;
    }
    NSString *sectionTitle = self.secTitleArr[indexPath.section];
    
    if([sectionTitle containsString:@"用户分享"]){
        if (self.viewModel.commentLayouts.count == 0) {
            return 45;
        }
        ActivityLayout *layout = self.viewModel.commentLayouts.firstObject;
        return layout.textLayout.textBoundingSize.height+45;
    }else if ([sectionTitle isEqualToString:@"自我介绍"]) {
        return [PublicTool isNull:self.viewModel.person.jieshao] && self.isMy ? 74 : self.viewModel.introduceCellLayout.cellHeight;
        
    } else if ([sectionTitle isEqualToString:@"人物画像"]) {
        return self.viewModel.tagsFrame.tagsHeight-10.5;
    } else if ([sectionTitle isEqualToString:@"商业关系"]) {
        return UITableViewAutomaticDimension;
    } else if ([sectionTitle isEqualToString:@"投资领域"]) {
        if(self.viewModel.tzlyFrame.tagsArray.count == 0){
            return 74;
        }else{
            return self.viewModel.tzlyFrame.tagsHeight-10.5;
        }
    }else if ([sectionTitle isEqualToString:@"主投阶段"]) {
        if(self.viewModel.jtjdFrame.tagsArray.count == 0){
            return 74;
        }else{
            return self.viewModel.jtjdFrame.tagsHeight-10.5;
        }
    }else if ([sectionTitle isEqualToString:@"投资案例"]) {
        if (_isEditing) {
            return self.viewModel.person.tzanli1.count ? 78:74;
        }

        if(self.viewModel.person.tzanli1.count == 0 && self.isMy){
            return 74;
        }
        if (self.viewModel.person.tzanli1.count >= 3) {
            return 68*3+5;
        }
        return self.viewModel.person.tzanli1.count * 68+5;

    }else if ([sectionTitle isEqualToString:@"服务案例"]) {
        if (self.viewModel.person.faanli.count >= 3) {
            return 68*3+5;
        }
        return self.viewModel.person.faanli.count * 68+5;
    }else if ([sectionTitle isEqualToString:@"工作经历"]) {
        if (self.viewModel.person.work_exp.count && indexPath.row == 0) { //第一个
            return 57;
        }
        if (indexPath.row == self.viewModel.person.work_exp.count - 1) { //最后一个
            return 52;
        }else{
            return self.viewModel.person.work_exp.count ? 55:74;
            
        }
        
    } else if ([sectionTitle isEqualToString:@"教育经历"]) {
        if (self.viewModel.person.edu_exp.count && indexPath.row == 0) { //第一个
            return 57;
        }
        if (indexPath.row == self.viewModel.person.edu_exp.count - 1) { //最后一个
            return 52;
        }else{
            return self.viewModel.person.edu_exp.count ? 55:74;
            
        }
        
    } else if ([sectionTitle isEqualToString:@"获奖经历"]) {
        if (self.viewModel.person.win_experience.count == 0) {
            return 74;
        }
        CGFloat width = _isEditing ? SCREENW-56-67:SCREENW-56-17;
        WinExperienceModel *winM = self.viewModel.person.win_experience[indexPath.row];
        CGFloat height = [PublicTool heightOfString:winM.winning width:width font:[UIFont systemFontOfSize:15]];
        if (indexPath.row == 0) {
            return height+50;
        }
        return height+40;
        
    } else if ([sectionTitle isEqualToString:@"人物新闻"]) {
        if (!self.viewModel.person.person_news || self.viewModel.person.person_news.count == 0) return 0;
        if (indexPath.row == 0) {
            return 67;
        }
        return 57;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.secTitleArr.count == 0) {
        UITableViewCell *imgCell = [tableView dequeueReusableCellWithIdentifier:@"IMGCELL"];
        if (!imgCell) {
            imgCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMGCELL"];
        }
        UIImageView *imgV = [imgCell.contentView viewWithTag:1000];
        if (!imgV) {
            imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENW*3)];
            imgV.image = [UIImage imageNamed:@"detail_placeholder_bg"];
            imgV.tag = 1000;
            [imgCell.contentView addSubview:imgV];
        }
        return imgCell;
    }
    
    NSString *sectionTitle = self.secTitleArr[indexPath.section];
    if([sectionTitle containsString:@"用户分享"]){
        if (self.viewModel.commentLayouts.count == 0) {
            __weak typeof(self) weakSelf = self;
            NoCommontInfoCell *cell = [NoCommontInfoCell cellWithTableView:tableView clickAddBtn:^{
                [weakSelf.viewModel.publishCommentCommand execute:nil];
                
            }];
            cell.title = self.isMy ? @"您还没有用户分享，点击发表～～" : @"暂无用户分享，点击发表～～";
            return cell;
            
        }
        __weak typeof(self) weakSelf = self;
        
        DynamicRelateCell *cell = [DynamicRelateCell cellWithTableView:tableView clickSeeMore:^{
            [weakSelf.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"用户分享",@"type":@"all"}];
        }];
        cell.dataArr = self.viewModel.commentLayouts;
        cell.totalCount = [NSString stringWithFormat:@"共%ld条用户分享",self.viewModel.status_Info.comment_count];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.type = DynamicRelateCellTypePerson;
        cell.ID = self.viewModel.person.personId;
        return cell;
        
    }else if ([sectionTitle isEqualToString:@"自我介绍"]) {
        if([PublicTool isNull:self.viewModel.person.jieshao]){
            NoInfoCell *cell = [NoInfoCell cellWithTableView:tableView reuseIndentifier:@"NoInfoCelljieshao"];
            cell.isMy = YES;
            cell.btnText = @"自我介绍";
            @weakify(self);
            [[cell.addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [[self.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"自我介绍",@"type":@"edit"}] subscribeNext:^(id  _Nullable x) {
                    if ([x boolValue]) {
                        [self requestData];
                    }
                }];
                
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        __weak typeof(self) weakSelf = self;
        CommonIntroduceCell *cell = [CommonIntroduceCell cellWithTableView:tableView didTapShowAll:^{
            
            BOOL spread = [weakSelf.viewModel.introduceInfoDic[@"spread"] boolValue];
            [weakSelf.viewModel.introduceInfoDic setValue:@(!spread) forKey:@"spread"];
            [weakSelf.viewModel.introduceCellLayout layout];
            [weakSelf.tableView reloadData];
        }];
        cell.layout = self.viewModel.introduceCellLayout;
        cell.shortUrl = self.viewModel.person.short_url;
        return  cell;
        
    } else if ([sectionTitle isEqualToString:@"人物画像"]) {
        __weak typeof(self) weakSelf = self;
        DetailTagsCell *cell = [DetailTagsCell cellWithTableView:tableView tagString:self.viewModel.person.tags clickShrinkTag:^(BOOL isSpread, TagsFrame *tagFrame) {
            weakSelf.viewModel.tagIsSpread = isSpread;
            weakSelf.viewModel.tagsFrame = tagFrame;
            [weakSelf.tableView reloadData];

        } clickAddTag:^{
            [weakSelf clickAddTag];
        } clickTag:nil];
        return cell;
        
    } else if ([sectionTitle isEqualToString:@"商业关系"]) {
        PersonBusinessRoleCell *roleCell = [PersonBusinessRoleCell cellWithTableView:tableView];
        PersonRoleModel *roleM = self.viewModel.allCompany[indexPath.row];
        roleCell.model = roleM;
        roleCell.avatarLabel.backgroundColor = RANDOM_COLORARR[indexPath.row % 6];
        return roleCell;
        
    } else if ([sectionTitle isEqualToString:@"投资领域"]) {
        if(self.viewModel.tzlyFrame.tagsArray.count == 0){
            NoInfoCell *cell = [NoInfoCell cellWithTableView:tableView reuseIndentifier:@"NoInfoCelltzly"];
            cell.isMy = YES;
            cell.tipLab.hidden = YES;
            cell.btnText = @"投资领域";
            @weakify(self);
            [[cell.addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [self.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"投资领域",@"type":@"edit"}];
                
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }else{
            __weak typeof(self) weakSelf = self;
            PersonTzPreferenceCell *cell = [PersonTzPreferenceCell cellWithTableView:tableView tagString:(NSString*)self.viewModel.person.lingyu  clickShrinkTag:^(BOOL isSpread, TagsFrame *tagFrame) {
                weakSelf.viewModel.tagLingyuIsSpread = isSpread;
                weakSelf.viewModel.tzlyFrame = tagFrame;
                [weakSelf.tableView reloadData];
            } clickTag:^(NSString *tag) {
                [weakSelf clickLingyuTag:tag];
            }];
            cell.editBtn.hidden = !_isEditing;
            @weakify(self);
            [[cell.editBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [self.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"投资领域",@"type":@"edit"}];
                
            }];
            cell.titleStr = @"投资领域";
            return cell;
        }
    }else if([sectionTitle isEqualToString:@"主投阶段"]){
        
        if(self.viewModel.jtjdFrame.tagsArray.count == 0){
            NoInfoCell *cell = [NoInfoCell cellWithTableView:tableView reuseIndentifier:@"NoInfoCellztjd"];
            cell.isMy = YES;
            cell.tipLab.hidden = YES;
            cell.btnText = @"主投阶段";
            @weakify(self);
            [[cell.addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [self.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"主投阶段",@"type":@"edit"}];
                
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            __weak typeof(self) weakSelf = self;
            PersonTzPreferenceCell *cell = [PersonTzPreferenceCell cellWithTableView:tableView tagString:(NSString*)self.viewModel.person.jieduan clickShrinkTag:^(BOOL isSpread, TagsFrame *tagFrame) {
                weakSelf.viewModel.tagJieduanIsSpread = isSpread;
                weakSelf.viewModel.jtjdFrame = tagFrame;
                [weakSelf.tableView reloadData];
            } clickTag:nil];
            cell.editBtn.hidden = !_isEditing;
            @weakify(self);
            [[cell.editBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [self.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"主投阶段",@"type":@"edit"}];
                
            }];
            cell.titleStr = @"主投阶段";
            return cell;
        }
        
    }else if ([sectionTitle isEqualToString:@"投资案例"]) {
        if(self.viewModel.person.tzanli1.count == 0 && self.isMy){
            NoInfoCell *cell = [NoInfoCell cellWithTableView:tableView reuseIndentifier:@"NoInfoCelltzanli"];
            cell.isMy = YES;
            cell.tipLab.hidden = YES;
            cell.btnText = @"投资案例";
            @weakify(self);
            [[cell.addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [self.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"投资案例",@"type":@"edit"}];
                
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        if (_isEditing) {
            InvestorTzCaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvestorTzCaseCellID" forIndexPath:indexPath];
            cell.tzCaseM = self.viewModel.person.tzanli1[indexPath.row];
            cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
            cell.deleteBtn.hidden = !_isEditing;
            @weakify(self);
            [[cell.deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [self.viewModel.cellEditCommand execute:self.viewModel.person.tzanli1[indexPath.row]];
                
            }];
            if (self.viewModel.person.tzanli1.count-1 == indexPath.row) {
                [[cell.contentView viewWithTag:1000] setHidden:YES];
            }else{
                [[cell.contentView viewWithTag:1000] setHidden:NO];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }else{
            
            PersonInvestCaseTableViewCell *cell = [PersonInvestCaseTableViewCell cellWithTableView:tableView];
            cell.dataArray = self.viewModel.person.tzanli1;
            return cell;
        }
        
    }else if ([sectionTitle isEqualToString:@"服务案例"]) {
        PersonInvestCaseTableViewCell *cell = [PersonInvestCaseTableViewCell cellWithTableView:tableView];
        cell.dataArray = self.viewModel.person.faanli;
        return cell;
    } else if ([sectionTitle isEqualToString:@"工作经历"]) {
        if(self.viewModel.person.work_exp.count == 0){
            NoInfoCell *cell = [NoInfoCell cellWithTableView:tableView reuseIndentifier:@"NoInfoCellzhiwei"];
            cell.isMy = YES;
            cell.tipLab.hidden = YES;
            cell.btnText = @"工作经历";
            @weakify(self);
            [[cell.addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [self.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"工作经历",@"type":@"edit"}];
                
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        JobExpriencesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JobExpriencesCellID" forIndexPath:indexPath];
        cell.exprienceM = self.viewModel.person.work_exp[indexPath.row];
        cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
        
        if (_isEditing) {
            cell.editBtn.hidden = NO;
            cell.zaizhiLab.hidden = YES;
        }else{
            cell.zaizhiLab.hidden = NO;
            cell.editBtn.hidden = YES;
        }
        @weakify(self);
        [[cell.editBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.viewModel.cellEditCommand execute:self.viewModel.person.work_exp[indexPath.row]];
            
        }];
        if (indexPath.row == 0) { //第一个
            cell.topEdge.constant = 5;
            cell.topLine.backgroundColor = [UIColor whiteColor];
        }else{
            cell.topEdge.constant = 0;
            cell.topLine.backgroundColor = F5COLOR;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if ([sectionTitle isEqualToString:@"教育经历"]) {
        if(self.viewModel.person.edu_exp.count == 0){
            NoInfoCell *cell = [NoInfoCell cellWithTableView:tableView reuseIndentifier:@"NoInfoCelledu"];
            cell.isMy = YES;
            cell.tipLab.hidden = YES;
            cell.btnText = @"教育经历";
            @weakify(self);
            [[cell.addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [self.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"教育经历",@"type":@"edit"}];
                
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        JobExpriencesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EduExpriencesCellID" forIndexPath:indexPath];
        cell.eduExprienceM = self.viewModel.person.edu_exp[indexPath.row];
        cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
        
        if (_isEditing) {
            cell.editBtn.hidden = NO;
        }else{
            cell.editBtn.hidden = YES;
        }
        @weakify(self);
        [[cell.editBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            
            [self.viewModel.cellEditCommand execute:self.viewModel.person.edu_exp[indexPath.row]];
            
        }];
        if (indexPath.row == 0) { //第一个
            cell.topEdge.constant = 5;
            cell.topLine.backgroundColor = [UIColor whiteColor];
        }else{
            cell.topEdge.constant = 0;
            cell.topLine.backgroundColor = F5COLOR;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;

    } else if ([sectionTitle isEqualToString:@"获奖经历"]) {
        
        if(self.viewModel.person.win_experience.count == 0){
            NoInfoCell *cell = [NoInfoCell cellWithTableView:tableView reuseIndentifier:@"NoInfoCellwin"];
            cell.isMy = YES;
            cell.tipLab.hidden = YES;
            cell.btnText = @"获奖经历";
            cell.tipLab.hidden = YES;
            @weakify(self);
            [[cell.addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [self.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"获奖经历",@"type":@"edit"}];
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        JobExpriencesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WinExpriencesCellID" forIndexPath:indexPath];
        if (_isEditing) {
            cell.editBtn.hidden = NO;
            cell.nameLabRightEdge.constant = 67;
        }else{
            cell.editBtn.hidden = YES;
            cell.nameLabRightEdge.constant = 17;
        }
        cell.winExprienceM = self.viewModel.person.win_experience[indexPath.row];
        if (indexPath.row == 0) { //第一个
            cell.topEdge.constant = 5;
            cell.topLine.backgroundColor = [UIColor whiteColor];
        }else{
            cell.topEdge.constant = 0;
            cell.topLine.backgroundColor = F5COLOR;
        }
        @weakify(self);
        [[cell.editBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.viewModel.cellEditCommand execute:self.viewModel.person.win_experience[indexPath.row]];
            
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else if ([sectionTitle isEqualToString:@"人物新闻"]) {
        //公司新闻
        static NSString *cellIdentifier = @"NewsTableViewCellID";
        NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        NewsModel *newsModel = self.viewModel.person.person_news[indexPath.row];
        cell.newsModel = newsModel;
        //长按复制
        UILongPressGestureRecognizer *longNews = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressJianjieLbl:)];
        [cell.titleLbl addGestureRecognizer:longNews];
        cell.firstRow = indexPath.row == 0;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        NoInfoCell *cell = [NoInfoCell cellWithTableView:tableView reuseIndentifier:@"NoInfoCellOthre"];
        cell.isMy = YES;
        cell.btnText = @"其他";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}


/**
 @param sender 点击企业画像
 */
- (void)clickAddTag{
    // 认证限制
    if (![PublicTool userisCliamed]) {
        return ;
    }
    
    NSArray *dataArr = [self.viewModel.person.tags componentsSeparatedByString:@"|"];
    ManagerAlertView *alertView = [ManagerAlertView initFrame];
    alertView.nameArr = [NSMutableArray arrayWithArray:dataArr];
    [alertView initViewWithTitle:@"给人物添加画像"];
    alertView.action = @"addAlbumToSelf";
    alertView.delegata = self;
    alertView.currentVC = self;

    [KEYWindow addSubview:alertView];
    _alertView = alertView;
}

- (void)longPressJianjieLbl:(UILongPressGestureRecognizer *)longPress{
    UILabel *lbl = (UILabel *)longPress.view;
    
    NSString *urlStr = self.viewModel.person.short_url;
    if ([urlStr hasPrefix:@"http://"]||[urlStr hasPrefix:@"https://"]) {
        [PublicTool storeShortUrlToLocal:urlStr];
    }
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [NSString stringWithFormat:@"%@ 来自@企名片%@",lbl.text,urlStr];
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}


/**
 @param sender 点击投资领域
 */
- (void)clickLingyuTag:(NSString*)tag{
    if (_isEditing) {
        return;
    }
    
    GetProductsFromTagsViewController *tagsVC = [[GetProductsFromTagsViewController alloc]init];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [mDict setValue:tag forKey:@"tag"];
    
    tagsVC.urlDict = mDict;
    
    [self.navigationController pushViewController:tagsVC animated:YES];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.secTitleArr.count == 0) {
        return;
    }
    NSString *sectionTitle = self.secTitleArr[indexPath.section];
    if ([sectionTitle containsString:@"用户分享"]) {
       
    }else if ([sectionTitle isEqualToString:@"投资案例"]) {
        if (self.viewModel.person.tzanli1.count == 0 || _isEditing) return;
        
        PersonTouziModel *touziModel = self.viewModel.person.tzanli1[indexPath.row];
        
        if ([PublicTool isNull:touziModel.detail]) return;
        
        NSDictionary *dic = [PublicTool toGetDictFromStr:touziModel.detail];
        [[AppPageSkipTool shared] appPageSkipToProductDetail:dic];
        [QMPEvent event:@"person_tzcaseCellClick"];
        
    }else if ([sectionTitle isEqualToString:@"服务案例"]) {
        if (self.viewModel.person.faanli.count == 0) return;
        
        PersonTouziModel *touziModel = self.viewModel.person.faanli[indexPath.row];
        
        if ([PublicTool isNull:touziModel.detail]) return;
        
        NSDictionary *dic = [PublicTool toGetDictFromStr:touziModel.detail];
        [[AppPageSkipTool shared] appPageSkipToProductDetail:dic];
        [QMPEvent event:@"person_tzcaseCellClick"];
        
    }  else if ([sectionTitle isEqualToString:@"工作经历"]) {
        
        if (_isEditing) {
            if (self.viewModel.person.work_exp.count == 0 ){
                [self.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"工作经历",@"type":@"edit"}];
            }else{
                ZhiWeiModel *workInfo = self.viewModel.person.work_exp[indexPath.row];
                [self.viewModel.cellEditCommand execute:workInfo];
            }

            return;
        }
        
        if (self.viewModel.person.work_exp.count == 0 ) return;

        ZhiWeiModel *workInfo = self.viewModel.person.work_exp[indexPath.row];

        if ([PublicTool isNull:workInfo.detail]) return;
        NSDictionary *dic = [PublicTool toGetDictFromStr:workInfo.detail];
        if ([workInfo.jump_type isEqualToString:@"jigou"]) {
            //如果是机构
            [[AppPageSkipTool shared] appPageSkipToJigouDetail:dic];
            
        } else if ([workInfo.jump_type isEqualToString:@"product"]){
            
            NSDictionary *dic = [PublicTool toGetDictFromStr:workInfo.detail];
            [[AppPageSkipTool shared] appPageSkipToProductDetail:dic];
        }else if ([workInfo.jump_type isEqualToString:@"register"]){
            
            NSDictionary *dic = [PublicTool toGetDictFromStr:workInfo.detail];
            [[AppPageSkipTool shared] appPageSkipToRegisterDetail:dic];
        }
        
        [QMPEvent event:@"person_workCellClick"];
        
    } else if ([sectionTitle isEqualToString:@"教育经历"]) {
        
        @weakify(self);
        if (_isEditing) {
            if (self.viewModel.person.edu_exp.count == 0 ){
                [self.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"教育经历",@"type":@"edit"}];
            }else{
                ExperienceModel *experience = self.viewModel.person.edu_exp[indexPath.row];
                [self.viewModel.cellEditCommand execute:experience];
            }
            
            return;
        }
        if (self.viewModel.person.edu_exp.count == 0 ) return;
        
        ExperienceModel *experience = self.viewModel.person.edu_exp[indexPath.row];
        
        if ([PublicTool isNull:experience.school]) return;
        
        SchoolPersonController  *personVC = [[SchoolPersonController alloc]init];
        personVC.school = experience.school;
        [self.navigationController pushViewController:personVC animated:YES];
        
    } else if ([sectionTitle isEqualToString:@"获奖经历"]) {
        if (_isEditing) {
            if (self.viewModel.person.win_experience.count == 0 ){
                [self.viewModel.sectionHeaderBtnCommand execute:@{@"title":@"获奖经历",@"type":@"edit"}] ;
            }else{
                WinExperienceModel *experience = self.viewModel.person.win_experience[indexPath.row];
                [self.viewModel.cellEditCommand execute:experience];
            }
            
            return;
        }
    } else if ([sectionTitle isEqualToString:@"人物新闻"]) {
        if (self.viewModel.person.person_news.count == 0) return;
        
        //新闻
        NewsModel *item = self.viewModel.person.person_news[indexPath.row];
        URLModel *urlModel = [[URLModel alloc] init];
        urlModel.url = item.link;
        urlModel.title = item.title;
        NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
        webView.fromVC = @"公司新闻";
        [self.navigationController pushViewController:webView animated:YES];
        [QMPEvent event:@"person_newsCellClick"];
        
        webView.feedbackFlag = @"人物";
        webView.person = @{@"id":self.viewModel.person.personId?:@"",@"name":self.viewModel.person.name?:@""};
        
    } else if ([sectionTitle isEqualToString:@"商业关系"]){
        
        PersonRoleModel *roleModel = self.viewModel.allCompany[indexPath.row];
        NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:[PublicTool toGetDictFromStr:roleModel.detail]];
        [mdic removeObjectForKey:@"id"];
        [mdic removeObjectForKey:@"p"];
        [[AppPageSkipTool shared] appPageSkipToRegisterDetail:mdic];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(scrollView != self.tableView){
        return;
    }    
    //导航
    if (scrollView.contentOffset.y <= 44) {
        if(![PublicTool isNull:_nabar.title]){
            _nabar.title = nil;
        }
    }else if(scrollView.contentOffset.y > 44){
        if([PublicTool isNull:_nabar.title]){
            _nabar.title = self.viewModel.person.name;
        }
    }
}

#pragma mark --event--
- (void)showDetailInfo{
    
    CompanyInfoView *alertV = [CompanyInfoView instanceCompanyInfoView:CGRectMake(0, 0, SCREENW, SCREENH) withName:self.viewModel.person.name withInfo:self.viewModel.person.jieshao];
    alertV.shortUrlStr = self.viewModel.person.short_url;
    [KEYWindow addSubview:alertV];
}

- (void)copyInfo{
    
    NSString *info = self.viewModel.person.jieshao;
    [UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"%@ 来自@企名片%@",info,self.viewModel.person.short_url];
    [PublicTool showMsg:@"复制成功"];
}


- (void)feedbackDetail:(UIButton*)sender{
    
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        NSString *sectionTitle;
        if (sender.tag != 10011) {
            sectionTitle = [(UILabel*)[sender.superview viewWithTag:9000] text];
            
        }
        
        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息
        [infoDic setValue:@"人物信息" forKey:@"module"];
        
        if (![PublicTool isNull:self.viewModel.person.name]) {
            [infoDic setValue:self.viewModel.person.name forKey:@"company"];
        }else{
            [infoDic setValue:@"" forKey:@"company"];
        }
        
        [infoDic setValue:self.viewModel.person.personId forKey:@"product"];
        
        if (sender.tag == 10001) { //头部
            [infoDic setValue:@"人物基本信息" forKey:@"title"];
            
            [mArr addObject:@"所在公司不对"];
            [mArr addObject:@"职务不对"];
            [mArr addObject:@"头像不对"];
        }else if([sectionTitle isEqualToString:@"自我介绍"]){
            [infoDic setValue:@"人物介绍" forKey:@"module"];
            
            [infoDic setValue:@"自我介绍" forKey:@"title"];
            
            [mArr addObject:@"简介不对"];
            [mArr addObject:@"简介不全"];
        }else if([sectionTitle isEqualToString:@"人物画像"]){
            [infoDic setValue:@"人物画像" forKey:@"module"];
            
            [infoDic setValue:@"人物画像" forKey:@"title"];
            
            [mArr addObject:@"人物画像不对"];
        }else if([sectionTitle isEqualToString:@"投资领域"]){
            [infoDic setValue:@"投资领域" forKey:@"title"];
            [infoDic setValue:@"投资领域" forKey:@"module"];
            
            [mArr addObject:@"投资领域不对"];
            [mArr addObject:@"投资领域不全"];
        }else if([sectionTitle isEqualToString:@"主投阶段"]){
            [infoDic setValue:@"主投阶段" forKey:@"title"];
            [infoDic setValue:@"主投阶段" forKey:@"module"];
            
            [mArr addObject:@"主投阶段不对"];
            [mArr addObject:@"主投阶段不全"];
        }else if([sectionTitle isEqualToString:@"投资案例"]){
            [infoDic setValue:@"人物投资案例" forKey:@"title"];
            [infoDic setValue:@"人物投资案例" forKey:@"module"];
            
            [mArr addObject:@"案例不对"];
            [mArr addObject:@"案例不全"];
        }else if([sectionTitle isEqualToString:@"工作经历"]){
            [infoDic setValue:@"工作经历" forKey:@"title"];
            [infoDic setValue:@"工作经历" forKey:@"module"];
            
            [mArr addObject:@"职务不对"];
            [mArr addObject:@"职务信息太旧"];
        }else if([sectionTitle isEqualToString:@"教育经历"]){
            [infoDic setValue:@"教育经历" forKey:@"title"];
            [infoDic setValue:@"教育经历" forKey:@"module"];
            
            [mArr addObject:@"学历信息不对"];
            [mArr addObject:@"学历信息不全"];
        }else if([sectionTitle isEqualToString:@"获奖经历"]){
            [infoDic setValue:@"获奖经历" forKey:@"title"];
            [infoDic setValue:@"获奖经历" forKey:@"module"];
            
            [mArr addObject:@"奖项名称不对"];
            [mArr addObject:@"颁奖单位不对"];
            [mArr addObject:@"颁奖时间不对"];
            
        }else if([sectionTitle isEqualToString:@"人物新闻"]){
            [infoDic setValue:@"人物新闻" forKey:@"title"];
            [infoDic setValue:@"人物新闻" forKey:@"module"];
            
            [mArr addObject:@"链接失效"];
            [mArr addObject:@"新闻不相关"];
            [mArr addObject:@"新闻重复"];
            [mArr addObject:@"新闻不全"];
            
        }
        
        CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:CGRectZero WithAlertViewHeight:50 infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
    }
    
    
}

#pragma mark --懒加载
-(NSArray *)moreOptionsArr{
    
    if (!_moreOptionsArr) {
        LrdCellModel *jietuLongM = [[LrdCellModel alloc] initWithTitle:@"截长图" imageName:@"captureScreen_more1"];
//        LrdCellModel *kefuM = [[LrdCellModel alloc] initWithTitle:@"客服" imageName:@"detail_kefu"];
        LrdCellModel *feedbackM = [[LrdCellModel alloc] initWithTitle:@"反馈" imageName:@"detail_feedback_icon"];
        
        LrdCellModel *homeModel = [[LrdCellModel alloc] initWithTitle:@"回首页" imageName:@"gohome_detail"];
        _moreOptionsArr = @[jietuLongM,homeModel];
    }
    return _moreOptionsArr;
}

- (NSMutableArray *)secTitleArr{
    if (!_secTitleArr) {
        _secTitleArr = [NSMutableArray array];
    }
    return _secTitleArr;
}


-(PersonDetailViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[PersonDetailViewModel alloc]init];
        _viewModel.personId = self.persionId;
        
        @weakify(self);
        if (!self.isMy) {
            
            [RACObserve(_viewModel, status_Info.focus_status) subscribeNext:^(id  _Nullable x) {
                @strongify(self);
                [self refreshBottomBtn];
            }];
            [RACObserve(_viewModel, status_Info.comment_count) subscribeNext:^(id  _Nullable x) {
                @strongify(self);
                [self.tableView reloadData];
            }];
        }
        
        _viewModel.refreshDataSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            [self requestData];
            return nil;
        }];
        _viewModel.refreshCommentSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            [self.tableView reloadData];
            return nil;
        }];
    }
    return _viewModel;
}

@end
