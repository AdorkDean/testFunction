//
//  WorkExperienceModel.m
//  qmp_ios
//
//  Created by QMP on 2018/1/31.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ExperienceModel.h"

@implementation ExperienceModel
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"experienceId":@"id"
                                                                  }];
}


@end
