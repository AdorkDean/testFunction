//
//  TextViewCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/30.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "TextViewCell.h"

@implementation TextViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addView];
    }
    return self;
}

- (void)addView{
    
    self.textView = [[HMTextView alloc]initWithFrame:CGRectMake(15, 0, SCREENW-30, self.contentView.height-10)];
    self.textView.placehoderColor = HCCOLOR;
    self.textView.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.textView];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.textView.frame = CGRectMake(12, 5, SCREENW-24, self.contentView.height-30);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
