//
//  FormEditTableViewCell.m
//  qmp_ios
//
//  Created by QMP on 2018/5/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "FormEditTableViewCell.h"

@interface FormEditTableViewCell ()
@end
@implementation FormEditTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)addView {
    
    self.keyLabel = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 120, 40)];
    [self.contentView addSubview:self.keyLabel];
    [self.keyLabel labelWithFontSize:14 textColor:NV_TITLE_COLOR];
    
    self.valueTf = [[UITextField alloc]initWithFrame:CGRectMake(self.keyLabel.right, 0, SCREENW-self.keyLabel.right - 17, 40)];
    [self.contentView addSubview:self.valueTf];
    self.valueTf.textAlignment = NSTextAlignmentRight;
    self.valueTf.font = [UIFont systemFontOfSize:14];
    self.valueTf.textColor = H5COLOR;
    [self.valueTf setValue:HCCOLOR forKeyPath:@"_placeholderLabel.textColor"];
    self.valueTf.hidden = YES;
    
    self.line = [[UIView alloc]initWithFrame:CGRectMake(17, 0, SCREENW, 0.5)];
    self.line.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:self.line];
    
    
    
    self.selectsView = [[UIView alloc] init];
    self.selectsView.frame = CGRectMake(0, 44, SCREENW, 36);
    [self.contentView addSubview:self.selectsView];
    CGFloat margin = 10;
    CGFloat w = (SCREENW-34-3*margin)/4.0;
    for (int i = 0; i < 4; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(17+(w+margin)*i, 0, w, 30);
        [button setTitle:[NSString stringWithFormat:@"haha%d", i] forState:UIControlStateNormal];
        [button setTitleColor:HTColorFromRGB(0x7a7a7a) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];

        CAShapeLayer *border = [CAShapeLayer layer];
        border.strokeColor = BORDER_LINE_COLOR.CGColor;
        border.fillColor = [UIColor clearColor].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:button.bounds cornerRadius:5];
        border.path = path.CGPath;
        border.frame = button.bounds;
        border.lineWidth = 1.f;
        border.cornerRadius = 4.f;
        border.masksToBounds = YES;
        border.lineDashPattern = @[@4, @2];
        [button.layer addSublayer:border];
        
        button.layer.cornerRadius = 4.f;
        button.clipsToBounds = YES;
        [button addTarget:self action:@selector(muSelectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.selectsView addSubview:button];
    }
    
    [self.contentView addSubview:self.textView];
}
- (void)muSelectButtonClick:(UIButton *)button {
    

    if (!self.isMultiSelection) {
        if (self.currentButton == button) {
            self.currentButton.selected = NO;
            self.currentButton = nil;
        } else {
            self.currentButton.selected = NO;
            [self fixButtonShow:self.currentButton];
            button.selected = YES;
            self.currentButton = button;
        }
        if (self.currentButton) {
            self.valueTf.text = [self.currentButton currentTitle];
        } else {
            self.valueTf.text = @"";
        }
    } else {
        button.selected = !button.selected;
        if (button.selected) {
            [self.selectedTitles addObject:[button currentTitle]];
        } else {
            [self.selectedTitles removeObject:[button currentTitle]];
        }
        NSMutableString *str = [NSMutableString string];
        for (NSString *title in self.selectedTitles) {
            [str appendString:title];
            if (![title isEqualToString:[self.selectedTitles lastObject]]) {
                [str appendString:@"、"];
            }
        }
        self.valueTf.text = str;
        
    }
    [self fixButtonShow:button];

    if ([self.delegate respondsToSelector:@selector(formEditTableViewCell:buttonClick:)]) {
        [self.delegate formEditTableViewCell:self buttonClick:button];
    }
}

- (void)fixButtonShow:(UIButton *)button {
    if (button.selected) {
        for (CALayer *border in button.layer.sublayers) {
            if ([border isKindOfClass:[CAShapeLayer class]]) {
                border.hidden = YES;
                break;
            }
        }
        button.backgroundColor = HTColorFromRGB(0xb7bcc3);
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        for (CALayer *border in button.layer.sublayers) {
            if ([border isKindOfClass:[CAShapeLayer class]]) {
                border.hidden = NO;
                break;
            }
        }
        button.backgroundColor = [UIColor whiteColor];
        
        [button setTitleColor:HTColorFromRGB(0x7a7a7a) forState:UIControlStateNormal];
    }
}
-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.valueTf.centerY = 50/2.0;
    self.keyLabel.centerY = 50/2.0;
    [self.valueTf setValue:H9COLOR forKeyPath:@"_placeholderLabel.textColor"];
    
    self.line.top = self.contentView.height-0.5;
    
    self.textView.hidden = !self.isMultiSelection;
    self.textView.frame = CGRectMake(17, self.selectsView.bottom, SCREENW, 80);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (NSMutableArray *)selectedTitles {
    if (!_selectedTitles) {
        _selectedTitles = [NSMutableArray array];
    }
    return _selectedTitles;
}
- (HMTextView *)textView {
    if (!_textView) {
        _textView = [[HMTextView alloc] init];
    }
    return _textView;
}
@end
