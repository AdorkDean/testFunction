//
//  OrgFaProductModel.h
//  qmp_ios
//
//  Created by QMP on 2018/4/19.
//  Copyright © 2018年 Molly. All rights reserved.

//机构在服项目

#import <JSONModel/JSONModel.h>

@interface OrgFaProductModel : JSONModel

@property (copy, nonatomic) NSString <Optional> *product;
@property (copy, nonatomic) NSString <Optional> *hangye1;
@property (copy, nonatomic) NSString <Optional> *yewu;
@property (copy, nonatomic) NSString <Optional> *icon;
@property (copy, nonatomic) NSString <Optional> *need_lunci;
@property (copy, nonatomic) NSString <Optional> *need_money;
@property (copy, nonatomic) NSString <Optional> *province;
@property (copy, nonatomic) NSString <Optional> *bp;
@property (copy, nonatomic) NSString <Optional> *sponsor;
@property (copy, nonatomic) NSString <Optional> *sponsor_phone;
@property (copy, nonatomic) NSString <Optional> *sponsor_position;


//需要
@property (copy, nonatomic) NSString <Optional> *detail;

//
//@property (copy, nonatomic) NSString <Optional> *collect;
//@property (copy, nonatomic) NSString <Optional> *company;
//@property (copy, nonatomic) NSString <Optional> *detail;
//@property (copy, nonatomic) NSString <Optional> *expire_flag;
//@property (copy, nonatomic) NSString <Optional> *jgname;
//@property (copy, nonatomic) NSString <Optional> *lianxi_mobile;
//@property (copy, nonatomic) NSString <Optional> *lianxi_name;
//@property (copy, nonatomic) NSString <Optional> *lianxi_zhiwu;
//@property (copy, nonatomic) NSString <Optional> *miaoshu;
//@property (copy, nonatomic) NSString <Optional> *product_id;
//@property (copy, nonatomic) NSString <Optional> *sp_flag;
//@property (copy, nonatomic) NSString <Optional> *unit;


@end
