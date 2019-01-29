//
//  CompanyDetailLianxiModel.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/7.
//  Copyright © 2016年 qimingpian. All rights reserved.
//
/*
 * 联系方式
 */
#import <Foundation/Foundation.h>

@interface CompanyDetailLianxiModel : JSONModel

@property(nonatomic,copy) NSString <Optional>* address;
@property(nonatomic,copy) NSString <Optional>* phone;
@property(nonatomic,copy) NSString <Optional>* email;
@property(nonatomic,copy) NSString <Optional>* other;
@property(nonatomic,copy) NSString <Optional>* province;


@end
