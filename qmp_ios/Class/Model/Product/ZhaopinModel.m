//
//  ZhaopinModel.m
//  qmp_ios
//
//  Created by QMP on 2018/2/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ZhaopinModel.h"

@implementation ZhaopinModel
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"descriptionStr": @"description",
                                                                  @"zhaopinId":@"id"
                                                                  }];
}
@end
