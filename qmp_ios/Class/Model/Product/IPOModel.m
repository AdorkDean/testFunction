//
//  IPOModel.m
//  qmp_ios
//
//  Created by QMP on 2018/3/13.
//  Copyright © 2018年 Molly. All rights reserved.
//IPO 信息

#import "IPOModel.h"

@implementation IPOModel
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"ipoId": @"id"
                                                                  }];
}
@end
