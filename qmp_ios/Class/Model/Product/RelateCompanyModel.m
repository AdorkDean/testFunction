//
//  RelateCompanyModel.m
//  qmp_ios
//
//  Created by QMP on 2018/2/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "RelateCompanyModel.h"

@implementation RelateCompanyModel
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"companyId": @"id"
                                                                  }];
}
@end
