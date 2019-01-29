//
//  CompanysDetailRegisterGudongModel.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/12.
//  Copyright © 2016年 Molly. All rights reserved.
//工商 股东

#import <Foundation/Foundation.h>

@interface CompanysDetailRegisterGudongModel : JSONModel

@property(nonatomic,copy) NSString <Optional>*capital; //认缴出资
@property(nonatomic,copy) NSString <Optional>*percent;  //出资比例

//新
@property(nonatomic,copy) NSString <Optional>*gd_name;
@property(nonatomic,copy) NSString <Optional>*gd_type; //股东类型
@property(nonatomic,copy) NSString <Optional>*person_id;    //人物id
@property(nonatomic,copy) NSString <Optional>*person_name;  //人物名
@property(nonatomic,copy) NSString <Optional>*person_icon;    //人物图标
@property(nonatomic,copy) NSString <Optional>*person_detail;    //人物链接
@property(nonatomic,copy) NSString <Optional>*product;    //项目名
@property(nonatomic,copy) NSString <Optional>*icon;    //项目图标
@property(nonatomic,copy) NSString <Optional>*detail;    //项目/公司链接
@property(nonatomic,copy) NSString <Optional>*agency_name;    //机构名
@property(nonatomic,copy) NSString <Optional>*agency_icon;    //机构图标
@property(nonatomic,copy) NSString <Optional>*agency_detail;    //机构链接

@property(nonatomic,copy) NSString <Optional>*uniq_hid; //人物数据


@end
