//
//  QMPActivityCell.h
//  qmp_ios
//
//  Created by QMP on 2018/8/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityModel, QMPActivityCellModel;
@protocol QMPActivityCellDelegate, QMPActivityCellMethod;
@interface QMPActivityCell : UITableViewCell <QMPActivityCellMethod>
+ (instancetype)activityCellWithTableView:(UITableView *)tableView;

@property (nonatomic, weak) id<QMPActivityCellDelegate> delegate;
@property (nonatomic, strong) QMPActivityCellModel *cellModel;
@property (nonatomic, strong) QMPActivityCellModel *noteCellModel;

- (void)updateFollowStatusWithModel:(ActivityModel *)activity;
@end

@class ActivityRelateModel, ActivityLinkModel, ActivityModel, ActivityUserModel;
@interface QMPActivityCellRelateView : UIButton
@property (nonatomic, strong) ActivityRelateModel *relate;
@property (nonatomic, strong) UIImageView *followView;

@property (nonatomic, strong) UIImageView *deleteView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, assign) NSInteger otherType; ///< -1: 添加 -2: 完成
@end


@protocol QMPActivityCellDelegate <NSObject>
@optional
- (void)activityCell:(QMPActivityCell *)cell payCoin:(NSString *)coinNum;

- (void)activityCell:(QMPActivityCell *)cell rightButtonClickForActivity:(NSString *)activityID;

- (void)activityCell:(QMPActivityCell *)cell headerItemTap:(NSString *)theID type:(NSString *)type;

- (void)activityCell:(QMPActivityCell *)cell relateItemTap:(ActivityRelateModel *)item;
- (void)activityCell:(UITableViewCell<QMPActivityCellMethod> *)cell editRelateItemTap:(ActivityRelateModel *)item withCellModel:(QMPActivityCellModel *)cellModel;
- (void)activityCell:(UITableViewCell<QMPActivityCellMethod> *)cell confirmRelateItemTap:(ActivityRelateModel *)item withCellModel:(QMPActivityCellModel *)cellModel;
- (void)activityCell:(UITableViewCell<QMPActivityCellMethod> *)cell addRelateItemTap:(ActivityRelateModel *)item withCellModel:(QMPActivityCellModel *)cellModel;
- (void)activityCell:(UITableViewCell<QMPActivityCellMethod> *)cell deleteRelateItemTap:(ActivityRelateModel *)item withCellModel:(QMPActivityCellModel *)cellModel;



- (void)activityCell:(QMPActivityCell *)cell textExpandTap:(BOOL)currentExpandStatus;

- (void)activityCell:(QMPActivityCell *)cell textLinkTap:(ActivityLinkModel *)link;
- (void)activityCell:(QMPActivityCell *)cell detailLinkTap:(NSString *)link;

- (void)activityCell:(QMPActivityCell *)cell likeButtonClick:(ActivityModel *)activity;

- (void)activityCell:(QMPActivityCell *)cell payCoinButtonClick:(ActivityModel *)activity;
- (void)activityCell:(QMPActivityCell *)cell shareButtonClickForActivity:(ActivityModel *)activity;
- (void)activityCell:(QMPActivityCell *)cell commentButtonClickForActivity:(ActivityModel *)activity;


- (void)activityCell:(UITableViewCell *)cell rightButtonClick:(ActivityModel *)activity isDelete:(BOOL)isDelete;

- (void)activityCell:(QMPActivityCell *)cell followButtonClick:(ActivityModel *)activity;

- (void)activityCell:(QMPActivityCell *)cell headerViewTap:(ActivityRelateModel *)relateItem;
- (void)activityCell:(QMPActivityCell *)cell headerUserTap:(ActivityUserModel *)user;

- (void)activityCell:(UITableViewCell *)cell userTap:(ActivityUserModel *)user;
- (void)activityCell:(UITableViewCell *)cell moreButtonClick:(UIButton *)button withActivity:(ActivityModel *)activity;


- (void)activityCell:(id<QMPActivityCellMethod>)cell diggButtonClick:(ActivityModel *)activity;
- (void)activityCell:(UITableViewCell *)cell textExpandTap:(BOOL)currentExpandStatus withCellModel:(QMPActivityCellModel *)model;
@end


@interface QMPActivityCellAvatarView : UIImageView
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UIImageView *authIcon;

@end



@protocol QMPActivityCellMethod <NSObject>

@optional
- (void)updateCountWithModel:(ActivityModel *)activity;

@end
