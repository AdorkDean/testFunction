//
//  BingGouProModel.m
//  qmp_ios
//
//  Created by QMP on 2018/3/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BingGouProModel.h"


@implementation BingGouLunci
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"lunciId": @"id"
                                                                  }];
}

@end

@implementation BingGouProModel

@end
