//
//  FinanceEventFilterView.m
//  qmp_ios
//
//  Created by QMP on 2018/8/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "FinanceEventFilterView.h"
#import "RzPartfilterTableViewCell.h"
#import "RzfilterTableViewCell.h"
NSString *const FinanceEventFilterAreaTableName = @"FinanceEventFilter_area"; ///< 存储筛选的本地数据表名
NSString *const FinanceEventFilterRoundTableName = @"FinanceEventFilter_round"; ///< 存储筛选的本地数据表名
@interface FinanceEventFilterView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) FMDatabase *db;

@property (nonatomic, strong) NSMutableArray *areaData;
@property (nonatomic, strong) NSMutableArray *roundData;

@property (nonatomic, strong) NSMutableArray *selectedAreaData;
@property (nonatomic, strong) NSMutableArray *selectedRoundData;


@property (nonatomic, strong) NSArray *oldSelectedAreaData;
@property (nonatomic, strong) NSArray *oldSelectedRoundData;

@property (nonatomic, assign) BOOL areaExpanding;

@property (nonatomic, strong) NSArray *allCountryData;
@property (nonatomic, strong) NSArray *allFieldData;
@property (nonatomic, strong) NSArray *allRoundData;
@property (nonatomic, strong) NSArray *allProvinceData;

@property (nonatomic, strong) NSMutableArray *sectionTitles;

@property (nonatomic, strong) NSMutableArray *sections;
@end

@implementation FinanceEventFilterView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initFilterSections];
        [self setupViews];
        [self loadData];
    }
    return self;
}
- (void)setupViews {
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    swipe.numberOfTouchesRequired = 1;
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipe];
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.rightView];
    
    [self.rightView addSubview:self.tableView];
    [self.rightView addSubview:self.bottomView];
    [self.bottomView addSubview:self.resetButton];
    [self.bottomView addSubview:self.confirmButton];
}
- (void)show {
    [KEYWindow addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundView.alpha = 1;
        self.rightView.left = 85*ratioWidth;
    }];
}
- (void)hide {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundView.alpha = 0.0001;
        self.rightView.left = SCREENW;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)loadData {
    self.db = [[DBHelper shared] toGetDB];
    
    BOOL isTableExist = YES;
    if ([self.db open]) {
        if ([[DBHelper shared] isTableOK:FinanceEventFilterAreaTableName ofDataBase:self.db] &&
            [[DBHelper shared] isTableOK:FinanceEventFilterRoundTableName ofDataBase:self.db]) {
            
            __weak typeof(self) weakSelf = self;
            [self loadDataWithTableName:FinanceEventFilterAreaTableName result:^(NSMutableArray *allData, NSMutableArray *selectedData) {
                weakSelf.areaData = [NSMutableArray arrayWithArray:allData];
                weakSelf.selectedAreaData = [NSMutableArray arrayWithArray:selectedData];
            }];
            
            [self loadDataWithTableName:FinanceEventFilterRoundTableName result:^(NSMutableArray *allData, NSMutableArray *selectedData) {
                weakSelf.roundData = [NSMutableArray arrayWithArray:allData];
                weakSelf.selectedRoundData = [NSMutableArray arrayWithArray:selectedData];
            }];
            
            if (self.areaData.count > 0 && self.roundData.count > 0) {
                // 刷新列表
                [self.tableView reloadData];
                
            }
        } else {
            isTableExist = NO;
            [self createTableWithName:FinanceEventFilterAreaTableName];
            [self createTableWithName:FinanceEventFilterRoundTableName];
        }
    }
    
    
    if (isTableExist == NO || self.areaData.count == 0 || self.roundData.count == 0) {
        
        [self requestIndustry:YES];
        
    }else if(isTableExist){
        
        [self requestIndustry:NO];
        
    }
}
- (BOOL)createTableWithName:(NSString *)name {
    if (![[DBHelper shared] isTableOK:name ofDataBase:self.db]) {
        NSString *sql = [NSString stringWithFormat:@"create table if not exists '%@' ('name' text, 'selected' text)", name];
        return [self.db executeUpdate:sql];
    }
    return YES;
}
- (void)loadDataWithTableName:(NSString *)tableName result:(void(^)(NSMutableArray *allData, NSMutableArray *selectedData))result {
    NSString *querySql = [NSString stringWithFormat:@"select * from '%@'",tableName];
    FMResultSet *rs = [self.db executeQuery:querySql];
    
    NSMutableArray *dataArr = [NSMutableArray array];
    NSMutableArray *selectedArr = [NSMutableArray array];
    while ([rs next]) {
        
        QMPFilterItem *item = [[QMPFilterItem alloc] init];
        item.name = [rs stringForColumn:@"name"];
        item.selected = [rs stringForColumn:@"selected"];
        
        if ([item.selected isEqualToString:@"1"]) {
            [selectedArr addObject:item.name];
        }
        [dataArr addObject:item];
    }
    if (result) {
        result(dataArr, selectedArr);
    }
}
- (void)requestIndustry:(BOOL)exist {
    if (![TestNetWorkReached networkIsReachedAlertOnView:self]) {
        self.oldSelectedAreaData = [NSArray arrayWithArray:self.selectedAreaData];
        self.oldSelectedRoundData = [NSArray arrayWithArray:self.selectedRoundData];
        return;
    }
        
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"1" forKey:@"filter_type"];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/showuserhangye" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        NSString *key = [NSString stringWithFormat:@"showUserhangyeHash4"];
        NSString *oldHash = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        NSString *newHash = [resultData objectForKey:@"hash"];
        
        //判断该接口数据是否变化
        if (oldHash && ![oldHash isEqualToString:@""] &&[oldHash isEqualToString:newHash] && !exist) {
            return ;
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:newHash forKey:key];
        [userDefaults synchronize];
        
        
        NSString *delSql = [NSString stringWithFormat:@"delete from '%@'", FinanceEventFilterAreaTableName];
        BOOL delRes = [_db executeUpdate:delSql];
        NSString *delEventSql = [NSString stringWithFormat:@"delete from '%@'", FinanceEventFilterRoundTableName];
        BOOL delEventRes = [_db executeUpdate:delEventSql];
        
        
        
        if (delRes && delEventRes) {
            
            NSArray *areaArr = [resultData objectForKey:@"data"];
            NSArray *roundArr = [resultData objectForKey:@"lunci"];
            
            roundArr = @[@{@"name":@"种子轮",@"selected":@"0"},@{@"name":@"天使轮",@"selected":@"0"},@{@"name":@"Pre-A轮",@"selected":@"0"},@{@"name":@"A轮",@"selected":@"0"},@{@"name":@"A+轮",@"selected":@"0"},@{@"name":@"Pre-B轮",@"selected":@"0"},@{@"name":@"B轮",@"selected":@"0"},@{@"name":@"B+轮",@"selected":@"0"},@{@"name":@"C轮",@"selected":@"0"},@{@"name":@"C+轮",@"selected":@"0"},@{@"name":@"D轮~Pre-IPO",@"selected":@"0"},@{@"name":@"战略融资",@"selected":@"0"}];
            
            NSMutableArray *areaItemArr = [self saveConvertData:areaArr withTableName:FinanceEventFilterAreaTableName];
            NSMutableArray *roundItemArr = [self saveConvertData:roundArr withTableName:FinanceEventFilterRoundTableName];
            
            if (exist || !oldHash) {
                
                //保留最开始选中的行业
                self.oldSelectedAreaData = [NSArray arrayWithArray:self.selectedAreaData];
                self.oldSelectedRoundData = [NSArray arrayWithArray:self.selectedRoundData];
                
                self.areaData = areaItemArr;
                self.roundData = roundItemArr;
                
                
                [self.tableView reloadData];
                
            }
        }
        
    }];
    
}

- (NSMutableArray *)saveConvertData:(NSArray *)data withTableName:(NSString *)tableName {
    NSMutableArray *tmpArr = [NSMutableArray array];

    if (data.count <= 0 ) {
        return tmpArr;
    }
    NSString *sql = [NSString stringWithFormat:@"insert into '%@' (name,selected) values ",tableName];
    for (int i = 0; i < data.count ; i++) {
        NSDictionary *dataDict = data[i];
        NSString *name = dataDict[@"name"];
        
        
        NSString *value = [NSString stringWithFormat:@",('%@','%@')",name,dataDict[@"selected"]];
        if (i == 0) {
            value = [NSString stringWithFormat:@"('%@','%@')",name,dataDict[@"selected"]];
        }
        sql = [NSString stringWithFormat:@"%@%@",sql,value];
        
        QMPFilterItem *item = [[QMPFilterItem alloc] init];
        item.name = name;
        item.selected = [NSString stringWithFormat:@"%@", dataDict[@"selected"]];
        [tmpArr addObject:item];
    }

    BOOL res = [self.db executeUpdate:sql];
    if (!res) {
        return [NSMutableArray array];
    }
    return tmpArr;
}
- (void)expadingButtonClick:(UIButton *)button {
    button.selected = !button.selected;
    
    NSInteger index = button.tag;
    QMPFilterSection *sectionData = self.sections[index];
    sectionData.expanding = !sectionData.expanding;
    
    [UIView performWithoutAnimation:^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
    }];
}
#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"rzfilterTableViewCell";
    NSMutableArray *selectedMArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *dataMArr = [[NSMutableArray alloc] initWithCapacity:0];
    
//    switch (indexPath.section) {
//        case 0:{
//            cellIdentifier = @"RzPartfilterTableViewCell";
//            selectedMArr = self.selectedAreaData;
//            dataMArr = self.areaData;
//            break;
//        }
//        case 1:{
//            selectedMArr = self.selectedRoundData;
//            dataMArr = self.roundData;
//            break;
//        }
//        default:
//            break;
//    }
    QMPFilterSection *sectionData = self.sections[indexPath.section];
    selectedMArr = sectionData.selectedArray;
    dataMArr = [NSMutableArray arrayWithArray:sectionData.dataArray];
    
    if (dataMArr.count > 15) {
        NSInteger allCount = dataMArr.count;
        if (!sectionData.expanding) {
            allCount = 12;
        }
        RzPartfilterTableViewCell *cell = [[RzPartfilterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withDataMArr:dataMArr withSelectedMArr:selectedMArr withCount:allCount];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        NSInteger count = dataMArr.count;
        
        RzfilterTableViewCell *cell = [[RzfilterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier isCountry:NO withCount:count withDataMArr:dataMArr  withSelectedMArr:selectedMArr];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
//    if (indexPath.section == 0) {
//        NSInteger allCount = dataMArr.count;
//        if (!self.areaExpanding) {
//            allCount = 12;
//        }
//        RzPartfilterTableViewCell *cell = [[RzPartfilterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withDataMArr:dataMArr withSelectedMArr:selectedMArr withCount:allCount];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        return cell;
//    }else{
//
//        NSInteger count = dataMArr.count;
//
//        RzfilterTableViewCell *cell = [[RzfilterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier isCountry:(indexPath.section == 2) withCount:count withDataMArr:dataMArr  withSelectedMArr:selectedMArr];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        return cell;
//    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger num = 0;
//    switch (indexPath.section) {
//        case 0:{
//            NSInteger allCount = self.areaData.count;
//            if (!self.areaExpanding) {
//                allCount = 12;
//            }
//            num = allCount;
//            break;
//        }
//        case 1:{
//            NSInteger allCount = self.roundData.count;
//            num =  allCount;
//            break;
//        }
//        default:
//            break;
//    }
    
    QMPFilterSection *sectionData = self.sections[indexPath.section];
    if (sectionData.dataArray.count > 15) {
        if (!sectionData.expanding) {
            num = 12;
        } else {
            num = sectionData.dataArray.count;
        }
    } else {
        num = sectionData.dataArray.count;
    }
    
    
    NSInteger count = ceil(num / 3.f);
    CGFloat height = 10;
    return count *37 + height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  45.f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    CGFloat h = 45;
    CGFloat w = self.rightView.width;
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    CGFloat margin = 17.f;
    
    CGFloat infoLblH = 16.f;
    UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(margin,h - infoLblH - 8.f ,w  - margin * 2, 16.f)];
    if (@available(iOS 8.2, *)) {
        infoLbl.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    } else {
        infoLbl.font = [UIFont systemFontOfSize:16.f];
    }
    infoLbl.text = section == 0 ? @"领域":@"轮次";
    infoLbl.textColor = H3COLOR;
    [headerV addSubview:infoLbl];
    infoLbl.centerY = headerV.centerY;
    
    
    
    QMPFilterSection *sectionData = self.sections[section];
    infoLbl.text = sectionData.title;
    
    if (sectionData.dataArray.count > 15 ){

        h = 45.f;
        headerV.frame = CGRectMake(0, 0, w, h);
        CGFloat centerW = 80.f;

        UIButton *expadingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [expadingButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
        [expadingButton setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateSelected];
        expadingButton.frame = CGRectMake(w-centerW, 0, centerW, h);
        expadingButton.tag = section;
        [expadingButton addTarget:self action:@selector(expadingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerV addSubview:expadingButton];

        expadingButton.selected = sectionData.expanding;
    }

    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, headerV.width, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    if (section == 1 || section == 2) {
        [headerV addSubview:line];
    }
    return headerV;
}
#pragma mark - Event
- (void)removeFilterView:(UITapGestureRecognizer *)tapGest {
    [self hide];
}
- (void)confirmButtonClick:(UIButton *)button {
    [self hide];
    if (self.confirmButtonClick) {
        self.confirmButtonClick(self.sections);
    }
}
#pragma mark - Getter
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
        _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFilterView:)];
        [_backgroundView addGestureRecognizer:tap];
    }
    return _backgroundView;
}
- (UIView *)rightView {
    if (!_rightView) {
        _rightView = [[UIView alloc] init];
        _rightView.frame = CGRectMake(SCREENW, 0, SCREENW-85*ratioWidth, SCREENH);
        _rightView.backgroundColor = [UIColor whiteColor];
    }
    return _rightView;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 30, SCREENW-85*ratioWidth, SCREENH - kScreenBottomHeight - 30) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.bounces = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENH-kScreenBottomHeight, SCREENW-85*ratioWidth, kScreenBottomHeight)];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}
- (UIButton *)resetButton {
    if (!_resetButton) {
        _resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, (SCREENW-85*ratioWidth)/2.0, 45)];
        _resetButton.backgroundColor = [UIColor whiteColor];
        [_resetButton setTitle:@"重置" forState:UIControlStateNormal];
        [_resetButton setTitleColor:H5COLOR  forState:UIControlStateNormal];
    }
    return _resetButton;
}
- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(self.resetButton.right, 0, (SCREENW-85*ratioWidth)/2.0, 45)];
        _confirmButton.backgroundColor = BLUE_TITLE_COLOR;
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}
#pragma mark - Class Method
+ (NSMutableArray *)areaDataOfLastFilter {
    return [self getSelectedDataWithTableName:FinanceEventFilterAreaTableName];
}
+ (NSMutableArray *)roundDataOfLastFilter {
    return [self getSelectedDataWithTableName:FinanceEventFilterRoundTableName];
}
+ (NSMutableArray *)getSelectedDataWithTableName:(NSString *)tableName {
    NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
    FMDatabase *db = [[DBHelper shared] toGetDB];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select name from '%@' where selected='1'", tableName];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            [retMArr addObject:[rs stringForColumn:@"name"]];
        }
    }
    [db close];
    return retMArr;
}


- (NSMutableArray *)sectionTitles {
    if (!_sectionTitles) {
        _sectionTitles = [NSMutableArray arrayWithArray:@[@"国家",@"领域",@"轮次",@"地区"]];
    }
    return _sectionTitles;
}
- (NSArray *)allCountryData {
    if (!_allCountryData) {
        _allCountryData = @[@{@"name":@"国内",@"selected":@"1"},@{@"name":@"国外",@"selected":@"0"}];
    }
    return _allCountryData;
}
- (NSArray *)allFieldData {
    if (!_allFieldData) {
        _allFieldData = @[@{@"name":@"人工智能",@"selected":@"0"},@{@"name":@"区块链",@"selected":@"0"},
                          @{@"name":@"大数据",@"selected":@"0"},@{@"name":@"医疗健康",@"selected":@"0"},
                          @{@"name":@"教育培训",@"selected":@"0"},@{@"name":@"文娱传媒",@"selected":@"0"},
                          @{@"name":@"消费升级",@"selected":@"0"},@{@"name":@"金融",@"selected":@"0"},
                          @{@"name":@"电子商务",@"selected":@"0"},@{@"name":@"企业服务",@"selected":@"0"},
                          @{@"name":@"VP/AR",@"selected":@"0"},@{@"name":@"旅游户外",@"selected":@"0"},
                          @{@"name":@"餐饮业",@"selected":@"0"},@{@"name":@"房产家居",@"selected":@"0"},
                          @{@"name":@"汽车交通",@"selected":@"0"},@{@"name":@"体育健身",@"selected":@"0"},
                          @{@"name":@"生活服务",@"selected":@"0"},@{@"name":@"食品饮料",@"selected":@"0"},
                          @{@"name":@"物联网",@"selected":@"0"},@{@"name":@"硬件",@"selected":@"0"},
                          @{@"name":@"游戏",@"selected":@"0"},@{@"name":@"生产制造",@"selected":@"0"},
                          @{@"name":@"物流运输",@"selected":@"0"},@{@"name":@"农业",@"selected":@"0"},
                          @{@"name":@"批发零售",@"selected":@"0"},@{@"name":@"先进制造",@"selected":@"0"},
                          @{@"name":@"社区社交",@"selected":@"0"},@{@"name":@"工具软件",@"selected":@"0"},
                          @{@"name":@"服装纺织",@"selected":@"0"},@{@"name":@"建筑",@"selected":@"0"},
                          @{@"name":@"开采",@"selected":@"0"},@{@"name":@"环保",@"selected":@"0"},
                          @{@"name":@"能源电力",@"selected":@"0"},@{@"name":@"政务及公共服务",@"selected":@"0"},
                          @{@"name":@"科研及技术服务",@"selected":@"0"},];
    }
    return _allFieldData;
}
- (NSArray *)allRoundData {
    if (!_allRoundData) {
        _allRoundData = @[@{@"name":@"种子轮",@"selected":@"0"},@{@"name":@"天使轮",@"selected":@"0"},
                         @{@"name":@"Pre-A轮",@"selected":@"0"},@{@"name":@"A轮",@"selected":@"0"},
                         @{@"name":@"A+轮",@"selected":@"0"},@{@"name":@"Pre-B轮",@"selected":@"0"},
                         @{@"name":@"B轮",@"selected":@"0"},@{@"name":@"B+轮",@"selected":@"0"},
                         @{@"name":@"C轮",@"selected":@"0"},@{@"name":@"C+轮",@"selected":@"0"},
                         @{@"name":@"D轮~Pre-IPO",@"selected":@"0"},@{@"name":@"战略融资",@"selected":@"0"}];
    }
    return _allRoundData;
}
- (NSArray *)allProvinceData {
    if (!_allProvinceData) {
        _allProvinceData = @[@{@"name":@"北京",@"selected":@"0"},@{@"name":@"上海",@"selected":@"0"},
                             @{@"name":@"深圳",@"selected":@"0"},@{@"name":@"广州",@"selected":@"0"},
                             @{@"name":@"重庆",@"selected":@"0"},@{@"name":@"天津",@"selected":@"0"},
                             @{@"name":@"苏州",@"selected":@"0"},@{@"name":@"成都",@"selected":@"0"},
                             @{@"name":@"武汉",@"selected":@"0"},@{@"name":@"杭州",@"selected":@"0"},
                             @{@"name":@"广东",@"selected":@"0"},@{@"name":@"江苏",@"selected":@"0"},
                             @{@"name":@"山东",@"selected":@"0"},@{@"name":@"浙江",@"selected":@"0"},
                             @{@"name":@"河南",@"selected":@"0"},@{@"name":@"四川",@"selected":@"0"},
                             @{@"name":@"湖北",@"selected":@"0"},@{@"name":@"河北",@"selected":@"0"},
                             @{@"name":@"湖南",@"selected":@"0"},@{@"name":@"福建",@"selected":@"0"},
                             @{@"name":@"安徽",@"selected":@"0"},@{@"name":@"辽宁",@"selected":@"0"},
                             @{@"name":@"陕西",@"selected":@"0"},@{@"name":@"江西",@"selected":@"0"},
                             @{@"name":@"广西",@"selected":@"0"},@{@"name":@"云南",@"selected":@"0"},
                             @{@"name":@"黑龙江",@"selected":@"0"},@{@"name":@"内蒙古",@"selected":@"0"},
                             @{@"name":@"吉林",@"selected":@"0"},@{@"name":@"山西",@"selected":@"0"},
                             @{@"name":@"贵州",@"selected":@"0"},@{@"name":@"新疆",@"selected":@"0"},
                             @{@"name":@"甘肃",@"selected":@"0"},@{@"name":@"海南",@"selected":@"0"},
                             @{@"name":@"宁夏",@"selected":@"0"},@{@"name":@"青海",@"selected":@"0"},
                             @{@"name":@"西藏",@"selected":@"0"},@{@"name":@"港澳台",@"selected":@"0"}];
    }
    return _allProvinceData;
}
- (void)initFilterSections {
    NSMutableArray *tmpArray = [NSMutableArray array];
    QMPFilterSection *section = [[QMPFilterSection alloc] init];
    section.title = @"国家";
    section.type = @"country";
    section.dataArray = [self fix:self.allCountryData];
    section.selectedArray = [NSMutableArray array];
    [tmpArray addObject:section];

    QMPFilterSection *section1 = [[QMPFilterSection alloc] init];
    section1.title = @"领域";
    section1.type = @"field";
    section1.dataArray = [self fix:self.allFieldData];
    section1.selectedArray = [NSMutableArray array];
    [tmpArray addObject:section1];
    
    QMPFilterSection *section2 = [[QMPFilterSection alloc] init];
    section2.title = @"轮次";
    section2.type = @"field";
    section2.dataArray = [self fix:self.allRoundData];
    section2.selectedArray = [NSMutableArray array];
    [tmpArray addObject:section2];
    
    QMPFilterSection *section3 = [[QMPFilterSection alloc] init];
    section3.title = @"地区";
    section3.type = @"area";
    section3.dataArray = [self fix:self.allProvinceData];
    section3.selectedArray = [NSMutableArray array];
    [tmpArray addObject:section3];
    
    self.sections = tmpArray;
}
- (NSMutableArray *)fix:(NSArray *)arr {
    NSMutableArray *tmpArr = [NSMutableArray array];
    for (NSDictionary *dict in arr) {
        QMPFilterItem *item = [[QMPFilterItem alloc] init];
        item.name = dict[@"name"];
        item.selected = [NSString stringWithFormat:@"%@", dict[@"selected"]];
        [tmpArr addObject:item];
    }
    return tmpArr;
}
@end

@implementation QMPFilterItem
@end


@implementation QMPFilterSection
@end
