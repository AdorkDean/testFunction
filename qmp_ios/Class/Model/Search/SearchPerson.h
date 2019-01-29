//
//  SearchPerson.h
//  qmp_ios
//
//  Created by QMP on 2018/8/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZhiWeiModel;
@class SearchHighlightMedia;

@interface SearchPerson : JSONModel
@property (nonatomic, copy) NSString<Optional> *icon;
@property (nonatomic, copy) NSString<Optional> *name;
@property (nonatomic, copy) NSString<Optional> *ename;
@property (nonatomic, copy) NSString<Optional> *personId;
@property (nonatomic, copy) NSString<Optional> *person_id;
@property (nonatomic, copy) NSString<Optional> *usercode;
@property (nonatomic, copy) NSString<Optional> *claim_type;
@property (nonatomic, copy) NSArray <Optional> *role;
@property (nonatomic, copy) NSString<Optional> *ticket;
@property (nonatomic, copy) NSString<Optional> *ticket_id;
@property (nonatomic, strong) NSArray<ZhiWeiModel, Optional> *zhiwei;

@property (nonatomic, copy) NSString<Optional> *match_reason;  ///< 搜索匹配理由
@property (nonatomic, strong) id<Optional> highlight;
@property (nonatomic, copy) NSString<Optional> *highlight_string;

@property (nonatomic, strong) SearchHighlightMedia<Optional> *highlightMedia;
@property (nonatomic, strong) SearchHighlightMedia<Optional> *highlightMedia2;
- (BOOL)needShowReason;
@end
