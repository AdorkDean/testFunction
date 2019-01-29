//
//  EaseBubbleView+Share.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2017/12/25.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "EaseBubbleView+Share.h"

@interface EaseBubbleView()


@end


@implementation EaseBubbleView (Share)


-(void)setUpShareBubbleView{
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = H9COLOR;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.backgroundImageView addSubview:self.titleLabel];
    
    self.content = [[UILabel alloc]init];
    self.content.font = [UIFont systemFontOfSize:12];
    self.content.numberOfLines = 0;
    self.content.textColor = H5COLOR;
    self.content.translatesAutoresizingMaskIntoConstraints = NO;
    self.content.textAlignment = NSTextAlignmentLeft;
    [self.backgroundImageView addSubview:self.content];
    
    
    self.imageShareView = [[UIImageView alloc]init];
    self.imageShareView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundImageView addSubview:self.imageShareView];
    [self _setUpShareBubbleMarginConstraints];
    
}

- (void)updateShareMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setUpShareBubbleMarginConstraints];
}


-(void)_setUpShareBubbleMarginConstraints{
    [self.marginConstraints removeAllObjects];
    
    NSLayoutConstraint *titleWithMarginTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.titleLabel
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:self.margin.top];
    
    NSLayoutConstraint *titleWithMarginRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.titleLabel
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-10];
    
    NSLayoutConstraint *titleWithMarginLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.titleLabel
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-205];
    NSLayoutConstraint *titleBottomConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-80];
    
    [self.marginConstraints addObject:titleWithMarginTopConstraint];
    [self.marginConstraints addObject:titleWithMarginRightConstraint];
    [self.marginConstraints addObject:titleWithMarginLeftConstraint];
    [self.marginConstraints addObject:titleBottomConstraint];
    
    
    NSLayoutConstraint *contentTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.content
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.titleLabel
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:35];
    
    NSLayoutConstraint *contentlLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.content
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1.0
                                  constant:10];
    NSLayoutConstraint *contentlRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.content
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-90];
    
    NSLayoutConstraint *contentlBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.content
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:-35];
    
    [self.marginConstraints addObject:contentTopConstraint];
    [self.marginConstraints addObject:contentlLeftConstraint];
    [self.marginConstraints addObject:contentlRightConstraint];
    [self.marginConstraints addObject:contentlBottomConstraint];
    
    
    
    NSLayoutConstraint *imageViewTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.imageShareView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.titleLabel
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:40];
    
    NSLayoutConstraint *imageViewLeadingConstraint =
    [NSLayoutConstraint constraintWithItem:self.imageShareView
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1.0
                                  constant:135];
    NSLayoutConstraint *imageViewRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.imageShareView
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-15];
    NSLayoutConstraint *imageViewBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.imageShareView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:-10];
    
    [self.marginConstraints addObject:imageViewTopConstraint];
    [self.marginConstraints addObject:imageViewLeadingConstraint];
    [self.marginConstraints addObject:imageViewRightConstraint];
    [self.marginConstraints addObject:imageViewBottomConstraint];
    
    [self addConstraints:self.marginConstraints];
    
    NSLayoutConstraint *backImageConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:260];
    
    [self.superview addConstraint:backImageConstraint];
    
}
- (void)_setupShareBubbleConstraints
{
    [self _setUpShareBubbleMarginConstraints];
}


@end
