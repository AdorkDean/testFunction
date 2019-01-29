//
//  Home5ViewController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/11/7.
//  Copyright © 2018 Molly. All rights reserved.
//  国外最近融资

#import "Home5ViewController.h"
#import <CommonLibrary/RZNewsModel.h>
#import "HomeRZProCell.h"

#import <CommonLibrary/RzEventFilterView.h>
@interface Home5ViewController () <RzEventFilterViewDelegate> {
    
    NSString *_lastId;
    NSString *_totalInfo;
    
    BOOL isFilter;
    NSString *_tableName;
}

@property (nonatomic, strong) NSMutableArray *allDataArr;


@property (strong, nonatomic) RzEventFilterView *filterV;//筛选页面
@property (strong, nonatomic) NSMutableArray *selectedMArr;
@property (strong, nonatomic) NSMutableArray *selectedLunciMArr;
@property (strong, nonatomic) NSMutableArray *selectedCountryMArr;
@end

@implementation Home5ViewController
- (void)showFilter {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    isFilter = YES;
    
    _filterV = [RzEventFilterView initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)  withKey:_tableName];
    _filterV.delegate = self;
    [KEYWindow addSubview:_filterV];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentPage = 1;
    self.numPerPage = 20;
    
    _tableName = @"国外";
    _totalInfo = @"";
    _lastId = @"";
    
    self.tableView.estimatedRowHeight = 83;
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeRZProCell" bundle:nil] forCellReuseIdentifier:@"HomeRZProCellID"];
    
    CGFloat top = -self.scrollView.contentOffset.y-120;
    [self showHUDAtTop:top];
    [self requestData];
}
- (void)updateRongziNews:(NSMutableArray *)selectedMArr withEventMArr:(NSMutableArray *)eventMArr lunciMArr:(NSMutableArray *)lunciArr{
    
    
    self.selectedMArr = [NSMutableArray arrayWithArray:selectedMArr];
    
    self.selectedLunciMArr = [NSMutableArray arrayWithArray:lunciArr];
    self.selectedCountryMArr = [NSMutableArray arrayWithArray:eventMArr];
    
    [self confirmFilter:self.selectedMArr  lunciMArr:self.selectedLunciMArr countryArr:self.selectedCountryMArr];
    
    self.currentPage = 1;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [self.tableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFI_COUNTRYFILTER_REFRESH object:nil];
    
    [QMPEvent event:@"trz_filter_sureclick"];
}
- (BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    if (self.currentPage == 1) {
        _lastId = @"";
    }
    NSMutableDictionary *reqDict = [NSMutableDictionary dictionaryWithDictionary:@{@"page":@(self.currentPage),@"page_num":@(self.numPerPage),@"id":_lastId?:@""}];
    
    if (self.allDataArr.count > 0) {
        NSString *debug = [self.mjHeader isRefreshing] ? @"1" : @"0";
        [reqDict setValue:debug forKey:@"debug"];
    }
    self.filterNumber = 0;
    if (self.selectedMArr.count > 0) {
        [reqDict setValue:[self handleArrToStr:self.selectedMArr] forKey:@"tag"];
        self.filterNumber ++;
    }
    if (self.selectedLunciMArr.count > 0) {
        [reqDict setValue:[self handleArrToStr:self.selectedLunciMArr] forKey:@"event"];
        self.filterNumber ++;
    }

    if (self.filterHaha) {
        self.filterHaha();
    }
    
    [reqDict setValue:@"国外" forKey:@"area"];
    [AppNetRequest getRZNewsWithParameter:reqDict completionHandle:^(NSURLSessionDataTask *dataTask, id resultData,NSError *error) {
        
        [self hideHUD];
        [self.mjHeader endRefreshing];
        [self.mjFooter endRefreshing];
        
        
        if (resultData) {
            NSDictionary *dict = resultData;
            NSArray *arr = dict[@"list"];
            _totalInfo = dict[@"descript"];

            if (self.currentPage == 1) {
                
                [self.allDataArr removeAllObjects];
                
            }
            
            for (NSDictionary *dic in arr) {
                
                NSError *error = nil;
                RZNewsModel *newsModel = [[RZNewsModel alloc]initWithDictionary:dic error:&error];
                [self.allDataArr addObject:newsModel];
            }
            _lastId = [self.allDataArr.lastObject productId];
            
            
            [self.tableView reloadData];
            
            [self refreshFooter:arr];
            
            
        }else{ //请求失败
            
            self.currentPage = self.currentPage > 1 ? self.currentPage--:1;
        }
        
    }];
    
    return YES;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark --UItableViewDelegate--
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 35)];
    UILabel *infoLab = [[UILabel alloc]initWithFrame:CGRectMake(13, 0, 120, 20)];
    [infoLab labelWithFontSize:12 textColor:H999999];
    infoLab.text = [PublicTool isNull:_totalInfo]?@"":_totalInfo;
    [headerV addSubview:infoLab];
    infoLab.centerY = headerV.height/2.0-1;
    
    BOOL selected = self.selectedMArr.count || self.selectedLunciMArr.count;
    UIButton *filterBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 6 - 58, 0, 58, 35)];
    filterBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [filterBtn setTitle:@"定制" forState:UIControlStateNormal];
    [filterBtn setImage:[UIImage imageNamed:@"setgray2"] forState:UIControlStateNormal];
    [filterBtn setImage:[UIImage imageNamed:@"setBlue2"] forState:UIControlStateSelected];
    [filterBtn setTitleColor:H999999 forState:UIControlStateNormal];
    [filterBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateSelected];
    [filterBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:3];
    filterBtn.selected = selected;
    [headerV addSubview:filterBtn];
    [filterBtn addTarget:self action:@selector(showFilter) forControlEvents:UIControlEventTouchUpInside];
    filterBtn.centerY = headerV.height/2.0-1;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 34, SCREENW, 1)];
    line.backgroundColor = LIST_LINE_COLOR;
    [headerV addSubview:line];
    return headerV;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allDataArr.count ? self.allDataArr.count : 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.allDataArr.count == 0) {
        return SCREENH;
    }
    return UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.allDataArr.count == 0) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
    
    RZNewsModel *urlModel = self.allDataArr[indexPath.row];
    HomeRZProCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeRZProCellID" forIndexPath:indexPath];
    cell.newsModel = urlModel;
    cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.allDataArr.count == 0) {
        return;
    }
    
    if(!self.tableView.mj_header.isRefreshing && !self.tableView.mj_footer.isRefreshing){
        
        RZNewsModel *oldModel = self.allDataArr[indexPath.row];
        
        if (![TestNetWorkReached networkIsReached:self]) {
            return;
        }
        if (![ToLogin canEnterDeep]) {
            [ToLogin accessEnterDeep];
            return;
        }
        // 如果没有新闻链接，直接跳到公司详情页
        if (oldModel.detail && [oldModel.detail isKindOfClass:[NSString class]] && ![oldModel.detail isEqualToString:@""]) {
            
            RZNewsModel *urlModel = self.allDataArr[indexPath.row];
                        [self enterDetailProduct:urlModel];
        }
    }
    [QMPEvent event:@"home_list_foreign_enterdetail"];
}

- (NSMutableArray *)allDataArr {
    if (!_allDataArr) {
        _allDataArr = [[NSMutableArray alloc] init];
    }
    return _allDataArr;
}

- (void)receiverLoginNotificationToRefresh{
    NSString *tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsindustry",_tableName]];
    self.selectedMArr = [self getArrFromDataWithTablename:tableName];
    NSString *lunciTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewslunci",_tableName]];
    self.selectedLunciMArr = [self getArrFromDataWithTablename:lunciTableName];
    NSString *countryTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsevent",_tableName]];
    self.selectedCountryMArr = [self getArrFromDataWithTablename:countryTableName];
    [self.tableView.mj_header beginRefreshing];
}

- (void)receiverQuitLoginNotificationToRefresh{
    self.selectedMArr = [[NSMutableArray alloc] initWithCapacity:0];
    self.selectedLunciMArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.tableView.mj_header beginRefreshing];
}


- (void)receiverRemoveFilterVNotification{
    
    if (_filterV) {
        [_filterV removeFromSuperview];
        _filterV = nil;
    }
    
}


- (NSString *)handleArrToStr:(NSMutableArray *)selectedMArr{
    
    NSString *value = @"";
    
    for (int i = 0; i < selectedMArr.count; i++) {
        if (i == 0) {
            value = selectedMArr[0];
        }
        else{
            value = [NSString stringWithFormat:@"%@|%@",value,selectedMArr[i]];
        }
    }
    return value;
}
- (NSString *)handleArrToSqlStr:(NSMutableArray *)selectedMArr{
    
    NSString *values = @"";
    if (selectedMArr.count > 0) {
        values = [NSString stringWithFormat:@"'%@'",selectedMArr[0]];
        
        if (selectedMArr.count > 1) {
            for (int i = 1 ; i < selectedMArr.count; i++) {
                
                values = [NSString stringWithFormat:@"%@,'%@'",values,selectedMArr[i]];
            }
        }
    }
    return values;
}

- (void)confirmFilter:(NSMutableArray *)selectedMArr  lunciMArr:(NSMutableArray*)selectedLunciMArr countryArr:(NSMutableArray *)selectedCountryArr {
    
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [docsdir stringByAppendingPathComponent:@"user.sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        
        NSString *values = [self handleArrToSqlStr:selectedMArr];
        [self updateFilterWithTable:[NSString stringWithFormat:@"%@filterrznewsindustry",_tableName] withValues:values onDB:db];
        
        NSString *lunciValues = [self handleArrToSqlStr:selectedLunciMArr];
        [self updateFilterWithTable:[NSString stringWithFormat:@"%@filterrznewslunci",_tableName] withValues:lunciValues onDB:db];
        
        NSString *countryValues = [self handleArrToSqlStr:selectedCountryArr];
        [self updateFilterWithTable:[NSString stringWithFormat:@"%@filterrznewsevent",_tableName] withValues:countryValues onDB:db];
        
    }
    
    [db close];
    db = nil;
    
    _filterV = nil;
    
    [QMPEvent event:@"tab_home_recent_filtersure" label:@"最近发生国外筛选"];
}

- (void)updateFilterWithTable:(NSString *)name withValues:(NSString *)values onDB:(FMDatabase *)db{
    
    NSString *tableName = [[DBHelper shared] toGetTablename:name];
    NSString *selectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='1'  WHERE name in (%@)",tableName,values];
    NSString *notSelectSql = [NSString stringWithFormat:@"UPDATE '%@' set SELECTED='0'  WHERE name not in (%@)",tableName,values];
    
    QMPLog(@"selectsql ==== %@",selectSql);
    QMPLog(@"notselectsql ==== %@",notSelectSql);
    [db executeUpdate:selectSql];
    [db executeUpdate:notSelectSql];
    
}
- (void)enterDetailProduct:(RZNewsModel *)urlModel{
    
    [[AppPageSkipTool shared] appPageSkipToDetail:urlModel.detail];
    self.tableView.editing = NO;
    
}




- (NSString *)handleSelectedMArrToStr:(NSMutableArray *)selectedMArr{
    NSString *hangye = @"";
    
    for (int i = 0; i < selectedMArr.count; i++) {
        if (i == 0) {
            hangye = selectedMArr[0];
        }
        else{
            hangye = [NSString stringWithFormat:@"%@|%@",hangye,selectedMArr[i]];
        }
    }
    
    return hangye;
}

- (NSMutableArray *)getArrFromDataWithTablename:(NSString *)tablename{
    NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
    FMDatabase *db = [[DBHelper shared] toGetDB];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select name from '%@' where selected='1'",tablename];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            [retMArr addObject:[rs stringForColumn:@"name"]];
        }
    }
    [db close];
    return retMArr;
}

#pragma mark - Getter


- (NSMutableArray *)selectedMArr{
    
    if (!_selectedMArr) {
        
        if ([ToLogin isLogin]) {
            //从数据库中获取
            NSString *tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsindustry",_tableName]];
            _selectedMArr = [self getArrFromDataWithTablename:tableName];
        }
        else{
            _selectedMArr = [[NSMutableArray alloc] initWithCapacity:0];
        }
    }
    return _selectedMArr;
}
- (NSMutableArray *)selectedLunciMArr{
    
    if (!_selectedLunciMArr) {
        
        if ([ToLogin isLogin]) {
            // 从数据库中获取
            NSString *countryTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewslunci",_tableName]];
            _selectedLunciMArr = [self getArrFromDataWithTablename:countryTableName];
        }
        else{
            _selectedLunciMArr = [[NSMutableArray alloc] initWithCapacity:0];
        }
    }
    return _selectedLunciMArr;
}
- (NSMutableArray *)selectedCountryMArr{
    
    if (!_selectedCountryMArr) {
        
        if ([ToLogin isLogin]) {
            // 从数据库中获取
            NSString *countryTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsevent",_tableName]];
            _selectedCountryMArr = [self getArrFromDataWithTablename:countryTableName];
        }
        else{
            _selectedCountryMArr = [[NSMutableArray alloc] initWithCapacity:0];
        }
    }
    return _selectedCountryMArr;
}
@end
