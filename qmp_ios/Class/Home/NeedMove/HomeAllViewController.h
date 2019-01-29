//
//  HomeAllViewController.h
//  qmp_ios
//
//  Created by QMP on 2018/5/23.
//  Copyright © 2018年 Molly. All rights reserved.
//  项目库

#import "BaseViewController.h"

@interface HomeAllViewController : BaseViewController
@property(nonatomic,assign,getter=isShow) BOOL show;
- (void)hideFilterView;

@end
