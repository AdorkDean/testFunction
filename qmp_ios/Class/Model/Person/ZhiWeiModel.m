//
//  ZhiWeiModel.m
//  qmp_ios
//
//  Created by QMP on 2017/11/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "ZhiWeiModel.h"

@implementation ZhiWeiModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"zhiweiId": @"id"
                        
                                                                  }];
}

@end
