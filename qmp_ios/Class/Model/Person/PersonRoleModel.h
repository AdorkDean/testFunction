//
//  PersonRoleModel.h
//  qmp_ios
//
//  Created by QMP on 2018/4/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface PersonRoleModel : JSONModel

@property (nonatomic, copy) NSString <Optional>*roleID;

@property (nonatomic, copy) NSString <Optional>*person_id;
@property (nonatomic, copy) NSString <Optional>*person_name;
@property (nonatomic, copy) NSString <Optional>*qy_province;
@property (nonatomic, copy) NSString <Optional>*qy_start_date;
@property (nonatomic, copy) NSString <Optional>*qy_status;
@property (nonatomic, copy) NSString <Optional>*qy_ziben;
@property (nonatomic, copy) NSString <Optional>*qy_name;
@property (nonatomic, copy) NSString <Optional>*role;
@property (nonatomic, copy) NSString <Optional>*unionid;
@property (nonatomic, copy) NSString <Optional>*detail_link;
@property (nonatomic, copy) NSString <Optional>*type;
@property (nonatomic, copy) NSString <Optional>*percent;
//新增
@property (nonatomic, copy) NSArray <Optional>*roles;
@property (nonatomic, copy) NSDictionary <Optional>*rel_project;  //name  icon  detail

//商业公司
@property (nonatomic, copy) NSString <Optional>*product;
@property (nonatomic, copy) NSString <Optional>*pro_icon;
@property (nonatomic, copy) NSString <Optional>*pro_detail;
@property (nonatomic, copy) NSString <Optional>*jg_name;
@property (nonatomic, copy) NSString <Optional>*jg_icon;
@property (nonatomic, copy) NSString <Optional>*jg_detail;

//商业角色
@property (nonatomic, copy) NSString <Optional>*detail;
@property (nonatomic, copy) NSString <Optional>*company;


@property (nonatomic, copy) NSString <Optional>*hid;
@property (nonatomic, copy) NSString <Optional>*cid;

@end
