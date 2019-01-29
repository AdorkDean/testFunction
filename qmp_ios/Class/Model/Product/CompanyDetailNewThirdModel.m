//
//  CompanyDetailNewThirdModel.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/5.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "CompanyDetailNewThirdModel.h"

@implementation CompanyDetailNewThirdModel

//防奔溃
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //键值的替换
    if ([key isEqualToString:@"file"]) {
        self.file = value;
    }
    if ([key isEqualToString:@"time"]) {
        self.time = value;
    }
    
    
}

@end
