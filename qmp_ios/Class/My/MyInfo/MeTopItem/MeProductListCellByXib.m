//
//  MeProductListCellByXib.m
//  qmp_ios
//
//  Created by QMP on 2018/5/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MeProductListCellByXib.h"

@interface MeProductListCellByXib()
@property (weak, nonatomic) IBOutlet UIImageView *iconImgVw;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *owerLbl;
@end

@implementation MeProductListCellByXib

+ (instancetype)cellWithTableView:(UITableView*)tableView{
    MeProductListCellByXib *cell = [tableView dequeueReusableCellWithIdentifier:@"MeProductListCellByXibID"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MeProductListCellByXib" owner:nil options:nil].lastObject;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.owerLbl.layer.cornerRadius = 1;
    self.owerLbl.clipsToBounds = YES;
    [self.attetionBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    self.attetionBtn.layer.cornerRadius = 14;
    self.attetionBtn.layer.masksToBounds = YES;
    
    self.iconImgVw.layer.cornerRadius = 8;
    self.iconImgVw.clipsToBounds = YES;
    self.iconImgVw.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    self.iconImgVw.layer.borderWidth = 0.5;
    self.iconImgVw.contentMode = UIViewContentModeScaleAspectFit;
}
- (void)setModel:(MeTopItemModel *)model{
    _model = model;
    if (_type == fromMeJiGouTyp) {
        [self.iconImgVw sd_setImageWithURL:[NSURL URLWithString:_model.icon] placeholderImage:[UIImage imageNamed:@"jigou_default.png"]];
    }else if (_type == fromMeProductType){
        [self.iconImgVw sd_setImageWithURL:[NSURL URLWithString:_model.icon] placeholderImage:[UIImage imageNamed:@"product_default.png"]];
    }else{
        
    }
    self.itemNameLbl.text = [PublicTool nilStringReturn:_model.project];
    [self.attetionBtn setImage:nil forState:UIControlStateNormal];
    if (![_model.display_flag isEqualToString:@"0"]) {
        //        self.attentBtn.layer.borderColor = HTColorFromRGB(0xBBBBBB).CGColor;
        [self.attetionBtn setTitleColor:H999999 forState:UIControlStateNormal];
        [self.attetionBtn setTitle:@"已关注" forState:UIControlStateNormal];
        self.attetionBtn.backgroundColor = [H999999 colorWithAlphaComponent:0.08];
    }else{
        //        self.attentBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
        [self.attetionBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [self.attetionBtn setTitle:@"关注" forState:UIControlStateNormal];
        self.attetionBtn.backgroundColor = [BLUE_TITLE_COLOR colorWithAlphaComponent:0.08];
    }
    
    //    self.owerLbl.hidden = [_model.claim_type isEqualToString:@"2"] ? NO : YES;
    self.owerLbl.hidden = NO;
    self.owerLbl.layer.borderWidth = 0.5;
    self.owerLbl.layer.cornerRadius = 2;
    if ([_model.claim_type isEqualToString:@"2"]) {
        self.owerLbl.text = @" 审核中 ";
        self.owerLbl.textColor = BLUE_TITLE_COLOR;
        self.owerLbl.backgroundColor = [UIColor whiteColor];
        self.owerLbl.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
        
    } else if ([_model.claim_type isEqualToString:@"1"]) {
        self.owerLbl.text = @" 审核失败 ";
        self.owerLbl.textColor = RED_TEXTCOLOR;
        self.owerLbl.backgroundColor = [UIColor whiteColor];
        self.owerLbl.layer.borderColor = [RED_TEXTCOLOR CGColor];
    } else if ([_model.claim_type isEqualToString:@"3"]) {
        self.owerLbl.text = @" 已认领 ";
        self.owerLbl.textColor = [UIColor whiteColor];
        self.owerLbl.backgroundColor = BLUE_TITLE_COLOR;
        self.owerLbl.layer.borderColor = [[UIColor clearColor] CGColor];
    } else {
        self.owerLbl.hidden = YES;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
