//
//  JigouDetailChartTableViewCell.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/6/30.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFChart.h"
@class JigouDetailChartModel;

@interface JigouDetailChartTableViewCell : UITableViewCell
{
// UIView * _subView;//放cell所有控件 虚拟cell之间间隙   
    
}

@property (nonatomic,strong)ZFHorizontalBarChart * barChart;//

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andModel:(NSArray *)model;

@end
