//
//  MoreTableViewCell.m
//  qmp_ios
//
//  Created by Molly on 16/10/9.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "MoreTableViewCell.h"

@implementation MoreTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.bottomLine.backgroundColor = LIST_LINE_COLOR;
    self.lineHeight.constant = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
