//
//  HapMapCell.m
//  qmp_ios
//
//  Created by QMP on 2017/11/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "HapMapCell.h"

@implementation HapMapCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _nameLab.textColor = NV_TITLE_COLOR;
    _countLab.textColor = BLUE_TITLE_COLOR;
    _line.backgroundColor = LIST_LINE_COLOR;
    self.lineHeight.constant = 0.5;
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
