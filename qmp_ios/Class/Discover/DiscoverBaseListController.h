//
//  DiscoverBaseListController.h
//  qmp_ios
//
//  Created by QMP on 2018/8/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

UIKIT_EXTERN NSNotificationName const ChildScrollVDidScrollNSNotification;
UIKIT_EXTERN NSNotificationName const ChildScrollVRefreshStateNSNotification;
//

#define kSearchViewH  (kScreenTopHeight)

#define kHeaderViewH ((SCREENW*34/75)+kScreenTopHeight+10) //banner+nabar


@interface DiscoverBaseListController : BaseViewController

@property (copy, nonatomic) void(^refreshComplated)(void);

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGPoint lastContentOffset;

@property (nonatomic, assign) BOOL isFirstViewLoaded;


@end
