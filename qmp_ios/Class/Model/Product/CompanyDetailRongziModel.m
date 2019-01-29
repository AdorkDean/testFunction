//
//  CompanyDetailRongziModel.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/7.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "CompanyDetailRongziModel.h"

@implementation CompanyDetailRongziModel

//防奔溃
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //键值的替换
        if ([key isEqualToString:@"id"]) {
            self.dataId = value;
        }
    
}

-(NSString<Optional> *)tzr_all{
    NSMutableString *tzrString = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@",_tzr_all]];
    NSString *tzrStr = _tzr_all;
    if ([tzrStr containsString:@"，"]) {
        tzrStr = [tzrString stringByReplacingOccurrencesOfString:@"，" withString:@"  "];
        
        tzrString = [NSMutableString stringWithString:tzrStr];
    }
    if ([tzrStr containsString:@"、"]) {
        tzrStr = [tzrString stringByReplacingOccurrencesOfString:@"、" withString:@"  "];
        
    }
    if ([tzrStr containsString:@","]) {
        tzrStr = [tzrString stringByReplacingOccurrencesOfString:@"," withString:@"  "];
        
    }
    return tzrStr;
}

@end
