//
//  InputTextview.m
//  qmp_ios
//
//  Created by molly on 2017/3/24.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "InputTextview.h"
@interface InputTextview()<UITextViewDelegate>

@property (strong, nonatomic) UILabel *placeholderLab;
@end
@implementation InputTextview

- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = RGB(210, 209, 215, 1).CGColor;
        
        CGFloat vH = self.frame.size.height;
        
        UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, vH)];
        textView.delegate = self;
        textView.font = [UIFont systemFontOfSize:15.f];
        textView.scrollEnabled = YES;
     //   [textView becomeFirstResponder];
        [self addSubview:textView];
        self.textView = textView;
        
        CGFloat clearH = 25.f;
        UIButton *clearAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        clearAllBtn.frame = CGRectMake(textView.frame.size.width-59, vH - clearH, 59, clearH);
        [clearAllBtn setTitle:@"清除所有" forState:UIControlStateNormal];
        [clearAllBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [clearAllBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [clearAllBtn addTarget:self action:@selector(clearAllInfo:) forControlEvents:UIControlEventTouchUpInside];
        clearAllBtn.layer.borderWidth = 0.5f;
        clearAllBtn.layer.borderColor = RGB(210, 209, 215, 1).CGColor;
        clearAllBtn.layer.cornerRadius = 4;
        clearAllBtn.layer.masksToBounds = YES;
        clearAllBtn.backgroundColor = [UIColor whiteColor];
//        [self addSubview:clearAllBtn];
        
        UILabel *placeholderLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, textView.frame.size.width - 5, 16)];
        placeholderLab.enabled = NO;//lable必须设置为不可用
        placeholderLab.backgroundColor = [UIColor clearColor];//clearColor
        placeholderLab.font = [UIFont systemFontOfSize:15.f];
        placeholderLab.textColor = HTColorFromRGB(0xcccccc);
        [textView addSubview:placeholderLab];
        _placeholderLab = placeholderLab;
        
        [self toSetPlaceholderlblText];
    }
    return self;
}
- (void)toSetPlaceholderlblText{
    if ([_textView.text isEqualToString:@""]) {
        NSString *placeholderStr = @"" ;
        if (self.flag) {
            placeholderStr = @"请在这里填写备注信息";//请在这里填写建议或问题反馈
        }else{
            placeholderStr = @"请在此填写线索、问题或者意见";
            if ([self.module isEqualToString:@"更多相似项目"]) {
                placeholderStr = @"请在这里填写更多相似项目";
            }else if ([self.module isEqualToString:@"成为官方人物"]){
                placeholderStr = @"若该人物认证有误\n请提供您的联系方式或添加客服微信qimingpian01\n我们的客服人员会在第一时间和您取得联系，感谢您的支持和配合！";
                NSRange subRange = [placeholderStr rangeOfString:@"客服微信qimingpian01"];
                NSMutableAttributedString * artStr = [[NSMutableAttributedString alloc] initWithString:placeholderStr];
                [artStr setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.f]} range:subRange];
                _placeholderLab.frame = CGRectMake(5, 8, _textView.frame.size.width - 10, [PublicTool heightOfString:placeholderStr width:(_textView.frame.size.width - 10) font:[UIFont systemFontOfSize:15.f]]);
                _placeholderLab.numberOfLines = 0;
                _placeholderLab.attributedText = artStr;
            }else{
                
            }
        }
        if ([self.module isEqualToString:@"成为官方人物"]) {
            
        }else{
         _placeholderLab.text = placeholderStr;
        }
        _placeholderLab.hidden = NO;

    }
    else{
        _placeholderLab.hidden = YES;
    }
}
- (void)clearAllInfo:(UIButton *)sender{
    
    [_textView becomeFirstResponder];
    _textView.text = @"";
    [self toSetPlaceholderlblText];
    if ([self.delegate respondsToSelector:@selector(inputTextViewChange:)]) {
        [self.delegate inputTextViewChange:@""];
    }

}
#pragma mark- UITextView的代理方法
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([self.delegate respondsToSelector:@selector(inputTextViewBeginEditing)]) {
        [self.delegate inputTextViewBeginEditing];
    }
}
-(void)textViewDidChange:(UITextView *)textView
{
    
    if (textView.text.length == 0) {
        [self toSetPlaceholderlblText];
    }else{
        _placeholderLab.text = @"";
    }
    if ([self.delegate respondsToSelector:@selector(inputTextViewChange:)]) {
        [self.delegate inputTextViewChange:textView.text];
    }

}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if (![text isEqualToString:@""]) {
        _placeholderLab.hidden = YES;
    }
    
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1) {
        _placeholderLab.hidden = NO;
    }
    
    return YES;
}

@end
