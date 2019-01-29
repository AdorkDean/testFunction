//
//  QMPIPOLibraryViewController.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/9/5.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

@interface QMPIPOLibraryViewController : BaseViewController
- (void)showFilterView;

@property (nonatomic, copy) void(^didFiltered)(BOOL flag);
@property (nonatomic, assign) BOOL filterFlag;
@end
