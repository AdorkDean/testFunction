//
//  WinExperienceModel.m
//  qmp_ios
//
//  Created by QMP on 2018/4/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "WinExperienceModel.h"

@implementation WinExperienceModel
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"winExId": @"id"
                                                                  }];
}
@end
