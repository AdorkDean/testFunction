//
//  JobExpriencesCell.m
//  qmp_ios
//
//  Created by QMP on 2017/11/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "JobExpriencesCell.h"

@interface JobExpriencesCell()
{
    __weak IBOutlet UIImageView *_iconimgV;
    
    __weak IBOutlet UILabel *_nameLab;
    
    __weak IBOutlet UILabel *_timeLab;
    __weak IBOutlet UILabel *_zhiweiLab;
    __weak IBOutlet UILabel *_iconLabel;
    
    __weak IBOutlet UILabel *xueliLabel;
}
@end

@implementation JobExpriencesCell

+ (instancetype)cellWithTableView:(UITableView*)tableView{
    JobExpriencesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JobExpriencesCellID"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"JobExpriencesCell" owner:nil options:nil].lastObject;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    _iconimgV.layer.cornerRadius = 5;
    _iconimgV.layer.masksToBounds = YES;
    _iconLabel.layer.cornerRadius = 5;
    _iconLabel.layer.masksToBounds = YES;
    _iconimgV.layer.borderWidth = 0.5;
    _iconimgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconimgV.contentMode = UIViewContentModeScaleAspectFit;
    self.topLine.backgroundColor = F5COLOR;

    [self.editBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    
    _nameLab.textColor = H3COLOR;
    _zhiweiLab.textColor = H6COLOR;
    _timeLab.textColor = H6COLOR;
}


- (void)setExprienceM:(ZhiWeiModel *)exprienceM{
    _exprienceM = exprienceM;
    xueliLabel.hidden = YES;
    [_iconimgV sd_setImageWithURL:[NSURL URLWithString:exprienceM.icon] placeholderImage:[UIImage imageNamed:PROICON_DEFAULT]];
    _nameLab.text = [PublicTool nilStringReturn:exprienceM.name];
    _zaizhiLab.hidden = NO;
    _zhiweiLab.text = @"";
    if (exprienceM.is_dimission.intValue == 1) {
        _zaizhiLab.text = @"已离职";
        _zaizhiLab.textColor = H9COLOR;
    }else{
        _zaizhiLab.text = @"在职";
        _zaizhiLab.textColor = COLOR2D343A;
    }
    
    if (![PublicTool isNull:exprienceM.start_time] || ![PublicTool isNull:exprienceM.end_time] ) {
        _timeLab.text = [NSString stringWithFormat:@"%@-%@",[PublicTool nilStringReturn:exprienceM.start_time],[PublicTool nilStringReturn:exprienceM.end_time]];
        _zhiweiLab.text =  [PublicTool isNull:exprienceM.zhiwu]?@"":exprienceM.zhiwu;

    }else{
        _timeLab.text =  [PublicTool isNull:exprienceM.zhiwu]?@"":exprienceM.zhiwu;
    }
    
    self.editBtn.hidden = YES;

    self.nameLabRightEdge.constant = 67;
}

- (void)setEduExprienceM:(EducationExpModel *)eduExprienceM{
    _eduExprienceM = eduExprienceM;
    _nameLab.text = [PublicTool nilStringReturn:eduExprienceM.school];
    _zaizhiLab.hidden = YES;
    _zhiweiLab.text = @"";
    if (![PublicTool isNull:eduExprienceM.start_time] || ![PublicTool isNull:eduExprienceM.end_time] ) {
        _timeLab.text = [NSString stringWithFormat:@"%@-%@",[PublicTool nilStringReturn:eduExprienceM.start_time],[PublicTool nilStringReturn:eduExprienceM.end_time]];
        _zhiweiLab.text =  [NSString stringWithFormat:@"%@  %@",[PublicTool nilStringReturn:eduExprienceM.major],eduExprienceM.xueli?:@""];

    }else{
        _timeLab.text =  [NSString stringWithFormat:@"%@  %@",[PublicTool nilStringReturn:eduExprienceM.major],eduExprienceM.xueli?:@""];
    }
    
    xueliLabel.text = @"";
    
    self.editBtn.hidden = YES;
    self.nameLabRightEdge.constant = 67;

}

- (void)setWinExprienceM:(WinExperienceModel *)winExprienceM{
    _winExprienceM = winExprienceM;
    xueliLabel.hidden = YES;
    _iconimgV.image = [UIImage imageNamed:@"person_win"];
    _iconLabel.hidden = YES;
    _nameLab.text = winExprienceM.winning;
    _zhiweiLab.text = @"";
    _zaizhiLab.hidden = YES;
    _zaizhiLab.text = @"";
    if (![PublicTool isNull:winExprienceM.time]) {
        _timeLab.text = winExprienceM.time;
        _zhiweiLab.text =  [PublicTool isNull:winExprienceM.awards]?@"":winExprienceM.awards;
    }else{
        _timeLab.text =  [PublicTool isNull:winExprienceM.awards]?@"-":winExprienceM.awards;
    }
    
    self.editBtn.hidden = YES;
    [_nameLab sizeToFit];
}

- (void)setProOrgPrizeM:(WinExperienceModel *)proOrgPrizeM{
    self.nameLabRightEdge.constant = 17;
    
    self.topLine.backgroundColor = F5COLOR;

    _proOrgPrizeM = proOrgPrizeM;
    xueliLabel.hidden = YES;
    _iconimgV.image = [UIImage imageNamed:@"person_win"];
    _iconLabel.hidden = YES;
    _nameLab.text = proOrgPrizeM.prize_name;
    _zaizhiLab.hidden = YES;
    _zhiweiLab.text = @"";

    if (![PublicTool isNull:proOrgPrizeM.prize_time]) {
        _timeLab.text = proOrgPrizeM.prize_time;
        _zhiweiLab.text =  [PublicTool nilStringReturn:proOrgPrizeM.awards];
    }else{
        _timeLab.text =  [PublicTool nilStringReturn:proOrgPrizeM.awards];
    }
    
    self.editBtn.hidden = YES;
    [_nameLab sizeToFit];
}

- (void)setIconColor:(UIColor *)iconColor{
    if (_exprienceM) {
        if ([PublicTool isNull:_exprienceM.icon] || [_exprienceM.icon containsString:@"product_default.png"]) {
            _iconLabel.hidden = NO;
            _iconLabel.backgroundColor = iconColor;
            if (![PublicTool isNull:_exprienceM.product] && _exprienceM.product.length > 0) {
                _iconLabel.text = [_exprienceM.product substringWithRange:NSMakeRange(0, 1)];
            }else{
                _iconLabel.text = @"-";
            }
        }else{
            _iconLabel.hidden = YES;
        }
    }else if(_eduExprienceM){
        _iconLabel.hidden = NO;
        _iconLabel.backgroundColor = iconColor;
        if (![PublicTool isNull:_eduExprienceM.school] && _eduExprienceM.school.length > 0) {
            _iconLabel.text = [_eduExprienceM.school substringWithRange:NSMakeRange(0, 1)];
        }else{
            _iconLabel.text = @"-";
        }
    }else if(_winExprienceM){
        _iconLabel.hidden = NO;
        _iconLabel.backgroundColor = iconColor;
        if (![PublicTool isNull:_winExprienceM.winning] && _winExprienceM.winning.length > 0) {
            _iconLabel.text = [_winExprienceM.winning substringWithRange:NSMakeRange(0, 1)];
        }else{
            _iconLabel.text = @"-";
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
