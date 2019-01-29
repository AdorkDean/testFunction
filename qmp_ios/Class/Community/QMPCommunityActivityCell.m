//
//  QMPCommunityActivityCell.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/9.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "QMPCommunityActivityCell.h"
#import <YYText.h>
#import "SLPhotosView.h"
#import "QMPActivityCell.h"
#import "QMPActivityCellModel.h"
#import "ActivityModel.h"
#import "ActivityHtmlMedia.h"
#import "NSDate+HY.h"
const CGFloat QMPCommunityActivityCellLeft = 13;
const CGFloat QMPCommunityActivityCellActionHeight = 37;

@interface QMPCommunityActivityCell ()
@end
@implementation QMPCommunityActivityCell
+ (instancetype)activityCellWithTableView:(UITableView *)tableView {
    QMPCommunityActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMPCommunityActivityCellID"];
    if (!cell) {
        cell = [[QMPCommunityActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QMPCommunityActivityCellID"];
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
- (void)setupViews {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.companyLabel];
    [self.contentView addSubview:self.positonLabel];
    [self.contentView addSubview:self.idButton];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.deleteButton];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.imagesView];
    [self.contentView addSubview:self.relatesView];
    [self.contentView addSubview:self.diggButton];
    [self.contentView addSubview:self.commentButton];
//    [self.contentView addSubview:self.shareButton];
//    [self.contentView addSubview:self.moreButton];
    [self.contentView addSubview:self.lineView];
    
    [self.relatesView addSubview:self.editView];
    [self.relatesView addSubview:self.confirmRelateView];
    [self.relatesView addSubview:self.addRelateView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - Setter
- (void)setCellModel:(QMPActivityCellModel *)cellModel {
    _cellModel = cellModel;
    
    ActivityModel *activity = cellModel.activity;
    ActivityUserModel *user = activity.user;
    ActivityCompanyModel *company = activity.company;
    
    if (cellModel.detail) {
        self.nameLabel.hidden = NO;
        self.companyLabel.hidden = NO;
        self.timeLabel.hidden = NO;
        
        self.timeLabel.text = [NSDate formatDate:activity.createTime];
        [self.timeLabel sizeToFit];
        self.timeLabel.frame = CGRectMake(13, cellModel.cellHeight-12-17, self.timeLabel.width, 12);
        
        self.nameLabel.text = user.name;
        self.nameLabel.textColor = HTColorFromRGB((activity.isAnonymous ? 0x666666 : 0x333333));
        [self.nameLabel sizeToFit];
        self.nameLabel.frame = CGRectMake(QMPCommunityActivityCellLeft, 13,
                                          MIN(self.nameLabel.width, SCREENW/2.0), 20);
        
        self.companyLabel.hidden = YES;
        if (!activity.anonymous) {
            self.companyLabel.hidden = NO;
            self.companyLabel.text = [NSString stringWithFormat:@"%@ %@",company.company,company.position];
        }else{
            if (activity.anonymous_degree.integerValue == 1 && ![PublicTool isNull:activity.company.role]) { //身份
                self.companyLabel.hidden = NO;
                self.companyLabel.text = company.role;
            }else if (activity.anonymous_degree.integerValue == 2) { //员工
                self.companyLabel.hidden = NO;
                self.companyLabel.text = company.company;
            }else{
                self.companyLabel.text = @"";
                self.companyLabel.hidden = YES;
            }
        }
        [self.companyLabel sizeToFit];
        
        self.idButton.hidden = !activity.isAnonymous;
        
        self.idButton.frame = CGRectMake(self.nameLabel.right+5,
                                         self.nameLabel.centerY-15+0.5, self.cellModel.showID?150:30, 30);
        
        if (self.cellModel.showID) {
            NSString *idStr = [NSString stringWithFormat:@"ID:%@", user.usercode];
            [self.idButton setTitle:idStr forState:UIControlStateNormal];
            [self.idButton setImage:[UIImage new] forState:UIControlStateNormal];
        } else {
            [self.idButton setTitle:@"" forState:UIControlStateNormal];
            [self.idButton setImage:[UIImage imageNamed:@"activity_cell_id"] forState:UIControlStateNormal];
        }
        if (self.companyLabel.hidden) {
            self.contentLabel.top = 61 - 17;
        } else {
            self.contentLabel.top = 61;
        }
        self.deleteButton.hidden = !activity.isMine;
   
    } else {
        
        self.nameLabel.hidden = NO;
        self.companyLabel.hidden = YES;
        self.timeLabel.hidden = YES;
        self.deleteButton.hidden = YES;
        self.contentLabel.top = 40;
        self.nameLabel.textColor = H999999;
        self.nameLabel.font = [UIFont systemFontOfSize:12];
        self.nameLabel.text = user.name;
        [self.nameLabel sizeToFit];
        self.nameLabel.frame = CGRectMake(QMPCommunityActivityCellLeft, 11,
                                          MIN(self.nameLabel.width, SCREENW/2.0), 20);
        self.idButton.hidden = !activity.isAnonymous;
        
        self.idButton.frame = CGRectMake(self.nameLabel.right+5,
                                         self.nameLabel.centerY-15+0.5, self.cellModel.showID?150:30, 30);
        
    }

    [self setupContentLabelText];
    
    self.imagesView.hidden = YES;
    if (activity.images.count > 0) {
        self.imagesView.hidden = NO;
        self.imagesView.top = self.contentLabel.bottom + 11 - 4;
        self.imagesView.height = cellModel.imagesSize.height;
        self.imagesView.photoModels = activity.images;
    }
    
    self.relatesView.top = cellModel.cellHeight - 42 - cellModel.relatesSize.height;
    self.relatesView.height = cellModel.relatesSize.height;
    [self setupRelateItems];
    
    CGFloat barButtonTop = cellModel.cellHeight - QMPCommunityActivityCellActionHeight - 4;
    self.diggButton.top = barButtonTop;
    self.commentButton.top = barButtonTop;
    self.shareButton.top = barButtonTop;
    self.moreButton.top = barButtonTop;
    [self setupBarButtonCount:activity];
    
    self.moreButton.hidden = cellModel.detail;
    
    self.lineView.top = cellModel.cellHeight - 1;
}
- (void)setupBarButtonCount:(ActivityModel *)activity {
    self.diggButton.selected = activity.isDigged;
    [self.diggButton setTitle:[self fixCountShow:activity.diggCount] forState:UIControlStateNormal];
    [self.commentButton setTitle:[self fixCountShow:activity.commentCount] forState:UIControlStateNormal];
}
- (void)setupRelateItems {
    QMPActivityCellModel *cellModel = self.cellModel;
    ActivityModel *activity = cellModel.activity;
    
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
}
- (void)setupContentLabelText {
    QMPActivityCellModel *cellModel = self.cellModel;
    ActivityModel *activity = cellModel.activity;
    
    self.contentLabel.height = cellModel.textHeight;
    
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
                [weakSelf.delegate activityCell:nil detailLinkTap:media.href];
            }
        }];
        
    }
    
    if (cellModel.linkHighlightRange.length > 0 &&
        (!cellModel.needExpand || cellModel.expanding)) {
        [attr yy_setTextHighlightRange:cellModel.linkHighlightRange color:BLUE_TITLE_COLOR backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            QMPLog(@"点击链接");
            if ([weakSelf.delegate respondsToSelector:@selector(activityCell:textLinkTap:)]) {
                [weakSelf.delegate activityCell:nil textLinkTap:activity.linkInfo];
            }
        }];
    }
    
    if (cellModel.needExpand) {
        [attr yy_setTextHighlightRange:NSMakeRange(attr.string.length-2, 2) color:BLUE_TITLE_COLOR backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            QMPLog(@"点击展开，收起");
            if ([weakSelf.delegate respondsToSelector:@selector(activityCell:textExpandTap:withCellModel:)]) {
                [weakSelf.delegate activityCell:self textExpandTap:cellModel.expanding withCellModel:cellModel];
            }
        }];
    }
    
    self.contentLabel.attributedText = attr;
}
#pragma mark - Event
- (void)headerViewTap {
    if (self.cellModel.activity.isAnonymous) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(activityCell:userTap:)]) {
        [self.delegate activityCell:self userTap:self.cellModel.activity.user];
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
        [button setImage:[UIImage imageNamed:@"activity_cell_id"] forState:UIControlStateNormal];
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
            [self.delegate activityCell:nil relateItemTap:item];
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
- (void)deleteButtonClick {
    if ([self.delegate respondsToSelector:@selector(activityCell:rightButtonClick:isDelete:)]) {
        [self.delegate activityCell:self rightButtonClick:self.cellModel.activity isDelete:YES];
    }
}
#pragma mark - <#msg#>
- (void)updateCountWithModel:(ActivityModel *)activity {
    [self setupBarButtonCount:activity];
}
#pragma mark - Getter
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(QMPCommunityActivityCellLeft, 13, 0, 20);
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = H6COLOR;
        _nameLabel.userInteractionEnabled = YES;        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTap)];
        [_nameLabel addGestureRecognizer:tapGest];
    }
    return _nameLabel;
}
- (UILabel *)companyLabel {
    if (!_companyLabel) {
        _companyLabel = [[UILabel alloc] init];
        _companyLabel.frame = CGRectMake(QMPCommunityActivityCellLeft, 36, 0, 16);
        _companyLabel.font = [UIFont systemFontOfSize:12];
        _companyLabel.textColor = HTColorFromRGB(0x666666);
    }
    return _companyLabel;
}
- (UILabel *)positonLabel {
    if (!_positonLabel) {
        _positonLabel = [[UILabel alloc] init];
        _positonLabel.frame = CGRectMake(QMPCommunityActivityCellLeft, 36, 0, 16);
        _positonLabel.font = [UIFont systemFontOfSize:12];
        _positonLabel.textColor = HTColorFromRGB(0x666666);
    }
    return _positonLabel;
}
- (UIButton *)idButton {
    if (!_idButton) {
        _idButton = [[UIButton alloc] init];
        _idButton.frame = CGRectMake(0, 0, 31, 31);
        _idButton.hidden = YES;
        _idButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_idButton setTitleColor:H9COLOR forState:UIControlStateNormal];
        [_idButton setImage:[UIImage imageNamed:@"activity_cell_id"] forState:UIControlStateNormal];
        _idButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_idButton addTarget:self action:@selector(idButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _idButton;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.frame = CGRectMake(SCREENW-100-13, 17, 100, 12);
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = HTColorFromRGB(0x999999);
    }
    return _timeLabel;
}
- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] init];
        _deleteButton.frame = CGRectMake(SCREENW-36-4, 3, 36, 36);
        [_deleteButton setImage:[UIImage imageNamed:@"activity_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}
- (YYLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[YYLabel alloc] init];
        _contentLabel.frame = CGRectMake(QMPCommunityActivityCellLeft, 61,
                                         SCREENW-QMPCommunityActivityCellLeft*2, 0);
        _contentLabel.numberOfLines = 0;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(textLongPress)];
        [_contentLabel addGestureRecognizer:longPress];
    }
    return _contentLabel;
}
- (SLPhotosView *)imagesView {
    if (!_imagesView) {
        _imagesView = [[SLPhotosView alloc] init];
        _imagesView.frame = CGRectMake(QMPCommunityActivityCellLeft, 0,
                                       SCREENW-QMPCommunityActivityCellLeft*2, 0);
    }
    return _imagesView;
}

- (UIView *)relatesView {
    if (!_relatesView) {
        _relatesView = [[UIView alloc] init];
        _relatesView.frame = CGRectMake(QMPCommunityActivityCellLeft, 0,
                                        SCREENW-QMPCommunityActivityCellLeft*2, 0);
       
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
- (QMPActivityCellBarButton *)diggButton {
    if (!_diggButton) {
        _diggButton = [[QMPActivityCellBarButton alloc] init];
        _diggButton.frame = CGRectMake(SCREENW-120, 0,50, QMPCommunityActivityCellActionHeight);
        _diggButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_diggButton setTitle:@"1" forState:UIControlStateNormal];
        [_diggButton setTitleColor:H999999 forState:UIControlStateNormal];
        [_diggButton setImage:[UIImage imageNamed:@"activity_cell_digg"] forState:UIControlStateNormal];
        [_diggButton setImage:[UIImage imageNamed:@"activity_cell_diggb"] forState:UIControlStateSelected];
        [_diggButton addTarget:self action:@selector(diggButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_diggButton setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 6)];
    }
    return _diggButton;
}

- (QMPActivityCellBarButton *)commentButton {
    if (!_commentButton) {
        _commentButton = [[QMPActivityCellBarButton alloc] init];
        _commentButton.frame = CGRectMake(SCREENW-58, 0, 50, QMPCommunityActivityCellActionHeight);
        _commentButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_commentButton setTitleColor:H999999 forState:UIControlStateNormal];
        [_commentButton setImage:[UIImage imageNamed:@"activity_cell_comment"] forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(commentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_commentButton setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 6)];
    }
    return _commentButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [[UIButton alloc] init];
        _shareButton.frame = CGRectMake(97, 0,
                                        36, QMPCommunityActivityCellActionHeight);
        _shareButton.titleLabel.font = [UIFont systemFontOfSize:8];
        [_shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_shareButton setImage:[UIImage imageNamed:@"activity_cell_share"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}
- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [[UIButton alloc] init];
        _moreButton.frame = CGRectMake(SCREENW - 35, 0, 35, QMPCommunityActivityCellActionHeight);
        _moreButton.backgroundColor = [UIColor whiteColor];
        _moreButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        [_moreButton setImage:[UIImage imageNamed:@"activity_cell_more2"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}
- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] init];
        _lineView.frame = CGRectMake(0, 0, SCREENW, 1);
        _lineView.backgroundColor = HTColorFromRGB(0xEEEEEE);
    }
    return _lineView;
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
@end

@implementation QMPActivityCellMenuView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.backgroundView];
        [self addSubview:self.collectButton];
        [self addSubview:self.reportButton];
    }
    return self;
}
- (void)setActivity:(ActivityModel *)activity {
    _activity = activity;
    self.collectButton.selected = activity.isCollected;
    self.reportButton.selected = activity.isReported;
}
- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] init];
        _backgroundView.frame = CGRectMake(0, 0, 166, 35);
        _backgroundView.image = [UIImage imageNamed:@"activity_cell_menu_bg"];
    }
    return _backgroundView;
}
- (UIButton *)collectButton {
    if (!_collectButton) {
        _collectButton = [[UIButton alloc] init];
        _collectButton.frame = CGRectMake(0, 0, 80, 35);
        _collectButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_collectButton setTitle:@"收藏" forState:UIControlStateNormal];
        [_collectButton setTitle:@"已收藏" forState:UIControlStateSelected];
        [_collectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_collectButton setImage:[UIImage imageNamed:@"activity_cell_collect"] forState:UIControlStateNormal];
        _collectButton.imageEdgeInsets = UIEdgeInsetsMake(0, -1.5, 0, 1.5);
        _collectButton.titleEdgeInsets = UIEdgeInsetsMake(0, 1.5, 0, -1.5);
        [_collectButton addTarget:self action:@selector(collectButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _collectButton;
}
- (UIButton *)reportButton {
    if (!_reportButton) {
        _reportButton = [[UIButton alloc] init];
        _reportButton.frame = CGRectMake(81, 0, 80, 35);
        _reportButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_reportButton setTitle:@"举报" forState:UIControlStateNormal];
        [_reportButton setTitle:@"已举报" forState:UIControlStateSelected];
        [_reportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_reportButton setImage:[UIImage imageNamed:@"activity_cell_report"] forState:UIControlStateNormal];
        _reportButton.imageEdgeInsets = UIEdgeInsetsMake(0, -1.5, 0, 1.5);
        _reportButton.titleEdgeInsets = UIEdgeInsetsMake(0, 1.5, 0, -1.5);
        [_reportButton addTarget:self action:@selector(reportButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reportButton;
}
- (void)collectButtonClick {
    if ([self.delegate respondsToSelector:@selector(activityCellMenuViewCollectButtonClick)]) {
        [self.delegate activityCellMenuViewCollectButtonClick];
    }
}
- (void)reportButtonClick {
    if ([self.delegate respondsToSelector:@selector(activityCellMenuViewReportButtonClick)]) {
        [self.delegate activityCellMenuViewReportButtonClick];
    }
}
@end
