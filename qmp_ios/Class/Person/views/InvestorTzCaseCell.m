//
//  InvestorTzCaseCell.m
//  qmp_ios
//
//  Created by QMP on 2017/11/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "InvestorTzCaseCell.h"
#import "InsetsLabel.h"

@interface InvestorTzCaseCell()
{
    __weak IBOutlet UIImageView *_iconImgV;
    
    __weak IBOutlet InsetsLabel *_curLunciLab;
    __weak IBOutlet UILabel *_nameLab;
    
    __weak IBOutlet UILabel *_hangyeLab;
    
    __weak IBOutlet UILabel *_jianjieLab;
    __weak IBOutlet UILabel *_iconLabel;
    __weak IBOutlet UILabel *_lunciMoneyLab;
    
    
}

@end


@implementation InvestorTzCaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _iconImgV.layer.cornerRadius = 5;
    _iconImgV.layer.masksToBounds = YES;
    _iconImgV.layer.borderWidth = 0.5;
    _iconImgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImgV.contentMode = UIViewContentModeScaleAspectFit;
    
    _iconLabel.layer.cornerRadius = 5;
    _iconLabel.layer.masksToBounds = YES;
    [self.deleteBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    
    [_curLunciLab labelWithFontSize:10 textColor:BLUE_TITLE_COLOR];
    _curLunciLab.backgroundColor = LABEL_BG_COLOR;

    _nameLab.textColor = COLOR2D343A;
    _hangyeLab.textColor = H9COLOR;
    _jianjieLab.textColor = COLOR737782;
}

-(void)setTzCaseM:(PersonTouziModel *)tzCaseM{

    _tzCaseM = tzCaseM;
    
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:tzCaseM.icon] placeholderImage:[BundleTool imageNamed:PROICON_DEFAULT]];
   
    _curLunciLab.hidden = [PublicTool isNull:tzCaseM.lunci];
    _curLunciLab.text = tzCaseM.lunci;
    
    //时间处理
    NSMutableArray *arr;
    if ([tzCaseM.valuations_time containsString:@"."]) {
        arr = [NSMutableArray arrayWithArray:[tzCaseM.valuations_time componentsSeparatedByString:@"."]];
        [arr removeLastObject]; //删除日期中的日
        
    }else if([tzCaseM.valuations_time length] > 0){
        arr = [NSMutableArray arrayWithObjects:tzCaseM.valuations_time, nil];
    }else{
        arr = [NSMutableArray array];
    }
    NSMutableString *timeStr = [NSMutableString string];
    for (NSString *str in arr) {
        if (str.length == 1) {
            [timeStr appendString:[NSString stringWithFormat:@".%@%@",@"0",str]];
        }else{
            [timeStr appendString:[NSString stringWithFormat:@".%@",str]];
        }
    }
    if (timeStr.length) {
        [timeStr deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    
    NSString *rowStr;
    
    if ([PublicTool isNull:tzCaseM.valuations_money] && [PublicTool isNull:tzCaseM.valuations_time]) {
        rowStr = @"";
    }else if (![PublicTool isNull:tzCaseM.valuations_time]) {
        rowStr = [NSString stringWithFormat:@"%@  %@  %@",timeStr,tzCaseM.lunci,tzCaseM.valuations_money];
        
    }else{
        rowStr = [NSString stringWithFormat:@"%@  %@",tzCaseM.lunci,tzCaseM.valuations_money];
    }
    
    _lunciMoneyLab.text = rowStr;

    _nameLab.text = tzCaseM.product;
    _hangyeLab.text = tzCaseM.hangye;
    _jianjieLab.text = tzCaseM.yewu;
    
    self.deleteBtn.hidden = YES;
}


- (void)setIconColor:(UIColor *)iconColor{
    if ([PublicTool isNull:_tzCaseM.icon] || [_tzCaseM.icon containsString:@"product_default.png"]) {
        _iconLabel.hidden = NO;
        _iconLabel.backgroundColor = iconColor;
        if (_tzCaseM.product.length > 1) {
            _iconLabel.text = [_tzCaseM.product substringToIndex:1];
        }else{
            _iconLabel.text = @"-";
        }
    }else{
        _iconLabel.hidden = YES;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
