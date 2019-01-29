//
//  MeTopItemModel.m
//  qmp_ios
//
//  Created by QMP on 2018/5/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MeTopItemModel.h"

@implementation MeTopItemModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"attentionId":@"id"}];
}


-(NSString<Optional> *)nickname{
    if ([PublicTool isNull:_nickname]) {
        return self.name;
    }
    return _nickname;
}
@end
