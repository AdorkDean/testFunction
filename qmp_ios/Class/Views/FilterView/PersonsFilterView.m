//
//  RzEventFilterView.m
//  qmp_ios_v2.0
//
//  Created by molly on 2017/8/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "PersonsFilterView.h"
#import "RzfilterTableViewCell.h"
#import "RzPartfilterTableViewCell.h"
#import "CenterButton.h"

#import "IndustryItem.h"

#import "ManagerHud.h"
#import "TestNetWorkReached.h"

#define showCount 12

@interface PersonsFilterView()<UITableViewDelegate,UITableViewDataSource>{
    NSString *_tableName;
    NSString *_roleTableName;
    NSString *_provinceTableName;
    
    BOOL _isPart;
}

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *resetBtn;
@property (strong, nonatomic) UIButton *confirmBtn;
@property (strong, nonatomic) CenterButton *centerBtn;
@property (strong, nonatomic) FMDatabase *db;

@property (strong, nonatomic) NSMutableArray *industryArr;
@property (strong, nonatomic) NSMutableArray *roleArr;
@property (strong, nonatomic) NSMutableArray *provinceArr;

@property (strong, nonatomic) NSMutableArray *selectedMArr;
@property (strong, nonatomic) NSMutableArray *selectedRoleMArr;
@property (strong, nonatomic) NSMutableArray *selectedProvinceArr;

@property (strong, nonatomic) NSArray *oldLyselectedMArr;
@property (strong, nonatomic) NSArray *oldRoleselectedMArr;
@property (strong, nonatomic) NSArray *oldProvinceselectedMArr;


@property (strong, nonatomic) NSArray *sectionArr;
@property (strong, nonatomic) NSString *countryKey;

@property (strong, nonatomic) ManagerHud *hud;

@end
@implementation PersonsFilterView

- (void)dealloc{
    
    if (_db) {
        [_db close];
    }
}


+ (PersonsFilterView *)initWithFrame:(CGRect)frame withKey:(NSString *)countryKey{
    
    PersonsFilterView *drawerView = [[PersonsFilterView alloc] initWithFrame:frame];
    drawerView.countryKey = countryKey;
    [drawerView initView];
    return drawerView;
}


- (void)initView{
    
    _isPart = YES;
   
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
    
    _tableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterindustry",self.countryKey]];
    _roleTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterpersonrole",self.countryKey]];
    _provinceTableName = [[DBHelper shared] toGetTablename:[NSString stringWithFormat:@"%@filterprovince",self.countryKey]];
    
    _db = [[DBHelper shared] toGetDB];
    
    BOOL tableExist = YES;
    
    if ([_db open]) {
        
        if ([[DBHelper shared] isTableOK:_tableName ofDataBase:_db] &&[[DBHelper shared] isTableOK:_roleTableName ofDataBase:_db] &&[[DBHelper shared] isTableOK:_provinceTableName ofDataBase:_db]) {
            //如果表存在,直接赋值
            
            //领域
            [self toGetDataFromDbWithTableName:_tableName withNowSelectedMArr:self.selectedMArr withNowDataArr:self.industryArr];
            
            //角色
            [self toGetDataFromDbWithTableName:_roleTableName withNowSelectedMArr:self.selectedRoleMArr withNowDataArr:self.roleArr];
            
            //省份
            [self toGetDataFromDbWithTableName:_provinceTableName withNowSelectedMArr:self.selectedProvinceArr withNowDataArr:self.provinceArr];
            
            if (self.industryArr.count > 0 && self.roleArr.count > 0 && self.provinceArr.count > 0) {
                //刷新列表
                [self.tableView reloadData];
                
                self.oldLyselectedMArr = [NSMutableArray arrayWithArray:self.selectedMArr];
                self.oldRoleselectedMArr = [NSMutableArray arrayWithArray:self.selectedRoleMArr];
                self.oldProvinceselectedMArr = [NSMutableArray arrayWithArray:self.selectedProvinceArr];
                
            }
            
        }
        else{
            tableExist = NO;
            //如果不存在表,则创建该表
            [self createTable:_tableName];
            [self createTable:_roleTableName];
            [self createTable:_provinceTableName];
            
        }
    }
    
    if (tableExist == NO || self.industryArr.count == 0 || self.roleArr.count == 0 || self.provinceArr.count == 0){
        
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
    [self.selectedRoleMArr removeAllObjects];
    [self.selectedProvinceArr removeAllObjects];
    
    [self resetMArr:self.industryArr];
    [self resetMArr:self.roleArr];
    [self resetMArr:self.provinceArr];
    
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
    
    if (self.selectedMArr.count == self.oldLyselectedMArr.count && self.selectedRoleMArr.count == self.oldRoleselectedMArr.count && self.selectedProvinceArr.count == self.oldProvinceselectedMArr.count) {
        if ([self isEqualOfArr:self.oldLyselectedMArr withNewArr:self.selectedMArr] && [self isEqualOfArr:self.oldRoleselectedMArr withNewArr:self.selectedRoleMArr]&& [self isEqualOfArr:self.oldProvinceselectedMArr withNewArr:self.selectedProvinceArr]) {
            return;
            //如果与旧的筛选条件相同,则不进行刷新
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(updateFiltIndustryArr:withRoleMArr:provinceMArr:)]) {
        
        [self.delegate updateFiltIndustryArr:self.selectedMArr withRoleMArr:self.selectedRoleMArr provinceMArr:self.selectedProvinceArr];
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
    for (IndustryItem *item in self.roleArr) {
        if ([self.selectedRoleMArr containsObject:item.name]) {
            item.selected = @"1";
        }
        else{
            item.selected = @"0";
        }
    }
    for (IndustryItem *item in self.provinceArr) {
        if ([self.selectedProvinceArr containsObject:item.name]) {
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
    return 3;
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
        case 1:{
            cellIdentifier = @"RzPartfilterTableViewCell";
            selectedMArr = self.selectedMArr;
            dataMArr = self.industryArr;
            break;
        }
        case 2:{
            selectedMArr = self.selectedProvinceArr;
            dataMArr = self.provinceArr;
            break;
        }
        case 0:{
            selectedMArr = self.selectedRoleMArr;
            dataMArr = self.roleArr;
            break;
        }
        default:
            break;
    }
    if (indexPath.section == 1) {
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
        case 1:{
            NSInteger allCount = self.industryArr.count;
            
            num = _isPart ? (allCount > showCount ? showCount : allCount) : allCount;
            break;
        }
        case 2:{
            NSInteger allCount = self.provinceArr.count;
            
            num =  allCount;
            break;
        }
        case 0:{
            num = self.roleArr.count;
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
    }else {
        
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
    
    if (section == 1){
        
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
            NSString *delEventSql = [NSString stringWithFormat:@"delete from '%@'",_roleTableName];
            BOOL delEventRes = [_db executeUpdate:delEventSql];
            
            NSString *delLunciSql = [NSString stringWithFormat:@"delete from '%@'",_provinceTableName];
            BOOL delLunciRes = [_db executeUpdate:delLunciSql];
            
            
            if (delRes && delEventRes && delLunciRes) {
                
                NSArray * dataArr = [resultData objectForKey:@"data"];
                NSArray *roleArr = [resultData objectForKey:@"event"];
                NSArray *provinceArr = [resultData objectForKey:@"lunci"];
                
                //国内外   测试
                roleArr = @[@{@"name":@"投资人",@"selected":@"0"},@{@"name":@"FA",@"selected":@"0"}];
                provinceArr = [NSArray arrayWithContentsOfFile:[[BundleTool commonBundle]pathForResource:@"ProvinceFilter" ofType:@"plist"]];
                
                NSMutableArray *retMArr = [self handelArr:dataArr ToArr:self.selectedMArr ofTableName:_tableName];
                NSMutableArray *retEventMArr = [self handelArr:roleArr ToArr:self.selectedRoleMArr ofTableName:_roleTableName];
                NSMutableArray *retLunciMArr = [self handelArr:provinceArr ToArr:self.selectedProvinceArr ofTableName:_provinceTableName];
                
                if (isFirst || !oldHash) {
                    
                    //保留最开始选中的行业
                    self.oldLyselectedMArr = [NSArray arrayWithArray:self.selectedMArr];
                    self.oldRoleselectedMArr = [NSArray arrayWithArray:self.selectedRoleMArr];
                    self.oldProvinceselectedMArr = [NSArray arrayWithArray:self.selectedProvinceArr];
                    self.industryArr = retMArr;
                    self.roleArr = retEventMArr;
                    self.provinceArr = retLunciMArr;
                    [self.tableView reloadData];
                    
                }
            }
            
        }];
        
    }else{
        
        self.oldLyselectedMArr = [NSArray arrayWithArray:self.selectedMArr];
        self.oldRoleselectedMArr = [NSArray arrayWithArray:self.selectedRoleMArr];
        self.oldProvinceselectedMArr = [NSArray arrayWithArray:self.selectedProvinceArr];
        
    }
}

- (NSMutableArray *)handelArr:(NSArray *)dataArr ToArr:(NSMutableArray *)selectedMArr ofTableName:(NSString *)tableName{
    NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *sql = @"";
    
    if (dataArr.count > 0 ) {
        
        NSDictionary *dataDict = dataArr[0];
        NSString *name = dataDict[@"name"];
        
        sql = [NSString stringWithFormat:@"insert into '%@' (name,selected) values('%@','%@')",tableName,name,dataDict[@"selected"]];
        
        if (dataArr.count > 1) {
            for (int i = 1; i < dataArr.count ; i++) {
                NSDictionary *dataDict = dataArr[i];
                NSString *name = dataDict[@"name"];
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

- (NSMutableArray *)roleArr{
    
    if (!_roleArr) {
        _roleArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _roleArr;
}
- (NSMutableArray *)provinceArr{
    
    if (!_provinceArr) {
        _provinceArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _provinceArr;
}
- (NSMutableArray *)selectedMArr{
    
    if (!_selectedMArr) {
        _selectedMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedMArr;
}

- (NSMutableArray *)selectedRoleMArr{
    
    if (!_selectedRoleMArr) {
        _selectedRoleMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedRoleMArr;
}
- (NSMutableArray *)selectedProvinceArr{
    
    if (!_selectedProvinceArr) {
        _selectedProvinceArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedProvinceArr;
}


- (NSArray *)sectionArr{
    
    if (!_sectionArr) {
        _sectionArr = @[@"角色",@"领域",@"地区"];
    }
    return _sectionArr;
}
@end
