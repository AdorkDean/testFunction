//
//  AlbumsListCell.m
//  qmp_ios
//
//  Created by QMP on 2017/10/25.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "AlbumsListCell.h"

@implementation AlbumsListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.topStaL.layer.masksToBounds = YES;
    self.topStaL.layer.cornerRadius = 1.5;
    self.topStaL.layer.borderColor = RED_TEXTCOLOR.CGColor;
    self.topStaL.layer.borderWidth = 0.5;

    self.topStaL.textColor = RED_TEXTCOLOR;
    self.nameLbl.textColor = NV_TITLE_COLOR;
    self.countLabel.textColor = NV_TITLE_COLOR;
}

- (void)setGroupModel:(GroupModel *)groupModel{
    _groupModel = groupModel;
    
    NSMutableAttributedString *mutableAttText = [[NSMutableAttributedString alloc]initWithString:groupModel.name];
    if (self.keyword && [groupModel.name containsString:self.keyword]) {
        for (NSValue *rangeV in [PublicTool noDifferenceUporLowRangeOfSubString:self.keyword inString:groupModel.name]) {
            NSRange range = rangeV.rangeValue;
            [mutableAttText addAttributes:@{NSForegroundColorAttributeName:RED_TEXTCOLOR} range:range];
        }
    }
    
    self.nameLbl.attributedText = mutableAttText;
    self.countLabel.text = [NSString stringWithFormat:@"(%@)",groupModel.count];
    self.topStaL.hidden = YES;
    self.nameLeading.constant = 17;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
