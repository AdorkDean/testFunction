//
//  WorkExprienceModel.m
//  qmp_ios
//
//  Created by QMP on 2017/11/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "WorkExprienceModel.h"

@implementation WorkExprienceModel
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"workExpId": @"id"
                                                                  }];
}
@end
