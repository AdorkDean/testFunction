//
//  RZNewsModel.m
//  qmp_ios
//
//  Created by qimingpian08 on 16/10/10.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "RZNewsModel.h"

@implementation RZNewsModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //键值的替换
        if ([key isEqualToString:@"id"]) {
            self.productId = value;
        }
    
}

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"productId": @"id",
                                                                  }];
}


-(NSString *)title{
    if (![PublicTool isNull:_title]) {
        return _title;
    }
//    NSString *center = [NSString stringWithFormat:@""]
    return [NSString stringWithFormat:@"%@\"%@\"%@",self.yewu,self.product,self.weiyu];
}

-(NSString<Optional> *)source{
    if (![PublicTool isNull:_qmp_url] && ![_qmp_url isEqualToString:@"http://news2.qimingpian.com/qmp/404.html"]) {
        return _qmp_url;
    }
    return _source;
}

-(NSString<Optional> *)img_url{
   
    if ([_img_url.lastPathComponent containsString:@"jpeg"] || [_img_url.lastPathComponent containsString:@"JPEG"] || [_img_url.lastPathComponent containsString:@"jpg"] || [_img_url.lastPathComponent containsString:@"JPG"] || [_img_url.lastPathComponent containsString:@"png"] || [_img_url.lastPathComponent containsString:@"PNG"]) {
        return _img_url;
    }
    return nil;
}
@end


@implementation RZNewsModel2

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //键值的替换
    if ([key isEqualToString:@"id"]) {
        self.productId = value;
    }
    
}

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"productId": @"id",
                                                                  @"money": @"rzmoney",
                                                                  @"time": @"rztime",
                                                                  }];
}


-(NSString *)title{
    if (![PublicTool isNull:_title]) {
        return _title;
    }
    //    NSString *center = [NSString stringWithFormat:@""]
    return [NSString stringWithFormat:@"%@\"%@\"%@",self.yewu,self.product,self.weiyu];
}

-(NSString<Optional> *)source{
    if (![PublicTool isNull:_qmp_url] && ![_qmp_url isEqualToString:@"http://news2.qimingpian.com/qmp/404.html"]) {
        return _qmp_url;
    }
    return _source;
}

-(NSString<Optional> *)img_url{
    
    if ([_img_url.lastPathComponent containsString:@"jpeg"] || [_img_url.lastPathComponent containsString:@"JPEG"] || [_img_url.lastPathComponent containsString:@"jpg"] || [_img_url.lastPathComponent containsString:@"JPG"] || [_img_url.lastPathComponent containsString:@"png"] || [_img_url.lastPathComponent containsString:@"PNG"]) {
        return _img_url;
    }
    return nil;
}
@end
