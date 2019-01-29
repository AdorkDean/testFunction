//
//  PersonModel.m
//  qmp_ios
//
//  Created by QMP on 2017/11/6.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "PersonModel.h"
#import "PublicTool.h"

@implementation PersonModel
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"personId": @"id",
                                                                  }];
}
-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"role"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @[value];
        }
    }
    [super setValue:value forKey:key];
}

-(NSString<Optional> *)personId{
    if ([PublicTool isNull:_personId]) {
        return _person_id ? _person_id:@"";
    }
    return _personId;
}


-(NSString<Optional> *)person_id{
    if ([PublicTool isNull:_person_id]) {
        return _personId ? _personId:@"";
    }
    return _person_id;
}
@end
