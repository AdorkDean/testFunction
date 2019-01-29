//
//  RzEventFilterView.h
//  qmp_ios
//
//  Created by molly on 2017/8/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RzEventFilterViewDelegate <NSObject>

- (void)updateRongziNews:(NSMutableArray *)selectedMArr withEventMArr:(NSMutableArray *)eventMArr lunciMArr:(NSMutableArray *)lunciArr;

@optional
- (void)notUpdateRongziNews;
@end

@interface RzEventFilterView : UIView

@property (strong, nonatomic) UIView *rightView;
@property (weak, nonatomic) id<RzEventFilterViewDelegate> delegate;

+ (RzEventFilterView *)initWithFrame:(CGRect)frame withKey:(NSString *)countryKey;

@end
