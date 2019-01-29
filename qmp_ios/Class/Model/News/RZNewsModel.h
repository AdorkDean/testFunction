//
//  RZNewsModel.h
//  qmp_ios
//
//  Created by qimingpian08 on 16/10/10.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RZNewsModel : JSONModel

@property (copy, nonatomic) NSString <Optional>*productId;
@property (copy, nonatomic) NSString <Optional>*product;
@property (copy, nonatomic) NSString <Optional>*company;
@property (copy, nonatomic) NSString <Optional>*province;
@property (copy, nonatomic) NSString <Optional>*icon;
@property (copy, nonatomic) NSString <Optional>*img_url;  //新闻缩略图
@property (copy, nonatomic) NSString <Optional>*qmp_url;  //新闻缩略图

@property (copy, nonatomic) NSString <Optional>*open_time;
@property (copy, nonatomic) NSString <Optional>*company_faren;
@property (copy, nonatomic) NSString <Optional>*company_ziben;
@property (copy, nonatomic) NSString <Optional>*desc;
@property (copy, nonatomic) NSString <Optional>*detail;
@property (copy, nonatomic) NSString <Optional>*detailwx;
@property (copy, nonatomic) NSString <Optional>*hangye1;
@property (copy, nonatomic) NSString <Optional>*hangye2;
@property (copy, nonatomic) NSString <Optional>*yewu;
@property (copy, nonatomic) NSString <Optional>*gw_link;
@property (copy, nonatomic) NSString <Optional>*from;
@property (copy, nonatomic) NSString <Optional>*money;
@property (copy, nonatomic) NSString <Optional>*jieduan;
@property (copy, nonatomic) NSString <Optional>*tzr;
@property (copy, nonatomic) NSString <Optional>*tzr_link;
@property (copy, nonatomic) NSString <Optional>*weiyu;
@property (copy, nonatomic) NSString <Optional>*time;
@property (copy, nonatomic) NSString <Optional>*source;
@property (copy, nonatomic) NSString <Optional>*country;
@property (copy, nonatomic) NSString <Optional>*short_url;//公司详情页短链接
@property (copy, nonatomic) NSString <Optional>*real_time;//事件事件,如果没有的话,给的是收录时间
@property (copy, nonatomic) NSString <Optional>*need_flag; //融资中
@property (copy, nonatomic) NSString <Optional>*lunci; //当前轮次
@property (copy, nonatomic) NSString <Optional>*news_time;

/**
  新闻标题
 */
@property (copy, nonatomic) NSString <Optional>*title;


@end


@interface RZNewsModel2 : JSONModel

@property (copy, nonatomic) NSString <Optional>*productId;
@property (copy, nonatomic) NSString <Optional>*product;
@property (copy, nonatomic) NSString <Optional>*company;
@property (copy, nonatomic) NSString <Optional>*province;
@property (copy, nonatomic) NSString <Optional>*icon;
@property (copy, nonatomic) NSString <Optional>*img_url;  //新闻缩略图
@property (copy, nonatomic) NSString <Optional>*qmp_url;  //新闻缩略图

@property (copy, nonatomic) NSString <Optional>*open_time;
@property (copy, nonatomic) NSString <Optional>*company_faren;
@property (copy, nonatomic) NSString <Optional>*company_ziben;
@property (copy, nonatomic) NSString <Optional>*desc;
@property (copy, nonatomic) NSString <Optional>*detail;
@property (copy, nonatomic) NSString <Optional>*detailwx;
@property (copy, nonatomic) NSString <Optional>*hangye1;
@property (copy, nonatomic) NSString <Optional>*hangye2;
@property (copy, nonatomic) NSString <Optional>*yewu;
@property (copy, nonatomic) NSString <Optional>*gw_link;
@property (copy, nonatomic) NSString <Optional>*from;
@property (copy, nonatomic) NSString <Optional>*money;
@property (copy, nonatomic) NSString <Optional>*jieduan;
@property (copy, nonatomic) NSString <Optional>*tzr;
@property (copy, nonatomic) NSString <Optional>*tzr_link;
@property (copy, nonatomic) NSString <Optional>*weiyu;
@property (copy, nonatomic) NSString <Optional>*time;
@property (copy, nonatomic) NSString <Optional>*source;
@property (copy, nonatomic) NSString <Optional>*country;
@property (copy, nonatomic) NSString <Optional>*short_url;//公司详情页短链接
@property (copy, nonatomic) NSString <Optional>*real_time;//事件事件,如果没有的话,给的是收录时间
@property (copy, nonatomic) NSString <Optional>*need_flag; //融资中
@property (copy, nonatomic) NSString <Optional>*lunci; //当前轮次

/**
 新闻标题
 */
@property (copy, nonatomic) NSString <Optional>*title;


@end
