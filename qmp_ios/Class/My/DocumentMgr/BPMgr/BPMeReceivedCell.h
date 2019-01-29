//
//  BPMeReceivedCell.h
//  qmp_ios
//
//  Created by QMP on 2018/4/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ReportModel;
#define kBPMeReceivedCellHeight 80.0
@protocol BPMeReceivedCellDelegate;

@interface BPMeReceivedCell : UITableViewCell

@property (nonatomic, strong) UIImageView   *projectAvatarView;
@property (nonatomic, strong) UILabel       *projectNameLabel;
@property (nonatomic, strong) UILabel       *projectYeWuLabel;
@property (nonatomic, strong) UILabel       *projectHangyeLabel;
@property (nonatomic, strong) UIButton      *lookBPButton;
@property (nonatomic, strong) UIButton      *contactButton;
@property (nonatomic, strong) UIButton      *bandProjectButton;
@property (nonatomic, strong) UILabel       *sourceUserLabel;
@property (nonatomic, strong) UILabel       *timeLabel;
@property (nonatomic, strong) UIButton      *favorButton;
@property (nonatomic, strong) UIImageView   *lineView;
@property (nonatomic, strong) UIView        *optionalView;
@property (nonatomic, strong) UIView        *redPoint;

@property (nonatomic, strong) ReportModel   *model;
@property (nonatomic, weak) id<BPMeReceivedCellDelegate> delegate;

@end


@protocol BPMeReceivedCellDelegate <NSObject>
@optional
- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell lookBPButtonClick:(UIButton *)button;
- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell projectButtonClick:(NSString *)project;
- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell caontactButtonClick:(NSString *)phone;
- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell favorButtonClick:(UIButton *)button;
- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell sourceUserClick:(ReportModel *)model;
- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell refreshTableView:(ReportModel *)model;
- (void)bpMeReceivedCell:(BPMeReceivedCell *)cell editBPButtonClick:(UIButton *)button;

@end
