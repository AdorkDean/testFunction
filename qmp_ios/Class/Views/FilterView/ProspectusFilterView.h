//
//  ProspectusFilterView.h
//  qmp_ios
//
//  Created by QMP on 2018/1/8.
//  Copyright © 2018年 Molly. All rights reserved.
//招股书

#import <UIKit/UIKit.h>
@protocol ProspectusFilterViewDelegate <NSObject>

- (void)updateRongziNews:(NSMutableArray *)selectedMArr withBanKuaiMArr:(NSMutableArray *)banKuaiMArr timeMArr:(NSMutableArray*)timeMArr;

@optional
- (void)notUpdateRongziNews;
@end

@interface ProspectusFilterView : UIView

@property (strong, nonatomic) UIView *rightView;
@property (weak, nonatomic) id<ProspectusFilterViewDelegate> delegate;

+ (ProspectusFilterView *)initWithFrame:(CGRect)frame withKey:(NSString *)countryKey;

@end


