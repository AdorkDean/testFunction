//
//  HapMapTrendCell.m
//  qmp_ios
//
//  Created by QMP on 2017/1/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "HapMapTrendCell.h"


@interface HapMapTrendCell()<ZFGenericChartDataSource,ZFLineChartDelegate,ZFLineChartDelegate>
{
    NSString* _topic;//图表标题
    NSString* _subTitle;//子视图
    NSString* _xUnit;//x轴单位
    NSInteger _yMax;//x最大值
    NSInteger _yMin;//x最小值
    NSArray *_xTitleArr;//x值
    NSInteger _yNumChart;//y轴(普通图表) 或 x轴(横向图表) 数值显示的段数(若不设置,默认5段)
    NSArray *_yTitleArr;//y轴每条名字
    
    NSString* _yUnit;//y轴单位
}
@property (nonatomic, assign) CGFloat height;




@end


@implementation HapMapTrendCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier trendArr:(NSArray*)trendArr{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI:trendArr];
    }
    return self;
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}

-(void)buildUI:(NSArray *)trendArr
{
    _height = 300;
    
    if (trendArr.count) {
        
       
        _xUnit = @"月";//x轴单位
        _yUnit = @"家";//y轴单位
        _yMax = 0;
        _yMin = 0;
        _yNumChart = 0;
        for (HapMapTrendModel *trend in trendArr) {
            if (_yMax < trend.mrongzi_count.integerValue) {
                _yMax = trend.mrongzi_count.integerValue;
            }
            if (_yMin > trend.mrongzi_count.integerValue) {
                _yMin = trend.mrongzi_count.integerValue;
            }
            if (_yNumChart < trend.mrongzi_count.integerValue) {
                _yNumChart = trend.mrongzi_count.integerValue;
            }
        }
        _yMax = [self currentMax];
    
        _topic = @"投资趋势";
        NSMutableArray *arr = [NSMutableArray array];
        NSMutableArray *yarr = [NSMutableArray array];

        for (HapMapTrendModel *trend in trendArr) {
            [arr addObject:trend.month];
            [yarr addObject:[NSString stringWithFormat:@"%@",trend.mrongzi_count]];
        }
        
            
        _xTitleArr = arr;
        _yTitleArr = yarr;
       
        self.lineChart = [[ZFLineChart alloc] initWithFrame:CGRectMake(-10, -10, SCREEN_WIDTH, _height)];
        self.lineChart.dataSource = self;
        self.lineChart.delegate = self;
        self.lineChart.isShowAxisArrows = NO;
        self.lineChart.isResetAxisLineMinValue = YES;
        self.lineChart.xLineNameLabelToXAxisLinePadding = -1;
        self.lineChart.isShowXLineSeparate = NO;
        self.lineChart.isShowYLineSeparate = YES;
        self.lineChart.linePatternType = kLinePatternTypeSharp;
        self.lineChart.separateLineStyle = kLineStyleDashLine;
        self.lineChart.separateColor = BORDER_LINE_COLOR;
        self.lineChart.valueLabelPattern = kPopoverLabelPatternBlank;
        self.lineChart.lineStyle = kLineStyleRealLine;
        self.lineChart.unitColor = ZFWhite;
        self.lineChart.xAxisColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"chart_dash_line"]];
        self.lineChart.separateLineDashPattern = @[@(4),@(4)];
        self.lineChart.yAxisColor = ZFWhite;
        self.lineChart.axisLineValueFont = [UIFont systemFontOfSize:13];
        self.lineChart.valueOnChartFont = [UIFont systemFontOfSize:14];
        self.lineChart.axisLineNameFont = [UIFont systemFontOfSize:13];
        self.lineChart.axisLineValueColor = H9COLOR;
        self.lineChart.axisLineNameColor = H9COLOR;
        self.lineChart.isShadow = NO;
        self.lineChart.isAnimated = NO;
                
        [self.contentView addSubview:self.lineChart];
        [self.lineChart strokePath];
    }
}

- (NSInteger)currentMax{
//    NSMutableString *str = [NSMutableString stringWithFormat:@"%ld",_yMax];
//    if (str.length >= 2) { //
//        NSString *ge = [str substringFromIndex:str.length-1];
//        NSString *shi = [str substringWithRange:NSMakeRange(str.length-2, 1)];
//        if (ge.integerValue > 5) { //进1
//            if (shi.int ) {
//                
//            }
//        }
//    }
    return  _yMax;
}
- (NSInteger)nsinterLength:(NSInteger)x {
    NSInteger sum=0,j=1;
    while( x >= 1 ) {
        NSLog(@"%zd位数是 : %zd\n",j,x%10);
        x=x/10;
        sum++;
        j=j*10;
    }
    NSLog(@"你输入的是一个%zd位数\n",sum);
    return sum;
}


- (NSInteger)countSection:(NSArray *)array{
    if (array.count<2) {
        return array.count;
    }else{
        NSMutableArray *mArr = [NSMutableArray array];
        [mArr addObject:[NSString stringWithFormat:@"%ld",(long)[array[0] integerValue]]];
        for (int i=1; i<array.count; i++) {
            for (int j=0; j<mArr.count; j++) {
                if ([mArr[j] isEqualToString:[NSString stringWithFormat:@"%ld",(long)[array[i] integerValue]]]) {
                    break;
                }
                if (j==mArr.count-1&&![mArr[mArr.count-1] isEqualToString:[NSString stringWithFormat:@"%ld",(long)[array[i] integerValue]]]) {
                    [mArr addObject:[NSString stringWithFormat:@"%ld",(long)[array[i] integerValue]]];
                    break;
                }
            }
        }
        return mArr.count>6?6:mArr.count;
    }
}


#pragma mark - ZFGenericChartDataSource
- (NSArray *)valueArrayInGenericChart:(ZFGenericChart *)chart{
    if (_yTitleArr) {
        
        return _yTitleArr;//元素是字符串
        
    }else{
        return @[@"1", @"2", @"3", @"4", @"5", @"6"];//y轴每条名字
    }
   
}

- (NSArray *)nameArrayInGenericChart:(ZFGenericChart *)chart{
    if (_xTitleArr) {
        return _xTitleArr;
    }else{
        return @[@"一",@"二",@"三",@"四",@"五",@"六"];//x值
    }
}

- (NSArray *)colorArrayInGenericChart:(ZFGenericChart *)chart{
    return @[HTColorFromRGB(0xFC7171)];
}

- (NSArray<ZFGradientAttribute *> *)gradientColorArrayInLineChart:(ZFLineChart *)lineChart{
    ZFGradientAttribute * gradientAttribute = [[ZFGradientAttribute alloc] init];
    gradientAttribute.colors = @[(id)HTColorFromRGB(0xFC7171).CGColor, (id)HTColorFromRGB(0xFC7171).CGColor];
    gradientAttribute.locations = @[@(0.0), @(0.9)];
    
    return [NSArray arrayWithObjects:gradientAttribute, nil];
}



- (CGFloat)axisLineMaxValueInGenericChart:(ZFGenericChart *)chart{
    return _yMax;//x轴最大
}

- (CGFloat)axisLineMinValueInGenericChart:(ZFGenericChart *)chart{
    return 0;
}

- (NSUInteger)axisLineSectionCountInGenericChart:(ZFGenericChart *)chart{
   
    return 5;
    
    return _yNumChart;////
}

- (NSInteger)axisLineStartToDisplayValueAtIndex:(ZFGenericChart *)chart{
    return 0;
}

//- (void)genericChartDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"当前偏移量 ------ %f", scrollView.contentOffset.x);
//}

//y轴(普通图表) 或 x轴(横向图表) 数值显示的最小值(若不设置，默认返回数据源最小值)
//- (CGFloat)axisLineMinValueInGenericChart:(ZFGenericChart *)chart{
////    return 50;
//}

- (NSArray *)valuePositionInLineChart:(ZFLineChart *)lineChart{
    
    return @[@(kChartValuePositionOnTop)];//, @(kChartValuePositionDefalut), @(kChartValuePositionOnBelow)
}


/**
 *  圆的半径(若不设置，默认为5.f)
 */
- (CGFloat)circleRadiusInLineChart:(ZFLineChart *)lineChart{
    return 2.f;
}

/**
 *  线宽(若不设置，默认为2.f)
 */
- (CGFloat)lineWidthInLineChart:(ZFLineChart *)lineChart{
    return 0.5f;
}

- (void)lineChart:(ZFLineChart *)lineChart didSelectCircleAtLineIndex:(NSInteger)lineIndex circleIndex:(NSInteger)circleIndex circle:(ZFCircle *)circle popoverLabel:(ZFPopoverLabel *)popoverLabel{
    QMPLog(@"第%ld条线========第%ld个",(long)lineIndex,(long)circleIndex);
    
    //可在此处进行circle被点击后的自身部分属性设置,可修改的属性查看ZFCircle.h
    //    circle.circleColor = ZFYellow;
    circle.isAnimated = YES;
    //    circle.opacity = 0.5;
    
    [circle strokePath];
    
    //    可将isShowAxisLineValue设置为NO，然后执行下句代码进行点击才显示数值
    //    popoverLabel.hidden = NO;
}

- (void)lineChart:(ZFLineChart *)lineChart didSelectPopoverLabelAtLineIndex:(NSInteger)lineIndex circleIndex:(NSInteger)circleIndex popoverLabel:(ZFPopoverLabel *)popoverLabel{
    QMPLog(@"第%ld条线========第%ld个",(long)lineIndex,(long)circleIndex);
    
    //可在此处进行popoverLabel被点击后的自身部分属性设置
    //    popoverLabel.textColor = ZFGold;
    //    [popoverLabel strokePath];
}

/**
 *  组宽(若不设置，默认为25.f)
 */
- (CGFloat)groupWidthInLineChart:(ZFLineChart *)lineChart{
    
    return 32*ratioWidth;
}

/**
 *  组与组之间的间距(若不设置，默认为20.f)
 */
- (CGFloat)paddingForGroupsInLineChart:(ZFLineChart *)lineChart{
    return 20;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
