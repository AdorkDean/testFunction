//
//  CompanyInvestorsController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/4.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CompanyInvestorsController.h"
#import "ProInvestorCell.h"
#import "CompanyDetailBasicModel.h"
#import "CustomAlertView.h"
#import "IPOCompanyCell.h"
#import "GestureScrollView.h"
#import "SPPageMenu.h"
#import "SearchJigouCell.h"
#import "ManagerItem.h"

#define TOPHEIGHT  70
#define SCROLLHEIGHT  (SCREENH - kScreenTopHeight - TOPHEIGHT - 44 - kScreenBottomHeight)

@interface CompanyInvestorsController ()<UITableViewDataSource,UITableViewDelegate,SPPageMenuDelegate>
{
    NSString *_countrStr;
    NSString *_jigouCount;
    NSInteger _selectedIndex;
    
}

@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *jigouArr;

@property (nonatomic,strong) UIView * investerFeedbackBgVw;
@property (nonatomic,strong) UILabel * investerFeedBackShowMessageLbl;
@property (nonatomic,strong) UIButton * investerFeedBackBtn;
@property (nonatomic,strong) SPPageMenu *pageMenu;
@property (nonatomic,strong)GestureScrollView *scrollV;
@property (nonatomic,strong)UITableView *jigouTableV;


@end

@implementation CompanyInvestorsController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _selectedIndex = 0;
    _countrStr = @"0";
    _jigouCount = @"0";
    
    self.title = @"投资人";
    self.currentPage = 1;
    self.numPerPage = 20;
    [self initView];
    [self showHUD];
    [self requestData];
}

- (void)initView{
    
    [self initTableView];
    
    [self addView];

    [self buildRightButton];
    
    [self.view addSubview:self.investerFeedbackBgVw];

}

- (void)buildRightButton{
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [btn setTitle:@"反馈" forState:UIControlStateNormal];
    [btn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn addTarget:self action:@selector(feedbackDetail:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
}


- (void)addView{
    
//    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, TOPHEIGHT)];
//    headerV.backgroundColor = [UIColor whiteColor];
//
//    IPOCompanyCell *companyCell = [[IPOCompanyCell alloc]initWithFrame:CGRectMake(0,0, SCREENW, 60)];
//    [companyCell refreshUI:self.companyModel];
//    companyCell.bottomLine.hidden = YES;
//
//    [headerV addSubview:companyCell];
//
//    companyCell.frame = CGRectMake(0, 0, SCREENW, 65);
//    [headerV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterCompanyDetailVC)]];
//
//    UIView *grayV = [[UIView alloc]initWithFrame:CGRectMake(0, 65, SCREENW, 5)];
//    grayV.backgroundColor = TABLEVIEW_COLOR;
//    [headerV addSubview:grayV];
//
//    [self.view addSubview:headerV];
//
//    [self.view addSubview:self.pageMenu];
    [self.view addSubview:self.tableView];
    
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    self.tableView.mj_header = self.mjHeader;
    
    self.tableView.mj_footer = self.mjFooter;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProInvestorCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"ProInvestorCellID"];
//    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"headerView"];

    
//    self.jigouTableV = [[UITableView alloc] initWithFrame:CGRectMake(SCREENW, 0, SCREENW, SCROLLHEIGHT) style:UITableViewStyleGrouped];
//    self.jigouTableV.backgroundColor = TABLEVIEW_COLOR;
//    self.jigouTableV.delegate = self;
//    self.jigouTableV.dataSource = self;
//    self.jigouTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
//
//    self.jigouTableV.mj_header = nil;
//    self.jigouTableV.mj_footer = nil;
//
//    self.jigouTableV.estimatedRowHeight = 0;
//    self.jigouTableV.estimatedSectionHeaderHeight = 0;
//    self.jigouTableV.estimatedSectionFooterHeight = 0;
//
//    [self.jigouTableV registerClass:[SearchJigouCell class] forCellReuseIdentifier:@"SearchJigouCellID"];
    
}


- (void)enterCompanyDetailVC{
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:self.companyModel.detail]];
}

- (void)pullDown{
    
    if (_scrollV.contentOffset.x == 0) {
        self.currentPage = 1;
        [self requestPerson];
    }
}

- (void)pullUp{
    
    self.currentPage ++;
    [self requestPerson];
}

-(BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    
    [self requestPerson];
    
//    //请求投资机构
//    [self requestJigou];
    
    return YES;
}

- (void)requestPerson{
    
    NSInteger isdebug = [self.tableView.mj_header isRefreshing] ? 1 : 0;
    NSDictionary *dic = @{@"page":@(self.currentPage),@"num":@(self.numPerPage),@"debug":@(isdebug),@"ticket":self.ticket?:@""};
    
    [AppNetRequest getProductInvestorListWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        [PublicTool dismissHud:KEYWindow];
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && [resultData isKindOfClass:[NSDictionary class]] && resultData[@"list"]) {
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                PersonModel *person = [[PersonModel alloc]initWithDictionary:dic error:nil];
                [arr addObject:person];
            }
            if (self.currentPage == 1) {
                [self.dataArr removeAllObjects];
                _countrStr = resultData[@"count"];
//                self.pageMenu = nil;
//                [self.view addSubview:self.pageMenu];
            }
            
            [self.dataArr addObjectsFromArray:arr];
            [self refreshFooter:arr];
           
            [self.tableView reloadData];
        }
    }];
}

- (void)requestJigou{
    
    NSDictionary *dic = @{@"product":self.companyModel.product};
    
    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"d/getInvestorByProduct" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:KEYWindow];
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && resultData[@"list"]) {
            _jigouCount = resultData[@"count"];
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                [arr addObject:dic];
            }
            [self.jigouArr removeAllObjects];
            [self.jigouArr addObjectsFromArray:arr];
        
            [self refreshFooter:@[]];
            [self.jigouTableV reloadData];
            self.pageMenu = nil;
            [self.view addSubview:self.pageMenu];
        }

    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 反馈
//人物反馈
- (void)managerFeedBack:(PersonModel*)person{
    
    NSArray *mArr = @[@"人物信息不全",@"人物信息有误",@"人物头像有误"];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息
    [infoDic setValue:@"人物信息" forKey:@"module"];
    [infoDic setValue:@"人物信息" forKey:@"title"];
    
    if (![PublicTool isNull:person.name]) {
        [infoDic setValue:person.name forKey:@"company"];
    }else{
        [infoDic setValue:@"" forKey:@"company"];
    }
    
    [infoDic setValue:person.personId forKey:@"product"];
    
    
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:CGRectZero WithAlertViewHeight:50 infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
    
}


- (void)feedbackDetail:(UIButton *)sender{ //全局反馈

    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息
    NSInteger moduleNum = 0;
   
    [infoDic setValue:@"项目投资人" forKey:@"module"];

    CGFloat height = 0;
    if (![PublicTool isNull:self.companyModel.product]) {
        [infoDic setValue:self.companyModel.product forKey:@"product"];
    }else{
        [infoDic setValue:@"" forKey:@"product"];
    }
    if (![PublicTool isNull:self.companyModel.company]) {
        [infoDic setValue:self.companyModel.company forKey:@"company"];
    }else{
        [infoDic setValue:@"" forKey:@"company"];
    }

    [infoDic setValue:@"项目投资方" forKey:@"title"];
    [mArr addObject:@"缺少投资方"];
    [mArr addObject:@"投资方信息不全"];
    [mArr addObject:@"投资轮次有误"];
    
    if (mArr.count>0) {
        
        height += (mArr.count/2)*35  + (mArr.count/2-1)*15;
    }
    
    [self feedbackAlertView:mArr frame:CGRectZero WithAlertViewHeight:height moduleDic:infoDic moduleNum:moduleNum];
    
}

- (void)feedbackAlertView:(NSMutableArray *)mArr frame:(CGRect)frame WithAlertViewHeight:(CGFloat)height moduleDic:(NSDictionary *)infoDic moduleNum:(NSInteger)num{
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:frame WithAlertViewHeight:height infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:num isFeeds:NO];
}



#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
    return 55.0f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;

}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
   
    return [[UIView alloc]init];
    
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    
    UIView *headV = [headerView viewWithTag:900];
    if (!headV) {
        headV = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREENW, 44)];
        headV.tag = 900;
        [headerView addSubview:headV];
        
        //    if (dataArr.count > 0) {
        headV.backgroundColor = [UIColor whiteColor];
        
        CGFloat top = 16;
        UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(17, top, 2, 14)];
        lineV.backgroundColor = RED_TEXTCOLOR;
        [headV addSubview:lineV];
        
        UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(25, 12, 200, 21)];
        infoLbl.font = [UIFont systemFontOfSize:15.f];
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
        UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0,43.5, headV.width, 0.5)];
        bottomLine.backgroundColor = LIST_LINE_COLOR;
        [headV addSubview:bottomLine];
    }
    
    UILabel *label = [headV viewWithTag:9000];
    if (tableView == self.tableView) {
        label.text = [NSString stringWithFormat: @"项目投资人(%@)",_countrStr];
    }else{
        label.text = [NSString stringWithFormat: @"项目投资机构(%@)",_jigouCount];
    }
    return headerView;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return self.dataArr.count ? self.dataArr.count:1;
    }
    return self.jigouArr.count ? self.jigouArr.count:1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        return self.dataArr.count ? 83:SCREENH - kScreenTopHeight - 44;
    }
    return self.jigouArr.count ? 77:SCREENH - kScreenTopHeight - 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if (tableView == self.tableView) {
        if (self.dataArr.count == 0) {
            NSString *title = REQUEST_DATA_NULL;
            return [self nodataCellWithInfo:title tableView:tableView];
            
        }else{
            ProInvestorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProInvestorCellID" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.person = self.dataArr[indexPath.row];
            cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
            return cell;
        }
        
    }
    if (self.jigouArr.count == 0) {
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
        
    }else{
        
        SearchJigouCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchJigouCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *dic = self.jigouArr[indexPath.row];
        [cell refreshTzJigouUI:dic];
        
        [cell refreshIconColor:RANDOM_COLORARR[indexPath.row%6]];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tableView) {
        if (self.dataArr.count == 0) {
            return;
        }
        PersonModel *person = self.dataArr[indexPath.row];
        [[AppPageSkipTool shared] appPageSkipToPersonDetail:person.personId nameLabBgColor:RANDOM_COLORARR[indexPath.row%6]];

        [QMPEvent event:@"trz_person_cellclick"];
    }
    
    if (self.jigouArr.count == 0) {
        return;
    }
    NSDictionary *dic = self.jigouArr[indexPath.row];
    NSString *detail = dic[@"detail"];
    [[AppPageSkipTool shared] appPageSkipToDetail:detail];

}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return NO;
  
}

#pragma mark --SPPagemenuDelegate--

-(void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    [_scrollV setContentOffset:CGPointMake(toIndex*SCREENW, 0) animated:YES];
}

#pragma mark - 懒加载
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _dataArr;
}

- (NSMutableArray *)jigouArr{
    if (!_jigouArr) {
        _jigouArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _jigouArr;
}

#pragma mark - 新增项目投资人-反馈
- (UIView *)investerFeedbackBgVw{
    if (_investerFeedbackBgVw == nil) {
        
        CGRect bgIframe = CGRectMake(0, SCREENH - kScreenTopHeight - kScreenBottomHeight, SCREENW, kScreenBottomHeight);
        _investerFeedbackBgVw = [[UIView alloc] initWithFrame:bgIframe];
        [_investerFeedbackBgVw addSubview:self.investerFeedBackShowMessageLbl];
        [_investerFeedbackBgVw addSubview:self.investerFeedBackBtn];
        
        _investerFeedbackBgVw.backgroundColor = [UIColor whiteColor];
        _investerFeedbackBgVw.layer.shadowColor = H9COLOR.CGColor;
        _investerFeedbackBgVw.layer.shadowOpacity = 0.1;
        _investerFeedbackBgVw.layer.shadowRadius = 3;
        _investerFeedbackBgVw.layer.shadowOffset = CGSizeMake(0, 0);
    }
    return _investerFeedbackBgVw;
}
- (UILabel *)investerFeedBackShowMessageLbl{
    if (_investerFeedBackShowMessageLbl == nil) {
        CGRect lblIframe = CGRectMake(15, (kScreenBottomHeight-16)/2.0, 200, 16);
        _investerFeedBackShowMessageLbl = [[UILabel alloc] initWithFrame:lblIframe];
        _investerFeedBackShowMessageLbl.font = [UIFont systemFontOfSize:14];
        _investerFeedBackShowMessageLbl.textColor = HTColorFromRGB(0x666666);
        _investerFeedBackShowMessageLbl.text = @"想要成为项目投资人？";
    }
    return _investerFeedBackShowMessageLbl;
}
- (UIButton *)investerFeedBackBtn{
    
    if (_investerFeedBackBtn == nil) {
        _investerFeedBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _investerFeedBackBtn.frame = CGRectMake(SCREENW - 140 - 15, (kScreenBottomHeight-32)/2.0, 140, 32);
        _investerFeedBackBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _investerFeedBackBtn.layer.cornerRadius = _investerFeedBackBtn.height / 2.0;
        [_investerFeedBackBtn setTitle:@"联系客服" forState:UIControlStateNormal];
        [_investerFeedBackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_investerFeedBackBtn setBackgroundColor:BLUE_BG_COLOR];
        
        [_investerFeedBackBtn addTarget:self action:@selector(jumpEnterPriseAssisant) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _investerFeedBackBtn;
}
#pragma mark 跳转客服
- (void)jumpEnterPriseAssisant{
     [PublicTool contactKefu:nil reply:kDefaultWel];
}

//-(GestureScrollView *)scrollV{
//
//    if (!_scrollV) {
//
//        _scrollV = [[GestureScrollView alloc]initWithFrame:CGRectMake(0, TOPHEIGHT+45, SCREENW, SCROLLHEIGHT)];
//        _scrollV.contentSize = CGSizeMake(SCREENW*2, SCROLLHEIGHT);
//        _scrollV.delegate = self;
//        _scrollV.pagingEnabled = YES;
//        _scrollV.bounces = NO;
//        _scrollV.showsHorizontalScrollIndicator = NO;
//        [_scrollV addSubview:self.tableView];
//        [_scrollV addSubview:self.jigouTableV];
//
//    }
//    return _scrollV;
//}

- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, TOPHEIGHT, SCREENW, 45) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        _pageMenu.bridgeScrollView = self.scrollV;
        _pageMenu.delegate = self;
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
        _pageMenu.itemPadding = 32*ratioWidth;
        
    }
   
    [_pageMenu setItems:@[[NSString stringWithFormat:@"投资人(%@)",_countrStr],[NSString stringWithFormat:@"投资机构(%@)",_jigouCount]] selectedItemIndex:_selectedIndex];

    return _pageMenu;
}

@end
