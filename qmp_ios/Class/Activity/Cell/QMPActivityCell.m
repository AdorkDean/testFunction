//
//  QMPActivityCell.m
//  qmp_ios
//
//  Created by QMP on 2018/8/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPActivityCell.h"
#import <YYText.h>
#import "SLPhotosView.h"
#import "ActivityModel.h"
#import <UIButton+WebCache.h>
#import "QMPActivityActionView.h"
#import "QMPActivityCellBarView.h"
#import "ActivityHtmlMedia.h"
#import "QMPCommunityActivityCell.h"
#import "QMPActivityCellModel.h"
#import "NSDate+HY.h"
#import "QMPActivityCellBarButton.h"

@interface QMPActivityCell () <QMPActivityCellBarViewDelegate>
@property (nonatomic, strong) QMPActivityCellAvatarView *avatarView;
@property (nonatomic, strong) UIImageView *authIcon;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) UIButton *idButton;

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

@property (nonatomic, strong) UIImageView *separatorView;
@end
@implementation QMPActivityCell

+ (instancetype)activityCellWithTableView:(UITableView *)tableView {
    QMPActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMPActivityCellID"];
    if (!cell) {
        cell = [[QMPActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QMPActivityCellID"];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        [self setupViews];
    }
    return self;
}

- (void)updateCountWithModel:(ActivityModel *)activity {
    [self setupBarButtonCount:activity];
}
- (void)updateFollowStatusWithModel:(ActivityModel *)activity {
    self.followButton.selected = activity.headerRelate.isFollowed;
}

- (void)setupViews {
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.authIcon];
    [self.contentView addSubview:self.followButton];
    [self.contentView addSubview:self.idButton];
    [self.contentView addSubview:self.deleteButton];

    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.imagesView];
    [self.contentView addSubview:self.relatesView];
    [self.relatesView addSubview:self.editView];
    [self.relatesView addSubview:self.addRelateView];
    [self.relatesView addSubview:self.confirmRelateView];
    
    [self.contentView addSubview:self.diggButton];
    [self.contentView addSubview:self.commentButton];
    [self.contentView addSubview:self.shareButton];
    
//    [self.contentView addSubview:self.moreButton];
    
    [self.contentView addSubview:self.separatorView];
}
#pragma mark - Setter

- (void)setNoteCellModel:(QMPActivityCellModel *)noteCellModel{
    
    ActivityModel *activity = noteCellModel.activity;
    
    ActivityUserModel *user = activity.user;
    self.nameLabel.text = user.name;
    self.avatarView.iconLabel.hidden = YES;
    self.descLabel.text = [NSDate formatDate:activity.createTime];
    
    if (![PublicTool isNull:user.avatar]) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:user.avatar]];
    } else {
        self.avatarView.iconLabel.text = [user.name substringToIndex:1];
        self.avatarView.iconLabel.hidden = NO;
        self.avatarView.image = [UIImage new];
        self.avatarView.iconLabel.backgroundColor = RANDOM_COLORARR[arc4random()%5];
    }
    self.diggButton.hidden = YES;
    self.shareButton.hidden = YES;
    self.commentButton.hidden = YES;
    self.followButton.hidden = YES;
    self.moreButton.hidden = YES;
    self.idButton.hidden = YES;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(53, 9, MIN(260, self.nameLabel.width), 20);
    
    [self.descLabel sizeToFit];
    self.descLabel.frame = CGRectMake(53, 30, MIN(260, self.descLabel.width), 15);

    self.contentLabel.height = noteCellModel.textHeight;

    __weak typeof(self) weakSelf = self;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:noteCellModel.textLayout.text];
    
    if (noteCellModel.needExpand) {
        [attr yy_setTextHighlightRange:NSMakeRange(attr.string.length-2, 2) color:BLUE_TITLE_COLOR backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            QMPLog(@"点击展开，收起");
            if ([weakSelf.delegate respondsToSelector:@selector(activityCell:textExpandTap:withCellModel:)]) {
                [weakSelf.delegate activityCell:weakSelf textExpandTap:noteCellModel.expanding withCellModel:noteCellModel];
            }
        }];
    }
    self.contentLabel.attributedText = attr;
    self.imagesView.hidden = YES;
    if (activity.images.count > 0) {
        self.imagesView.hidden = NO;
        self.imagesView.top = self.contentLabel.bottom + 13 - 4;
        self.imagesView.height = noteCellModel.imagesSize.height;
        self.imagesView.photoModels = activity.images;
    }
    
    self.relatesView.frame = CGRectMake(13, noteCellModel.cellHeight-42-noteCellModel.relatesSize.height,
                                        SCREENW-26, noteCellModel.relatesSize.height);

    NSInteger index = 0;
    for (QMPActivityCellRelateView *item in self.relatesView.subviews) {
        if (index >= noteCellModel.relateItemFrames.count) {
            item.hidden = YES;
            continue;
        }
        item.hidden = NO;
        ActivityRelateModel *relate = noteCellModel.displayRelates[index];
        item.relate = relate;
        item.deleteView.hidden = !activity.editing;
        NSValue *val = noteCellModel.relateItemFrames[index];
        item.frame = [val CGRectValue];
        index++;
    }
    
    self.editView.hidden = YES;
    self.addRelateView.hidden = YES;
    self.confirmRelateView.hidden = YES;
    self.moreButton.hidden = YES;
    
    self.separatorView.top = noteCellModel.cellHeight -25 - 1;    
}

- (void)setCellModel:(QMPActivityCellModel *)cellModel {
    if (!cellModel) {
        return;
    }
    _cellModel = cellModel;
   
    ActivityModel *activity = cellModel.activity;
    ActivityRelateModel *headerRelate = activity.headerRelate;
    
    
   
    self.avatarView.iconLabel.hidden = YES;
    if (![PublicTool isNull:headerRelate.image]) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:headerRelate.image]];
    } else {
        self.avatarView.iconLabel.text = [headerRelate.name substringToIndex:1];
        self.avatarView.iconLabel.hidden = NO;
        self.avatarView.image = [UIImage new];
        self.avatarView.iconLabel.backgroundColor = RANDOM_COLORARR[arc4random()%5];
    }
    
    if ([@[@"person", @"theme", @"user"] containsObject:headerRelate.type]) {
        self.avatarView.layer.cornerRadius = self.avatarView.width / 2.0;
        self.avatarView.contentMode = UIViewContentModeScaleToFill;
    } else {
        self.avatarView.layer.cornerRadius = 6;
        self.avatarView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    self.authIcon.hidden = YES;
    self.nameLabel.text = headerRelate.name;
//    self.nameLabel.attributedText = [[NSMutableAttributedString alloc]initWithString:headerRelate.name];
    if ([headerRelate.type isEqualToString:@"person"] || [headerRelate.type isEqualToString:@"user"]) {
        self.authIcon.frame = CGRectMake(self.avatarView.right - 10, self.avatarView.bottom - 11, 12, 12);
        if (headerRelate.isAuthor && ([headerRelate.claim_type integerValue] == 2) && !activity.isAnonymous) {
            self.authIcon.hidden = NO;
            self.authIcon.image = [BundleTool imageNamed:@"activity_person_claim"];
        }
        //不显示发布身份
//        NSString *name = headerRelate.name;
//        NSMutableAttributedString *attText;
//        if (headerRelate.isAuthor) {
//            if(cellModel.detail){
//                if (!activity.anonymous && ![PublicTool isNull:activity.company.company]) {
//                    name = [NSString stringWithFormat:@"%@(%@·%@)",headerRelate.name,activity.company.company,activity.company.position];
//                }else{
//                    if (activity.anonymous_degree.integerValue == 1 && ![PublicTool isNull:activity.company.role]) {
//                        name = [NSString stringWithFormat:@"%@(%@)",headerRelate.name,activity.company.role];
//                    }else if (activity.anonymous_degree.integerValue == 1 && ![PublicTool isNull:activity.company.role]) {
//                        name = [NSString stringWithFormat:@"%@(%@)",headerRelate.name,activity.company.company];
//                    }
//                }
//                attText = [[NSMutableAttributedString alloc]initWithString:name];
//                [attText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:H6COLOR} range:NSMakeRange(headerRelate.name.length, name.length-headerRelate.name.length)];
//                self.nameLabel.attributedText = attText;
//            }
//
//        }
    }
    
    self.descLabel.text = [NSDate formatDate:activity.createTime];
    self.idButton.hidden = YES;
    if (headerRelate.isAuthor && activity.isAnonymous) {
        self.idButton.hidden = NO;
    }
    
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(53, 18, MIN(260, self.nameLabel.width), 21);

    [self.descLabel sizeToFit];
    self.descLabel.frame = CGRectMake(14, cellModel.cellHeight-16-12, MIN(260, self.descLabel.width), 12);
    
    self.idButton.frame = CGRectMake(self.nameLabel.right+5,
                                     self.nameLabel.centerY-15+0.5,
                                     self.cellModel.showID?150:30, 30);
    
    if (self.cellModel.showID) {
        NSString *idStr = [NSString stringWithFormat:@"ID:%@", activity.user.usercode];
        [self.idButton setTitle:idStr forState:UIControlStateNormal];
        [self.idButton setImage:[UIImage new] forState:UIControlStateNormal];
    } else {
        [self.idButton setTitle:@"" forState:UIControlStateNormal];
        [self.idButton setImage:[BundleTool imageNamed:@"activity_cell_id"] forState:UIControlStateNormal];
    }
    
    if (self.cellModel.detail) {
        self.followButton.hidden = activity.isMine;
        self.followButton.selected = headerRelate.isFollowed;
    } else {
        self.followButton.hidden = YES;
    }
    
    self.deleteButton.hidden = !cellModel.needDelete;
    
    self.contentLabel.height = cellModel.textHeight;
    //
    __weak typeof(self) weakSelf = self;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:cellModel.textLayout.text];
    
    for (ActivityHtmlMediaItem *media in activity.htmlMedia.mediaItems) {
        NSRange range = media.range;
        
        if (![PublicTool isNull:activity.linkInfo.linkUrl]) {
            NSInteger loc = attr.length - activity.linkInfo.linkTitle.length;
            if (range.location >= loc) {
                continue;
            }
        }
        
        [attr yy_setTextHighlightRange:range color:BLUE_TITLE_COLOR backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            if ([weakSelf.delegate respondsToSelector:@selector(activityCell:detailLinkTap:)]) {
                [weakSelf.delegate activityCell:weakSelf detailLinkTap:media.href];
            }
        }];
        
    }
    
    if (cellModel.linkHighlightRange.length > 0 && (!cellModel.needExpand || cellModel.expanding)) {
        [attr yy_setTextHighlightRange:cellModel.linkHighlightRange color:BLUE_TITLE_COLOR backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            QMPLog(@"点击链接");
            if ([weakSelf.delegate respondsToSelector:@selector(activityCell:textLinkTap:)]) {
                [weakSelf.delegate activityCell:weakSelf textLinkTap:activity.linkInfo];
            }
        }];
    }
    
    if (cellModel.needExpand) {
        [attr yy_setTextHighlightRange:NSMakeRange(attr.string.length-2, 2) color:BLUE_TITLE_COLOR backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            QMPLog(@"点击展开，收起");
            if ([weakSelf.delegate respondsToSelector:@selector(activityCell:textExpandTap:withCellModel:)]) {
                [weakSelf.delegate activityCell:weakSelf textExpandTap:cellModel.expanding withCellModel:cellModel];
            }
        }];
    }
    self.contentLabel.attributedText = attr;
    
    
    self.imagesView.hidden = YES;
    if (activity.images.count > 0) {
        self.imagesView.hidden = NO;
        self.imagesView.top = self.contentLabel.bottom + 13 - 4;
        self.imagesView.height = cellModel.imagesSize.height;
        self.imagesView.photoModels = activity.images;
    }
    
    
    self.relatesView.frame = CGRectMake(13, cellModel.cellHeight-42-cellModel.relatesSize.height,
                                        SCREENW-26, cellModel.relatesSize.height);
    NSInteger index = 0;
    for (QMPActivityCellRelateView *item in self.relatesView.subviews) {
        if (index >= cellModel.relateItemFrames.count) {
            item.hidden = YES;
            continue;
        }
        item.hidden = NO;
        ActivityRelateModel *relate = cellModel.displayRelates[index];
        item.relate = relate;
        item.deleteView.hidden = !activity.editing;
        NSValue *val = cellModel.relateItemFrames[index];
        item.frame = [val CGRectValue];
        index++;
    }

    self.editView.hidden = YES;
    self.addRelateView.hidden = YES;
    self.confirmRelateView.hidden = YES;
    if (activity.isMine && activity.showEdit) {
        if (!activity.editing) {
            self.editView.hidden = NO;
            self.editView.frame = cellModel.editRelateFrame;
            ActivityRelateModel *relate = [ActivityRelateModel new];
            relate.name = @"编辑";
            relate.qmpIcon = @"activity_edit";
            self.editView.relate = relate;
        } else {
            self.addRelateView.hidden = NO;
            self.confirmRelateView.hidden = NO;
            
            self.addRelateView.frame = cellModel.editRelateFrame;
            ActivityRelateModel *relate = [ActivityRelateModel new];
            relate.name = @"添加";
            relate.qmpIcon = @"activity_add";
            self.addRelateView.relate = relate;
            
            self.confirmRelateView.frame = cellModel.editRelateFrame2;
            ActivityRelateModel *relate2 = [ActivityRelateModel new];
            relate2.name = @"完成";
            self.confirmRelateView.relate = relate2;
        }
    }
    
    CGFloat barButtonTop = cellModel.cellHeight - 37 - 4;
    self.diggButton.top = barButtonTop;
    self.commentButton.top = barButtonTop;
    self.shareButton.top = barButtonTop;
    self.moreButton.top = barButtonTop;
    [self setupBarButtonCount:activity];
    self.moreButton.hidden = cellModel.detail;
    
    self.separatorView.top = cellModel.cellHeight - 1;
}
- (void)setupBarButtonCount:(ActivityModel *)activity {
    self.diggButton.selected = activity.isDigged;
    [self.diggButton setTitle:[self fixCountShow:activity.diggCount] forState:UIControlStateNormal];
    [self.commentButton setTitle:[self fixCountShow:activity.commentCount] forState:UIControlStateNormal];
    if (self.cellModel.detail) {
        self.followButton.hidden = activity.isMine;
        self.followButton.selected = activity.headerRelate.isFollowed;
    }
}

- (NSString *)fixCountShow:(NSInteger)count {
    if (count <= 0) {
        return @"";
    } else if (count < 10000) {
        return [NSString stringWithFormat:@"%zd", count];
    } else {
        return [NSString stringWithFormat:@"%zd万", count / 10000];
    }
}
#pragma mark - Event
- (void)headerViewTap {
    ActivityRelateModel *item = self.cellModel.activity.headerRelate;
    if (self.cellModel.activity.isAnonymous && item.isAuthor) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(activityCell:relateItemTap:)]) {
        [self.delegate activityCell:nil relateItemTap:item];
    }
}
- (void)idButtonClick:(UIButton *)button {
    self.cellModel.showID = !self.cellModel.showID;
    if (self.cellModel.showID) {
        NSString *idStr = [NSString stringWithFormat:@"ID:%@", self.cellModel.activity.user.usercode];
        [button setTitle:idStr forState:UIControlStateNormal];
        [button setImage:[UIImage new] forState:UIControlStateNormal];
        button.width = 150;
    } else {
        [button setTitle:@"" forState:UIControlStateNormal];
        [button setImage:[BundleTool imageNamed:@"activity_cell_id"] forState:UIControlStateNormal];
        button.width = 30;
    }
}
- (void)textLongPress {
    [UIPasteboard generalPasteboard].string = self.cellModel.activity.content;
    [PublicTool showMsg:@"复制成功"];
}
- (void)relateViewTap:(UITapGestureRecognizer *)relateTap {
    NSInteger index = relateTap.view.tag;
    ActivityRelateModel *item = self.cellModel.displayRelates[index];
    if (self.cellModel.activity.editing) {
        if ([self.delegate respondsToSelector:@selector(activityCell:deleteRelateItemTap:withCellModel:)]) {
            [self.delegate activityCell:self deleteRelateItemTap:item withCellModel:self.cellModel];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(activityCell:relateItemTap:)]) {
            [self.delegate activityCell:self relateItemTap:item];
        }
    }
}
- (void)editRelateViewTap {
    if ([self.delegate respondsToSelector:@selector(activityCell:editRelateItemTap:withCellModel:)]) {
        [self.delegate activityCell:self editRelateItemTap:nil withCellModel:self.cellModel];
    }
}
- (void)addRelateViewTap {
    if (self.cellModel.activity.relates.count > 5) {
        [PublicTool showMsg:@"最多关联5个对象"];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(activityCell:addRelateItemTap:withCellModel:)]) {
        [self.delegate activityCell:self addRelateItemTap:nil withCellModel:self.cellModel];
    }
}
- (void)confirmRelateViewTap {
    if ([self.delegate respondsToSelector:@selector(activityCell:confirmRelateItemTap:withCellModel:)]) {
        [self.delegate activityCell:self confirmRelateItemTap:nil withCellModel:self.cellModel];
    }
}
- (void)diggButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(activityCell:diggButtonClick:)]) {
        [self.delegate activityCell:self diggButtonClick:self.cellModel.activity];
    }
}
- (void)commentButtonClick:(UIButton *)button {
    if (self.cellModel.detail) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(activityCell:commentButtonClickForActivity:)]) {
        [self.delegate activityCell:nil commentButtonClickForActivity:self.cellModel.activity];
    }
}
- (void)shareButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(activityCell:shareButtonClickForActivity:)]) {
        [self.delegate activityCell:nil shareButtonClickForActivity:self.cellModel.activity];
    }
}
- (void)moreButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(activityCell:moreButtonClick:withActivity:)]) {
        [self.delegate activityCell:self moreButtonClick:button withActivity:self.cellModel.activity];
    }
}
- (void)followButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(activityCell:followButtonClick:)]) {
        [self.delegate activityCell:self followButtonClick:self.cellModel.activity];
    }
}
- (void)deleteButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(activityCell:rightButtonClick:isDelete:)]) {
        [self.delegate activityCell:self rightButtonClick:self.cellModel.activity isDelete:YES];
    }
}

#pragma mark - Getter
- (QMPActivityCellAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[QMPActivityCellAvatarView alloc] init];
        _avatarView.frame = CGRectMake(13, 13, 32, 32);
        _avatarView.layer.cornerRadius = 16;
        _avatarView.layer.borderWidth = 0.5;
        _avatarView.layer.borderColor = [BORDER_LINE_COLOR CGColor];
        _avatarView.clipsToBounds = YES;
        _avatarView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTap)];
        [_avatarView addGestureRecognizer:tapGest];
    }
    return _avatarView;
}

- (UIImageView *)authIcon {
    if (!_authIcon) {
        _authIcon = [[UIImageView alloc] init];
        _authIcon.frame = CGRectMake(0, 0, 0, 0);
        CGFloat w = 15;
        _authIcon.frame = CGRectMake(self.avatarView.right-w, self.avatarView.bottom-w, w, w);
    }
    return _authIcon;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(53, 13, 0, 20);
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.textColor = H3COLOR;
        _nameLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTap)];
        [_nameLabel addGestureRecognizer:tapGest];
    }
    return _nameLabel;
}
- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.frame = CGRectMake(56, self.nameLabel.bottom + 2, 260, 16);
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.textColor = HTColorFromRGB(0x999999);
//        _descLabel.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTap)];
//        [_descLabel addGestureRecognizer:tapGest];
    }
    return _descLabel;
}
- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [[UIButton alloc] init];
        _followButton.frame = CGRectMake(SCREENW-57-12, 15, 57, 24);
        _followButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _followButton.layer.cornerRadius = 12;
        _followButton.layer.masksToBounds = YES;
        _followButton.layer.borderColor = [HTColorFromRGB(0xEEEEEE) CGColor];
        _followButton.layer.borderWidth = 1;
        
        [_followButton setTitle:@"关注" forState:UIControlStateNormal];
        [_followButton setTitle:@"已关注" forState:UIControlStateSelected];
        [_followButton setTitleColor:H999999 forState:UIControlStateNormal];
        [_followButton setTitleColor:H999999 forState:UIControlStateSelected];
        [_followButton setImage:[BundleTool imageNamed:@"activity_cell_follow"] forState:UIControlStateNormal];
        [_followButton setImage:[UIImage new] forState:UIControlStateSelected];
        [_followButton addTarget:self action:@selector(followButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _followButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        
    }
    return _followButton;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] init];
        _deleteButton.frame = CGRectMake(SCREENW-57-13, 15, 57, 24);
        [_deleteButton setImage:[BundleTool imageNamed:@"activity_delete"] forState:UIControlStateNormal];
        [_deleteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];

        [_deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.hidden = YES;
    }
    return _deleteButton;
}
- (YYLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[YYLabel alloc] init];
        _contentLabel.frame = CGRectMake(13, 57, SCREENW-26, 0);
        _contentLabel.numberOfLines = 0;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(textLongPress)];
        [_contentLabel addGestureRecognizer:longPress];
    }
    return _contentLabel;
}
- (SLPhotosView *)imagesView {
    if (!_imagesView) {
        _imagesView = [[SLPhotosView alloc] init];
        _imagesView.frame = CGRectMake(13, 0, SCREENW-26, 0);
    }
    return _imagesView;
}

- (UIView *)relatesView {
    if (!_relatesView) {
        _relatesView = [[UIView alloc] init];
        _relatesView.frame = CGRectMake(13, 0, SCREENW-26, 0);
        
        for (int i = 0; i < 10; i++) {
            QMPActivityCellRelateView *item = [[QMPActivityCellRelateView alloc] init];
            item.tag = i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(relateViewTap:)];
            [item addGestureRecognizer:tap];
            [_relatesView addSubview:item];
        }
        
    }
    return _relatesView;
}
- (QMPActivityCellRelateView *)editView {
    if (!_editView) {
        _editView = [[QMPActivityCellRelateView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editRelateViewTap)];
        [_editView addGestureRecognizer:tap];
        _editView.otherType = -3;
    }
    return _editView;
}
- (QMPActivityCellRelateView *)addRelateView {
    if (!_addRelateView) {
        _addRelateView = [[QMPActivityCellRelateView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addRelateViewTap)];
        [_addRelateView addGestureRecognizer:tap];
        _addRelateView.otherType = -1;
    }
    return _addRelateView;
}
- (QMPActivityCellRelateView *)confirmRelateView {
    if (!_confirmRelateView) {
        _confirmRelateView = [[QMPActivityCellRelateView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(confirmRelateViewTap)];
        [_confirmRelateView addGestureRecognizer:tap];
        _confirmRelateView.otherType = -2;
    }
    return _confirmRelateView;
}

- (UIImageView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIImageView alloc] init];
        _separatorView.frame = CGRectMake(0, 0, SCREENW, 1);
        _separatorView.backgroundColor = HTColorFromRGB(0xEEEEEE);
    }
    return _separatorView;
}
- (UIButton *)idButton {
    if (!_idButton) {
        _idButton = [[UIButton alloc] init];
        _idButton.frame = CGRectMake(0, 0, 31, 31);
        _idButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_idButton setTitleColor:H9COLOR forState:UIControlStateNormal];
        [_idButton setImage:[BundleTool imageNamed:@"activity_cell_id"] forState:UIControlStateNormal];
        _idButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_idButton addTarget:self action:@selector(idButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _idButton;
}
- (QMPActivityCellBarButton *)diggButton {
    if (!_diggButton) {
        _diggButton = [[QMPActivityCellBarButton alloc] init];
        _diggButton.frame = CGRectMake(SCREENW-170, 0,50, 37);
        _diggButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_diggButton setTitle:@" " forState:UIControlStateNormal];
        [_diggButton setTitleColor:H999999 forState:UIControlStateNormal];
        [_diggButton setImage:[BundleTool imageNamed:@"activity_cell_digg"] forState:UIControlStateNormal];
        [_diggButton setImage:[BundleTool imageNamed:@"activity_cell_diggb"] forState:UIControlStateSelected];
        [_diggButton addTarget:self action:@selector(diggButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _diggButton;
}

- (QMPActivityCellBarButton *)commentButton {
    if (!_commentButton) {
        _commentButton = [[QMPActivityCellBarButton alloc] init];
        _commentButton.frame = CGRectMake(SCREENW-100, 0, 50, 37);
        [_commentButton setTitle:@" " forState:UIControlStateNormal];
        _commentButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_commentButton setTitleColor:H999999 forState:UIControlStateNormal];
        [_commentButton setImage:[BundleTool imageNamed:@"activity_cell_comment"] forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(commentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [[UIButton alloc] init];
        _shareButton.frame = CGRectMake(SCREENW-40-14, 0, 54, 37);
        _shareButton.titleLabel.font = [UIFont systemFontOfSize:8];
        [_shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_shareButton setImageEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
        [_shareButton setImage:[BundleTool imageNamed:@"activity_cell_share"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}
- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [[UIButton alloc] init];
        _moreButton.frame = CGRectMake(SCREENW - 35, 0, 35, 37);
        _moreButton.backgroundColor = [UIColor whiteColor];
        _moreButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        [_moreButton setImage:[BundleTool imageNamed:@"activity_cell_more2"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}
@end







@interface QMPActivityCellRelateView ()
@end

@implementation QMPActivityCellRelateView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        [self setTitleColor:H6COLOR forState:UIControlStateNormal];
        self.backgroundColor = HTColorFromRGB(0xF5F5F5);
        [self addSubview:self.followView];
        [self addSubview:self.deleteView];
        [self addSubview:self.nameLabel];
    }
    return self;
}
- (void)setRelate:(ActivityRelateModel *)relate {
    _relate = relate;
    
    [self setTitle:relate.name forState:UIControlStateNormal];
    [self setImage:[BundleTool imageNamed:relate.qmpIcon] forState:UIControlStateNormal];
    self.followView.hidden = !relate.isFollowed;
    
    self.nameLabel.hidden = YES;
    if (self.otherType == -1) {
        [self setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    } else if (self.otherType == -2) {
        self.nameLabel.hidden = NO;
        self.nameLabel.text = relate.name;
        [self setTitle:@"" forState:UIControlStateNormal];
    } else if (self.otherType == -3) {
        [self setTitleColor:H6COLOR forState:UIControlStateNormal];
    } else {
        [self setTitleColor:H9COLOR forState:UIControlStateNormal];
    }
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(6, 6, contentRect.size.height-12, contentRect.size.height-12);
}
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(24, 0, contentRect.size.width-24, contentRect.size.height);
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.followView.frame = CGRectMake(self.width-19, 5, 12, 12);
    self.deleteView.frame = CGRectMake(self.width-8, -6, 12, 12);
    self.nameLabel.frame = self.bounds;
}
- (UIImageView *)followView {
    if (!_followView) {
        _followView = [[UIImageView alloc] init];
        _followView.image = [BundleTool imageNamed:@"activity_relate_follow"];
    }
    return _followView;
}
- (UIImageView *)deleteView {
    if (!_deleteView) {
        _deleteView = [[UIImageView alloc] init];
        _deleteView.image = [BundleTool imageNamed:@"activity_relate_delete"];
        _deleteView.hidden = YES;
    }
    return _deleteView;
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.textColor = H3COLOR;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}
@end


@implementation QMPActivityCellAvatarView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.iconLabel];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.iconLabel.frame = self.bounds;
}

- (UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [[UILabel alloc] init];
        _iconLabel.frame = CGRectMake(0, 0, 0, 0);
        _iconLabel.textColor = [UIColor whiteColor];
        _iconLabel.font = [UIFont systemFontOfSize:14];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _iconLabel;
}
@end
