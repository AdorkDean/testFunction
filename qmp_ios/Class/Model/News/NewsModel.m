//
//  NewsModel.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/5.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "NewsModel.h"

@implementation NewsModel

//防奔溃
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //键值的替换
        if ([key isEqualToString:@"id"]) {
            self.news_id = value;
        }
    
}

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"news_id": @"id"
                                                                  }];
}
@end
