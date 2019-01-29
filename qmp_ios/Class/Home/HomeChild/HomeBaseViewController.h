//
//  HomeBaseViewController.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/11/7.
//  Copyright © 2018 Molly. All rights reserved.
//


UIKIT_EXTERN NSNotificationName const ChildHomeScrollViewDidScrollNSNotification;
UIKIT_EXTERN NSNotificationName const ChildHomeScrollViewRefreshStateNSNotification;

NS_ASSUME_NONNULL_BEGIN

@interface HomeBaseViewController : BaseViewController <UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) BOOL isFirstViewLoaded;

@property (nonatomic, assign) CGFloat headerHeight;

@property (nonatomic, assign) NSInteger filterNumber;

@property (nonatomic, copy) void(^filterHaha)(void) ;

//tablefooterView点击
- (void)moreBtnClick;

- (void)refreshData;
@end

NS_ASSUME_NONNULL_END
