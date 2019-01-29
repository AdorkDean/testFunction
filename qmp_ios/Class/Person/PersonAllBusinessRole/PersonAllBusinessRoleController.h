//
//  PersonAllBusinessRoleController.h
//  qmp_ios
//
//  Created by QMP on 2018/4/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"
@class PersonModel;
@interface PersonAllBusinessRoleController : BaseViewController
@property (nonatomic, strong) NSString *personID;
@property (nonatomic, strong) NSString *sid;
@property (nonatomic, strong) PersonModel *personModel;

@property (nonatomic, assign) BOOL isNeedUserHeader;
@end
