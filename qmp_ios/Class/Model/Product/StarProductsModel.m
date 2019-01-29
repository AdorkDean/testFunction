//
//  StarProductsModel.m
//  qmp_ios
//
//  Created by qimingpian08 on 16/10/17.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "StarProductsModel.h"

@implementation StarProductsModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"productId": @"id"
                                                                  }];
}


//防奔溃
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //键值的替换
    if ([key isEqualToString:@"id"]) {
//        self.pro_id = value;
        self.productId = value;
//        self.company_id = value;
    }

}

@end
