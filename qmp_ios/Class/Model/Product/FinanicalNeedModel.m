//
//  FinanicalNeedModel.m
//  qmp_ios
//
//  Created by QMP on 2018/4/19.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "FinanicalNeedModel.h"

@implementation FinanicalNeedModel
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"bpId":@"id"
                                                                  }];
}
@end
