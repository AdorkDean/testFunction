//
//  SearchHighlightMedia.h
//  qmp_ios
//
//  Created by QMP on 2018/8/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchHighlightMedia : NSObject
@property (nonatomic, copy) NSString *origionalText;
@property (nonatomic, copy) NSMutableString *displayText;

@property (nonatomic, strong) NSMutableArray *items;


+ (instancetype)highLightMediaWithString:(NSString *)htmlString;
- (instancetype)initWithString:(NSString *)htmlString;
@end


@interface SearchHighlightMediaItem : NSObject
@property (nonatomic, copy) NSString *displayText;
@property (nonatomic, assign) NSRange range;
@end
