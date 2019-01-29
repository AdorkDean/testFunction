//
//  CompanysDetailRegisterTouziModel.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/12.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompanysDetailRegisterTouziModel : NSObject
@property(nonatomic,copy)NSString *tz_name;    //公司名
@property(nonatomic,copy)NSString *qy_start_date;    //成立时间
@property(nonatomic,copy)NSString *qy_ziben;    //注册资本
@property(nonatomic,copy)NSString *icon;    //项目图标
@property(nonatomic,copy)NSString *detail;    //项目/公司链接
@property(nonatomic,copy)NSString *product;    //项目名
@property(nonatomic,copy)NSString *yewu;    //项目业务
@property(nonatomic,copy)NSString *agency_icon;    // 机构图标
@property(nonatomic,copy)NSString *agency_detail;    //机构链接
@property(nonatomic,copy)NSString *agency_name;    //机构名
//
//
//@property(nonatomic,copy)NSString * name;
//@property(nonatomic,copy)NSString * jglink;
//@property(nonatomic,copy)NSString * icon;
//@property(nonatomic,copy)NSString * detail;
//@property(nonatomic,copy)NSString * detailm;
//@property(nonatomic,copy)NSString * detailwx;
@end
