//
//  HomeHeaderView.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/6/22.
//  Copyright © 2018年 Molly. All rights reserved.
//  首页顶部

#import <UIKit/UIKit.h>
@class HomeHeaderView;

#define HomeHeaderViewBgHeight (kStatusBarHeight+47+45)

//extern const CGFloat HomeHeaderViewBgHeight; ///< 包含navbar的高度的
extern const CGFloat HomeHeaderMetaViewHeight;
extern const CGFloat HomeHeaderTitleViewHeight;
extern const CGFloat HomeHeaderMenuViewHeight;

@protocol HomeHeaderViewDelegate <NSObject>
@optional
- (void)homeHeaderView:(HomeHeaderView *)view didScroll:(CGFloat)y;
- (void)homeHeaderView:(HomeHeaderView *)view searchButtonClick:(UIButton *)button;
- (void)homeHeaderView:(HomeHeaderView *)view metaButtonClick:(UIButton *)button;
- (void)homeHeaderView:(HomeHeaderView *)view menuButtonClick:(UIButton *)button;
@end
@interface HomeHeaderView : UIView
@property (nonatomic, weak) id<HomeHeaderViewDelegate> delegate;
@property (nonatomic, strong) NSArray *metaConfig;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIScrollView *menuView;
@property (nonatomic, weak) UIView *titleView;

- (void)hideCreateTip;
@end


@interface HomeHeaderViewPageControl : UIPageControl

@end

@interface HomeHeaderViewProgress : UIView
@property (nonatomic, assign) CGFloat progress;
@end

