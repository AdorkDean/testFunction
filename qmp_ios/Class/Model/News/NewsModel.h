//
//  NewsModel.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/5.
//  Copyright © 2016年 qimingpian. All rights reserved.
//
/*
 * 公司详情 媒体报道
 */
#import <Foundation/Foundation.h>

@interface NewsModel : JSONModel
@property(nonatomic,copy) NSString <Optional>*post_time;
@property(nonatomic,copy) NSString <Optional>*news_detail;
@property(nonatomic,copy) NSString <Optional>*news_id;

@property(nonatomic,copy) NSString <Optional>*title;
@property(nonatomic,copy) NSString <Optional>*link;
@property(nonatomic,copy) NSString <Optional>*type;
@property(nonatomic,copy) NSString <Optional>*date;
@property(nonatomic,copy) NSString <Optional>*source;
@property(nonatomic,copy) NSString <Optional>*icon;
@property(nonatomic,copy) NSString <Optional>*news_date;
@property(nonatomic,copy) NSString <Optional>*mark_type;

@end
