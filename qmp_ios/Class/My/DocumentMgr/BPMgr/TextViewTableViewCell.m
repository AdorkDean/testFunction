//
//  TextViewTableViewCell.m
//  qmp_ios
//
//  Created by QMP on 2018/5/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "TextViewTableViewCell.h"
#import "HMTextView.h"
@implementation TextViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.keyLabel];
        [self.contentView addSubview:self.textView];
        [self.contentView addSubview:self.lineView];
        [self makeConstraints];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _lineView.bottom = self.contentView.height;
}

- (void)makeConstraints{
    
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.top.equalTo(self.contentView);
        make.width.equalTo(@(200));
        make.height.equalTo(@(44));
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.keyLabel.mas_bottom).offset(-2);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView).offset(-5);
    }];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (UILabel *)keyLabel {
    if (!_keyLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = NV_TITLE_COLOR;
        label.frame = CGRectMake(17, 0, 200, 44);
        label.font = [UIFont systemFontOfSize:14.0];
        _keyLabel = label;
    }
    return _keyLabel;
}
- (HMTextView *)textView {
    if (!_textView) {
        HMTextView *textView = [[HMTextView alloc] init];
        textView.frame = CGRectMake(15, 38, SCREENW-34, 100);
        textView.layer.borderColor = [BORDER_LINE_COLOR CGColor];
        textView.layer.borderWidth = 0.5;
        _textView = textView;
    }
    return _textView;
}
- (UIImageView *)lineView {
    if (!_lineView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(15, 100, SCREENW-15, 0.5);
        imageView.backgroundColor = LIST_LINE_COLOR;
        _lineView = imageView;
    }
    return _lineView;
}
@end
