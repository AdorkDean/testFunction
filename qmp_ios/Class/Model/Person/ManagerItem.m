//
//  ManagerItem.m
//  qmp_ios
//
//  Created by Molly on 2016/11/28.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "ManagerItem.h"

@implementation ManagerItem
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"personId": @"id"
                                                                  }];
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
