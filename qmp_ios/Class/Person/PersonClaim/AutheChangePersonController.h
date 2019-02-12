//
//  UnautherizedPersonController.h
//  qmp_ios
//
//  Created by QMP on 2018/3/30.
//  Copyright © 2018年 Molly. All rights reserved.
//认证 修改

#import "BaseViewController.h"
#import "PersonModel.h"

@interface AutheChangePersonController : BaseViewController

@property (copy, nonatomic)NSString *persionId;
@property (copy, nonatomic) NSString *claim_id;

/**
 从认证页传入的人物数据
 */
@property (strong, nonatomic)PersonModel *cachePersonInfo;
@property(nonatomic,assign)  BOOL isInvestor; //此人是投资者
@end
