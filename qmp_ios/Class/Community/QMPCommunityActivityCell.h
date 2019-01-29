//
//  QMPCommunityActivityCell.h
//  CommonLibrary
//
//  Created by QMP on 2019/1/9.
//  Copyright © 2019 WSS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMPActivityCellBarButton.h"

@class YYLabel, SLPhotosView, QMPActivityCellRelateView, QMPActivityCellModel, ActivityModel;
@protocol QMPActivityCellDelegate, QMPActivityCellMethod;
NS_ASSUME_NONNULL_BEGIN

@interface QMPCommunityActivityCell : UITableViewCell <QMPActivityCellMethod>

+ (instancetype)activityCellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *companyLabel;
@property (nonatomic, strong) UILabel *positonLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *idButton;
@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) YYLabel *contentLabel;

@property (nonatomic, strong) SLPhotosView *imagesView;

@property (nonatomic, strong) UIView *relatesView;
@property (nonatomic, strong) QMPActivityCellRelateView *editView;
@property (nonatomic, strong) QMPActivityCellRelateView *addRelateView;
@property (nonatomic, strong) QMPActivityCellRelateView *confirmRelateView;

@property (nonatomic, strong) QMPActivityCellBarButton *diggButton;
@property (nonatomic, strong) QMPActivityCellBarButton *commentButton;
@property (nonatomic, strong) UIButton *shareButton;

@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic, strong) UIImageView *lineView;


@property (nonatomic, strong) QMPActivityCellModel *cellModel;
@property (nonatomic, weak) id<QMPActivityCellDelegate> delegate;
@end




@protocol QMPActivityCellMenuViewDelegate <NSObject>
@optional
- (void)activityCellMenuViewCollectButtonClick;
- (void)activityCellMenuViewReportButtonClick;
@end
@interface QMPActivityCellMenuView : UIView
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIButton *collectButton;
@property (nonatomic, strong) UIButton *reportButton;

@property (nonatomic, strong) ActivityModel *activity;
@property (nonatomic, weak) id<QMPActivityCellMenuViewDelegate> delegate;
@end



NS_ASSUME_NONNULL_END
