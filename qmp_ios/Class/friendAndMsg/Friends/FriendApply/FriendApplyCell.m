//
//  FriendApplyCell.m
//  qmp_ios
//
//  Created by QMP on 2018/2/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "FriendApplyCell.h"

@implementation FriendApplyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.iconImgV.layer.masksToBounds = YES;
    self.iconImgV.layer.cornerRadius = 27.5;
    self.iconImgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    self.iconImgV.layer.borderWidth = 0.5;

    
    
    [self.rightButton setImage:[[BundleTool imageNamed:@"area_add"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.rightButton setTitle:@"好友" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
    [self.rightButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    
    self.rightButton.layer.masksToBounds = YES;
    self.rightButton.layer.cornerRadius = 16;
    self.rightButton.layer.borderWidth = 0.5;
    self.rightButton.layer.borderColor = BORDER_LINE_COLOR.CGColor;
}


- (void)setDic:(NSDictionary *)dic{
    
    _dic = dic;
    if (![PublicTool isNull:dic[@"img_url"]]) {
        [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:dic[@"img_url"]] placeholderImage:[BundleTool imageNamed:@"heading"]];
    }else{
        [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:dic[@"headimgurl"]] placeholderImage:[BundleTool imageNamed:@"heading"]];

    }
    self.nameLab.text = dic[@"nickname"];
    self.comZhiLab.text = [PublicTool nilStringReturn:dic[@"company"]];
    self.zhiweiLab.text = [PublicTool nilStringReturn:dic[@"zhiwei"]];
    self.ignoreBtn.hidden = NO;
    self.passBtn.hidden = NO;
    self.rightButton.hidden = YES;
}

- (void)setFriendM:(FriendModel *)friendM{
    
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:friendM.headimgurl] placeholderImage:[BundleTool imageNamed:@"heading"]];

    self.nameLab.text = friendM.name;
    self.comZhiLab.text = [PublicTool nilStringReturn:friendM.company];
    self.zhiweiLab.text = [PublicTool nilStringReturn:friendM.zhiwei];
   
    self.ignoreBtn.hidden = YES;
    self.passBtn.hidden = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
