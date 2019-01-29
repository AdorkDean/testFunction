//
//  OrganizeManagerViewController.m
//  qmp_ios
//
//  Created by Molly on 2016/11/28.
//  Copyright © 2016年 Molly. All rights reserved.
// 公司要增加 相关员工

#import "OrganizeManagerViewController.h"
#import "ManagerItem.h"
#import "CustomAlertView.h"
#import "UnauthPeresonPageController.h"
#import "MemberPersonCell.h"
#import <YYTextLayout.h>
#import "InsetsLabel.h"

@interface OrganizeManagerViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>


@property (strong, nonatomic) NSArray *actionArr;
@property (strong, nonatomic) NSMutableArray *tableData;

@property (strong, nonatomic) ManagerHud *hudTool;

@property (strong, nonatomic) NSMutableArray *relateStaffArr; // 相关员工

@property (nonatomic, strong) UIView * contactBgVw;
@property (nonatomic,strong) UILabel * contactShowMsgLbl;
@property (nonatomic,strong) UIButton * contactBtn;
@end

@implementation OrganizeManagerViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentPage = 1;
    self.numPerPage = 15;
    [self initTableView];
    
    [self showHUD];
    
    NSString *title = @"";
    
    if (_action) {
        NSInteger index = [self.actionArr indexOfObject:_action];
        switch (index) {
            case 0:{
                //机构
                title = @"投资团队";
                [self requestJigouManager];
                
                break;
            }
            case 1:{
                //公司
                title = @"公司团队";
                [self requestCompanyManager];
                break;
            }
            default:
                break;
        }
    }
    [self buildRightBarButtonItem];
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
        return  SCREENH - kScreenTopHeight;
    }
    return UITableViewAutomaticDimension;
//    ManagerItem *item = _tableData[indexPath.row];
//    if (![PublicTool isNull:item.jieshao]) {
//
//        NSMutableAttributedString *atttext = [[NSMutableAttributedString alloc]initWithString:item.jieshao attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
//        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(SCREENW - 32-60, CGFLOAT_MAX) text:atttext];
//        if (layout.rowCount == 1) {
//            return 54+17;
//        }
//        return 54 + MIN(layout.rowCount,5) * 17;
//    }else{
//        return 72;
//    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableData.count == 0) {
        
        return [self nodataCellWithInfo:@"暂无团队成员" tableView:tableView];
    }else{
        
        ManagerItem *item = _tableData[indexPath.row];
        MemberPersonCell * memberCell = [tableView dequeueReusableCellWithIdentifier:@"MemberPersonCellID" forIndexPath:indexPath];
        memberCell.manager = item;
        memberCell.iconColor = RANDOM_COLORARR[indexPath.row%6];
        if ([_action isEqualToString:@"organize"] && (item.is_adviser.integerValue == 1)) {
            memberCell.hiddenStatusLab = YES;
        }
        memberCell.clickCardBtn.hidden = NO;
        memberCell.clickCardBtn.tag = 1000 + indexPath.row;
        [memberCell.clickCardBtn addTarget:self action:@selector(cellFeedbackClick:) forControlEvents:UIControlEventTouchUpInside];
        return memberCell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableData.count == 0) {
        return;
    }
    
    
    ManagerItem *item = _tableData[indexPath.row];
    
    if (![PublicTool isNull:item.person_id]) {
        [[AppPageSkipTool shared] appPageSkipToPersonDetail:item.personId nameLabBgColor:RANDOM_COLORARR[indexPath.row%6]];
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
    return NO;
    
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
- (void)cellFeedbackClick:(UIButton*)feedBtn{
    ManagerItem *item = _tableData[feedBtn.tag - 1000];
    [self managerFeedBack:item];

}
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
            [mDict setValue:self.organizeItem.name?:@"" forKey:@"company"];
            [mDict setValue:self.organizeItem.name?:@"" forKey:@"product"];
            
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
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
    [rightBtn setTitle:@"反馈" forState:UIControlStateNormal];
    [rightBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
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
    
    CGFloat tableHeight = SCREENH - kScreenTopHeight;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, tableHeight) style:UITableViewStyleGrouped];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.mj_header = self.mjHeader;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MemberPersonCell" bundle:nil] forCellReuseIdentifier:@"MemberPersonCellID"];
    
    
    [self.view addSubview:self.tableView];
    
    self.tableView.estimatedRowHeight = 80;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
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
                [self requestCompanyManager];
                
                break;
            }
            default:
                break;
        }
    }
}

-(void)pullUp{
    self.currentPage ++;
    NSInteger index = [self.actionArr indexOfObject:_action];
    switch (index) {
        case 0:{
            //机构
            [self requestJigouManager];
            
            break;
        }
        case 1:{
            [self requestCompanyManager];
            
            break;
        }
        default:
            break;
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
            [mDict setValue:self.companyItem.company?:@"" forKey:@"company"];
             [mDict setValue:self.companyItem.product?:@"" forKey:@"product"];
        }else if (self.organizeItem){
            [mDict setValue:self.organizeItem.name?:@"" forKey:@"company"];
            [mDict setValue:self.organizeItem.name?:@"" forKey:@"product"];
        }
        
        [mDict setValue:desc forKey:@"desc"];
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/editcommonfeedback" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
        }];
    }
}



#pragma mark - 请求公司团队
- (void)requestCompanyManager{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        
        NSString *debug = self.tableView.mj_header.isRefreshing ? @"1":@"0";
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.requestDict];
        [param setValue:debug forKey:@"debug"];
        [param setValue:@(self.currentPage) forKey:@"page"];
        [param setValue:@(self.numPerPage) forKey:@"num"];

        [AppNetRequest getCompanyPersonWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
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
                [self refreshFooter:managerMArr];
                [self.tableView reloadData];
            }
        }];
    }
    
}

- (void)requestJigouManager{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        NSString *debug = self.tableView.mj_header.isRefreshing ? @"1":@"0";
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.requestDict];
        [param setValue:debug forKey:@"debug"];
        [param setValue:@(self.currentPage) forKey:@"page"];
        [param setValue:@(self.numPerPage) forKey:@"num"];
        
        [AppNetRequest getJigouPersonWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
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
                [self refreshFooter:managerMArr];
                [self.tableView reloadData];
            }
        }];
        
    }
    
}

//- (void)showFeedbackAlert{
//    BOOL haveAlert = [USER_DEFAULTS boolForKey:[NSString stringWithFormat:@"showFeedbackAlert%@",self.action]];
//    if (!haveAlert) {
//        [PublicTool alertActionWithTitle:@"提示" message:@"向左滑动可反馈错误信息" btnTitle:@"确定" action:^{
//            [USER_DEFAULTS setValue:@(YES) forKey:[NSString stringWithFormat:@"showFeedbackAlert%@",self.action]];
//        }];
//    }
//
//}


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
