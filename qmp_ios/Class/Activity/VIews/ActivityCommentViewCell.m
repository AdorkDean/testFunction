//
//  ActivityCommentViewCell.m
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ActivityCommentViewCell.h"
#import <YYText.h>
#import "ActivityCommentModel.h"
#import "ActivityModel.h"
#import "NSDate+HY.h"
#import "QMPCommunityActivityCell.h"
#import "QMPActivityCellBarButton.h"

@interface ActivityCommentViewCell ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *companyLabel;
@property (nonatomic, strong) UILabel *positonLabel;
@property (nonatomic, strong) YYLabel *contentLabel;
@property (nonatomic, strong) QMPActivityCellBarButton *likeButton;

@property (nonatomic, strong) UIButton *idButton;
@end
@implementation ActivityCommentViewCell

+ (ActivityCommentViewCell *)cellWithTableView:(UITableView *)tableView {
    ActivityCommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCommentViewCellID"];
    if (!cell) {
        cell = [[ActivityCommentViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActivityCommentViewCellID"];
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
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.companyLabel];
    [self.contentView addSubview:self.positonLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.likeButton];
    [self.contentView addSubview:self.idButton];
}
- (void)setComment:(ActivityCommentModel *)comment {
    _comment = comment;
    
    self.nameLabel.text = comment.user.name;
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(13, 11, MIN(260, self.nameLabel.width), 18);
    
    self.companyLabel.hidden = YES;
    if (comment.anonymous) {
        if (comment.anonymous_degree == 1 && ![PublicTool isNull:comment.company.role]) {
            self.companyLabel.hidden = NO;
            self.companyLabel.text = comment.company.role;
        } else if(comment.anonymous_degree == 2){
            self.companyLabel.hidden = NO;
            self.companyLabel.text = comment.company.company;
        }
    } else {
        self.companyLabel.hidden = NO;
        self.companyLabel.text = [NSString stringWithFormat:@"%@ %@", comment.company.company, comment.company.position];
    }
    [self.companyLabel sizeToFit];
    self.companyLabel.frame = CGRectMake(13, 30, MIN(260, self.companyLabel.width), 15);
    
    
    self.idButton.frame = CGRectMake(self.nameLabel.right+5,
                                     self.nameLabel.centerY-15+1, comment.showID?120:30, 30);
    if (comment.showID) {
        NSString *idStr = [NSString stringWithFormat:@"ID:%@", self.comment.user.usercode];
        [self.idButton setTitle:idStr forState:UIControlStateNormal];
        [self.idButton setImage:[UIImage new] forState:UIControlStateNormal];
    } else {
        [self.idButton setTitle:@"" forState:UIControlStateNormal];
        [self.idButton setImage:[UIImage imageNamed:@"activity_cell_id"] forState:UIControlStateNormal];
    }
    if (self.companyLabel.hidden) {
        self.contentLabel.top = 40;
    }else{
        self.contentLabel.top = 55;
    }
    self.contentLabel.textLayout = comment.textLayout;
    self.contentLabel.height = comment.textLayout.textBoundingSize.height;
    
    self.lineView.frame = CGRectMake(0, comment.cellHeight-1, SCREENW, 1);
    NSString *imgName = comment.like_status?@"activity_comment_cell_diggb":@"activity_comment_cell_digg";

    [self.likeButton setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [self.likeButton setTitle:[self fixCountShow:comment.likeCount] forState:UIControlStateNormal];
    self.likeButton.centerY = self.nameLabel.centerY;
    
    self.idButton.hidden = !comment.isAnonymous;
}

- (void)updateDiggButtonShow {
    
    NSString *imgName = self.comment.like_status?@"activity_comment_cell_diggb":@"activity_comment_cell_digg";
    [self.likeButton setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [self.likeButton setTitle:[self fixCountShow:self.comment.likeCount] forState:UIControlStateNormal];
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
- (void)redirectToUser {
    if (self.comment.isAnonymous) {
        return;
    }
    if (![PublicTool isNull:self.comment.user.ID]) {
        [[AppPageSkipTool shared] appPageSkipToPersonDetail:self.comment.user.ID];
    } else if (![PublicTool isNull:self.comment.user.uID]) {
        [[AppPageSkipTool shared] appPageSkipToUserDetail:self.comment.user.uID];
    }
}

- (void)deleteButtonClick:(UIButton*)button{

    __weak typeof(self) weakSelf = self;
    [PublicTool alertActionWithTitle:@"提示" message:@"确认要删除这条评论？" cancleAction:^{
        
    } sureAction:^{
        
        [PublicTool showHudWithView:KEYWindow];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:weakSelf.comment.ID forKey:@"comment_id"];
        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/activityCommentDel" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [PublicTool dismissHud:KEYWindow];
            
            if (resultData) {
                if (weakSelf.didDeletedComment) {
                    weakSelf.didDeletedComment();
                }
                [ShowInfo showInfoOnView:KEYWindow withInfo:@"删除成功"];
                //我的评论列表需要刷新
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_ACTCOMMENTDEL object:nil];
            }else{
                [ShowInfo showInfoOnView:KEYWindow withInfo:@"删除失败"];
            }
        }];
        
        
    }];
}

- (void)likeButtonClick:(UIButton *)button {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.comment.ID forKey:@"comment_id"];
    [dic setValue:@(!self.comment.like_status) forKey:@"like"];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Comment/commentLike" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]){
            self.comment.like_status = !self.comment.like_status;
            self.comment.likeCount = self.comment.likeCount + (self.comment.like_status ? 1 : -1);
            [self updateDiggButtonShow];
            [ShowInfo showInfoOnView:KEYWindow withInfo:self.comment.like_status?@"点赞成功":@"取消点赞"];
            
            if (self.didLikeComment) {
                self.didLikeComment(YES);
            }
            
        }else{
            [ShowInfo showInfoOnView:KEYWindow withInfo:@"点赞失败"];
        }
    }];
}

- (void)copyComment{
    [UIPasteboard generalPasteboard].string = self.contentLabel.attributedText.string;
    [PublicTool showMsg:@"复制成功"];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)idButtonClick:(UIButton *)button {
    self.comment.showID = !self.comment.showID;
    if (self.comment.showID) {
        NSString *idStr = [NSString stringWithFormat:@"ID:%@", self.comment.user.usercode];
        [button setTitle:idStr forState:UIControlStateNormal];
        [button setImage:[UIImage new] forState:UIControlStateNormal];
        button.width = 150;
    } else {
        [button setTitle:@"" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"activity_cell_id"] forState:UIControlStateNormal];
        button.width = 30;
    }
}
- (UIButton *)idButton {
    if (!_idButton) {
        _idButton = [[UIButton alloc] init];
        _idButton.frame = CGRectMake(0, 0, 31, 31);
        _idButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_idButton setTitleColor:H9COLOR forState:UIControlStateNormal];
        [_idButton setImage:[UIImage imageNamed:@"activity_cell_id"] forState:UIControlStateNormal];
        _idButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_idButton addTarget:self action:@selector(idButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _idButton;
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(13, 11, 200, 18);
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = HTColorFromRGB(0x333333);
        _nameLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(redirectToUser)];
        [_nameLabel addGestureRecognizer:tapGest];
    }
    return _nameLabel;
}
- (UILabel *)companyLabel {
    if (!_companyLabel) {
        _companyLabel = [[UILabel alloc] init];
        _companyLabel.frame = CGRectMake(13, 30, 0, 15);
        _companyLabel.textColor = HTColorFromRGB(0x999999);
        _companyLabel.font = [UIFont systemFontOfSize:11];
    }
    return _companyLabel;
}
- (UILabel *)positonLabel {
    if (!_positonLabel) {
        _positonLabel = [[UILabel alloc] init];
        _positonLabel.frame = CGRectMake(13, 30, 0, 15);
        _positonLabel.textColor = HTColorFromRGB(0x999999);
        _positonLabel.font = [UIFont systemFontOfSize:11];
    }
    return _positonLabel;
}
- (YYLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[YYLabel alloc] init];
        _contentLabel.frame = CGRectMake(13, 55, SCREENW-26, 0);
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textColor = HTColorFromRGB(0x222222);
        [_contentLabel addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyComment)]];
    }
    return _contentLabel;
}
- (QMPActivityCellBarButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [[QMPActivityCellBarButton alloc] init];
        _likeButton.frame = CGRectMake(SCREENW-50, 11, 40, 35);
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:11];
        [_likeButton setTitleColor:H999999 forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"activity_delete"] forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(likeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeButton;
}

- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] init];
        _lineView.frame = CGRectMake(0, 0, SCREENW, 1);
        _lineView.backgroundColor = HTColorFromRGB(0xEEEEEE);
    }
    return _lineView;
}
@end

CGFloat const ActivityNoCommentViewCellHeight = 123;
@implementation ActivityNoCommentViewCell : UITableViewCell
+ (ActivityNoCommentViewCell *)cellWithTableView:(UITableView *)tableView {
    ActivityNoCommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityNoCommentViewCellID"];
    if (cell == nil) {
        cell = [[ActivityNoCommentViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActivityNoCommentViewCellID"];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    [self.contentView addSubview:self.messageLabel];
}
- (UILabel *)messageLabel {
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.frame = CGRectMake(0, (ActivityNoCommentViewCellHeight-20)/2.0, SCREENW, 20);
        _messageLabel.font = [UIFont systemFontOfSize:16];
        _messageLabel.textColor = HCCOLOR;
        _messageLabel.text = @"暂无评论";
        _messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLabel;
}
@end
