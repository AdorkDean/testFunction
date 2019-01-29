//
//  AttentionNewsModel.h
//  qmp_ios
//
//  Created by QMP on 2018/1/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface AttentionNewsModel : JSONModel
//3.8.0
@property (copy, nonatomic) NSString <Optional> *totalnews_id;
@property (copy, nonatomic) NSString <Optional> *title;
@property (copy, nonatomic) NSString <Optional> *news_img;
@property (copy, nonatomic) NSString <Optional> *img_url;
@property (copy, nonatomic) NSString <Optional> *link;
@property (copy, nonatomic) NSString <Optional> *object_time;
@property (copy, nonatomic) NSNumber <Optional> *cellHeight;
@property (copy, nonatomic) NSString <Optional> *source;
@property (copy, nonatomic) NSNumber <Optional> *showAll;

/**
 评论人
 company 、"person_id" 、unionid 、"user_name"、zhiwu 、user_type = 2(官方账号);
 */
@property (copy, nonatomic) NSDictionary <Optional> *comment_info;

/**
 融资项目
 product 、"lunci" 、money 、"detail"
 */
@property (copy, nonatomic) NSDictionary <Optional> *rongzi;

//以前
@property (copy, nonatomic) NSString <Optional> *icon;
@property (copy, nonatomic) NSString <Optional> *product;
@property (copy, nonatomic) NSString <Optional> *jigou;
@property (copy, nonatomic) NSString <Optional> *detail;
@property (copy, nonatomic) NSString <Optional> *lingyu;
@property (copy, nonatomic) NSAttributedString <Optional>*attText;
@property(nonatomic,strong) NSNumber <Optional>*rowHeight;

@end
