/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseMessageTimeCell.h"

CGFloat const EaseMessageTimeCellPadding = 7.5;

@interface EaseMessageTimeCell()


@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@end

@implementation EaseMessageTimeCell

//+ (void)initialize
//{
//    // UIAppearance Proxy Defaults
//    EaseMessageTimeCell *cell = [self appearance];
//    cell.titleLabelColor = [UIColor grayColor];
//    cell.titleLabelFont = [UIFont systemFontOfSize:10];
//}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self _setupSubview];
    }
    
    return self;
}

#pragma mark - setup subviews

- (void)_setupSubview
{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.backgroundColor = HTColorFromRGB(0xEAEAEA);
    _titleLabel.layer.cornerRadius = 4.0;
    _titleLabel.clipsToBounds = YES;
    _titleLabel.textColor = [UIColor grayColor];
    _titleLabel.font = [UIFont systemFontOfSize:10];
    _titleLabel.numberOfLines = -1;

    [self.contentView addSubview:_titleLabel];
    
    [self _setupTitleLabelConstraints];
}

#pragma mark - Setup Constraints

- (void)_setupTitleLabelConstraints
{
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:EaseMessageTimeCellPadding]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-EaseMessageTimeCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                         attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f constant:30]];
    
    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f constant:0];
    [self addConstraint:self.widthConstraint];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeWidth
//                                                relatedBy:NSLayoutRelationEqual
//                                                   toItem:nil attribute:NSLayoutAttributeNotAnAttribute
//                                               multiplier:1.0f constant:200.0f]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-EaseMessageTimeCellPadding]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:EaseMessageTimeCellPadding]];
}

#pragma mark - setter

- (void)setTitle:(NSString *)title
{
    _title = title;
    
//    [_titleLabel sizeToFit];
    
    NSAttributedString *a = [[NSAttributedString alloc] initWithString:_title?:@"" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName: [UIFont systemFontOfSize:10]}];
    if ([title containsString:@"试试委托联系"]) {
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithAttributedString:a];
        [attText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:NSMakeRange(title.length-4, 4)];
        _titleLabel.attributedText = attText;
    }else{
        _titleLabel.attributedText = a;
    }
    CGFloat w = [a boundingRectWithSize:CGSizeMake(SCREENW-32, 20)
                                options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                context:nil].size.width;
    
    [self removeConstraint:self.widthConstraint];
    self.widthConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f constant:w+20];
    [self addConstraint:self.widthConstraint];
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont
{
    _titleLabelFont = titleLabelFont;
    _titleLabel.font = _titleLabelFont;
}

- (void)setTitleLabelColor:(UIColor *)titleLabelColor
{
    _titleLabelColor = titleLabelColor;
    _titleLabel.textColor = _titleLabelColor;
}

#pragma mark - public

+ (NSString *)cellIdentifier
{
    return @"MessageTimeCell";
}

@end
