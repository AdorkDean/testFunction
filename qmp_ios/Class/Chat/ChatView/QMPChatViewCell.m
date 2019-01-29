//
//  QMPChatViewCell.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/11/14.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "QMPChatViewCell.h"
#import <UIImageView+WebCache.h>
#import <UIImage+GIF.h>
#import "IMessageModel.h"


@interface QMPChatViewCell ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;

@end
@implementation QMPChatViewCell
- (void)setExStatus:(NSString *)s {
    NSInteger status = [s integerValue];
    
//    if (status == 2) { // 拒绝
//        self.bubbleView.okButton.hidden = YES;
//        self.bubbleView.noOkButton.hidden = YES;
//        self.bubbleView.grayButton.hidden = NO;
//        self.bubbleView.grayButton.selected = YES;
//    } else
//    if (status == 3) { // 同意
//        self.bubbleView.okButton.hidden = YES;
//        self.bubbleView.noOkButton.hidden = YES;
//        self.bubbleView.grayButton.hidden = NO;
//        self.bubbleView.grayButton.selected = NO;
//    }
//    else {
//        self.bubbleView.okButton.hidden = NO;
//        self.bubbleView.noOkButton.hidden = NO;
//        self.bubbleView.grayButton.hidden = YES;
//        self.bubbleView.grayButton.selected = YES;
//    }
}
- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return YES;
}

- (void)setCustomModel:(id<IMessageModel>)model
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.model.message.ext];
    NSString *type = dict[@"type"];
    if ([type containsString:@"wechat"]) {
        self.bubbleView.msgLabel.text = [NSString stringWithFormat:@"%@申请和你交换微信号",model.nickname];
    } else {
        self.bubbleView.msgLabel.text = [NSString stringWithFormat:@"%@申请和你交换手机号",model.nickname];
    }
    
    
    if ([dict.allKeys containsObject:@"ok"]) {
    NSString *a = dict[@"ok"];
    
        if ([a isEqualToString:@"-1"]) {
            _bubbleView.okButton.hidden = YES;
            _bubbleView.noOkButton.hidden = YES;
            _bubbleView.grayButton.hidden = NO;
            _bubbleView.grayButton.selected = YES;
        } else if ([a isEqualToString:@"1"]) {
            _bubbleView.okButton.hidden = YES;
            _bubbleView.noOkButton.hidden = YES;
            _bubbleView.grayButton.hidden = NO;
            _bubbleView.grayButton.selected = NO;
        } else {
            _bubbleView.okButton.hidden = NO;
            _bubbleView.noOkButton.hidden = NO;
            _bubbleView.grayButton.hidden = YES;
        }
    }
    
    
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    [_bubbleView setUpABubbleView];
    
    [_bubbleView.okButton addTarget:self action:@selector(okClick) forControlEvents:UIControlEventTouchUpInside];
    [_bubbleView.noOkButton addTarget:self action:@selector(noOkClick) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)okClick {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.model.message.ext];
    [dict setValue:@"1" forKey:@"ok"];
    NSString *aid = dict[@"aid"];
    self.model.message.ext = dict;
    [[EMClient sharedClient].chatManager updateMessage:self.model.message completion:^(EMMessage *aMessage, EMError *aError) {
        
    }];
    
    _bubbleView.okButton.hidden = YES;
    _bubbleView.noOkButton.hidden = YES;
    _bubbleView.grayButton.hidden = NO;
    _bubbleView.grayButton.selected = NO;
    
    if(self.okButtonClick) {
        self.okButtonClick(aid);
    }
    
}
- (void)noOkClick {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.model.message.ext];
    [dict setValue:@"-1" forKey:@"ok"];
    NSString *aid = dict[@"aid"];
    self.model.message.ext = dict;
    [[EMClient sharedClient].chatManager updateMessage:self.model.message completion:^(EMMessage *aMessage, EMError *aError) {
        
    }];
    
    _bubbleView.okButton.hidden = YES;
    _bubbleView.noOkButton.hidden = YES;
    _bubbleView.grayButton.hidden = NO;
    _bubbleView.grayButton.selected = YES;
    if(self.noOkButtonClick) {
        self.noOkButtonClick(aid);
    }
}
- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    [_bubbleView updateAMargin:UIEdgeInsetsZero];
}


/*!
 @method
 @brief 获取cell的重用标识
 @discussion
 @param model   消息model
 @return 返回cell的重用标识
 */
+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    return @"EaseMessageCellSendPhone";
}

/*!
 @method
 @brief 获取cell的高度
 @discussion
 @param model   消息model
 @return  返回cell的高度
 */
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    return 78+25;
}
@end


@implementation EaseBubbleView (A)


-(void)setUpABubbleView {
    
    self.msgLabel = [[UILabel alloc] init];
    self.msgLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.msgLabel.font = [UIFont systemFontOfSize:15];
    self.msgLabel.numberOfLines = 0;
    self.msgLabel.textColor = H3COLOR;
    self.msgLabel.textAlignment = NSTextAlignmentCenter;
    [self.backgroundImageView addSubview:self.msgLabel];
    
    
    self.okButton = [[UIButton alloc] init];
    self.okButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.okButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.okButton setTitle:@"同意" forState:UIControlStateNormal];
    [self.okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.okButton.backgroundColor = HTColorFromRGB(0x006EDA);
    [self.backgroundImageView addSubview:self.okButton];
    
    self.noOkButton = [[UIButton alloc] init];
    self.noOkButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.noOkButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.noOkButton setTitle:@"拒绝" forState:UIControlStateNormal];
    [self.noOkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.noOkButton.backgroundColor = HTColorFromRGB(0x2292F9);
    [self.backgroundImageView addSubview:self.noOkButton];
    
    self.grayButton = [[UIButton alloc] init];
    self.grayButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.grayButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.grayButton setTitle:@"已同意" forState:UIControlStateNormal];
    [self.grayButton setTitle:@"已拒绝" forState:UIControlStateSelected];
    [self.grayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.grayButton.backgroundColor = HTColorFromRGB(0xCCCCCC);
    [self.backgroundImageView addSubview:self.grayButton];
    self.grayButton.hidden = YES;
    

    
    [self _setUpABubbleMarginConstraints];
    
}

- (void)updateAMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setUpABubbleMarginConstraints];
}


-(void)_setUpABubbleMarginConstraints{
    [self.marginConstraints removeAllObjects];
    
    NSLayoutConstraint *titleWithMarginTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.msgLabel
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:14];
    
    NSLayoutConstraint *titleWithMarginRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.msgLabel
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-12];
    
    NSLayoutConstraint *titleWithMarginLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.msgLabel
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1.0
                                  constant:12];
    
//    NSLayoutConstraint *titleBottomConstraint =
//    [NSLayoutConstraint constraintWithItem:self.msgLabel
//                                 attribute:NSLayoutAttributeBottom
//                                 relatedBy:NSLayoutRelationEqual
//                                    toItem:self.backgroundImageView
//                                 attribute:NSLayoutAttributeBottom
//                                multiplier:1.0
//                                  constant:-50];
    
    NSLayoutConstraint *titleHConstraint =
    [NSLayoutConstraint constraintWithItem:self.msgLabel
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:15];
//    titleHConstraint.priority = UILayoutPriorityDefaultHigh;
//    titleBottomConstraint.priority = UILayoutPriorityDefaultLow;
    
    
    
    [self.marginConstraints addObject:titleWithMarginTopConstraint];
    [self.marginConstraints addObject:titleWithMarginRightConstraint];
    [self.marginConstraints addObject:titleWithMarginLeftConstraint];
//    [self.marginConstraints addObject:titleBottomConstraint];
    [self.marginConstraints addObject:titleHConstraint];
    
    
    NSLayoutConstraint *contentTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.okButton
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:35];
    
    NSLayoutConstraint *contentlLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.okButton
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeWidth
                                multiplier:0.5
                                  constant:-2];
    
    NSLayoutConstraint *contentlRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.okButton
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:0];
    
    NSLayoutConstraint *contentlBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.okButton
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0];
    
    [self.marginConstraints addObject:contentTopConstraint];
    [self.marginConstraints addObject:contentlLeftConstraint];
    [self.marginConstraints addObject:contentlRightConstraint];
    [self.marginConstraints addObject:contentlBottomConstraint];
    
    
    NSLayoutConstraint *acontentTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.noOkButton
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:35];
    
    NSLayoutConstraint *acontentlLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.noOkButton
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1.0
                                  constant:4];
    
    NSLayoutConstraint *acontentlRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.noOkButton
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeWidth
                                multiplier:0.5
                                  constant:-2];
    
    NSLayoutConstraint *acontentlBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.noOkButton
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0];
    
    [self.marginConstraints addObject:acontentTopConstraint];
    [self.marginConstraints addObject:acontentlLeftConstraint];
    [self.marginConstraints addObject:acontentlRightConstraint];
    [self.marginConstraints addObject:acontentlBottomConstraint];
    
    
    NSLayoutConstraint *bcontentTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.grayButton
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:35];
    
    NSLayoutConstraint *bcontentlLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.grayButton
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1.0
                                  constant:4];
    
    NSLayoutConstraint *bcontentlRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.grayButton
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeWidth
                                multiplier:1
                                  constant:-4];
    
    NSLayoutConstraint *bcontentlBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.grayButton
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0];
    
    [self.marginConstraints addObject:bcontentTopConstraint];
    [self.marginConstraints addObject:bcontentlLeftConstraint];
    [self.marginConstraints addObject:bcontentlRightConstraint];
    [self.marginConstraints addObject:bcontentlBottomConstraint];
    
    
    [self addConstraints:self.marginConstraints];
    
    NSLayoutConstraint *backImageConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:216];

    [self.superview addConstraint:backImageConstraint];
    
//    [self.superview layoutIfNeeded];
//    [self.backgroundImageView layoutIfNeeded];
    
    [self.noOkButton layoutIfNeeded];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.noOkButton.bounds byRoundingCorners: UIRectCornerBottomLeft cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.noOkButton.bounds;
    maskLayer.path = maskPath.CGPath;
    self.noOkButton.layer.mask = maskLayer;
    
    [self.okButton layoutIfNeeded];
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:self.okButton.bounds byRoundingCorners: UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = self.okButton.bounds;
    maskLayer2.path = maskPath2.CGPath;
    self.okButton.layer.mask = maskLayer2;
    
    [self.grayButton layoutIfNeeded];
    UIBezierPath *maskPath3 = [UIBezierPath bezierPathWithRoundedRect:self.grayButton.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer3 = [[CAShapeLayer alloc] init];
    maskLayer3.frame = self.okButton.bounds;
    maskLayer3.path = maskPath3.CGPath;
    self.grayButton.layer.mask = maskLayer3;
    
    
}
- (void)_setupABubbleConstraints
{
    [self _setUpABubbleMarginConstraints];
}


@end

/***********************************/

@interface QMPChatViewCell2 ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;

@end
@implementation QMPChatViewCell2

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return YES;
}

- (void)setCustomModel:(id<IMessageModel>)model
{
//    self.bubbleView.msgLabel.text = [NSString stringWithFormat:@"%@申请和你交换手机号",model.nickname];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.model.message.ext];
    
    NSString *type = dict[@"type"];
    if ([type containsString:@"wechat"]) {
        self.bubbleView.msgLabel.text = dict[@"wechat"];
        self.bubbleView.msg2Label.text = [NSString stringWithFormat:@"%@的微信号", dict[@"userNick"]];
        self.bubbleView.okButton.hidden = YES;
        self.bubbleView.noOkButton.hidden = YES;
        self.bubbleView.grayButton.hidden = NO;
        self.bubbleView.grayButton.backgroundColor = HTColorFromRGB(0x006EDA);
        [self.bubbleView.grayButton setTitle:@"复制并打开微信" forState:UIControlStateNormal];
    } else {
        self.bubbleView.msgLabel.text = dict[@"phone"];
        self.bubbleView.msg2Label.text = [NSString stringWithFormat:@"%@的手机号", dict[@"userNick"]];
        self.bubbleView.okButton.hidden = NO;
        self.bubbleView.noOkButton.hidden = NO;
        self.bubbleView.grayButton.hidden = YES;
    }
    
    [self.bubbleView.grayButton addTarget:self action:@selector(grayButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)grayButtonClick {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.model.message.ext];
    if (![PublicTool isNull:dict[@"wechat"]]) {
        [UIPasteboard generalPasteboard].string = dict[@"wechat"];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"wechat://"]];
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    [_bubbleView setUpBBubbleView];
    
    [_bubbleView.okButton addTarget:self action:@selector(okClick) forControlEvents:UIControlEventTouchUpInside];
    [_bubbleView.noOkButton addTarget:self action:@selector(noOkClick) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)okClick {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.model.message.ext];
//    [UIPasteboard generalPasteboard].string = dict[@"phone"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",dict[@"phone"]]];
    [[UIApplication sharedApplication] openURL:url];
    
}
- (void)noOkClick {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.model.message.ext];
    [UIPasteboard generalPasteboard].string = dict[@"phone"];
    [PublicTool showMsg:@"复制成功"];
}
- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    [_bubbleView updateBMargin:UIEdgeInsetsZero];
}


/*!
 @method
 @brief 获取cell的重用标识
 @discussion
 @param model   消息model
 @return 返回cell的重用标识
 */
+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    return @"EaseMessageCellSendPhone2";
}

/*!
 @method
 @brief 获取cell的高度
 @discussion
 @param model   消息model
 @return  返回cell的高度
 */
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    return 78+25;
}
@end


@implementation EaseBubbleView (B)


-(void)setUpBBubbleView {
    
    self.msgLabel = [[UILabel alloc] init];
    self.msgLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.msgLabel.font = [UIFont systemFontOfSize:15];
    self.msgLabel.numberOfLines = 0;
    self.msgLabel.textColor = HTColorFromRGB(0x006EDA);
    self.msgLabel.textAlignment = NSTextAlignmentCenter;
    [self.backgroundImageView addSubview:self.msgLabel];
    
    self.msg2Label = [[UILabel alloc] init];
    self.msg2Label.translatesAutoresizingMaskIntoConstraints = NO;
    self.msg2Label.font = [UIFont systemFontOfSize:11];
    self.msg2Label.numberOfLines = 0;
    self.msg2Label.textColor = HTColorFromRGB(0x999999);
    self.msg2Label.textAlignment = NSTextAlignmentCenter;
    [self.backgroundImageView addSubview:self.msg2Label];
    
    
    self.okButton = [[UIButton alloc] init];
    self.okButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.okButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.okButton setTitle:@"拨打" forState:UIControlStateNormal];
    [self.okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.okButton.backgroundColor = HTColorFromRGB(0x006EDA);
    [self.backgroundImageView addSubview:self.okButton];
    
    self.noOkButton = [[UIButton alloc] init];
    self.noOkButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.noOkButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.noOkButton setTitle:@"复制" forState:UIControlStateNormal];
    [self.noOkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.noOkButton.backgroundColor = HTColorFromRGB(0x2292F9);
    [self.backgroundImageView addSubview:self.noOkButton];
    
    self.grayButton = [[UIButton alloc] init];
    self.grayButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.grayButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.grayButton setTitle:@"已同意" forState:UIControlStateNormal];
    [self.grayButton setTitle:@"已拒绝" forState:UIControlStateSelected];
    [self.grayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.grayButton.backgroundColor = HTColorFromRGB(0xCCCCCC);
    [self.backgroundImageView addSubview:self.grayButton];
    self.grayButton.hidden = YES;
    
    
    
    [self _setUpBBubbleMarginConstraints];
    
}

- (void)updateBMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setUpBBubbleMarginConstraints];
}


-(void)_setUpBBubbleMarginConstraints{
    [self.marginConstraints removeAllObjects];
    
    NSLayoutConstraint *titleWithMarginTopConstraint2 =
    [NSLayoutConstraint constraintWithItem:self.msg2Label
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:8];
    
    NSLayoutConstraint *titleWithMarginRightConstraint2 =
    [NSLayoutConstraint constraintWithItem:self.msg2Label
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-12];
    
    NSLayoutConstraint *titleWithMarginLeftConstraint2 =
    [NSLayoutConstraint constraintWithItem:self.msg2Label
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1.0
                                  constant:12];
    
    NSLayoutConstraint *titleHConstraint2 =
    [NSLayoutConstraint constraintWithItem:self.msg2Label
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:14];
    
    
    
    [self.marginConstraints addObject:titleWithMarginTopConstraint2];
    [self.marginConstraints addObject:titleWithMarginRightConstraint2];
    [self.marginConstraints addObject:titleWithMarginLeftConstraint2];
    [self.marginConstraints addObject:titleHConstraint2];
    
    NSLayoutConstraint *titleWithMarginTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.msgLabel
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:26];
    
    NSLayoutConstraint *titleWithMarginRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.msgLabel
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-12];
    
    NSLayoutConstraint *titleWithMarginLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.msgLabel
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1.0
                                  constant:12];
    
    
    NSLayoutConstraint *titleHConstraint =
    [NSLayoutConstraint constraintWithItem:self.msgLabel
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:20];

    
    
    [self.marginConstraints addObject:titleWithMarginTopConstraint];
    [self.marginConstraints addObject:titleWithMarginRightConstraint];
    [self.marginConstraints addObject:titleWithMarginLeftConstraint];
    [self.marginConstraints addObject:titleHConstraint];
    
    
    NSLayoutConstraint *contentTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.okButton
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:35];
    
    NSLayoutConstraint *contentlLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.okButton
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeWidth
                                multiplier:0.5
                                  constant:-2];
    
    NSLayoutConstraint *contentlRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.okButton
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:0];
    
    NSLayoutConstraint *contentlBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.okButton
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0];
    
    [self.marginConstraints addObject:contentTopConstraint];
    [self.marginConstraints addObject:contentlLeftConstraint];
    [self.marginConstraints addObject:contentlRightConstraint];
    [self.marginConstraints addObject:contentlBottomConstraint];
    
    
    NSLayoutConstraint *acontentTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.noOkButton
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:35];
    
    NSLayoutConstraint *acontentlLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.noOkButton
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1.0
                                  constant:4];
    
    NSLayoutConstraint *acontentlRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.noOkButton
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeWidth
                                multiplier:0.5
                                  constant:-2];
    
    NSLayoutConstraint *acontentlBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.noOkButton
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0];
    
    [self.marginConstraints addObject:acontentTopConstraint];
    [self.marginConstraints addObject:acontentlLeftConstraint];
    [self.marginConstraints addObject:acontentlRightConstraint];
    [self.marginConstraints addObject:acontentlBottomConstraint];
    
    
    NSLayoutConstraint *bcontentTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.grayButton
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:35];
    
    NSLayoutConstraint *bcontentlLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.grayButton
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1.0
                                  constant:4];
    
    NSLayoutConstraint *bcontentlRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.grayButton
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeWidth
                                multiplier:1
                                  constant:-4];
    
    NSLayoutConstraint *bcontentlBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.grayButton
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0];
    
    [self.marginConstraints addObject:bcontentTopConstraint];
    [self.marginConstraints addObject:bcontentlLeftConstraint];
    [self.marginConstraints addObject:bcontentlRightConstraint];
    [self.marginConstraints addObject:bcontentlBottomConstraint];
    
    
    [self addConstraints:self.marginConstraints];
    
    NSLayoutConstraint *backImageConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:216];
    
    [self.superview addConstraint:backImageConstraint];
    
    //    [self.superview layoutIfNeeded];
    //    [self.backgroundImageView layoutIfNeeded];
    
    [self.noOkButton layoutIfNeeded];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.noOkButton.bounds byRoundingCorners: UIRectCornerBottomLeft cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.noOkButton.bounds;
    maskLayer.path = maskPath.CGPath;
    self.noOkButton.layer.mask = maskLayer;
    
    [self.okButton layoutIfNeeded];
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:self.okButton.bounds byRoundingCorners: UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = self.okButton.bounds;
    maskLayer2.path = maskPath2.CGPath;
    self.okButton.layer.mask = maskLayer2;
    
    [self.grayButton layoutIfNeeded];
    UIBezierPath *maskPath3 = [UIBezierPath bezierPathWithRoundedRect:self.grayButton.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer3 = [[CAShapeLayer alloc] init];
    maskLayer3.frame = self.okButton.bounds;
    maskLayer3.path = maskPath3.CGPath;
    self.grayButton.layer.mask = maskLayer3;
    
    
}
- (void)_setupBBubbleConstraints
{
    [self _setUpBBubbleMarginConstraints];
}


@end



/******************************************/

@interface QMPChatBPViewCell ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;

@end
@implementation QMPChatBPViewCell

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return YES;
}

- (void)setCustomModel:(id<IMessageModel>)model
{
    //    self.bubbleView.msgLabel.text = [NSString stringWithFormat:@"%@申请和你交换手机号",model.nickname];
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.model.message.ext];
//
    self.bubbleView.msgLabel.text = dict[@"bpname"];
//    self.bubbleView.msg2Label.text = [NSString stringWithFormat:@"%@的手机号", dict[@"userNick"]];

    
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.model.isSender) {
        _bubbleView.backgroundImageView.image = [[UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_bg3"] stretchableImageWithLeftCapWidth:35 topCapHeight:35];
    } else {
        _bubbleView.backgroundImageView.image = [[UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_bg2"] stretchableImageWithLeftCapWidth:35 topCapHeight:35];
    }
}
- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    [_bubbleView setUpBPBubbleView];
    
  
    [_bubbleView.grayButton addTarget:self action:@selector(lookClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}
- (void)lookClick {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.model.message.ext];
    
    NSString *url = dict[@"bpurl"];
    
    if (self.okButtonClickBP) {
        self.okButtonClickBP(url, dict[@"bpname"], dict[@"bpid"]);
    }
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    [_bubbleView updateBPMargin:UIEdgeInsetsZero];
}


/*!
 @method
 @brief 获取cell的重用标识
 @discussion
 @param model   消息model
 @return 返回cell的重用标识
 */
+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    return @"EaseMessageCellSendPhoneBPPPPPP";
}

/*!
 @method
 @brief 获取cell的高度
 @discussion
 @param model   消息model
 @return  返回cell的高度
 */
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    return 78+25;
}
@end


@implementation EaseBubbleView (BP)


-(void)setUpBPBubbleView {
    
    self.bpiconView = [[UIImageView alloc] init];
    self.bpiconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bpiconView.backgroundColor = [UIColor whiteColor];
    self.bpiconView.image = [[UIImage imageNamed:@"EaseUIResource.bundle/chat_bp_icon"] stretchableImageWithLeftCapWidth:35 topCapHeight:35];
    [self.backgroundImageView addSubview:self.bpiconView];
    
    
    self.msgLabel = [[UILabel alloc] init];
    self.msgLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.msgLabel.font = [UIFont systemFontOfSize:15];
    self.msgLabel.numberOfLines = 1;
    self.msgLabel.textColor = HTColorFromRGB(0x333333);
    self.msgLabel.textAlignment = NSTextAlignmentLeft;
    [self.backgroundImageView addSubview:self.msgLabel];
    
    self.grayButton = [[UIButton alloc] init];
    self.grayButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.grayButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.grayButton setTitle:@"查看" forState:UIControlStateNormal];
    [self.grayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.grayButton.backgroundColor = HTColorFromRGB(0x006EDA);
    [self.backgroundImageView addSubview:self.grayButton];
    
    
    
    [self _setUpBPBubbleMarginConstraints];
    
}

- (void)updateBPMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setUpBPBubbleMarginConstraints];
}


-(void)_setUpBPBubbleMarginConstraints{
    [self.marginConstraints removeAllObjects];

    NSLayoutConstraint *iconTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.bpiconView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1 constant:9];
    
    NSLayoutConstraint *iconLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.bpiconView
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1 constant:10];
    
    NSLayoutConstraint *iconWidthConstraint =
    [NSLayoutConstraint constraintWithItem:self.bpiconView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1 constant:25];
    
    NSLayoutConstraint *iconHeightConstraint =
    [NSLayoutConstraint constraintWithItem:self.bpiconView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1 constant:25];
    
    [self.marginConstraints addObject:iconTopConstraint];
    [self.marginConstraints addObject:iconLeftConstraint];
    [self.marginConstraints addObject:iconWidthConstraint];
    [self.marginConstraints addObject:iconHeightConstraint];
    
    NSLayoutConstraint *titleWithMarginTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.msgLabel
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.bpiconView
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0
                                  constant:0];
    
    NSLayoutConstraint *titleWithMarginRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.msgLabel
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-12];
    
    NSLayoutConstraint *titleWithMarginLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.msgLabel
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.bpiconView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:4];
    
    NSLayoutConstraint *titleHConstraint =
    [NSLayoutConstraint constraintWithItem:self.msgLabel
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:19];
    
    
    
    [self.marginConstraints addObject:titleWithMarginTopConstraint];
    [self.marginConstraints addObject:titleWithMarginRightConstraint];
    [self.marginConstraints addObject:titleWithMarginLeftConstraint];
    [self.marginConstraints addObject:titleHConstraint];
    
    
    
    
    
    
    NSLayoutConstraint *bcontentTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.grayButton
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:35];
    
    NSLayoutConstraint *bcontentlLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.grayButton
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1.0
                                  constant:self.isSender?0:4];
    
    NSLayoutConstraint *bcontentlRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.grayButton
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeWidth
                                multiplier:1
                                  constant:-4];
    
    NSLayoutConstraint *bcontentlBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.grayButton
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0];
    
    [self.marginConstraints addObject:bcontentTopConstraint];
    [self.marginConstraints addObject:bcontentlLeftConstraint];
    [self.marginConstraints addObject:bcontentlRightConstraint];
    [self.marginConstraints addObject:bcontentlBottomConstraint];
    
    
    [self addConstraints:self.marginConstraints];
    
    NSLayoutConstraint *backImageConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:216];
    
    [self.superview addConstraint:backImageConstraint];
    
    
    [self.grayButton layoutIfNeeded];
    UIBezierPath *maskPath3 = [UIBezierPath bezierPathWithRoundedRect:self.grayButton.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer3 = [[CAShapeLayer alloc] init];
    maskLayer3.frame = self.okButton.bounds;
    maskLayer3.path = maskPath3.CGPath;
    self.grayButton.layer.mask = maskLayer3;
    
    
}
- (void)_setupBPBubbleConstraints
{
    [self _setUpBBubbleMarginConstraints];
}


@end
