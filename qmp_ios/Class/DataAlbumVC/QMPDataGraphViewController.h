//
//  QMPDataGraphViewController.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/9/6.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

@interface QMPDataGraphViewController : BaseViewController
@property (nonatomic, copy) void(^refreshComplated)(void);
- (void)refreshCallback:(void(^)(void))refreshComplated;
@end
