//
//  ProductAppDataViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/7/20.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductAppDataViewController.h"
#import "ZFChart.h"

@interface ProductAppDataViewController () <ZFLineChartDelegate, ZFGenericChartDataSource, ZFBarChartDelegate>
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UILabel *rankLabel;
@property (nonatomic, strong) ZFLineChart *lineChart;
@property (nonatomic, strong) UISegmentedControl *segmentView;
@property (nonatomic, strong) NSMutableArray *chartData;
@property (nonatomic, strong) NSMutableArray *chartBData;
@property (nonatomic, assign) NSInteger max;
@property (nonatomic, assign) NSInteger min;
@property (nonatomic, strong) UILabel *scoreLabel;

@property (nonatomic, strong) UILabel *sourceLabel;
@property (nonatomic, strong) UILabel *sourceLabel2;

@property (nonatomic, strong) UILabel *downloadLabel;
@property (nonatomic, strong) UISegmentedControl *downSegmentView;
@property (nonatomic, strong) ZFBarChart *barChart;
@property (nonatomic, strong) NSMutableArray *barChartData;
@property (nonatomic, strong) NSMutableArray *barChartBData;
@property (nonatomic, assign) NSInteger bMax;
@property (nonatomic, assign) NSInteger bMin;
@property (nonatomic, strong) UILabel *allDownloadLabel;

@property (nonatomic, strong) UIView *separatorView;
@end

@implementation ProductAppDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.contentView];
    
    [self.contentView addSubview:self.lineChart];
    [self.contentView addSubview:self.rankLabel];
    [self.contentView addSubview:self.scoreLabel];
    [self.contentView addSubview:self.sourceLabel];
    [self.contentView addSubview:self.segmentView];
    [self loadRankData:6];
    self.navigationItem.title = self.appName;
    
    [self.contentView addSubview:self.barChart];
    [self.contentView addSubview:self.downloadLabel];
    [self.contentView addSubview:self.downSegmentView];
    [self.contentView addSubview:self.sourceLabel2];
    [self.contentView addSubview:self.allDownloadLabel];
    
    [self.contentView addSubview:self.separatorView];
    
    self.separatorView.centerY = self.scoreLabel.bottom + (self.downloadLabel.top-self.scoreLabel.bottom)/2.0;
    [self loadDownData:7];
    
    self.contentView.contentSize = CGSizeMake(SCREENW, self.allDownloadLabel.bottom + 50);
    
    self.scoreLabel.attributedText = [self scoreWithAppInfo];
    self.allDownloadLabel.attributedText = [self downloadWithAppInfo];
    
}
- (void)segmentViewClick:(UISegmentedControl *)seg {
    [self loadRankData:((seg.selectedSegmentIndex == 0) ? 6 : 29)];
}
- (void)loadRankData:(NSInteger)day {
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    [mDict setValue:self.appID forKey:@"app_id"];
    
    
    NSDate *date = [NSDate date];
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"YYYY-MM-dd";
    NSString *s = [form stringFromDate:date];
    NSString *e = [form stringFromDate:[NSDate dateWithDaysBeforeNow:day]];
    QMPLog(@"%@-%@", s, e);
    
    [mDict setValue:[NSString stringWithFormat:@"%@|%@",e,s] forKey:@"time_interval"];
    //appData/getAppRank
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"CompanyDetail/appRank" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            self.chartData = [NSMutableArray array];
            self.chartBData = [NSMutableArray array];
            
            NSMutableArray *price = [NSMutableArray array];
            NSArray *arr = resultData[@"list"];
            for (NSInteger i = arr.count; i > 0; i--) {
                NSDictionary *dict = arr[i-1];
                [self.chartData addObject:dict[@"rank"]];
                [self.chartBData addObject:[dict[@"up_date"] substringFromIndex:5]];
                
                [price addObject: [NSNumber numberWithInteger:[dict[@"rank"] integerValue]]];
            }
            
            NSInteger maxPrice = [[price valueForKeyPath:@"@max.floatValue"]?:@"1" integerValue];
            NSInteger minPrice = [[price valueForKeyPath:@"@min.floatValue"]?:@"0" integerValue];
            self.max = maxPrice;
            self.min = minPrice;
            
            [self.lineChart strokePath];
        }
    }];
}

#pragma mark - ZFGenericChartDataSource
- (NSArray *)valueArrayInGenericChart:(ZFGenericChart *)chart {
    if ([chart isEqual:self.lineChart]) {
        return self.chartData;
    }
    return self.barChartData;
}


- (NSArray *)nameArrayInGenericChart:(ZFGenericChart *)chart {
    if ([chart isEqual:self.lineChart]) {
        return self.chartBData;
    }
    return self.barChartBData;
}

- (NSUInteger)axisLineSectionCountInGenericChart:(ZFGenericChart *)chart{
    if ([chart isKindOfClass:[ZFLineChart class]]) {
        return MIN(MAX(self.max - self.min, 5), 6);
    }
    return MIN(self.bMax - self.bMin, 6);
}
- (CGFloat)axisLineMinValueInGenericChart:(ZFGenericChart *)chart {
    if ([chart isKindOfClass:[ZFLineChart class]]) {
        return self.min;
    }
    return self.bMin;
}

- (CGFloat)axisLineMaxValueInGenericChart:(ZFGenericChart *)chart {
    if ([chart isKindOfClass:[ZFLineChart class]]) {
        if (self.max - self.min < 5) {
            return self.min + 5;
        }
        return self.max;
    }
    
    return self.bMax;
}
- (NSArray *)colorArrayInGenericChart:(ZFGenericChart *)chart{
    return @[HTColorFromRGB(0x0D90FF)];
}
- (NSArray<ZFGradientAttribute *> *)gradientColorArrayInBarChart:(ZFBarChart *)barChart {
    ZFGradientAttribute * gradientAttribute = [[ZFGradientAttribute alloc] init];
    gradientAttribute.colors = @[(id)HTColorFromRGB(0x006EDA).CGColor, (id)HTColorFromRGB(0x006EDA).CGColor];
    gradientAttribute.locations = @[@(0.0), @(0.9)];
    
    return [NSArray arrayWithObjects:gradientAttribute, nil];
}
/**
 *  圆的半径(若不设置，默认为5.f)
 */
- (CGFloat)circleRadiusInLineChart:(ZFLineChart *)lineChart{
    return 3.f;
}

/**
 *  线宽(若不设置，默认为2.f)
 */
- (CGFloat)lineWidthInLineChart:(ZFLineChart *)lineChart{
    return 1;
}
#pragma mark - ZFLineChartDelegate


- (ZFLineChart *)lineChart {
    if (!_lineChart) {
        _lineChart = [[ZFLineChart alloc] initWithFrame:CGRectMake(-20, 20, SCREENW+20-16, 240)];
        _lineChart.yLineReverse = YES;
        _lineChart.dataSource = self;
        _lineChart.delegate = self;
        _lineChart.isResetAxisLineMaxValue = YES;
        _lineChart.isResetAxisLineMinValue = YES;
        _lineChart.xLineNameLabelToXAxisLinePadding = -1;
        _lineChart.isShowXLineSeparate = NO;
        _lineChart.isShowYLineSeparate = YES;
        _lineChart.linePatternType = kLinePatternTypeSharp;
        _lineChart.separateLineStyle = kLineStyleRealLine;
        _lineChart.separateColor = BORDER_LINE_COLOR;
        _lineChart.valueLabelPattern = kPopoverLabelPatternBlank;
        _lineChart.lineStyle = kLineStyleRealLine;
        _lineChart.unitColor = H9COLOR;
        _lineChart.unit = @"单位/位";
        _lineChart.xAxisColor = HTColorFromRGB(0xE3E3E3);
//        _lineChart.separateLineDashPattern = @[@(4),@(4)];
        _lineChart.yAxisColor = HTColorFromRGB(0xE3E3E3);
        _lineChart.axisLineValueFont = [UIFont systemFontOfSize:10];
        _lineChart.valueOnChartFont = [UIFont systemFontOfSize:12];
        _lineChart.axisLineNameFont = [UIFont systemFontOfSize:10];
        _lineChart.axisLineValueColor = H9COLOR;
        _lineChart.axisLineNameColor = H9COLOR;
        _lineChart.valueCenterToCircleCenterPadding = 10;
        _lineChart.isShadow = NO;
        _lineChart.isAnimated = YES;
        _lineChart.isShowAxisArrows = YES;
        
    }
    return _lineChart;
}
- (UILabel *)rankLabel {
    if (!_rankLabel) {
        _rankLabel = [[UILabel alloc] init];
        _rankLabel.frame = CGRectMake(16, 16, 200, 18);
        _rankLabel.text = @"AppStore 排行榜";
        if (@available(iOS 8.2, *)) {
            _rankLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        }else{
            _rankLabel.font = [UIFont systemFontOfSize:18];
        }
        _rankLabel.textColor = COLOR2D343A;
    }
    return _rankLabel;
}
- (UISegmentedControl *)segmentView {
    if (!_segmentView) {
        _segmentView = [[UISegmentedControl alloc] initWithItems:@[@"近一周", @"近一月"]];
        _segmentView.frame = CGRectMake(SCREENW-110-16, 16, 110, 22);
        _segmentView.selectedSegmentIndex = 0;
        _segmentView.tintColor = BLUE_TITLE_COLOR;
        [_segmentView addTarget:self action:@selector(segmentViewClick:) forControlEvents:UIControlEventValueChanged];
        [_segmentView setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11], NSForegroundColorAttributeName:BLUE_TITLE_COLOR} forState:UIControlStateNormal];
        [_segmentView setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11], NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
    }
    return _segmentView;
}
- (UILabel *)scoreLabel {
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc] init];
        _scoreLabel.frame = CGRectMake(16, self.lineChart.bottom + 12, 240, 12);
        _scoreLabel.font = [UIFont systemFontOfSize:12];
        _scoreLabel.text = @"AppStore 评分：";
    }
    return _scoreLabel;
}
- (UILabel *)downloadLabel {
    if (!_downloadLabel) {
        _downloadLabel = [[UILabel alloc] init];
        _downloadLabel.frame = CGRectMake(16, self.scoreLabel.bottom+40+6, 240, 18);
        _downloadLabel.text = @"Android 下载量";
        if (@available(iOS 8.2, *)) {
            _downloadLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        }else{
            _downloadLabel.font = [UIFont systemFontOfSize:18];
        }
        _downloadLabel.textColor = COLOR2D343A;
    }
    return _downloadLabel;
}
- (UISegmentedControl *)downSegmentView {
    if (!_downSegmentView) {
        _downSegmentView = [[UISegmentedControl alloc] initWithItems:@[@"近一周", @"近一月"]];
        _downSegmentView.frame = CGRectMake(SCREENW-110-16, self.scoreLabel.bottom+40+6, 110, 22);
        
        _downSegmentView.selectedSegmentIndex = 0;
        _downSegmentView.tintColor = BLUE_TITLE_COLOR;
        [_downSegmentView addTarget:self action:@selector(downSegmentViewClick:) forControlEvents:UIControlEventValueChanged];
        [_downSegmentView setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11], NSForegroundColorAttributeName:BLUE_TITLE_COLOR} forState:UIControlStateNormal];
        [_downSegmentView setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11], NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
    }
    return _downSegmentView;
}
- (void)downSegmentViewClick:(UISegmentedControl *)seg {
    [self loadDownData:((seg.selectedSegmentIndex == 0) ? 7 : 30)];
}
- (void)loadDownData:(NSInteger)day {
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    [mDict setValue:self.appID forKey:@"app_id"];
    NSDate *date = [NSDate date];
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"YYYY-MM-dd";
    NSString *s = [form stringFromDate:date];
    NSString *e = [form stringFromDate:[NSDate dateWithDaysBeforeNow:day]];
    QMPLog(@"%@-%@", s, e);
    [mDict setValue:[NSString stringWithFormat:@"%@|%@",e,s] forKey:@"time_interval"];
    //appData/getAppDownload
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"CompanyDetail/AndroidDownload" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            self.barChartData = [NSMutableArray array];
            self.barChartBData = [NSMutableArray array];
            
            NSMutableArray *price = [NSMutableArray array];
            NSArray *arr = resultData[@"list"];
            for (NSInteger i = arr.count; i > 0; i--) {
                
                NSDictionary *dict = arr[i-1];
                NSInteger d = [dict[@"downloads"] integerValue];
                [self.barChartData addObject:[NSString stringWithFormat:@"%zd", d/10000]];
                [self.barChartBData addObject:[dict[@"date_download"] substringFromIndex:5]];
                
                [price addObject: [NSNumber numberWithInteger:d/10000]];
            }
            
            
            
            NSInteger maxPrice = [[price valueForKeyPath:@"@max.floatValue"] integerValue];
            NSInteger minPrice = [[price valueForKeyPath:@"@min.floatValue"] integerValue];
            self.bMax = maxPrice;
            self.bMin = minPrice;
            if (self.bMax == self.bMin) {
                self.bMax = self.bMin + 1;
            }
            
            [self.barChart strokePath];
            self.andirodDownCount = resultData[@"total"];
            self.allDownloadLabel.attributedText = [self downloadWithAppInfo];
        }
    }];
}


- (CGFloat)barWidthInBarChart:(ZFBarChart *)barChart {
    return 15.0;
}

- (CGFloat)paddingForGroupsInBarChart:(ZFBarChart *)barChart {
    return 26.0;
}
- (ZFBarChart *)barChart {
    if (!_barChart) {
        _barChart = [[ZFBarChart alloc] initWithFrame:CGRectMake(-20, self.downloadLabel.bottom-16, SCREENW+20-16, 240)];
        _barChart.axisLineNameFont = [UIFont systemFontOfSize:10];
        _barChart.valueOnChartFont = [UIFont systemFontOfSize:10];
        _barChart.axisLineValueFont = [UIFont systemFontOfSize:10];
        _barChart.backgroundColor = [UIColor whiteColor];
        _barChart.unit = @"单位/万";
        _barChart.valueLabelPattern = kPopoverLabelPatternBlank;
        _barChart.isResetAxisLineMinValue = YES;
        _barChart.isShowXLineSeparate = NO;
        _barChart.isShowYLineSeparate = YES;
        _barChart.unitColor = H9COLOR;
        _barChart.xAxisColor = HTColorFromRGB(0xE3E3E3);
        _barChart.yAxisColor = HTColorFromRGB(0xE3E3E3);
        _barChart.axisLineNameColor = H9COLOR;
        _barChart.axisLineValueColor = H9COLOR;
        
        _barChart.isShowAxisLineValue = YES;
        _barChart.isShowAxisArrows = YES;
        _barChart.isAnimated = YES;
        _barChart.isShadow = NO;
        _barChart.dataSource = self;
        _barChart.delegate = self;
        
//        _barChart.valueCenterToCircleCenterPadding = 10;
    }
    return _barChart;
}

- (UILabel *)sourceLabel {
    if (!_sourceLabel) {
        _sourceLabel = [[UILabel alloc] init];
        _sourceLabel.frame = CGRectMake(SCREENW-200-16, 0, 200, 11);
        _sourceLabel.font = [UIFont systemFontOfSize:11];
        _sourceLabel.textColor = COLOR2D343A;
        _sourceLabel.textAlignment = NSTextAlignmentRight;
        _sourceLabel.text = @"来源：七麦数据";
        _sourceLabel.centerY = self.scoreLabel.centerY;
    }
    return _sourceLabel;
}
- (UILabel *)sourceLabel2 {
    if (!_sourceLabel2) {
        _sourceLabel2 = [[UILabel alloc] init];
        _sourceLabel2.frame = CGRectMake(SCREENW-200-16, 0, 200, 11);
        _sourceLabel2.font = [UIFont systemFontOfSize:11];
        _sourceLabel2.textColor = COLOR2D343A;
        _sourceLabel2.textAlignment = NSTextAlignmentRight;
        _sourceLabel2.text = @"来源：七麦数据";
        _sourceLabel2.centerY = self.allDownloadLabel.centerY;
    }
    return _sourceLabel2;
}
- (UILabel *)allDownloadLabel {
    if (!_allDownloadLabel) {
        _allDownloadLabel = [[UILabel alloc] init];
        _allDownloadLabel.frame = CGRectMake(16, self.barChart.bottom + 12, 240, 12);
        _allDownloadLabel.font = [UIFont systemFontOfSize:12];
        _allDownloadLabel.text = @"Android 总下载量：";
    }
    return _allDownloadLabel;
}
- (UIScrollView *)contentView {
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
        _contentView.frame = CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight);
        _contentView.alwaysBounceVertical = YES;
        _contentView.contentSize = _contentView.bounds.size;
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.showsVerticalScrollIndicator = NO;
    }
    return _contentView;
}
                                           
- (NSAttributedString *)scoreWithAppInfo {
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendString:@"AppStore 评分："];
    NSInteger len = str.length;
    if (![PublicTool isNull:self.appStoreScore]) {
        [str appendString:self.appStoreScore];
        [str appendString:@"分"];
    } else {
        [str appendString:@"-"];
    }
    NSMutableAttributedString *rank = [[NSMutableAttributedString alloc] initWithString:str
                                                                             attributes:@{
                                                                                          NSFontAttributeName:self.scoreLabel.font,
                                                                                          NSForegroundColorAttributeName: self.scoreLabel.textColor
                                                                                          }];
    [rank addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:NSMakeRange(len, str.length-len)];
    
    return rank;
}
- (NSAttributedString *)downloadWithAppInfo {
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendString:@"Android 总下载量："];
    NSInteger len = str.length;
    if (![PublicTool isNull:self.andirodDownCount]) {
        NSInteger downCount = [self.andirodDownCount integerValue];
        [str appendString:[NSString stringWithFormat:@"%zd万", downCount/10000]];
    } else {
        [str appendString:@"-"];
    }
    NSMutableAttributedString *download = [[NSMutableAttributedString alloc] initWithString:str
                                                                                 attributes:@{
                                                                                              NSFontAttributeName:self.allDownloadLabel.font,
                                                                                              NSForegroundColorAttributeName: self.allDownloadLabel.textColor
                                                                                              }];
    [download addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:NSMakeRange(len, str.length-len)];
    
    return download;
}
- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.frame = CGRectMake(0, 0, SCREENW, 10);
        _separatorView.backgroundColor = H568COLOR;
    }
    return _separatorView;
}
@end
