//
//  OneSquareListViewController.h
//  qmp_ios
//
//  Created by Molly on 16/9/6.
//  Copyright © 2016年 Molly. All rights reserved.
//首页专辑  -> 一个专辑

#import <UIKit/UIKit.h>
#import "GroupModel.h"

@interface OneSquareListViewController : BaseViewController

@property (strong, nonatomic) GroupModel *groupModel;
@property (strong, nonatomic) NSString *action;

@end
