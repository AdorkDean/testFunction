//
//  TagEditCell.m
//  TestPod
//
//  Created by QMP on 2017/8/28.
//  Copyright © 2017年 WSS. All rights reserved.
//

#import "TagEditCell.h"
#import "BackWardTextField.h"


@interface TagEditCell ()<UITextViewDelegate,UITextFieldDelegate>

{
    NSInteger deleteCount; //点击删除的次数，2次再删
    BOOL deleteText;
}
@property(nonatomic,strong)BackWardTextField *textField;

@end

#define BLACK_BORDER_COLOR HTColorFromRGB(0xb3b3b3)

@implementation TagEditCell

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        deleteCount = 0;
        deleteText = NO;
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        self.layer.borderWidth = 0.5;

        BackWardTextField *textView = [[BackWardTextField alloc]initWithFrame:self.bounds];
        textView.font = [UIFont systemFontOfSize:14];
        textView.textColor = H5COLOR;
        textView.tintColor = HTColorFromRGB(0xe1403f);
        textView.delegate = self;
        UIColor *color = [UIColor lightGrayColor];
        textView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"添加专辑" attributes:@{NSForegroundColorAttributeName: color}];
        
        textView.returnKeyType = UIReturnKeyNext;
        textView.tintColor = RGBBlueColor;
        [self.contentView addSubview:textView];
        [textView addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
        self.textField = textView;
       
        
        __weak typeof(self) weakSelf = self;
        textView.centerY = textView.centerY - 1;
        
        textView.backWardEvent = ^{ //text为空，还点击删除的生活
            if (_textField.text.length) {
                weakSelf.layer.borderWidth = 0.5;

            }else{
                weakSelf.layer.borderWidth = 0;

            }

            //点击删除按钮
            
            if (textView.text.length == 0 && deleteCount == 2) {
                if (weakSelf.deleteLastCell) {
                    weakSelf.deleteLastCell();

                }
                deleteCount = 0;

            }else if([PublicTool isNull:weakSelf.textField.text]){
            
                if (deleteText == NO) {
                    if (weakSelf.willDeleteLastCell) {
                        weakSelf.willDeleteLastCell();
                        deleteCount = 2;
                    }
                }else{
                    deleteText = NO;
                }
          
            }
            
        };
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor whiteColor];
    self.textField.frame = self.bounds;
    self.textField.centerY = self.height/2.0 - 1;
    if (self.textField.text.length) {
        self.layer.borderWidth = 0.5;
    }else{
        self.layer.borderWidth = 0;

    }
////    self.textField.width = self.width - 5;
//    self.textField.centerX = self.width/2.0;

}


#pragma mark --UITextFieldDelegate---
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    self.layer.borderWidth = 0;

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{

    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}


- (void)textChange{
    NSString *text = _textField.text;
    CGFloat width = [PublicTool widthOfString:text height:CGFLOAT_MAX fontSize:14];
    self.width = width > 90 ? width : 90;
    [self setNeedsLayout];
    self.textChanged(_textField.text);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    if (textField.text.length >= 25 && string && string.length) {
        return NO;
    }
    
    if (([PublicTool isNull:textField.text] && string.length == 0) || (textField.text.length == 1 && string.length == 0)) { //不显示边框

        self.layer.borderWidth = 0;
        
        if (textField.text.length == 1 && string.length == 0) {
            deleteCount = 0;
            deleteText = YES;
            
        }else{
            deleteText = NO;
        }
        
    }else{ //边框
        self.layer.borderWidth = 0.5;
        deleteText = NO;

    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{ //下一项
    
    if (textField.text.length >0) {
        NSString *str = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (self.addTag) {
            self.addTag(str);

        }
        self.textField.text = @"";
        [self.textField becomeFirstResponder];

    }
    return YES;
}



- (void)becomesFirstResponder{
    if (![self.textField isFirstResponder]) {
        [self.textField becomeFirstResponder];

    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.actionForKeyboard) {
        [self.textField becomeFirstResponder];

    }else{
        [self.textField resignFirstResponder];

    }

}

- (void)clearText{
    _textField.text = @"";
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setNeedsDisplay];
}

@end
