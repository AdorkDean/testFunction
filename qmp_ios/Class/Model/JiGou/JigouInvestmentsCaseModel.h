//
//  JigouInvestmentsCaseModel.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/11/26.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JigouInvestmentsCaseModel : JSONModel

// FA案例
@property (nonatomic,copy)NSString <Optional>*product;   //项目
@property (nonatomic,copy)NSString <Optional>*icon;   //项目图标
@property (nonatomic,copy)NSString <Optional>*hangye1;   //行业领域
@property (nonatomic,copy)NSString <Optional>*yewu;   //业务
@property (nonatomic,copy)NSString <Optional>*province;   //地区
@property (nonatomic,copy)NSString <Optional>*jieduan;   //服务阶段
@property (nonatomic,copy)NSString <Optional>*time;   //完成时间
@property (nonatomic,copy)NSString <Optional>*money;   //金额
@property (nonatomic,copy)NSString <Optional>*detail;   //详情页链接
@property (nonatomic,copy)NSString <Optional>*curtime;   //当前轮次时间

//需要
@property (nonatomic,strong)NSArray <Optional>*luncis;  //以往投资轮次[@"lunci"],[@"money"],[@"time"]
@property (nonatomic,strong)NSArray <Optional>*invest_turns; //所有投资轮次数组
@property (nonatomic,strong)NSArray <Optional>*finance_history; //所有轮次数组

//Other
@property (nonatomic,copy)NSString <Optional>*lunci_time;   //完成时间

@property (nonatomic,copy)NSArray <Optional>*lunciStringArr; //机构详情用的
/**当今轮次*/
@property (copy, nonatomic)NSString <Optional>*nowLunci;
/**曾投轮次*/
@property (copy, nonatomic)NSString <Optional>*pastLunci;

//投资案例
@property (nonatomic,copy)NSString <Optional>*company;
@property (nonatomic,copy)NSString <Optional>*lunci; //当前轮次
@property (nonatomic,copy)NSString <Optional>*invest_latest_time; //投资时间


@property(nonatomic,assign) BOOL isFeedback;

@property(nonatomic,assign) BOOL isPreciseFeedback;
@property(nonatomic,assign) BOOL isOverallFeedback;

@property (copy, nonatomic)NSNumber <Optional>*is_top;


@end
