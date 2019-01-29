//
//  ActivityHtmlMedia.m
//  qmp_ios
//
//  Created by QMP on 2018/8/6.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ActivityHtmlMedia.h"
#import <TFHpple.h>
@implementation ActivityHtmlMedia
+ (instancetype)htmlMediaWithString:(NSString *)htmlString {
    return [[self alloc] initWithString:htmlString];
}
- (NSString *)htmlEntityDecode:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    return string;
}
- (instancetype)initWithString:(NSString *)htmlString {
    self = [super init];
    if (self) {
        htmlString = [self htmlEntityDecode:htmlString];
        _origionalText = htmlString;
        
        if (![htmlString hasPrefix:@"<body>"]) {
            htmlString = [NSString stringWithFormat:@"<body>%@</body>", htmlString];
        }
        _displayText = [NSMutableString stringWithString:@""];
        _mediaItems = [NSMutableArray array];
        
        NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *docu = [TFHpple hppleWithHTMLData:data];
        TFHppleElement *rootElement = [docu peekAtSearchWithXPathQuery:@"//body"];
        [self analyseHtmlElement:rootElement];
    }
    return self;
}
- (void)analyseHtmlElement:(TFHppleElement *)element {
    ActivityHtmlMediaItem *item = nil;
    if (element.isTextNode) {
        if ([element.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
            [_displayText appendString:element.content];
        } else if (![_displayText hasSuffix:@"\n"] && _displayText.length > 0){
            NSCharacterSet *lineSet = [NSCharacterSet newlineCharacterSet];
            if ([element.content rangeOfCharacterFromSet:lineSet].location != NSNotFound) {
                [_displayText appendString:@"\n"];
            }else{
                [_displayText appendString:element.content];
            }
        }
    } else if ([element.tagName isEqualToString:@"br"]){
        if (![_displayText hasSuffix:@"\n"] && _displayText.length > 0) {
            [_displayText appendString:@"\n"];
        }
    } else if ([element.tagName isEqualToString:@"url"]) {
        NSDictionary *attributes = element.attributes;
        NSString *element_Class = [attributes objectForKey:@"type"];
        if ([element_Class isEqualToString:@"product"]) {
            // 项目
            item = [ActivityHtmlMediaItem htmlMediaItemWithType:ActivityHtmlMediaItemTypeProduct];
            item.href = [attributes objectForKey:@"detail"];
            item.name = element.text? element.text: @"";
        } else if ([element_Class isEqualToString:@"jigou"]) {
            // 机构
            item = [ActivityHtmlMediaItem htmlMediaItemWithType:ActivityHtmlMediaItemTypeOrganize];
            item.href = [attributes objectForKey:@"detail"];
            item.name = element.text? element.text: @"";
        } else{
            // 人
            if (element.text.length > 0) {
                item = [ActivityHtmlMediaItem htmlMediaItemWithType:ActivityHtmlMediaItemTypePerson];
                item.href = [attributes objectForKey:@"detail"];
                item.linkStr = element.text;
            }
        }
    }
    if (item) {
        item.range = NSMakeRange(_displayText.length, item.displayText.length);
        [_mediaItems addObject:item];
        [_displayText appendString:item.displayText];
        return;
    }
    if (element.hasChildren) {
        for (TFHppleElement *child in [element children]) {
            [self analyseHtmlElement:child];
        }
    }
}
@end

@implementation ActivityHtmlMediaItem
+ (instancetype)htmlMediaItemWithType:(ActivityHtmlMediaItemType)type {
    ActivityHtmlMediaItem *item = [[ActivityHtmlMediaItem alloc] init];
    item.type = type;
    return item;
}
- (NSString *)displayText {
    return self.name;
}
@end
