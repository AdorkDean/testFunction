//
//  InvestOpportunityViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/7/25.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "InvestOpportunityViewController.h"
#import "ProductHomeCell.h"
#import "StarProductsModel.h"
#import "HomeFilterView.h"
#import "TitleAndBtnBottomView.h"
#import "FinanceSearchComController.h"

@interface InvestOpportunityViewController () <UITableViewDataSource, UITableViewDelegate, HomeFilterViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *productData;

@property (nonatomic, strong) HomeFilterHeaderView *filterHeaderView;
@property (nonatomic, strong) HomeFilterView *filterView;

@property (nonatomic, strong) NSString *currentRange; ///< 全部 国内最新 国外 融资需求
@property (nonatomic, strong) NSMutableArray *hangyes;
@property (nonatomic, strong) NSMutableArray *filterData;
@property (nonatomic, strong) NSDictionary *lingyu2;

@property (nonatomic, assign) CGFloat originalOffSetY;

@property (nonatomic, strong) TitleAndBtnBottomView *createFinanceView;
@end

@implementation InvestOpportunityViewController
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.filterHeaderView.filterViewIsShow) {
        [self.filterView hideWithNoConfirmAnimate:NO];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([ToLogin isLogin]) {
        [self requestHangye];
    }
    
    self.navigationItem.title = @"投资机会";
    [self initTableView];
//    [self.view addSubview:self.createFinanceView];
    [self.view addSubview:self.filterHeaderView];
    [self.view insertSubview:self.filterView belowSubview:self.filterHeaderView];
    
    [self showHUD];
    [self requestData];
    
}
- (void)initTableView {
    
    CGFloat h = SCREENH - kScreenTopHeight;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, h) style:UITableViewStylePlain];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProductHomeCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"ProductHomeCellID"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(self.filterHeaderView.height, 0, self.filterHeaderView.height, 0);

    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;

    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [rightButton setTitle:@"发布融资" forState:UIControlStateNormal];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [rightButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(createFinanceClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = item;
}
- (void)createFinanceClick {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    FinanceSearchComController *vc = [[FinanceSearchComController alloc] init];
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
}
#pragma mark - LoadData
- (BOOL)requestData {
    if (![super requestData]) {
        return NO;
    }
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [mDict setValue:[NSString stringWithFormat:@"%ld",(long)self.currentPage] forKey:@"page"];
    [mDict setValue:[NSString stringWithFormat:@"%ld",(long)self.numPerPage] forKey:@"num"];
    
    NSMutableArray *tags = [NSMutableArray arrayWithArray:self.filterView.sLingyu1Data];
    [tags addObjectsFromArray:self.filterView.sLingyu2Data];
    if (tags.count > 0) {
        [mDict setValue:[self handleArrToStr:tags] forKey:@"tags"];
    }
    
    
    tags = self.filterView.sLunciData;
    if (tags.count > 0) {
        [mDict setValue:[self handleArrToStr:tags] forKey:@"luncis"];
    }
    
    tags = [NSMutableArray arrayWithArray:self.filterView.sDiquData];
    if (tags.count > 0) {
        [mDict setValue:[self handleArrToStr:tags] forKey:@"province"];
    }
    
    [mDict setValue:@"or" forKey:@"tag_type"];
    
    [AppNetRequest getRongziAbutmentListWithParameter:mDict completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self hideHUD];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = resultData;
            if (self.currentPage == 1) {
                self.navigationItem.title = [NSString stringWithFormat:@"投资机会(%@)", dict[@"count"]];
            }
            if ([dict[@"list"] isKindOfClass:[NSArray class]]) {
                NSArray *data = dict[@"list"];
                
                NSMutableArray *mArr = [NSMutableArray array];
                for (NSDictionary *dataDict in data) {
                    StarProductsModel *starPModel = [[StarProductsModel alloc] init];
                    [starPModel setValuesForKeysWithDictionary:dataDict];
                    [mArr addObject:starPModel];
                    
                }
                
                // 正常状态下包含分页
                if (self.currentPage == 1) {
                    self.productData = mArr;
                } else {
                    [self.productData addObjectsFromArray:mArr];
                }
                [self refreshFooter:mArr];
            }
            [self.tableView reloadData];
        }
        
    }];
    
    return YES;
}
#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(1, self.productData.count);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.productData.count == 0) {
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
    }
    
    ProductHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductHomeCellID" forIndexPath:indexPath];
    StarProductsModel *model = self.productData[indexPath.row];
    cell.productM = model;
    cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.productData.count == 0) {
        return SCREENH - kScreenTopHeight - kScreenBottomHeight;
    }
    return 83;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.productData.count == 0 || ![TestNetWorkReached networkIsReached:self]) {
        return;
    }
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    StarProductsModel *model = self.productData[indexPath.row];
    if ([PublicTool isNull:model.detail]) {
        return;
    }
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:model.detail]];

    [QMPEvent event:@"trz_product_recomment_cellClick"];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.originalOffSetY = scrollView.contentOffset.y;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat currentOffSetY = scrollView.contentOffset.y;
    if ((self.originalOffSetY < currentOffSetY) && (currentOffSetY > 10)&& (self.filterHeaderView.top == 0)) {   //上滑
        [UIView animateWithDuration:0.3 animations:^{
            self.filterHeaderView.top = -44;
        }];
    } else if (self.originalOffSetY > currentOffSetY && (self.filterHeaderView.top == -44)) {  //下拉
        [UIView animateWithDuration:0.3 animations:^{
            self.filterHeaderView.top = 0;
        }];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 点击状态栏的情况捕捉
    if(scrollView.contentOffset.y <= 2 && self.filterHeaderView.top == -44) {  //下拉
        [UIView animateWithDuration:0.3 animations:^{
            self.filterHeaderView.top = 0;
        }];
    }
}
#pragma mark - HomeFilterViewDelegate
- (void)homeFilterHeaderView:(HomeFilterHeaderView *)headerView itemButtonClick:(UIButton *)button needRefresh:(BOOL)need {
    NSArray *arr = @[ @"领域", @"轮次", @"地区"];
    if (!need) {
        [self.filterView scrollToSectionTitle:arr[button.tag] animated:YES];
        return;
    }
    if (headerView.filterViewIsShow) {
        [self.filterView scrollToSectionTitle:arr[button.tag] animated:NO];
        [self.filterView show];
        
        NSMutableArray *arr = [NSMutableArray array];
        for (UIButton *button in self.filterHeaderView.subviews) {
            [arr addObject:button.currentTitle];
        }
        self.filterHeaderView.oldTitles = [NSArray arrayWithArray:arr];
        
    } else {
        [self.filterView hide];
        [self.filterView scrollToSection:0 animated:NO];
    }
}

- (void)fixButton:(UIButton *)button {
    
    [button.titleLabel sizeToFit];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, button.titleLabel.width+2, 0, -button.titleLabel.width-2);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -button.imageView.width-2, 0, button.imageView.width+2);
}
- (void)homeFilterView:(HomeFilterView *)filterView cellClick:(NSString *)title section:(NSString *)section {
    if ([section isEqualToString:@"范围"]) {
        NSArray *arr = [filterView arrWithTitle:section];
        UIButton *button1 = [self.filterHeaderView.subviews objectAtIndex:0];
        [button1 setTitle:[arr firstObject] forState:UIControlStateNormal];
        [self fixButton:button1];
    } else if ([section containsString:@"领域"]) {
        UIButton *button2 = [self.filterHeaderView.subviews objectAtIndex:0];
        NSMutableArray *marr = [NSMutableArray array];
        [marr addObjectsFromArray:filterView.sLingyu1Data];
        [marr addObjectsFromArray:filterView.sLingyu2Data];
        if (marr.count == 0) {
            [button2 setTitle:@"领域" forState:UIControlStateNormal];
        } else if (marr.count == 1) {
            [button2 setTitle:[marr firstObject] forState:UIControlStateNormal];
        } else {
            [button2 setTitle:[NSString stringWithFormat:@"领域(%zd)", marr.count] forState:UIControlStateNormal];
        }
        [self fixButton:button2];
    } else if ([section isEqualToString:@"轮次"]) {
        NSArray *arr = [filterView arrWithTitle:section];
        UIButton *button3 = [self.filterHeaderView.subviews objectAtIndex:1];
        
        if (arr.count == 0) {
            [button3 setTitle:@"轮次" forState:UIControlStateNormal];
        } else if (arr.count == 1) {
            [button3 setTitle:[arr firstObject] forState:UIControlStateNormal];
        } else {
            [button3 setTitle:[NSString stringWithFormat:@"轮次(%zd)", arr.count] forState:UIControlStateNormal];
        }
        [self fixButton:button3];
    } else {
        
        UIButton *button4 = [self.filterHeaderView.subviews objectAtIndex:2];
        NSMutableArray *ma = [NSMutableArray array];
        for (NSString *otherTitle in @[@"地区", @"亮点"]) {
            NSArray *arr = [filterView arrWithTitle:otherTitle];
            if (arr.count > 0) {
                [ma addObjectsFromArray:arr];
            }
        }
        if (ma.count == 0) {
            title = @"地区";
        } else if (ma.count == 1) {
            title = [ma firstObject];
        } else {
            title = [NSString stringWithFormat:@"地区(%zd)", ma.count];
        }
        [button4 setTitle:title forState:UIControlStateNormal];
        [self fixButton:button4];
    }
}

- (void)homeFilterView:(HomeFilterView *)filterView confirmButtonClick:(UIButton *)button {
    [self.filterView hide];
    [self.tableView.mj_header beginRefreshing];
}
- (void)hideHomeFilterView:(HomeFilterView *)filterView {
    self.filterHeaderView.currentButton.selected = NO;
    self.filterHeaderView.currentButton = nil;
    self.filterHeaderView.filterViewIsShow = NO;
}
- (void)resetHomeFilterView:(HomeFilterView *)filterView {
    [self.filterView hide];
    
    [self.tableView.mj_header beginRefreshing];
    
    NSArray *arr = @[@"领域", @"轮次", @"地区"];
    for (UIButton *button in self.filterHeaderView.subviews) {
        if ([button.currentTitle isEqualToString:arr[button.tag]]) {
            continue;
        }
        [button setTitle:arr[button.tag] forState:UIControlStateNormal];
        [self fixButton:button];
    }
    
}
- (void)hideNoConfirmHomeFilterView:(HomeFilterView *)filterView {
    for (UIButton *button in self.filterHeaderView.subviews) {
        if ([button.currentTitle isEqualToString:self.filterHeaderView.oldTitles[button.tag]]) {
            continue;
        }
        [button setTitle:self.filterHeaderView.oldTitles[button.tag] forState:UIControlStateNormal];
        [self fixButton:button];
    }
}
#pragma mark - Getter
- (HomeFilterHeaderView *)filterHeaderView {
    if (!_filterHeaderView) {
        _filterHeaderView = [[HomeFilterHeaderView alloc] init];
        _filterHeaderView.frame = CGRectMake(0, 0, SCREENW, kHomeFilterHeaderViewHeight);
        _filterHeaderView.backgroundColor = [UIColor whiteColor];
        _filterHeaderView.titles = @[@"领域", @"轮次", @"地区"]; // 初始状态
        _filterHeaderView.delegate = self;
    }
    return _filterHeaderView;
}
- (HomeFilterView *)filterView {
    if (!_filterView) {
        // kScreenTopHeight+kHomeFilterHeaderViewHeight
        _filterView = [[HomeFilterView alloc] init];
        _filterView.frame = CGRectMake(0, (kHomeFilterHeaderViewHeight), SCREENW, kHomeFilterViewMaxHeight);
        _filterView.transform = CGAffineTransformMakeTranslation(0, -kHomeFilterViewMaxHeight-45);
        _filterView.delegate = self;
        _filterView.hidden = YES;
    }
    return _filterView;
}
- (NSArray *)province {
    return @[@"北京",@"上海",@"深圳",@"广州",@"重庆",@"天津",@"苏州",@"成都",@"武汉",@"杭州",@"广东",
             @"江苏",@"山东",@"浙江",@"河南",@"四川",@"湖北",@"河北",@"湖南",@"福建",@"安徽",@"辽宁",
             @"陕西",@"江西",@"广西",@"云南",@"黑龙江",@"内蒙古",@"吉林",@"山西",@"贵州",@"新疆",@"甘肃",
             @"海南",@"宁夏",@"青海",@"西藏",@"港澳台"];
}
- (NSArray *)lunci {
    return @[@"尚未获投",@"种子轮",@"天使轮",@"Pre-A轮",@"A轮",@"A+轮",@"Pre-B轮",@"B轮",
             @"B+轮",@"C轮",@"C+轮",@"D轮~Pre-IPO",@"战略融资",@"并购", @"战略合并"];
}
- (NSString *)handleArrToStr:(NSArray *)selectedMArr{
    NSString *hangye = @"";
    
    for (int i = 0; i < selectedMArr.count; i++) {
        if (i == 0) {
            hangye = selectedMArr[0];
        } else {
            hangye = [NSString stringWithFormat:@"%@|%@",hangye,selectedMArr[i]];
        }
    }
    
    return hangye;
}
-(NSMutableArray *)hangyes {
    if (!_hangyes) {
        _hangyes = [NSMutableArray array];
    }
    return _hangyes;
}
- (NSMutableArray *)filterData {
    if (!_filterData) {
        _filterData = [NSMutableArray array];
        
    }
    NSArray *m = @[
                   @{
                       @"title":@"领域",
                       @"datas":self.hangyes,
                       },
                   @{
                       @"title":@"轮次",
                       @"datas":[self lunci],
                       },
                   @{
                       @"title":@"地区",
                       @"datas":[self province],
                       },
                   ];
    _filterData = [NSMutableArray arrayWithArray:m];
    
    return _filterData;
}

- (void)requestHangye{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"1" forKey:@"filter_type"];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/showuserhangye" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            [self.hangyes removeAllObjects];
            for (NSDictionary *dic in resultData[@"data"]) {
                [self.hangyes addObject:dic[@"name"]];
            }
            self.filterView.filterData = self.filterData;
            [self.filterView reload];
        }
    }];
    
    NSMutableDictionary *ndict = [NSMutableDictionary dictionary];
    //    [ndict setObject:@"" forKey:@""];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/showFocusLingyu2" HTTPBody:ndict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            //            NSArray *lingyu = resultData[@"lingyu"];
            NSDictionary *lingyu2 = resultData[@"lingyu2"];
            self.lingyu2 = lingyu2;
            self.filterView.lingyu2 = lingyu2;
        }
    }];
}

- (TitleAndBtnBottomView *)createFinanceView {
    if (!_createFinanceView) {
        NSString *msgStr = @"你的项目有融资需要？";
        NSString *btnTitle = @"发布融资需求";
        
        __weak typeof(self) weakSelf = self;
        _createFinanceView = [TitleAndBtnBottomView titleAndBtnViewWithFrame:CGRectMake(0, SCREENH-kScreenBottomHeight-kScreenTopHeight, SCREENW, kScreenBottomHeight) Title:msgStr buttonTitle:btnTitle btnClick:^{
            FinanceSearchComController *VC = [[FinanceSearchComController alloc] init];
            [weakSelf.navigationController pushViewController:VC animated:YES];
        }];
    }
    return _createFinanceView;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(BOOL)isShow{
    return self.filterView.isShow;
}
@end
