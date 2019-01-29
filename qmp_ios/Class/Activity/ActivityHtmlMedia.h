//
//  ActivityHtmlMedia.h
//  qmp_ios
//
//  Created by QMP on 2018/8/6.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, ActivityHtmlMediaItemType) {
    ActivityHtmlMediaItemTypePerson = 0,
    ActivityHtmlMediaItemTypeOrganize,
    ActivityHtmlMediaItemTypeProduct,
};

@interface ActivityHtmlMedia : NSObject
@property (nonatomic, copy) NSString *origionalText;
@property (nonatomic, copy) NSMutableString *displayText;
@property (nonatomic, strong) NSMutableArray *mediaItems;


+ (instancetype)htmlMediaWithString:(NSString *)htmlString;
- (instancetype)initWithString:(NSString *)htmlString;

@end

@interface ActivityHtmlMediaItem : NSObject
@property (nonatomic, assign) ActivityHtmlMediaItemType type;
@property (nonatomic, copy) NSString *title, *href, *name, *linkStr;
@property (nonatomic, assign) NSRange range;

- (NSString *)displayText;

+ (instancetype)htmlMediaItemWithType:(ActivityHtmlMediaItemType)type;
@end
