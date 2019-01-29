//
//  EditBasicInfoController.h
//  qmp_ios
//
//  Created by QMP on 2018/1/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"
#import "PersonModel.h"

@interface EditBasicInfoController : BaseViewController

@property(nonatomic,strong)PersonModel *person;
@property(nonatomic,strong)NSMutableDictionary *userInfoDic;
@property(nonatomic,strong)NSMutableDictionary *personInfo;

@end
