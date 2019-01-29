//
//  SearchJigouModel.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/3.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "SearchJigouModel.h"

@implementation SearchJigouModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"jigou_id": @"id"
                                                                  }];
}

//防奔溃
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
//    键值的替换
    if ([key isEqualToString:@"id"]) {
        self.jigou_id = value;
    }
    
}

-(NSString<Optional> *)jianjie{
    if ([PublicTool isNull:_jianjie]) {
        return _desc?_desc:@"";
    }
    return _jianjie;
}
-(NSString<Optional> *)jigou_name{
    if ([PublicTool isNull:_jigou_name]) {
        return _jgname?_jgname:@"";
    }
    return _jigou_name;
}


@end
