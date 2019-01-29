//
//  RecommendModel.m
//  qmp_ios
//
//  Created by Molly on 2017/3/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "RecommendModel.h"

@implementation RecommendModel

+ (JSONKeyMapper*)keyMapper{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"id": @"orderId",
                                                                
                                                                  }];
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}

-(NSString *)title{
    if (![PublicTool isNull:_title]) {
        return _title;
    }
     return [NSString stringWithFormat:@"%@\"%@\"完成%@",self.yewu,self.product,self.lunci];
}


-(NSString<Optional> *)news_link{
    if (![PublicTool isNull:_qmp_url] && ![_qmp_url isEqualToString:@"http://news2.qimingpian.com/qmp/404.html"]) {
        return _qmp_url;
    }
    return _news_link;
}

-(NSString<Optional> *)img_url{
    if ([_img_url.lastPathComponent containsString:@"jpeg"] || [_img_url.lastPathComponent containsString:@"JPEG"] || [_img_url.lastPathComponent containsString:@"jpg"] || [_img_url.lastPathComponent containsString:@"JPG"] || [_img_url.lastPathComponent containsString:@"png"] || [_img_url.lastPathComponent containsString:@"PNG"]) {
        return _img_url;
    }
    return nil;
}
@end
