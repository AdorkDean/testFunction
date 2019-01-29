//
//  ZhaopinModel.h
//  qmp_ios
//
//  Created by QMP on 2018/2/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface ZhaopinModel : JSONModel

@property (copy, nonatomic) NSString <Optional> *zhaopinId;
@property (copy, nonatomic) NSString <Optional> *title;
@property (copy, nonatomic) NSString <Optional> *city;
@property (copy, nonatomic) NSString <Optional> *district;
@property (copy, nonatomic) NSString <Optional> *ori_salary;
@property (copy, nonatomic) NSString <Optional> *url_path;
@property (copy, nonatomic) NSString <Optional> *start_date;
@property (copy, nonatomic) NSString <Optional> *end_date;
@property (copy, nonatomic) NSString <Optional> *source;
@property (copy, nonatomic) NSString <Optional> *education;
@property (copy, nonatomic) NSString <Optional> *employer_number;
@property (copy, nonatomic) NSString <Optional> *experience;
@property (copy, nonatomic) NSString <Optional> *zhiwei_createtime;
@property (copy, nonatomic) NSString <Optional> *zhiwei_updatetime;
@property (copy, nonatomic) NSString <Optional> *desc;

@end
