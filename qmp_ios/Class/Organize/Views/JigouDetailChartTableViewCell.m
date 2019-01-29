//
//  JigouDetailChartTableViewCell.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/6/30.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "JigouDetailChartTableViewCell.h"
#import "JigouDetailChartModel.h"
#import "ZFChart.h"

@interface JigouDetailChartTableViewCell ()<ZFGenericChartDataSource, ZFHorizontalBarChartDelegate,ZFLineChartDelegate>
{
    NSString* _topic;//图表标题
    NSString* _subTitle;//子视图
    NSString* _xUnit;//x轴单位
    CGFloat _xMax;//x最大值
    CGFloat _xMin;//x最小值
    NSArray *_xTitleArr;//x值
    NSInteger _xNumChart;//y轴(普通图表) 或 x轴(横向图表) 数值显示的段数(若不设置,默认5段)
    NSArray *_yTitleArr;//y轴每条名字
    
    NSString* _yUnit;//y轴单位
}
@property (nonatomic, strong) ZFLineChart * lineChart;
@property (nonatomic, assign) CGFloat height;
@end

@implementation JigouDetailChartTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andModel:(NSArray *)model
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI:model];
    }
    
    return self;
}

-(void)buildUI:(NSArray *)chartArr{
    
    NSArray *trueArr = [NSArray arrayWithArray:chartArr];
    if (trueArr.count==0) {
        return;
    }
    JigouDetailChartModel *firstModel = trueArr[0];
    JigouDetailChartModel *model;
    if ((firstModel.chartType == ChartType_Industry || firstModel.chartType == ChartType_Lunci) && (chartArr.count>1)) { //不显示全部, 当count>1
        NSMutableArray *delAllArr = [NSMutableArray arrayWithArray:chartArr];
        [delAllArr removeObjectAtIndex:0];
        chartArr = delAllArr;
        model = chartArr.firstObject;
    }else{
        model = firstModel;
    }
        
    self.contentView.backgroundColor = RGB(255, 255, 255, 1);//RGB(244, 244, 244, 1);//cell背景
    //是水平柱状图还是折线图，
    BOOL isHorizentalBar = chartArr.count && ![PublicTool isNull:[chartArr[0] name]];
    //最大值
    NSInteger maxCount = 0;
    for (JigouDetailChartModel *chartM in chartArr) {
        maxCount = maxCount>chartM.count.integerValue?maxCount:chartM.count.integerValue;
    }
    _xNumChart = chartArr.count;

    if (isHorizentalBar) {
        _xUnit = @"笔";//x轴单位
        _yUnit = @"笔";
        _xMax = maxCount;
        
        if (model.chartType == ChartType_Industry) {
            _topic = @"领域分布";
        }else if (model.chartType == ChartType_Lunci) {
            _topic = @"轮次分布";
        }else if (model.chartType == ChartType_Time) {
            _topic = @"投资统计";
        }
        NSMutableArray *xTitleArr = [NSMutableArray array];
        NSMutableArray *yTitleArr = [NSMutableArray array];
        NSMutableArray *sortArr = [NSMutableArray arrayWithArray:chartArr];
        [sortArr sortUsingComparator:^NSComparisonResult(JigouDetailChartModel * _Nonnull obj1, JigouDetailChartModel*  _Nonnull obj2) {
            return obj1.count.integerValue >= obj2.count.integerValue;
        }];
        for (int i=0; i<sortArr.count; i++) {
            JigouDetailChartModel *chartM = sortArr[i];
            
            [xTitleArr addObject:chartM.count];
            [yTitleArr addObject:chartM.name];
        }
        
        _xTitleArr = xTitleArr;
        _yTitleArr = yTitleArr;
        /////////////////////////
        _barChart = [[ZFHorizontalBarChart alloc] initWithFrame:CGRectMake(10, 10, SCREENW-20, chartArr.count*(10+14)+ 30+chartArr.count*2)];//tmpArr.count*(20+25)+ 80) //80是x轴label高度  //88
        [self.contentView addSubview:_barChart];
        _barChart.dataSource = self;
        _barChart.delegate = self;
        _barChart.topicLabel.textColor = ZFBlack;
        _barChart.backgroundColor = RGB(255, 255, 255, 1);
        _barChart.layer.cornerRadius = 3;
        _barChart.layer.masksToBounds = YES;
        _barChart.yAxisColor = [UIColor clearColor];
        _barChart.xAxisColor = [UIColor clearColor];
        _barChart.axisLineValueFont = [UIFont systemFontOfSize:1];
        _barChart.valueLabelPattern = kPopoverLabelPatternBlank;
        _barChart.isShadow = NO;
        _barChart.isAnimated = NO;

        
        if (_topic&&![_topic isEqualToString:@""]) {
            NSInteger trailLength = 6;
            NSString *str = [NSString stringWithFormat:@"%@  单位(笔)",_topic];//图表标题
            if (model.chartType == ChartType_Industry || model.chartType == ChartType_Lunci) {
                str = [NSString stringWithFormat:@"%@  (%@笔)",_topic,firstModel.count];//图表标题
                trailLength = firstModel.count.length+3;
            }
            NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:str];
            [attText addAttributes:@{NSForegroundColorAttributeName:H9COLOR,NSFontAttributeName:[UIFont systemFontOfSize:11]} range:NSMakeRange(str.length-trailLength, trailLength)];
            _barChart.topicLabel.attributedText = attText;
            
        }
        //每当更新数据后或更改属性设置，则需重新调用一次.网络获取数据后，才调用
        [_barChart strokePath];//重绘
            
    }else{ //折线图
        _topic = @"投资数量";
        NSMutableArray *xTitleArr = [NSMutableArray array];
        NSMutableArray *yTitleArr = [NSMutableArray array];
        
        for (int i=0; i<chartArr.count; i++) {
            JigouDetailChartModel *chartM = chartArr[i];
            [xTitleArr addObject:chartM.time];
            [yTitleArr addObject:chartM.count];
        }
        
        _xTitleArr = xTitleArr;
        _yTitleArr = yTitleArr;
        
        ///////////////////
        self.lineChart = [[ZFLineChart alloc] initWithFrame:CGRectMake(0, 10, SCREENW-10, (chartArr.count*(10+14))/0.85f +20 +60)];//tmpArr.count*(20+25)+ 80) //80是x轴label高度  //88
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
        
        if (_topic&&![_topic isEqualToString:@""]) {
            if (chartArr.count>=2) {
                NSString *str = [NSString stringWithFormat:@"%@-%@投资数量",_xTitleArr[0],_xTitleArr.lastObject];//图表标题
                 self.lineChart.topicLabel.text = str;
                
            }
        }
        //每当更新数据后或更改属性设置，则需重新调用一次.网络获取数据后，才调用
        [_lineChart strokePath];//重绘
    }
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
    if (_xTitleArr) {
        if ([_topic rangeOfString:@"投资数量"].location !=NSNotFound) {
            return _yTitleArr;
        }else{
            return _xTitleArr;//元素是字符串
        }
    }else{
        return @[@"0",@"0",@"0",@"0",@"0",@"0"];//x值
    }
}

- (NSArray *)nameArrayInGenericChart:(ZFGenericChart *)chart{
    if (_yTitleArr) {
        if ([_topic rangeOfString:@"投资数量"].location !=NSNotFound) {
            return _xTitleArr;
        }else{
            return _yTitleArr;//元素是字符串
        }
    }else{
        return @[@"一", @"二", @"三", @"四", @"五", @"六"];//y轴每条名字
    }
}

//条形图颜色
- (NSArray *)colorArrayInGenericChart:(ZFGenericChart *)chart{
    return  @[HTColorFromRGB(0x81B8F7)];//@[ZFYellow];;//@[RGB(46, 119, 167, 1)];  // ZFMagenta
}

- (CGFloat)axisLineMaxValueInGenericChart:(ZFGenericChart *)chart{
    return _xMax;//x轴最大
}
//y轴(普通图表) 或 x轴(横向图表) 数值显示的最小值(若不设置，默认返回数据源最小值)
- (CGFloat)axisLineMinValueInGenericChart:(ZFGenericChart *)chart{
    return 0;
}

//y轴(普通图表) 或 x轴(横向图表) 数值显示的段数(若不设置,默认5段)
- (NSUInteger)axisLineSectionCountInGenericChart:(ZFGenericChart *)chart{
    if ([_topic rangeOfString:@"投资数量"].location !=NSNotFound) {
        return _xNumChart>0?_xNumChart:0;
    }
    return _xNumChart;////
}

#pragma mark - ZFHorizontalBarChartDelegate

- (CGFloat)barHeightInHorizontalBarChart:(ZFHorizontalBarChart *)barChart{
    return 14.f;//25
}

- (CGFloat)paddingForGroupsInHorizontalBarChart:(ZFHorizontalBarChart *)barChart{
    return 10.f;//20
}
//
//- (CGFloat)paddingForBarInHorizontalBarChart:(ZFHorizontalBarChart *)barChart{
//    return 5.f;
//}

//方框内字体颜色
- (id)valueTextColorArrayInHorizontalBarChart:(ZFHorizontalBarChart *)barChart{
    return  @[RGB(46, 119, 167, 1)]; //ZFBlue;
}
- (void)horizontalBarChart:(ZFHorizontalBarChart *)barChart didSelectBarAtGroupIndex:(NSInteger)groupIndex barIndex:(NSInteger)barIndex horizontalBar:(ZFHorizontalBar *)horizontalBar popoverLabel:(ZFPopoverLabel *)popoverLabel{
    
    //可将isShowAxisLineValue设置为NO，然后执行下句代码进行点击才显示数值
    //    popoverLabel.hidden = NO;
    
    //特殊说明，因传入数据是3个subArray(代表3个类型)，每个subArray存的是6个元素(代表每个类型存了1~6年级的数据),所以这里的groupIndex是第几个subArray(类型)
    //eg：三年级第0个元素为 groupIndex为0，barIndex为2
    QMPLog(@"第%ld个颜色中的第%ld个",(long)groupIndex,(long)barIndex);
    //umeng统计 "机构轮次分布图”点击次数
    if([_topic rangeOfString:@"轮次分布"].location !=NSNotFound)
    {
    }
    //“机构行业分布图”点击次数“
    if([_topic rangeOfString:@"行业分布"].location !=NSNotFound)
    {
    }
}

- (void)horizontalBarChart:(ZFHorizontalBarChart *)barChart didSelectPopoverLabelAtGroupIndex:(NSInteger)groupIndex labelIndex:(NSInteger)labelIndex popoverLabel:(ZFPopoverLabel *)popoverLabel{
    //理由同上
    QMPLog(@"第%ld组========第%ld个",(long)groupIndex,(long)labelIndex);
    //umeng统计 “机构轮次分布图”点击次数
    if([_topic rangeOfString:@"轮次分布"].location !=NSNotFound)
    {
    }
    //“机构行业分布图”点击次数
    if([_topic rangeOfString:@"行业分布"].location !=NSNotFound)
    {
    }
}
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
    return 1.0f;
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



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
