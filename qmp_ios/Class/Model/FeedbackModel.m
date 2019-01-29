//
//  FeedbackModel.m
//  qmp_ios
//
//  Created by QMP on 2018/1/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "FeedbackModel.h"

@implementation FeedbackModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"feedbackId": @"id"
                                                                  }];
}

@end
