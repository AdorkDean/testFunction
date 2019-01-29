//
//  InvestementFilterView.h
//  qmp_ios
//
//  Created by Molly on 2016/12/1.
//  Copyright © 2016年 Molly. All rights reserved.
//投资案例 的筛选 不存储筛选条件

#import <UIKit/UIKit.h>

@protocol InvestementFilterViewDelegate <NSObject>

- (void)updateRongziNews:(NSMutableArray *)selectedMArr lunciArr:(NSMutableArray*)selectedLunciMArr;

@end

@interface InvestementFilterView : UIView

@property (strong, nonatomic) UIView *rightView;
@property (weak, nonatomic) id<InvestementFilterViewDelegate> delegate;
@property (strong, nonatomic) NSString *action;

+ (InvestementFilterView *)initWithFrame:(CGRect)frame withSelectMArr:(NSMutableArray *)selectMArr withHangyeArr:(NSArray *)hangyeArr;

+ (InvestementFilterView *)initWithFrame:(CGRect)frame withSelectMArr:(NSMutableArray *)selectMArr withHangyeArr:(NSArray *)hangyeArr withSelectLunciMArr:(NSMutableArray*)selectLunciMArr withLunciArr:(NSArray*)lunciArr;


+ (InvestementFilterView *)initWithFrame:(CGRect)frame withSelectMArr:(NSMutableArray *)selectMArr withRequestDict:(NSMutableDictionary *)dict;
@end
