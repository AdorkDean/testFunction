//
//  SearchRegistCell.m
//  qmp_ios
//
//  Created by QMP on 2017/11/15.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "SearchRegistCell.h"


@interface SearchRegistCell()
{
    __weak IBOutlet UILabel *farenTitle;
    
    __weak IBOutlet UILabel *dateTitle;
    __weak IBOutlet UILabel *zibenTitle;
    __weak IBOutlet UIImageView *_iconImgV;
    __weak IBOutlet UILabel *_jigouNameLab;
    __weak IBOutlet UILabel *_farenLab;
    __weak IBOutlet UILabel *_registMonLab;
    
    __weak IBOutlet UILabel *_dateLab;
    
    __weak IBOutlet UILabel *_nameIconLab;
    __weak IBOutlet UIView *_line1;
    __weak IBOutlet UIView *_line2;
    
    __weak IBOutlet NSLayoutConstraint *_line2Leading;
    __weak IBOutlet NSLayoutConstraint *_line1Leading;
    
    __weak IBOutlet NSLayoutConstraint *_viewWidth;
    __weak IBOutlet UIView *contentV;
    
}
@end
@implementation SearchRegistCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _iconImgV.layer.cornerRadius = 5;
    _iconImgV.layer.masksToBounds = YES;
    _iconImgV.layer.borderWidth = 0.5;
    _iconImgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImgV.contentMode = UIViewContentModeScaleAspectFit;
    
    _nameIconLab.layer.cornerRadius = 5;
    _nameIconLab.layer.masksToBounds = YES;
    
    _jigouNameLab.textColor = H3COLOR;
    if (@available(iOS 8.2, *)) {
        _jigouNameLab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    } else {
        _jigouNameLab.font = [UIFont systemFontOfSize:15];
        
    }
    
    [farenTitle labelWithFontSize:13 textColor:H999999];
    [zibenTitle labelWithFontSize:13 textColor:H999999];
    [dateTitle labelWithFontSize:13 textColor:H999999];

    _farenLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [_farenLab labelWithFontSize:14 textColor:H3COLOR];
    [_registMonLab labelWithFontSize:14 textColor:H3COLOR];
    [_dateLab labelWithFontSize:14 textColor:H3COLOR];

    _line2.backgroundColor = HTColorFromRGB(0xDBDBDB);
    _line1.backgroundColor = HTColorFromRGB(0xDBDBDB);
    
    farenTitle.textAlignment = NSTextAlignmentCenter;
    zibenTitle.textAlignment = NSTextAlignmentCenter;
    dateTitle.textAlignment = NSTextAlignmentCenter;
    _farenLab.textAlignment = NSTextAlignmentCenter;
    _registMonLab.textAlignment = NSTextAlignmentCenter;
    _dateLab.textAlignment = NSTextAlignmentCenter;
}

- (void)setRegistModel:(SearchProRegisterModel *)registModel{
    _registModel = registModel;
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:registModel.company];
    if (![PublicTool isNull:self.keyWord]) {
        NSArray *rangs = [PublicTool rangeOfSubString:self.keyWord inString:registModel.company];
        for (NSValue *rangStr in rangs) {
            NSRange range = rangStr.rangeValue;
            [attText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:range];
        }
    }
    _jigouNameLab.attributedText = attText;

    _farenLab.text = [NSString stringWithFormat:@"%@",[PublicTool nilStringReturn:registModel.faren]];
    NSString *ziben = [PublicTool nilStringReturn:registModel.qy_ziben];
    ziben = [ziben stringByReplacingOccurrencesOfString:@"人民币" withString:@""];
    _registMonLab.text = [NSString stringWithFormat:@"%@",ziben];
    NSString *time = [PublicTool nilStringReturn:registModel.open_time];
    time = [time stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    _dateLab.text = [NSString stringWithFormat:@"%@",time];
    
    if (SCREENW > 375) {
        _viewWidth.constant = 320;
    }else{
        _viewWidth.constant = 280;
    }
    [contentV updateConstraints];
    [self.contentView updateConstraints];
}

- (void)setNameIconColor:(UIColor *)nameIconColor{
    
    _nameIconLab.backgroundColor = nameIconColor;
    
    if (_registModel.company && _registModel.company.length>0 ) {
        _nameIconLab.text = [_registModel.company substringToIndex:1];
        _nameIconLab.hidden = NO;
        
    }else{
        _nameIconLab.hidden = YES;
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = 280;
    if (SCREENW > 375) {
        width = 320;
        _line1Leading.constant = width/3.5;
        _line2Leading.constant = width/3*1.9-2;
    }else{
        width = 280;
        _line1Leading.constant = width/4.0 + 10;
        _line2Leading.constant = width/3.2*2;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
