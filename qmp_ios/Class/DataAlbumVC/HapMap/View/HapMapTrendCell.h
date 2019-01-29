//
//  HapMapTrendCell.h
//  qmp_ios
//
//  Created by QMP on 2017/1/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFChart.h"
#import "HapMapTrendModel.h"


@interface HapMapTrendCell : UITableViewCell


@property (nonatomic,strong)ZFLineChart * lineChart;//线状图

@property (nonatomic,strong)HapMapTrendModel * trendModel;

@property (nonatomic,strong)HapMapActiveJIgouModel * activeJigouModel;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier trendArr:(NSArray*)trendArr;

-(void)buildUI:(NSArray *)trendArr;


@end
