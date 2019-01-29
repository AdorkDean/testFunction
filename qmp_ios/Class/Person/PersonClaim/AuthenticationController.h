//
//  AuthenticationController.h
//  qmp_ios
//
//  Created by QMP on 2018/3/26.
//  Copyright © 2018年 Molly. All rights reserved.
//身份认证   认领和创建的最后一步，认领头部有被认领人信息

#import "BaseViewController.h"
#import "PersonModel.h"

@interface AuthenticationController : BaseViewController

@property (assign, nonatomic) PersonRole role;

@property(nonatomic,strong)PersonModel *person; //为空即创建
@property(nonatomic,strong)NSString *searchName; //搜索不到，进入创建
@end
