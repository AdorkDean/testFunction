//
//  CompanysDetailRegisterGudongModel.m
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/12.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CompanysDetailRegisterGudongModel.h"

@implementation CompanysDetailRegisterGudongModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"personId":@"id"
                                                                  }];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //键值的替换
    //    if ([key isEqualToString:@"register"]) {
    //        self.registerDic = value;
    //    }
    
}

@end
