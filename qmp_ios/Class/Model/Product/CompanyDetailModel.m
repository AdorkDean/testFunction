//
//  CompanyDetailModel.m
//  qmp_ios
//
//  Created by QMP on 2017/9/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "CompanyDetailModel.h"

@implementation CompanyDetailModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"companyRegister": @"register",
                                                                  @"rz_flag":@"rg_flag"}];
}


@end
