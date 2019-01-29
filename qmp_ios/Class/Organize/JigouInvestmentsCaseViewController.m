//
//  JigouInvestmentsCaseViewController.m
//  qmp_ios
//
//  Created by qimingpian10 on 2016/11/26.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "JigouInvestmentsCaseViewController.h"
#import "InvestementFilterView.h"
#import "JigouInvestmentsCaseModel.h"
#import "IndustryItem.h"

#import "CustomAlertView.h"
#import "JigouTZCaseCell.h"

@interface JigouInvestmentsCaseViewController () <UITableViewDelegate, UITableViewDataSource, InvestementFilterViewDelegate>
{
    UILabel *_filterLabel;
    BOOL isFilter;
    NSInteger filterNumber;
}


@property (nonatomic, strong) NSMutableArray *investmentsCaseMdata;
@property (nonatomic, strong) NSMutableArray *hangyeMArr;
@property (nonatomic, strong) NSMutableArray *lunciArr;
@property (nonatomic, strong) NSMutableArray *timeArr;
@property (nonatomic, strong) NSArray *actionArr;

@property (nonatomic, strong) InvestementFilterView *filterV;

@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) NSString *hangyeTitle;

@property (nonatomic, strong) JigouTZCaseCell *caseCell;


//@property (nonatomic, strong) UILabel *filterLabel;
//@property (nonatomic, assign) BOOL isFilter;
//@property (nonatomic, assign) NSInteger filterNumber;

@property (nonatomic, strong) NSMutableDictionary *heightCacheDict;
@end


@implementation JigouInvestmentsCaseViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_filterV removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 1;
    self.numPerPage = 20;
    
    [self buildRightBarButtonItem];
    [self buildInvestmentsCaseUI];
    [self showHUD];
    if ([self.actionArr indexOfObject:self.action] == 0) {
        [self requestJigouInvestmentsCase:self.parametersDic];
        
    }else{
        
        [self requestFACase:self.parametersDic];
    }
    
}

- (void)pullUp{
    
    self.currentPage ++;
    [self.parametersDic setValue:@"" forKey:@"debug"];
    if ([self.actionArr indexOfObject:self.action] == 0) {
        [self requestJigouInvestmentsCase:self.parametersDic];
        
    }else{
        
        [self requestFACase:self.parametersDic];
    }
    
}
#pragma mark - FeedbackResultDelegate

- (void)FeedbackResultSuccess{
    [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
}


/**
 *  点击左侧返回按钮
 */
- (void)pressLeftButtonItem:(id)sender{
    
    if (_filterV) {
        [_filterV removeFromSuperview];
        _filterV = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)buildRightBarButtonItem{
    
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
        NSUInteger moduleNum = 0;
        
        if ([self.actionArr indexOfObject:self.action] == 0) {
            [infoDic setValue:@"投资案例" forKey:@"module"];
            [mArr addObject:@"案例不全"];
            [mArr addObject:@"案例不对"];
            [infoDic setValue:@"机构投资案例" forKey:@"title"];

        }
        else{
            
            [infoDic setValue:@"FA服务案例" forKey:@"module"];
            [infoDic setValue:@"机构FA案例" forKey:@"title"];

            [mArr addObject:@"FA服务案例不全"];
            [mArr addObject:@"FA服务案例不对"];
        }
        
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
        
        
        if (mArr.count>0) {
            height += ((mArr.count-1)/2+1)*35 + 55.f;
        }

        [self feedbackAlertView:mArr frame:frame WithAlertViewHeight:height moduleDic:infoDic moduleNum:(int)moduleNum];
    }
}

- (void)feedbackAlertView:(NSMutableArray *)mArr frame:(CGRect)frame WithAlertViewHeight:(CGFloat)height moduleDic:(NSDictionary *)infoDic moduleNum:(int)num{
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:frame WithAlertViewHeight:height infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:num isFeeds:NO];
}
- (void)buildInvestmentsCaseUI{
    
    NSString *title = @"FA服务案例";
    if ([self.actionArr indexOfObject:self.action] == 0){
        title = @"投资案例";
    }
    self.title = title;
    
    [self initTableView];
}
- (void)initTableView{
    
    
    CGFloat top = 0;
    if ([self.actionArr indexOfObject:self.action] == 0) {
        UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];
        headView.backgroundColor = [UIColor whiteColor];
        _filterLabel = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, SCREENW - 17 - 44, 45)];
        [_filterLabel labelWithFontSize:14 textColor:H9COLOR];
        [headView addSubview:_filterLabel];
        
        UIButton *filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 44-3, 0, 44, 45)];
        [filterBtn addTarget:self action:@selector(pressFilterBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.filterBtn = filterBtn;
        [headView addSubview:self.filterBtn];
        if (self.selectedMArr.count) {
            _filterLabel.text = [NSString stringWithFormat:@"已选：%@",self.hangyeTitle];
            [self.filterBtn setImage:[BundleTool imageNamed:@"setBlue"] forState:UIControlStateNormal];
            
        }else{
            _filterLabel.text = [NSString stringWithFormat:@"投资案例%@个",self.organizeItem.tzcount];
            [self.filterBtn setImage:[BundleTool imageNamed:@"setgray2"] forState:UIControlStateNormal];
            
        }
        
        //line
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44, headView.width, 1)];
        line.backgroundColor = LIST_LINE_COLOR;
        [headView addSubview:line];
        [self.view addSubview:headView];
        top = 45;
    }
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, top, SCREENW, SCREENH-kScreenTopHeight-top) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = self.mjHeader;
    [self.tableView registerNib:[UINib nibWithNibName:@"JigouTZCaseCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"JigouTZCaseCellID"];
    [self.view addSubview:self.tableView];
}

#pragma mark - public
- (void)pullDown{
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:self.parametersDic];
    [mDict setValue:@"1" forKey:@"debug"];
    self.currentPage = 1;
    self.tableView.mj_footer = nil;
    if ([self.actionArr indexOfObject:self.action] == 0) {
        self.filterBtn.enabled = NO;

        [self requestJigouInvestmentsCase:mDict];
        
    }
    else{
        [self requestFACase:mDict];
    }
}

- (void)fillData{
    
    self.filterBtn.enabled = YES;
    if (self.selectedMArr.count || self.selectedLunciMArr.count) {
        if (self.selectedMArr.count == 0) {
            _filterLabel.text = @"轮次";
        }else{
            _filterLabel.text = [NSString stringWithFormat:@"已选：%@",self.hangyeTitle];
        }
        [self.filterBtn setImage:[BundleTool imageNamed:@"setBlue"] forState:UIControlStateNormal];
        
    }else{
        _filterLabel.text = [NSString stringWithFormat:@"投资案例%@个",self.organizeItem.tzcount];
        [self.filterBtn setImage:[BundleTool imageNamed:@"setgray2"] forState:UIControlStateNormal];
    }
    
    [self.tableView reloadData];
}

- (void)pressFilterBtn:(id)sender{
    
    if ([TestNetWorkReached networkIsReachedAlertOnView:self.view]) {
        
        if (isFilter) {
            isFilter = NO;
            [_filterV removeFromSuperview];
            _filterV = nil;
        }
        else{
            isFilter = YES;
            _filterV = [InvestementFilterView initWithFrame:CGRectMake(0, kScreenTopHeight, SCREENW, SCREENH - kScreenTopHeight) withSelectMArr:self.selectedMArr withHangyeArr:self.hangyeMArr withSelectLunciMArr:self.selectedLunciMArr withLunciArr:self.lunciArr];
            
            _filterV.delegate = self;
            [KEYWindow addSubview:_filterV];
           
        }
    }
}

#pragma mark - DrawerViewDelegate
- (void)updateRongziNews:(NSMutableArray *)selectedMArr lunciArr:(NSMutableArray *)selectedLunciMArr{
    
    if ((self.selectedMArr.count == selectedMArr.count) && (self.selectedLunciMArr.count == selectedLunciMArr.count)) {
        
        if ([self isEqualOfArr:self.selectedMArr withNewArr:selectedMArr] && [self isEqualOfArr:self.selectedLunciMArr withNewArr:selectedLunciMArr]) {
            isFilter = NO;
            return;
        }
    }
    
    for (IndustryItem *item in self.hangyeMArr) {
        
        if ([selectedMArr containsObject:item.name]) {
            item.selected = @"1";
        }
        else{
            item.selected = @"0";
        }
    }
    
    isFilter = YES;
    self.selectedMArr = [NSMutableArray arrayWithArray:selectedMArr];
    self.selectedLunciMArr = [NSMutableArray arrayWithArray:selectedLunciMArr];
    
    //刷新时不可筛选
    self.filterBtn.enabled = NO;
    if ([self.tableView visibleCells].count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    [self.tableView.mj_header beginRefreshing];
    
    _filterLabel.text = [NSString stringWithFormat:@"已选：%@",[self.selectedMArr componentsJoinedByString:@"|"]];
}

- (BOOL)isEqualOfArr:(NSArray *)oldArr withNewArr:(NSArray *)newArr{
    
    for (NSString *itemStr in newArr) {
        if (![oldArr containsObject:itemStr]) {
            return NO;
        }
    }
    return YES;
}

- (void)updateTzCase:(NSMutableArray *)selectedMArr withLunciMArr:(NSMutableArray *)lunciMArr withTime:(NSMutableArray *)timeMArr{
    
    
    [self handleSelect:selectedMArr withNowMArr:self.hangyeMArr];
    self.selectedMArr = [NSMutableArray arrayWithArray:selectedMArr];
    [self handleSelect:lunciMArr withNowMArr:self.lunciArr];
    self.selectedLunciMArr = [NSMutableArray arrayWithArray:lunciMArr];
    [self handleSelect:timeMArr withNowMArr:self.timeArr];
    self.selectedTimeMArr = [NSMutableArray arrayWithArray:timeMArr];
    
    isFilter = YES;
    //刷新时不可筛选
    self.filterBtn.enabled = NO;
    [self.tableView.mj_header beginRefreshing];
    
}
- (void)handleSelect:(NSMutableArray *)selectedMArr withNowMArr:(NSMutableArray *)nowMArr{
    
    for (IndustryItem *item in nowMArr) {
        
        if ([selectedMArr containsObject:item.name]) {
            item.selected = @"1";
        }
        else{
            item.selected = @"0";
        }
    }
}
#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.investmentsCaseMdata.count == 0) {
        return 1;
    }
    return self.investmentsCaseMdata.count;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.investmentsCaseMdata.count == 0 ) {
        return SCREENH - kScreenTopHeight - 35.f;
    }
    JigouInvestmentsCaseModel *caseModel = self.investmentsCaseMdata[indexPath.row];
    if (![self.heightCacheDict objectForKey:caseModel.detail]) {
        CGFloat height = [self.caseCell setCaseModel:caseModel];
        [self.heightCacheDict setValue:@(height) forKey:caseModel.detail];
        return height;
    }
    
    CGFloat height = [[self.heightCacheDict objectForKey:caseModel.detail] floatValue];
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.investmentsCaseMdata.count == 0 ) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
    else{
        
        JigouTZCaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JigouTZCaseCellID" forIndexPath:indexPath];
        [cell setCaseModel:self.investmentsCaseMdata[indexPath.row]];
        cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.investmentsCaseMdata.count == 0) {
        
        return;
    }else{
        JigouInvestmentsCaseModel *model = self.investmentsCaseMdata[indexPath.row];
        if (![PublicTool isNull:model.detail]) {
            [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:model.detail]];            
        }
    }
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.mj_header.isRefreshing) {
        return NO;
    }
    return YES;
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *preciseActionText = @"";
    
    JigouInvestmentsCaseModel *model = self.investmentsCaseMdata[indexPath.row];
    
    if (model.isFeedback) {
        preciseActionText = @"已反馈";
    }else{
        preciseActionText = @"案例不对";
    }
    
    UIContextualAction *isPreciseAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:preciseActionText handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
            [self mgsingleImmediateFeedbackUs:model];
        
    }];
    
    if (model.isFeedback) {
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
    
    JigouInvestmentsCaseModel *model = self.investmentsCaseMdata[indexPath.row];
    
    if (model.isFeedback) {
        preciseActionText = @"已反馈";
    }else{
        preciseActionText = @"案例不对";
    }
    
    UITableViewRowAction *isPreciseAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:preciseActionText handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self mgsingleImmediateFeedbackUs:model];
    }];
    
    if (model.isFeedback) {
        isPreciseAction.backgroundColor = [UIColor lightGrayColor];
    }else{
        isPreciseAction.backgroundColor = RED_TEXTCOLOR;
    }
    
    return @[isPreciseAction];
}

#pragma mark - 请求d/jigouFaCase -FA服务案例
- (void)requestFACase:(NSDictionary *)dict{ //没有分页
    
    if ([TestNetWorkReached networkIsReached:self]){
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dict];
        [dic setValue:@(self.currentPage) forKey:@"page"];
        [dic setValue:@(self.numPerPage) forKey:@"num"];

        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyFaCase470" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            [self hideHUD];
            
            if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
                
                NSMutableArray *touziMArr = [[NSMutableArray alloc] initWithCapacity:0];
                
                NSArray *touziArr = resultData[@"list"];
                for (NSDictionary *touziDict in touziArr) {
                    
                    JigouInvestmentsCaseModel *item = [[JigouInvestmentsCaseModel alloc] init];
                    [item setValuesForKeysWithDictionary:touziDict];
                    
                    [touziMArr addObject:item];
                    
                }
                
                if (self.currentPage == 1) {
                    [self.investmentsCaseMdata removeAllObjects];
                }
                [self.investmentsCaseMdata addObjectsFromArray:touziMArr];

                [self refreshFooter:touziMArr];
            }
            
            [self.tableView reloadData];
        }];
       
    }else{
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self hideHUD];
    }
}

#pragma mark - 请求投资列表
- (void)requestJigouInvestmentsCase:(NSDictionary *)requestDict{

    filterNumber = 0;
    
    NSString *hangye = [self hangleSearchKey:self.selectedMArr];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:requestDict];
    [mDict setValue:hangye forKey:@"hangye"];
    [mDict setValue:[self hangleSearchKey:self.selectedLunciMArr] forKey:@"lunci"];
//        [mDict setValue:[self hangleSearchKey:self.selectedTimeMArr] forKey:@"time"];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:mDict];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyInvestCompany470" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        self.filterBtn.enabled = YES;

        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            
            filterNumber = self.selectedMArr.count;
            _hangyeTitle = hangye;
            
            NSMutableArray *dataMarr = resultData[@"list"];
            
            NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *dataDict in dataMarr) {
                JigouInvestmentsCaseModel *investmentsCaseModel = [[JigouInvestmentsCaseModel alloc] init];
                [investmentsCaseModel setValuesForKeysWithDictionary:dataDict];
                [retMArr addObject:investmentsCaseModel];
            }
            if (self.currentPage == 1) {
                [self.investmentsCaseMdata removeAllObjects];
            }
            [self.investmentsCaseMdata addObjectsFromArray:retMArr];

            if (self.hangyeMArr.count == 0) {
                NSArray *hangyeArr = resultData[@"industry_list"];
                self.hangyeMArr = [self handleItemState:hangyeArr withSelectMArr:self.selectedMArr];
                
                NSArray *lunciArr = resultData[@"rotation_list"];
                self.lunciArr = [self handleItemState:lunciArr withSelectMArr:self.selectedLunciMArr];
                
                NSArray *timeArr = resultData[@"year_list"];
                self.timeArr = [self handleItemState:timeArr withSelectMArr:self.selectedTimeMArr];
            }
            
            [self refreshFooter:retMArr];
        }
        
        [self fillData];
        
        [self hideHUD];
        isFilter = NO;
    }];

}

- (NSString *)hangleSearchKey:(NSMutableArray *)selectedMArr{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:selectedMArr];
    NSString *key = @"";
    if ([arr containsObject:@"全部"]) {
        [arr removeObject:@"全部"];
    }
    if (arr && arr.count > 0) {
        
        for (int i = 0; i < arr.count; i++) {
            if (i == 0) {
                key = arr[0];
            }else{
                key = [NSString stringWithFormat:@"%@|%@",key,arr[i]];
            }
        }
    }
    return key;
}

#pragma mark - public

- (NSMutableArray *)handleItemState:(NSArray *)dataArr withSelectMArr:(NSMutableArray *)selectMArr{
    
    NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (id oneData in dataArr) {
        IndustryItem *item = [[IndustryItem alloc] init];
        if ([oneData isKindOfClass:[NSString class]]) {
            item.name = (NSString*)oneData;
        }else{
            item.name = [oneData valueForKey:@"name"];
        }
        
        item.selected = @"0";
        if (![item.name isEqualToString:@"全部"]) {
            [retMArr addObject:item];
        }
        
    }
    return retMArr;
}

- (void)mgsingleImmediateFeedbackUs:(JigouInvestmentsCaseModel *)managerModel{
    
    if (managerModel.isFeedback) {
        return;
    }
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        
        
        NSArray *managerArr = _investmentsCaseMdata;
        NSMutableString *desc = [NSMutableString stringWithCapacity:0];
        [desc appendString:@"案例不对"];

        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        [mDict setValue:@"投资案例" forKey:@"type"];
        [mDict setValue:@"" forKey:@"c1"];
        [mDict setValue:[NSString stringWithFormat:@"%ld",(unsigned long)managerArr.count] forKey:@"c2"];
        [mDict setValue:self.organizeItem.name forKey:@"company"];
        [mDict setValue:managerModel.product forKey:@"product"];
        
        [mDict setValue:desc forKey:@"desc"];
        
        if ([self.actionArr indexOfObject:self.action] == 1) {
            [mDict setValue:@"FA服务案例" forKey:@"type"];
        }
        
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/editcommonfeedback" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
        }];
        
        [self.tableView setEditing:NO];
        [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
    }
}
#pragma mark - 懒加载
- (NSMutableArray *)investmentsCaseMdata{
    if (!_investmentsCaseMdata) {
        _investmentsCaseMdata = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _investmentsCaseMdata;
}


- (NSMutableArray *)hangyeMArr{
    
    if (!_hangyeMArr) {
        _hangyeMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _hangyeMArr;
}

- (NSArray *)actionArr{
    
    if (!_actionArr) {
        _actionArr = @[@"investment",@"fa"];
    }
    return _actionArr;
}
-(JigouTZCaseCell *)caseCell{
    
    if (!_caseCell) {
        _caseCell = [[BundleTool commonBundle]loadNibNamed:@"JigouTZCaseCell" owner:nil options:nil].lastObject;
    }
    return _caseCell;
}
- (NSMutableDictionary *)heightCacheDict {
    if (!_heightCacheDict) {
        _heightCacheDict = [NSMutableDictionary dictionary];
    }
    return _heightCacheDict;
}
@end

