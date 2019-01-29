//
//  PostSelectRelateViewController.h
//  qmp_ios
//
//  Created by QMP on 2018/6/30.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

@interface PostSelectRelateViewController : BaseViewController
@property (nonatomic, copy) void(^didSelected)(id selectedObject, BOOL isOrgnize);
@property (nonatomic, copy) void(^didSelectedObject)(id selectedObject, NSString *type);

@end
