//
//  JigouDetailChartModel.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/6/30.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,ChartType) {
    ChartType_Industry = 1,
    ChartType_Lunci,
    ChartType_Time
};

@interface JigouDetailChartModel : NSObject

@property (assign, nonatomic) ChartType chartType;

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *count;
@property (copy, nonatomic) NSString *time;
@property (copy, nonatomic) NSString *performance_count;
@property (copy, nonatomic) NSString *unperformance_count;
//
//
@property (nonatomic,strong)NSDictionary *xaxis;
@property (nonatomic,strong)NSDictionary *yaxis;
@property (nonatomic,strong)NSDictionary *bar;
@property (nonatomic,strong)NSDictionary *pie;
@property (nonatomic,assign)int min;
@property (nonatomic,assign)int max;

@property (nonatomic,strong)NSDictionary *line;

@end
