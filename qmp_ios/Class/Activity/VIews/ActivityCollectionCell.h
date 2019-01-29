//
//  ActivityCollectionCell.h
//  qmp_ios
//
//  Created by QMP on 2018/7/3.
//  Copyright © 2018年 Molly. All rights reserved.
//


#import <UIKit/UIKit.h>

extern CGFloat const ActivityCollectionCellHeight;
@class ActivityLayout;
@interface ActivityCollectionHeaderView : UIView
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) ActivityLayout *layout;

@property (copy, nonatomic) void(^clickHeader)(void);

@end

@interface ActivityCollectionCell : UICollectionViewCell
@property (nonatomic, strong) ActivityLayout *layout;
@property (copy, nonatomic) void(^clickHeaderEvent)(void);

@end
