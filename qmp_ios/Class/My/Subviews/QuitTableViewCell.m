//
//  QuitTableViewCell.m
//  QimingpianSearch
//
//  Created by Molly on 16/8/12.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "QuitTableViewCell.h"

@implementation QuitTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];


    self.quitBtn.layer.masksToBounds = YES;
    self.quitBtn.layer.cornerRadius = 5.f;
    self.quitBtn.backgroundColor = RED_DARKCOLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
