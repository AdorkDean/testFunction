//
//  HotJigouListCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "HotJigouListCell.h"

@implementation HotJigouListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _countLab.textColor = BLUE_TITLE_COLOR;
}



-(void)setOrganize:(OrganizeItem *)organize{
    _organize = organize;
    
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:organize.icon] placeholderImage:[UIImage imageNamed:PROICON_DEFAULT]];
//    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:organize.icon] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        self.iconImgV.image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(80, 80)];
//    }];
    
    _nameLab.text = organize.jigou_name;
    _countLab.text = organize.tz_count;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
