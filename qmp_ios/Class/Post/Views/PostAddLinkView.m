//
//  PostAddLinkView.m
//  qmp_ios
//
//  Created by QMP on 2018/10/17.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "PostAddLinkView.h"

@interface PostAddLinkView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;
@end
@implementation PostAddLinkView

- (void)hide {
    [self removeFromSuperview];
}
- (void)show {
    [KEYWindow addSubview:self];
    [self.textField becomeFirstResponder];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    self.backgroundColor = RGBa(0, 0, 0, 0.3);
    self.frame = CGRectMake(0, 0, SCREENW, SCREENH);
    
    [self addSubview:self.contentView];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.textField];
    [self.contentView addSubview:self.cancelButton];
    [self.contentView addSubview:self.confirmButton];
    
    UIImageView *line = [[UIImageView alloc] init];
    line.frame = CGRectMake(0, 98, SCREENW-70, 1);
    line.backgroundColor = HTColorFromRGB(0xEDEEF0);
    [self.contentView addSubview:line];
    
    UIImageView *line1 = [[UIImageView alloc] init];
    line1.frame = CGRectMake((SCREENW-70)/2-0.5, 99, 1, 48);
    line1.backgroundColor = HTColorFromRGB(0xEDEEF0);
    [self.contentView addSubview:line1];
    
}
- (void)textFieldClear {
    self.textField.text = @"";
}
- (void)confirmButtonClick {
    [self hide];
    if (self.confirmActionTap) {
        self.confirmActionTap(self.textField.text);
    }
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(35, 200, SCREENW-70, 145);
        _contentView.layer.cornerRadius = 12;
        _contentView.clipsToBounds = YES;
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(20, 20, SCREENW-70-40, 18);
        if (@available(iOS 8.2, *)) {
            _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        }else{
            _titleLabel.font = [UIFont systemFontOfSize:18];
        }
        _titleLabel.textColor = HTColorFromRGB(0x2D343A);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"添加链接";
    }
    return _titleLabel;
}
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.frame = CGRectMake(15, 52, SCREENW-70-30, 30);
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.textColor = HTColorFromRGB(0x197CD8);
        _textField.layer.borderColor = [HTColorFromRGB(0xEDEEF0) CGColor];
        _textField.layer.cornerRadius = 2;
        _textField.layer.borderWidth = 1;
        _textField.clipsToBounds = YES;
        _textField.keyboardType = UIKeyboardTypeURL;
        _textField.placeholder = @"请输入链接地址";
        
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, 10, 30);
        _textField.leftView = view;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(0, 0, 30, 30);
        [button setImage:[BundleTool imageNamed:@"add_link_delete"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(textFieldClear) forControlEvents:UIControlEventTouchUpInside];
        _textField.rightView = button;
        _textField.rightViewMode = UITextFieldViewModeWhileEditing;
    }
    return _textField;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.frame = CGRectMake(0, 99, (SCREENW-70)/2.0, 48);
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:HTColorFromRGB(0x2D343A) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}
- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] init];
        _confirmButton.frame = CGRectMake((SCREENW-70)/2.0, 99, (SCREENW-70)/2.0, 48);
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:HTColorFromRGB(0x197CD8) forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}


@end
