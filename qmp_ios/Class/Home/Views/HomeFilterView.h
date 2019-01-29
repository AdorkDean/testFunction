//
//  HomeFilterView.h
//  qmp_ios
//
//  Created by QMP on 2018/5/15.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HomeFilterViewDelegate;

#define kHomeFilterViewMaxHeight (SCREENH*0.72)
@interface HomeFilterView : UIView
@property (nonatomic, strong) NSMutableArray *filterData;
@property(nonatomic,assign,getter=isShow)BOOL show;
- (void)show;
- (void)hide;
- (void)hideWithNoConfirm;
- (void)hideWithNoConfirmAnimate:(BOOL)animate;
- (void)reload;
- (void)scrollToSection:(NSInteger)section animated:(BOOL)animated;
- (void)scrollToSectionTitle:(NSString *)sectionTitle animated:(BOOL)animated;

@property (nonatomic, weak) id<HomeFilterViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *selectedData;
@property (nonatomic, strong) NSDictionary *lingyu2;
@property (nonatomic, assign) BOOL isHaveChildLingyu;

- (NSMutableArray *)arrWithTitle:(NSString *)sectionTitle;
@property (nonatomic, strong) NSMutableArray *sRoundData;
@property (nonatomic, strong) NSMutableArray *sLingyu1Data;
@property (nonatomic, strong) NSMutableArray *sLingyu2Data;
@property (nonatomic, strong) NSMutableArray *sLunciData;
@property (nonatomic, strong) NSMutableArray *sDiquData;
@property (nonatomic, strong) NSMutableArray *sLiangdianData;

@property (nonatomic, strong) NSMutableDictionary *oldSelectedDict;

@end





#define kHomeFilterHeaderViewHeight 44
@interface HomeFilterHeaderView : UIView
- (instancetype)initWithTitles:(NSArray *)titles;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, weak) id<HomeFilterViewDelegate> delegate;
@property (nonatomic, assign) BOOL filterViewIsShow;
@property (nonatomic, weak) UIButton *currentButton;

@property (nonatomic, strong) NSArray *oldTitles;
@end

@protocol HomeFilterViewDelegate <NSObject>
@optional
- (void)homeFilterHeaderView:(HomeFilterHeaderView *)headerView itemButtonClick:(UIButton *)button needRefresh:(BOOL)need;
- (void)homeFilterView:(HomeFilterView *)filterView cellClick:(NSString *)title section:(NSString *)section;
- (void)homeFilterView:(HomeFilterView *)filterView confirmButtonClick:(UIButton *)button;
- (void)hideHomeFilterView:(HomeFilterView *)filterView;
- (void)resetHomeFilterView:(HomeFilterView *)filterView;
- (void)hideNoConfirmHomeFilterView:(HomeFilterView *)filterView;
@end
