//
//  HapMapTrendModel.h
//  qmp_ios
//
//  Created by QMP on 2017/11/14.
//  Copyright © 2017年 Molly. All rights reserved.
//图谱 趋势

#import <JSONModel/JSONModel.h>


@interface HapMapActiveJIgouModel: JSONModel

@property(nonatomic,strong) NSNumber <Optional>*count; //投资数
@property (copy, nonatomic) NSString <Optional>*name;  //机构
@property (copy, nonatomic) NSString <Optional>*link;   //机构链接



@end


@interface HapMapTrendModel : JSONModel

@property (copy, nonatomic) NSString <Optional>*month;
@property(nonatomic,strong) NSNumber <Optional>*mrongzi_count; //月融资数

@end
