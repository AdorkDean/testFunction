//
//  QMPActivityDetialBarView.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/11.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "QMPActivityDetialBarView.h"
#import "ActivityDetailBottomView.h"
#import "QMPActivityDetialCommentView.h"
@interface QMPActivityDetialBarView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *roleView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIImageView *arrowView;

@property (nonatomic, strong) CommentPostRoleSelectView *roleSelectView;

@property (nonatomic, strong) UIButton *commentHolderButton;
@property (nonatomic, strong) UIImageView *lineView;

@property (nonatomic, weak) UIView *maskView2;
@end
@implementation QMPActivityDetialBarView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.roleView];
    [self addSubview:self.commentHolderButton];
    [self addSubview:self.lineView];
    
    UIImageView *line = [[UIImageView alloc] init];
    line.frame = CGRectMake(0, 0, SCREENW, 1);
    line.backgroundColor = HTColorFromRGB(0xEDEEF0);
    [self addSubview:line];
    
    self.nameLabel.text = @"显示身份";
    self.roleView.frame = CGRectMake(13, 10, 91, 31);
    if (!self.anonymous2) {
        self.anonymous2 = @"1";
    }
    if (!self.degree2) {
        self.degree2 = @"1";
    }
}
- (void)commentButtonClick {
    if (![PublicTool userisCliamed]) {
        return;
    }
    QMPActivityDetialCommentView *commentView = [[QMPActivityDetialCommentView alloc] init];
    commentView.anonymous2 = self.anonymous2;
    commentView.degree2 = self.degree2;
    commentView.activityTicket = self.activityTicket;
    [commentView updateRoleShow];
    [commentView show];
    __weak typeof(self) weakSelf = self;
    commentView.roleDidTap = ^(NSString * _Nonnull anonymous2, NSString * _Nonnull degree2) {
        weakSelf.anonymous2 = anonymous2;
        weakSelf.degree2 = degree2;
        [weakSelf updateRoleShow];
    };
    commentView.activityCommentPost = ^(ActivityCommentModel * _Nonnull model) {
        if (weakSelf.activityCommentPost) {
            weakSelf.activityCommentPost(model);
        }
    };
    if (self.showRole) {
        [self roleViewTap];
    }
    
}
- (void)roleViewTap {
    if (![PublicTool userisCliamed]) {
        return;
    }
    if (self.showRole) {
        [self.superview removeFromSuperview];
        if (self.roleDidTap) {
            self.roleDidTap(self.anonymous2, self.degree2);
        }
    } else {
        UIView *maskView = [[UIView alloc] init];
        maskView.frame = CGRectMake(0, 0, SCREENW, SCREENH);
        maskView.backgroundColor = RGBa(0, 0, 0, 0.3);
        [[UIApplication sharedApplication].keyWindow addSubview:maskView];
        self.maskView2 = maskView;
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        tapGest.delegate = self;
        [maskView addGestureRecognizer:tapGest];
        
        QMPActivityDetialBarView *barView = [[QMPActivityDetialBarView alloc] init];
        CGFloat h = 50;
        if (isiPhoneX) {
            h = 66;
        }
        barView.frame = CGRectMake(0, SCREENH-h, SCREENW, h);
        barView.showRole = YES;
        barView.anonymous2 = self.anonymous2;
        barView.degree2 = self.degree2;
        barView.activityTicket = self.activityTicket;
        [barView updateRoleShow];
        [barView showRoleView];
        [maskView addSubview:barView];
        __weak typeof(self) weakSelf = self;
        barView.roleDidTap = ^(NSString * _Nonnull anonymous2, NSString * _Nonnull degree2) {
            weakSelf.anonymous2 = anonymous2;
            weakSelf.degree2 = degree2;
            [weakSelf updateRoleShow];
        };
        barView.activityCommentPost = ^(ActivityCommentModel * _Nonnull model) {
            if (weakSelf.activityCommentPost) {
                weakSelf.activityCommentPost(model);
            }
        };
    }
    
    
}
- (void)hide {
    [self.maskView2 removeFromSuperview];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self]) {
        return NO;
    }
    return YES;
}
- (void)showRoleView {
    self.arrowView.transform = CGAffineTransformRotate(self.arrowView.transform, M_PI);
    
    if (self.roleSelectView.superview) {
        [self.roleSelectView removeFromSuperview];
    } else {
        [self addSubview:self.roleSelectView];
    }
}
- (void)updateRoleShow {
    if ([self.anonymous2 isEqualToString:@"1"]) {
        if ([self.degree2 isEqualToString:@"2"]) {
            self.nameLabel.text = @"显示公司";
        } else {
            self.nameLabel.text = @"显示身份";
        }
    } else {
        self.nameLabel.text = @"显示实名";
    }
    self.arrowView.transform = CGAffineTransformIdentity;
}
- (void)roleSelectViewTap:(UITapGestureRecognizer *)tapGest {
    UIView *view = tapGest.view;
    CGFloat height = view.height / 3;
    
    CGPoint p = [tapGest locationInView:view];
    
    self.anonymous2 = p.y > height ? @"1" : @"0";
    self.degree2 = p.y > height *2 ? @"1" : @"2";
    
    if (self.roleDidTap) {
        self.roleDidTap(self.anonymous2, self.degree2);
    }
    if (self.superview.superview) {
        [self.superview removeFromSuperview];
    }
//    [self updateRoleShow];
}
- (UIView *)roleView {
    if (!_roleView) {
        _roleView = [[UIView alloc] init];
        _roleView.frame = CGRectMake(0, 0, 86, 31);
        _roleView.layer.cornerRadius = 15.5;
        _roleView.layer.borderWidth = 1;
        _roleView.layer.borderColor = [HTColorFromRGB(0xEEEEEE) CGColor];
        _roleView.clipsToBounds = YES;
        _roleView.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(10, (31-13)/2.0, 54, 13);
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = H3COLOR;
        [_roleView addSubview:label];
        self.nameLabel = label;
        
        UIImageView *arrowView = [[UIImageView alloc] init];
        arrowView.frame = CGRectMake(65, 12.5, 11, 6);
        arrowView.image = [BundleTool imageNamed:@"activity_role_arrow"];
        [_roleView addSubview:arrowView];
        self.arrowView = arrowView;
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(roleViewTap)];
        [_roleView addGestureRecognizer:tapGest];
    }
    return _roleView;
}

- (CommentPostRoleSelectView *)roleSelectView {
    if (!_roleSelectView) {
        _roleSelectView = [[CommentPostRoleSelectView alloc] init];
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(roleSelectViewTap:)];
        [_roleSelectView addGestureRecognizer:tapGest];
    }
    return _roleSelectView;
}
- (UIButton *)commentHolderButton {
    if (!_commentHolderButton) {
        _commentHolderButton = [[UIButton alloc] init];
        _commentHolderButton.frame = CGRectMake(117, (50-36)/2.0, SCREENW-13-117, 36);
        _commentHolderButton.layer.cornerRadius = 18.0;
        _commentHolderButton.backgroundColor = HTColorFromRGB(0xF5F5F5);
        _commentHolderButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_commentHolderButton setTitleColor:H3COLOR forState:UIControlStateNormal];
        [_commentHolderButton setTitle:@"写评论..." forState:UIControlStateNormal];
        _commentHolderButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _commentHolderButton.titleEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 0);
        [_commentHolderButton addTarget:self action:@selector(commentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentHolderButton;
}
- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] init];
        _lineView.frame = CGRectMake(0, 0, SCREENW, 1);
        _lineView.backgroundColor = HTColorFromRGB(0xE2E4E8);
    }
    return _lineView;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint myPoint = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, myPoint)) {
                return subView;
            }
        }
    }
    return view;
}
@end





@interface CommentPostRoleSelectView ()
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) NSArray *data;
@end
@implementation CommentPostRoleSelectView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        //        [self addSubview:self.bgView];
        
        [self setupItems];
    }
    return self;
}
- (void)setupItems {
    int i = 0;
    CGFloat max = SCREENW;
    CGFloat height = 53;
    for (NSDictionary *dict in self.data) {
        UIButton *button = [self button];
        [button setTitle:dict[@"name"] forState:UIControlStateNormal];
        [button setImage:[BundleTool imageNamed:dict[@"icon"]] forState:UIControlStateNormal];
        button.frame = CGRectMake(0, height*i, max, height);
        button.tag = i;
        i++;
        [self addSubview:button];
    }
    
    for (int j = 1; j <= self.data.count; j++) {
        UIImageView *line = [self lineView];
        line.frame = CGRectMake(0, j*52, max, 1);
        [self addSubview:line];
    }
    
    self.frame = CGRectMake(0, -height*3+1, max, height*3);
    [self cornerRadius:8 rectCorner:UIRectCornerTopLeft|UIRectCornerTopRight];
}

- (UIImageView *)bgView {
    if (!_bgView) {
        _bgView = [[UIImageView alloc] init];
        //        _popView.image = [BundleTool imageNamed:@"activity_role_pop"];
        UIImage *image = [BundleTool imageNamed:@"activity_role_pop"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 100, 90) resizingMode:UIImageResizingModeStretch];
        _bgView.image = image;
    }
    return _bgView;
}
- (NSArray *)data {
    if (!_data) {
        NSString *company = [PublicTool isNull:[WechatUserInfo shared].company]?@"":[WechatUserInfo shared].company;
        NSString *zhiwei = [PublicTool isNull:[WechatUserInfo shared].zhiwei]?@"":[WechatUserInfo shared].zhiwei;

        NSString *name = [NSString stringWithFormat:@"实名：%@ %@ %@", [WechatUserInfo shared].nickname, company, zhiwei];
        NSString *name2 = [NSString stringWithFormat:@"公司：%@员工", company];
        NSString *role = [NSString stringWithFormat:@"身份：%@", [PublicTool roleTextWithRequestStr:[WechatUserInfo shared].person_role]];
        _data = @[
                  @{@"name": name, @"anonymous":@"0", @"degree":@"", @"icon":@"activity_comment_role1"},
                  @{@"name": name2, @"anonymous":@"1", @"degree":@"1", @"icon":@"activity_comment_role2"},
                  @{@"name": role, @"anonymous":@"1", @"degree":@"2", @"icon":@"activity_comment_role3"},
                  ];
    }
    return _data;
}

- (UIImageView *)lineView {
    UIImageView *line = [[UIImageView alloc] init];
    line.frame = CGRectMake(0, 46, 0, 1);
    line.backgroundColor = HTColorFromRGB(0xF5F5F5);
    return line;
}
- (UIButton *)button {
    UIButton *button = [[UIButton alloc] init];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:HTColorFromRGB(0x333333) forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 23, 0, 0);
    return button;
}
@end
