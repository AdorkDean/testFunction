//
//  RzEventFilterView.m
//  qmp_ios_v2.0
//
//  Created by molly on 2017/8/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "RzEventFilterView.h"
#import "RzfilterTableViewCell.h"
#import "RzPartfilterTableViewCell.h"
#import "CenterButton.h"

#import "IndustryItem.h"

#import "ManagerHud.h"
#import "TestNetWorkReached.h"

#define showCount 12

@interface RzEventFilterView()<UITableViewDelegate,UITableViewDataSource>{
    NSInteger _sectionNum;
    NSString *_tableName;
    NSString *_eventTableName;
    NSString *_lunciTableName;
    
    BOOL _isPart;
}

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *resetBtn;
@property (strong, nonatomic) UIButton *confirmBtn;
@property (strong, nonatomic) CenterButton *centerBtn;
@property (strong, nonatomic) FMDatabase *db;

@property (strong, nonatomic) NSMutableArray *industryArr;
@property (strong, nonatomic) NSMutableArray *eventArr;
@property (strong, nonatomic) NSMutableArray *lunciArr;

@property (strong, nonatomic) NSMutableArray *selectedMArr;
@property (strong, nonatomic) NSMutableArray *selectedEventMArr;
@property (strong, nonatomic) NSMutableArray *selectedLunciArr;

@property (strong, nonatomic) NSArray *oldLyselectedMArr;
@property (strong, nonatomic) NSArray *oldEventselectedMArr;
@property (strong, nonatomic) NSArray *oldLunciselectedMArr;


@property (strong, nonatomic) NSArray *sectionArr;
@property (strong, nonatomic) NSString *countryKey;


@property (strong, nonatomic) ManagerHud *hud;

@end
@implementation RzEventFilterView

- (void)dealloc{
    
    if (_db) {
        [_db close];
    }
}


+ (RzEventFilterView *)initWithFrame:(CGRect)frame withKey:(NSString *)countryKey{
    
    RzEventFilterView *drawerView = [[RzEventFilterView alloc] initWithFrame:frame];
    drawerView.countryKey = countryKey;
    [drawerView initView];
    return drawerView;
}


- (void)initView{
    
    _isPart = YES;
    if ([self.countryKey isEqualToString:@"report"]) {
        _isPart = NO;
    }
    CGFloat viewW = self.frame.size.width;
    CGFloat viewH = self.frame.size.height;
    self.backgroundColor = [UIColor clearColor];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeFilterVWhenSwipe:)];
    swipe.numberOfTouchesRequired = 1;
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipe];
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFilterV:)];
    [_backgroundView addGestureRecognizer:tap];
    [self addSubview:_backgroundView];
    
    CGFloat rightViewX = 85*ratioWidth;
    CGFloat righrViewW = viewW - rightViewX;
    _rightView = [[UIView alloc] initWithFrame:CGRectMake(SCREENW, 0, righrViewW, viewH)];
    _rightView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_rightView];
    
    _tableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 30, righrViewW, SCREENH - kScreenBottomHeight - 30) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.bounces = NO;
    [_rightView addSubview:_tableView];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    CGFloat btnH = 45.f;
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, viewH - btnH, viewW, 0.5)];
    lineView.backgroundColor = LINE_COLOR;
    [_rightView addSubview:lineView];
    
    _resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,lineView.frame.origin.y+0.5 , (SCREENW-85*ratioWidth)/2.0, btnH)];
    _resetBtn.backgroundColor = [UIColor whiteColor];
    [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
    [_resetBtn setTitleColor:H5COLOR  forState:UIControlStateNormal];
    [_resetBtn addTarget:self action:@selector(pressResetBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_rightView addSubview:_resetBtn];
    
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(_resetBtn.right, lineView.frame.origin.y, (SCREENW-85*ratioWidth)/2.0, btnH)];
    _confirmBtn.backgroundColor = BLUE_TITLE_COLOR;
    [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(pressConfirmBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_rightView addSubview:_confirmBtn];
    
    [self getLocalIndustryData];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect rightFrame = _rightView.frame;
        rightFrame.origin.x = rightViewX;
        _rightView.frame = rightFrame;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)getLocalIndustryData{
    
    _tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsindustry",self.countryKey]];
    _eventTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewsevent",self.countryKey]];
    _lunciTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterrznewslunci",self.countryKey]];
    
    _db = [[DBHelper shared] toGetDB];
    
    BOOL tableExist = YES;
    
    if ([_db open]) {
        
        if ([[DBHelper shared] isTableOK:_tableName ofDataBase:_db] &&[[DBHelper shared] isTableOK:_eventTableName ofDataBase:_db] &&[[DBHelper shared] isTableOK:_lunciTableName ofDataBase:_db]) {
            //如果表存在,直接赋值
            
            //领域
            [self toGetDataFromDbWithTableName:_tableName withNowSelectedMArr:self.selectedMArr withNowDataArr:self.industryArr];
            
            //事件
            [self toGetDataFromDbWithTableName:_eventTableName withNowSelectedMArr:self.selectedEventMArr withNowDataArr:self.eventArr];
            
            //轮次
            [self toGetDataFromDbWithTableName:_lunciTableName withNowSelectedMArr:self.selectedLunciArr withNowDataArr:self.lunciArr];
            
            if (self.industryArr.count > 0 && self.eventArr.count > 0 && self.lunciArr.count > 0) {
                //刷新列表
                [self.tableView reloadData];
                
                self.oldLyselectedMArr = [NSMutableArray arrayWithArray:self.selectedMArr];
                self.oldEventselectedMArr = [NSMutableArray arrayWithArray:self.selectedEventMArr];
                self.oldLunciselectedMArr = [NSMutableArray arrayWithArray:self.selectedLunciArr];
                
            }
            
        }
        else{
            tableExist = NO;
            //如果不存在表,则创建该表
            [self createTable:_tableName];
            [self createTable:_eventTableName];
            [self createTable:_lunciTableName];
            
        }
    }
    
    if (tableExist == NO || self.industryArr.count == 0 || self.eventArr.count == 0 || self.lunciArr.count == 0){
        
        [self requestIndustry:YES]; //当做首次请求，无数据存在
        
    }else if(tableExist){
        
        [self requestIndustry:NO]; //非首次请求，只判断接口是否有变
        
    }
}

- (NSMutableArray *)toGetPartMArrWithArr:(NSMutableArray *)mArr{
    
    NSMutableArray *partMArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < 24; i++) {
        if (i > mArr.count - 1) {
            break;
        }
        else{
            
            [partMArr addObject:mArr[i]];
        }
    }
    return partMArr;
}

- (void)createTable:(NSString *)tableName{
    
    if (![[DBHelper shared] isTableOK:tableName ofDataBase:_db]) {
        NSString *sql = [NSString stringWithFormat:@"create table if not exists '%@' ('name' text, 'selected' text)",tableName];
        BOOL res = [_db executeUpdate:sql];
        
    }
}

- (void)toGetDataFromDbWithTableName:(NSString *)tableName withNowSelectedMArr:(NSMutableArray *)nowSelectedMArr withNowDataArr:(NSMutableArray *)nowDataArr{
    
    NSString *querySql = [NSString stringWithFormat:@"select * from '%@'",tableName];
    FMResultSet *rs = [_db executeQuery:querySql];
    [nowDataArr removeAllObjects];
    [nowSelectedMArr removeAllObjects];
    while ([rs next]) {
        
        IndustryItem *item = [[IndustryItem alloc] init];
        item.name = [rs stringForColumn:@"name"];
        item.selected = [rs stringForColumn:@"selected"];
        
        if ([item.selected isEqualToString:@"1"]) {
            [nowSelectedMArr addObject:item.name];
        }
        [nowDataArr addObject:item];
    }
}

- (void)pressResetBtn:(UIButton *)sender{
    [QMPEvent event:@"filter_reset_click"];
    
    [self.selectedMArr removeAllObjects];
    [self.selectedEventMArr removeAllObjects];
    [self.selectedLunciArr removeAllObjects];
    
    [self resetMArr:self.industryArr];
    [self resetMArr:self.eventArr];
    [self resetMArr:self.lunciArr];
    
    [self.tableView reloadData];
}

- (void)resetMArr:(NSMutableArray *)dataArr{
    
    for (int i = 0 ; i < dataArr.count; i++) {
        IndustryItem *item = dataArr[i];
        if ([item.selected isEqualToString:@"1"]) {
            item.selected = @"0";
        }
    }
}

- (void)removeFilterV:(UITapGestureRecognizer *)tap{
    [self removeViewWithAni];
    [self confirmFilter];
}

- (void)removeFilterVWhenSwipe:(UISwipeGestureRecognizer *)tap{
    
    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _backgroundView.alpha = 0;
        
        CGRect rightFrame = _rightView.frame;
        rightFrame.origin.x = SCREENW ;
        _rightView.frame = rightFrame;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
    [self confirmFilter];
}

- (void)removeViewWithAni{
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [_backgroundView removeFromSuperview];
        
        CGRect rightFrame = _rightView.frame;
        rightFrame.origin.x = SCREENW ;
        _rightView.frame = rightFrame;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
    
}
- (void)pressConfirmBtn:(UIButton *)sender{
    
    [self removeViewWithAni];
    [self confirmFilter];
    
}

- (void)confirmFilter{
    
    if (self.selectedMArr.count == self.oldLyselectedMArr.count && self.selectedEventMArr.count == self.oldEventselectedMArr.count && self.selectedLunciArr.count == self.oldLunciselectedMArr.count) {
        if ([self isEqualOfArr:self.oldLyselectedMArr withNewArr:self.selectedMArr] && [self isEqualOfArr:self.oldEventselectedMArr withNewArr:self.selectedEventMArr]&& [self isEqualOfArr:self.oldLunciselectedMArr withNewArr:self.selectedLunciArr]) {
            return;
            //如果与旧的筛选条件相同,则不进行刷新
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(updateRongziNews:withEventMArr:lunciMArr:)]) {
        
        [self.delegate updateRongziNews:self.selectedMArr withEventMArr:self.selectedEventMArr lunciMArr:self.selectedLunciArr];
    }
}


/**
 此方法的判断条件前提是两个数组的数量相同
 
 @param oldArr
 @param newArr
 @return
 */
- (BOOL)isEqualOfArr:(NSArray *)oldArr withNewArr:(NSArray *)newArr{
    
    for (NSString *itemStr in newArr) {
        if (![oldArr containsObject:itemStr]) {
            return NO;
        }
    }
    return YES;
}
- (void)pressInductryBtn:(UIButton *)sender{
    
    BOOL selected = !sender.selected;
    sender.selected = selected;
    if (sender.selected) {
        
        [self.selectedMArr addObject:sender.titleLabel.text];
        sender.backgroundColor = [UIColor whiteColor];
        sender.layer.borderColor = RGBa(211,66,53,1).CGColor;
    }
    else{
        sender.backgroundColor = RGBa(240,239,245,1);
        sender.layer.borderColor = RGBa(240,239,245,1).CGColor;
        if([self.selectedMArr containsObject:sender.titleLabel.text]){
            
            [self.selectedMArr removeObject:sender.titleLabel.text];
        }
    }
}

- (void)pressAllBtn{
    
    if (_isPart) { //点击展开
        [QMPEvent event:@"filter_showall_click"];
    }
    
    _isPart = !_isPart;
    
    for (IndustryItem *item in self.industryArr) {
        if ([self.selectedMArr containsObject:item.name]) {
            item.selected = @"1";
        }
        else{
            item.selected = @"0";
        }
    }
    for (IndustryItem *item in self.industryArr) {
        if ([self.selectedMArr containsObject:item.name]) {
            item.selected = @"1";
        }
        else{
            item.selected = @"0";
        }
    }
    for (IndustryItem *item in self.eventArr) {
        if ([self.selectedEventMArr containsObject:item.name]) {
            item.selected = @"1";
        }
        else{
            item.selected = @"0";
        }
    }
    for (IndustryItem *item in self.lunciArr) {
        if ([self.selectedLunciArr containsObject:item.name]) {
            item.selected = @"1";
        }
        else{
            item.selected = @"0";
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self.countryKey containsString:@"BingGou"] ){
        _sectionNum = 2;
        return 2;
    } else if ([self.countryKey containsString:@"RongZi"]) { //并购库筛选有国内外
        _sectionNum = 3;
        return 3;
    }else if([self.countryKey isEqualToString:@"国内"] || [self.countryKey isEqualToString:@"国外"]){
        _sectionNum = 2;
        return 2;
    }
    _sectionNum = 1;
    _isPart = NO;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = @"rzfilterTableViewCell";
    NSMutableArray *selectedMArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *dataMArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    switch (indexPath.section) {
        case 0:{
            cellIdentifier = @"RzPartfilterTableViewCell";
            selectedMArr = self.selectedMArr;
            dataMArr = self.industryArr;
            break;
        }
        case 1:{
            if ([self.countryKey containsString:@"BingGou"] ){
                selectedMArr = self.selectedEventMArr;
                dataMArr = self.eventArr;
            } else {
                selectedMArr = self.selectedLunciArr;
                dataMArr = self.lunciArr;
            }
            
            break;
        }
        case 2:{
            selectedMArr = self.selectedEventMArr;
            dataMArr = self.eventArr;
            break;
        }
        default:
            break;
    }
    if (indexPath.section == 0) {
        NSInteger allCount = dataMArr.count;
        RzPartfilterTableViewCell *cell = [[RzPartfilterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withDataMArr:dataMArr withSelectedMArr:selectedMArr withCount:(_isPart ? (allCount > showCount ? showCount : allCount) : allCount)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        
        NSInteger count = dataMArr.count;
        
        RzfilterTableViewCell *cell = [[RzfilterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier isCountry:(indexPath.section == 2) withCount:count withDataMArr:dataMArr  withSelectedMArr:selectedMArr];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger num = 0;
    switch (indexPath.section) {
        case 0:{
            NSInteger allCount = self.industryArr.count;
            
            num = _isPart ? (allCount > showCount ? showCount : allCount) : allCount;
            break;
        }
        case 1:{
            NSInteger allCount = self.lunciArr.count;
            
            num =  allCount;
            break;
        }
        case 2:{
            num = self.eventArr.count;
            break;
        }
        default:
            break;
    }
    
    NSInteger count = ceil(num / 3.f);
    CGFloat height = (indexPath.section == 0 && _isPart == NO)? 10:10;
    return count *37 + height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return  45.f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (section == 2) {
        return 15.f;
    }
    else {
        
        return 5.f;
    }
    
    return 0.1f;
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
    infoLbl.text = self.sectionArr[section];
    infoLbl.textColor = H3COLOR;
    [headerV addSubview:infoLbl];
    infoLbl.centerY = headerV.centerY;
    
    if (section == 0 && (_sectionNum >= 2)){
        
        h = 45.f;
        headerV.frame = CGRectMake(0, 0, w, h);
        CGFloat centerW = 80.f;
        CenterButton *centerBtn = [[CenterButton alloc] initWithFrame:CGRectMake(w - centerW, 14, centerW, h)];
        [centerBtn setToCenterWithRightImage:(_isPart ? @"arrow_down" :@"arrow_up") withImgSize:CGSizeMake(18.f, 18.f) withTitle:(_isPart ? @"展开" :@"收起") withTitleSize:CGSizeMake(100.f, 20.f) withFont:14.f withTitleColor:H5COLOR withBtnW:SCREENW];
        [headerV addSubview:centerBtn];
        centerBtn.centerY = infoLbl.centerY;
        self.centerBtn = centerBtn;
        
        
        UIButton *showBtn = [[UIButton alloc] initWithFrame:centerBtn.frame];
        [showBtn addTarget:self action:@selector(pressAllBtn) forControlEvents:UIControlEventTouchUpInside];
        [headerV addSubview:showBtn];
    }
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, headerV.width, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    if (section == 1 || section == 2) {
        [headerV addSubview:line];
    }
    return headerV;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

#pragma mark -请求行业
- (void)requestIndustry:(BOOL)isFirst{
    
    if ([TestNetWorkReached networkIsReachedAlertOnView:self]) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"1" forKey:@"filter_type"];
        
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/showuserhangye" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            NSString *key = [NSString stringWithFormat:@"%@showUserhangyeHash",self.countryKey];
            NSString *oldHash = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            NSString *newHash = [resultData objectForKey:@"hash"];
            
            //判断该接口数据是否变化
            if (oldHash && ![oldHash isEqualToString:@""] &&[oldHash isEqualToString:newHash] && !isFirst) {
                return ;
                
            }else{
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setValue:newHash forKey:key];
                [userDefaults synchronize];
            }
            
            NSString *delSql = [NSString stringWithFormat:@"delete from '%@'",_tableName];
            BOOL delRes = [_db executeUpdate:delSql];
            NSString *delEventSql = [NSString stringWithFormat:@"delete from '%@'",_eventTableName];
            BOOL delEventRes = [_db executeUpdate:delEventSql];
            
            NSString *delLunciSql = [NSString stringWithFormat:@"delete from '%@'",_lunciTableName];
            BOOL delLunciRes = [_db executeUpdate:delLunciSql];
            
            
            if (delRes && delEventRes && delLunciRes) {
                
                NSArray * dataArr = [resultData objectForKey:@"data"];
                NSArray *eventArr = [resultData objectForKey:@"event"];
                NSArray *lunciArr = [resultData objectForKey:@"lunci"];
                
                //国内外   测试
                eventArr = @[@{@"name":@"国内",@"selected":@"0"},@{@"name":@"国外",@"selected":@"0"}];
                lunciArr = @[@{@"name":@"种子轮",@"selected":@"0"},@{@"name":@"天使轮",@"selected":@"0"},@{@"name":@"Pre-A轮",@"selected":@"0"},@{@"name":@"A轮",@"selected":@"0"},@{@"name":@"A+轮",@"selected":@"0"},@{@"name":@"Pre-B轮",@"selected":@"0"},@{@"name":@"B轮",@"selected":@"0"},@{@"name":@"B+轮",@"selected":@"0"},@{@"name":@"C轮",@"selected":@"0"},@{@"name":@"C+轮",@"selected":@"0"},@{@"name":@"D轮~Pre-IPO",@"selected":@"0"},@{@"name":@"战略融资",@"selected":@"0"}];
                NSMutableArray *retMArr = [self handelArr:dataArr ToArr:self.selectedMArr ofTableName:_tableName];
                NSMutableArray *retEventMArr = [self handelArr:eventArr ToArr:self.selectedEventMArr ofTableName:_eventTableName];
                NSMutableArray *retLunciMArr = [self handelArr:lunciArr ToArr:self.selectedLunciArr ofTableName:_lunciTableName];
                
                if (isFirst || !oldHash) {
                    
                    //保留最开始选中的行业
                    self.oldLyselectedMArr = [NSArray arrayWithArray:self.selectedMArr];
                    self.oldEventselectedMArr = [NSArray arrayWithArray:self.selectedEventMArr];
                    self.oldLunciselectedMArr = [NSArray arrayWithArray:self.selectedLunciArr];
                    self.industryArr = retMArr;
                    self.eventArr = retEventMArr;
                    self.lunciArr = retLunciMArr;
                    [self.tableView reloadData];
                    
                }
            }
            
        }];
        
    }else{
        
        self.oldLyselectedMArr = [NSArray arrayWithArray:self.selectedMArr];
        self.oldEventselectedMArr = [NSArray arrayWithArray:self.selectedEventMArr];
        self.oldLunciselectedMArr = [NSArray arrayWithArray:self.selectedLunciArr];
        
    }
}

- (NSMutableArray *)handelArr:(NSArray *)dataArr ToArr:(NSMutableArray *)selectedMArr ofTableName:(NSString *)tableName{
    NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *sql = @"";
    
    if (dataArr.count > 0 ) {
        
        NSDictionary *dataDict = dataArr[0];
        NSString *name = dataDict[@"name"];
        if ([name isEqualToString:@"CN"]) {
            name = @"国内";
        }
        if ([name isEqualToString:@"EN"]) {
            name = @"国外";
        }
        
        
        sql = [NSString stringWithFormat:@"insert into '%@' (name,selected) values('%@','%@')",tableName,name,dataDict[@"selected"]];
        
        if (dataArr.count > 1) {
            for (int i = 1; i < dataArr.count ; i++) {
                NSDictionary *dataDict = dataArr[i];
                NSString *name = dataDict[@"name"];
                if ([name isEqualToString:@"CN"]) {
                    name = @"国内";
                }
                if ([name isEqualToString:@"EN"]) {
                    name = @"国外";
                }
                
                NSString *value = [NSString stringWithFormat:@",('%@','%@')",name,@"0"];
                sql = [NSString stringWithFormat:@"%@%@",sql,value];
                
            }
        }
    }
    
    NSLog(@"insertSql========%@",sql);
    
    BOOL res = [_db executeUpdate:sql];
    
    if (res) {
        
        [selectedMArr removeAllObjects];
        
        for (NSDictionary *dataDict in dataArr) {
            IndustryItem *item = [[IndustryItem alloc] init];
            [item setValuesForKeysWithDictionary:dataDict];
            NSString *name = item.name;
            if ([name isEqualToString:@"CN"]) {
                name = @"国内";
            }
            if ([name isEqualToString:@"EN"]) {
                name = @"国外";
            }
            
            item.name = name;
            item.selected = @"0";
            
            [retMArr addObject:item];
        }
    }
    
    return retMArr;
}
#pragma mark - 懒加载
- (NSMutableArray *)industryArr{
    
    if (!_industryArr) {
        _industryArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _industryArr;
}

- (NSMutableArray *)eventArr{
    
    if (!_eventArr) {
        _eventArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _eventArr;
}
- (NSMutableArray *)lunciArr{
    
    if (!_lunciArr) {
        _lunciArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _lunciArr;
}
- (NSMutableArray *)selectedMArr{
    
    if (!_selectedMArr) {
        _selectedMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedMArr;
}

- (NSMutableArray *)selectedEventMArr{
    
    if (!_selectedEventMArr) {
        _selectedEventMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedEventMArr;
}
- (NSMutableArray *)selectedLunciArr{
    
    if (!_selectedLunciArr) {
        _selectedLunciArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedLunciArr;
}


- (NSArray *)sectionArr{
    
    if (!_sectionArr) {
        if([self.countryKey containsString:@"BingGou"]){
            _sectionArr = @[@"领域",@"国家"];
        }else{
            _sectionArr = @[@"领域",@"轮次",@"地区",@"事件",@"地区"];
        }
        
    }
    return _sectionArr;
}
@end
