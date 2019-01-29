//
//  SearchOrganize.m
//  qmp_ios
//
//  Created by QMP on 2018/8/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SearchOrganize.h"
#import "SearchHighlightMedia.h"
@implementation SearchOrganize
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"jigou_id": @"id"
                                                                  }];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    //    键值的替换
    if ([key isEqualToString:@"id"]) {
        self.jigou_id = value;
    }
}


- (BOOL)needShowReason {
    if ([PublicTool isNull:self.match_reason]) {
        return NO;
    }
    NSString *matchReason = self.match_reason;
    NSInteger index = [matchReason rangeOfString:@":"].location + 2;
    
    NSString *matchStr = [matchReason substringFromIndex:index];
    if (matchReason.length > 0 && matchStr.length > 0) {
        return YES;
    }
    return NO;
}
- (void)setHighlight_string:(NSString<Optional> *)highlight_string {
    _highlight_string = highlight_string;
    
    _highlightMedia = [SearchHighlightMedia highLightMediaWithString:highlight_string];
}

- (void)setHighlight:(id<Optional>)highlight {
    _highlight = highlight;
    return;
    id hl = highlight;
    if (![hl isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSDictionary *hs = (NSDictionary *)hl;
    if (hs.count == 0) {
        return;
    }
    if (![PublicTool isNull:hs[@"name"]]) {
        if (![hs[@"name"] isKindOfClass:[NSArray class]]) {
            return;
        }
        NSArray *res = hs[@"name"];
        if (res.count == 0) {
            return;
        }
        NSString *str = [res firstObject];
        
        _highlightMedia = [SearchHighlightMedia highLightMediaWithString:str];
    } else if (![PublicTool isNull:hs[@"name_default"]]) {
        if (![hs[@"name_default"] isKindOfClass:[NSArray class]]) {
            return;
        }
        NSArray *res = hs[@"name_default"];
        if (res.count == 0) {
            return;
        }
        NSString *str = [res firstObject];
        
        _highlightMedia = [SearchHighlightMedia highLightMediaWithString:str];
        
    }
    
}
-(NSString<Optional> *)jianjie{
    if ([PublicTool isNull:_jianjie]) {
        return _desc?_desc:@"";
    }
    return _jianjie;
}
-(NSString<Optional> *)jigou_name{
    if ([PublicTool isNull:_jigou_name]) {
        return _jgname?_jgname:@"";
    }
    return _jigou_name;
}
@end
