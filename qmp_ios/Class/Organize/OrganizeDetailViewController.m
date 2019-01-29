//
//  OrganizeDetailViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/6/25.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "OrganizeDetailViewController.h"
#import "OrganizeViewModel.h"
#import "JigouInvestGeneralCell.h"
#import "RelateCompanyCell.h"
#import "DetailNavigationBar.h"
#import "LrdOutputView.h"
#import "OrganizeDetailHeaderView.h"
#import "NoCommontInfoCell.h"
#import "DynamicRelateCell.h"
#import "CommonTableVwSecHeadVw.h"
#import "CommonIntroduceCell.h"
#import "JigouDetailOfficalWebCell.h"
#import "NewsTableViewCell.h"
#import "PostActivityViewController.h"
#import "OrganizeManagerViewController.h"
#import "JigouInvestmentsCaseViewController.h"
#import "JoinInvestController.h"
#import "JigouNextTargetInvestments.h"
#import "InvestmentDistributionViewController.h"
#import "RelateCompanyModel.h"
#import "RegisterInfoViewController.h"
#import "NewsWebViewController.h"
#import "RelateCompanyController.h"
#import "OneSourceViewController.h"
#import "DetailFeedBackVC.h"
#import "OrganizeInvestCaseTableCell.h"
#import "DetailMemberSectionCell.h"
#import "FAProductCell.h"
#import "JobExpriencesCell.h"
#import "MemberContactViewController.h"
#import "PersonWinExperienceVC.h"
#import "CombineTableViewCell.h"
#import "CompanyZhaopinCell.h"
#import "JointInvestmentDetailViewController.h"
#import "CompanyZhaopinController.h"
#import "ZhaopinDetailController.h"
#import "FAProductListController.h"


@interface OrganizeDetailViewController () <UITableViewDataSource, UITableViewDelegate, LrdOutputViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *requestParamDict;
@property (nonatomic, strong) dispatch_group_t group;
@property (nonatomic, strong) dispatch_group_t group2;
@property (nonatomic, strong) OrganizeViewModel *viewModel;

@property (nonatomic, strong) DetailNavigationBar *myNavBar;
//
@property (nonatomic, assign) CFAbsoluteTime startTime;

@property (nonatomic, weak) LrdOutputView *outputView;
@property (nonatomic, strong) NSMutableArray *moreOptionsArr;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) OrganizeDetailHeaderView *headerCardView;

@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, weak) UIButton *toolFollowButton;

@property (nonatomic, strong) UIImage *longScreenImage;
@property (nonatomic, assign) BOOL secondRequestFinish;

@end

@implementation OrganizeDetailViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [QMPEvent beginEvent:@"jigou_detail_timer"];
    [IQKeyboardManager sharedManager].enable = NO;
    self.tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initTableView];
    
    if ([self.requestParamDict.allKeys containsObject:@"ticket"] &&
        [self.requestParamDict.allKeys containsObject:@"id"]) {
        self.startTime = CFAbsoluteTimeGetCurrent();
        [self requestData:self.requestParamDict];
    }else{
        [PublicTool showMsg:@"数据错误"];
    }
    [QMPEvent event:@"jigou_detail_enter"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [QMPEvent endEvent:@"jigou_detail_timer"];
    [IQKeyboardManager sharedManager].enable = YES;
}
- (void)dealloc {
    QMPLog(@"%s", __func__);
}
- (void)initTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kScreenTopHeight, SCREENW, SCREENH - kScreenBottomHeight - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];

    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.tableView registerNib:[UINib nibWithNibName:@"CompanyZhaopinCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"CompanyZhaopinCellID"];

    [self.view addSubview:self.tableView];
    
    __weak typeof(self) weakSelf = self;
    DetailNavigationBar *topBar = [DetailNavigationBar detailTopBarWithRightMenuArr:self.moreOptionsArr shareEvent:^{
        [weakSelf shareEvent];
    } moreClick:^{
        [weakSelf pressRightButtonItem:nil];
    }];
    self.myNavBar = topBar;
    topBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    [self.view addSubview:topBar];
    
    self.headerCardView.height = 160;
    self.tableView.tableHeaderView = self.headerCardView;
    [self.tableView reloadData];
}

#pragma mark - Event
- (void)shareEvent {
    
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }
    OrganizeItem *organize = self.viewModel.organizeInfo;
    NSString *titleSessionStr = [NSString stringWithFormat:@"%@", organize.name];//好友标题
    NSString *titleTimelineStr = [NSString stringWithFormat:@"%@投资盘点-投资%@家公司",organize.name,organize.tzcount];//朋友圈 收藏 标题
    NSString *detailStr = nil;
    if (![PublicTool isNull:organize.tzcount]) {
        detailStr = [NSString stringWithFormat:@"%@投资盘点-投资%@家公司",organize.name,organize.tzcount];
    }else{
        detailStr = [NSString stringWithFormat:@"%@投资盘点",organize.name];
    }
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:organize.icon]];
    UIImage *image = [UIImage imageWithData:data];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"share/addUserShareLog" HTTPBody:@{@"project_id":self.viewModel.organizeInfo.ticket,@"project_type":@"jigou"} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (![PublicTool isNull:resultData[@"url_short"]]) {
            NSString *copyString = [NSString stringWithFormat:@"%@%@来自@企名片",organize.name,resultData[@"url_short"]];
            [[[ShareTo alloc]init] shareWithDetailStr:detailStr sessionTitle:titleSessionStr timelineTitle:titleTimelineStr copyString:copyString aIcon:image aOpenUrl:resultData[@"url_short"] onViewController:self shareResult:^(BOOL shareSuccess) {
                
            }];
        }
    }];
    
    [QMPEvent event:@"jigou_share_click"];
}

- (void)pressRightButtonItem:(id)sender {
    CGFloat x = SCREENW - 13;
    CGFloat y = kScreenTopHeight + 10;
    
    LrdOutputView *outputView = [[LrdOutputView alloc] initWithDataArray:self.moreOptionsArr origin:CGPointMake(x, y) viewLeftBottomLocation:CGPointMake(x, y) width:125 height:44 screenH:SCREENH direction:kLrdOutputViewDirectionRight ofAction:@"moreOptions" hasImg:YES];
    self.outputView = outputView;
    
    __weak typeof(self) weakSelf = self;
    outputView.delegate = self;
    outputView.dismissOperation = ^(){
        //设置成nil，以防内存泄露
        weakSelf.outputView = nil;
    };
    [self.outputView popFromBottom];
}

- (void)gotoPostActivity {
    if (![PublicTool userisCliamed]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    PostActivityViewController *vc = [[PostActivityViewController alloc] init];
    vc.postFrom = PostFrom_Detail;
    vc.orgnize = self.viewModel.organizeInfo;
    vc.postSuccessBlock = ^{
        [weakSelf requestCommentListAgain];
    };
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
    [QMPEvent event:@"pro_noteBtnclick"];
}
- (void)gotoPostActivityList {
    __weak typeof(self) weakSelf = self;
    [PublicTool enterActivityListControllerWithTicket:self.viewModel.organizeInfo.ticket type:ActivityListViewControllerTypeOrgnize model:self.viewModel.organizeInfo refresh:^{
        [weakSelf requestCommentListAgain];
    }];
}
- (void)gotoOrganizeTeamList {
    if (![PublicTool userisCliamed]) {
        if ([WechatUserInfo shared].claim_type.integerValue != 1) {
            [QMPEvent event:@"jigou_team_all_noclaim_alert"];
        }
        return;
    }
    OrganizeManagerViewController *vc = [[OrganizeManagerViewController alloc] init];
    vc.requestDict = [NSMutableDictionary dictionaryWithDictionary:self.urlDict];
    vc.action = @"organize";
    vc.organizeItem = self.viewModel.organizeInfo;
    [self.navigationController pushViewController:vc animated:YES];
    [QMPEvent event:@"jigou_team_allclick"];
}

- (void)gotoOrganizeTeamList2{
    
    MemberContactViewController *vc = [[MemberContactViewController alloc] init];
    vc.requestDict = [NSMutableDictionary dictionaryWithDictionary:self.urlDict];
    vc.action = @"organize";
    vc.organizeItem = self.viewModel.organizeInfo;
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
    
}
- (void)enterAllWinExperience{
    
    PersonWinExperienceVC *winVC = [[PersonWinExperienceVC alloc]init];
    winVC.jigModel = self.viewModel.organizeInfo;
    winVC.navTitleStr = [NSString stringWithFormat:@"%@获奖经历",self.viewModel.organizeInfo.name];
    winVC.formType = ExperionStyleJiGou;
    winVC.listArr = [NSMutableArray arrayWithArray:self.viewModel.organizePrizeData];
    [[PublicTool topViewController].navigationController pushViewController:winVC animated:YES];
}

- (void)gotoInvestSituation:(NSString *)title {
    if ([title isEqualToString:@"FA案例"]) {
        [self gotoFaCaseList];
    } else if ([title isEqualToString:@"投资案例"]) {
        [self gotoInvestCaseList];
    } else if ([title isEqualToString:@"战绩"]) {
        JigouNextTargetInvestments *vc = [[JigouNextTargetInvestments alloc]init];
        vc.parametersDic = self.urlDict;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"投资偏好"]) {
        InvestmentDistributionViewController *vc = [[InvestmentDistributionViewController alloc] init];
        vc.userDict = self.urlDict;
        vc.title = self.viewModel.organizeInfo.name;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"投资团队"]) {
        [self gotoOrganizeTeamList];
    }
}


- (void)enterJoinInvestVC{
  
    JoinInvestController *vc = [[JoinInvestController alloc] init];
    vc.organizeInfo = self.viewModel.organizeInfo;
    vc.urlDic = self.urlDict;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterZhaopinVC{
    CompanyZhaopinController *zhaopinVC = [[CompanyZhaopinController alloc]init];
    zhaopinVC.requestDict = [NSMutableDictionary dictionaryWithDictionary:self.urlDict];
    [[PublicTool topViewController].navigationController pushViewController:zhaopinVC animated:YES];
}

- (void)enterFAproductVC{
    FAProductListController *vc = [[FAProductListController alloc]init];
    vc.dataArr = self.viewModel.serviceCases;
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
}


- (void)newsCellLabelLongPress:(UILongPressGestureRecognizer *)longPressGest {
    
}
- (void)gotoInvestCaseList {
    // 认证限制
    if (![PublicTool userisCliamed]) {
        if ([WechatUserInfo shared].claim_type.integerValue != 1) {
            [QMPEvent event:@"jigou_tzanli_all_noclaim_alert"];
        }
        return;
    }
    JigouInvestmentsCaseViewController *jigouVC = [[JigouInvestmentsCaseViewController alloc] init];
    jigouVC.action = @"investment";
    jigouVC.parametersDic = [NSMutableDictionary dictionaryWithDictionary:self.urlDict];
    jigouVC.organizeItem = self.viewModel.organizeInfo;
    [self.navigationController pushViewController:jigouVC animated:YES];
    [QMPEvent event:@"jigou_tzanli_allclick"];
}
- (void)gotoFaCaseList {
    JigouInvestmentsCaseViewController *jigouVC = [[JigouInvestmentsCaseViewController alloc]init];
    jigouVC.action = @"fa";
    jigouVC.parametersDic = [NSMutableDictionary dictionaryWithDictionary:self.urlDict];
    jigouVC.organizeItem = self.viewModel.organizeInfo;
    [self.navigationController pushViewController:jigouVC animated:YES];
}
- (void)gotoNextPageWithTitle:(NSString *)title {
    if ([title isEqualToString:@"最新动态"]) {
        [self gotoPostActivityList];
    }else if ([title isEqualToString:@"投资团队"]) {
        [self gotoOrganizeTeamList];
    }else if ([title isEqualToString:@"FA案例"]) {
        [self gotoFaCaseList];
    }else if ([title isEqualToString:@"投资案例"]) {
        [self gotoInvestCaseList];
    }else if ([title isEqualToString:@"相关公司"]) {
        RelateCompanyController *companyVC = [[RelateCompanyController alloc]init];
        companyVC.dict = self.urlDict;
        [self.navigationController pushViewController:companyVC animated:YES];
    }else if ([title isEqualToString:@"相关新闻"]) {
        OneSourceViewController *vc = [[OneSourceViewController alloc] init];
        vc.newsMArr = [NSMutableArray arrayWithArray:self.viewModel.organizeNewsData];
        vc.action = @"OrganizesView";
        vc.requestDict = [NSMutableDictionary dictionaryWithDictionary:self.urlDict];
        vc.organizeItem = self.viewModel.organizeInfo;
        [self.navigationController pushViewController:vc animated:YES];
        [QMPEvent event:@"jigou_news_allclick"];
    }else if ([title isEqualToString:@"获奖经历"]) {
        [self enterAllWinExperience];

    }else if ([title isEqualToString:@"合投/参投机构"]) {
        [self enterJoinInvestVC];

    }else if ([title isEqualToString:@"招聘信息"]) {
        [self enterZhaopinVC];

    }else if ([title isEqualToString:@"在服项目"]) {
        [self enterFAproductVC];
    }
    
}

- (void)toolViewFollowButtonClick:(UIButton *)followButton {
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [mDict setValue:self.viewModel.organizeInfo.ticket forKey:@"ticket"];
    [mDict setValue:self.viewModel.organizeInfo.name forKey:@"project"];
    [mDict setValue:@(!self.viewModel.followed) forKey:@"work_flow"];
    [mDict setValue:@"jigou" forKey:@"type"];
    followButton.userInteractionEnabled = NO;
    [AppNetRequest attentFunctionWithParam:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if ([resultData[@"msg"] isEqualToString:@"success"]) {
            NSString * alrtMsg = self.viewModel.followed ? @"取消关注":@"关注成功";
            [PublicTool showMsg:alrtMsg];
            self.viewModel.followed = !self.viewModel.followed;
            [self toolViewFollowButtonStatusResfresh];
            
        }else{
            [PublicTool showMsg:@"失败,请重试"];
        }
        followButton.userInteractionEnabled = YES;
    }];
}
- (void)toolViewFeedbackButtonClick {
    DetailFeedBackVC *feedbackVC = [[DetailFeedBackVC alloc]init];
    feedbackVC.type = DetailFeedBackTypeOrganize;
    feedbackVC.organizeInfo = self.viewModel.organizeInfo;
    [self.navigationController pushViewController:feedbackVC animated:YES];
}
#pragma mark - LrdOutputViewDelegate
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    switch (indexPath.row) {
        case 0:{
            //截长图
            [self screenLongCut];
            break;
        }
        
            break;
//        case 1:{
//            //kefu
//            [self kefuBtnClick];
//        }
//            break;
        case 1:{
            //
            [self goHome];
        }
            break;
        default:
            break;
    }
}
- (void)screenLongCut {
    
    self.longScreenImage = [PublicTool getLongCaptureImage:self.tableView];
    
    [self sharePrintScreen];
}

- (void)sharePrintScreen {
    // 判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        if (self.longScreenImage) {
            self.longScreenImage = nil;
        }
        return;
    }
        
    [[[ShareTo alloc] init] shareDetailImage:self.longScreenImage];
}
- (void)kefuBtnClick {
    
    NSString *text = [NSString stringWithFormat:@"%@正在浏览机构【%@】时，进入客服",[WechatUserInfo shared].nickname,self.viewModel.organizeInfo.jigou_name];
    [PublicTool contactKefuMSG:text reply:kDefaultWel delMsg:YES];
    [QMPEvent event:@"jigou_kefu_click"];
}

- (void)goHome {
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDateSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowInSection:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.sectionTitles.count == 0) {
        UITableViewCell *imgCell = [tableView dequeueReusableCellWithIdentifier:@"IMGCELL"];
        if (!imgCell) {
            imgCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMGCELL"];
        }
        UIImageView *imgV = [imgCell.contentView viewWithTag:1000];
        if (!imgV) {
            imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENW*3)];
            imgV.image = [BundleTool imageNamed:@"detail_placeholder_bg"];
            imgV.tag = 1000;
            [imgCell.contentView addSubview:imgV];
            imgV.contentMode = UIViewContentModeScaleToFill;
        }
        return imgCell;
    }
    NSString *title = [self.viewModel titleOfSection:indexPath.section];
    __weak typeof(self) weakSelf = self;
    if ([title isEqualToString:@"最新动态"]) {
        if (self.viewModel.countOfActivities == 0) {
            NoCommontInfoCell *cell = [NoCommontInfoCell cellWithTableView:tableView clickAddBtn:^{
                [weakSelf gotoPostActivity];
            }];
            cell.title = @"暂无动态，点击发表～～";
            return cell;
        }
        DynamicRelateCell * cell = [DynamicRelateCell cellWithTableView:tableView clickSeeMore:^{
            [weakSelf gotoPostActivityList];
        }];
        cell.dataArr = self.viewModel.activityData;
        cell.ID = self.viewModel.organizeInfo.ticket;
        cell.type = DynamicRelateCellTypeOrganize;
        cell.totalCount = [NSString stringWithFormat:@"共%ld条动态",self.viewModel.countOfActivities];
        return cell;
    }else if ([title isEqualToString:@"机构介绍"]) {
        if (indexPath.row == 0) {
            if (self.viewModel.organizeInfo.tzcount.integerValue > 0 || self.viewModel.organizeInfo.score.length > 0) {
                JigouInvestGeneralCell *cell = [JigouInvestGeneralCell cellWithTableView:tableView];
                cell.secondRequestFinish = self.secondRequestFinish;
                cell.memberCount = [NSString stringWithFormat:@"%zd", self.viewModel.teamCount];
                cell.organizeItem = self.viewModel.organizeInfo;
                cell.clickIndex = ^(NSString *selectedStr) {
                    [weakSelf gotoInvestSituation:selectedStr];
                };
                return cell;
            }
            CommonIntroduceCell * introCell  = [CommonIntroduceCell cellWithTableView:tableView didTapShowAll:^{
                BOOL spread = [weakSelf.viewModel.introduceInfoDic[@"spread"] boolValue];
                [weakSelf.viewModel.introduceInfoDic setValue:@(!spread) forKey:@"spread"];
                weakSelf.viewModel.introduceCellLayout.introduceInfoDic = weakSelf.viewModel.introduceInfoDic;
                [weakSelf.viewModel.introduceCellLayout layout];
                [weakSelf.tableView reloadData];
            }];
            introCell.layout = self.viewModel.introduceCellLayout;
            introCell.shortUrl = self.viewModel.organizeInfo.short_url;
            return introCell;
        }else if (indexPath.row == 1) {
            if (self.viewModel.organizeInfo.tzcount.integerValue > 0 || self.viewModel.organizeInfo.score.length > 0) {
                CommonIntroduceCell * introCell  = [CommonIntroduceCell cellWithTableView:tableView didTapShowAll:^{
                    BOOL spread = [weakSelf.viewModel.introduceInfoDic[@"spread"] boolValue];
                    [weakSelf.viewModel.introduceInfoDic setValue:@(!spread) forKey:@"spread"];
                    weakSelf.viewModel.introduceCellLayout.introduceInfoDic = weakSelf.viewModel.introduceInfoDic;
                    [weakSelf.viewModel.introduceCellLayout layout];
                    [weakSelf.tableView reloadData];
                }];
                introCell.layout = self.viewModel.introduceCellLayout;
                introCell.shortUrl = self.viewModel.organizeInfo.short_url;
                return introCell;
            }
        }
        JigouDetailOfficalWebCell * webCell = [JigouDetailOfficalWebCell cellWithTableView:tableView];
        webCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [webCell setOrganize:self.viewModel.organizeInfo];
        webCell.vc = weakSelf;
        return webCell;
    }else if ([title isEqualToString:@"投资团队"]) {
        
        DetailMemberSectionCell *cell = [DetailMemberSectionCell memberSectionCellWithTableView:tableView];
        cell.memberArray = self.viewModel.organizeMember;
        return cell;
    }else if ([title isEqualToString:@"机构概况"]) {
        JigouInvestGeneralCell *cell = [JigouInvestGeneralCell cellWithTableView:tableView];
        cell.secondRequestFinish = self.secondRequestFinish;
        cell.memberCount = [NSString stringWithFormat:@"%zd", self.viewModel.teamCount];
        cell.organizeItem = self.viewModel.organizeInfo;
        cell.clickIndex = ^(NSString *selectedStr) {
            [weakSelf gotoInvestSituation:selectedStr];
        };
        return cell;
    }else if ([title isEqualToString:@"在服项目"]) {
        FAProductCell *cell = [FAProductCell cellWithTableView:tableView];
        cell.faProductM = self.viewModel.serviceCases[indexPath.row];
        return cell;
    }else if ([title isEqualToString:@"投资案例"] || [title isEqualToString:@"FA案例"]) {

        OrganizeInvestCaseTableCell *cell = [OrganizeInvestCaseTableCell cellWithTableView:tableView];
        cell.dataArray = [self.viewModel caseArrWithTitle:title];
        return cell;
    }else if ([title hasPrefix:@"合投"]) {
        OrganizeCombineItem *item = [self.viewModel togetherInvestOrganizeAtRow:indexPath.row];
        
        CombineTableViewCell *cell = [CombineTableViewCell cellWithTableView:tableView];
        [cell initData:item];
        //是合投还是参投
        NSString *name = [item.type containsString:@"combine"]?@"合投次数":@"参投项目";
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@"%@%@",name,item.count]];
        [attText addAttributes:@{NSForegroundColorAttributeName:H6COLOR,NSFontAttributeName:[UIFont systemFontOfSize:13]} range:NSMakeRange(0, attText.length)];
        [attText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:NSMakeRange(4, attText.length-4)];
        cell.countLbl.text = nil;
        cell.countLbl.attributedText = attText;
        cell.iconColor = RANDOM_COLORARR[indexPath.row%3];
        return cell;
        
    }else if ([title hasPrefix:@"相关公司"]) {
        RelateCompanyCell *cell = [RelateCompanyCell cellWithTableView:tableView];
        [cell setCompanyName:[self.viewModel relateCompanyNameAtRow:indexPath.row] titleBgColor:RANDOM_COLORARR[indexPath.row%6]];
        return cell;
    }else if ([title isEqualToString:@"相关新闻"]) {
        NewsTableViewCell *cell = [NewsTableViewCell cellWithTableView:tableView];
        cell.newsModel = [self.viewModel newsModelAtRow:indexPath.row];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(newsCellLabelLongPress:)];
        [cell.titleLbl addGestureRecognizer:longPress];
        cell.firstRow = indexPath.row == 0;
        return cell;
    }else if ([title isEqualToString:@"获奖经历"]) {
        JobExpriencesCell *cell = [JobExpriencesCell cellWithTableView:tableView];
        cell.proOrgPrizeM = self.viewModel.organizePrizeData[indexPath.row];
        if (indexPath.row == 0) { //第一个
            cell.topEdge.constant = 5;
            cell.topLine.backgroundColor = [UIColor whiteColor];
        }else{
            cell.topEdge.constant = 0;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else  if ([title isEqualToString:@"招聘信息"]) {
        //
        static NSString *cellIdentifier = @"CompanyZhaopinCellID";
        CompanyZhaopinCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.model = self.viewModel.zhaopinArr[indexPath.row];
        NSInteger lastCell = self.viewModel.zhaopinArr.count > 3 ? 2:self.viewModel.zhaopinArr.count-1;
        if (indexPath.row == lastCell) {
            cell.bottomLine.hidden = YES;
        }else{
            cell.bottomLine.hidden = NO;
        }
        if (indexPath.row == 0) {
            cell.topEdge.constant = 17;
        }else{
            cell.topEdge.constant = 10;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellID"];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel heightForRowAtIndexPath:indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.viewModel.sectionTitles.count == 0) {
        return 0.01;
    }
    if (section == 0) {
        return HEADERHEIGHT;
    }
    return HEADERHEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.viewModel.sectionTitles.count == 0) {
        return [[UIView alloc]init];
    }
    NSString *title = [self.viewModel titleOfSection:section];
    NSString *rightTitle = [self.viewModel rightTitleOfSection:section];
    __weak typeof(self) weakSelf = self;
    if ([title isEqualToString:@"最新动态"] && self.viewModel.countOfActivities != 0) {
        
        CommonTableVwSecHeadVw *headerView = [[CommonTableVwSecHeadVw alloc] initlbltitle:title leftBtnTitle:@"发布" btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
            [weakSelf gotoNextPageWithTitle:sectionTitle];
        } leftBtnClick:^{
           
                PostActivityViewController *postVC = [[PostActivityViewController alloc]init];
                postVC.postFrom = PostFrom_Detail;
                postVC.orgnize = weakSelf.viewModel.organizeInfo;
                [[PublicTool topViewController].navigationController pushViewController:postVC animated:YES];
            
                postVC.postSuccessBlock = ^{
                    //如果发布了动态 ,重新请求动态，则刷新 refreshCommentListSignal
                    [weakSelf requestCommentListAgain];
                };
        }];
        return headerView;
    }
    
    CommonTableVwSecHeadVw *commentHeader = [[CommonTableVwSecHeadVw alloc] initlbltitle:title btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
        [weakSelf gotoNextPageWithTitle:sectionTitle];
    }];
    
    return commentHeader;
    
    return [[UIView alloc]init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.000001;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     NSString *title = [self.viewModel titleOfSection:indexPath.section];

    if ([title isEqualToString:@"相关公司"]) {
        RelateCompanyModel *company = [self.viewModel relateCompanyAtRow:indexPath.row];
        if (![PublicTool isNull:company.detail]) {
            NSDictionary *dic = [PublicTool toGetDictFromStr:company.detail];
            RegisterInfoViewController *registerDetailVC = [[RegisterInfoViewController alloc] init];
            NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [mdic removeObjectForKey:@"id"];
            [mdic removeObjectForKey:@"p"];
            registerDetailVC.urlDict = mdic;
            registerDetailVC.companyName = company.company;
            [self.navigationController pushViewController:registerDetailVC animated:YES];
        }
    } else if ([title isEqualToString:@"相关新闻"]){
        //投资新闻
        NewsModel *item = [self.viewModel newsModelAtRow:indexPath.row];
        URLModel *urlModel = [[URLModel alloc] init];
        urlModel.url = item.news_detail;
        urlModel.title = item.title;
        NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
        webView.feedbackFlag = @"机构";
        webView.jigou = @{@"name":self.viewModel.organizeInfo.name?:@""};
        [self.navigationController pushViewController:webView animated:YES];
        [QMPEvent event:@"jigou_news_cellclick"];
        [QMPEvent event:@"news_webpage_enter" label:@"新闻_机构"];

        
    }else if([title isEqualToString:@"在服项目"]){
        [self enterFAProduct:indexPath];
    }else if([title isEqualToString:@"合投/参投机构"]){
        OrganizeCombineItem *item = [self.viewModel togetherInvestOrganizeAtRow:indexPath.row];
        OrganizeCombineItem *model = [[OrganizeCombineItem alloc] init];
        model.name = self.viewModel.organizeInfo.name;
        model.icon = self.viewModel.organizeInfo.icon;
        model.detail = self.viewModel.organizeInfo.detail;
        
        JointInvestmentDetailViewController *JointInvestmentDetail = [[JointInvestmentDetailViewController alloc]init];
        JointInvestmentDetail.model1 = model;
        JointInvestmentDetail.model2 = item;
        JointInvestmentDetail.title = [item.type containsString:@"combine"]?@"合投机构":@"参投机构";
        JointInvestmentDetail.action = [item.type containsString:@"combine"] ? @"AgencyDetail/agencyCombineCase470" : @"AgencyDetail/agencyTogetherCase";
        [self.navigationController pushViewController:JointInvestmentDetail animated:YES];
    }else if([title isEqualToString:@"招聘信息"]){
        
        ZhaopinDetailController *detailVC = [[ZhaopinDetailController alloc]init];
        detailVC.zhaopinM = self.viewModel.zhaopinArr[indexPath.row];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (void)enterFAProduct:(NSIndexPath *)indexPath{
    OrgFaProductModel *faProductM = self.viewModel.serviceCases[indexPath.row];
    if ([PublicTool isNull:faProductM.detail]) {
        return;
    }
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:faProductM.detail]];
}

#pragma mark - Request Data
- (void)pullDown {
    [super pullDown];
    
    [self requestData:self.requestParamDict];
}

- (BOOL)requestData:(NSMutableDictionary *)dict {
    if (![super requestData]) {
        return NO;
    }
    if (!self.viewModel.organizeInfo) {
        self.secondRequestFinish = NO;
    }
    self.group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSArray *a = @[@"requestDetailInfo:complated:",@"requestFaProduct:complated:",@"requestManager:complated:"];
    
    for (NSString *selStr in a) {
        dispatch_group_enter(self.group);
        [self dispatchRequestWithType:selStr dict:dict complated:^{
            dispatch_group_leave(self.group);
        }];
    }
    
    dispatch_group_notify(self.group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.group = nil;

            [self hideHUD];
            [self.viewModel fixSectionTitles];
            //如果section count过少，为了不显示出底部图片，用tableFooter
            if ([self.viewModel numberOfSections] < 5) {
                UIView *footerV = self.tableView.tableFooterView;
                footerV.height = 200;
            }
            
            [self.tableView reloadData];
            [self.view addSubview:self.toolView];

            self.headerCardView.lianxi = self.viewModel.lianxi;
            self.headerCardView.organize = self.viewModel.organizeInfo;
            self.headerCardView.height = self.viewModel.tableHeaderViewHeight;
            self.tableView.tableHeaderView = self.headerCardView;
            
            [self.myNavBar hideAnimator];
            
            //tableFooterV
            UIImageView *footerImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENW)];
            footerImg.image = [BundleTool imageNamed:@"detail_placeholder_second"];
            self.tableView.tableFooterView = footerImg;
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self requestNext:dict];
//            });
        
        });
    });
    

    return YES;
}
- (void)requestNext:(NSMutableDictionary *)dict{
    self.group2 = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSArray *requestArr = @[@"requestFACase:complated:",@"requestTouziExample:complated:",@"requestRelateCompany:complated:",@"requestPrizes:complated:",@"requestNews:complated:",@"requestJoinInvtest:complated:",@"requestZhaopinInfo:complated:"];
    for (NSString *selStr in requestArr) {
        dispatch_group_enter(self.group2);
        [self dispatchRequestWithType:selStr dict:dict complated:^{
            dispatch_group_leave(self.group2);
        }];
    }
    
    dispatch_group_notify(self.group2, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.group) {
                return;
            }
            self.group2 = nil;
            self.secondRequestFinish = YES;

            [self hideHUD];
            [self.viewModel fixSectionTitles];
            //如果section count过少，为了不显示出底部图片，用tableFooter
            if ([self.viewModel numberOfSections] < 5) {
                UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 200)];
                footerV.backgroundColor = [UIColor whiteColor];
                self.tableView.tableFooterView = footerV;
            }else{
                UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 50)];
                footerV.backgroundColor = [UIColor whiteColor];
                self.tableView.tableFooterView = footerV;
            }
            
            [self.tableView reloadData];
            [self.myNavBar hideAnimator];
            
        });
    });
}

- (void)dispatchRequestWithType:(NSString *)type dict:(NSMutableDictionary *)theDict complated:(void(^)(void))complated {
    SEL selector = NSSelectorFromString(type);
    ((void (*)(id, SEL, NSMutableDictionary *, void(^)(void)))[self methodForSelector:selector])(self, selector, theDict, complated);
}

- (void)requestActivityList {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"jigou" forKey:@"type"];
    [dic setValue:self.viewModel.organizeInfo.ticket forKey:@"ticket"];
    [dic setValue:@(1) forKey:@"page"];
    [dic setValue:@(12) forKey:@"num"];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/getDetailRelationList" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel handleOrganizeActivityWithResponse:resultData];
        }
        [self.tableView reloadData];
    }];
}

- (void)requestCountOfOrganize {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.viewModel.organizeInfo.ticket forKey:@"project_id"];
    [dict setValue:@"jigou" forKey:@"project_type"];
    [dict setValue:self.viewModel.organizeInfo.name forKey:@"project"];
    
    [AppNetRequest getCountOfDetailWIthParam:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel handleCommonCountWithResponse:resultData];
            [self toolViewFollowButtonStatusResfresh];
        }
    }];
}
- (void)requestCommentListAgain{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"jigou" forKey:@"type"];
    [dic setValue:self.viewModel.organizeInfo.ticket forKey:@"ticket"];
    [dic setValue:@(1) forKey:@"page"];
    [dic setValue:@(10) forKey:@"num"];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/getDetailRelationList" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel handleOrganizeActivityWithResponse:resultData];
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self scrollShowOrHiddenNavTitle:(scrollView.contentOffset.y)];
}

- (void)scrollShowOrHiddenNavTitle:(CGFloat)offsetY {
    // 导航
    if (offsetY > 44) {
        if([PublicTool isNull:self.myNavBar.title]) {
            self.myNavBar.title = self.viewModel.organizeInfo.name;
        }
    } else if (offsetY < 44) {
        
        if(![PublicTool isNull:self.myNavBar.title]) {
            self.myNavBar.title = nil;
        }
    }
}
#pragma mark - Getter
- (NSMutableDictionary *)requestParamDict {
    if (!_requestParamDict) {
        _requestParamDict = [NSMutableDictionary dictionaryWithDictionary:self.urlDict];
    }
    return _requestParamDict;
}
- (OrganizeViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OrganizeViewModel alloc] init];
    }
    return _viewModel;
}
- (NSMutableArray *)moreOptionsArr {
    if (!_moreOptionsArr) {
        LrdCellModel *jietuLongM = [[LrdCellModel alloc] initWithTitle:@"截长图" imageName:@"captureScreen_more1"];
//        LrdCellModel *kefuM = [[LrdCellModel alloc] initWithTitle:@"客服" imageName:@"detail_kefu"];
        LrdCellModel *homeM = [[LrdCellModel alloc] initWithTitle:@"回首页" imageName:@"gohome_detail"];
        _moreOptionsArr = [NSMutableArray arrayWithArray:@[jietuLongM, homeM]];
    }
    return _moreOptionsArr;
}

- (OrganizeDetailHeaderView *)headerCardView {
    if (!_headerCardView) {
        _headerCardView = [[OrganizeDetailHeaderView alloc] init];
        _headerCardView.frame = CGRectMake(0, 0, SCREENW, 0);

    }
    return _headerCardView;
}

- (UIView *)toolView {
    if (!_toolView) {
        _toolView = [[UIView alloc] init];
        _toolView.frame = CGRectMake(0, SCREENH-kScreenBottomHeight, SCREENW, kScreenBottomHeight);
        _toolView.backgroundColor = [UIColor whiteColor];
        
        CGFloat leftWidth = SCREENW*23/73;
        CGFloat itemW = (SCREENW - leftWidth)/2.0;
        CGFloat btnHeight = 49;
        
        UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, leftWidth, btnHeight)];
        leftView.backgroundColor = [UIColor whiteColor];
        [_toolView addSubview:leftView];
        
        //  客服
        UIButton *kefuBtn = [[UIButton alloc]initWithFrame:CGRectMake(8, 0,(leftWidth - 16)/2.0, btnHeight)];
        [kefuBtn setTitle:@"客服" forState:UIControlStateNormal];
        [kefuBtn setImage:[BundleTool imageNamed:@"detail_kefu_icon"] forState:UIControlStateNormal];
        [kefuBtn setTitleColor:H6COLOR forState:UIControlStateNormal];
        kefuBtn.titleLabel.font = [UIFont systemFontOfSize:9];
        [kefuBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:5];
        [kefuBtn addTarget:self action:@selector(kefuBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:kefuBtn];
    
        
        UIButton *feedBackButton = [[UIButton alloc] initWithFrame:CGRectMake(kefuBtn.right, 0, (leftWidth - 16)/2.0, btnHeight)];
        [feedBackButton setTitle:@"反馈" forState:UIControlStateNormal];
        [feedBackButton setTitleColor:COLOR737782 forState:UIControlStateNormal];
        [feedBackButton setImage:[BundleTool imageNamed:@"detail_feedback_icon"] forState:UIControlStateNormal];
        feedBackButton.titleLabel.font = [UIFont systemFontOfSize:9];
        [feedBackButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:2];
        [feedBackButton addTarget:self action:@selector(toolViewFeedbackButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:feedBackButton];
        
        // 立即联系
        UIButton *contactBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftWidth, 0, itemW, btnHeight)];
        [contactBtn buttonWithTitle:@"立即联系" image:nil titleColor:[UIColor whiteColor] fontSize:15];
        if (@available(iOS 8.2, *)) {
            contactBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        } else {
            contactBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        }
        contactBtn.backgroundColor = HTColorFromRGB(0x2292F9);
        [contactBtn addTarget:self action:@selector(gotoOrganizeTeamList2) forControlEvents:UIControlEventTouchUpInside];
        [_toolView addSubview:contactBtn];
        
        // 关注
        UIButton *followButton = [[UIButton alloc] initWithFrame:CGRectMake(contactBtn.right, 0, SCREENW-contactBtn.right, btnHeight)];
        if (@available(iOS 8.2, *)) {
            followButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        } else {
            followButton.titleLabel.font = [UIFont systemFontOfSize:15];
        }
        followButton.backgroundColor = BLUE_TITLE_COLOR;
        [followButton addTarget:self action:@selector(toolViewFollowButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.toolFollowButton = followButton;
        [self toolViewFollowButtonStatusResfresh];
        
        [_toolView addSubview:followButton];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, itemW, 0.5)];
        line.backgroundColor = LINE_COLOR;
        [_toolView addSubview:line];
    }
    return _toolView;
}

- (void)toolViewFollowButtonStatusResfresh {
    NSString *imageName = self.viewModel.followed ? @"workflow_have" : @"workflow_add";
    NSString *titleStr = self.viewModel.followed ? @"已关注":@"关注";
    [self.toolFollowButton setImage:[BundleTool imageNamed:imageName] forState:UIControlStateNormal];
    [self.toolFollowButton setTitle:titleStr forState:UIControlStateNormal];
    [self.toolFollowButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
}

#pragma mark - New Request
- (void)requestDetailInfo:(NSMutableDictionary *)dict complated:(void(^)(void))complated{

    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyBasic" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel detailModelWithResponse:resultData];
            self.viewModel.organizeInfo.ticket = self.requestParamDict[@"ticket"];
            if (!self.viewModel.organizeInfo) {
                [PublicTool showMsg:@"数据错误"];
                complated();
                return;
            }else{
                [self requestActivityList]; // 动态列表
                [self requestCountOfOrganize];
                complated();
            }
        }else{
            complated();
        }
    }];
}

- (void)requestRelateCompany:(NSMutableDictionary *)dict complated:(void(^)(void))complated{
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:dict];
    [param setValue:@"6" forKey:@"num"];
    [param setValue:@"1" forKey:@"page"];

    [AppNetRequest getRelateCompanyWithParameter:dict completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel handleRelateCompanyWithResponse:resultData];
        }
        complated();
    }];
}
- (void)requestJoinInvtest:(NSMutableDictionary *)dict complated:(void(^)(void))complated{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dict];
    [dic setValue:@(1) forKey:@"page"];
    [dic setValue:@(5) forKey:@"num"];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"agencyDetail/indexCombineTogether" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel handleTogetherOrganizeWithResponse:resultData];
        }
        complated();
    }];
}

- (void)requestFaProduct:(NSMutableDictionary *)dict complated:(void(^)(void))complated{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dict];
    [dic setValue:@(1) forKey:@"page"];
    [dic setValue:@(50) forKey:@"num"];
    [AppNetRequest getJigouFAProductWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel handleServiceCaseWithResponse:resultData];
        }
        complated();
    }];
}
- (void)requestTouziExample:(NSMutableDictionary *)dict complated:(void(^)(void))complated{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dict];
    [dic setValue:@(1) forKey:@"page"];
    [dic setValue:@(6) forKey:@"num"];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyInvestCompany470" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel handleInvestCaseWithResponse:resultData];
        }
        complated();
    }];
}

- (void)requestFACase:(NSMutableDictionary *)dict complated:(void(^)(void))complated{
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:dict];
    [param setValue:@(1) forKey:@"page"];
    [param setValue:@(6) forKey:@"num"];

    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyFaCase470" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel handleFACaseWithResponse:resultData];
        }
        complated();
    }];
}

- (void)requestManager:(NSMutableDictionary *)dict complated:(void(^)(void))complated{
    //    dict
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:dict];
    [param setValue:@(5) forKey:@"num"];
    [param setValue:@(1) forKey:@"page"];
    [param setValue:@"detail" forKey:@"from"];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyTeam" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel handleManagersWithResponse:resultData];
        }
        complated();
    }];
}

- (void)requestPrizes:(NSMutableDictionary*)dict complated:(void(^)(void))complated{
    //dict
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:dict];
    [param setValue:@(1) forKey:@"page"];
    [param setValue:@(100) forKey:@"num"];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyAwards" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel handlePrizeWithResponse:resultData];
        }
        complated();
    }];
}

- (void)requestNews:(NSMutableDictionary *)dict complated:(void(^)(void))complated{
    //dict
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:dict];
    [param setValue:@(1) forKey:@"page"];
    [param setValue:@(5) forKey:@"num"];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyNews" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel handleNewsWithResponse:resultData];
        }
        complated();
    }];
}
- (void)requestZhaopinInfo:(NSMutableDictionary*)dict complated:(void(^)(void))complated{
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:dict];
    [param setValue:@(1) forKey:@"page"];
    [param setValue:@(5) forKey:@"num"];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyRecruitInfo" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            [self.viewModel handleZhaopinInfoWithResponse:resultData];
        }
        complated();
    }];
}

@end
