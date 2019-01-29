//
//  MemberContactViewController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/10/30.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "MemberContactViewController.h"

#import "ManagerItem.h"
#import "NewsWebViewController.h"
#import "CustomAlertView.h"
#import "PersonDetailsController.h"
#import "UnauthPeresonPageController.h"
#import "ProductContactsController.h"
#import "MemberPersonCell2.h"
#import <YYTextLayout.h>
#import "InsetsLabel.h"
#import "HYNoticeView.h"
#import "EaseUI.h"


@interface MemberContactViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>


@property (strong, nonatomic) NSArray *actionArr;
@property (strong, nonatomic) NSMutableArray *tableData;

@property (strong, nonatomic) ManagerHud *hudTool;

@property (strong, nonatomic) NSMutableArray *relateStaffArr; // 相关员工

@property (nonatomic, strong) UIView * contactBgVw;
@property (nonatomic,strong) UILabel * contactShowMsgLbl;
@property (nonatomic,strong) UIButton * contactBtn;
@end

@implementation MemberContactViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    
    
    [self showHUD];
    
    NSString *title = @"";
    
    if (_action) {
        NSInteger index = [self.actionArr indexOfObject:_action];
        switch (index) {
            case 0:{
                //机构
                title = @"立即联系";
                [self requestJigouManager];
                [QMPEvent event:@"jigou_contact_click"];
                
                break;
            }
            case 1:{
                //公司
                title = @"立即联系";
                [self requestCompanyPersonConnectList];
                [QMPEvent event:@"pro_contact_click"];
                break;
            }
            default:
                break;
        }
    }
    self.title = title;
    
    self.mjFooter.stateLabel.hidden = YES;
    self.mjFooter.state = MJRefreshStateNoMoreData;
    self.tableView.mj_footer = self.mjFooter;

}


#pragma mark - FeedbackResultDelegate

- (void)FeedbackResultSuccess{
    
    [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
}

#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.1;
    
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return [[UIView alloc]init];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return self.tableData.count?self.tableData.count:1;
    }
    return self.relateStaffArr.count ? self.relateStaffArr.count:1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableData.count == 0) {
        return tableView.height;
    }

    return 75;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableData.count == 0) {
        HomeInfoTableViewCell *cell = [self nodataCellWithInfo:[self.action containsString:@"company"] ? @"该项目暂无联系人" : @"该机构暂无联系人" tableView:tableView];
        cell.createBtn.hidden = YES;
        return cell;
        
    }else{
        
        ManagerItem *item = _tableData[indexPath.row];
        MemberPersonCell2 * memberCell = [tableView dequeueReusableCellWithIdentifier:@"MemberPersonCellID" forIndexPath:indexPath];
        memberCell.isCompany = [self.actionArr indexOfObject:_action] == 1;
        memberCell.manager = item;
        memberCell.iconColor = RANDOM_COLORARR[indexPath.row%6];
        memberCell.contactButton.tag = indexPath.row + 300;
        [memberCell.contactButton addTarget:self action:@selector(contactButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        if ([_action isEqualToString:@"organize"]&& (item.is_adviser.integerValue == 1)) {
            [memberCell.statusLabel setHidden:YES];
        }
        
        if ((indexPath.row == 0) && ![USER_DEFAULTS boolForKey:@"CONTACT_INFO_CHANGE"]) {
            HYNoticeView *noticeTop = [[HYNoticeView alloc] initWithFrame:CGRectMake(SCREENW - 17-160, 55, 160, 30) text:@"私信内可交换联系方式" bgColor:H3COLOR textColor:[UIColor whiteColor] position:HYNoticeViewPositionTopRight];
            [noticeTop showType:HYNoticeTypeTestTop inView:self.view after:0 duration:0.2 options:UIViewAnimationOptionCurveEaseInOut];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [HYNoticeView hideNoticeInView:self.view];
            });
            [USER_DEFAULTS setValue:@(YES) forKey:@"CONTACT_INFO_CHANGE"];
            [USER_DEFAULTS synchronize];
        }
        return memberCell;
        
    }
}
- (void)contactButtonClick:(UIButton *)button {
    
    if(![PublicTool userisCliamed]){
        return;
    }
    ManagerItem *item = _tableData[button.tag - 300];
        
    [[AppPageSkipTool shared] appPageSkipToChatView:[NSString stringWithFormat:@"%@",item.usercode]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableData.count == 0) {
        return;
    }
    
    
    ManagerItem *item = _tableData[indexPath.row];
    
    if (![PublicTool isNull:item.person_id]) {
        [[AppPageSkipTool shared] appPageSkipToPersonDetail:item.person_id nameLabBgColor:RANDOM_COLORARR[indexPath.row%6]];
    }else if(![PublicTool isNull:item.unionids]){
        UnauthPeresonPageController *detailVC = [[UnauthPeresonPageController alloc]init];
        detailVC.unionid = item.unionids;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableData.count == 0) {
        return NO;
    }
    return YES;
    
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *preciseActionText = @"";
    
    ManagerItem *model = self.tableData[indexPath.row];
    
    if (model.isPreciseFeedback) {
        preciseActionText = @"已反馈";
    }else{
        preciseActionText = @"信息反馈";
    }
    
    UIContextualAction *isPreciseAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:preciseActionText handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        [self managerFeedBack:model];
        
    }];
    
    if (model.isPreciseFeedback) {
        isPreciseAction.backgroundColor = [UIColor lightGrayColor];
    }else{
        isPreciseAction.backgroundColor = RED_TEXTCOLOR;
    }
    
    UISwipeActionsConfiguration *action = [UISwipeActionsConfiguration configurationWithActions:@[isPreciseAction]];
    action.performsFirstActionWithFullSwipe = NO;
    return action;
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (iOS11_OR_HIGHER) {
        return @[];
        
    }
    
    NSString *preciseActionText = @"";
    
    ManagerItem *model = self.tableData[indexPath.section];
    
    if (model.isPreciseFeedback) {
        preciseActionText = @"已反馈";
    }else{
        preciseActionText = @"信息不对";
    }
    
    UITableViewRowAction *isPreciseAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:preciseActionText handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self managerFeedBack:model];
    }];
    
    if (model.isPreciseFeedback) {
        isPreciseAction.backgroundColor = [UIColor lightGrayColor];
    }else{
        isPreciseAction.backgroundColor = RED_TEXTCOLOR;
    }
    
    return @[isPreciseAction];
}


#pragma mark - 反馈
//人物反馈
- (void)managerFeedBack:(ManagerItem*)manager{
    
    NSArray *mArr = @[@"人物信息不全",@"人物信息有误",@"人物头像有误"];
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSInteger action = [self.actionArr indexOfObject:_action];
    
    switch (action) {
        case 0:{
            [mDict setValue:@"机构投资团队" forKey:@"title"];
            [mDict setValue:@"投资团队" forKey:@"type"];
            [mDict setValue:@"投资团队" forKey:@"module"];
            [mDict setValue:self.organizeItem.name forKey:@"company"];
            [mDict setValue:self.organizeItem.name forKey:@"product"];
            
            break;
        }
        case 1:{
            //公司
            [mDict setValue:@"公司团队" forKey:@"title"];
            
            [mDict setValue:@"公司团队" forKey:@"type"];
            [mDict setValue:@"公司团队" forKey:@"module"];
            [mDict setValue:self.companyItem.company forKey:@"company"];
            [mDict setValue:self.companyItem.product forKey:@"product"];
            
            break;
        }
        default:
            break;
    }
    
    
    [mDict setValue:@"" forKey:@"c1"];
    [mDict setValue:manager.name forKey:@"managerName"];
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:self.view.frame WithAlertViewHeight:0 infoDic:(NSDictionary *)mDict viewcontroller:self moduleNum:self.tableData.count isFeeds:NO];
    
}


#pragma mark - public
-(void)buildRightBarButtonItem{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"反馈" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(feedbackDetail:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)feedbackDetail:(UIButton *)sender{
    
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        id first = objc_getAssociatedObject(sender, "feedbackDetail");
        UIView *view = (UIView *)first;
        CGRect frame = view.frame;
        CGFloat height = 65;
        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息
        NSInteger moduleNum = 0;
        
        if (self.companyItem) {
            [infoDic setValue:@"公司团队" forKey:@"title"];//模块
            [infoDic setValue:@"公司团队" forKey:@"module"];//模块
            if (![PublicTool isNull:_companyItem.product]) {
                [infoDic setValue:_companyItem.product forKey:@"product"];
            }else{
                [infoDic setValue:@"" forKey:@"product"];
            }
            if (![PublicTool isNull:_companyItem.company]) {
                [infoDic setValue:_companyItem.company forKey:@"company"];
            }else{
                [infoDic setValue:@"" forKey:@"company"];
            }
        }else if (self.organizeItem){
            [infoDic setValue:@"投资团队" forKey:@"title"];//模块
            [infoDic setValue:@"投资团队" forKey:@"module"];//模块
            if (![PublicTool isNull:self.organizeItem.name]) {
                [infoDic setValue:self.organizeItem.name forKey:@"product"];
            }else{
                [infoDic setValue:@"" forKey:@"product"];
            }
            if (![PublicTool isNull:self.organizeItem.name]) {
                [infoDic setValue:self.organizeItem.name forKey:@"company"];
            }else{
                [infoDic setValue:@"" forKey:@"company"];
            }
        }
        
        if (_tableData) {
            if (_tableData.count>0) {
                [mArr addObject:@"团队成员不全"];
                [mArr addObject:@"成员信息不全"];
                [mArr addObject:@"成员信息不对"];
                moduleNum = _tableData.count;
            }
        }
        if (_tableData.count<=0||!_tableData||![_tableData isKindOfClass:[NSArray class]]) {
            [mArr addObject:@"团队缺失"];
            moduleNum = 0;
        }
        
        if (mArr.count>0) {
            height += ((mArr.count-1)/2+1)*35 + 55.f;
        }
        
        [self feedbackAlertView:mArr frame:frame WithAlertViewHeight:height moduleDic:infoDic moduleNum:moduleNum];
    }
}

- (void)feedbackAlertView:(NSMutableArray *)mArr frame:(CGRect)frame WithAlertViewHeight:(CGFloat)height moduleDic:(NSDictionary *)infoDic moduleNum:(NSInteger)num{
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:frame WithAlertViewHeight:height infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:num isFeeds:NO];
}

- (void)initTableView{
    
    CGFloat tableHeight = SCREENH - kScreenTopHeight - kScreenBottomHeight;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, tableHeight) style:UITableViewStyleGrouped];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.mj_header = self.mjHeader;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MemberPersonCell2" bundle:nil] forCellReuseIdentifier:@"MemberPersonCellID"];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.contactBgVw];
    
}

- (void)pullDown{
    self.currentPage = 1;
    self.tableView.mj_footer = nil;
    
    if (_action) {
        NSInteger index = [self.actionArr indexOfObject:_action];
        switch (index) {
            case 0:{
                //机构
                [self requestJigouManager];
                
                break;
            }
            case 1:{
                //公司
                [self requestCompanyPersonConnectList];

                break;
            }
            default:
                break;
        }
    }
}

/**
 左滑反馈 团队
 
 @param managerModel
 */
- (void)mgsingleImmediateFeedbackUs:(ManagerItem *)managerModel{
    
    if (!managerModel.isPreciseFeedback&&!managerModel.isOverallFeedback) {
        return;
    }
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        
        NSArray *managerArr = self.tableData;
        NSMutableString *desc = [NSMutableString stringWithCapacity:0];
        if (managerModel.isPreciseFeedback) {
            [desc appendString:@"信息不准"];
            if (managerModel.isOverallFeedback) {
                [desc appendString: @"|信息不全"];
            }
        }else{
            if (managerModel.isOverallFeedback) {
                [desc appendString: @"信息不全"];
            }
        }
        
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        if (self.organizeItem) {
            [mDict setValue:@"机构团队" forKey:@"type"];
        }else if (self.companyItem){
            [mDict setValue:@"公司团队" forKey:@"type"];
        }
        [mDict setValue:@"" forKey:@"c1"];
        [mDict setValue:[NSString stringWithFormat:@"%ld",(unsigned long)managerArr.count] forKey:@"c2"];
        [mDict setValue:managerModel.name forKey:@"c3"];
        if (self.companyItem) {
            [mDict setValue:self.companyItem.company forKey:@"company"];
            [mDict setValue:self.companyItem.product forKey:@"product"];
        }else if (self.organizeItem){
            [mDict setValue:self.organizeItem.name forKey:@"company"];
            [mDict setValue:self.organizeItem.name forKey:@"product"];
        }
        
        [mDict setValue:desc forKey:@"desc"];
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/editcommonfeedback" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
        }];
    }
}

/**
 跳转到百度
 
 @param key
 */
- (void)enterToBaidu:(NSString *)key{
    
    URLModel *urlModel = [[URLModel alloc]init];
    urlModel.url = [NSString stringWithFormat:@"https://m.baidu.com/s?word=%@",[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
    webView.fromVC = @"baidu";
    [self.navigationController pushViewController:webView animated:YES];
    
}

#pragma mark 立即联系公司团队
- (void)requestCompanyPersonConnectList{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        NSDictionary *dict = @{@"product_id": self.companyItem.product_id?:@""};
        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Product/showProductContacts" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            if (resultData && [resultData isKindOfClass:[NSArray class]]) {
                NSArray *managerArr = resultData;
                NSMutableArray *managerMArr = [NSMutableArray array];
                for (NSDictionary *managerDict in managerArr) {
                    ManagerItem *manager = [[ManagerItem alloc] initWithDictionary:managerDict error:nil];
                    if (manager.person_type.integerValue == 1) {
                        [managerMArr insertObject:manager atIndex:0];
                    } else {
                        [managerMArr addObject:manager];
                    }
                }
                self.tableData = [NSMutableArray arrayWithArray:managerMArr];
                [self refreshFooter:@[]];
                [self.tableView reloadData];
            }
        }];
    }
}
#pragma mark - 请求机构团队
- (void)requestJigouManager{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        NSString *debug = self.tableView.mj_header.isRefreshing ? @"1":@"0";
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.requestDict];
        [param setValue:debug forKey:@"debug"];
//        [param setValue:@(self.currentPage) forKey:@"page"];
//        [param setValue:@(499) forKey:@"num"];

        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyTeamClaim" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
           
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];

            if (resultData) {
                
                NSArray *managerArr = resultData[@"list"];
                
                NSMutableArray *managerMArr = [NSMutableArray array];
                for (NSDictionary *managerDict in managerArr) {
                    ManagerItem *manager = [[ManagerItem alloc] initWithDictionary:managerDict error:nil];
                    [managerMArr addObject:manager];
                }
                if (self.currentPage == 1) {
                    [self.tableData removeAllObjects];
                }
                [self.tableData addObjectsFromArray:managerMArr];
                [self refreshFooter:@[]];
                [self.tableView reloadData];
            
            }
        }];
    }
    
}


#pragma mark 委托联系
- (void)getContact{
    if ([self.contactBtn.titleLabel.text isEqualToString:@"今日已委托"]) {
        [PublicTool showMsg:@"今日已委托，请耐心等待结果"];
        return;
    }
    if ([self.contactBtn.titleLabel.text isEqualToString:@"已委托"]) {
        ProductContactsController *cardVC = [[ProductContactsController alloc]init];
        [self.navigationController pushViewController:cardVC animated:YES];
        return;
    }
    if (![PublicTool userisCliamed]) {
        return ;
    }
    
    [self requestLeftCount];

    
    [QMPEvent event:@"pro_contactBtnClick"];
}

- (void)requestLeftCount{
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"f/getUserAuthCount" HTTPBody:@{} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData) {
            
            NSString *leftCount = resultData[@"left_entrust_count"];
            NSString *message;
            BOOL haveChance = leftCount.integerValue > 0;
            
            if (!leftCount || leftCount.intValue == 0) {
                message = @"您的委托联系机会已用完\n请明日再来";
            }else{
                message = [NSString stringWithFormat:@"今日还剩%@次免费机会",leftCount];
            }
            
            if (haveChance) {
                [PublicTool alertActionWithTitle:@"提示" message:message leftTitle:@"取消" rightTitle:@"委托联系" leftAction:^{
                    
                } rightAction:^{
                    [self contactInfo];
                }];
            }else{
                [PublicTool alertActionWithTitle:@"提示" message:message leftTitle:@"取消" rightTitle:@"委托联系" leftActionClick:^{
                    
                } rightActionClick:^{
                    
                } leftEnable:YES rightEnable:NO];
            }
            
        }else{
            
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
}

- (void)gotoClaim{    
    [[AppPageSkipTool shared] appPageSkipToClaimPage];
}

- (void)contactInfo{
    
    [PublicTool showHudWithView:KEYWindow];
    //项目和机构
    if ([self.action containsString:@"company"]) {
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/getProductContact" HTTPBody:@{@"product_id":self.companyDetail.company_basic.product_id} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

            [PublicTool dismissHud:KEYWindow];
            if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
                [self refreshContactBtn];
            }else if(resultData[@"msg"]){
                [PublicTool showMsg:resultData[@"msg"]];
            }
        }];
    }else{ //机构
        
        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Entrust/getAgencyContact" HTTPBody:@{@"ticket":self.organizeItem.ticket} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [PublicTool dismissHud:KEYWindow];
            if (resultData && resultData[@"left_count"]) {
                [self refreshContactBtn];
            }else if(resultData[@"msg"]){
                [PublicTool showMsg:resultData[@"msg"]];
            }
        }];
    }
}

- (void)refreshContactBtn{
    [PublicTool alertActionWithTitle:@"委托成功" message:@"委托结果稍后通过短信通知您，您也可以在[我的][委托联系]中查看委托结果" btnTitle:@"我知道了" action:nil];
    [self.contactBtn setTitle:@"今日已委托" forState:UIControlStateNormal];
    if ([self.action containsString:@"company"]) {
        self.companyDetail.obtain_status = @"3";
    }else{
        self.organizeItem.entrust_state = @"3";
    }
    [self.contactBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:5];
}

#pragma mark 懒加载
- (UIView *)contactBgVw{
    if (_contactBgVw == nil) {
        CGRect bgIframe = CGRectMake(0, SCREENH - kScreenTopHeight - kScreenBottomHeight, SCREENW, kScreenBottomHeight);
        _contactBgVw = [[UIView alloc] initWithFrame:bgIframe];
        [_contactBgVw addSubview:self.contactShowMsgLbl];
        [_contactBgVw addSubview:self.contactBtn];
        
        _contactBgVw.backgroundColor = [UIColor whiteColor];
        _contactBgVw.layer.shadowColor = H9COLOR.CGColor;
        _contactBgVw.layer.shadowOpacity = 0.2;
        _contactBgVw.layer.shadowRadius = 3;
        _contactBgVw.layer.shadowOffset = CGSizeMake(0, 0);
    }
    return _contactBgVw;
}
- (UILabel *)contactShowMsgLbl{
    if (_contactShowMsgLbl == nil) {
        CGRect lblIframe = CGRectMake(15, (kScreenBottomHeight-16)/2.0, 200, 16);
        _contactShowMsgLbl = [[UILabel alloc] initWithFrame:lblIframe];
        _contactShowMsgLbl.font = [UIFont systemFontOfSize:14];
        _contactShowMsgLbl.textColor = HTColorFromRGB(0x666666);
        if ([self.action containsString:@"company"]) {
            _contactShowMsgLbl.text = @"快速联系项目团队？";
        }else{
            _contactShowMsgLbl.text = @"快速联系机构团队？";
        }
    }
    return _contactShowMsgLbl;
}
- (UIButton *)contactBtn{
    if (_contactBtn == nil) {
        _contactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _contactBtn.frame = CGRectMake(SCREENW - 140 - 15, (kScreenBottomHeight-32)/2.0, 140, 32);
        _contactBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _contactBtn.layer.cornerRadius = _contactBtn.height / 2.0;
        if ([self.action containsString:@"company"]) {
            if (self.companyDetail.obtain_status && (self.companyDetail.obtain_status.integerValue == 2)) { //委托成功
                [self.contactBtn setTitle:@"已委托" forState:UIControlStateNormal];
            }else  if (self.companyDetail.obtain_status && (self.companyDetail.obtain_status.integerValue == 3)) { //今日已委托
                [self.contactBtn setTitle:@"今日已委托" forState:UIControlStateNormal];
            }else if (!self.companyDetail.obtain_status || (self.companyDetail.obtain_status.integerValue == 1)) { //还没委托
                [self.contactBtn setTitle:@"委托联系该项目" forState:UIControlStateNormal];
            }else{
                
            }
        }else{
            if (self.organizeItem.entrust_state && (self.organizeItem.entrust_state.integerValue == 2)) { //委托成功
                [self.contactBtn setTitle:@"已委托" forState:UIControlStateNormal];
            }else  if (self.organizeItem.entrust_state && (self.organizeItem.entrust_state.integerValue == 3)) { //今日已委托
                [self.contactBtn setTitle:@"今日已委托" forState:UIControlStateNormal];
            }else if (!self.organizeItem.entrust_state || (self.organizeItem.entrust_state.integerValue == 1)) { //还没委托
                [_contactBtn setTitle:@"委托联系该机构" forState:UIControlStateNormal];
            }else{
                
            }
        }
        [_contactBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_contactBtn setBackgroundColor:BLUE_BG_COLOR];
        
        [_contactBtn addTarget:self action:@selector(clickEntrustContact) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _contactBtn;
}

#pragma mark 委托联系
- (void)clickEntrustContact{
    [self getContact];
}
#pragma mark --懒加载
- (NSMutableArray *)tableData{
    if (!_tableData) {
        _tableData = [NSMutableArray array];
    }
    return _tableData;
}

- (NSArray *)actionArr{
    
    if (!_actionArr) {
        _actionArr = @[@"organize",@"company"];
    }
    return _actionArr;
}

- (ManagerHud *)hudTool{
    
    if (!_hudTool) {
        _hudTool = [[ManagerHud alloc] init];
    }
    return _hudTool;
}

@end
