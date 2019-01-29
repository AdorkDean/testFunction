//
//  DatePickerView.m
//  qmp_ios
//
//  Created by QMP on 2018/1/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DatePickerView.h"
@interface DatePickerView () <UIPickerViewDataSource,UIPickerViewDelegate, UIGestureRecognizerDelegate>{
    UIView *contentView;
    void(^backBlock)(NSString *);
    
    NSMutableArray *yearArray;
    NSMutableArray *monthArray;
    NSMutableArray *dayArray;

    NSInteger currentYear;
    NSInteger currentMonth;
    NSInteger currentDay;

    NSString *restr;
    
    NSString *selectedYear;
    NSString *selectecMonth;
    NSString *selectecDay;

}

@property (nonatomic, weak) UIPickerView *pickerView;
@end

@implementation DatePickerView

#pragma mark - initDatePickerView
- (instancetype)initDatePackerWithResponse:(void (^)(NSString *))block{
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    [self addView];
    if (block) {
        backBlock = block;
    }
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tapGest.delegate = self;
    [self addGestureRecognizer:tapGest];
    return self;
}

- (instancetype)initDatePackerWithNumColoum:(NSString*)ranksNum response:(void (^)(NSString *))block{
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    self.ranksCount = ranksNum;
    [self addView];
    if (block) {
        backBlock = block;
    }
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tapGest.delegate = self;
    [self addGestureRecognizer:tapGest];
    return self;
}


#pragma mark - ConfigurationUI
- (void)addView {
    //获取当前时间 （时间格式支持自定义）
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];//自定义时间格式
    NSString *currentDateStr = [formatter stringFromDate:[NSDate date]];
    //拆分年月成数组
    NSArray *dateArray = [currentDateStr componentsSeparatedByString:@"-"];
    if (dateArray.count == 3) {//年 月 日
        currentYear = [[dateArray firstObject]integerValue];
        currentMonth =  [dateArray[1] integerValue];
        currentDay =  [dateArray[2] integerValue];

    }
    selectedYear = [NSString stringWithFormat:@"%ld",(long)currentYear];
    selectecMonth = [NSString stringWithFormat:@"%ld",(long)currentMonth];
    selectecDay = [NSString stringWithFormat:@"%ld",(long)currentDay];

    //初始化年数据源数组
    yearArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1970; i <= currentYear ; i++) {
        NSString *yearStr = [NSString stringWithFormat:@"%ld年",(long)i];
        [yearArray addObject:yearStr];
    }
    
    if ([PublicTool isNull:self.ranksCount]) {
        [yearArray addObject:@"至今"];
    }
    
    //初始化月数据源数组
    monthArray = [NSMutableArray array];
    for (int i = 1; i<=currentMonth; i++) {
        [monthArray addObject:[NSString stringWithFormat:@"%d",i]];
    }

    [self DaysfromYear:selectedYear.integerValue andMonth:selectecMonth.integerValue];
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 300)];
    [self addSubview:contentView];
    //设置背景颜色为黑色，并有0.4的透明度
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    //添加白色view
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:whiteView];
    //添加确定和取消按钮
    for (int i = 0; i < 2; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 60) * i, 0, 60, 40)];
        [button setTitle:i == 0 ? @"取消" : @"确定" forState:UIControlStateNormal];
        if (i == 0) {
            [button setTitleColor:[UIColor colorWithRed:97.0 / 255.0 green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1] forState:UIControlStateNormal];
        } else {
            [button setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        }
        [whiteView addSubview:button];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 10 + i;
    }
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.bounds), 260)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView = pickerView;
    
    //设置pickerView默认选中当前时间
    [pickerView selectRow:[selectedYear integerValue] - 1970 inComponent:0 animated:YES];
    if (![self.ranksCount isEqualToString:@"1"]) {
        [pickerView selectRow:[selectecMonth integerValue] - 1 inComponent:1 animated:YES];
    }
    if (![PublicTool isNull:self.ranksCount]) {
        if ([self.ranksCount isEqualToString:@"3"]) {
            [pickerView selectRow:[selectecDay integerValue] - 1 inComponent:2 animated:YES];
        }
    }
    
    [contentView addSubview:pickerView];
}

//通过年月求每月天数
- (NSInteger)DaysfromYear:(NSInteger)year andMonth:(NSInteger)month
{
    NSInteger num_year  = year;
    NSInteger num_month = month;
    
    BOOL isrunNian = num_year%4==0 ? (num_year%100==0? (num_year%400==0?YES:NO):YES):NO;
    switch (num_month) {
        case 1:case 3:case 5:case 7:case 8:case 10:case 12:{
            [self setdayArray:31];
            return 31;
        }
        case 4:case 6:case 9:case 11:{
            [self setdayArray:30];
            return 30;
        }
        case 2:{
            if (isrunNian) {
                [self setdayArray:29];
                return 29;
            }else{
                [self setdayArray:28];
                return 28;
            }
        }
        default:
            break;
    }
    
    return 0;
}

//设置每月的天数数组
- (void)setdayArray:(NSInteger)num
{
    if (!dayArray) {
        dayArray = [NSMutableArray array];
    }
    [dayArray removeAllObjects];
    for (int i=1; i<=num; i++) {
        [dayArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    if (self.ranksCount.integerValue == 3) {
        if (selectedYear.integerValue == currentYear && selectecMonth.integerValue == currentMonth) {
            [dayArray removeAllObjects];
            for (int i=1; i <= currentDay; i++) {
                [dayArray addObject:[NSString stringWithFormat:@"%02d",i]];
            }
        }
    }
    
}

#pragma mark - Actions
- (void)buttonTapped:(UIButton *)sender {
    if (sender.tag == 10) {
        [self dismiss];
    } else {
        if (![PublicTool isNull:self.ranksCount]) {
    
            if ([self.ranksCount isEqualToString:@"1"]) {
                restr = [NSString stringWithFormat:@"%@", selectedYear];
            } else if ([self.ranksCount isEqualToString:@"2"]) {
                restr = [NSString stringWithFormat:@"%@-%@",selectedYear,selectecMonth];
            } else {
                restr = [NSString stringWithFormat:@"%@-%@-%@",selectedYear,selectecMonth,selectecDay];
            }


        }else{
            if ([selectecMonth isEqualToString:@""]) {//至今的情况下 不需要中间-
                restr = [NSString stringWithFormat:@"%@%@",selectedYear,selectecMonth];
            } else {
                restr = [NSString stringWithFormat:@"%@.%@",selectedYear,selectecMonth];
            }
        }
        
        restr = [restr stringByReplacingOccurrencesOfString:@"年" withString:@""];
        restr = [restr stringByReplacingOccurrencesOfString:@"月" withString:@""];
        backBlock(restr);
        [self dismiss];
    }
}

#pragma mark - pickerView出现
- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.4 animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y - contentView.frame.size.height);
    }];
}
- (void)showSoFar {
    if ([PublicTool isNull:self.ranksCount]) {
        [self.pickerView selectRow:yearArray.count - 1 inComponent:0 animated:YES];
        [self pickerView:self.pickerView didSelectRow:yearArray.count - 1 inComponent:0];
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.4 animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y - contentView.frame.size.height);
    }];
}
#pragma mark - pickerView消失
- (void)dismiss{
    
    [UIView animateWithDuration:0.4 animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y + contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIPickerViewDataSource UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (![PublicTool isNull:self.ranksCount]) {
        return self.ranksCount.integerValue;
    }
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return yearArray.count;
    }else if (component == 1) {
        return monthArray.count;
    }else if (component == 2) {
        return dayArray.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return yearArray[row];
    } else if (component == 1) {
        return monthArray[row];
    }else if (component == 2) {
        return dayArray[row];
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 0) {
        selectedYear = yearArray[row];
        NSString *year = [selectedYear stringByReplacingOccurrencesOfString:@"年" withString:@""];
        if ([year isEqualToString:@"至今"]) {//至今的情况下,月份清空
            [monthArray removeAllObjects];
            selectecMonth = @"";
        } else if(year.integerValue == currentYear){//今年
            
            monthArray = [[NSMutableArray alloc]init];
            for (NSInteger i = 1 ; i <= currentMonth; i++) {
                NSString *monthStr = [NSString stringWithFormat:@"%ld月",(long)i];
                [monthArray addObject:monthStr];
            }
            if ([pickerView numberOfComponents] > 1) {
                selectecMonth = monthArray[[pickerView selectedRowInComponent:1]];
            }
            
        }else{ //往年
            
            monthArray = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"]];
            if ([pickerView numberOfComponents] > 1) {
                selectecMonth = monthArray[[pickerView selectedRowInComponent:1]];
            }
        }
        
        if (![self.ranksCount isEqualToString:@"1"]) {
            [pickerView reloadComponent:1];
        }

        if (![PublicTool isNull:self.ranksCount]) {
            if ([self.ranksCount isEqualToString:@"3"]) {
                [self DaysfromYear:selectedYear.integerValue andMonth:selectecMonth.integerValue];
                [pickerView reloadComponent:2];
                if ([pickerView selectedRowInComponent:2] < dayArray.count) {
                    selectecDay = dayArray[[pickerView selectedRowInComponent:2]];
                }
            }
        }
        
    } else if (component == 1) {
        if (row >= monthArray.count) {
            return;
        }
        selectecMonth = monthArray[row];
        if (![PublicTool isNull:self.ranksCount]) {
            
            if ([self.ranksCount isEqualToString:@"3"]) {
                
                [self DaysfromYear:selectedYear.integerValue andMonth:selectecMonth.integerValue];
                [pickerView reloadComponent:2];
            }
        }

    }else if (component == 2){
        if (row >= dayArray.count) {
            return;
        }
        selectecDay = dayArray[row];
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:contentView]) {
        return NO;
    }
    return YES;
}
@end

@interface SLDatePickerView()<UIPickerViewDataSource,UIPickerViewDelegate, UIGestureRecognizerDelegate>{
    UIView *contentView;
    void(^backBlock)(NSString *);
    
    NSMutableArray *yearArray;
    NSMutableArray *monthArray;
    NSMutableArray *dayArray;
    
    NSInteger currentYear;
    NSInteger currentMonth;
    NSInteger currentDay;
    
    NSString *restr;
    
    NSString *selectedYear;
    NSString *selectecMonth;
    NSString *selectecDay;
    
}


@end
@implementation SLDatePickerView
#pragma mark - initDatePickerView
- (instancetype)initDatePackerWithResponse:(void (^)(NSString *))block{
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    [self addView];
    if (block) {
        backBlock = block;
    }
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tapGest.delegate = self;
    [self addGestureRecognizer:tapGest];
    return self;
}

- (instancetype)initDatePackerWithNumColoum:(NSString*)ranksNum response:(void (^)(NSString *))block{
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    [self addView];
    if (block) {
        backBlock = block;
    }
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tapGest.delegate = self;
    [self addGestureRecognizer:tapGest];
    return self;
}


#pragma mark - ConfigurationUI
- (void)addView {
    //获取当前时间 （时间格式支持自定义）
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];//自定义时间格式
    NSString *currentDateStr = [formatter stringFromDate:[NSDate date]];
    //拆分年月成数组
    NSArray *dateArray = [currentDateStr componentsSeparatedByString:@"-"];
    if (dateArray.count == 3) {//年 月 日
        currentYear = [[dateArray firstObject]integerValue];
        currentMonth =  [dateArray[1] integerValue];
        currentDay =  [dateArray[2] integerValue];
    }
    
    selectedYear = [NSString stringWithFormat:@"%ld",(long)currentYear];
    selectecMonth = [NSString stringWithFormat:@"%ld",(long)currentMonth];
    selectecDay = [NSString stringWithFormat:@"%ld",(long)currentDay+1];
    
    //初始化年数据源数组
    yearArray = [[NSMutableArray alloc]init];
    [yearArray addObject:[NSString stringWithFormat:@"%ld", currentYear]];
    if (currentMonth >= 10) {
        [yearArray addObject:[NSString stringWithFormat:@"%ld", currentYear+1]];
    }
    
    //初始化月数据源数组
    monthArray = [NSMutableArray array];
    NSInteger month = currentMonth;
    for (NSInteger i = 0; i < 4; i++) {
        if (month > 12) {
            break;
        }
        [monthArray addObject:[NSString stringWithFormat:@"%zd", month]];
        month++;
    }
    if (yearArray.count > 1) {
        monthArray = [NSMutableArray array];
        NSInteger month = 4 - (12 -  currentMonth + 1);
        
        for (NSInteger i = 1; i <= month; i++) {
            [monthArray addObject:[NSString stringWithFormat:@"%zd", i]];
        }
        
    }
    
   
    //初始化日数据源数组
    NSInteger days = [self DaysfromYear:currentYear andMonth:currentMonth];
    dayArray = [NSMutableArray array];
//    for (NSInteger i = currentDay+1; i<=days; i++) {
//        [dayArray addObject:[NSString stringWithFormat:@"%zd", i]];
//    }
    for (NSInteger i = 1; i<=currentDay; i++) {
        [dayArray addObject:[NSString stringWithFormat:@"%zd", i]];
    }
    
    
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 300)];
    [self addSubview:contentView];
    //设置背景颜色为黑色，并有0.4的透明度
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    
    //添加白色view
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40+24)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:whiteView];
    
    UILabel *label = [[UILabel alloc] init];
    
    NSMutableAttributedString *maStr = [[NSMutableAttributedString alloc] initWithString:@"*项目上架最多可在本平台展示三个月，超过三个月自动下架"
                                                                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                                                                           NSForegroundColorAttributeName: H9COLOR,
                                                                                           }];
    
    [maStr setAttributes:@{NSForegroundColorAttributeName: RED_DARKCOLOR,
                           NSFontAttributeName:[UIFont systemFontOfSize:12],
                           } range:NSMakeRange(0, 1)];
    label.attributedText = maStr;//[self fixCellTitleShow:@"*项目上架最多可在本平台展示三个月，超过三个月自动下架"];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(15, 6, SCREENW-30, 14);
    [whiteView addSubview:label];
    //添加确定和取消按钮
    for (int i = 0; i < 2; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 60) * i, 24, 60, 40)];
        [button setTitle:i == 0 ? @"取消" : @"确定" forState:UIControlStateNormal];
        if (i == 0) {
            [button setTitleColor:[UIColor colorWithRed:97.0 / 255.0 green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1] forState:UIControlStateNormal];
        } else {
            [button setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        }
        [whiteView addSubview:button];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 10 + i;
    }
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.bounds), 260)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.backgroundColor = [UIColor whiteColor];
    
    //设置pickerView默认选中当前时间
    [pickerView selectRow:yearArray.count-1 inComponent:0 animated:YES];
    [pickerView selectRow:monthArray.count-1 inComponent:1 animated:YES];
    [pickerView selectRow:dayArray.count-1 inComponent:2 animated:YES];
    
    selectedYear = [NSString stringWithFormat:@"%ld",(long)([yearArray.lastObject integerValue])];
    selectecMonth = [NSString stringWithFormat:@"%ld",(long)([monthArray.lastObject integerValue])];
    selectecDay = [NSString stringWithFormat:@"%ld",(long)([dayArray.lastObject integerValue])];
    
    [contentView addSubview:pickerView];
    
    [contentView bringSubviewToFront:whiteView];
}

//通过年月求每月天数
- (NSInteger)DaysfromYear:(NSInteger)year andMonth:(NSInteger)month
{
    NSInteger num_year  = year;
    NSInteger num_month = month;
    
    BOOL isrunNian = num_year%4==0 ? (num_year%100==0? (num_year%400==0?YES:NO):YES):NO;
    switch (num_month) {
        case 1:case 3:case 5:case 7:case 8:case 10:case 12:{
                        return 31;
        }
        case 4:case 6:case 9:case 11:{
            
            return 30;
        }
        case 2:{
            if (isrunNian) {
                return 29;
            }else{
                return 28;
            }
        }
        default:
            break;
    }
    return 0;
}


#pragma mark - Actions
- (void)buttonTapped:(UIButton *)sender {
    if (sender.tag == 10) {
        [self dismiss];
    } else {
        if (selectecMonth.length == 1) {
            selectecMonth = [NSString stringWithFormat:@"0%@", selectecMonth];
        }
        restr = [NSString stringWithFormat:@"%@-%@-%@",selectedYear,selectecMonth, selectecDay];
        restr = [restr stringByReplacingOccurrencesOfString:@"年" withString:@""];
        restr = [restr stringByReplacingOccurrencesOfString:@"月" withString:@""];
        backBlock(restr);
        [self dismiss];
    }
}

#pragma mark - pickerView出现
- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.4 animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y - contentView.frame.size.height);
    }];
}
#pragma mark - pickerView消失
- (void)dismiss{
    
    [UIView animateWithDuration:0.4 animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y + contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIPickerViewDataSource UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return yearArray.count;
    }else if (component == 1) {
        return monthArray.count;
    }else if (component == 2) {
        return dayArray.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return yearArray[row];
    } else if (component == 1) {
        return monthArray[row];
    }else if (component == 2) {
        return dayArray[row];
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 0) {
        selectedYear = yearArray[row];
        
        monthArray = [NSMutableArray array];
        if (selectedYear.integerValue != currentYear) {
            NSInteger month = 4 - (12 -  currentMonth + 1);
            
            for (NSInteger i = 1; i <= month; i++) {
                [monthArray addObject:[NSString stringWithFormat:@"%zd", i]];
            }
        } else {
            NSInteger month = currentMonth;
            for (NSInteger i = 0; i < 4; i++) {
                if (month > 12) {
                    break;
                }
                [monthArray addObject:[NSString stringWithFormat:@"%zd", month]];
                month++;
            }
        }
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [self pickerView:pickerView didSelectRow:0 inComponent:1];
        
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        [self pickerView:pickerView didSelectRow:0 inComponent:2];
        
    } else if (component == 1) {
        if (row >= monthArray.count) {
            return;
        }
        selectecMonth = monthArray[row];
        
        NSInteger days = [self DaysfromYear:selectedYear.integerValue andMonth:selectecMonth.integerValue];
        dayArray = [NSMutableArray array];
        
        
        if ((yearArray.count==1 || selectedYear.integerValue != currentYear) && row+1 == monthArray.count) {
            for (NSInteger i = 1; i<=currentDay; i++) {
                [dayArray addObject:[NSString stringWithFormat:@"%zd", i]];
            }
        } else {
            NSInteger startDay = selectecMonth.integerValue == currentMonth ? currentDay+1 : 1;
            for (NSInteger i = startDay; i<=days; i++) {
                [dayArray addObject:[NSString stringWithFormat:@"%zd", i]];
            }
        }
        
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        [self pickerView:pickerView didSelectRow:0 inComponent:2];
        
        selectecDay = dayArray[0];

    }else if (component == 2){
        if (row >= dayArray.count) {
            return;
        }
        selectecDay = dayArray[row];
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:contentView]) {
        return NO;
    }
    return YES;
}
- (NSAttributedString *)fixCellTitleShow:(NSString *)str {
    NSMutableAttributedString *maStr = [[NSMutableAttributedString alloc] initWithString:str];
    if ([str hasPrefix:@"*"]) {
        [maStr setAttributes:@{NSForegroundColorAttributeName: RED_DARKCOLOR} range:NSMakeRange(0, 1)];
    } else {
        [maStr insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
    }
    return maStr;
}
@end
