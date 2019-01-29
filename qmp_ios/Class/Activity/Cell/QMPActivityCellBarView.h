//
//  QMPActivityCellBarView.h
//  qmp_ios
//
//  Created by QMP on 2018/9/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMPActivityCellBarView, QMPActivityCellModel, ActivityModel;
@protocol QMPActivityCellBarViewDelegate <NSObject>
@optional
- (void)activityBar:(QMPActivityCellBarView *)barView likeButtonClick:(UIButton *)button;
- (void)activityBar:(QMPActivityCellBarView *)barView coinButtonClick:(UIButton *)button;
- (void)activityBar:(QMPActivityCellBarView *)barView commentButtonClick:(UIButton *)button;
- (void)activityBar:(QMPActivityCellBarView *)barView shareButtonClick:(UIButton *)button;
@end
@interface QMPActivityCellBarView : UIView
@property (nonatomic, weak) id<QMPActivityCellBarViewDelegate> delegate;

- (void)updateCountWithCellModel:(QMPActivityCellModel *)cellModel;
- (void)updateCountWithModel:(ActivityModel *)activity;
@end
