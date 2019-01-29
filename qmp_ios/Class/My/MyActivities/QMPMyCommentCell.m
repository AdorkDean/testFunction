//
//  QMPMyCommentCell.m
//  qmp_ios
//
//  Created by QMP on 2018/9/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPMyCommentCell.h"
#import <YYText.h>
#import "NSDate+HY.h"
#import "ActivityDetailViewController.h"
@interface QMPMyCommentCell ()
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) YYLabel *commentLabel;
@property (nonatomic, strong) YYLabel *contentLabel;

@property (nonatomic, strong) UIImageView *lineView;
@end

@implementation QMPMyCommentCell
+ (QMPMyCommentCell *)myCommentCellWithTableView:(UITableView *)tableView {
    QMPMyCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMPMyCommentCellID"];
    if (!cell) {
        cell = [[QMPMyCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QMPMyCommentCellID"];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.rightButton];
    
    [self.contentView addSubview:self.commentLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.lineView];
}

- (void)setComment:(QMPMyComment *)comment {
    _comment = comment;
    
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:comment.avatar]];
    
    self.descLabel.text = comment.desc;
    [self.descLabel sizeToFit];
    
    self.nameLabel.text = comment.name;
    [self.nameLabel sizeToFit];
    CGFloat maxW = SCREENW - 62 - 40 - self.descLabel.width;
    self.nameLabel.frame = CGRectMake(self.avatarView.right+10, self.avatarView.top-2, MIN(self.nameLabel.width, maxW), 20);
 
    self.descLabel.left = self.nameLabel.right + 5;
    self.descLabel.centerY = self.nameLabel.centerY;
    
    self.commentLabel.attributedText = comment.comment;
    self.commentLabel.height = comment.textHeight;
    
    self.contentLabel.attributedText = comment.content;
    
    self.contentLabel.top = self.commentLabel.bottom + 12;
    self.contentLabel.height = comment.contentHeight;
    
}
- (void)activityContentTap {
    if (self.comment.didDeleted) {
        return ;
    }
    ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] init];
    vc.activityID = self.comment.activityID;
    vc.activityTicket = self.comment.activityTicket;
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
}
- (void)rightButtonClick:(UIButton *)button {
    __weak typeof(self) weakSelf = self;
    [PublicTool alertActionWithTitle:@"提示" message:@"确认要删除这条评论？" cancleAction:^{
        
    } sureAction:^{
        
        [PublicTool showHudWithView:KEYWindow];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:weakSelf.comment.ID forKey:@"comment_id"];
        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/activityCommentDel" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [PublicTool dismissHud:KEYWindow];
            
            if (resultData) {
                if (weakSelf.commentDidDeleted) {
                    weakSelf.commentDidDeleted();
                }
                [ShowInfo showInfoOnView:KEYWindow withInfo:@"删除成功"];
            }else{
                [ShowInfo showInfoOnView:KEYWindow withInfo:@"删除失败"];
            }
        }];
        
        
    }];
}
#pragma mark - Getter
- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.frame = CGRectMake(17, 12, 35, 35);
        _avatarView.layer.cornerRadius = 17.5;
        _avatarView.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        _avatarView.layer.borderWidth = 0.5;
        _avatarView.clipsToBounds = YES;
    }
    return _avatarView;
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(self.avatarView.right+10, self.avatarView.top-2, 0, 20);
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = COLOR2D343A;
    }
    return _nameLabel;
}
- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.frame = CGRectMake(0, 0, 0, 0);
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.textColor = COLOR737782;
    }
    return _descLabel;
}
- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(SCREENW-38-7, 3, 38, 38);
        [_rightButton setImage:[BundleTool imageNamed:@"activity_delete"] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _rightButton;
}
- (YYLabel *)commentLabel {
    if (!_commentLabel) {
        _commentLabel = [[YYLabel alloc] init];
        _commentLabel.frame = CGRectMake(self.nameLabel.left, 42, SCREENW-self.nameLabel.left-17, 0);
        _commentLabel.numberOfLines = 0;
    }
    return _commentLabel;
}
- (YYLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[YYLabel alloc] init];
        _contentLabel.frame = CGRectMake(self.nameLabel.left, 0, SCREENW-self.nameLabel.left-17, 0);
        _contentLabel.numberOfLines = 0;
        _contentLabel.textContainerInset = UIEdgeInsetsMake(10, 12, 10, 12);
        _contentLabel.backgroundColor = F5COLOR;
        _contentLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(activityContentTap)];
        [_contentLabel addGestureRecognizer:tapGest];
    }
    return _contentLabel;
}
- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] init];
        _lineView.frame = CGRectMake(0, 0, SCREENW, 1);
        _lineView.backgroundColor = LIST_LINE_COLOR;
    }
    return _lineView;
}
@end

@interface QMPMyComment ()
@property (nonatomic, assign) CGFloat top;
@end
@implementation QMPMyComment
/*
 "act_id" = 90b20390e2d7aca0bd6ac12f3fc58a7a;
 anonymous = 0;
 comment = "\U5466\U5466\U5466";
 content = "\U7231\U56de\U6536\U5b8c\U6210\U65b0\U4e00\U8f6e1.5\U4ebf\U7f8e\U5143\U878d\U8d44\Uff0c\U53d1\U529bB2B\U4e1a\U52a1\U548c\U5168\U7403\U5316";
 "create_time" = "2018-09-05 15:53:36";
 icon = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTKC6AnabiaayoLC2UUibY5sGoOToKQAFLzwMLQUSBGRxzGX6OYAX290oJoftORIC1picwqCEKq2ibaPGg/132";
 id = 1c9ac0159c94d8d0cbedc973445af2da156;
 nickname = "\U4fee\U58eb\U6797";
 "parent_id" = 0;
 ticket = d210f72e11e95f1fb897b934648c71f2;
 uuid = d9d95f8700be5845af4a5a892766ba3c;
 like_num = @"0"
*/

- (instancetype)initWithCommentDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _ID = dict[@"id"]?:@"";
        _activityID = dict[@"act_id"]?:@"";
        _activityTicket = dict[@"ticket"]?:@"";
        if ([PublicTool isNull:dict[@"act_id"]]) {
            _didDeleted = YES;
        }
        
        _name = dict[@"nickname"]?:@"";
        if ([dict[@"anonymous"] integerValue] == 1) {
            _name = dict[@"flower_name"];
        }
        _avatar = dict[@"icon"]?:@"";
        _desc = [NSDate formatDate:dict[@"create_time"]?:@""];
        _like_num = dict[@"like_num"]?:@"";

        _top = 42;
        
        [self fixComment:dict[@"comment"]];
        
        _top += _textHeight;
        [self fixContent:dict[@"content"]];
        if (_didDeleted) {
            [self fixContent:@"[动态已删除]"];
        } else if([PublicTool isNull:dict[@"content"]]){
            if (![PublicTool isNull:dict[@"link_title"]]) {
                [self fixContent:dict[@"link_title"]];
            }else if (![PublicTool isNull:dict[@"link_url"]]){
                [self fixContent:@"分享链接"];
            }else{
                [self fixContent:@"分享图片"];
            }
        }
        
        _top += 12;
        _top += _contentHeight;
        _top += 12;
        
        _cellHeight = _top + 1;
    }
    return self;
}

- (void)fixComment:(NSString *)comment {
    UIFont *font = [UIFont systemFontOfSize:15];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:comment?:@"" attributes:@{}];
    attr.yy_font = font;
    attr.yy_lineSpacing = 6 - (font.lineHeight - font.pointSize);
    
    _comment = attr;
    
    CGFloat maxW = SCREENW - 62 - 17;
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(maxW, MAXFLOAT) text:attr];
    
    _textHeight = layout.textBoundingSize.height;
}

- (void)fixContent:(NSString *)content {
    UIFont *font = [UIFont systemFontOfSize:15];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content?:@"" attributes:@{}];
    attr.yy_font = font;
    attr.yy_lineSpacing = 6 - (font.lineHeight - font.pointSize);
    
    _content = attr;
    
    CGFloat maxW = SCREENW - 62 - 17 - 24;
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(maxW, MAXFLOAT) text:attr];
    
    _contentHeight = layout.textBoundingSize.height + 20;
}
@end
