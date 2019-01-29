//
//  SearchCompanyModel.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/3.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "SearchCompanyModel.h"

@implementation SearchCompanyModel

//防奔溃
-(void)setValue:(id)value forKey:(nonnull NSString *)key{
    [super setValue:value forKey:key];
    //键值的替换
    if ([key isEqualToString:@"id"]) {
        self.productId = value;
    }
    if ([key isEqualToString:@"product_id"]) {
        self.productId = value;
    }
    if ([key isEqualToString:@"company_id"]) {
        self.productId = value;
    }
}

-(void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key{
    //键值的替换
    if ([key isEqualToString:@"id"]) {
        self.productId = value;
    }
    if ([key isEqualToString:@"product_id"]) {
        self.productId = value;
    }
    if ([key isEqualToString:@"company_id"]) {
        self.productId = value;
    }
}

@end
