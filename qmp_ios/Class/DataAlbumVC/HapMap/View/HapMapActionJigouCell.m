//
//  HapMapActionJigouCell.m
//  qmp_ios
//
//  Created by QMP on 2017/11/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "HapMapActionJigouCell.h"
#import "ZFChart.h"

@interface HapMapActionJigouCell()<ZFHorizontalBarChartDelegate,ZFGenericChartDataSource>
{
    CGFloat _height;
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
@property(nonatomic,strong)ZFHorizontalBarChart *barChart;
@property(nonatomic,strong)NSArray *dataArr;

@end

@implementation HapMapActionJigouCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)buildUI:(NSArray*)dataArr{
    _dataArr = dataArr;
    _height = dataArr.count * 37 + 30 + dataArr.count*6;
    
    if (dataArr.count == 0) {
        
        return;
    }
        
        
    _xUnit = @"月";//x轴单位
    _yUnit = @"个";//y轴单位
    _yMax = 0;
    HapMapActiveJIgouModel *model = dataArr[0];
    _yMin = model.count.integerValue;
    _yNumChart = 0;
    for (HapMapActiveJIgouModel *jigouM in dataArr) {
        if (_yMax < jigouM.count.integerValue) {
            _yMax = jigouM.count.integerValue;
        }
        if (_yMin > jigouM.count.integerValue) {
            _yMin = jigouM.count.integerValue;
        }
        if (_yNumChart < jigouM.count.integerValue) {
            _yNumChart = jigouM.count.integerValue;
        }
    }
//        _yMax = [self currentMax];

    _topic = @"活跃机构";
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *yarr = [NSMutableArray array];
    
    for (HapMapActiveJIgouModel *jigouM in dataArr) {
        [arr addObject:jigouM.name];
        [yarr addObject:[NSString stringWithFormat:@"%@",jigouM.count]];
    }
    
    
    _xTitleArr = arr;
    _yTitleArr = yarr;
    
    self.barChart = [[ZFHorizontalBarChart alloc] initWithFrame:CGRectMake(23, -50, SCREENW - 30, _height)];
    self.barChart.axisLineNameFont = [UIFont systemFontOfSize:13];
    self.barChart.valueOnChartFont = [UIFont systemFontOfSize:14];
    self.barChart.axisLineValueFont = [UIFont systemFontOfSize:1];
    self.barChart.backgroundColor = [UIColor clearColor];

//    self.barChart.topicLabel.text = _topic;
//    self.barChart.unit = @"投资笔数：个";
//    self.barChart.topicLabel.textColor = ZFPurple;
    self.barChart.valueLabelPattern = kPopoverLabelPatternBlank;
    self.barChart.isResetAxisLineMinValue = YES;
    self.barChart.isShowXLineSeparate = NO;
    self.barChart.isShowYLineSeparate = NO;
    self.barChart.unitColor = ZFWhite;
    self.barChart.xAxisColor = ZFWhite;
    self.barChart.yAxisColor = ZFWhite;
    self.barChart.axisLineNameColor = NV_TITLE_COLOR;
    self.barChart.axisLineValueColor = NV_TITLE_COLOR;

    self.barChart.isShowAxisLineValue = YES;
    self.barChart.isShowAxisArrows = NO;
    self.barChart.isAnimated = NO;
    self.barChart.isShadow = NO;
    self.barChart.dataSource = self;
    self.barChart.delegate = self;
 
//    self.barChart.
    
  
    
    [self.contentView addSubview:self.barChart];
    [self.barChart strokePath];
}

#pragma mark - ZFGenericChartDataSource

- (NSArray *)valueArrayInGenericChart:(ZFGenericChart *)chart{
    return _yTitleArr;
}

- (NSArray *)nameArrayInGenericChart:(ZFGenericChart *)chart{
    return _xTitleArr;
}

//- (NSArray *)colorArrayInGenericChart:(ZFGenericChart *)chart{
//    return @[ZFMagenta];
//}

- (CGFloat)axisLineMaxValueInGenericChart:(ZFGenericChart *)chart{
    return _yMax;
}

- (CGFloat)axisLineMinValueInGenericChart:(ZFGenericChart *)chart{
    return _yMin > 10 ?  10: 0;
}

- (NSUInteger)axisLineSectionCountInGenericChart:(ZFGenericChart *)chart{
    return 4;
}

- (NSInteger)axisLineStartToDisplayValueAtIndex:(ZFGenericChart *)chart{
    return 0;
}

- (void)genericChartDidScroll:(UIScrollView *)scrollView{
    NSLog(@"当前偏移量 ------ %f", scrollView.contentOffset.y);
}

#pragma mark - ZFHorizontalBarChartDelegate

- (CGFloat)barHeightInHorizontalBarChart:(ZFHorizontalBarChart *)barChart{
    return 22;
}

- (CGFloat)paddingForGroupsInHorizontalBarChart:(ZFHorizontalBarChart *)barChart{
    return 15.f;
}

//- (CGFloat)paddingForBarInHorizontalBarChart:(ZFHorizontalBarChart *)barChart{
//    return 5.f;
//}

- (id)valueTextColorArrayInHorizontalBarChart:(ZFHorizontalBarChart *)barChart{
    return NV_TITLE_COLOR;
}

- (NSArray<ZFGradientAttribute *> *)gradientColorArrayInHorizontalBarChart:(ZFHorizontalBarChart *)barChart{
    ZFGradientAttribute * gradientAttribute = [[ZFGradientAttribute alloc] init];
    gradientAttribute.colors = @[(id)HTColorFromRGB(0x81B8F7).CGColor, (id)HTColorFromRGB(0x81B8F7).CGColor];
    gradientAttribute.locations = @[@(0.0), @(0.9)];
    
    return [NSArray arrayWithObjects:gradientAttribute, nil];
}

- (void)horizontalBarChart:(ZFHorizontalBarChart *)barChart didSelectBarAtGroupIndex:(NSInteger)groupIndex barIndex:(NSInteger)barIndex horizontalBar:(ZFHorizontalBar *)horizontalBar popoverLabel:(ZFPopoverLabel *)popoverLabel{
    //特殊说明，因传入数据是3个subArray(代表3个类型)，每个subArray存的是6个元素(代表每个类型存了1~6年级的数据),所以这里的groupIndex是第几个subArray(类型)
    //eg：三年级第0个元素为 groupIndex为0，barIndex为2
    NSLog(@"第%ld个颜色中的第%ld个",(long)groupIndex,(long)barIndex);
    self.clickJigou([_dataArr[barIndex] link]);
    //可在此处进行bar被点击后的自身部分属性设置
    //    horizontalBar.barColor = ZFYellow;
    //    horizontalBar.isAnimated = YES;
    //    horizontalBar.opacity = 0.5;
    //    [horizontalBar strokePath];
    
    //可将isShowAxisLineValue设置为NO，然后执行下句代码进行点击才显示数值
    //    popoverLabel.hidden = NO;
}

- (void)horizontalBarChart:(ZFHorizontalBarChart *)barChart didSelectPopoverLabelAtGroupIndex:(NSInteger)groupIndex labelIndex:(NSInteger)labelIndex popoverLabel:(ZFPopoverLabel *)popoverLabel{
    //理由同上
    NSLog(@"第%ld组========第%ld个",(long)groupIndex,(long)labelIndex);
    
    //可在此处进行popoverLabel被点击后的自身部分属性设置
    //    popoverLabel.textColor = ZFSkyBlue;
    //    [popoverLabel strokePath];
}

#pragma mark - 横竖屏适配(若需要同时横屏,竖屏适配，则添加以下代码，反之不需添加)

/**
 *  PS：size为控制器self.view的size，若图表不是直接添加self.view上，则修改以下的frame值
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator NS_AVAILABLE_IOS(8_0){
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
        self.barChart.frame = CGRectMake(0, 0, size.width, size.height - NAVIGATIONBAR_HEIGHT * 0.5);
    }else{
        self.barChart.frame = CGRectMake(0, 0, size.width, size.height + NAVIGATIONBAR_HEIGHT * 0.5);
    }
    
    [self.barChart strokePath];
}

@end
