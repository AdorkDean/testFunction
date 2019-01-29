//
//  RzEventFilterView.h
//  qmp_ios
//
//  Created by molly on 2017/8/17.
//  Copyright © 2017年 Molly. All rights reserved.
//人物库筛选

#import <UIKit/UIKit.h>
@protocol PersonsFilterViewDelegate <NSObject>

- (void)updateFiltIndustryArr:(NSMutableArray *)selectedMArr withRoleMArr:(NSMutableArray *)roleMArr provinceMArr:(NSMutableArray *)provinceArr;

@optional
- (void)notUpdateRongziNews;
@end

@interface PersonsFilterView : UIView

@property (strong, nonatomic) UIView *rightView;
@property (weak, nonatomic) id<PersonsFilterViewDelegate> delegate;

+ (PersonsFilterView *)initWithFrame:(CGRect)frame withKey:(NSString *)countryKey;

@end
