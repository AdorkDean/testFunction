//
//  EditCell.m
//  qmp_ios
//
//  Created by QMP on 2018/3/1.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "EditCell.h"


@implementation EditCell

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


- (void)addView{
    
    self.keyLabel = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 120, 40)];
    [self.contentView addSubview:self.keyLabel];
    [self.keyLabel labelWithFontSize:14 textColor:NV_TITLE_COLOR];
    
    self.valueTf = [[UITextField alloc]initWithFrame:CGRectMake(self.keyLabel.right, 0, SCREENW-self.keyLabel.right - 17, 40)];
    [self.contentView addSubview:self.valueTf];
    self.valueTf.textAlignment = NSTextAlignmentRight;
    self.valueTf.font = [UIFont systemFontOfSize:14];
    self.valueTf.textColor = H5COLOR;
    [self.valueTf setValue:HCCOLOR forKeyPath:@"_placeholderLabel.textColor"];

    self.line = [[UIView alloc]initWithFrame:CGRectMake(17, 0, SCREENW, 0.5)];
    self.line.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:self.line];

}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    self.valueTf.centerY = self.contentView.height/2.0;
    self.keyLabel.centerY = self.contentView.height/2.0;
    [self.valueTf setValue:H9COLOR forKeyPath:@"_placeholderLabel.textColor"];

    self.line.top = self.contentView.height-0.5;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
