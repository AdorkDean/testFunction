//
//  Home6ViewController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/11/8.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "Home6ViewController.h"
#import <CommonLibrary/BingGouProModel.h>

#import <CommonLibrary/RzEventFilterView.h>
#import "QMPRecentEventCell2.h"

@interface Home6ViewController () <RzEventFilterViewDelegate> {
    
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

@implementation Home6ViewController
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

- (void)updateRongziNews:(NSMutableArray *)selectedMArr withEventMArr:(NSMutableArray *)eventMArr lunciMArr:(NSMutableArray *)lunciArr{
    
    
    self.selectedMArr = [NSMutableArray arrayWithArray:selectedMArr];
    
    self.selectedLunciMArr = [NSMutableArray arrayWithArray:lunciArr];
    self.selectedCountryMArr = [NSMutableArray arrayWithArray:eventMArr];
    
    [self confirmFilter:self.selectedMArr  lunciMArr:self.selectedLunciMArr countryArr:self.selectedCountryMArr];
    
    self.currentPage = 1;
    [self.tableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFI_COUNTRYFILTER_REFRESH object:nil];
    
    [QMPEvent event:@"tab_home_recent_filtersure" label:@"最近发生并购筛选"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableName = @"BingGou";
    
    self.currentPage = 1;
    self.numPerPage = 20;
    
    self.tableView.estimatedRowHeight = 83;

    CGFloat top = -self.scrollView.contentOffset.y-120;
    [self showHUDAtTop:top];
    [self requestData];
}


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
    
    BOOL selected = self.selectedMArr.count || self.selectedCountryMArr.count;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.allDataArr.count ? self.allDataArr.count : 1;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.allDataArr.count == 0) {
        return SCREENH;
    }
    QMPRecentEvent2 *event = self.allDataArr[indexPath.row];
    return event.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.allDataArr.count == 0) {
        
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
    
    QMPRecentEventCell2 *cell = [QMPRecentEventCell2 cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.event = self.allDataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    if (self.allDataArr.count == 0) {
        return;
    }
    
    QMPRecentEvent2 *event = self.allDataArr[indexPath.row];
    if (![PublicTool isNull:event.detail]) {
        [[AppPageSkipTool shared] appPageSkipToDetail:event.detail];
    }
    [QMPEvent event:@"home_list_"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    NSMutableDictionary *reqDict = [NSMutableDictionary dictionaryWithDictionary:@{@"curpage":@(self.currentPage),@"num":@(self.numPerPage),@"tag_type":@"or",@"md5":@"no"}];
    
    if (self.allDataArr.count > 0) {
        NSString *debug = [self.mjHeader isRefreshing] ? @"1" : @"0";
        [reqDict setValue:debug forKey:@"debug"];
    }
    
    self.filterNumber = 0;
    //筛选
    if (self.selectedMArr.count > 0) {
        [reqDict setValue:[self handleArrToStr:self.selectedMArr] forKey:@"tag"];
        self.filterNumber ++;
    }
//    if (self.selectedLunciMArr.count > 0) {
//        [reqDict setValue:[self handleArrToStr:self.selectedLunciMArr] forKey:@"lunci"];
//        self.filterNumber ++;
//    }

    if (self.selectedCountryMArr.count > 0) {
        [reqDict setValue:[self handleArrToStr:self.selectedCountryMArr] forKey:@"country"];
        self.filterNumber ++;
    }
    
    if (self.filterHaha) {
        self.filterHaha();
    }
//
//    if (self.countryKey) {
//        [reqDict setValue:self.countryKey forKey:@"country"];
//    }
    //缺 ticket参数
    [AppNetRequest getBingGouEventWithParameter:reqDict completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
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
                BingGouProModel *model = [[BingGouProModel alloc]initWithDictionary:dic error:nil];
                QMPRecentEvent2 *model2 = [[QMPRecentEvent2 alloc] initWithBingGouProModel:model];
                [self.allDataArr addObject:model2];
            }
            
            
            [self.tableView reloadData];
            
            [self refreshFooter:arr];
            
        }
        
        
    }];
    
    
    
    return YES;
}
- (NSMutableArray *)allDataArr {
    if (!_allDataArr) {
        _allDataArr = [NSMutableArray array];
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
    
    [QMPEvent event:@"trz_product_filter_sure_click"];
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
