//
//  UnauthPeresonPageController.m
//  qmp_ios
//
//  Created by QMP on 2018/6/6.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "UnauthPeresonPageController.h"
#import "NoInfoCell.h"
#import "EditBasicInfoController.h"
#import "LrdOutputView.h"
#import "PersonHeadView.h"
#import "ActivityModel.h"
#import "ActivityLayout.h"
#import "CommonTableVwSecHeadVw.h"
#import "NoCommentCell.h"
#import "IntroduceCellLayout.h"
#import "CommonIntroduceCell.h"
#import "DetailNavigationBar.h"
#import "NoCommontInfoCell.h"
#import "PostActivityViewController.h"
#import "ActivityListViewController.h"
#import "DynamicRelateCell.h"
#import "FriendModel.h"
#import "AutheChangePersonController.h"

#define QMPRobotUnionid @"ff0dd6495cf59d76a7debefbf6065db2"

@interface UnauthPeresonPageController ()<UITableViewDelegate,UITableViewDataSource,LrdOutputViewDelegate>
{
    BOOL fromEditBasicInfo; //来自修改基本信息页
    CGFloat originalOffSetY;
    UIView *_bottomView;
    UIButton *_contactBtn;
    UIButton *_shareBtn; //自己的主页
    UIButton *_focusBtn; //关注

    BOOL _isEditing;
    
    LrdOutputView *_outputView;
    
    UIImage *_printsmallImage;
    UIImage *_printscreenImage;
    UIButton *_editBarButton;
    
    PersonHeadView *_headerView;
}

@property(nonatomic,assign)BOOL isMy;
@property(nonatomic,strong)NSMutableArray *secTitleArr;
@property(nonatomic,strong)NSMutableDictionary *userInfoDic; //基本数据信息
@property(nonatomic,strong)NSMutableArray *commentList; //
@property(nonatomic,copy)NSString *commentCount; //
@property(nonatomic,strong)NSMutableDictionary *introduceInfoDic;
@property(nonatomic,strong)IntroduceCellLayout *introduceCellLayout;
@property(nonatomic,strong)NSArray *moreOptionsArr;
@property(nonatomic,strong)DetailNavigationBar *nabar;;


@end

@implementation UnauthPeresonPageController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [QMPEvent endEvent:@"person_pageTimer"];
    [IQKeyboardManager sharedManager].enable = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //更新基本信息
    if (self.userInfoDic && self.userInfoDic && fromEditBasicInfo) {
        [self requestData];
    }
    [QMPEvent beginEvent:@"person_pageTimer"];
    self.tableView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

//    self.unionid = @"oP3fkwCNJVEfsVe1IsjDWDMhJdgI";
    self.isMy = [self.unionid isEqualToString:[WechatUserInfo shared].unionid] ? YES:NO;
    if (self.isMy) {
        _isEditing = YES;
    }
    [self setUI];
    [self showHUD];
    [self requestData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(claimFinish) name:@"claimFinish" object:nil];
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUI{
    
    if(!self.userInfoDic){
        return;
    }
    if (!self.tableView) {
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kScreenTopHeight, SCREENW, SCREENH-kScreenBottomHeight+kStatusBarHeight) style:UITableViewStylePlain];
        self.tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview:self.tableView];
        if (self.isMy) {
            self.tableView.mj_header = self.mjHeader;
            self.mjHeader.gifView.hidden = YES;
        }
        
        [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"headerView"];
        [self.tableView registerClass:[NoInfoCell class] forCellReuseIdentifier:@"NoInfoCellID"];
        
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        
        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        //如果是机器人账户 不加载
        if (![self.userInfoDic[@"unionid"] isEqualToString:QMPRobotUnionid]) {
            _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH  - kScreenBottomHeight, SCREENW, kScreenBottomHeight)];
            _bottomView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:_bottomView];
            
            _contactBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW/2.0, kShortBottomHeight)];
            [_contactBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _contactBtn.backgroundColor = HTColorFromRGB(0xE3E3E3); //对方普通用户未入驻不能发私信
            [_contactBtn setTitle:@"私信" forState:UIControlStateNormal];
            if (@available(iOS 8.2, *)) {
                _contactBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            } else {
                _contactBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            }
            [_contactBtn addTarget:self action:@selector(chatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:_contactBtn];
            
            _focusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _focusBtn.frame = CGRectMake(SCREENW/2.0, 0, SCREENW/2.0, kShortBottomHeight);
            _focusBtn.backgroundColor = BLUE_BG_COLOR;
            [_focusBtn buttonWithTitle:@"关注" image:@"workflow_add" titleColor:[UIColor whiteColor] fontSize:15];
            [_focusBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:8];
            [_focusBtn setTitle:@"已关注" forState:UIControlStateSelected];
            if (@available(iOS 8.2, *)) {
                _focusBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            } else {
                _focusBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            }
            [_focusBtn setImage:[UIImage imageNamed:@"workflow_have"] forState:UIControlStateSelected];
            [_focusBtn addTarget:self action:@selector(focusBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:_focusBtn];
            
            _shareBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW/2.0+1, 0, 132, 32)];
            [_shareBtn setTitle:@"认证官方人物" forState:UIControlStateNormal];
            [_shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _shareBtn.backgroundColor = [UIColor whiteColor];
            _shareBtn.layer.masksToBounds = YES;
            _shareBtn.layer.cornerRadius = 16;
            _shareBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [_shareBtn addTarget:self action:@selector(myClaimBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:_shareBtn];
            _shareBtn.centerY = kScreenBottomHeight == 49 ? _bottomView.height/2.0:_bottomView.height/2.0 - 8;
            _shareBtn.centerX = _bottomView.width/2.0;
            
           
            
        }
       
        //线
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
        topLine.backgroundColor = LIST_LINE_COLOR;
        [_bottomView addSubview:topLine];
        _bottomView.hidden = YES;
        
        __weak typeof(self) weakSelf = self;
        DetailNavigationBar *topBar = [DetailNavigationBar detailTopBarWithRightMenuArr:self.moreOptionsArr moreClick:^{
            [weakSelf pressRightButtonItem:nil];
        }];
        topBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
        [self.view addSubview:topBar];
        _nabar = topBar;
        
        if (!self.isMy) {
            UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 400)];
            footerV.backgroundColor = [UIColor whiteColor];
            self.tableView.tableFooterView = footerV;
        }else{
            UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, kScreenBottomHeight)];
            footerV.backgroundColor = [UIColor whiteColor];
            self.tableView.tableFooterView = footerV;
        }
    }
    
    PersonHeadView *headerView = [[PersonHeadView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 172+15 + kScreenTopHeight)];
    headerView.infoDic = self.userInfoDic;
    headerView.editBtn.hidden = !_isEditing;
    [headerView.editBtn addTarget:self action:@selector(editBasicInfo:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = headerView;
    //机器人账户 隐藏交换按钮
    if ([self.userInfoDic[@"unionid"] isEqualToString:QMPRobotUnionid]) {
        headerView.editBtn.hidden = YES;
        headerView.tipInfoLab.hidden = YES;
    }
    
    [self.tableView reloadData];
    _headerView = headerView;
    _shareBtn.hidden = YES;
    
    
    if (!self.userInfoDic) {
        return;
    }
    //如果是机器人账户 不加载
    if ([self.userInfoDic[@"unionid"] isEqualToString:QMPRobotUnionid]) {
        [_bottomView removeFromSuperview];
        self.tableView.height += kScreenBottomHeight;
        return;
    }
    _bottomView.hidden = NO;

    if(!_bottomView.superview){
        [self.view addSubview:_bottomView];
    }
    
    if (self.isMy) { //我自己（认证按钮）
        _shareBtn.hidden = NO;
        _contactBtn.hidden = YES;
        _focusBtn.hidden = YES;
        [[_bottomView viewWithTag:1000] setHidden:YES];
        if ([WechatUserInfo shared].claim_type.integerValue == 0 || [WechatUserInfo shared].claim_type.integerValue == 3) {
            [_shareBtn setTitle:@"认证官方人物" forState:UIControlStateNormal];
            _shareBtn.backgroundColor = BLUE_BG_COLOR;

        }else if ([WechatUserInfo shared].claim_type.integerValue == 1) {
            [_shareBtn setTitle:@"审核中" forState:UIControlStateNormal];
            _shareBtn.backgroundColor = H9COLOR;
        }
        return;
    }
    
    _shareBtn.hidden = YES;
    //关注是否
    [self refreshFocusBtn];
}

- (void)claimFinish{
    
    [WechatUserInfo shared].claim_type = @"1";
    [self setUI];
}


- (void)focusBtnClick{
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setValue:self.userInfoDic[@"unionid"] forKey:@"ticket"];
    [dic setValue:self.userInfoDic[@"nickname"]?self.userInfoDic[@"nickname"]:@"" forKey:@"project"];
    NSString *changeStatus = [self.userInfoDic[@"is_focus"] integerValue] == 1 ? @"0":@"1";
    [dic setValue:changeStatus forKey:@"work_flow"];
    [dic setValue:@"user" forKey:@"type"];
    
    [AppNetRequest attentFunctionWithParam:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            [PublicTool showMsg:changeStatus.integerValue == 0?@"取消关注成功":@"关注成功"];
            [self.userInfoDic setValue:changeStatus forKey:@"is_focus"];
            [self refreshFocusBtn];
        }else{
            [PublicTool showMsg:changeStatus.integerValue == 0?@"取消关注失败":@"关注失败"];
        }
    }];
    
}


- (void)refreshFocusBtn{
    
    if ([self.userInfoDic[@"is_focus"] integerValue] == 1) {
        //已关注
        [_focusBtn setTitle:@"已关注" forState:UIControlStateNormal];
        [_focusBtn setImage:[UIImage imageNamed:@"workflow_have"] forState:UIControlStateNormal];
    }else{
        //没关注
        [_focusBtn setTitle:@"关注" forState:UIControlStateNormal];
        [_focusBtn setImage:[UIImage imageNamed:@"workflow_add"] forState:UIControlStateNormal];
    }
   
}


#pragma mark --Event--
//手动截屏响应
- (void)userDidTakeScreenshot:(NSNotification *)notification
{
    _printsmallImage = [PublicTool getWindowCaptureImage];
    [self.shareTool shareDetailImage:_printsmallImage];
    
}

- (void)screenLongCut{
    
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
    _printsmallImage = [PublicTool getWindowCaptureImage];
    
    [_outputView pop];

}


- (void)myClaimBtnClick:(UIButton*)btn{
    if ([btn.titleLabel.text containsString:@"审核中"]) {
        return;
    }
    
    [[AppPageSkipTool shared] appPageSkipToClaimPage];
    
}
#pragma mark - LrdOutputViewDelegate 代理方法
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.view endEditing:YES];
    switch (indexPath.row) {
        case 0:{
//            //截短屏
            [self screenLongCut];
        }
            break;
      
        case 1:{
            [self kefuBtnClick];
        }
            break;
        case 2:{
            //首页
            [self.tabBarController setSelectedIndex:0];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)chatBtnClick:(UIButton*)btn{
    
    if ([WechatUserInfo shared].claim_type.integerValue == 2 ){ //对方未入驻
        [PublicTool alertActionWithTitle:@"提示" message:@"对方还未认证" btnTitle:@"我知道了" action:nil];
        
    }else {
        [PublicTool userisCliamed];
    }

}

// 导航编辑按钮
- (void)editBtnClick:(UIButton*)editBtn{
    
    if ([editBtn.titleLabel.text isEqualToString:@"编辑"]) {
        [_editBarButton setTitle:@"完成" forState:UIControlStateNormal];
        [USER_DEFAULTS setBool:YES forKey:isEditedMyInfo];
        [USER_DEFAULTS synchronize];
        self.tableView.mj_header = nil;
    }else{
        self.tableView.mj_header = self.mjHeader;
        [_editBarButton setTitle:@"编辑" forState:UIControlStateNormal];
    }
    
    _isEditing = !_isEditing;
    PersonHeadView *headerV = (PersonHeadView*)self.tableView.tableHeaderView;
    headerV.editBtn.hidden = !_isEditing;
    [self.tableView reloadData];
}

//修改头部数据
- (void)editBasicInfo:(UIButton*)btn{
    
    EditBasicInfoController *basicInfoVC = [[EditBasicInfoController alloc]init];
    basicInfoVC.userInfoDic = self.userInfoDic;
    [self.navigationController pushViewController:basicInfoVC animated:YES];
    fromEditBasicInfo = YES;
    
}


- (void)kefuBtnClick{
    [PublicTool contactKefu:nil reply:kDefaultWel];
    [QMPEvent event:@"company_kefu_click"];
    
}

- (BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    
    NSString *unionid = self.isMy ? [WechatUserInfo shared].unionid : (self.unionid?self.unionid:@"");
    [AppNetRequest getUserInfoWithParameter:@{@"unionid":[WechatUserInfo shared].unionid,@"unionids":unionid} completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.nabar hideAnimator];
        
        if (resultData && resultData[@"data"]) {
            
            self.userInfoDic = [NSMutableDictionary dictionaryWithDictionary:resultData[@"data"]];
            //认领状态可能会更新
            self.title = [PublicTool nilStringReturn:self.userInfoDic[@"nickname"]];
            if (self.isMy) {
                [WechatUserInfo shared].claim_type = [NSString stringWithFormat:@"%@",self.userInfoDic[@"claim_type"]];
                [[WechatUserInfo shared] save];
            }
            self.introduceInfoDic = [NSMutableDictionary dictionaryWithDictionary:@{@"content":self.userInfoDic[@"desc"]?:@"",@"spread":@(NO)}];
            self.introduceCellLayout = [[IntroduceCellLayout alloc]initWithIntroduce:self.introduceInfoDic];

            [self requestDynamicInfo];
        }
        
        [self setUI];
        
    }];
    

    return YES;
}

- (void)requestDynamicInfo{
    
    if ([PublicTool isNull: self.userInfoDic[@"uuid"]]) {
        return;
    }
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:@(self.currentPage) forKey:@"page"];
    [paramDict setValue:@(self.numPerPage) forKey:@"num"];
    [paramDict setValue:@"user" forKey:@"type"];
    [paramDict setValue:self.userInfoDic[@"uuid"] forKey:@"ticket"];
    
    if (![[WechatUserInfo shared].unionid isEqualToString:self.unionid]) {
        [paramDict setValue:@"1" forKey:@"anonymous_flag"];
    }

    if (self.tableView.mj_header.isRefreshing) {
        [paramDict setValue:@"1" forKey:@"debug"];
    }
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/getDetailReleaseList" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        NSArray *list = @[];
        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            list = resultData[@"list"];
            self.commentCount = resultData[@"count"];
            [self.commentList removeAllObjects];
            for (NSDictionary *dict in list) {
                ActivityModel *model = [ActivityModel activityModelWithDict:dict];
                if (![PublicTool isNull:model.linkInfo.linkUrl]) {
                    model.linkInfo.linkTitle = @"新闻链接";
                }
                ActivityLayout *layout = [[ActivityLayout alloc] initLayoutWithActivityModel:model type:ActivityLayoutTypePerson] ;//layoutWithActivityModel:model];
                [self.commentList addObject:layout];
            }
        }
        [self.tableView reloadData];
        
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.secTitleArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!self.isMy && self.commentCount.integerValue == 0) {
        return 1;
    }
    
    NSString *secTitle =  self.secTitleArr[section];
    if ([secTitle containsString:@"用户分享"]) {
        if (self.isMy) {
            return 1;
        }else{
            if (self.commentCount.integerValue) {
                return 1;
            }
            return 0;
        }
    }else if([secTitle isEqualToString:@"人物介绍"]){
        return self.isMy ? 1:0;
    }else if([secTitle containsString:@"经历"]){
        return 1;
    }else{
        return 0;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 44;
    }
    
    NSString *secTitle =  self.secTitleArr[section];
    if ([secTitle containsString:@"用户分享"]) {
        if (self.isMy) {
            return HEADERHEIGHT;
        }else{
            if (self.commentCount.integerValue) {
                return HEADERHEIGHT;
            }
            return 0.1;
        }
    }else if([secTitle isEqualToString:@"人物介绍"]){
        return self.isMy ? HEADERHEIGHT:0.1;
    }else if([secTitle containsString:@"经历"]){
        return HEADERHEIGHT;
    }else{
        return 0.1;
    }
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *secTitle =  self.secTitleArr[section];
    NSString *rightTitle = @"";
    if ([secTitle containsString:@"用户分享"]) {
        if (!self.isMy && self.commentCount.integerValue == 0) {
            UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.1)];
            head.backgroundColor = [UIColor whiteColor];
            return head;
        }
        
        rightTitle = self.commentCount.integerValue > 0 ? [NSString stringWithFormat:@"全部(%@)",self.commentCount]:@"";
        __weak typeof(self) weakSelf = self;
        if (_isMy && self.commentCount.integerValue > 0) {
            CommonTableVwSecHeadVw *commentHeader = [[CommonTableVwSecHeadVw alloc]initlbltitle:@"用户分享" leftBtnTitle:@"发布" btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
                [weakSelf enterAllComment];
                
            } leftBtnClick:^{
                [weakSelf enterPublishComment];
                
            }];
            return commentHeader;
        }
        
        return [[CommonTableVwSecHeadVw alloc]initlbltitle:self.isMy ? @"用户分享" : @"用户分享" btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
            [weakSelf enterAllComment];
        }];
        
    }else if([secTitle isEqualToString:@"人物介绍"] || [secTitle isEqualToString:@"工作经历"] || [secTitle isEqualToString:@"教育经历"]){
        return [[CommonTableVwSecHeadVw alloc]initlbltitle:secTitle btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
            
        }];
        
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.1)];
    footerV.backgroundColor = [UIColor whiteColor];
    return footerV;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.isMy && self.commentCount.integerValue == 0) {
        return SCREENH-210;
    }
    NSString *sectionTitle = self.secTitleArr[indexPath.section];
    if ([sectionTitle isEqualToString:@"人物介绍"]) {
        NSString *dec = self.userInfoDic[@"desc"];
        if ([PublicTool isNull:dec]) return 74;
        
        return self.introduceCellLayout.cellHeight;
    }else if ([sectionTitle isEqualToString:@"工作经历"]) {
        return 74;
    } else if ([sectionTitle isEqualToString:@"教育经历"]) {
        return 74;
    }else if([sectionTitle containsString:@"用户分享"]){
        if (self.commentCount.integerValue) {
            return 94+15;
        }
        return 45;
    }else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.isMy && self.commentCount.integerValue == 0) {
        HomeInfoTableViewCell *cell = [self nodataCellWithInfo:@"" tableView:tableView];
        cell.iconImgView.hidden = YES;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    
    NSString *sectionTitle = self.secTitleArr[indexPath.section];
    
    if ([sectionTitle isEqualToString:@"人物介绍"]) {
        if([PublicTool isNull:self.userInfoDic[@"desc"]] && self.isMy){
            NoInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoInfoCellID" forIndexPath:indexPath];
            cell.isMy = YES;
            [cell unAuthCellMsg];
            cell.addBtn.tag = 1000;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        __weak typeof(self) weakSelf = self;
        CommonIntroduceCell *cell = [CommonIntroduceCell cellWithTableView:tableView didTapShowAll:^{
            
            BOOL spread = [weakSelf.introduceInfoDic[@"spread"] boolValue];
            [weakSelf.introduceInfoDic setValue:@(!spread) forKey:@"spread"];
            [weakSelf.introduceCellLayout layout];
            [weakSelf.tableView reloadData];
        }];
        cell.layout = self.introduceCellLayout;
        return  cell;
        
    }else if ([sectionTitle isEqualToString:@"工作经历"]) {
        NoInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoInfoCellID" forIndexPath:indexPath];
        cell.isMy = YES;
        [cell unAuthCellMsg];
        cell.addBtn.tag = 1004;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if ([sectionTitle isEqualToString:@"教育经历"]) {
        NoInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoInfoCellID" forIndexPath:indexPath];
        cell.isMy = YES;
        [cell unAuthCellMsg];
        cell.addBtn.tag = 1005;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if([sectionTitle containsString:@"用户分享"]){
        if (self.commentCount.integerValue == 0) {
            __weak typeof(self) weakSelf = self;
            NoCommontInfoCell *cell = [NoCommontInfoCell cellWithTableView:tableView clickAddBtn:^{
                [weakSelf enterPublishComment];
            }];
            cell.title = @"您还没有用户分享，点击发表～～";
            return cell;
            
        }
            __weak typeof(self) weakSelf = self;
            DynamicRelateCell *cell = [DynamicRelateCell cellWithTableView:tableView clickSeeMore:^{
                [weakSelf enterAllComment];
            }];
            cell.dataArr = self.commentList;
            cell.totalCount = [NSString stringWithFormat:@"共%@条用户分享",self.commentCount];
            cell.type = DynamicRelateCellTypeUser;
            cell.ID = self.unionid;
            return cell;
        
    }
    
    return [[UITableViewCell alloc]init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *sectionTitle = self.secTitleArr[indexPath.section];

    if ([sectionTitle isEqualToString:@"人物介绍"]) {
        
    }else if ([sectionTitle isEqualToString:@"工作经历"]) {
//        [self toAuthenticationPerson];
        
    } else if ([sectionTitle isEqualToString:@"教育经历"]) {
//        [self toAuthenticationPerson];
    }else if([sectionTitle containsString:@"用户分享"] && (self.commentCount.integerValue == 0) && self.isMy){
        [self enterPublishComment];
    }
}


- (void)enterPublishComment{
    if (![PublicTool userisCliamed]) {
        return;
    }
    PostActivityViewController *postVC = [[PostActivityViewController alloc]init];
    [self.navigationController pushViewController:postVC animated:YES];
    __weak typeof(self) weakSelf = self;
    postVC.postSuccessBlock = ^{
        [weakSelf requestDynamicInfo];
    };
}
- (void)enterAllComment{

    __weak typeof(self) weakSelf = self;
    [PublicTool enterActivityListControllerWithID:self.userInfoDic[@"uuid"] type:ActivityListViewControllerTypeUser model:nil refresh:^{
        [weakSelf requestDynamicInfo];
    }];
    
}


- (void)toAuthenticationPerson{
    
    [PublicTool alertActionWithTitle:@"提示" message:@"认证用户才能编辑" leftTitle:@"取消" rightTitle:@"去认证" leftAction:^{
        
    } rightAction:^{
        [[AppPageSkipTool shared] appPageSkipToClaimPage];
    }];

}

- (void)feedbackDetail:(UIButton*)sender{
    
    [self toAuthenticationPerson];
}


#pragma mark --UIScrollViewDidScroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView != self.tableView){
        return;
    }
    
    //导航
    if (scrollView.contentOffset.y > 44 ) {
        if([PublicTool isNull:_nabar.title]){
            _nabar.title = self.userInfoDic[@"nickname"];
        }
        
    }else if(scrollView.contentOffset.y < 44){
        if(![PublicTool isNull:_nabar.title]){
            _nabar.title = nil;
        }
    }
}


#pragma mark --懒加载

- (NSMutableArray *)secTitleArr{
    if (!_secTitleArr) {
        if (self.isMy) {
            _secTitleArr = [NSMutableArray arrayWithObjects:@"我发布的用户分享",@"人物介绍",@"工作经历",@"教育经历", nil];
        }else{
            _secTitleArr = [NSMutableArray arrayWithObjects:@"Ta发布的用户分享",nil];
        }
    }
    return _secTitleArr;
}

-(NSMutableArray *)commentList{
    if (!_commentList) {
        _commentList = [NSMutableArray array];
    }
    return _commentList;
}
-(NSArray *)moreOptionsArr{
    if (!_moreOptionsArr) {
        LrdCellModel *captureScreenModel = [[LrdCellModel alloc] initWithTitle:@"截长图" imageName:@"captureScreen_more1"];
        LrdCellModel *homeModel = [[LrdCellModel alloc] initWithTitle:@"回首页" imageName:@"gohome_detail"];
        LrdCellModel *kefu = [[LrdCellModel alloc] initWithTitle:@"客服" imageName:@"detail_kefu"];
       _moreOptionsArr = @[captureScreenModel,kefu,homeModel];
    }
    return _moreOptionsArr;
}

@end
