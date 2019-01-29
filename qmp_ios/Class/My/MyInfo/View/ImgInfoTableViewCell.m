//
//  ImgInfoTableViewCell.m
//  qmp_ios
//
//  Created by Molly on 2017/3/11.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "ImgInfoTableViewCell.h"
#import <UIImageView+WebCache.h>

@implementation ImgInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _iconImg.layer.masksToBounds = YES;
    _iconImg.layer.cornerRadius = 23;

    _iconImg.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImg.layer.borderWidth = 0.5;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initData:(NSString *)imgName{

    if (![PublicTool isNull:imgName]) {
        [self.iconImg sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:nil];

    }
    
}

@end
