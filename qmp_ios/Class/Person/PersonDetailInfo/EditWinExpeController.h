//
//  EditWinExpeController.h
//  qmp_ios
//
//  Created by QMP on 2018/4/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"
#import "WinExperienceModel.h"

typedef void(^SaveSuccess)(id newExperienceM);
typedef void(^DelSuccess)(id newExperienceM);
typedef void(^BackToLastpage)(void);

@interface EditWinExpeController : BaseViewController

@property (copy, nonatomic) SaveSuccess saveInfoSuccess;
@property (copy, nonatomic) DelSuccess  delInfoSuccess;
@property (copy, nonatomic) BackToLastpage  backToLastpage;

@property(nonatomic,strong)WinExperienceModel *experienceM;  //空  添加   不空 编辑


@end
