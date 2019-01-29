//
//  JointInvestmentDetailViewController.m
//  qmp_ios
//
//  Created by qimingpian10 on 2016/11/30.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "JointInvestmentDetailViewController.h"
#import "JigouInvestmentsCaseModel.h"

#import "SearchCompanyModel.h"
#import <UIImageView+WebCache.h>
#import "CustomAlertView.h"
#import "JigouTZCaseCell.h"

#define FEEDBACKBUTTONFRAME CGRectMake(8, 11.5, 20, 21)
@interface JointInvestmentDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (copy, nonatomic) NSString *productCount;
@property (strong, nonatomic) NSMutableArray *tableData;

@property (strong, nonatomic) NSMutableDictionary *heightCacheDict;


@property (nonatomic, strong) JigouTZCaseCell *caseCell;
@end

@implementation JointInvestmentDetailViewController



- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildRightBarButtonItem];
    [self buildJointInvestmentDetailUI];
    [self showHUD];

    [self requestData];
}

-(void)buildRightBarButtonItem{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"反馈" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
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
        
        if (self.model1&&self.model2) {
            [infoDic setValue:[NSString stringWithFormat:@"%@项目",self.title] forKey:@"module"];//模块
            if (![PublicTool isNull:self.model1.name]&&![PublicTool isNull:self.model2.name]) {
                [infoDic setValue:_model1.name forKey:@"c3"];
                [infoDic setValue:_model2.name forKey:@"c5"];
                [infoDic setValue:@"" forKey:@"product"];
            }else{
                [infoDic setValue:@"" forKey:@"c3"];
                [infoDic setValue:@"" forKey:@"c5"];
                [infoDic setValue:@"" forKey:@"product"];
            }
            [infoDic setValue:@"" forKey:@"company"];
        }
        
        [mArr addObject:[NSString stringWithFormat:@"%@项目不全",self.title]];
        [mArr addObject:[NSString stringWithFormat:@"%@项目不准",self.title]];
        moduleNum = [_model2.count integerValue];
        
        if (mArr.count>0) {
            height += ((mArr.count-1)/2+1)*35 + 55.f;
        }
        [infoDic setValue:@"合投项目信息" forKey:@"title"];

        [self feedbackAlertView:mArr frame:frame WithAlertViewHeight:height moduleDic:infoDic moduleNum:moduleNum];
    }
}

- (void)feedbackAlertView:(NSMutableArray *)mArr frame:(CGRect)frame WithAlertViewHeight:(CGFloat)height moduleDic:(NSDictionary *)infoDic moduleNum:(NSInteger)num{
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:frame WithAlertViewHeight:height infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:num isFeeds:NO];
}
- (void)buildJointInvestmentDetailUI{
    
    self.navigationItem.title  = [NSString stringWithFormat:@"%@公司",self.title];
    
    [self initTableView];
}
- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight+40) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"JigouTZCaseCell" bundle:nil] forCellReuseIdentifier:@"JigouTZCaseCellID"];
    [self addTableHeaderView];
    
    self.tableView.mj_header = self.mjHeader;
}


- (void)addTableHeaderView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 50)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, (SCREENW-40)/2, view.height);
//    [leftBtn addTarget:self action:@selector(clickJigouBtn:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.tag = 100;
    [leftBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [leftBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [leftBtn setTitleColor:HTColorFromRGB(0x1d1d1d) forState:UIControlStateNormal];
    [leftBtn setTitle:self.model1.name forState:UIControlStateNormal];
    [view addSubview:leftBtn];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(leftBtn.frame.origin.x+leftBtn.frame.size.width, 0, 40, view.height)];
    lab.text = @"-";
    [lab setTextColor:[UIColor grayColor]];
    [lab setFont:[UIFont systemFontOfSize:20]];
    lab.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lab];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(lab.frame.origin.x+lab.frame.size.width, 0, (SCREENW-40)/2, view.height);
    rightBtn.tag = 101;
    [rightBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightBtn setTitle:self.model2.name forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(clickJigouBtn:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];

    [view addSubview:rightBtn];
    self.tableView.tableHeaderView = view;
}
- (void)clickJigouBtn:(UIButton *)button{

    if (button.tag == 100) {
        if (![PublicTool isNull:self.model1.detail]) {
            [[AppPageSkipTool shared] appPageSkipToDetail:self.model1.detail];
            return;
        }
    }else{
        if (![PublicTool isNull:self.model2.detail]) {
            [[AppPageSkipTool shared] appPageSkipToDetail:self.model2.detail];

        }
    }
    
}


#pragma mark - UITableView
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];
    headV.backgroundColor = [UIColor whiteColor];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, SCREENW-17, 45)];
    [headV addSubview:lab];
    lab.font = [UIFont systemFontOfSize:14];
    
    NSString *info = @"";
    if ([self.title containsString:@"合投"]) {
        info = [NSString stringWithFormat:@"%@%@次、%@项目%@个",self.title,self.model2.count,self.title,self.productCount];
    }else{
    
        info = [NSString stringWithFormat:@"%@项目%@个",self.title,self.productCount];
    }
    lab.text = info;
    [lab setTextColor:H9COLOR];
    
    //两条线
    UIView *grayView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 1)];
    grayView1.backgroundColor = self.tableView.backgroundColor;
    [headV addSubview:grayView1];
    UIView *grayView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 44, SCREENW, 1)];
    grayView2.backgroundColor = self.tableView.backgroundColor;
    [headV addSubview:grayView2];
    
    return headV;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.title isEqualToString:@"合投"]) {
        JigouInvestmentsCaseModel *caseModel = self.tableData[indexPath.row];
        if (![self.heightCacheDict objectForKey:caseModel.detail]) {
            CGFloat height = [self.caseCell setCaseModel:caseModel];
            [self.heightCacheDict setValue:@(height) forKey:caseModel.detail];
            return height;
        }
        
        CGFloat height = [[self.heightCacheDict objectForKey:caseModel.detail] floatValue];
        return height;
    }
    return 75;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if([self.title isEqualToString:@"合投"]){
        JigouInvestmentsCaseModel *model = self.tableData[indexPath.row];
        JigouTZCaseCell * cell = [tableView dequeueReusableCellWithIdentifier:@"JigouTZCaseCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setCaseModel:model];

        return cell;
        
    } else {
        //参投
        JigouInvestmentsCaseModel *model = self.tableData[indexPath.row];

        JigouTZCaseCell * cell = [tableView dequeueReusableCellWithIdentifier:@"JigouTZCaseCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell layoutWithCaseModel:model];

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JigouInvestmentsCaseModel *model = self.tableData[indexPath.row];
    NSString *urlTmp = model.detail;

    if (![PublicTool isNull:urlTmp]) {
        [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:urlTmp]];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *overallActionText = @"";
    NSString *preciseActionText = @"";
    
    JigouInvestmentsCaseModel *model = self.tableData[indexPath.row];
    
    if (model.isPreciseFeedback) {
        preciseActionText = @"已反馈";
    }else{
        preciseActionText = [NSString stringWithFormat:@"不是%@案例",self.title];
    }
    if (model.isOverallFeedback) {
        overallActionText = @"已反馈";
    }else{
        overallActionText = @"案例数据出错";
    }
    
    UIContextualAction *isPreciseAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:preciseActionText handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        if (!model.isPreciseFeedback) {
            model.isPreciseFeedback = YES;
            [self mgsingleImmediateFeedbackUs:model];
        }
        [self.tableView setEditing:NO];
        
    }];
    UIContextualAction *isOverallAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:overallActionText handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        if (!model.isOverallFeedback) {
            model.isOverallFeedback = YES;
            [self mgsingleImmediateFeedbackUs:model];
        }
        
        [self.tableView reloadData];
    }];
    if (model.isPreciseFeedback) {
        isPreciseAction.backgroundColor = [UIColor lightGrayColor];
    }else{
        isPreciseAction.backgroundColor = RED_TEXTCOLOR;
    }
    if (model.isOverallFeedback) {
        isOverallAction.backgroundColor = [UIColor grayColor];
    }else{
        isOverallAction.backgroundColor = [UIColor orangeColor];
    }
    
    
    UISwipeActionsConfiguration *action = [UISwipeActionsConfiguration configurationWithActions:@[isPreciseAction,isOverallAction]];
    action.performsFirstActionWithFullSwipe = NO;
    return action;
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (iOS11_OR_HIGHER) {
        return @[];
        
    }
    
    NSString *overallActionText = @"";
    NSString *preciseActionText = @"";

    JigouInvestmentsCaseModel *model = self.tableData[indexPath.row];
    
    if (model.isPreciseFeedback) {
        preciseActionText = @"已反馈";
    }else{
        preciseActionText = [NSString stringWithFormat:@"不是%@案例",self.title];
    }
    if (model.isOverallFeedback) {
        overallActionText = @"已反馈";
    }else{
        overallActionText = @"案例数据出错";
    }
    
    UITableViewRowAction *isPreciseAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:preciseActionText handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (!model.isPreciseFeedback) {
            model.isPreciseFeedback = YES;
            [self mgsingleImmediateFeedbackUs:model];
        }
        
        [self.tableView setEditing:NO];
    }];
    UITableViewRowAction *isOverallAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:overallActionText handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (!model.isOverallFeedback) {
            model.isOverallFeedback = YES;
            [self mgsingleImmediateFeedbackUs:model];
        }
        
        [self.tableView reloadData];
    }];
    if (model.isPreciseFeedback) {
        isPreciseAction.backgroundColor = [UIColor lightGrayColor];
    }else{
        isPreciseAction.backgroundColor = RED_TEXTCOLOR;
    }
    if (model.isOverallFeedback) {
        isOverallAction.backgroundColor = [UIColor grayColor];
    }else{
        isOverallAction.backgroundColor = [UIColor orangeColor];
    }
    
    return @[isPreciseAction,isOverallAction];
}
- (void)mgsingleImmediateFeedbackUs:(JigouInvestmentsCaseModel *)managerModel{
    
    if (!managerModel.isPreciseFeedback&&!managerModel.isOverallFeedback) {
        return;
    }
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        
        NSMutableString *desc = [NSMutableString stringWithCapacity:0];
        if (managerModel.isPreciseFeedback) {
            [desc appendString:[NSString stringWithFormat:@"不是%@案例",self.title]];
            if (managerModel.isOverallFeedback) {
                [desc appendString: @"|案例数据出错"];
            }
        }else{
            if (managerModel.isOverallFeedback) {
                [desc appendString: @"案例数据出错"];
            }
        }
        
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        [mDict setValue:[NSString stringWithFormat:@"%@项目",self.title] forKey:@"type"];
        [mDict setValue:_model1.name forKey:@"c3"];
        [mDict setValue:_model2.name forKey:@"c5"];
        [mDict setValue:@"" forKey:@"c1"];
        [mDict setValue:[NSString stringWithFormat:@"%@",self.model2.count] forKey:@"c2"];
        
        if (managerModel.product) {
            [mDict setValue:managerModel.product forKey:@"product"];
        }else{
            [mDict setValue:@"" forKey:@"product"];
        }
        
        [mDict setValue:desc forKey:@"desc"];
        
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/editcommonfeedback" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
        }];
    }
}

- (void)FeedbackResultSuccess{
    [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    NSDictionary *jigouDetail = [PublicTool toGetDictFromStr:self.model1.detail];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:jigouDetail[@"ticket"] forKey:@"ticket"];
    [requestDict setValue:self.model2.agency_uuid forKey:@"combine_agency_uuid"];
    [requestDict setValue:@(self.currentPage) forKey:@"page"];
    [requestDict setValue:@(self.numPerPage) forKey:@"num"];

    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:self.action HTTPBody:requestDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
           
            NSMutableArray *listMArr = [[NSMutableArray alloc] initWithCapacity:0];
            NSArray *listArr = resultData[@"list"];
            self.productCount = resultData[@"count"];
            for (NSDictionary *dict in listArr) {
                JigouInvestmentsCaseModel *model = [[JigouInvestmentsCaseModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [listMArr addObject:model];
            }
            if (self.currentPage == 1) {
                [self.tableData removeAllObjects];
            }
            [self.tableData addObjectsFromArray:listMArr];
            [self refreshFooter:listMArr];
        }
        
        [self.tableView reloadData];
    }];
    return YES;
}

- (NSMutableArray *)tableData{

    if (!_tableData) {
        _tableData =  [NSMutableArray array];

    }
    return _tableData;
}



- (JigouTZCaseCell *)caseCell {
    if (!_caseCell) {
        _caseCell = [nilloadNibNamed:@"JigouTZCaseCell" owner:nil options:nil].lastObject;
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
