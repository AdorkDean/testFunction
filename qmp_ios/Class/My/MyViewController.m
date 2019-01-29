
//  MyViewController.m
//  QimingpianSearch
//
//  Created by Molly on 16/8/12.
//  Copyright © 2016年 qimingpian. All rights reserved.
//
#import "MyViewController.h"
#import "MainNavViewController.h"
#import "SettingTableViewCell.h"
#import "QuitTableViewCell.h"
#import "TagsManagerViewController.h"
#import "AllFeedbackViewController.h"
#import "MyTabHeaderView.h"
#import "GetMd5Str.h"
#import "ShareTo.h"
#import <UIButton+WebCache.h>
#import "ManagerAlertView.h"
#import "SetTableViewController.h"
#import "MyFeedbackController.h"
#import "MYHeaderItemVwbyXib.h"
#import "MeMoreItemListVC.h"
#import "METopItemParentVC.h"
#import "MyActivitiesViewController.h"
#import "MyWalletViewController.h"
#import "QMPMyActivityCommentViewController.h"
#import <JPush/JPUSHService.h>
#import "MyActivityListViewController.h"
#import "CommentLikeActivityViewController.h"
#import "CardExchangeListController.h"
#import "ProductContactsController.h"
#import "PersonDetailsController.h"

static NSString *const APPGroupId = @"group.mofang.Qimingpian";

@interface MyViewController() <UITableViewDelegate, UITableViewDataSource,
SetTableViewControllerDelegate, AllFeedbackViewDelegate> {
    
    NSString *_nowVersion; //< 返回的版本
    ShareTo *_shareToTool;
    UIImageView *_underView;
}
@property (strong, nonatomic) MyTabHeaderView * headerView;
@property (strong, nonatomic) MYHeaderItemVwbyXib * belowItemVw;
@property (strong, nonatomic) UIImageView * bgHeaderVw;
@property (strong, nonatomic) NSArray *tableDataArr;
@property (strong, nonatomic) NSArray *imageArr;
@property (nonatomic, strong) NSArray *tableConfigDatas;

@property (nonatomic, strong) UIView *showAlertMessageBgVw;

@end

@implementation MyViewController


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [QMPEvent endEvent:@"me_tab_timer"];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [QMPEvent beginEvent:@"me_tab_timer"];
    
    if ([ToLogin isLogin]) {
        [self againRequestUserInfo];
    }
}

- (void)againRequestUserInfo{
    
    [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:@"user/getUserInfo" HTTPBody:@{@"uuid":[WechatUserInfo shared].uuid} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData) {
            NSInteger claim_type = [WechatUserInfo shared].claim_type.integerValue;
            WechatUserInfo *userModel = [WechatUserInfo shared];
            [userModel setValuesForKeysWithDictionary:resultData];
            [userModel save];
            
            if ((claim_type != 2) && ([resultData[@"claim_type"] integerValue] == 2)) {
                [[ToLogin shared].delegate refreshUserInfo];
                [self showbindPhone];
            }
            [self showheadTxtSytle];
            [self topShowMsg];
        }
    }];
    
}

- (void)showheadTxtSytle{
    
    if ([[WechatUserInfo shared].claim_type integerValue] != 0) {
        
        [self showbindPhone];
        if ([WechatUserInfo shared].claim_type.integerValue == 1 || [WechatUserInfo shared].claim_type.integerValue == 3) {
            _headerView.homePageLab.hidden = NO;
            _headerView.homePageLab.text = [WechatUserInfo shared].claim_type.integerValue == 1 ? @"审核中":@"审核失败";
            _headerView.homePageLab.textColor = [UIColor whiteColor];
            _headerView.homePageLab.backgroundColor = H9COLOR;
            
            _headerView.rzStatusLbl.hidden = YES;
            _headerView.bindPhoneLab.text = @"认证官方人物，获取更多权限";
        } else {
            if ([WechatUserInfo shared].claim_type.integerValue == 2) {
                _headerView.rzStatusLbl.hidden = NO;
                if ([USER_DEFAULTS boolForKey:isEditedMyInfo]) {
                    [self showbindPhone];
                }else{
                    _headerView.bindPhoneLab.text = @"去主页完善资料，让大家更加了解你";
                }
            }
            _headerView.homePageLab.hidden = YES;
        }
        
    } else {
        
        _headerView.homePageLab.hidden = NO;
        _headerView.rzStatusLbl.hidden = YES;
        _headerView.homePageLab.text = @"去认证";
        _headerView.homePageLab.textColor = [UIColor whiteColor];
        _headerView.homePageLab.backgroundColor = BLUE_BG_COLOR;
        _headerView.bindPhoneLab.text = @"认证官方人物，获取更多权限";
    }
}
- (void)showbindPhone{
    
    NSMutableString *desc = [NSMutableString string];
    if (![PublicTool isNull:[WechatUserInfo shared].company]) {
        [desc appendString:[WechatUserInfo shared].company];
        
        if (![PublicTool isNull:[WechatUserInfo shared].zhiwei]) {
            [desc appendFormat:@"  %@", [WechatUserInfo shared].zhiwei];
        }
    }
    _headerView.bindPhoneLab.text = desc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的";
    
    [self buildTableView];
    [self builHeaderView];
    [self buildNavigationItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeInfo:) name:NOTIFI_LOGIN object:nil];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //刷新tableHeaderView
    [self changeView];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    
    if ([ToLogin isLogin]) {
        [self getNumberOfAttetion];//登录才请求数据
        [self getUnReadCount];
    }
}

- (void)topShowMsg{
    
    if ([WechatUserInfo shared].claim_type.integerValue == 2 && ![USER_DEFAULTS boolForKey:isEditedMyInfo]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[WechatUserInfo shared].person_id,@"person_id",@(1),@"debug", nil];
        [AppNetRequest personDetailWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            if (resultData) {
                PersonModel *person = [[PersonModel alloc]initWithDictionary:resultData error:nil];
                if (person.work_exp.count <=0) {
                    if (![self.showAlertMessageBgVw isDescendantOfView:self.bgHeaderVw]) {
                        [self.bgHeaderVw addSubview:self.showAlertMessageBgVw];
                        self.showAlertMessageBgVw.top = self.headerView.height;
                        self.bgHeaderVw.height = 186+35-10;
                        self.belowItemVw.top = 100+self.showAlertMessageBgVw.height;
                        self.belowItemVw.height = 74;
                        [self.tableView beginUpdates];
                        [self.tableView setTableHeaderView:self.bgHeaderVw];
                        [self.tableView endUpdates];
                        [self.tableView reloadData];
                    }
                }
               
            }
        }];
        
    }else{
        if ([self.showAlertMessageBgVw isDescendantOfView:self.bgHeaderVw]) {
            self.bgHeaderVw.height = 186;
            self.belowItemVw.top = 116;
            self.belowItemVw.height = 74;
            [self.showAlertMessageBgVw removeFromSuperview];
            [self.tableView beginUpdates];
            [self.tableView setTableHeaderView:self.bgHeaderVw];
            [self.tableView endUpdates];
            [self.tableView reloadData];
        }
    }
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**
 *  构建tableView基本样式
 */
- (void)buildTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.frame = CGRectMake(0, 0, SCREENW, SCREENH - kScreenBottomHeight-kScreenTopHeight);
    [self.view addSubview:self.tableView];
    
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    
    UIView *tableFooterVw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 62)];
    UILabel *versionLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, 8, SCREENW, 36)];
    versionLabel.text = [NSString stringWithFormat:@"V %@",VERSION];
#if DEBUG
    versionLabel.text = [NSString stringWithFormat:@"V %@(build %@ 4.9.3)",VERSION,VERSIONBUILD];
#endif
    versionLabel.text = [NSString stringWithFormat:@"V %@(build %@ 4.9.3)",VERSION,VERSIONBUILD];

    versionLabel.textColor = RGBa(160, 159, 165, 1);
    versionLabel.font = [UIFont systemFontOfSize:13.f];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    tableFooterVw.backgroundColor = TABLEVIEW_COLOR;
    [tableFooterVw addSubview:versionLabel];
    self.tableView.tableFooterView = tableFooterVw;
   
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)buildNavigationItem{
//    UIButton *walletBtn = [[UIButton alloc]initWithFrame:LEFTBUTTONFRAME];
//    [walletBtn setImage:[BundleTool imageNamed:@"me_walletIcon"] forState:UIControlStateNormal];
//    [walletBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    @weakify(self);
//    [[walletBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//        @strongify(self);
//        [self enterMyWallet];
//    }];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:walletBtn];
    
    UIButton *setBtn = [[UIButton alloc]initWithFrame:RIGHTBARBTNFRAME];
    [setBtn setImage:[BundleTool imageNamed:@"me_seting"] forState:UIControlStateNormal];
    [setBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [[setBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self tagClick];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:setBtn];
    
}


#pragma mark ---Event--
- (void)enterMyWallet{
    
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    MyWalletViewController *myWalletVC = [[MyWalletViewController alloc]init];
    [self.navigationController pushViewController:myWalletVC animated:YES];
    [QMPEvent event:@"me_wallet_click"];
}


#pragma mark 进入领域
- (void)eterLingYuListVc{
    if ([self isUserLogin]) {
        [self enterSelectedItemListVC:3];
    }
}
#pragma mark 进入项目
- (void)enterXiangMuListVc{
    if ([self isUserLogin]) {
        [self enterSelectedItemListVC:1];
    }
}
#pragma mark 进入机构
- (void)enterJiGouListVC{
    if ([self isUserLogin]) {
        [self enterSelectedItemListVC:2];
    }
}
- (void)eterPersonListVc{
    if ([self isUserLogin]) {
        [self enterSelectedItemListVC:0];
    }
}

- (void)enterSelectedItemListVC:(NSInteger)selectedIndx{
    METopItemParentVC * topItemPVC = [[METopItemParentVC alloc] init];
    topItemPVC.topPageMenu.selectedItemIndex = selectedIndx;
    [self.navigationController pushViewController:topItemPVC animated:YES];
}

- (void)clickCancelTarget:(UIButton *)btn{
    [USER_DEFAULTS setBool:YES forKey:isEditedMyInfo];
    [USER_DEFAULTS synchronize];
    
    [self topShowMsg];
}

#pragma mark 是否登录
- (BOOL)isUserLogin{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return NO;
    }else{
        return YES;
    }
}

-(UIImageView *)bgHeaderVw{
    if (_bgHeaderVw == nil) {
        _bgHeaderVw = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 186)];
        _bgHeaderVw.backgroundColor = TABLEVIEW_COLOR;
        _bgHeaderVw.userInteractionEnabled = YES;
        [_bgHeaderVw addSubview:self.headerView];
        [_bgHeaderVw addSubview:self.belowItemVw];
    }
    return _bgHeaderVw;
}
/**
 *  构建头部
 */
- (void)builHeaderView{
    
    self.tableView.tableHeaderView = self.bgHeaderVw;
    
    [self.tableView.tableHeaderView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterMyInfo)]];
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"登录企名片体验更多功能"];
    if (@available(iOS 8.2, *)) {
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium] range:NSMakeRange(0, 5)];
    }else{
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, 5)];
    }
    _headerView.loginInfoLbl.attributedText = attributeStr;
    
    [self changeView];
}

- (void)changeView {
    
    BOOL isLogin = ![PublicTool isNull:[WechatUserInfo shared].unionid];
    if (!isLogin) {
        [self changeViewWhenLoginOut];
        return;
    } else {
        
        _headerView.arrowBtn.hidden = NO;
        _headerView.nameLbl.hidden = NO;
        _headerView.loginInfoLbl.hidden = YES;
        _headerView.infoLbl.hidden = NO;
        _headerView.bindPhoneLab.hidden = NO;
        
        [self showheadTxtSytle];
        
        _headerView.nameLbl.text = [WechatUserInfo shared].nickname;
        [_headerView.iconButton sd_setBackgroundImageWithURL:[NSURL URLWithString:[WechatUserInfo shared].headimgurl] forState:UIControlStateNormal placeholderImage:[BundleTool imageNamed:@"heading"] ];
    }
}

- (void)changeViewWhenLoginOut {
    _headerView.arrowBtn.hidden = YES;
    _headerView.nameLbl.hidden = YES;
    _headerView.infoLbl.hidden = YES;
    _headerView.loginInfoLbl.hidden = NO;
    _headerView.bindPhoneLab.hidden = YES;
    _headerView.homePageLab.hidden = YES;
    _headerView.rzStatusLbl.hidden = YES;
    [_headerView.iconButton setBackgroundImage:[BundleTool imageNamed:@"heading"] forState:UIControlStateNormal];
    [self changeTopItemNumber];
}
/**
 *  登录后改变UI,以及标志位
 */
- (void)changeInfo:(NSNotification *)noti{
    
    [self changeView];
}


#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableConfigDatas.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rows = self.tableConfigDatas[section];
    return rows.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SettingTableViewCellID";
    
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSArray *rows = self.tableConfigDatas[indexPath.section];
    NSDictionary *rowDict = rows[indexPath.row];
    
    cell.titleLab.text = rowDict[@"title"];
    cell.leftImageV.image = [BundleTool imageNamed:rowDict[@"icon"]];
    
    cell.lineView.hidden = (indexPath.row+1 == rows.count);
    
    cell.redPointView.hidden = YES;
    cell.keyRedView.hidden = YES;
    
    [self.tabBarItem setBadgeValue:nil];
    if ([ToLogin isLogin]) {
        if ([rowDict[@"title"] isEqualToString:@"工作台"]) { //BP管理
            if ([WechatUserInfo shared].bp_count.integerValue) {
                cell.keyRedView.hidden = NO;
                [self.tabBarController.tabBar showBadgeOnItemIndex:3];
            }else{
                cell.keyRedView.hidden = YES;
                [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
            }
            
        }else if ([rowDict[@"title"] isEqualToString:@"通讯录"]) { //BP管理
            if([WechatUserInfo shared].exchange_card_count.integerValue){
                cell.keyRedView.hidden = NO;
                [self.tabBarController.tabBar showBadgeOnItemIndex:3];
                
            }else{
                cell.keyRedView.hidden = YES;
                [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
            }
            
        }else{
            cell.keyRedView.hidden = YES;
        }
    }else{
        cell.keyRedView.hidden = YES;
        [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
        
    }
    
    //更多 私人笔记入口
    if ([rowDict[@"title"] isEqualToString:@"工作台"]) {
        UILabel * tipLab = [cell.contentView viewWithTag:1000];
        if (!tipLab) {
            tipLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREENW - 40 - 150, 10, 150, 32)];
            [tipLab labelWithFontSize:14 textColor:HCCOLOR];
            tipLab.textAlignment = NSTextAlignmentRight;
            tipLab.text = @"BP 文档 笔记 专辑...";
            [cell.contentView addSubview:tipLab];
            tipLab.tag = 1000;
        }
        
    }else{
        UILabel * tipLab = [cell.contentView viewWithTag:1000];
        if (tipLab) {
            [tipLab removeFromSuperview];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 10)];
    v.backgroundColor = TABLEVIEW_COLOR;
    return v;
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSArray *rows = self.tableConfigDatas[indexPath.section];
    NSDictionary *rowDict = rows[indexPath.row];
    
    SEL selector = NSSelectorFromString(rowDict[@"action"]);
    ((void (*)(id, SEL))[self methodForSelector:selector])(self, selector);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        CGRect frame = _underView.frame;
        frame.size.height = kStatusBarHeight - scrollView.contentOffset.y;
        _underView.frame = frame;
        
    } else {
        CGRect frame = _underView.frame;
        frame.size.height = kStatusBarHeight;
        _underView.frame = frame;
    }
}


#pragma mark - AllFeedbackViewDelegate
- (void)feedbackSuccess{
    [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
}

#pragma mark - SetTableViewControllerDelegate
- (void)pressQuitLoginBtn{
    
    QMPLog(@"点击退出--%s",__FUNCTION__);
    [[WechatUserInfo shared] clear];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFI_QUITLOGIN object:@"0"];
    //    [self changeViewWhenLoginOut];
    [USER_DEFAULTS setValue:nil forKey:@"lastLoginTime"];
    [ShowInfo showInfoOnView:self.view withInfo:@"退出成功"];
    [self.tableView reloadData];
    
    __block NSInteger sequ = 0;
    [JPUSHService setAlias:nil completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        sequ = seq;
    } seq:sequ];
}
#pragma mark - Other Event
- (void)tapIconImageV:(UIButton *)sender {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    [self enterMyInfo];
    
}
- (void)enterMyInfo {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }
    
    if ([WechatUserInfo shared].claim_type.integerValue == 2) {
        
        PersonDetailsController *vc = [[PersonDetailsController alloc] init];
        vc.persionId = [WechatUserInfo shared].person_id;
        vc.isMy = YES;
        [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
        
    } else {
        [[AppPageSkipTool shared] appPageSkipToUserDetail:[WechatUserInfo shared].unionid];
    }
    [QMPEvent event:@"my_menu_click" label:@"我的主页"];
}
- (void)copyQIDBtnClick {
    UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
    if ([WechatUserInfo shared].usercode) {
        pastboard.string = [WechatUserInfo shared].usercode;
        [PublicTool showMsg:@"复制成功"];
    }
}

#pragma mark - Cell Event
//我的评论
- (void)enterMyComment{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    QMPMyActivityCommentViewController *vc = [[QMPMyActivityCommentViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [QMPEvent event:@"my_menu_click" label:@"我的评论"];

}
// 进入我的发布
- (void)enterMyPublishList {
    
    if(![ToLogin canEnterDeep]){
        [ToLogin accessEnterDeep];
        return;
    }
    
    MyActivitiesViewController *vc = [[MyActivitiesViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [QMPEvent event:@"my_menu_click" label:@"我的发布"];
    
}
// 进入我的反馈
- (void)enterMyFeedBack {
    
    if(![ToLogin canEnterDeep]){
        [ToLogin accessEnterDeep];
        return;
    }
    
    if ([self isUserLogin]) {
        MyFeedbackController *feedbackVC = [[MyFeedbackController alloc]init];
        [self.navigationController pushViewController:feedbackVC animated:YES];
        [QMPEvent event:@"me_tab_feedClick"];
    }
}


// 进入设置页面
- (void)tagClick {
    
    SetTableViewController *settingsVC = [[SetTableViewController alloc]init];
    settingsVC.delegate = self;
    [self.navigationController pushViewController:settingsVC animated:YES];
    [QMPEvent event:@"my_menu_click" label:@"我的设置"];

}
// App分享
- (void)extensionShare {
    
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        NSString *titleSessionStr = [NSString stringWithFormat:@"企名片App·商业信息服务平台"];
        NSString *titleTimelineStr = [NSString stringWithFormat:@"企名片App·商业信息服务平台"];
        NSString *detailStr = [NSString stringWithFormat:@"百万创业者十万投资人都在用的App"];
        [self.shareToTool shareToOtherApp:detailStr aTitleSessionStr:titleSessionStr aTitleTimelineStr:titleTimelineStr aIcon:[BundleTool imageNamed:@"87"] aOpenUrl:@"http://wx.qimingpian.com/cb/download.html"  onViewController:self shareResult:^(BOOL shareSuccess) {
            if (shareSuccess) {//
            }
        }];
        
    }
    [QMPEvent event:@"my_menu_click" label:@"分享app"];
}

// 我的投币&收藏
- (void)enterMyCollect{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    CommentLikeActivityViewController *vc = [[CommentLikeActivityViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [QMPEvent event:@"my_menu_click" label:@"点赞收藏"];
}
- (void)enterMyCard{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    //交换的名片
    CardExchangeListController *cardVC = [[CardExchangeListController alloc] init];
    [self.navigationController pushViewController:cardVC animated:YES];
    [QMPEvent event:@"my_menu_click" label:@"通讯录"];
}

- (void)enterProductContact{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    ProductContactsController *contactVC = [[ProductContactsController alloc]init];
    [self.navigationController pushViewController:contactVC animated:YES];
}

#pragma mark 更多
- (void)enterMoreItemList{
    
    MeMoreItemListVC * moreVC = [[MeMoreItemListVC alloc] init];
    [self.navigationController pushViewController:moreVC animated:YES];
    [QMPEvent event:@"my_menu_click" label:@"工作台"];
}


#pragma  mark - 懒加载
- (MyTabHeaderView *)headerView{
    if (_headerView == nil) {
        _headerView = [[[BundleTool commonBundle]loadNibNamed:@"MyTabHeaderView" owner:nil options:nil] lastObject];
        _headerView.backgroundColor = [UIColor whiteColor];
        _headerView.frame = CGRectMake(0, 12, SCREENW, 92);
        _headerView.iconButton.layer.cornerRadius = 30.0f;
        _headerView.iconButton.layer.masksToBounds = YES;
        _headerView.iconButton.layer.borderColor = HTColorFromRGB(0xe1e1e1).CGColor;
        _headerView.iconButton.layer.borderWidth = 0.5;
        [_headerView.iconButton addTarget:self action:@selector(tapIconImageV:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView.arrowBtn addTarget:self action:@selector(tapIconImageV:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _headerView;
}
- (MYHeaderItemVwbyXib *)belowItemVw{
    if (_belowItemVw == nil) {
        _belowItemVw = [[[BundleTool commonBundle] loadNibNamed:@"MYHeaderItemVwbyXib" owner:self options:nil] lastObject];
        _belowItemVw.frame = CGRectMake(0, 116, SCREENW, 74);
        _belowItemVw.backgroundColor = [UIColor whiteColor];
        [_belowItemVw.personBtn addTarget:self action:@selector(eterPersonListVc) forControlEvents:UIControlEventTouchUpInside];
        [_belowItemVw.lingyBtn addTarget:self action:@selector(eterLingYuListVc) forControlEvents:UIControlEventTouchUpInside];
        [_belowItemVw.xiangmBtn addTarget:self action:@selector(enterXiangMuListVc) forControlEvents:UIControlEventTouchUpInside];
        [_belowItemVw.jigBtn addTarget:self action:@selector(enterJiGouListVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _belowItemVw;
}
- (UIView *)showAlertMessageBgVw{
    if (_showAlertMessageBgVw == nil) {
        _showAlertMessageBgVw = [[UIView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, SCREENW, 35)];
        _showAlertMessageBgVw.backgroundColor = [UIColor colorWithRed:213/255.0 green:232/255.0 blue:255/255.0 alpha:1/1.0];
        
        UIButton * clickCancelBtn= [UIButton buttonWithType:UIButtonTypeCustom];
        clickCancelBtn.frame = CGRectMake(7, 0, 40, 35);
        [clickCancelBtn setImage:[BundleTool imageNamed:@"my_close"] forState:UIControlStateNormal];
        [clickCancelBtn addTarget:self action:@selector(clickCancelTarget:) forControlEvents:UIControlEventTouchUpInside];
        [_showAlertMessageBgVw addSubview:clickCancelBtn];
        
        UILabel * msgLbl = [[UILabel alloc] initWithFrame:CGRectMake(clickCancelBtn.right, 4,200, 28)];
        msgLbl.textColor =  [UIColor colorWithRed:13/255.0 green:125/255.0 blue:255/255.0 alpha:1/1.0];
        msgLbl.text = @"您已认证成功，请尽快完善资料";
        msgLbl.font = [UIFont systemFontOfSize:14];
        [_showAlertMessageBgVw addSubview:msgLbl];
        [msgLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterMyInfo)]];
        
        UIButton * nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextBtn setImage:[BundleTool imageNamed:@"rightarrow_quan"] forState:UIControlStateNormal];
        [nextBtn setImage:[BundleTool imageNamed:@"rightarrow_quan"] forState:UIControlStateHighlighted];
        
        nextBtn.frame = CGRectMake(SCREENW - 50-17, 0, 50, 35);
        [nextBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [nextBtn addTarget:self action:@selector(enterMyInfo) forControlEvents:UIControlEventTouchUpInside];
        [_showAlertMessageBgVw addSubview:nextBtn];
    }
    return _showAlertMessageBgVw;
}

- (NSArray *)tableConfigDatas {
    if (!_tableConfigDatas) {
        _tableConfigDatas = @[
                              @[
                                  @{@"title":@"我的发布", @"icon":@"me_noteIcon", @"action":@"enterMyPublishList", @"extra":@"..."},
                                  @{@"title":@"评论点赞", @"icon":@"me_commentIcon", @"action":@"enterMyCollect", @"extra":@"..."},
                                  @{@"title":@"委托联系", @"icon":@"me_productContact", @"action":@"enterProductContact", @"extra":@"..."},
                                  @{@"title":@"通讯录",@"icon":@"me_contact",@"action":@"enterMyCard",@"extra":@"..."},
                                  @{@"title":@"工作台", @"icon":@"me_more", @"action":@"enterMoreItemList", @"extra":@"..."},
                                  ],
                              @[
                                  @{@"title":@"分享App", @"icon":@"me_share", @"action":@"extensionShare", @"extra":@"..."},
                                  @{@"title":@"给个好评", @"icon":@"me_goodcomment", @"action":@"goodReputation", @"extra":@"..."},
                                  @{@"title":@"我的反馈", @"icon":@"me_kefu", @"action":@"enterMyFeedBack", @"extra":@"..."}                                  ],
                              ];
    }
    return _tableConfigDatas;
}

- (ShareTo *)shareToTool {
    if (!_shareToTool) {
        _shareToTool = [[ShareTo alloc] init];
    }
    return _shareToTool;
}
- (void)goodReputation {
    if (APPSTORE) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE]];
    }
    [QMPEvent event:@"my_menu_click" label:@"给个好评"];
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)getUnReadCount{
    if (![ToLogin isLogin]) {
        return;
    }
    
    if ([PublicTool isNull:[WechatUserInfo shared].vip]) {
        return;
    }
    
    //请求好友申请 和  通知未读
    NSDictionary *dic = @{@"keyword":[WechatUserInfo shared].vip};
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"user/getBpCardCoutByUnionid" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            
            [WechatUserInfo shared].apply_count = resultData[@"apply_count"];
            [WechatUserInfo shared].bp_count = resultData[@"bp_count"];
            [WechatUserInfo shared].exchange_card_count = resultData[@"exchange_card_count"];
            [WechatUserInfo shared].system_notification_count = resultData[@"system_notification_count"];
            [WechatUserInfo shared].activity_notifi_count = resultData[@"activity_notifi_count"];
            [[WechatUserInfo shared] save];
            
            //如果交换的名片 和收到的BP有未读
            if ([resultData[@"bp_count"] integerValue] || [resultData[@"exchange_card_count"] integerValue]) {
                [[PublicTool topViewController].tabBarController.tabBar showBadgeOnItemIndex:3];
            }else{
                [[PublicTool topViewController].tabBarController.tabBar hideBadgeOnItemIndex:3];
            }
            
            [self.tableView reloadData];
        }
    }];
}
#pragma mark 获取项目、机构、领域的数量
- (void)getNumberOfAttetion{
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"focus/getFocusCount" HTTPBody:nil completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        self.belowItemVw.personCountLbl.text = [PublicTool nilStringReturn:resultData[@"person"]];
        self.belowItemVw.lingyNumLbl.text = [PublicTool nilStringReturn:resultData[@"theme"]];
        self.belowItemVw.xingmNumLbl.text = [PublicTool nilStringReturn:resultData[@"product"]];
        self.belowItemVw.jigNumLbl.text = [PublicTool nilStringReturn:resultData[@"jigou"]];
    }];
}

#pragma mark 登录请求数据需要赋值，登出需要置空
- (void)changeTopItemNumber{
    
    self.belowItemVw.personCountLbl.text = @"0";
    self.belowItemVw.lingyNumLbl.text = @"0";
    self.belowItemVw.xingmNumLbl.text = @"0";
    self.belowItemVw.jigNumLbl.text = @"0";
}

//-(UIStatusBarStyle)preferredStatusBarStyle{
//    return UIStatusBarStyleLightContent;
//}

@end
