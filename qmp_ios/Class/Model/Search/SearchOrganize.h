//
//  SearchOrganize.h
//  qmp_ios
//
//  Created by QMP on 2018/8/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SearchHighlightMedia;
@interface SearchOrganize : JSONModel

@property (nonatomic, copy) NSString<Optional> *jigou_name;
@property (nonatomic, copy) NSString<Optional> *jgname;
@property (nonatomic, copy) NSString<Optional> *detail;
@property (nonatomic, copy) NSString<Optional> *jg_type;
@property (nonatomic, copy) NSString<Optional> *jigou_id;
@property (nonatomic, copy) NSString<Optional> *ticket;
@property (nonatomic, copy) NSString<Optional> *jianjie;
@property (nonatomic, copy) NSString<Optional> *desc;
@property (nonatomic, copy) NSString<Optional> *icon;


@property (nonatomic, copy) NSString<Optional> *match_reason;  ///< 搜索匹配理由
@property (nonatomic, strong) id<Optional> highlight;
@property (nonatomic, copy) NSString<Optional> *highlight_string;

@property (nonatomic, strong) SearchHighlightMedia<Optional> *highlightMedia;
- (BOOL)needShowReason;
@end
