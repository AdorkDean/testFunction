//
//  EducationExpModel.m
//  qmp_ios
//
//  Created by QMP on 2017/11/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "EducationExpModel.h"

@implementation EducationExpModel
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"educationId": @"id",
                                                                  @"major": @"zhuanye"
                                                                  }];
}
@end
