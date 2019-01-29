//
//  ActivityCollectionCell.m
//  qmp_ios
//
//  Created by QMP on 2018/7/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ActivityCollectionCell.h"
#import <YYText.h>
#import "ActivityLayout.h"
#import "ActivityModel.h"
#import "NSDate+HY.h"
#import "NewsWebViewController.h"

CGFloat const ActivityCollectionCellHeight = 94.0;

@implementation ActivityCollectionHeaderView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.nameLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.timeLabel];
    }
    return self;
}
- (void)setLayout:(ActivityLayout *)layout {
    _layout = layout;
    
    self.timeLabel.text = [NSDate formatDate:layout.activityModel.createTime];
    [self.timeLabel sizeToFit];
    self.timeLabel.left = layout.collectionCellSize.width - self.timeLabel.width-14;
    self.timeLabel.centerY = self.nameLabel.centerY;
    
    
    self.nameLabel.text = [layout.activityModel.user.name isEqualToString:@"机器人"]?@"":layout.activityModel.user.name;
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(self.timeLabel.left - 8 - self.nameLabel.width, 14, self.nameLabel.width, 16);
    self.nameLabel.textColor = H9COLOR;
    
    if ([layout.activityModel.user.type isEqualToString:@"2"]) {
        self.descLabel.text = layout.activityModel.user.desc;
    } else {
        if (![PublicTool isNull:layout.activityModel.user.company] && !layout.activityModel.isAnonymous) {
            self.descLabel.text = layout.activityModel.user.company;
        } else {
            self.descLabel.text = @"";
        }
    }
    [self.descLabel sizeToFit];
    CGFloat w = SCREENW-32-self.timeLabel.width-self.nameLabel.width - 28 - 12;
    self.descLabel.frame = CGRectMake(self.nameLabel.right+4, 14, MIN(self.descLabel.width, w), 16);
    
}

- (void)nameLabelTap{
    if (self.clickHeader) {
        self.clickHeader();
    }
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(14, 14, 160, 16);
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = BLUE_TITLE_COLOR;
        _nameLabel.userInteractionEnabled = YES;
//        [_nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(nameLabelTap)]];
    }
    return _nameLabel;
}
- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.frame = CGRectMake(self.nameLabel.right, 14, 160, 16);
        _descLabel.font = [UIFont systemFontOfSize:13];
        _descLabel.textColor = H9COLOR;
    }
    return _descLabel;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.frame = CGRectMake(0, 0, 200, 12);
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = H9COLOR;
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

@end



@interface ActivityCollectionCell ()
@property (nonatomic, strong) ActivityCollectionHeaderView *headerView;
@property (nonatomic, strong) YYLabel *contentLabel;

@property (nonatomic, strong) UIButton *companyButton;
@property (nonatomic, strong) UIImageView *companyIconView;
@property (nonatomic, strong) UILabel *companyNameLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end
@implementation ActivityCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentView.backgroundColor = TABLEVIEW_COLOR;
        self.contentView.layer.cornerRadius = 4.0;

//        [self.contentView addSubview:self.headerView];
        [self.contentView addSubview:self.contentLabel];
//        [self.contentView addSubview:self.companyButton];
//        [self.contentView addSubview:self.companyIconView];
//        [self.contentView addSubview:self.companyNameLabel];
//        [self.contentView addSubview:self.timeLabel];
//
        __weak typeof(self) weakSelf = self;
        self.headerView.clickHeader = ^{
            if (weakSelf.clickHeaderEvent) {
                weakSelf.clickHeaderEvent();
            }
        };
    }
    return self;
}

- (void)setLayout:(ActivityLayout *)layout {
    _layout = layout;
    
//   
//    self.headerView.hidden = YES;
//    self.companyIconView.hidden = YES;
//    self.companyNameLabel.hidden = YES;
//    self.timeLabel.hidden = YES;
    
    CGFloat top = 14;
    CGFloat left = 14;
    if (layout.type == ActivityLayoutTypePerson) {

    } else if (layout.type == ActivityLayoutTypeCompany) {
//        top = 39;

    }
    
    self.contentLabel.frame = CGRectMake(left, top, layout.collectionCellSize.width-left*2, layout.textLayout.textBoundingSize.height);
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:layout.textLayout.text];

    if (layout.linkRange.length > 0) {
        [attr yy_setTextHighlightRange:layout.linkRange color:BLUE_TITLE_COLOR backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            QMPLog(@"点击链接");
           NSString *url = layout.activityModel.linkInfo.linkUrl;
            URLModel *model = [[URLModel alloc] init];
            model.url = url;
            NewsWebViewController *vc = [[NewsWebViewController alloc] init];
            vc.urlModel = model;
            if (layout.activityModel.relateProducts.count > 0) {
                ActivityRelateModel *relate = [layout.activityModel.relateProducts firstObject];
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:relate.ticket forKey:@"ticket"];
                [dict setObject:relate.ticketID forKey:@"id"];
                vc.requestDic = dict;
            }
            [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
        }];
    }
    self.contentLabel.attributedText = attr;
    
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
- (ActivityCollectionHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ActivityCollectionHeaderView alloc] init];
        _headerView.frame = CGRectMake(0, 0, 366, 40);
    }
    return _headerView;
}
- (YYLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[YYLabel alloc] init];
        _contentLabel.frame = CGRectMake(9, 0, 240-18, 99);
        _contentLabel.numberOfLines = 3;
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.textAlignment = NSTextAlignmentJustified;
    }
    return _contentLabel;
}
- (UIButton *)companyButton {
    if (!_companyButton) {
        _companyButton = [[UIButton alloc] init];
    }
    return _companyButton;
}

- (UIImageView *)companyIconView {
    if (!_companyIconView) {
        _companyIconView = [[UIImageView alloc] init];
        _companyIconView.frame = CGRectMake(14, 65, 15, 15);
        _companyIconView.layer.cornerRadius = 2.0;
        _companyIconView.clipsToBounds = YES;
        _companyIconView.layer.borderWidth = 0.5;
        _companyIconView.layer.borderColor = [BORDER_LINE_COLOR CGColor];
    }
    return _companyIconView;
}
- (UILabel *)companyNameLabel {
    if (!_companyNameLabel) {
        _companyNameLabel = [[UILabel alloc] init];
        _companyNameLabel.frame = CGRectMake(33, 65, 240, 15);
        _companyNameLabel.font = [UIFont systemFontOfSize:13];
        _companyNameLabel.textColor = COLOR737782;
    }
    return _companyNameLabel;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.frame = CGRectMake(0, 0, 200, 10);
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = H9COLOR;
    }
    return _timeLabel;
}
@end
