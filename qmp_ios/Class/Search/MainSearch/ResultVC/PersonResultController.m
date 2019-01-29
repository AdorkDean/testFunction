//
//  PersonResultController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonResultController.h"
#import "SearchPersonCell.h"
#import "GetMd5Str.h"
#import "AuthenticationController.h"
#import "TitleAndBtnBottomView.h"
#import "SearchPerson.h"
#define TabNameKey @"person"

@interface PersonResultController ()<UITableViewDataSource,UITableViewDelegate, CustomAlertViewDelegate>
{
   CGFloat originalOffSetY;
    NSString *_totalCount;
}
@property(nonatomic,strong)UIView *tableHeaderView;
@property (nonatomic, strong) TitleAndBtnBottomView *createFinanceView;

@end

@implementation PersonResultController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _totalCount = @"0";
    [self initTableView];
    
    self.currentPage = 1;
    self.numPerPage = 20;
    [self requestData];

    if ([WechatUserInfo shared].claim_type.integerValue == 0 || [WechatUserInfo shared].claim_type.integerValue == 3) {
        [self.view addSubview:self.createFinanceView];
    }
    
}


- (void)initTableView{
    
    CGFloat height = SCREENH - kScreenTopHeight-45;
    
    if ([WechatUserInfo shared].claim_type.integerValue == 0 || [WechatUserInfo shared].claim_type.integerValue == 3) {
        height = SCREENH - kScreenTopHeight-45-kScreenBottomHeight;
    }
    self.tableView.frame = CGRectMake(0, 0, SCREENW, height);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchPersonCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"SearchPersonCellID"];
    
//    self.tableView.tableFooterView = self.tableFooterView;
}


-(BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    NSString *w = [self.keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 注意考虑特殊字符
    [dic setValue:w forKey:@"keywords"];
    
    [dic setValue:@"3" forKey:@"type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    if (self.dataArr.count == 0) {
        [self showHUD];
    }
    
    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        NSMutableArray *arr = [NSMutableArray array];

        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            if (self.currentPage == 1) {
                _totalCount = resultData[@"count"];
            }
            for (NSDictionary *dic in resultData[@"list"]) {
                SearchPerson *person = [[SearchPerson alloc]initWithDictionary:dic error:nil];
                [arr addObject:person];
            }
            if (self.currentPage == 1) {
                [self.dataArr removeAllObjects];
            }
            
            [self.dataArr addObjectsFromArray:arr];
            
            
        }else{
            if (self.currentPage == 1) {
                _totalCount = @"0";
            }
        }
        
        [self refreshFooter:arr];
        
        [self.tableView reloadData];
        
    }];
    return YES;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createBtnClick {
    [QMPEvent event:@"mainsearch_person_createClick"];

    AuthenticationController *claimPerson = [[AuthenticationController alloc]init];
    claimPerson.searchName = [self.keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self.navigationController pushViewController:claimPerson animated:YES];    
}


#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 55.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1f;

}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 55)];
    sectionView.backgroundColor = TABLEVIEW_COLOR;
    
    UIView *_headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, SCREENW, 45)];//表头
    _headerView.backgroundColor = [UIColor whiteColor];
    [sectionView addSubview:_headerView];
    
    UILabel *headerLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 200, 45)];
    headerLab.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:headerLab];
    headerLab.font = [UIFont systemFontOfSize:14];
    headerLab.textColor = H9COLOR;
    NSString *headerStr = [NSString stringWithFormat:@"人物(%@)",_totalCount];
    headerLab.text = headerStr;
    [_headerView addSubview:headerLab];
    if (self.dataArr.count > 0) {
        UIButton *baiduBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        baiduBtn.frame = CGRectMake(SCREENW-135,0, 72, 45);
        baiduBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        baiduBtn.tag = 100;
        [baiduBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [baiduBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [baiduBtn setTitle:@"全网搜索" forState:UIControlStateNormal];
        [baiduBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [baiduBtn addTarget:self action:@selector(baiduBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:baiduBtn];
    }
    
    self.feedbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.feedbackBtn.frame = CGRectMake(SCREENW-67,0, 50, 45);
    self.feedbackBtn.tag = 100;
    [self.feedbackBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [self.feedbackBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self.feedbackBtn setTitle:@"反馈" forState:UIControlStateNormal];
    [self.feedbackBtn setTitle:@"已反馈" forState:UIControlStateSelected];
    [self.feedbackBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.feedbackBtn addTarget:self action:@selector(feedbackAlertView1) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:self.feedbackBtn];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 54.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [sectionView addSubview:line];
    
    return sectionView;
}
#pragma mark - EVENT
- (void)feedbackAlertView1{
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"有人物",@"有人物联系方式",@"有人物工作经历",@"有人物新闻报道", nil];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:@{@"module":@"搜索列表详情",@"title":@"搜索"}];
    [infoDic setValue:@"人工信息完善" forKey:@"type"];
    [infoDic setValue:@"急" forKey:@"c4"];
    [infoDic setValue:self.keyword forKey:@"c1"];
    [infoDic setValue:self.keyword forKey:@"company"];
    
    CustomAlertView *alertV = [[CustomAlertView alloc]initWithAlertViewHeight:arr frame:CGRectZero WithAlertViewHeight:10 infoDic:infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
    alertV.delegate = self;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    tableView.tableFooterView.hidden = NO;
    if (self.dataArr.count == 0) {
        tableView.tableFooterView.hidden = YES;
        return 1;
    }
    
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        return SCREENH - kScreenTopHeight - 90;  //未搜索到
    }
    SearchPerson *person = self.dataArr[indexPath.row];
    if ([person needShowReason]) {
        return 92;
    }
    return 77;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        
        NSString *title = REQUEST_DATA_NULL;
        HomeInfoTableViewCell *cell = [self nodataCellWithInfo:title tableView:tableView];
        [cell.createBtn setTitle:@"全网搜索" forState:UIControlStateNormal];
        cell.createBtn.hidden = NO;
        [cell.createBtn addTarget:self action:@selector(baiduBtnClick) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    static NSString *ID2 = @"SearchPersonCellID";
    
    SearchPersonCell *cell =  [tableView dequeueReusableCellWithIdentifier:ID2];
    if (!cell) {
        cell = (SearchPersonCell*)[[BundleTool commonBundle]loadNibNamed:@"SearchPersonCell" owner:nil options:nil].lastObject;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    SearchPerson *person = self.dataArr[indexPath.row];
    cell.person2 = person;
    cell.nametitColor = RANDOM_COLORARR[indexPath.row%6];
    cell.bottomLine.hidden = indexPath.row+1 == self.dataArr.count;
    cell.claimBtn.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == 0) {
        return;
    }
    
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    SearchPerson *person = self.dataArr[indexPath.row];
    
    [[AppPageSkipTool shared] appPageSkipToPersonDetail:person.personId nameLabBgColor:RANDOM_COLORARR[indexPath.row%6]];

    [QMPEvent event:@"search_person_cellClick"];
}


#pragma mark --UIScrollViewDelegate--
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (!self.createFinanceView.superview) {
        return;
    }
    CGFloat currentOffSetY = scrollView.contentOffset.y;
    originalOffSetY = currentOffSetY;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!self.createFinanceView.superview) {
        return;
    }
}

#pragma mark - 懒加载
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (TitleAndBtnBottomView *)createFinanceView {
    if (!_createFinanceView) {
        __weak typeof(self) weakSelf = self;
        _createFinanceView = [TitleAndBtnBottomView titleAndBtnViewWithFrame:CGRectMake(0, SCREENH-kScreenBottomHeight-kScreenTopHeight-45, SCREENW, kScreenBottomHeight) Title:@"没有找到自己?" buttonTitle:@"创建人物" btnClick:^{
            [weakSelf createBtnClick];
        }];
    }
    return _createFinanceView;
}

@end

