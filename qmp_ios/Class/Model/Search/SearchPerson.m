//
//  SearchPerson.m
//  qmp_ios
//
//  Created by QMP on 2018/8/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SearchPerson.h"
#import "SearchHighlightMedia.h"
#import "ZhiWeiModel.h"

@implementation SearchPerson
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"personId": @"id",
                                                                  }];
}
- (BOOL)needShowReason {
    if ([PublicTool isNull:self.match_reason]) {
        return NO;
    }
    NSString *matchReason = self.match_reason;
    NSInteger index = [matchReason rangeOfString:@":"].location + 2;
    NSString *matchStr = [matchReason substringFromIndex:index];
    
    if ([matchReason hasPrefix:@"人名"]) {
        return ![matchStr isEqualToString:self.name];
    }
    if ([matchReason hasPrefix:@"工作经历"]) {
        NSString *company;
        if (self.zhiwei.count) {
            ZhiWeiModel *zhiwei = self.zhiwei[0];
            company = zhiwei.name;
        }
        return ![matchStr isEqualToString:company];
    }
    
    if (matchReason.length > 0 && matchStr.length > 0) {
        return YES;
    }
    return NO;
}
- (void)setHighlight_string:(NSString<Optional> *)highlight_string {
    _highlight_string = highlight_string;
    
    if ([self.match_reason hasPrefix:@"人名"]) {
        _highlightMedia = [SearchHighlightMedia highLightMediaWithString:highlight_string];
    } else if ([self.match_reason hasPrefix:@"工作经历"]) {
        _highlightMedia2 = [SearchHighlightMedia highLightMediaWithString:highlight_string];
    }
}
- (void)setMatch_reason:(NSString<Optional> *)match_reason {
    _match_reason = match_reason;
    
    if ([self.match_reason hasPrefix:@"人名"]) {
        _highlightMedia = [SearchHighlightMedia highLightMediaWithString:self.highlight_string];
    } else if ([self.match_reason hasPrefix:@"工作经历"]) {
        _highlightMedia2 = [SearchHighlightMedia highLightMediaWithString:self.highlight_string];
    }
}
// [1]    (null)    @"products.bigram" : @"1 element"
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
    if (![PublicTool isNull:hs[@"name_zh.bigram"]]) {
        if (![hs[@"name_zh.bigram"] isKindOfClass:[NSArray class]]) {
            return;
        }
        NSArray *res = hs[@"name_zh.bigram"];
        if (res.count == 0) {
            return;
        }
        NSString *str = [res firstObject];
        
        _highlightMedia = [SearchHighlightMedia highLightMediaWithString:str];
    }
    if (![PublicTool isNull:hs[@"products.bigram"]]) {
        if (![hs[@"products.bigram"] isKindOfClass:[NSArray class]]) {
            return;
        }
        NSArray *res = hs[@"products.bigram"];
        if (res.count == 0) {
            return;
        }
        NSString *str = [res firstObject];
        
        _highlightMedia2 = [SearchHighlightMedia highLightMediaWithString:str];
    } else {
        if (![PublicTool isNull:hs[@"jigous.bigram"]]) {
            if (![hs[@"jigous.bigram"] isKindOfClass:[NSArray class]]) {
                return;
            }
            NSArray *res = hs[@"jigous.bigram"];
            if (res.count == 0) {
                return;
            }
            NSString *str = [res firstObject];
            
            _highlightMedia2 = [SearchHighlightMedia highLightMediaWithString:str];
        }
    }
    
}

-(NSString<Optional> *)personId{
    if ([PublicTool isNull:_personId]) {
        return _person_id?_person_id:@"";
    }
    return _personId;
}
@end
