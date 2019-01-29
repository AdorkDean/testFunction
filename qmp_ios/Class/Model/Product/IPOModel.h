//
//  IPOModel.h
//  qmp_ios
//
//  Created by QMP on 2018/3/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface IPOModel : JSONModel

@property (copy, nonatomic) NSString <Optional> *company;
@property (copy, nonatomic) NSString <Optional> *ipoId;
@property (copy, nonatomic) NSString <Optional> *name;
@property (copy, nonatomic) NSString <Optional> *now_status;
@property (copy, nonatomic) NSString <Optional> *preUpdatestime;
@property (copy, nonatomic) NSString <Optional> *prestime;
@property (copy, nonatomic) NSString <Optional> *shtime;
@property (copy, nonatomic) NSString <Optional> *sponsor;
@property (copy, nonatomic) NSString <Optional> *state;
@property (copy, nonatomic) NSString <Optional> *time;
@property (copy, nonatomic) NSString <Optional> *title;
@property (copy, nonatomic) NSString <Optional> *type;
@property (copy, nonatomic) NSString <Optional> *accountant_sign;
@property (copy, nonatomic) NSString <Optional> *lawyer_sign;
@property (copy, nonatomic) NSString <Optional> *accountting_firm;
@property (copy, nonatomic) NSString <Optional> *company_gz;
@property (copy, nonatomic) NSString <Optional> *flag;
@property (copy, nonatomic) NSString <Optional> *hangye;
@property (copy, nonatomic) NSString <Optional> *ipo_type;
@property (copy, nonatomic) NSString <Optional> *is_join_check;
@property (copy, nonatomic) NSString <Optional> *law_firm;
@property (copy, nonatomic) NSString <Optional> *num;
@property (copy, nonatomic) NSString <Optional> *number; //序号
@property (copy, nonatomic) NSString <Optional> *plate_name;
@property (copy, nonatomic) NSString <Optional> *preipo_area;
@property (copy, nonatomic) NSString <Optional> *regist_area;
@property (copy, nonatomic) NSString <Optional> *remark;
@property (copy, nonatomic) NSString <Optional> *sponsor_person;
@property (copy, nonatomic) NSString <Optional> *update_time;
@property (copy, nonatomic) NSString <Optional> *shangshididian;
@property (copy, nonatomic) NSString <Optional> *hangye1;

@end
