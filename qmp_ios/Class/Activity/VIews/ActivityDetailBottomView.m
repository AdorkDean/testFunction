//
//  ActivityDetailBottomView.m
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ActivityDetailBottomView.h"
#import "HMTextView.h"
#import "ActivityCommentModel.h"
#import "ActivityModel.h"
#import "ActivityShareViewController.h"
#import "QMPActivityCellModel.h"

@interface ActivityDetailBottomView ()
@property (nonatomic, strong) UIButton *commentHolderButton;
@property (nonatomic, strong) UIButton *upvoteButton;
@property (nonatomic, strong) UIButton *shareButton;

@property (nonatomic, strong) UIImageView *lineView;

@property (nonatomic, strong) ActivityDetailCommentView *commentView;
@end
@implementation ActivityDetailBottomView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.commentHolderButton];
        [self addSubview:self.upvoteButton];
        [self addSubview:self.shareButton];
        [self addSubview:self.lineView];
        
    }
    return self;
}
#pragma mark - Evnet
- (void)commentButtonClick {
    [self.commentView show];
    self.commentView.activity = self.activity;
    self.commentView.activityValueChanged = self.activityValueChanged;
    self.commentView.activityCommentPost = self.activityCommentPost;
}
- (void)setActivityID:(NSString *)activityID {
    _activityID = activityID;
    self.commentView.activityID = activityID;
}
- (void)setActivity:(ActivityModel *)activity {
    _activity = activity;
    
    self.commentView.activityTicket = activity.ticket;
    [self.upvoteButton setTitle:[self fixCountShow:activity.diggCount] forState:UIControlStateNormal];
    self.upvoteButton.selected = activity.isDigged;
}

- (NSString *)fixCountShow:(NSInteger)count {
    if (count <= 0) {
        return @"";
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
- (void)diggButtonClick:(UIButton *)button {
    
    if ([PublicTool isNull:self.activityID]) {
        return;
    }
    
    if ([PublicTool isNull:self.activityID]) {
        return;
    }
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    BOOL zanStatus = !self.activity.digged;
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [mDict setValue:self.activity.act_id forKey:@"project_id"];
    [mDict setValue:@(zanStatus) forKey:@"like"];
    
    [AppNetRequest likeOrCancelwithParam:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            [PublicTool showMsg: zanStatus == 0?@"取消点赞成功":@"点赞成功"];
            self.activity.digged = zanStatus;
            self.activity.diggCount += (zanStatus==0?-1:1);
            [self.upvoteButton setTitle:[self fixCountShow:self.activity.diggCount] forState:UIControlStateNormal];
            self.upvoteButton.selected = zanStatus;
        }else{
            
            [PublicTool showMsg:zanStatus == 0?@"取消点赞失败":@"点赞失败"];
        }
        if (self.activityValueChanged) {
            self.activityValueChanged();
        }
    }];
}

-(void)shareButtonClick {
    ActivityShareViewController *vc = [[ActivityShareViewController alloc] init];
    vc.cellModel = [[QMPActivityCellModel alloc]initWithActivity:self.activity forCommunity:NO];
    if (self.activity.headerRelate) {
        vc.relateModel = self.activity.headerRelate;
    }
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
}
#pragma mark - Getter

- (UIButton *)commentHolderButton {
    if (!_commentHolderButton) {
        _commentHolderButton = [[UIButton alloc] init];
        _commentHolderButton.frame = CGRectMake(15, (45-30)/2.0, SCREENW-15-90, 30);
        _commentHolderButton.layer.cornerRadius = 15.0;
        _commentHolderButton.backgroundColor = HTColorFromRGB(0xF5F5F5);
        _commentHolderButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_commentHolderButton setTitleColor:H9COLOR forState:UIControlStateNormal];
        [_commentHolderButton setTitle:@"写评论..." forState:UIControlStateNormal];
        _commentHolderButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _commentHolderButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        [_commentHolderButton addTarget:self action:@selector(commentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentHolderButton;
}
- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [[UIButton alloc] init];
        _shareButton.frame = CGRectMake(SCREENW-45, 1, 45, 45);
        [_shareButton setImage:[BundleTool imageNamed:@"activity_cell_share"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _shareButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _shareButton.imageEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 0);
    }
    return _shareButton;
}

- (UIButton *)upvoteButton {
    if (!_upvoteButton) {
        _upvoteButton = [[UIButton alloc] init];
        _upvoteButton.frame = CGRectMake(SCREENW-45*2, 0, 45, 45);
        _upvoteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _upvoteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
        _upvoteButton.titleEdgeInsets = UIEdgeInsetsMake(-7, 11, 9, -11);
        _upvoteButton.titleLabel.font = [UIFont systemFontOfSize:10];
        _upvoteButton.titleLabel.backgroundColor = [UIColor whiteColor];
        [_upvoteButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [_upvoteButton setImage:[BundleTool imageNamed:@"activity_bottom_diggb"] forState:UIControlStateSelected];
        [_upvoteButton setImage:[BundleTool imageNamed:@"activity_cell_digg"] forState:UIControlStateNormal];
        [_upvoteButton addTarget:self action:@selector(diggButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _upvoteButton;
}
- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] init];
        _lineView.frame = CGRectMake(0, 0, SCREENW, 1);
        _lineView.backgroundColor = HTColorFromRGB(0xE2E4E8);
    }
    return _lineView;
}
- (ActivityDetailCommentView *)commentView {
    if (!_commentView) {
        _commentView = [[ActivityDetailCommentView alloc] init];
    }
    return _commentView;
}
@end


@interface ActivityDetailCommentView () <NSLayoutManagerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>
@property (nonatomic, strong) UIButton *anonymousButton;
@property (nonatomic, strong) HMTextView *commentTextView;
@property (nonatomic, strong) UIButton *postCommentButton;

@property (nonatomic, weak) UIView *maskView;

@property (nonatomic, strong) UIView *roleView;
@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIImageView *arrowView;

@property (nonatomic, strong) UIImageView *popView;
@property (nonatomic, weak) UIImageView *selectView1;
@property (nonatomic, weak) UIImageView *selectView2;

@end

@implementation ActivityDetailCommentView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = H568COLOR;
        self.defaultHeight = 170;
        [self addSubview:self.commentTextView];
        [self addSubview:self.postCommentButton];
//        [self addSubview:self.anonymousButton];
        [self addSubview:self.roleView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboard:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboard:) name:UIKeyboardWillHideNotification object:nil];
        
        [self updateRoleShow];
    }
    return self;
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)keyboard:(NSNotification *)noti {
    NSDictionary *userInfo = [noti userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:animationDuration delay:0.0f options:[self animationOptionsForCurve:animationCurve] animations:^{
        CGFloat keyboardY =  keyboardEndFrame.origin.y;
        CGFloat footerToolBarY = keyboardY- CGRectGetHeight(self.frame) - ((keyboardY+1 > SCREENH)? (isiPhoneX? 34: 0): 0);
        [self setTop:footerToolBarY];
    } completion:^(BOOL finished) {
    }];
}
- (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve {
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            break;
    }
    return kNilOptions;
}
- (void)postCommentButtonClick {
    
    
    NSString *s = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:s?:@"" forKey:@"comment"];
    [paramDict setValue:@(self.anonymous) forKey:@"anonymous"];
    [paramDict setValue:self.activityTicket forKey:@"relate_id"];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/activityComment" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            ActivityCommentModel *model = [ActivityCommentModel activityDetail_commentModelWithResponse:resultData];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"ActivityPostComment" object:self userInfo:@{@"comment":model}];
            if (self.activityCommentPost) {
                self.activityCommentPost(model);
            }
            self.commentTextView.text = @"";
            self.anonymousButton.selected = NO;
            self.postCommentButton.enabled = NO;
            
            [PublicTool showMsg:@"评论成功"];
            [self hide];
        } else {
            [PublicTool showMsg:@"评论失败"];
        }
    }];
}
- (void)anonymousButtonClick:(UIButton *)button {
    button.selected = !button.selected;
}
- (void)textViewDidChange:(UITextView *)textView {
    NSString *s = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.postCommentButton.enabled = (s.length > 0);
    
    if (textView.text.length > 1000) {
        [PublicTool showMsg:@"最多1000字"];
        textView.text = [textView.text substringToIndex:1000];
    }
}
#pragma mark - Public

- (void)autoAnonymous {
    [self anonymousButtonClick:self.anonymousButton];
}
- (void)show {
    UIView *maskView = [[UIView alloc] init];
    maskView.frame = CGRectMake(0, 0, SCREENW, SCREENH);
    maskView.backgroundColor = RGBa(0, 0, 0, 0.3);
    [[UIApplication sharedApplication].keyWindow addSubview:maskView];
    self.maskView = maskView;
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    tapGest.delegate = self;
    [maskView addGestureRecognizer:tapGest];
    
    self.frame = CGRectMake(0, SCREENH-self.defaultHeight, SCREENW, self.defaultHeight);
    [maskView addSubview:self];
    
    [self.commentTextView becomeFirstResponder];
}
- (void)hide {
    [self.commentTextView resignFirstResponder];
    [self.maskView removeFromSuperview];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self]) {
        return NO;
    }
    return YES;
}
- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return 4.0;
}
#pragma mark - Getter
- (HMTextView *)commentTextView {
    if (!_commentTextView) {
        _commentTextView = [[HMTextView alloc] init];
        _commentTextView.frame = CGRectMake(16, 18, SCREENW-32, 100);
        _commentTextView.placehoder = @"写评论...";
        _commentTextView.font = [UIFont systemFontOfSize:15];
        _commentTextView.textColor = NV_TITLE_COLOR;
        _commentTextView.layer.borderWidth = 0.5;
        _commentTextView.layer.borderColor = [HTColorFromRGB(0xE2E4E8) CGColor];
        _commentTextView.layer.cornerRadius = 4.0;
        _commentTextView.clipsToBounds = YES;
        _commentTextView.contentInset = UIEdgeInsetsMake(4, 0, 4, 0);
        _commentTextView.layoutManager.delegate = self;
        _commentTextView.delegate = self;
        _commentTextView.backgroundColor = [UIColor whiteColor];
    }
    return _commentTextView;
}
- (UIButton *)postCommentButton {
    if (!_postCommentButton) {
        _postCommentButton = [[UIButton alloc] init];
        _postCommentButton.frame = CGRectMake(SCREENW-70-16, self.defaultHeight-28-12, 70, 28);
        if (@available(iOS 8.2, *)) {
            _postCommentButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        }else{
            _postCommentButton.titleLabel.font = [UIFont systemFontOfSize:16];
        }
//        _postCommentButton.layer.cornerRadius = 2.0;
//        _postCommentButton.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
//        _postCommentButton.layer.borderWidth = 1.0;
        [_postCommentButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [_postCommentButton setTitleColor:COLOR737782 forState:UIControlStateDisabled];
        [_postCommentButton setTitle:@"发表" forState:UIControlStateNormal];
        [_postCommentButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_postCommentButton addTarget:self action:@selector(postCommentButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _postCommentButton.enabled = NO;
    }
    return _postCommentButton;
}
- (UIButton *)anonymousButton {
    if (!_anonymousButton) {
        UIButton *anonymousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        anonymousButton.frame = CGRectMake(16, self.defaultHeight-40-5, 66, 40);
        anonymousButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [anonymousButton setTitle:@"匿名" forState:UIControlStateNormal];
        [anonymousButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateSelected];
        [anonymousButton setTitleColor:COLOR737782 forState:UIControlStateNormal];
        [anonymousButton setImage:[BundleTool imageNamed:@"post_bar_anonymous"] forState:UIControlStateNormal];
        [anonymousButton setImage:[BundleTool imageNamed:@"post_bar_anonymousb"] forState:UIControlStateSelected];
        anonymousButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        anonymousButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, -6);
        [anonymousButton addTarget:self action:@selector(anonymousButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _anonymousButton = anonymousButton;
    }
    return _anonymousButton;
}

- (void)roleViewTap {
    self.arrowView.transform = CGAffineTransformRotate(self.arrowView.transform, M_PI);
    
    if (self.popView.superview) {
        [self.popView removeFromSuperview];
    } else {
        [self addSubview:self.popView];
    }
}
- (void)updateRoleShow {
    if (!self.anonymous) {
        self.nameLabel.text = [WechatUserInfo shared].nickname;
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:[WechatUserInfo shared].headimgurl]];
    } else {
        self.nameLabel.text = [WechatUserInfo shared].flower_name;
        self.iconView.image = [BundleTool imageNamed:@"activity_post_flower2"];
    }
    
    CGFloat maxW = SCREENW - self.postCommentButton.width - 34;
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(31, 5, MIN(self.nameLabel.width, maxW-31-27), 18);
    self.arrowView.left = self.nameLabel.right + 6;
    self.roleView.frame = CGRectMake(17, self.postCommentButton.centerY-14, self.nameLabel.width+31+27, 28);
    self.arrowView.transform = CGAffineTransformRotate(self.arrowView.transform, M_PI);
}
- (UIView *)roleView {
    if (!_roleView) {
        _roleView = [[UIView alloc] init];
        _roleView.frame = CGRectMake(0, 0, 100, 28);
        _roleView.layer.cornerRadius = 14.0;
        _roleView.clipsToBounds = YES;
        _roleView.backgroundColor = HTColorFromRGB(0x006EDA);
        
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.frame = CGRectMake(7, 4, 20, 20);
        iconView.layer.cornerRadius = 10;
        iconView.clipsToBounds = YES;
        [_roleView addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(31, 5, 100, 18);
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor whiteColor];
        [_roleView addSubview:label];
        self.nameLabel = label;
        
        UIImageView *arrowView = [[UIImageView alloc] init];
        arrowView.frame = CGRectMake(79, 10, 13, 8);
        arrowView.image = [BundleTool imageNamed:@"activity_role_arrow"];
        [_roleView addSubview:arrowView];
        self.arrowView = arrowView;
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(roleViewTap)];
        [_roleView addGestureRecognizer:tapGest];
    }
    return _roleView;
}
- (void)popViewTap:(UITapGestureRecognizer *)tapGest {
    UIView *v = tapGest.view;
    
    CGPoint p = [tapGest locationInView:v];
    
    self.anonymous = p.y > (self.popView.height / 2);
    
    self.selectView1.hidden = self.anonymous;
    self.selectView2.hidden = !self.anonymous;
    [self updateRoleShow];
    
    if (self.popView.superview) {
        [self.popView removeFromSuperview];
    }
}

- (UIImageView *)popView {
    if (!_popView) {
        _popView = [[UIImageView alloc] init];
        _popView.frame = CGRectMake(SCREENW-135-17, -94, 135, 107);
        _popView.backgroundColor = [UIColor clearColor];
        _popView.userInteractionEnabled = YES;
        //        _popView.image = [BundleTool imageNamed:@"activity_role_pop"];
        UIImage *image = [BundleTool imageNamed:@"activity_role_pop_left"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 100, 90) resizingMode:UIImageResizingModeStretch];
        _popView.image = image;
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popViewTap:)];
        [_popView addGestureRecognizer:tapGest];
        
        CGFloat maxW = SCREENW - 34;
        CGFloat maxLabelW = maxW - 48 - 38;
        
        UIView *item1 = [[UIView alloc] init];
        item1.frame = CGRectMake(6, 6, 135, 45);
        [_popView addSubview:item1];
        
        UIImageView *icon1 = [[UIImageView alloc] init];
        icon1.frame = CGRectMake(15, 11, 24, 24);
        icon1.layer.cornerRadius = 12;
        icon1.clipsToBounds = YES;
        [icon1 sd_setImageWithURL:[NSURL URLWithString:[WechatUserInfo shared].headimgurl]];
        [item1 addSubview:icon1];
        
        UILabel *label1 = [[UILabel alloc] init];
        label1.frame = CGRectMake(48, 13, 100, 20);
        label1.font = [UIFont systemFontOfSize:16];
        label1.textColor = H6COLOR;
        [item1 addSubview:label1];
        
        label1.text = [WechatUserInfo shared].nickname;
        [label1 sizeToFit];
        label1.frame = CGRectMake(48, 13, MIN(label1.width, maxLabelW), 20);
        
        UIImageView *selectView1 = [[UIImageView alloc] init];
        selectView1.frame = CGRectMake(label1.right+8, 17, 15, 10);
        selectView1.image = [BundleTool imageNamed:@"activity_post_select"];
        [item1 addSubview:selectView1];
        self.selectView1 = selectView1;
        
        UIImageView *line = [[UIImageView alloc] init];
        line.frame = CGRectMake(6, 46, 0, 1);
        line.backgroundColor = HTColorFromRGB(0xF5F5F5);
        [_popView addSubview:line];
        
        
        UIView *item2 = [[UIView alloc] init];
        item2.frame = CGRectMake(6, 46+6, 135, 45);
        [_popView addSubview:item2];
        
        UIImageView *icon2 = [[UIImageView alloc] init];
        icon2.frame = CGRectMake(15, 11, 24, 24);
        icon2.layer.cornerRadius = 12;
        icon2.clipsToBounds = YES;
        icon2.image = [BundleTool imageNamed:@"activity_post_flower"];
        [item2 addSubview:icon2];
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.frame = CGRectMake(31, 13, 100, 20);
        label2.font = [UIFont systemFontOfSize:16];
        label2.textColor = H6COLOR;
        [item2 addSubview:label2];
        
        label2.text = [WechatUserInfo shared].flower_name;
        [label2 sizeToFit];
        label2.frame = CGRectMake(48, 13, MIN(label2.width, maxLabelW), 20);
        
        UIImageView *selectView2 = [[UIImageView alloc] init];
        selectView2.frame = CGRectMake(105, 17, 15, 10);
        selectView2.image = [BundleTool imageNamed:@"activity_post_select"];
        selectView2.hidden = YES;
        [item2 addSubview:selectView2];
        self.selectView2 = selectView2;
        
        CGFloat w = MAX(label1.width, label2.width) + 48 + 38;
        selectView1.left = w - 15 - 15;
        selectView2.left = w - 15 - 15;
        _popView.frame = CGRectMake(17-6, self.roleView.top - 107, w+12, 107);
        line.frame = CGRectMake(6, 46+6, w, 1);
    }
    return _popView;
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
