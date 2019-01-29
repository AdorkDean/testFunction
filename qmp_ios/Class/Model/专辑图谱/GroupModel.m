//
//  GroupModel.m
//  qmp_ios
//
//  Created by Molly on 16/8/18.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "GroupModel.h"

@implementation GroupModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"album_id": @"id"
                                                                 
                                                                  }];
}

-(NSString<Optional> *)groupId{
    if ([PublicTool isNull:_groupId]) {
        return _album_id;
    }
    return _groupId;
}

-(NSString<Optional> *)userfolderid{
    
    if ([PublicTool isNull:_userfolderid]) {
        return _album_name;
    }
    return _userfolderid;
}

-(NSString<Optional> *)name{
    if ([PublicTool isNull:_name]) {
        return _album_name;
    }
    return _name;
}
@end
