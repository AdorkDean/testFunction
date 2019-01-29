//
//  CardItem.m
//  qmp_ios
//
//  Created by Molly on 16/9/22.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CardItem.h"

@implementation CardItem

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //键值的替换
    if ([key isEqualToString:@"id"]) {
        self.cardId = value;
    }
    if ([key isEqualToString:@"person_name"]) {
        self.cardName = value;
    }
    if ([key isEqualToString:@"web_url"]) {
        self.imgUrl = value;
    }
    if ([key isEqualToString:@"beizhu"]) {
        self.remark = value;
    }
    if ([key isEqualToString:@"create_time"]) {
        NSString *time = value;
        self.uploadTime = [[time componentsSeparatedByString:@" "] firstObject];
    }
    
    if ([key isEqualToString:@"back_url"]) {
        self.backImgUrl = value;
    }   
  
}

- (void)setValue:(id)value forKey:(NSString *)key{
    [super setValue:value forKey:key];
   
    if ([key isEqualToString:@"title"]) {
        self.zhiwu = value;
    }
    if ([key isEqualToString:@"name"]) {
        self.cardName = value;
    }
    
    if ([key isEqualToString:@"mobile"]) {
        self.phone = value;
    }
    
    if ([key isEqualToString:@"addr"]) {
        self.offaddress = value;
    }
    if ([key isEqualToString:@"comp"]) {
        self.company = value;
    }
    
}

@end
