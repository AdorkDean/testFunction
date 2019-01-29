//
//  PersonBusinessRoleController.h
//  qmp_ios
//
//  Created by QMP on 2018/4/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, PersonBusinessRoleControllerType) {
    PersonBusinessRoleControllerTypeLegal,          ///< 法人
    PersonBusinessRoleControllerTypeShareholder,    ///< 股东
    PersonBusinessRoleControllerTypeExecutives,     ///< 高管
};

@interface PersonBusinessRoleController : BaseViewController
@property (nonatomic, strong) NSString *personID;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) PersonBusinessRoleControllerType type;
@end
