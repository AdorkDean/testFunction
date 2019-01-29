//
//  SearchProduct.h
//  qmp_ios
//
//  Created by QMP on 2018/8/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SearchHighlightMedia;
@interface SearchProduct : JSONModel
@property (nonatomic, copy) NSString<Optional> *company_id;
@property (nonatomic, copy) NSString<Optional> *product_id;
@property (nonatomic, copy) NSString<Optional> *productId;
@property (nonatomic, copy) NSString<Optional> *ticket;
@property (nonatomic, copy) NSString<Optional> *detail;
@property (nonatomic, copy) NSString<Optional> *product;
@property (nonatomic, copy) NSString<Optional> *company;
@property (nonatomic, copy) NSString<Optional> *icon;
@property (nonatomic, copy) NSString<Optional> *desc;
@property (nonatomic, copy) NSString<Optional> *hangye1;
@property (nonatomic, copy) NSString<Optional> *yewu;
@property (nonatomic, copy) NSString<Optional> *curlunci;
@property (nonatomic, copy) NSString<Optional> *lunci;

@property (nonatomic, copy) NSString<Optional> *match_reason; ///< 搜索匹配理由
@property (nonatomic, strong) id <Optional> highlight;
@property (nonatomic, copy) NSString<Optional> *highlight_string;

@property (nonatomic, strong) SearchHighlightMedia *highlightMedia;
- (BOOL)needShowReason;
@end
