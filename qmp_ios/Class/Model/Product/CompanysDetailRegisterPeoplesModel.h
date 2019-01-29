//
//  CompanysDetailRegisterPeoplesModel.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/27.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompanysDetailRegisterPeoplesModel : NSObject
@property(nonatomic,copy)NSString * name;    //姓名
@property(nonatomic,copy)NSString * zhiwu;    //职务
@property(nonatomic,copy)NSString * icon;    //人物图标
@property(nonatomic,copy)NSString * person_name;    //关联人物的名字
@property(nonatomic,copy)NSString * detail;    //人物链接
@property(nonatomic,copy)NSString * jieshao;    //人物介绍
@property(nonatomic,copy) NSString <Optional>*uniq_hid; //人物数据

//@property(nonatomic,copy)NSString * peopleId;
//@property(nonatomic,copy) NSString *uniq_hid;
//
//@property(nonatomic,copy)NSString * name;
//@property(nonatomic,copy)NSString * job;
//@property(nonatomic,copy)NSString *detail_person;
@end
