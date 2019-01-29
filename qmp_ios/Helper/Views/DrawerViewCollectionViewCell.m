//
//  DrawerViewCollectionViewCell.m
//  qmp_ios
//
//  Created by Molly on 2016/10/28.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "DrawerViewCollectionViewCell.h"

@implementation DrawerViewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.industryBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [self.industryBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
        self.industryBtn.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:self.industryBtn];
        self.industryBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.industryBtn.layer.masksToBounds = YES;
        self.industryBtn.layer.cornerRadius = 2;
        self.industryBtn.layer.borderColor = H999999.CGColor;
        self.industryBtn.layer.borderWidth = 0.5;
        self.industryBtn.backgroundColor = [UIColor whiteColor];
//        CGFloat width = 54;
//        CGFloat height = 48;
//        CGFloat trueH = 20;
//
//        if (self.frame.size.height == 26) {
//            trueH = 16;
//        }
//        CGFloat trueW = trueH * width / height;
//        self.delIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-trueW, 0, trueW, trueH)];
//        self.delIcon.image = [UIImage imageNamed:@"filter_delIcon"];
//        [self.contentView addSubview:self.delIcon];
//        self.delIcon.hidden = YES;
//        self.delIcon.tag = 10009;
        
    }
    return self;
}

- (UIButton *)industryBtn{
    
    if (!_industryBtn) {
        _industryBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    return _industryBtn;
}
@end
