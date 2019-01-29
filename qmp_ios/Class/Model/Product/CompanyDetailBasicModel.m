//
//  CompanyDetailBasicModel.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/5.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "CompanyDetailBasicModel.h"

@implementation CompanyDetailBasicModel


+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"companyId": @"id"
                                                                  }];
}



@end
