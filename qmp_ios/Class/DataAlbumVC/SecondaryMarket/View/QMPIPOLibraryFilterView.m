//
//  QMPIPOLibraryFilterView.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/9/5.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPIPOLibraryFilterView.h"
#import "FinanceEventFilterView.h"
#import "RzPartfilterTableViewCell.h"
#import "RzfilterTableViewCell.h"

@interface QMPIPOLibraryFilterView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *confirmButton;


@property (nonatomic, strong) NSArray *allBoardData;
@property (nonatomic, strong) NSArray *allStateData;
@property (nonatomic, strong) NSArray *allFieldData;

@property (nonatomic, strong) NSMutableArray *sections;

@property (nonatomic, strong) NSArray *oldSelectedAreaData2;
@property (nonatomic, strong) NSArray *oldSelectedRoundData2;
@property (nonatomic, strong) NSArray *oldSelectedTagData2;
@end

@implementation QMPIPOLibraryFilterView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initFilterSections];
        [self setupViews];
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
    
    self.oldSelectedTagData2 = [NSArray arrayWithArray:[self filterTags]];
    self.oldSelectedRoundData2 = [NSArray arrayWithArray:[self filterRound]];
    self.oldSelectedAreaData2 = [NSArray arrayWithArray:[self filterArea]];
    
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
- (BOOL)filterChange {
    return true;
//    BOOL a = [self aa:[self filterTags] bb:self.oldSelectedTagData2];
//    BOOL b = [self aa:[self filterRound] bb:self.oldSelectedRoundData2];
//    BOOL c = [self aa:[self filterArea] bb:self.oldSelectedAreaData2];
//    return !(a && b && c);
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
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger num = 0;
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
        infoLbl.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
    } else {
        infoLbl.font = [UIFont systemFontOfSize:16.f];
    }
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
        expadingButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [expadingButton setTitleColor:H5COLOR forState:UIControlStateNormal];
        [expadingButton setTitle:@"展开" forState:UIControlStateNormal];
        [expadingButton setTitle:@"收起" forState:UIControlStateSelected];
        [expadingButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
        [expadingButton setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateSelected];
        expadingButton.frame = CGRectMake(w-centerW, 0, centerW, h);
        expadingButton.tag = section;
        [expadingButton addTarget:self action:@selector(expadingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerV addSubview:expadingButton];
        [expadingButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:2];
        
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
- (void)expadingButtonClick:(UIButton *)button {
    button.selected = !button.selected;
    
    NSInteger index = button.tag;
    QMPFilterSection *sectionData = self.sections[index];
    sectionData.expanding = !sectionData.expanding;
    
    [UIView performWithoutAnimation:^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
    }];
}
- (void)removeFilterView:(UITapGestureRecognizer *)tapGest {
    [self hide];
    if (self.confirmButtonClick && [self filterChange]) {
        self.confirmButtonClick(self.sections);
    }
}
- (void)confirmButtonClick:(UIButton *)button {
    [self hide];
    if (self.confirmButtonClick && [self filterChange]) {
        self.confirmButtonClick(self.sections);
    }
}
- (void)resetButtonClick:(UIButton *)button {
    [self hide];
    [self initFilterSections];
    [self.tableView reloadData];
    if (self.confirmButtonClick && [self filterChange]) {
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
        _resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, (SCREENW-85*ratioWidth)/2.0, 49)];
        _resetButton.backgroundColor = [UIColor whiteColor];
        [_resetButton setTitle:@"重置" forState:UIControlStateNormal];
        [_resetButton setTitleColor:H5COLOR  forState:UIControlStateNormal];
        [_resetButton addTarget:self action:@selector(resetButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetButton;
}
- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(self.resetButton.right, 0, (SCREENW-85*ratioWidth)/2.0, 49)];
        _confirmButton.backgroundColor = BLUE_TITLE_COLOR;
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
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
- (NSArray *)allBoardData {
    if (!_allBoardData) {
        _allBoardData = @[
                            @{@"name":@"上交所", @"selected":@"0"},
                            @{@"name":@"深交所主板", @"selected":@"0"},
                            @{@"name":@"深交所中小板", @"selected":@"0"},
                            @{@"name":@"深交所创业板", @"selected":@"0"},
                            @{@"name":@"港交所主板", @"selected":@"0"},
                            @{@"name":@"港交所创业板", @"selected":@"0"},
                            @{@"name":@"纽交所", @"selected":@"0"},
                            @{@"name":@"纳斯达克", @"selected":@"0"},
                            @{@"name":@"美交所", @"selected":@"0"},
                            @{@"name":@"新三板", @"selected":@"0"},
                          ];
    }
    return _allBoardData;
}



- (void)initFilterSections {
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    QMPFilterSection *section1 = [[QMPFilterSection alloc] init];
    section1.title = @"交易板块";
    section1.type = @"board";
    section1.dataArray = [self fix:self.allBoardData];
    section1.selectedArray = [NSMutableArray array];
    section1.selectedArray2 = [NSMutableArray array];
    [tmpArray addObject:section1];
    
    QMPFilterSection *section2 = [[QMPFilterSection alloc] init];
    section2.title = @"行业领域";
    section2.type = @"field";
    section2.dataArray = [self fix:self.allFieldData];
    section2.selectedArray = [NSMutableArray array];
    [tmpArray addObject:section2];
    
    self.sections = tmpArray;
}
- (NSMutableArray *)fix:(NSArray *)arr {
    NSMutableArray *tmpArr = [NSMutableArray array];
    for (NSDictionary *dict in arr) {
        QMPFilterItem *item = [[QMPFilterItem alloc] init];
        item.name = dict[@"name"];
        item.selected = [NSString stringWithFormat:@"%@", dict[@"selected"]];
        
        NSMutableArray *tmpArr2 = [NSMutableArray array];
        if (![PublicTool isNull:dict[@"place"]]) {
            for (NSDictionary *dict2 in dict[@"place"]) {
                QMPFilterItem *item2 = [[QMPFilterItem alloc] init];
                item2.name = dict2[@"name"];
                item2.selected = [NSString stringWithFormat:@"%@", dict2[@"selected"]];
                [tmpArr2 addObject:item2];
            }
        }
        item.subItems = tmpArr2;
        
        [tmpArr addObject:item];
    }
    return tmpArr;
}
- (NSArray *)filteBoard {
    for (QMPFilterSection *section in self.sections) {
        if ([section.title isEqualToString:@"交易板块"]) {
            return section.selectedArray;
        }
    }
    return nil;
}
- (NSArray *)filterPlace {
    for (QMPFilterSection *section in self.sections) {
        if ([section.title isEqualToString:@"交易板块"]) {
            return section.selectedArray;
        }
    }
    return nil;
}
- (NSArray *)filterTags {
    for (QMPFilterSection *section in self.sections) {
        if ([section.title isEqualToString:@"行业领域"]) {
            return section.selectedArray;
        }
    }
    return nil;
}
- (NSArray *)filterRound {
    for (QMPFilterSection *section in self.sections) {
        if ([section.title isEqualToString:@"轮次"]) {
            return section.selectedArray;
        }
    }
    return nil;
}
- (NSArray *)filterArea {
    for (QMPFilterSection *section in self.sections) {
        if ([section.title isEqualToString:@"地区"]) {
            return section.selectedArray;
        }
    }
    return nil;
}
- (BOOL)aa:(NSArray *)a bb:(NSArray *)b {
    BOOL bol = false;
    
    NSMutableArray *oldArr = [NSMutableArray arrayWithArray:a];
    NSMutableArray *newArr = [NSMutableArray arrayWithArray:b];
    
    [oldArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return obj1 > obj2;
    }];
    
    [newArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return obj1 > obj2;
    }];
    
    if (newArr.count == oldArr.count) {
        
        bol = true;
        for (int16_t i = 0; i < oldArr.count; i++) {
            
            id c1 = [oldArr objectAtIndex:i];
            id newc = [newArr objectAtIndex:i];
            
            if (![newc isEqualToString:c1]) {
                bol = false;
                break;
            }
        }
    }
    return bol;
}
@end
