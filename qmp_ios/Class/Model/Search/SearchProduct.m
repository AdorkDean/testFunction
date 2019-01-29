//
//  SearchProduct.m
//  qmp_ios
//
//  Created by QMP on 2018/8/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SearchProduct.h"
#import "SearchHighlightMedia.h"
@implementation SearchProduct
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.company_id = value;
        self.productId = value;
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
    
    if ([PublicTool isNull:hs[@"product"]]) {
        return;
    }
    if (![hs[@"product"] isKindOfClass:[NSArray class]]) {
        return;
    }
    NSArray *res = hs[@"product"];
    if (res.count == 0) {
        return;
    }
    NSString *str = [res firstObject];
    
    _highlightMedia = [SearchHighlightMedia highLightMediaWithString:str];
}
@end


/*
 
 search_reason:
    人名：
    工作经历：
    其他：
 
 
 */
