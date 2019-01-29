//
//  WalletHeaderView.m
//  qmp_ios
//
//  Created by QMP on 2018/8/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "WalletHeaderView.h"

@implementation WalletHeaderView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.usrHeadV.layer.cornerRadius = 16;
    self.usrHeadV.layer.masksToBounds = YES;
    
    self.userHeaderImgV.layer.cornerRadius = 14;
    self.userHeaderImgV.layer.masksToBounds = YES;
    self.userHeaderImgV.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userHeaderImgV.layer.borderWidth = 0.5;
    [self.userHeaderImgV sd_setImageWithURL:[NSURL URLWithString:[WechatUserInfo shared].headimgurl] placeholderImage:[UIImage imageNamed:@"heading"]];
    

}

-(void)layoutSubviews{
    [super layoutSubviews];
}

@end
