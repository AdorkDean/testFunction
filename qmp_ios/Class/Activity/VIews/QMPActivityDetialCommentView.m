//
//  QMPActivityDetialCommentView.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/11.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "QMPActivityDetialCommentView.h"
#import "QMPActivityDetialBarView.h"
#import "ActivityCommentModel.h"
@interface QMPActivityDetialCommentView () <NSLayoutManagerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>
@property (nonatomic, strong) QMPActivityDetialCommentTextView *commentTextView;
@property (nonatomic, assign) CGFloat defaultHeight;

@property (nonatomic, strong) UIView *roleView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIImageView *arrowView;

@property (nonatomic, strong) CommentPostRoleSelectView *roleSelectView;

@property (nonatomic, weak) UILabel *placeLabel;
@property (nonatomic, strong) UIView *maskView2;
@end
@implementation QMPActivityDetialCommentView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = H568COLOR;
        self.defaultHeight = 50;
        [self addSubview:self.commentTextView];
        [self addSubview:self.roleView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboard:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboard:) name:UIKeyboardWillHideNotification object:nil];
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

- (void)anonymousButtonClick:(UIButton *)button {
    button.selected = !button.selected;
}
- (void)textViewDidChange:(UITextView *)textView {
 
    if (textView.text.length > 1000) {
        [PublicTool showMsg:@"最多1000字"];
        textView.text = [textView.text substringToIndex:1000];
    }
    
    static CGFloat maxHeight = 74.0f;
    static CGFloat minHeight = 36.0f;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height<=frame.size.height) {
        if (size.height <= minHeight) {
            size.height = minHeight;
        }
    }else{
        if (size.height >= maxHeight)
        {
            size.height = maxHeight;
            textView.scrollEnabled = YES;   // 允许滚动
        }
        else
        {
            textView.scrollEnabled = NO;    // 不允许滚动
        }
    }
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    CGFloat top = self.top;
    CGFloat height = self.height;
    self.frame = CGRectMake(0, top - (size.height+17-height), SCREENW, size.height+17);
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        QMPLog(@"发布评论");
        [self postCommentButtonClick];
        return NO;
    }
    return YES;
}
- (void)postCommentButtonClick {
    
    
    NSString *s = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:s?:@"" forKey:@"comment"];
    [paramDict setValue:self.anonymous2 forKey:@"anonymous"];
    [paramDict setValue:self.degree2 forKey:@"anonymous_degree"];
    [paramDict setValue:self.activityTicket forKey:@"relate_id"];
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/activityComment" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            ActivityCommentModel *model = [ActivityCommentModel activityDetail_commentModelWithResponse:resultData];
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"ActivityPostComment" object:self userInfo:@{@"comment":model}];
            if (self.activityCommentPost) {
                self.activityCommentPost(model);
            }
            self.commentTextView.text = @"";
            
            [PublicTool showMsg:@"评论成功"];
            [self hide];
        } else {
            [PublicTool showMsg:@"评论失败"];
        }
    }];
}

#pragma mark - Public

- (void)show {
    UIView *maskView = [[UIView alloc] init];
    maskView.frame = CGRectMake(0, 0, SCREENW, SCREENH);
    maskView.backgroundColor = RGBa(0, 0, 0, 0.3);
    [[UIApplication sharedApplication].keyWindow addSubview:maskView];
    self.maskView2 = maskView;
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    tapGest.delegate = self;
    [maskView addGestureRecognizer:tapGest];
    
    self.frame = CGRectMake(0, SCREENH-self.defaultHeight, SCREENW, self.defaultHeight);
    [maskView addSubview:self];
    
    [self.commentTextView becomeFirstResponder];
}
- (void)hide {
    [self.commentTextView resignFirstResponder];
    [self.maskView2 removeFromSuperview];
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
- (QMPActivityDetialCommentTextView *)commentTextView {
    if (!_commentTextView) {
        _commentTextView = [[QMPActivityDetialCommentTextView alloc] init];
        _commentTextView.frame = CGRectMake(112, 7, SCREENW-112-13, 36);
        _commentTextView.placeholder = @"写评论...";
        _commentTextView.font = [UIFont systemFontOfSize:15];
        _commentTextView.textColor = H3COLOR;
        _commentTextView.layer.borderWidth = 1;
        _commentTextView.layer.borderColor = [HTColorFromRGB(0xE2E4E8) CGColor];
        _commentTextView.layer.cornerRadius = 18;
        _commentTextView.clipsToBounds = YES;
        _commentTextView.textContainerInset = UIEdgeInsetsMake(8, 8, 6, 8);
        _commentTextView.layoutManager.delegate = self;
        _commentTextView.delegate = self;
        _commentTextView.backgroundColor = HTColorFromRGB(0xEAEAEA);
        _commentTextView.returnKeyType = UIReturnKeySend;
        _commentTextView.enablesReturnKeyAutomatically = YES;
    }
    return _commentTextView;
}


- (UIView *)roleView {
    if (!_roleView) {
        _roleView = [[UIView alloc] init];
        _roleView.frame = CGRectMake(13, 10, 86, 31);
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
        arrowView.image = [UIImage imageNamed:@"activity_role_arrow"];
        [_roleView addSubview:arrowView];
        self.arrowView = arrowView;
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(roleViewTap)];
        [_roleView addGestureRecognizer:tapGest];
    }
    return _roleView;
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
- (void)roleViewTap {
    
    self.arrowView.transform = CGAffineTransformRotate(self.arrowView.transform, M_PI);
    
    if (self.roleSelectView.superview) {
        [self.roleSelectView removeFromSuperview];
    } else {
        [self addSubview:self.roleSelectView];
    }
    
}
- (CommentPostRoleSelectView *)roleSelectView {
    if (!_roleSelectView) {
        _roleSelectView = [[CommentPostRoleSelectView alloc] init];
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(roleSelectViewTap:)];
        [_roleSelectView addGestureRecognizer:tapGest];
    }
    return _roleSelectView;
}
- (void)roleSelectViewTap:(UITapGestureRecognizer *)tapGest {
    UIView *view = tapGest.view;
    CGFloat height = view.height / 3;
    
    CGPoint p = [tapGest locationInView:view];
    
    self.anonymous2 = p.y > height ? @"1" : @"0";
    self.degree2 = p.y > height *2 ? @"1" : @"2";
    
    if (self.roleSelectView.superview) {
        [self.roleSelectView removeFromSuperview];
    }
    [self updateRoleShow];
    if (self.roleDidTap) {
        self.roleDidTap(self.anonymous2, self.degree2);
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
@end


@implementation QMPActivityDetialCommentTextView

@end
