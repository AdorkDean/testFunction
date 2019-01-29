//
//  SearchHighlightMedia.m
//  qmp_ios
//
//  Created by QMP on 2018/8/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SearchHighlightMedia.h"
#import <TFHpple.h>

@implementation SearchHighlightMedia

+ (instancetype)highLightMediaWithString:(NSString *)htmlString {
    return [[self alloc] initWithString:htmlString];
}

- (instancetype)initWithString:(NSString *)htmlString {
    self = [super init];
    if (self) {
        self.origionalText = htmlString;
        
        if (![htmlString hasPrefix:@"<body>"]) {
            htmlString = [NSString stringWithFormat:@"<body>%@</body>", htmlString];
        }
        _displayText = [NSMutableString stringWithString:@""];
        _items = [NSMutableArray array];
        
        NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *docu = [TFHpple hppleWithHTMLData:data];
        TFHppleElement *rootElement = [docu peekAtSearchWithXPathQuery:@"//body"];
        [self analyseHtmlElement:rootElement];
    }
    return self;
}
- (void)analyseHtmlElement:(TFHppleElement *)element {
    SearchHighlightMediaItem *item = nil;
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
    } else if ([element.tagName isEqualToString:@"em"]) {
        item = [[SearchHighlightMediaItem alloc] init];
        item.displayText = element.text? element.text: @"";
    }
    if (item) {
        item.range = NSMakeRange(_displayText.length, item.displayText.length);
        [_items addObject:item];
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

@implementation SearchHighlightMediaItem
@end
