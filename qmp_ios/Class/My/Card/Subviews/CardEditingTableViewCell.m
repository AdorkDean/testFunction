//
//  CardEditingTableViewCell.m
//  qmp_ios
//
//  Created by Molly on 16/9/27.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CardEditingTableViewCell.h"

@implementation CardEditingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization codel
    self.contentView.backgroundColor = TABLEVIEW_COLOR;
//    self.infoTextField.borderStyle = UITextBorderStyleNone;
    self.rightButton.layer.masksToBounds = YES;
    self.rightButton.layer.cornerRadius = 2;
    self.rightButton.layer.borderColor = LINE_COLOR.CGColor;
    self.rightButton.layer.borderWidth = 0.5;
    [self.rightButton addTarget:self action:@selector(copyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *copyGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyBtnClick)];
    [self.infoTextField addGestureRecognizer:copyGesture];
    
    self.infoTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
}


- (void)copyBtnClick{
    
    if ([PublicTool isNull:self.infoTextField.text]) {
        return;
    }
    [[UIPasteboard  generalPasteboard] setString:self.infoTextField.text];
    [PublicTool showMsg:@"复制成功"];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
