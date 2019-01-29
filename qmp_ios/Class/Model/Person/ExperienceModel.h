//
//  WorkExperienceModel.h
//  qmp_ios
//
//  Created by QMP on 2018/1/31.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface ExperienceModel : JSONModel

@property (copy, nonatomic)NSString <Optional> *experienceId;
@property (copy, nonatomic)NSString <Optional> *unionid;
@property (copy, nonatomic)NSString <Optional> *icon; //公司icon

@property (copy, nonatomic)NSString <Optional> *company;
@property (copy, nonatomic)NSString <Optional> *product;

@property (copy, nonatomic)NSString <Optional> *type; // 工作经历所在 是公司还是机构,company\jigou

@property (copy, nonatomic)NSString <Optional> *school;
@property (copy, nonatomic)NSString <Optional> *zhiwei;
@property (copy, nonatomic)NSString <Optional> *zhuanye;
@property (copy, nonatomic)NSString <Optional> *xueli;
@property (copy, nonatomic)NSString <Optional> *desc;
@property (copy, nonatomic)NSString <Optional> *start_time;
@property (copy, nonatomic)NSString <Optional> *end_time;

@end
