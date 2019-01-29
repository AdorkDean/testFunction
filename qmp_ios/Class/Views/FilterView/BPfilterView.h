//
//  BPfilterView.h
//  qmp_ios
//
//  Created by QMP on 2018/4/11.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BPfilterViewDelegate <NSObject>

- (void)updateWithFirstArr:(NSMutableArray *)lingyuArr secondArr:(NSMutableArray *)provinceArr flagArr:(NSMutableArray *)flagArr;

@optional
- (void)notUpdateRongziNews;

@end

@interface BPfilterView : UIView

@property (strong, nonatomic) UIView *rightView;
@property (weak, nonatomic) id<BPfilterViewDelegate> delegate;

+ (BPfilterView *)initWithFrame:(CGRect)frame withKey:(NSString *)tableKey;
@end
