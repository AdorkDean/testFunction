//
//  SearchPersonNoDataCell.m
//  qmp_ios
//
//  Created by QMP on 2018/2/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SearchPersonNoDataCell.h"


@implementation SearchPersonNoDataCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _createBtn.layer.masksToBounds = YES;
    _createBtn.layer.cornerRadius = 16;
    _createBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
    _createBtn.layer.borderWidth = 0.5;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
