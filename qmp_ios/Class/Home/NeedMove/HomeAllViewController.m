//
//  HomeAllViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/5/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "HomeAllViewController.h"

#import "HomeProductCell.h"
#import "GetMd5Str.h"
#import "HomeFilterView.h"
#import "SearchCreateProductViewController.h"
#import "JustSearcProductController.h"
#import "DBHelper.h"
#import "SearchCompanyModel.h"


NSString *const Lingyu1TableName = @"FilterLingyu1TableName";
NSString *const Lingyu2TableName = @"FilterLingyu2TableName";
NSString *const LunciTableName = @"FilterLunciTableName";
NSString *const DiquTableName = @"FilterDiquTableName";

@interface HomeAllViewController () <UITableViewDelegate, UITableViewDataSource, HomeFilterViewDelegate>

@property (nonatomic, strong) NSMutableArray *productData;

@property (nonatomic, strong) HomeFilterHeaderView *filterHeaderView;
@property (nonatomic, strong) HomeFilterView *filterView;
@property (nonatomic, strong) NSMutableArray *lingyu1;
@property (nonatomic, strong) NSDictionary *lingyu2;
@property (nonatomic, strong) NSMutableArray *filterData;

@property (nonatomic, assign) CGFloat originalOffSetY;
//导航
@property (nonatomic, strong) UIBarButtonItem *proCreateItem;
@property (nonatomic, strong) UIBarButtonItem *searchItem;

@property (nonatomic, strong) FMDatabase *db;
@end

@implementation HomeAllViewController
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 更新数据表
    self.db = [[DBHelper shared] toGetDB];
    [self.db open];
    
    [self updateDBWithTable:Lingyu1TableName data:self.filterView.sLingyu1Data];
    [self updateDBWithTable:Lingyu2TableName data:self.filterView.sLingyu2Data];
    [self updateDBWithTable:LunciTableName data:self.filterView.sLunciData];
    [self updateDBWithTable:DiquTableName data:self.filterView.sDiquData];
}
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

    [self initData];
    
    self.navigationItem.title = @"项目库";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, self.view.height-self.filterHeaderView.height)
                                                  style:UITableViewStylePlain];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.layer.masksToBounds = NO;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    [self.tableView registerNib:[UINib nibWithNibName:@"EventCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"EventCellID"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeProductCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"HomeProductCellID"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProductHomeCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"ProductHomeCellID"];
    [self.view addSubview:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(self.filterHeaderView.height, 0, self.filterHeaderView.height, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.estimatedRowHeight = 83;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
//    self.tableView.tableHeaderView = self.filterHeaderView;
    [self.view addSubview:self.filterHeaderView];
    self.filterHeaderView.userInteractionEnabled = NO;
    [self.view insertSubview:self.filterView belowSubview:self.filterHeaderView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginStatusChange) name:NOTIFI_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginStatusChange) name:NOTIFI_QUITLOGIN object:nil];

    self.navigationItem.rightBarButtonItems = @[self.proCreateItem,self.searchItem];
    
    [self showHUD];
    [self requestData];
}

- (void)createProductClick {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    SearchCreateProductViewController *vc = [[SearchCreateProductViewController alloc] init];
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
}

- (void)searchItemClick{
    JustSearcProductController *searchProductVC = [[JustSearcProductController alloc]init];
    [self.navigationController pushViewController:searchProductVC animated:YES];
}


- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)userLoginStatusChange {
    if ([ToLogin isLogin]) {
        [self requestHangye];
    }
    [self.productData removeAllObjects];
    [self.tableView reloadData];
    [self.tableView.mj_header beginRefreshing];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, SCREENW, self.view.height);
}
- (void)hideFilterView {
    if (self.filterHeaderView.filterViewIsShow) {
        [self.filterView hideWithNoConfirm];
    }
    
}
- (void)pullUp {
    if (![ToLogin isLogin]) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    [super pullUp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.productData.count == 0) {
        return 1;
    }
    return self.productData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.productData.count == 0) {
        HomeInfoTableViewCell *cell = [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
        return cell;
    }
    HomeProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeProductCellID" forIndexPath:indexPath];
    SearchCompanyModel *comModel = self.productData[indexPath.row];
    cell.companyM = comModel;
    cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.productData.count == 0) {
        return tableView.height;
    }
    return UITableViewAutomaticDimension;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.productData.count == 0) {
        return;
    }
    
    if(!self.tableView.mj_header.isRefreshing && !self.tableView.mj_footer.isRefreshing){
        
        SearchCompanyModel *oldModel = self.productData[indexPath.row];
        
        if (![TestNetWorkReached networkIsReached:self]) {
            
            return;
        }else{
            //如果没有新闻链接,直接跳到公司详情页
            if (oldModel.detail&&[oldModel.detail isKindOfClass:[NSString class]]&&![oldModel.detail isEqualToString:@""]) {
                
                SearchCompanyModel *urlModel = self.productData[indexPath.row];
                if (![ToLogin canEnterDeep]) {
                    [ToLogin accessEnterDeep];
                    return;
                }
                
                [self enterDetailProduct:urlModel];
            }
            
        }
    }
    [QMPEvent event:@"home_findPro_innerCellClick"];
    
}
- (void)enterDetailProduct:(SearchCompanyModel *)urlModel{
    
    
    NSString *detailUrl = urlModel.detail;
    NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *maskStr =@"?";
    NSArray *arr1 = [detailUrl componentsSeparatedByString:maskStr]; //从字符A中分隔成2个元素的数组
    maskStr = @"&";
    NSArray *arr2 = [arr1[1] componentsSeparatedByString:maskStr];
    maskStr = @"=";
    for (NSString *tmpStr in arr2) {
        
        NSArray *arr3 = [tmpStr componentsSeparatedByString:maskStr];
        [mdict setValue:arr3[1] forKey:arr3[0]];
    }
    
    NSDictionary *urlDict = [NSDictionary dictionaryWithDictionary:mdict];
    [[AppPageSkipTool shared] appPageSkipToProductDetail:urlDict];

    self.tableView.editing = NO;
    
}
- (BOOL)requestData {
    if (![super requestData]) return NO;
  
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    self.numPerPage = 20;
    
    [mDict setValue:[NSString stringWithFormat:@"%ld",(long)self.numPerPage] forKey:@"num"];
    [mDict setValue:[NSString stringWithFormat:@"%ld",(long)self.currentPage] forKey:@"page"];
    
    NSMutableArray *tags = [NSMutableArray arrayWithArray:self.filterView.sLingyu1Data];
    [tags addObjectsFromArray:self.filterView.sLingyu2Data];
    if (tags.count > 0) {
        [mDict setValue:[self handleArrToStr:tags] forKey:@"tag"];
    }


    tags = self.filterView.sLunciData;
    if (tags.count > 0) {
        [mDict setValue:[self handleArrToStr:tags] forKey:@"lunci"];
    }

    tags = [NSMutableArray arrayWithArray:self.filterView.sDiquData];
    if ([tags containsObject:@"国内"] && [tags containsObject:@"国外"]) {
        if (tags.count ==  2) { //说明只选了国内和国外
            [tags removeObject:@"国外"];
        }
        [tags removeObject:@"国内"];
    }
    
    if (tags.count > 0) {
        [mDict setValue:[self handleArrToStr:tags] forKey:@"region"];
    }
    
    [mDict setObject:@"or" forKey:@"tag_type"];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Product/productList" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        [self.mjHeader endRefreshing];
        [self.mjFooter endRefreshing];
        
        if (resultData) {
            
            NSDictionary *dict = resultData;
            NSArray *arr = dict[@"list"];
            
            if (self.currentPage == 1) {
                
                [self.productData removeAllObjects];
                
            }
            
            for (NSDictionary *dic in arr) {
                NSError *error = nil;
                SearchCompanyModel *newsModel = [[SearchCompanyModel alloc]initWithDictionary:dic error:&error];
                [self.productData addObject:newsModel];
            }
            
            [self.tableView reloadData];
            
            [self refreshFooter:arr];
            
            
            
        }else{ //请求失败
            NSDictionary *dict = error.userInfo;
            self.mjFooter.stateLabel.hidden = NO;
            NSString *title = dict[@"data"][@"msg"];
            if ([title isEqualToString:@"无法查看"]) {
                [self.mjFooter setTitle:@"手机端最多显示100条，请使用PC版FinOS查看更多" forState:MJRefreshStateNoMoreData];
                [self.mjFooter endRefreshingWithNoMoreData];
                
            }
            
            self.currentPage = self.currentPage > 1 ? self.currentPage--:1;
        }
    }];
    
    
    
    return YES;
}
- (void)headerFilterButtonClick:(UIButton *)button {
    
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.originalOffSetY = scrollView.contentOffset.y;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat currentOffSetY = scrollView.contentOffset.y;
    if ((self.originalOffSetY < currentOffSetY) && (currentOffSetY > 10) && (self.filterHeaderView.top == 0)) {   //上滑
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - getter
- (BOOL)isShow {
    return self.filterView.isShow;
}
- (NSMutableArray *)productData {
    if (!_productData) {
        _productData = [NSMutableArray array];
    }
    return _productData;
}
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
    return @[@"国内",@"国外",@"北京",@"上海",@"深圳",@"广州",@"重庆",@"天津",@"苏州",@"成都",@"武汉",@"杭州",@"广东",
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
        }else{
            hangye = [NSString stringWithFormat:@"%@|%@",hangye,selectedMArr[i]];
        }
    }
    
    return hangye;
}
- (NSMutableArray *)lingyu1 {
    if (!_lingyu1) {
        _lingyu1 = [NSMutableArray array];
    }
    return _lingyu1;
}
- (NSMutableArray *)filterData {
    if (!_filterData) {
        _filterData = [NSMutableArray array];
        
    }
    NSArray *m = @[
                   @{
                       @"title":@"领域",
                       @"datas":self.lingyu1,
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
    [dict setObject:@"1" forKey:@"filter_type"];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/showuserhangye" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            [self.lingyu1 removeAllObjects];
            for (NSDictionary *dic in resultData[@"data"]) {
                [self.lingyu1 addObject:dic[@"name"]];
            }
            self.filterView.filterData = self.filterData;
            [self.filterView reload];
            self.filterHeaderView.userInteractionEnabled = YES;
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
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark --懒加载--
- (UIBarButtonItem *)proCreateItem {
    if (!_proCreateItem) {
        UIImage *image = [BundleTool imageNamed:@"product_create"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _proCreateItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(createProductClick)];
    }
    return _proCreateItem;
}
- (UIBarButtonItem *)searchItem {
    if (!_searchItem) {
        UIImage *image = [BundleTool imageNamed:@"nav_search_icon"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _searchItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClick)];
        _searchItem.imageInsets = UIEdgeInsetsMake(0, 16, 0, -16);

    }
    return _searchItem;
}
/** 筛选的本地存储 **/
- (void)updateDBWithTable:(NSString *)tableName data:(NSArray *)array {
    if (![[DBHelper shared] isTableOK:tableName ofDataBase:self.db]) {
        [self createTable:tableName database:self.db];
    }
    [self cleanTable:tableName database:self.db];
    for (NSString *name in array) {
        [self insertData:name inTable:tableName withDB:self.db];
    }
}
- (NSArray *)dataFormTable:(NSString *)tableName {
    if (![[DBHelper shared] isTableOK:tableName ofDataBase:self.db]) {
        [self createTable:tableName database:self.db];
    }
    return [self dataFromTable:tableName withDB:self.db];
}
- (void)initData {
    self.db = [[DBHelper shared] toGetDB];
    [self.db open];
    
    NSArray *arr = [self dataFromTable:Lingyu1TableName withDB:self.db];
    self.filterView.sLingyu1Data = [NSMutableArray arrayWithArray:arr];
    
    NSArray *arr1 = [self dataFromTable:Lingyu2TableName withDB:self.db];
    self.filterView.sLingyu2Data = [NSMutableArray arrayWithArray:arr1];
    
    NSArray *arr2 = [self dataFromTable:LunciTableName withDB:self.db];
    self.filterView.sLunciData = [NSMutableArray arrayWithArray:arr2];
    
    NSArray *arr3 = [self dataFromTable:DiquTableName withDB:self.db];
    self.filterView.sDiquData = [NSMutableArray arrayWithArray:arr3];
    
    [self.filterView reload];
    [self updateHeaderShow];
}
- (NSArray *)dataFromTable:(NSString *)tableName withDB:(FMDatabase *)db {
    if (![[DBHelper shared] isTableOK:tableName ofDataBase:db]) {
        [self createTable:tableName database:db];
    }
    NSMutableArray *data = [NSMutableArray array];
    NSString *queryStr = [NSString stringWithFormat:@"select * from '%@'", tableName];
    FMResultSet *rs = [db executeQuery:queryStr];
    
    while ([rs next]) {
        NSString *name = [rs stringForColumn:@"name"];
        [data addObject:name];
    }
    return data;
}
- (void)insertData:(NSString *)data inTable:(NSString *)tableName withDB:(FMDatabase *)db {
    NSString *queryStr = [NSString stringWithFormat:@"select * from '%@' where name='%@'", tableName, data];
    FMResultSet *rs = [db executeQuery:queryStr];
    if ([rs next]) {
        QMPLog(@"数据存在");
        return;
    }
    
    NSString *insertStr = [NSString stringWithFormat:@"insert into '%@' (name) values('%@')", tableName, data];
    BOOL res = [db executeUpdate:insertStr];
    if (res) {
        QMPLog(@"数据插入成功");
    }
}
- (void)createTable:(NSString *)tableName database:(FMDatabase *)db {
    NSString *sql = [NSString stringWithFormat:@"create table if not exists '%@' ('name' text, 'selected' text)",tableName];
    BOOL res = [db executeUpdate:sql];
    if (res) {
        QMPLog(@"创建数据表成功");
    }
}
- (void)cleanTable:(NSString *)tableName database:(FMDatabase *)db {
    NSString *deleteStr = [NSString stringWithFormat:@"delete from '%@'", tableName];
    BOOL res = [db executeUpdate:deleteStr];
    if (res) {
        QMPLog(@"清空数据表成功");
    }
}
- (void)updateHeaderShow {
    
    UIButton *button2 = [self.filterHeaderView.subviews objectAtIndex:0];
    NSMutableArray *marr = [NSMutableArray array];
    [marr addObjectsFromArray:self.filterView.sLingyu1Data];
    [marr addObjectsFromArray:self.filterView.sLingyu2Data];
    if (marr.count == 0) {
        [button2 setTitle:@"领域" forState:UIControlStateNormal];
    } else if (marr.count == 1) {
        [button2 setTitle:[marr firstObject] forState:UIControlStateNormal];
    } else {
        [button2 setTitle:[NSString stringWithFormat:@"领域(%zd)", marr.count] forState:UIControlStateNormal];
    }
    [self fixButton:button2];
    
    
    NSArray *arr = self.filterView.sLunciData;
    UIButton *button3 = [self.filterHeaderView.subviews objectAtIndex:1];
    
    if (arr.count == 0) {
        [button3 setTitle:@"轮次" forState:UIControlStateNormal];
    } else if (arr.count == 1) {
        [button3 setTitle:[arr firstObject] forState:UIControlStateNormal];
    } else {
        [button3 setTitle:[NSString stringWithFormat:@"轮次(%zd)", arr.count] forState:UIControlStateNormal];
    }
    [self fixButton:button3];
    
    
    NSString *title = @"地区";
    UIButton *button4 = [self.filterHeaderView.subviews objectAtIndex:2];
    NSMutableArray *ma = [NSMutableArray array];
    for (NSString *otherTitle in @[@"地区", @"亮点"]) {
        NSArray *arr = [self.filterView arrWithTitle:otherTitle];
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
@end
