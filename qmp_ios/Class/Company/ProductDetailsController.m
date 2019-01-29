//
//  ProductDetailsController.m
//  qmp_ios
//
//  Created by QMP on 2018/6/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductDetailsController.h"
#import "NewsWebViewController.h"
#import "GetProductsFromTagsViewController.h"
#import "CompanyBasicInfoTableViewCell.h"
#import "NewsTableViewCell.h"
#import "DetailTagsCell.h"
#import "TagEditController.h"
#import "NewsModel.h"
#import "ZhaopinModel.h"
#import "TagsFrame.h"
#import "ManagerAlertView.h"
#import "RegisterInfoViewController.h"
#import "CustomAlertView.h"
#import "LrdOutputView.h"//右上更多选项菜单
#import "CompanyDetailModel.h"
#import "CompanyZhaopinController.h"
#import "IpoInfoCell.h"
#import "CompanyZhaopinCell.h"
#import "ZhaopinDetailController.h"
#import "PersonAllBusinessRoleController.h"
#import "CompanyInvestorsController.h"
#import "CompanyFinancialViewController.h"
#import "CompanyInfoView.h"
#import "ProductTableHeadView.h"
#import "ProductDetailViewModel.h"
#import "ProductYewuCell.h"
#import "DynamicRelateCell.h"
#import "CommonTableVwSecHeadVw.h"
#import "CommonIntroduceCell.h"
#import "ProRegisterCell.h"
#import "DetailFeedBackVC.h"
#import "DetailNavigationBar.h"
#import "NoCommontInfoCell.h"
#import "ProductRongziCell.h"
#import "NoteEditController.h"
#import "HYNoticeView.h"
#import "DetailMemberSectionCell.h"
#import "ProductValueActivityCell.h"
#import "ActivityLayout.h"
#import "ActivityModel.h"
#import "ActivityDetailViewController.h"
#import "ProductAppListCell.h"
#import "ProductAppDataViewController.h"
#import "ProInvestorCell.h"
#import "JobExpriencesCell.h"
#import "ClaimCell.h"


@interface ProductDetailsController ()<UITableViewDelegate,
UITableViewDataSource,LrdOutputViewDelegate,ShareDelegate,ManagerAlertDelegate,SPPageMenuDelegate,UIScrollViewDelegate>
{
    CGFloat _beginDragY;
    
    TagEditController *_tagVC;
}

@property(nonatomic, strong) NSMutableArray *groupArr; //请求小组
@property(nonatomic, assign) BOOL fromClaimCompany; //从认领项目页返回
@property(nonatomic, strong) ManagerAlertView *alertView;
@property (strong, nonatomic) UIView *toolView;//底部关注/反馈
@property (strong, nonatomic) UIButton *flowToolBtn;
@property (strong, nonatomic) UIButton *albumToolBtn; //专辑

@property (strong, nonatomic) UIButton *toolFeedbackBtn;

@property (strong, nonatomic) UIButton *aboveFlowBtn;//工作流
@property (strong, nonatomic) NSDictionary *registImageDic;
@property (strong, nonatomic) NSDictionary *workFlowDict;
@property (nonatomic, strong) LrdOutputView *outputView;//导航条右上角菜单
@property (nonatomic, strong) NSArray *moreOptionsArr;//更多选项
@property (nonatomic, strong) NSMutableArray *basicInfoCellInfoArr;
@property (nonatomic, strong) ShareTo *shareToTool;

@property(nonatomic,strong) NSMutableArray *sectionTitleArr;
@property(nonatomic,strong)UIView *commentBar;
@property(nonatomic,strong)UIButton *commentBtn;

@property(nonatomic,strong)ProductTableHeadView *tableHeadView;
@property(nonatomic,strong)ProductDetailViewModel *viewModel;
@property(nonatomic,strong)DetailNavigationBar *nabar;


@end

@implementation ProductDetailsController
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [QMPEvent endEvent:@"pro_detail_timer"];
    [IQKeyboardManager sharedManager].enable = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.backgroundColor = [UIColor whiteColor];

    if (self.viewModel.companyDetail.rz_flag.integerValue == 1) {
        self.viewModel.needModel = nil;
    }

    [QMPEvent beginEvent:@"pro_detail_timer"];
    [self.tableView reloadData];
    [IQKeyboardManager sharedManager].enable = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = nil;
    self.view.backgroundColor = [UIColor whiteColor];
    self.currentPage = 1;
    self.numPerPage = 20;
    [self initTableView];
    [self initTableHeaderView];

    if ([self.urlDict.allKeys containsObject:@"ticket"] && [self.urlDict.allKeys containsObject:@"id"]) {
        [self requestData];
    }else{
        [PublicTool showMsg:@"数据错误"];
    }
    [QMPEvent event:@"pro_enterDetail"];
}

- (void)dealloc
{
    NSLog(@"__%s__", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - ShareDelegate
- (void)shareSuccess{
    
    _printscreenImage = nil;
    [ShowInfo showInfoOnView:self.view withInfo:@"分享成功"];
}

- (void)shareFaild{
    
    _printscreenImage = nil;
    [ShowInfo showInfoOnView:self.view withInfo:@"分享取消"];
}

#pragma mark - AllFeedbackViewDelegate
- (void)feedbackSuccess{
    [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
}
#pragma mark - UpdateRegisterInfoDelegate
- (void)UpdateRegisterInfo{
    [self requestData];
}

#pragma mark - LrdOutputViewDelegate 代理方法
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    if (!self.viewModel.companyDetail) {
        return;
    }
    switch (indexPath.row) {
        case 0:{
            //截长图
            [self screenLongCut];
            break;
        }
        case 1:{ //写笔记
            [self addNoteEvent];
        }
            break;
        case 2:{ //加专辑
            [self enterAlbumEdit];
        }
            break;
//        case 3:{
//            //kefu
//            [self kefuBtnClick];
//        }
//            break;
        case 3:{
            //
            [self goHome];
        }
            break;
        default:
            break;
    }
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionTitleArr.count?:1;;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.sectionTitleArr.count == 0) {
        return 1;
    }
    NSString *sectionTitle = self.sectionTitleArr[section];
    if ([sectionTitle isEqualToString:@"融资历史"]) {
        return self.viewModel.companyDetail.company_rongzi.count;
    }else  if ([sectionTitle isEqualToString:@"团队成员"]) {
        return 1;
    }else  if ([sectionTitle isEqualToString:@"相关新闻"]) {
        return MIN(3,self.viewModel.newsArr.count);
    }else  if ([sectionTitle isEqualToString:@"公司业务"]) {
        return 1 ;
    }else  if ([sectionTitle isEqualToString:@"相似项目"]) {
        return 1;
    }else if([sectionTitle isEqualToString:@"项目介绍"]){
        return self.basicInfoCellInfoArr.count;
    }else if([sectionTitle isEqualToString:@"最新动态"]){
        return 1;
        
    }else  if ([sectionTitle isEqualToString:@"招聘信息"]) {
        return MIN(3,self.viewModel.zhaopinArr.count);
    }else if([sectionTitle isEqualToString:@"App数据"]){
        return MIN(self.viewModel.apps.count,3);
    }else if([sectionTitle isEqualToString:@"投资人"]){
        if ([WechatUserInfo shared].claim_type.integerValue != 2) {
            return 1;
        }
        return MIN(self.viewModel.investorsArr.count,3);
    }else if([sectionTitle isEqualToString:@"获奖经历"]){
        return MIN(self.viewModel.prizeArr.count,3);
    }
    
    return 1;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sectionTitleArr.count == 0) {
        return SCREENW *3;
    }
    NSString *sectionTitle = self.sectionTitleArr[indexPath.section];
    if ([sectionTitle isEqualToString:@"证券信息"]) {
        return self.viewModel.companyDetail.company_basic.allipo.count*(14+25)+15;
        
    }else  if ([sectionTitle isEqualToString:@"融资需求"]) {
        return 35.0f;
        
    }else if ([sectionTitle isEqualToString:@"融资历史"]) {
        
        CompanyDetailRongziModel *model = self.viewModel.companyDetail.company_rongzi[indexPath.row];
        
        CGFloat height = [tableView fd_heightForCellWithIdentifier:@"ProductRongziCellID" configuration:^(ProductRongziCell *cell) {
            [cell initData:model];
        }];
        return height;
        
    }else  if ([sectionTitle isEqualToString:@"团队成员"]) {//公司团队成员
        if (self.viewModel.companyDetail.company_team.count > 3) {
            return 82*3+10;
        }
        return self.viewModel.companyDetail.company_team.count * 82+10;
    
    }else  if ([sectionTitle isEqualToString:@"相关新闻"]) {
        //公司相关新闻
        return 57;

    }else  if ([sectionTitle isEqualToString:@"公司业务"]) {
        //公司业务
        return self.viewModel.companyDetail.company_business.count >= 3 ? 68*3 : (self.viewModel.companyDetail.company_business.count*68);
        
    }else  if ([sectionTitle isEqualToString:@"相似项目"]) {
        //相似项目
        return self.viewModel.similarArr.count >= 3 ? 68*3 : (self.viewModel.similarArr.count * 68);

    }else if([sectionTitle isEqualToString:@"项目画像"]){
        //项目画像
        return self.viewModel.tagsFrame.tagsHeight-10.5;

    }else if([sectionTitle isEqualToString:@"项目介绍"]){
        if (indexPath.row == 0) {
            return self.viewModel.introduceCellLayout.cellHeight;
        }else{
            NSString *key = self.basicInfoCellInfoArr[indexPath.row];
            if([key isEqualToString:@"法人代表"] || [key isEqualToString:@"公司官网"] || [key isEqualToString:@"公司名称"]){
                
                NSString *title = [key isEqualToString:@"公司官网"] ? self.viewModel.companyDetail.company_basic.gw_link:([key isEqualToString:@"法人代表"] ? self.viewModel.companyDetail.company_basic.faren:self.viewModel.companyDetail.company_basic.company);
                CGFloat width = (SCREENW-107);
                CGFloat height = [title boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.height+1;
                if (height < 34) {
                    return 24;
                }
                return 44.f;
            }else{
                return 24;
            }
        }
    }else if([sectionTitle isEqualToString:@"最新动态"]){
        if (self.viewModel.commentLayouts.count == 0) {
            return 45;
        }
        ActivityLayout *layout = self.viewModel.commentLayouts.firstObject;
        return layout.textLayout.textBoundingSize.height + 45;
        
    }else  if ([sectionTitle isEqualToString:@"招聘信息"]) {
        if (indexPath.row == 0) {
            return 65;
        }
        return 58;
    }else  if ([sectionTitle isEqualToString:@"工商信息"]) {
        return 70;
    } else if ([sectionTitle isEqualToString:@"App数据"]) {
        return 95;
    } else if([sectionTitle isEqualToString:@"投资人"]){
        if ([WechatUserInfo shared].claim_type.integerValue != 2) {
            return 180+15;
        }
        return 85;
    }else if ([sectionTitle isEqualToString:@"获奖经历"]) {
        WinExperienceModel *winM = self.viewModel.prizeArr[indexPath.row];
        CGFloat height = [PublicTool heightOfString:winM.prize_name width:SCREENW-56-17 font:[UIFont systemFontOfSize:15]];
        if (indexPath.row == 0) {
            return height+50;
        }
        return height+40;
    }
    
    return 0.1f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sectionTitleArr.count == 0) {
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
    
    NSString *sectionTitle = self.sectionTitleArr[indexPath.section];
    if ([sectionTitle isEqualToString:@"证券信息"]) {
        
        IpoInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IpoInfoCellID" forIndexPath:indexPath];
        cell.companyModel = self.viewModel.companyDetail;
        cell.requetDict = [NSMutableDictionary dictionaryWithDictionary:self.urlDict];
        cell.arr = self.viewModel.companyDetail.company_basic.allipo;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if ([sectionTitle isEqualToString:@"融资历史"]) {
        
        ProductRongziCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductRongziCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CompanyDetailRongziModel *model = self.viewModel.companyDetail.company_rongzi[indexPath.row];
        cell.firstRow = indexPath.row == 0 ;
        cell.lastRow = indexPath.row == self.viewModel.companyDetail.company_rongzi.count-1;
        [cell initData:model];
        
        if (indexPath.row == self.viewModel.companyDetail.company_rongzi.count - 1) {
            cell.lineView.hidden = YES;
        }else{
            cell.lineView.hidden = NO;
        }
        return cell;
        
    }else  if ([sectionTitle isEqualToString:@"团队成员"]) {
        DetailMemberSectionCell *cell = [DetailMemberSectionCell memberSectionCellWithTableView:tableView];
        cell.memberArray = self.viewModel.companyDetail.company_team;
        return cell;
        
    }else if ([sectionTitle isEqualToString:@"相关新闻"]) {

        //公司相关新闻
        static NSString *cellIdentifier = @"NewsTableViewCellID";
        NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        NewsModel *newsModel = self.viewModel.newsArr[indexPath.row];
        cell.newsModel = newsModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       
        //长按复制
        UILongPressGestureRecognizer *longNews = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressJianjieLbl:)];
        [cell.titleLbl addGestureRecognizer:longNews];
        return cell;
        
    }else  if ([sectionTitle isEqualToString:@"公司业务"]) {
        ProductYewuCell *cell = [ProductYewuCell cellWithTableView:tableView];
        cell.dataArray = self.viewModel.companyDetail.company_business;
        return cell;
        
    }else  if ([sectionTitle isEqualToString:@"相似项目"]) {
        
        ProductYewuCell *cell = [ProductYewuCell cellWithTableView:tableView];
        cell.dataArray = self.viewModel.similarArr;
        __weak typeof(self) weakSelf = self;
        return cell;
    }else if([sectionTitle isEqualToString:@"项目画像"]){
        __weak typeof(self) weakSelf = self;
        DetailTagsCell *cell = [DetailTagsCell cellWithTableView:tableView tagString:self.viewModel.companyDetail.company_basic.tags isCompany:YES clickShrinkTag:^(BOOL isSpread, TagsFrame *tagFrame) {
            weakSelf.viewModel.tagIsSpread = isSpread;
            weakSelf.viewModel.tagsFrame = tagFrame;
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[weakSelf.sectionTitleArr indexOfObject:@"项目画像"]-1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } clickAddTag:^{
            [weakSelf clickAddTag];
        } clickTag:^(NSString *tag) {
            [weakSelf clickTag:tag];
        }];
        
        return cell;

    }else if([sectionTitle isEqualToString:@"项目介绍"]){
        if (indexPath.row == 0) {
            __weak typeof(self) weakSelf = self;
            CommonIntroduceCell *cell = [CommonIntroduceCell cellWithTableView:tableView didTapShowAll:^{
                BOOL spread = [weakSelf.viewModel.introduceInfoDic[@"spread"] boolValue];
                [weakSelf.viewModel.introduceInfoDic setValue:@(!spread) forKey:@"spread"];
                [weakSelf.viewModel.introduceCellLayout layout];
                [UIView performWithoutAnimation:^{
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }];
            }];
            cell.shortUrl = self.viewModel.companyDetail.company_basic.short_url;
            cell.layout = self.viewModel.introduceCellLayout;
            return cell;
        }else{
            static NSString *cellIdentifier = @"basicInfoCell";
            CompanyBasicInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[CompanyBasicInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            cell.model = self.viewModel.companyDetail.company_basic;
            [cell dataWithKey:self.basicInfoCellInfoArr[indexPath.row] withValue:self.viewModel.companyDetail.company_basic];
            
            UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressInfoLbl:)];
            [cell.infoLbl addGestureRecognizer:touch];
            cell.infoLbl.userInteractionEnabled = YES;
            return cell;
        }
        
    }else if([sectionTitle isEqualToString:@"最新动态"]){
        if (self.viewModel.commentLayouts.count == 0) {
            __weak typeof(self) weakSelf = self;
            NoCommontInfoCell *cell = [NoCommontInfoCell cellWithTableView:tableView clickAddBtn:^{
                [weakSelf.viewModel.publishCommentCommand execute:nil];
            }];
            cell.title = @"暂无动态，点击发表～～";
            return cell;
        }
        __weak typeof(self) weakSelf = self;
        DynamicRelateCell *cell = [DynamicRelateCell cellWithTableView:tableView clickSeeMore:^{
            [weakSelf.viewModel.enterSecondPageCommand execute:@"最新动态"];
        }];
        cell.dataArr = self.viewModel.commentLayouts;
        cell.totalCount = [NSString stringWithFormat:@"共%@条动态",self.viewModel.sectionDataCountDic[@"最新动态"]];
        cell.ID = self.viewModel.companyDetail.company_basic.product_id;
        cell.type = DynamicRelateCellTypeProduct;
        return cell;
        
    }else  if ([sectionTitle isEqualToString:@"招聘信息"]) {
        //
        static NSString *cellIdentifier = @"CompanyZhaopinCellID";
        CompanyZhaopinCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.model = self.viewModel.zhaopinArr[indexPath.row];
        NSInteger lastCell = self.viewModel.newsArr.count > 3 ? 2:self.viewModel.newsArr.count-1;
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
    }else  if ([sectionTitle isEqualToString:@"工商信息"]) {
        __weak typeof(self) weakSelf = self;
        ProRegisterCell *cell = [ProRegisterCell cellWithTableView:tableView titles:self.viewModel.registInfoMenusArr images:[self registInfoCellImages]  didSelectedItem:^(NSString *title) {
            [weakSelf enterRegistController:title];
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if ([sectionTitle isEqualToString:@"App数据"]) {
        ProductAppListCell *cell = [ProductAppListCell cellWithTableView:tableView];
        cell.appInfo = self.viewModel.apps[indexPath.row];
        return cell;

    } else if([sectionTitle isEqualToString:@"投资人"]){
        if ([WechatUserInfo shared].claim_type.integerValue != 2) {
            ClaimCell *claimCell = [ClaimCell cellWithTableView:tableView tipInfo:@"成为认证用户，即可查看项目投资人" showbgImg:YES];
            return claimCell;
        }
        ProInvestorCell *cell = [ProInvestorCell cellWithTableView:tableView];
        PersonModel *person = self.viewModel.investorsArr[indexPath.row];
        cell.person = person;
        cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
        return cell;
    }else if ([sectionTitle isEqualToString:@"获奖经历"]) {
        JobExpriencesCell *cell = [JobExpriencesCell cellWithTableView:tableView];
        cell.proOrgPrizeM = self.viewModel.prizeArr[indexPath.row];
        if (indexPath.row == 0) { //第一个
            cell.topEdge.constant = 3;
            cell.topLine.backgroundColor = [UIColor whiteColor];
        }else{
            cell.topEdge.constant = 0;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    return [[UITableViewCell alloc]init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *sectionTitle = self.sectionTitleArr[indexPath.section];
    if ([sectionTitle isEqualToString:@"相关新闻"]) {
        //公司相关新闻
        NewsModel *item = self.viewModel.newsArr[indexPath.row];
        URLModel *urlModel = [[URLModel alloc] init];
        urlModel.url = item.news_detail;
        urlModel.title = item.title;
        NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
        webView.fromVC = @"公司相关新闻";
        webView.feedbackFlag = @"项目";
        webView.company = @{@"product":self.viewModel.companyDetail.company_basic.product?:@"",@"company":self.viewModel.companyDetail.company_basic.company?:@""};

        [self.navigationController pushViewController:webView animated:YES];
        [QMPEvent event:@"pro_news_cellclick"];
        [QMPEvent event:@"news_webpage_enter" label:@"新闻_项目"];
        
    }else if([sectionTitle isEqualToString:@"招聘信息"]){
        
        ZhaopinDetailController *detailVC = [[ZhaopinDetailController alloc]init];
        detailVC.zhaopinM = self.viewModel.zhaopinArr[indexPath.row];
        [self.navigationController pushViewController:detailVC animated:YES];
    }else if ([sectionTitle isEqualToString:@"最新动态"]) {
        if (self.viewModel.commentLayouts.count == 0) {
            [self.viewModel.publishCommentCommand execute:nil];
        }
    }else if([sectionTitle isEqualToString:@"项目介绍"]){
        NSString *key = self.basicInfoCellInfoArr[indexPath.row];
        if ([key isEqualToString:@"公司名称"] && (self.viewModel.companyDetail.is_register.integerValue == 1)) {
            [self enterRegistController:nil];
        } else if([key isEqualToString:@"法人代表"] && (self.viewModel.companyDetail.is_register.integerValue == 1)){
            [self enterFaRenVC];
        }
    }else if([sectionTitle isEqualToString:@"价值动态"]) {
        ActivityLayout *l = self.viewModel.valueDynamicArr[indexPath.row];
        ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] init];
        vc.activityID = l.activityModel.ID;
        vc.activityTicket = l.activityModel.ticket;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if([sectionTitle isEqualToString:@"App数据"]) {
        NSDictionary *dict = self.viewModel.apps[indexPath.row];
        ProductAppDataViewController *vc = [[ProductAppDataViewController alloc] init];
        vc.appID = dict[@"app_id"];
        vc.appName = dict[@"app_name"];
        vc.appStoreScore = dict[@"score"];
        vc.andirodDownCount = dict[@"downloads"];
        [self.navigationController pushViewController:vc animated:YES];
    }else if([sectionTitle isEqualToString:@"投资人"]) {
        if ([WechatUserInfo shared].claim_type.integerValue != 2) {
            return;
        }
        [PublicTool goPersonDetail:self.viewModel.investorsArr[indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.sectionTitleArr.count == 0) {
        return 0;
    }
    NSString *title = self.sectionTitleArr[section];

    if ([title containsString:@"最新动态"]) {
        return 45;
    }else{
        if ([self.sectionTitleArr[section-1] containsString:@"融资历史"]) {
            return 50;
        }
    }
    return HEADERHEIGHT;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.sectionTitleArr.count == 0) {
        return [[UIView alloc]init];
    }
    __weak typeof(self) weakSelf = self;    
    NSString *title = self.sectionTitleArr[section];
    if ([self.sectionTitleArr[section] isEqualToString:@"最新动态"] || [title isEqualToString:@"团队成员"] || [title isEqualToString:@"相关新闻"] || [title isEqualToString:@"招聘信息"] || [title isEqualToString:@"相似项目"] || [title isEqualToString:@"公司业务"] || [title isEqualToString:@"工商信息"] || [title isEqualToString:@"App数据"] || [title isEqualToString:@"投资人"] || [title isEqualToString:@"获奖经历"]) {
        
        NSString *rightTitle;
        if ([title isEqualToString:@"团队成员"]) {
            rightTitle  = [NSString stringWithFormat:@"全部(%@)",@(self.viewModel.companyDetail.company_team.count)];
        }else if ([title isEqualToString:@"相关新闻"]) {
            rightTitle  = self.viewModel.newsArr.count > 3 ? [NSString stringWithFormat:@"全部(%@)",self.viewModel.sectionDataCountDic[@"新闻"]]:@"";
        }else if ([title isEqualToString:@"招聘信息"]) {
            rightTitle  = self.viewModel.zhaopinArr.count > 3 ? [NSString stringWithFormat:@"全部(%@)",self.viewModel.sectionDataCountDic[@"招聘"]]:@"";
        }else if([title isEqualToString:@"最新动态"]){
           rightTitle = self.viewModel.status_Info.comment_count > 0 ? [NSString stringWithFormat:@"全部(%@)",self.viewModel.sectionDataCountDic[@"最新动态"]]:@"";
            if (self.viewModel.status_Info.comment_count > 0) {
                CommonTableVwSecHeadVw *commentHeader = [[CommonTableVwSecHeadVw alloc]initlbltitle:title leftBtnTitle:@"发布" btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
                    [weakSelf.viewModel.enterSecondPageCommand execute:sectionTitle];

                } leftBtnClick:^{
                    [weakSelf.viewModel.publishCommentCommand execute:nil];
                }];
                return commentHeader;
            }else{
                CommonTableVwSecHeadVw *commentHeader = [[CommonTableVwSecHeadVw alloc]initlbltitle:title btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
                    [weakSelf.viewModel.enterSecondPageCommand execute:sectionTitle];
                }];
                return commentHeader;
            }

        }else if([title isEqualToString:@"工商信息"]){
            rightTitle = @"全部";
        }else if([title isEqualToString:@"相似项目"]){
            rightTitle  = self.viewModel.similarArr.count > 3 ? [NSString stringWithFormat:@"全部(%@)",self.viewModel.sectionDataCountDic[@"相似项目"]]:@"";
        }else if([title isEqualToString:@"公司业务"]){
            rightTitle  = self.viewModel.companyDetail.company_business.count > 3 ? @"全部":@"";
        }else if([title isEqualToString:@"App数据"]){
            rightTitle  = self.viewModel.apps.count > 3 ? [NSString stringWithFormat:@"全部(%ld)",self.viewModel.apps.count]:@"";
        }else if([title isEqualToString:@"投资人"]){
            rightTitle  = self.viewModel.investorsArr.count > 0 ? [NSString stringWithFormat:@"全部(%@)",self.viewModel.sectionDataCountDic[@"投资人"]]:@"";
        }else if([title isEqualToString:@"获奖经历"]){
            rightTitle  = self.viewModel.prizeArr.count > 3 ? [NSString stringWithFormat:@"全部(%@)",self.viewModel.sectionDataCountDic[@"获奖经历"]]:@"";
        }else{
            rightTitle = @"";
        }

        CommonTableVwSecHeadVw *commentHeader = [[CommonTableVwSecHeadVw alloc]initlbltitle:title btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
            [weakSelf.viewModel.enterSecondPageCommand execute:sectionTitle];
        }];
        
        return commentHeader;
    }
    
   //只显示左方
    if ([title isEqualToString:@"证券信息"] || [title isEqualToString:@"项目画像"] || [title isEqualToString:@"项目介绍"] || [title isEqualToString:@"融资历史"]) {

        CommonTableVwSecHeadVw *commentHeader = [[CommonTableVwSecHeadVw alloc]initlbltitle:title btnTitle:@"" callBack:^(NSString *sectionTitle) {
            
        }];
        
        return commentHeader;
    }
   
    if([title isEqualToString:@"价值动态"]){
        __weak typeof(self) weakSelf = self;
        NSString *rightTitle = [self.viewModel.sectionDataCountDic[@"价值动态"] integerValue] > 0 ? [NSString stringWithFormat:@"全部(%@)",self.viewModel.sectionDataCountDic[@"价值动态"]]:@"";
        CommonTableVwSecHeadVw *commentHeader = [[CommonTableVwSecHeadVw alloc]initlbltitle:title btnTitle:rightTitle callBack:^(NSString *sectionTitle) {
            [weakSelf.viewModel.enterSecondPageCommand execute:@"价值动态"];
        }];
        
        return commentHeader;
    }
    
    return [[UIView alloc]init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.1)];
    footerV.backgroundColor = [UIColor whiteColor];
    return footerV;
}


- (void)chatBtnClick:(UIButton*)btn{
    NSInteger row = btn.tag - 2000;
    PersonModel *person = self.viewModel.investorsArr[row];
    if ([PublicTool isNull:person.usercode]) {
        return;
    }
    
    if ([WechatUserInfo shared].claim_type.integerValue == 2){
        [[AppPageSkipTool shared] appPageSkipToChatView:[NSString stringWithFormat:@"%@",person.usercode]];
        
    }else {
        [PublicTool userisCliamed];
    }
}

- (void)enterFaRenVC{
    
    if ([PublicTool isNull:self.viewModel.companyDetail.company_basic.legal_hid]) {
        [PublicTool showMsg:@"暂无数据"];        
        return;
    }
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/isRelateTyc1" HTTPBody:@{@"uniq_hid":self.viewModel.companyDetail.company_basic.legal_hid} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData) {
            
            if (![PublicTool isNull:resultData[@"person_id"]]) {
                [self enterPersonDetail:resultData[@"person_id"]];
                
            }else{
                if ([PublicTool isNull:self.viewModel.companyDetail.company_basic.legal_hid]) {
                    [PublicTool showMsg:@"暂无数据"];
                    return;
                }else{
                    PersonAllBusinessRoleController *busicnessVC = [[PersonAllBusinessRoleController alloc]init];
                    PersonModel *person = [[PersonModel alloc]init];
//                    NSDictionary *gs = @{@"hid":self.viewModel.companyDetail.company_basic.faren_id,@"cid":self.viewModel.companyDetail.company_basic.cid};
//                    person.gs = gs;
                    person.name = self.viewModel.companyDetail.company_basic.faren;
                    person.uniq_hid = self.viewModel.companyDetail.company_basic.legal_hid;
                    busicnessVC.personModel = person;
                    busicnessVC.isNeedUserHeader = YES;
                    [self.navigationController pushViewController:busicnessVC animated:YES];
                }
                
            }
        }
    }];
}

- (void)enterPersonDetail:(NSString*)personId{
    [[AppPageSkipTool shared] appPageSkipToPersonDetail:personId];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView != self.tableView){
        return;
    }
    //导航
    if (scrollView.contentOffset.y > 44) {
        if([PublicTool isNull:_nabar.title]){
            _nabar.title = self.viewModel.companyDetail.company_basic.product;
        }
    }else if(scrollView.contentOffset.y < 44){
        if(![PublicTool isNull:_nabar.title]){
            _nabar.title = nil;
        }
    }
}

#pragma mark - 请求公司详情 c1
- (void)dealCompanyDetailOtherInfo{
    
    [self.basicInfoCellInfoArr removeAllObjects];
    
    [self.basicInfoCellInfoArr addObject:@"项目介绍"];

    if (self.viewModel.companyDetail.company_basic.product.length) {
        [self.basicInfoCellInfoArr addObject:@"公司名称"];
    }
    if (self.viewModel.companyDetail.company_basic.faren.length) {
        [self.basicInfoCellInfoArr addObject:@"法人代表"];
        ;
    }
    if (self.viewModel.companyDetail.company_basic.open_time.length) {
        [self.basicInfoCellInfoArr addObject:@"成立时间"];
    }
    if (self.viewModel.companyDetail.company_basic.province.length) {
        [self.basicInfoCellInfoArr addObject:@"所属地区"];
    }
    if (self.viewModel.companyDetail.company_basic.hangye1.length) {
        [self.basicInfoCellInfoArr addObject:@"所属行业"];
    }
    if (self.viewModel.companyDetail.company_basic.gw_link.length) {
        [self.basicInfoCellInfoArr addObject:@"公司官网"];
    }
    if (self.viewModel.companyDetail.company_basic.valuations_money.length) {
        [self.basicInfoCellInfoArr addObject:@"公司估值"];
    }
    
    return;
}

- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    @weakify(self);
    [self.viewModel.requestFinishSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);

        if (!self.viewModel.companyDetail) {
            return;
        }
        [self dealCompanyDetailOtherInfo];
        [self refreshModelView];
        
        //显示笔记入口提示
        NSString *key = [NSString stringWithFormat:@"%@NOTE",@"4.0.4"];
        if (![USER_DEFAULTS valueForKey:key]) {
            //显示气泡
            HYNoticeView *noticeTop = [[HYNoticeView alloc] initWithFrame:CGRectMake(SCREENW - 203, kScreenTopHeight-4, 200, 35) text:@"添加笔记功能移到这里了哦～" bgColor:H3COLOR textColor:[UIColor whiteColor] position:HYNoticeViewPositionTopRight];
            [noticeTop showType:HYNoticeTypeTestTop inView:self.view after:0 duration:0.2 options:UIViewAnimationOptionCurveEaseInOut];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [HYNoticeView hideNoticeInView:self.view];
            });
            [USER_DEFAULTS setValue:@(YES) forKey:key];
            [USER_DEFAULTS synchronize];
        }
        
        //tableFooterV
        UIImageView *footerImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENW)];
        footerImg.image = [UIImage imageNamed:@"detail_placeholder_second"];
        self.tableView.tableFooterView = footerImg;

        [self.viewModel.requestFinishTwoSignal subscribeNext:^(id  _Nullable x) {
            if (!self.viewModel.companyDetail) {
                return;
            }
            [self dealCompanyDetailOtherInfo];
            [self refreshModelView];
        }];
    }];
    
    return YES;
}

- (void)refreshModelView{
    
    [self sortRightOrder]; //整理显示的顺序
    [self initTableHeaderView];
    
    UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 50)];
    footerV.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = footerV;
    
    [self.tableView reloadData];
    
    [self initBottomView];
    
    [self.tableView reloadData];
    [self hideHUD];
    
}

- (void)sortRightOrder{
    
    self.sectionTitleArr = [NSMutableArray array];
    
    [self.sectionTitleArr addObject:@"最新动态"];
    if (self.viewModel.companyDetail.company_basic.allipo.count > 0) {
        [self.sectionTitleArr addObject:@"证券信息"];
    }
    
    //section 1 项目画像
    if (self.viewModel.companyDetail.company_basic.tags_portrait.count) {
        [self.sectionTitleArr addObject:@"项目画像"];
    }
    

    [self.sectionTitleArr addObject:@"项目介绍"];
    if (self.viewModel.companyDetail.is_register.integerValue == 1 && self.viewModel.registInfoMenusArr.count) {
        [self.sectionTitleArr addObject:@"工商信息"];
    }
    //section4 团队成员
    if (self.viewModel.companyDetail.company_team.count) {
        [self.sectionTitleArr addObject:@"团队成员"];
        
    }
    //section3  融资
    if (self.viewModel.companyDetail.company_rongzi.count) {
        [self.sectionTitleArr addObject:@"融资历史"];
        
    }
    if (self.viewModel.investorsArr.count) {
       [self.sectionTitleArr addObject:@"投资人"];

    }
    //section 6 公司业务
    if (self.viewModel.companyDetail.company_business.count > 1) {
        [self.sectionTitleArr addObject:@"公司业务"];
        
    }
    if (self.viewModel.similarArr.count) {
        [self.sectionTitleArr addObject:@"相似项目"];
    }
    
    if (self.viewModel.apps.count) {
        [self.sectionTitleArr addObject:@"App数据"];
    }
    
    if(self.viewModel.prizeArr.count){
        [self.sectionTitleArr addObject:@"获奖经历"];
    }
    //section 5 相关新闻
    if (self.viewModel.newsArr.count) {
        [self.sectionTitleArr addObject:@"相关新闻"];
    }
    
    if (self.viewModel.zhaopinArr.count) {
        [self.sectionTitleArr addObject:@"招聘信息"];        
    }
    
    return;
}


#pragma mark - ManagerAlertDelegate
//添加项目画像
- (void)addAlbumToSelf:(NSString *)newName{
    //项目画像为空
    newName = [newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (newName.length == 0 || !newName) {
        [ShowInfo showInfoOnView:KEYWindow withInfo:@"项目画像不能为空"];
        return;
    }
    
    if (newName.length > 12 || !newName) {
        [ShowInfo showInfoOnView:KEYWindow withInfo:@"项目画像请不要超过12个字"];
        return;
    }
    
    //上传项目画像
    NSArray *dataArr = [self.viewModel.companyDetail.company_basic.tags componentsSeparatedByString:@"|"];
    if ([dataArr containsObject:newName]) {
        [ShowInfo showInfoOnView:KEYWindow withInfo:@"项目画像已存在"];
        return;
    }
    _alertView.userInteractionEnabled = NO;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
    [param setValue:@"qmp_ios" forKey:@"ptype"];
    [param setValue:VERSION forKey:@"version"];
    [param setValue:self.viewModel.companyDetail.company_basic.product_id forKey:@"product_id"];
    [param setValue:newName forKey:@"tag"];
    
    QMPLog(@"上传项目画像传惨====%@",param);
    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"tag/addTagUr" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData) {
            [self.alertView removeFromSuperview];
            
            [ShowInfo showInfoOnView:KEYWindow withInfo:@"画像添加成功"];
            NSMutableArray *tagsMuArr = [NSMutableArray arrayWithArray:self.viewModel.companyDetail.company_basic.tags_portrait];
            [tagsMuArr insertObject:newName atIndex:0];
            self.viewModel.companyDetail.company_basic.tags_portrait = (NSArray*)tagsMuArr;
            @weakify(self);
            [self.viewModel.updateTagsFrameSignal subscribeNext:^(id  _Nullable x) {
                @strongify(self);
                [self.tableView reloadData];
            }];
            
        }else{
            self.alertView.userInteractionEnabled = YES;
            [ShowInfo showInfoOnView:KEYWindow withInfo:@"画像添加失败"];
        }
    }];
    
}

#pragma mark - public

/**
 长按基本信息
 
 @param longPress
 */
- (void)longPressInfoLbl:(UILongPressGestureRecognizer *)longPress{
    
    UILabel *lbl = (UILabel *)longPress.view;
    NSArray *txtArr = [lbl.text componentsSeparatedByString:@"："];
    [self copyText:[txtArr lastObject]];
}

/**
 拷贝信息
 
 @param txt
 */
- (void)copyText:(NSString *)txt{
    
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string = txt;
    
    [ShowInfo showInfoOnView:self.view withInfo:@"复制成功"];
}
- (void)enterRegistController:(NSString*)title{
    
    RegisterInfoViewController *registerDetailVC = [[RegisterInfoViewController alloc]init];
    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:self.urlDict];
    [mdic removeObjectForKey:@"id"];
    [mdic removeObjectForKey:@"p"];
    registerDetailVC.urlDict = mdic;
    registerDetailVC.gotoSection = title;
    registerDetailVC.companyName = self.viewModel.companyDetail.company_basic.company&&![self.self.viewModel.companyDetail.company_basic.company isEqualToString:@""] ? self.self.viewModel.companyDetail.company_basic.company:@"";
    
    [[PublicTool topViewController].navigationController pushViewController:registerDetailVC animated:YES];
}

/**长按相关新闻复制*/
- (void)longPressJianjieLbl:(UILongPressGestureRecognizer *)longPress{
    UILabel *lbl = (UILabel *)longPress.view;
    
    NSString *urlStr = self.viewModel.companyDetail.company_basic.short_url;
    if ([urlStr hasPrefix:@"http://"]||[urlStr hasPrefix:@"https://"]) {
        
        [PublicTool storeShortUrlToLocal:urlStr];
        
    }
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [NSString stringWithFormat:@"%@ 来自@企名片%@",lbl.text,urlStr];
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}

- (void)screenLongCut{
    
    _printscreenImage = [PublicTool getLongCaptureImage:self.tableView];
    [self.shareToTool shareDetailImage:_printscreenImage];
    
    [QMPEvent event:@"company_screenshot_click"];
}



/**
 *  rightButtonItem
 */
- (void)pressRightButtonItem:(id)sender{
    
    CGFloat x = SCREENW - 13;
    CGFloat y = kScreenTopHeight + 10;
    
    self.outputView = [[LrdOutputView alloc] initWithDataArray:_moreOptionsArr origin:CGPointMake(x, y) viewLeftBottomLocation:CGPointMake(x, y) width:125 height:44 screenH:SCREENH direction:kLrdOutputViewDirectionRight ofAction:@"moreOptions" hasImg:YES];
    
    self.outputView.delegate = self;
    __weak typeof(self) weakSelf = self;
    self.outputView.dismissOperation = ^(){
        //设置成nil，以防内存泄露
        weakSelf.outputView = nil;
    };
    [self.outputView popFromBottom];
    
    [QMPEvent event:@"pro_nabar_moreClick"];
}

- (void)shareEvent{
    
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        NSString *titleSessionStr = [NSString stringWithFormat:@"%@-%@",self.viewModel.companyDetail.company_basic.product,self.viewModel.companyDetail.company_basic.yewu];
        NSString *titleTimelineStr = [NSString stringWithFormat:@"%@-%@-%@",self.viewModel.companyDetail.company_basic.product,self.viewModel.companyDetail.company_basic.yewu,self.viewModel.companyDetail.company_basic.faren];//,_searchCompanyModel.company
        NSString *product = self.viewModel.companyDetail.company_basic.product;
        NSString *company = self.viewModel.companyDetail.company_basic.company;
        NSString *faren = self.viewModel.companyDetail.company_basic.faren;
        NSString *detailStr = [NSString stringWithFormat:@"%@-%@-%@",product,company,faren];
        if ([PublicTool isNull:faren]) {
          titleTimelineStr = [NSString stringWithFormat:@"%@-%@",self.viewModel.companyDetail.company_basic.product,self.viewModel.companyDetail.company_basic.yewu];//,_searchCompanyModel.company
           detailStr = [NSString stringWithFormat:@"%@-%@",product,company];
        }
        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"share/addUserShareLog" HTTPBody:@{@"project_id":self.viewModel.companyDetail.ticket,@"project_type":@"product"} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            if (![PublicTool isNull:resultData[@"url_short"]]) {
                NSString *copyString = [NSString stringWithFormat:@"%@%@来自@企名片",detailStr,resultData[@"url_short"]];
                [[[ShareTo alloc] init] shareWithDetailStr:detailStr sessionTitle:titleSessionStr timelineTitle:titleTimelineStr copyString:copyString aIcon:self.viewModel.companyDetail.company_basic.icon aOpenUrl:resultData[@"url_short"] onViewController:self shareResult:^(BOOL shareSuccess) {
                    
                }];
            }
        }];
        
        [QMPEvent event:@"pro_nabar_more_shareClick"];
    }
}

/**
 回首页
 */
- (void)goHome{
    
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:YES];
    //    ;
    [QMPEvent event:@"pro_nabar_more_homeClick"];
}

- (void)gotoFeedBack{
    DetailFeedBackVC *feedVC = [[DetailFeedBackVC alloc]init];
    feedVC.type = DetailFeedBackTypeProduct;
    feedVC.companyM = self.viewModel.companyDetail;
    [self.navigationController pushViewController:feedVC animated:YES];
}
- (void)initTableView{
   
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kScreenTopHeight, SCREENW, SCREENH-kScreenBottomHeight-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[ProductRongziCell class] forCellReuseIdentifier:@"ProductRongziCellID"];
    [self.tableView registerClass:[NewsTableViewCell class] forCellReuseIdentifier:@"NewsTableViewCellID"];
    [self.tableView registerClass:[IpoInfoCell  class] forCellReuseIdentifier:@"IpoInfoCellID"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CompanyZhaopinCell" bundle:nil] forCellReuseIdentifier:@"CompanyZhaopinCellID"];
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"headerView"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:self.tableView];
    [self.tableView reloadData];

    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.viewModel.scrollView = self.tableView;
    
    __weak typeof(self) weakSelf = self;
    DetailNavigationBar *topBar = [DetailNavigationBar detailTopBarWithRightMenuArr:self.moreOptionsArr shareEvent:^{
        [weakSelf shareEvent];
    } moreClick:^{
        [weakSelf pressRightButtonItem:nil];
    }];
    _nabar = topBar;
    [self.view addSubview:topBar];
}


/**
 头部信息 tableHeaderView
 */
- (void)initTableHeaderView{
    
    __weak typeof(self) welf = self;
    
    self.tableHeadView = [[ProductTableHeadView alloc]initWithCompanyDetailModel:self.viewModel.companyDetail financeNeedModel:self.viewModel.needModel];
    self.tableHeadView.viewModel = self.viewModel;
    //点击融资需求
    self.tableHeadView.tapedNeedMoneyView = ^{
        [welf enterNeedMoneyVC];
    };

    if (!self.viewModel.companyDetail) {
        self.tableHeadView.height = 170;
    }
    self.tableView.tableHeaderView =  self.tableHeadView;
    [self.tableView reloadData];
    
}


- (void)enterNeedMoneyVC{
    if(![PublicTool userisClaimInvestor]){
        return;
    }
    //别人看
    CompanyFinancialViewController *financialVC = [[CompanyFinancialViewController alloc] init];
    financialVC.needModel = self.viewModel.needModel;
    financialVC.companyDetail = self.viewModel.companyDetail;
    [self.navigationController pushViewController:financialVC animated:YES];
}


- (void)initBottomView{
    
    if (_toolView.superview) {
        return;
    }
    
    _toolView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH - kScreenBottomHeight, SCREENW, kScreenBottomHeight)];
    _toolView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_toolView];
    
    CGFloat btnHeight = 49;
    
    CGFloat fontSize = 15.f;
    CGFloat leftWidth = SCREENW*23/73;
    CGFloat width = (SCREENW - leftWidth)/2.0;
    
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, leftWidth, btnHeight)];
    leftView.backgroundColor = [UIColor whiteColor];
    [_toolView addSubview:leftView];
    
//  客服
    UIButton *kefuBtn = [[UIButton alloc]initWithFrame:CGRectMake(8, 0,(leftWidth - 16)/2.0, btnHeight)];
    [kefuBtn setTitle:@"客服" forState:UIControlStateNormal];
    [kefuBtn setImage:[UIImage imageNamed:@"detail_kefu_icon"] forState:UIControlStateNormal];
    [kefuBtn setTitleColor:H6COLOR forState:UIControlStateNormal];
    kefuBtn.titleLabel.font = [UIFont systemFontOfSize:9];
    [kefuBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:5];
    [kefuBtn addTarget:self action:@selector(kefuBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:kefuBtn];
    
    _toolFeedbackBtn = [[UIButton alloc]initWithFrame:CGRectMake(kefuBtn.right, 0, (leftWidth - 16)/2.0, btnHeight)];
    [_toolFeedbackBtn setTitle:@"反馈" forState:UIControlStateNormal];
    [_toolFeedbackBtn setImage:[UIImage imageNamed:@"detail_feedback_icon"] forState:UIControlStateNormal];
    [_toolFeedbackBtn setTitleColor:H6COLOR forState:UIControlStateNormal];
    _toolFeedbackBtn.titleLabel.font = [UIFont systemFontOfSize:9];
    _toolFeedbackBtn.backgroundColor = [UIColor whiteColor];

    [_toolFeedbackBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:5];
    [_toolFeedbackBtn addTarget:self action:@selector(gotoFeedBack) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:_toolFeedbackBtn];
    
    
    UIButton *oncelikeBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftWidth, 0, width, btnHeight)];
    [oncelikeBtn buttonWithTitle:@"立即联系" image:nil titleColor:[UIColor whiteColor] fontSize:fontSize];
    if (@available(iOS 8.2, *)) {
        oncelikeBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightMedium];
    }else{
        oncelikeBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    [oncelikeBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    oncelikeBtn.backgroundColor = HTColorFromRGB(0x2292F9);

    @weakify(self);
    [[oncelikeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self.viewModel.enterSecondPageCommand execute:@"立即联系"];
    }];
    [_toolView addSubview:oncelikeBtn];
    
    _flowToolBtn = [[UIButton alloc] initWithFrame:CGRectMake(oncelikeBtn.right, 0, SCREENW-oncelikeBtn.right, btnHeight)];
    if (@available(iOS 8.2, *)) {
        _flowToolBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    } else {
        _flowToolBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    _flowToolBtn.backgroundColor = BLUE_TITLE_COLOR;
    [_toolView addSubview:_flowToolBtn];
    
    _aboveFlowBtn = [[UIButton alloc] initWithFrame:_flowToolBtn.frame];
    _aboveFlowBtn.backgroundColor = [UIColor clearColor];
    _aboveFlowBtn.rac_command = self.viewModel.updateAttentStatusCommand;
    [_toolView addSubview:_aboveFlowBtn];
    [self changeWorkFlowStatusToolBtnStatus];

    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, leftWidth, 0.5)];
    line.backgroundColor = LINE_COLOR;
    [_toolView addSubview:line];
    
}

- (void)changeWorkFlowStatusToolBtnStatus{
    
    BOOL inWorkFlow = (self.viewModel.status_Info.focus_status != -1) && (self.viewModel.status_Info.focus_status != 0) && (self.viewModel.status_Info.focus_status != 999) && (self.viewModel.status_Info.focus_status != 5);
    
    
    NSString *imageName = inWorkFlow ? @"workflow_have" : @"workflow_add";
    NSString *titleStr = inWorkFlow ? @"已关注":@"关注";
    [_flowToolBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [_flowToolBtn setTitle:titleStr forState:UIControlStateNormal];
    [_flowToolBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
}

- (void)addNoteEvent{
    
    NoteEditController *noteVC = [[NoteEditController alloc]init];
    
    SearchCompanyModel *company = [[SearchCompanyModel alloc]init];
    company.product = self.viewModel.companyDetail.company_basic.product;
    company.company = self.viewModel.companyDetail.company_basic.company;
    company.productId = self.viewModel.companyDetail.company_basic.product_id;
    company.icon = self.viewModel.companyDetail.company_basic.icon;
    noteVC.searchComM = company;
    [self.navigationController pushViewController:noteVC animated:YES];
}

- (void)kefuBtnClick{
    
    NSString *text = [NSString stringWithFormat:@"%@正在浏览项目【%@】时，进入客服",[WechatUserInfo shared].nickname,self.viewModel.companyDetail.company_basic.product];
    [PublicTool contactKefuMSG:text reply:kDefaultWel delMsg:YES];
    [QMPEvent event:@"company_kefu_click"];
}

//进入 加入专辑
- (void)enterAlbumEdit{
    _tagVC = [[TagEditController alloc]init];    
    _tagVC.productId = self.viewModel.companyDetail.company_basic.product_id;
    _tagVC.finishEdit = ^(NSArray *addTagArr) { //worktag 数组
    };
    
    [self.navigationController pushViewController:_tagVC animated:YES];
}

/**
 @param sender 点击项目画像
 */
- (void)clickAddTag{
    // 认证限制
    if (![PublicTool userisCliamed]) {
        return;
    }
    
    ManagerAlertView *alertView = [ManagerAlertView initFrame];
    NSArray *dataArr = [self.viewModel.companyDetail.company_basic.tags componentsSeparatedByString:@"|"];
    alertView.nameArr = [NSMutableArray arrayWithArray:dataArr];
    [alertView initViewWithTitle:@"给企业添加画像"];
    alertView.action = @"addAlbumToSelf";
    alertView.delegata = self;
    alertView.currentVC = self;
    
    [KEYWindow addSubview:alertView];
    _alertView = alertView;
}

- (void)clickTag:(NSString*)tag{
    
    GetProductsFromTagsViewController *tagsVC = [[GetProductsFromTagsViewController alloc]init];
    tagsVC.isMatchTag = [self.viewModel.tagsMatchMArr containsObject:tag];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:0];
    if (self.viewModel.companyDetail.company_basic.product) {
        [mDict setValue:self.viewModel.companyDetail.company_basic.product forKey:@"product"];
    }
    [mDict setValue:tag forKey:@"tag"];
    
    tagsVC.urlDict = mDict;
    
    [self.navigationController pushViewController:tagsVC animated:YES];
    
}


- (void)updateCompanyDesc:(NSString*)newDesc{
    
    [PublicTool showHudWithView:KEYWindow];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
    [param setValue:self.viewModel.companyDetail.company_basic.yewu forKey:@"yewu"];
    [param setValue:self.viewModel.companyDetail.company_basic.product_id forKey:@"product_id"];
    [param setValue:newDesc forKey:@"miaoshu"];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/productManageBasic" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        if (resultData) {
            
            [PublicTool showMsg:@"更新成功"];
            self.viewModel.companyDetail.company_basic.miaoshu = newDesc;
            [self.tableView reloadData];
        } else {
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
    
}

- (void)userClaimBtnClick{
    [[AppPageSkipTool shared] appPageSkipToClaimPage];
    [QMPEvent event:@"pro_investor_toclaim_click"];
}

#pragma mark - 懒加载
- (ShareTo *)shareToTool{
    
    if (!_shareToTool) {
        _shareToTool = [[ShareTo alloc] init];
        _shareToTool.delegate = self;
    }
    return _shareToTool;
}


- (ProductDetailViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[ProductDetailViewModel alloc]init];
        _viewModel.requestDic = self.urlDict;
        @weakify(self);
        
        _viewModel.refreshCommentListSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            [self.tableView reloadData];
            return nil;
        }];
       
        [RACObserve(_viewModel, status_Info.focus_status) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self changeWorkFlowStatusToolBtnStatus];
        }];
        
    }
    return _viewModel;
}

-(NSArray *)moreOptionsArr{
    if (!_moreOptionsArr) {
        LrdCellModel *jietuLongM = [[LrdCellModel alloc] initWithTitle:@"截长图" imageName:@"captureScreen_more1"];
        LrdCellModel *note = [[LrdCellModel alloc] initWithTitle:@"写笔记" imageName:@"detail_addNote"];

        LrdCellModel *tag2 = [[LrdCellModel alloc] initWithTitle:@"加专辑" imageName:@"company_addToTag"];
        
//        LrdCellModel *kefuM = [[LrdCellModel alloc] initWithTitle:@"客服" imageName:@"detail_kefu"];
        LrdCellModel *homeModel = [[LrdCellModel alloc] initWithTitle:@"回首页" imageName:@"gohome_detail"];
        
        _moreOptionsArr = @[jietuLongM,note,tag2,homeModel];
    }
    return _moreOptionsArr;
}
- (NSArray*)registInfoCellImages{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *title in self.viewModel.registInfoMenusArr) {
        [arr addObject:self.registImageDic[title]];
    }
    return arr;
}

-(NSMutableArray *)basicInfoCellInfoArr{
    if (!_basicInfoCellInfoArr) {
        _basicInfoCellInfoArr = [NSMutableArray array];
    }
    return _basicInfoCellInfoArr;
}

- (NSDictionary*)registImageDic{
    if (!_registImageDic) {
        _registImageDic = @{@"注册信息":@"regist_basic",@"股东信息":@"regist_gudong",@"主要成员":@"regist_people",@"对外投资":@"regist_touzi",@"联系方式":@"regist_basic",@"备案信息":@"regist_record",@"变更记录":@"regist_change"};
    }
    return _registImageDic;
}
- (UITableViewCell*)claimCell{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ClaimCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ClaimCell"];
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    UIImageView *bgImgV = [cell.contentView viewWithTag:1000];
    if (!bgImgV) {
        UIImage *img = [UIImage imageNamed:@"company_investorclaimbg"];
        bgImgV = [[UIImageView alloc]initWithFrame:CGRectMake(16, 15, img.size.width*180/img.size.height, 180)];
        bgImgV.image = img;
        bgImgV.tag = 1000;
        [cell.contentView addSubview:bgImgV];
    }
    UILabel *titleLab = [cell.contentView viewWithTag:1001];
    if (!titleLab) {
        titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 67, SCREENW, 18)];
        [titleLab labelWithFontSize:14 textColor:H3COLOR];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.numberOfLines = 2;
        titleLab.tag = 1001;
        [cell.contentView addSubview:titleLab];
    }
    UIButton *claimBtn = [cell.contentView viewWithTag:1002];
    if (!claimBtn) {
        claimBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 110, 108, 30)];
        [claimBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [claimBtn setTitle:@"立即认证" forState:UIControlStateNormal];
        claimBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        claimBtn.backgroundColor = BLUE_BG_COLOR;
        claimBtn.layer.cornerRadius = 15;
        claimBtn.layer.masksToBounds = YES;
        claimBtn.tag = 1002;
        [cell.contentView addSubview:claimBtn];
        [claimBtn addTarget:self action:@selector(userClaimBtnClick) forControlEvents:UIControlEventTouchUpInside];
        claimBtn.centerX = SCREENW/2.0;
    }
    if ([WechatUserInfo shared].claim_type.integerValue == 1) { //审核中
        claimBtn.hidden = YES;
        titleLab.width = 180;
        titleLab.height = 45;
        titleLab.center = CGPointMake(SCREENW/2.0, bgImgV.height/2.0);
        //3. 我正在寻找的问题，并能中心对齐在NSAttributedString的文字是这样的：
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        NSAttributedString *attstr = [@"您的认证信息正在审核中，暂时无法查看该内容" stringWithParagraphlineSpeace:6 textColor:H3COLOR textFont:[UIFont systemFontOfSize:14]];
        NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithAttributedString:attstr];
        [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attribString length])];
        titleLab.text = nil;
        titleLab.attributedText = attribString;
        
    }else{
        
        claimBtn.hidden = NO;
        titleLab.width = 290;
        titleLab.height = 18;
        titleLab.top = 67;
        titleLab.attributedText = nil;
        titleLab.text = @"成为认证用户，即可查看项目投资人";
        titleLab.centerX = SCREENW/2.0;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
