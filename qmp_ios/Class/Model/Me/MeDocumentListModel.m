//
//  MeDocumentListModel.m
//  qmp_ios
//
//  Created by QMP on 2018/5/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MeDocumentListModel.h"

@implementation MeDocumentListModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"ID":@"id"}];
}

@end
