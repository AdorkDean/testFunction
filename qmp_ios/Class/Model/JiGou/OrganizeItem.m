//
//  OrganizeItem.m
//  qmp_ios
//
//  Created by Molly on 2016/11/28.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "OrganizeItem.h"

@implementation OrganizeItem
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"ID": @"id"
                                                                  }];
}

-(NSString<Optional> *)name{
    if ([PublicTool isNull:_name]) {
        return _jigou_name;
    }
    return _name;
}

-(NSString<Optional> *)jigou_name{
    if ([PublicTool isNull:_jigou_name]) {
        return _name;
    }
    return _jigou_name;
}
@end
