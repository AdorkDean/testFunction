//
//  QMPActivityCellBarView.m
//  qmp_ios
//
//  Created by QMP on 2018/9/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPActivityCellBarView.h"
#import "QMPActivityCellModel.h"
#import "ActivityModel.h"
const CGFloat ActionBarHeight = 48;
@interface QMPActivityCellBarView ()
@property (nonatomic, strong) UIImageView *lineView;
@property (nonatomic, strong) UIButton *coinButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *shareButton;

@end
@implementation QMPActivityCellBarView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.coinButton];
        [self addSubview:self.commentButton];
        [self addSubview:self.shareButton];
        [self addSubview:self.lineView];
    }
    return self;
}

- (void)updateCountWithCellModel:(QMPActivityCellModel *)cellModel {
    ActivityModel *activity = cellModel.activity;
    self.coinButton.selected = activity.isDigged;
    [self.coinButton setTitle:[self fixCountShow:activity.diggCount]?:@"点赞" forState:UIControlStateNormal];
    [self.commentButton setTitle:[self fixCountShow:activity.commentCount]?:@"评论" forState:UIControlStateNormal];
}
- (void)updateCountWithModel:(ActivityModel *)activity {
    self.coinButton.selected = activity.isDigged;
    [self.coinButton setTitle:[self fixCountShow:activity.diggCount]?:@"点赞" forState:UIControlStateNormal];
    [self.commentButton setTitle:[self fixCountShow:activity.commentCount]?:@"评论" forState:UIControlStateNormal];
}
- (NSString *)fixCountShow:(NSInteger)count {
    if (count <= 0) {
        return nil;
    } else if (count < 1000) {
        return [NSString stringWithFormat:@"%zd", count];
    } else if (count < 10000) {
        return [NSString stringWithFormat:@"%.1fk", count / 1000.0];
    } else if (count < 100000) {
        return [NSString stringWithFormat:@"%zdk", count / 1000];
    } else {
        return @"99k+";
    }
}
#pragma mark - Event
- (void)coinButtonClick:(UIButton *)button {
    [QMPEvent event:@"tab_activity_coinclick"];
    if ([self.delegate respondsToSelector:@selector(activityBar:likeButtonClick:)]) {
        [self.delegate activityBar:self likeButtonClick:button];
    }
}
- (void)commentButtonClick:(UIButton *)button {
    [QMPEvent event:@"tab_activity_commentlick"];
    if ([self.delegate respondsToSelector:@selector(activityBar:commentButtonClick:)]) {
        [self.delegate activityBar:self commentButtonClick:button];
    }
}
- (void)shareButtonClick:(UIButton *)button {
    [QMPEvent event:@"tab_activity_shareclick"];
    if ([self.delegate respondsToSelector:@selector(activityBar:shareButtonClick:)]) {
        [self.delegate activityBar:self shareButtonClick:button];
    }
}
#pragma mark - Getter
- (UIButton *)coinButton {
    if (!_coinButton) {
        _coinButton = [[UIButton alloc] init];
        _coinButton.frame = CGRectMake(0, 0, 105, ActionBarHeight);
        _coinButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_coinButton setTitle:@"点赞" forState:UIControlStateNormal];
        _coinButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _coinButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        _coinButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
        [_coinButton setTitleColor:H9COLOR forState:UIControlStateNormal];
        [_coinButton setTitleColor:HTColorFromRGB(0x006EDA) forState:UIControlStateSelected];
        [_coinButton setImage:[BundleTool imageNamed:@"activity_cell_digg"] forState:UIControlStateNormal];
        [_coinButton setImage:[BundleTool imageNamed:@"activity_cell_diggb"] forState:UIControlStateSelected];
        [_coinButton addTarget:self action:@selector(coinButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coinButton;
}

- (UIButton *)commentButton {
    if (!_commentButton) {
        _commentButton = [[UIButton alloc] init];
        _commentButton.frame = CGRectMake(SCREENW/3.0, 0, SCREENW/3.0, ActionBarHeight);
        _commentButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _commentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _commentButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        _commentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
        [_commentButton setTitle:@"评论" forState:UIControlStateNormal];
        [_commentButton setTitleColor:H9COLOR forState:UIControlStateNormal];
        [_commentButton setImage:[BundleTool imageNamed:@"activity_cell_comment"] forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(commentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentButton;
}
- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [[UIButton alloc] init];
        _shareButton.frame = CGRectMake(SCREENW-105, 0, 105, ActionBarHeight);
        _shareButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _shareButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _shareButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        _shareButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
        [_shareButton setTitle:@"分享" forState:UIControlStateNormal];
        [_shareButton setTitleColor:H9COLOR forState:UIControlStateNormal];
        [_shareButton setImage:[BundleTool imageNamed:@"activity_cell_share"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}
- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] init];
        _lineView.frame = CGRectMake(0, 0, SCREENW, 1);
        _lineView.backgroundColor = TABLEVIEW_COLOR;
    }
    return _lineView;
}
@end
