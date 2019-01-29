//
//  SearchJigouModel.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/3.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchJigouModel : JSONModel


@property(nonatomic,copy) NSString <Optional>* from;
@property(nonatomic,copy) NSString <Optional>* jigou_ticket;
@property(nonatomic,copy) NSString <Optional>* jigou_name;
@property(nonatomic,copy) NSString <Optional>* jgname;
@property(nonatomic,copy) NSString <Optional>* desc;

@property(nonatomic,copy) NSString <Optional>* source_link;
@property(nonatomic,copy) NSString <Optional>* detail;
@property(nonatomic,copy) NSString <Optional>* detailwx;
@property(nonatomic,copy) NSString <Optional>* jieduan;//2.2.6之后弃用,改为tz_lunci
@property(nonatomic,copy) NSString <Optional>* tz_lunci;
@property(nonatomic,copy) NSString <Optional>* gw_link;
@property(nonatomic,copy) NSString <Optional>* hangye;
@property(nonatomic,copy) NSString <Optional>* jianjie;
@property(nonatomic,copy) NSString <Optional>* icon;
@property(nonatomic,copy) NSString <Optional>* score;
@property(nonatomic,copy) NSString <Optional>* renzheng;
@property(nonatomic,copy) NSString <Optional>* heyan;
@property(nonatomic,copy) NSString <Optional>* heyan2;
@property(copy,nonatomic) NSString <Optional>*jigou_id;
@property(copy,nonatomic) NSString <Optional>* jg_type;
@property(nonatomic,copy) NSString <Optional>*match_reason;//搜索匹配理由


@end
