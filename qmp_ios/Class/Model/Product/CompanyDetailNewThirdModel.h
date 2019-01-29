//
//  CompanyDetailNewThirdModel.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/5.
//  Copyright © 2016年 qimingpian. All rights reserved.
//
/*
 * 公司详情 公司公告
 */
#import <Foundation/Foundation.h>

@interface CompanyDetailNewThirdModel : JSONModel

@property(nonatomic,copy) NSString <Optional>*title;
@property(nonatomic,copy) NSString <Optional>*size;
@property(nonatomic,copy) NSString <Optional>*file;
@property(nonatomic,copy) NSString <Optional>*time;
@property (nonatomic, copy) NSString <Optional>*category;
@property(nonatomic,copy) NSString <Optional>*pdf_id;
@property(nonatomic,copy) NSString <Optional>*pdf_type;
@property(nonatomic,strong) NSNumber <Optional>*is_collect;

@end
