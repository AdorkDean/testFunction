//
//  SearchProRegisterModel.m
//  qmp_ios
//
//  Created by QMP on 2017/11/14.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "SearchProRegisterModel.h"

@implementation SearchProRegisterModel
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"faren": @"company_faren",
                                                                  @"open_time":@"qy_time",
                                                                  @"regCapital":@"province"
                                                                  }];
}

@end
