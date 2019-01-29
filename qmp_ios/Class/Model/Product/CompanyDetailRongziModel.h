//
//  CompanyDetailRongziModel.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/7.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompanyDetailRongziModel : JSONModel

@property(nonatomic,copy) NSString <Optional>* fa;
@property(nonatomic,copy) NSArray <Optional>* fa_info;
@property(nonatomic,copy) NSString <Optional>*tzr_all;
@property(nonatomic,copy) NSArray <Optional>* investor_info;
@property(nonatomic,copy) NSString <Optional>*bili;
@property(nonatomic,copy) NSString <Optional>*guzhi;
@property(nonatomic,copy) NSString <Optional>*source;//披露链接
@property(nonatomic,copy) NSString <Optional>*jieduan;
@property(nonatomic,copy) NSString <Optional>* time; //披露时间
@property(nonatomic,copy) NSString <Optional>*news_title;//披露标题
@property(nonatomic,copy) NSString <Optional>*rz_time;//融资时间


@property(nonatomic,copy) NSDictionary <Optional>* fa_link_ios;
@property(nonatomic,copy) NSString <Optional>* dataId;//id
@property(nonatomic,copy) NSString <Optional>* real_time;
@property(nonatomic,copy) NSString <Optional>* pl_time;//
@property(nonatomic,copy) NSString <Optional>*from;
@property(nonatomic,copy) NSString <Optional>*lunci;

@property(nonatomic,copy) NSString <Optional>*money;
//@property(nonatomic,copy) NSString <Optional>*tzr;
//@property(nonatomic,copy) NSString <Optional>*tzr_link;
//@property(nonatomic,copy) NSString <Optional>*tzr_link_wx;
//@property(nonatomic,copy) NSString <Optional>*orderbyrztime;
@property(nonatomic,copy) NSString <Optional>*weiyu;//复制融资轮次分享出去的信息

//@property(nonatomic,strong) NSDictionary <Optional>*tzr_link_obj_pro;
@property(nonatomic,copy) NSString <Optional>*isFeedback;
@end
