//
//  HapMapArea.h
//  qmp_ios
//
//  Created by QMP on 2017/11/13.
//  Copyright © 2017年 Molly. All rights reserved.
////图谱  细分领域

#import <JSONModel/JSONModel.h>


@protocol HapMapAreaModel;

@interface HapMapAreaModel : JSONModel

@property (copy, nonatomic) NSString <Optional> *count;
@property (copy, nonatomic) NSString <Optional> *name;
@property (strong, nonatomic) NSArray <HapMapAreaModel,Optional> *list;


@end
