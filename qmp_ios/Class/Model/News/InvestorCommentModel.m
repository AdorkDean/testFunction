//
//  InvestorCommentModel.m
//  qmp_ios
//
//  Created by QMP on 2018/3/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "InvestorCommentModel.h"

@implementation InvestorCommentModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"commentId": @"id"
                                                                  }];
}

@end
