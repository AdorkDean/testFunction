//
//  FinanPersonInfoVC.h
//  qmp_ios
//
//  Created by QMP on 2018/5/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"


@interface FinanPersonInfoVC : BaseViewController

@property(nonatomic,assign) BOOL needClaim; //需要认领吗
@property(nonatomic,strong) NSDictionary *param; //项目+融资需求

@end
