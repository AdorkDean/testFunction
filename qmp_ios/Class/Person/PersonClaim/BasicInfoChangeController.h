//
//  BasicInfoChangeController.h
//  qmp_ios
//
//  Created by QMP on 2018/3/30.
//  Copyright © 2018年 Molly. All rights reserved.
// 认证之前的修改  基本信息,（未认证的人物信息）

#import "BaseViewController.h"
#import "PersonModel.h"

@interface BasicInfoChangeController : BaseViewController

@property(nonatomic,strong)PersonModel *person;
@property(nonatomic,strong)NSMutableDictionary *personInfo;

@end
