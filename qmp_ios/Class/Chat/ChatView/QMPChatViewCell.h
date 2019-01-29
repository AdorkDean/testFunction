//
//  QMPChatViewCell.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/11/14.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "EaseBaseMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMPChatViewCell : EaseBaseMessageCell


@property (nonatomic, copy) void(^okButtonClick)(NSString *aid);
@property (nonatomic, copy) void(^noOkButtonClick)(NSString *aid);

- (void)setExStatus:(NSString *)s;  // s: 0, 1, -1
@end


@interface EaseBubbleView (A)


-(void)setUpABubbleView;


- (void)updateAMargin:(UIEdgeInsets)margin;

- (void)_setUpABubbleMarginConstraints;

@end


@interface QMPChatViewCell2 : EaseBaseMessageCell


@property (nonatomic, copy) void(^okButtonClick2)(void);
@end

@interface EaseBubbleView (B)


-(void)setUpBBubbleView;


- (void)updateBMargin:(UIEdgeInsets)margin;

- (void)_setUpBBubbleMarginConstraints;

@end


@interface QMPChatBPViewCell : EaseBaseMessageCell


@property (nonatomic, copy) void(^okButtonClickBP)(NSString *url, NSString *name, NSString *fid);
@end

@interface EaseBubbleView (BP)


-(void)setUpBPBubbleView;


- (void)updateBPMargin:(UIEdgeInsets)margin;

- (void)_setUpBPBubbleMarginConstraints;

@end
NS_ASSUME_NONNULL_END
