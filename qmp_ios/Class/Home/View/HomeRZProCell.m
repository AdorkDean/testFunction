//
//  HomeProductCell.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2017/12/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "HomeRZProCell.h"

@interface HomeRZProCell()
{
    __weak IBOutlet UIImageView *_iconImgV;
    __weak IBOutlet UILabel *_productName;
    __weak IBOutlet UILabel *_hangyeLab;
    
    __weak IBOutlet UILabel *_timeLab;
    __weak IBOutlet UILabel *_lunciLab;
    __weak IBOutlet UILabel *_moneyLab;
    
    __weak IBOutlet UILabel *_tzJigouLab;
    __weak IBOutlet UILabel *_iconLabel;
}
@end

@implementation HomeRZProCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _iconImgV.layer.cornerRadius = 4;
    _iconImgV.layer.masksToBounds = YES;
    _iconImgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImgV.layer.borderWidth = 0.5;
    
    _iconLabel.layer.cornerRadius = 4;
    _iconLabel.layer.masksToBounds = YES;
    
    _productName.textColor = H27COLOR;
    _tzJigouLab.textColor = HTColorFromRGB(0x838CA1);
    _hangyeLab.textColor = H9COLOR;
    _bottomLabel.textColor = HTColorFromRGB(0x444444);
}

- (void)setCompanyM:(SearchCompanyModel *)companyM{
    _companyM = companyM;
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:companyM.icon] placeholderImage:[UIImage imageNamed:PROICON_DEFAULT]];
    
    _productName.text = companyM.product;
    
    _hangyeLab.text =  companyM.hangye1;
    _hangyeLab.hidden = YES;
    _tzJigouLab.text = companyM.yewu;//newsModel.tzr;
    
    _timeLab.hidden = YES;
    _lunciLab.hidden = YES;
    _moneyLab.hidden = YES;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    NSMutableAttributedString *m = [[NSMutableAttributedString alloc] init];
    if (![PublicTool isNull:companyM.time]) {
        [m appendAttributedString:[self fixtime:companyM.time]];
        [m appendAttributedString:[self fixSoso:@"   "]];
    }
    if (![PublicTool isNull:companyM.lunci]) {
        [m appendAttributedString:[self fixSoso:companyM.lunci]];
        [m appendAttributedString:[self fixSoso:@"   "]];
    }
    if (![PublicTool isNull:companyM.money]) {
        [m appendAttributedString:[self fixSoso:companyM.money]];
        [m appendAttributedString:[self fixSoso:@"   "]];
    }
    for (NSDictionary *dic in companyM.investor_info) {
        NSString *investor = dic[@"investor"];
        if (![PublicTool isNull:investor]) {
            [m appendAttributedString:[self fixSoso:[self fixTZJG:investor]]];
            [m appendAttributedString:[[NSAttributedString alloc]initWithString:@"，"]];
        }
    }
    if (m.length) {
        [m replaceCharactersInRange:NSMakeRange(m.length-1, 1) withString:@""];
    }
    
    [m addAttributes:@{NSParagraphStyleAttributeName: style} range: NSMakeRange(0, m.string.length)];
    self.bottomLabel.attributedText = m;
}

-(void)setNewsModel:(RZNewsModel *)newsModel{
    _newsModel = newsModel;

    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:newsModel.icon] placeholderImage:[UIImage imageNamed:PROICON_DEFAULT]];
    
    _productName.text = newsModel.product;

    _hangyeLab.text =  newsModel.hangye1;
    _hangyeLab.hidden = YES;
    _tzJigouLab.text = newsModel.yewu;//newsModel.tzr;

    _timeLab.hidden = YES;
    _lunciLab.hidden = YES;
    _moneyLab.hidden = YES;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    NSMutableAttributedString *m = [[NSMutableAttributedString alloc] init];
    if (![PublicTool isNull:newsModel.time]) {
        [m appendAttributedString:[self fixtime:newsModel.time]];
        [m appendAttributedString:[self fixSoso:@"   "]];
    }
    if (![PublicTool isNull:newsModel.lunci]) {
        [m appendAttributedString:[self fixSoso:newsModel.lunci]];
        [m appendAttributedString:[self fixSoso:@"   "]];
    }
    if (![PublicTool isNull:newsModel.money]) {
        [m appendAttributedString:[self fixSoso:newsModel.money]];
        [m appendAttributedString:[self fixSoso:@"   "]];
    }
    if (![PublicTool isNull:newsModel.tzr]) {
        [m appendAttributedString:[self fixSoso:[self fixTZJG:newsModel.tzr]]];
    }
    [m addAttributes:@{NSParagraphStyleAttributeName: style} range: NSMakeRange(0, m.string.length)];
    
    self.bottomLabel.attributedText = m;
}

- (NSString *)fixTZJG:(NSString *)str {
    NSString *str2 = [str stringByReplacingOccurrencesOfString:@"资本" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfString:@"创投" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfString:@"母基金" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfString:@"基金" withString:@""];
    return str2;
}

- (NSAttributedString *)fixSoso:(NSString *)soso {
    
    return [[NSAttributedString alloc] initWithString:soso?:@""
                                    attributes:@{NSFontAttributeName:_bottomLabel.font,
                                                 NSForegroundColorAttributeName:H4COLOR,
                                                 }];
}
- (NSAttributedString *)fixtime2:(NSString *)time {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSDate *d = [formatter dateFromString:time];
    if (d.isToday) {
        NSDateFormatter *formatterToday = [[NSDateFormatter alloc] init];
        [formatterToday setDateFormat:@"HH:mm"];
        [formatterToday setLocale:[NSLocale currentLocale]];
        time = [formatterToday stringFromDate:d];
        return [[NSAttributedString alloc] initWithString:time
                                               attributes:@{NSFontAttributeName:_bottomLabel.font, NSForegroundColorAttributeName:BLUE_TITLE_COLOR,}];
    } else if (d.isThisYear) {
        NSDateFormatter *formatterToday = [[NSDateFormatter alloc] init];
        [formatterToday setDateFormat:@"MM.dd"];
        [formatterToday setLocale:[NSLocale currentLocale]];
        time = [formatterToday stringFromDate:d];
    } else {
        NSDateFormatter *formatterToday = [[NSDateFormatter alloc] init];
        [formatterToday setDateFormat:@"yyyy.MM.dd"];
        [formatterToday setLocale:[NSLocale currentLocale]];
        time = [formatterToday stringFromDate:d];
    }
    
    return [[NSAttributedString alloc] initWithString:time
                                           attributes:@{NSFontAttributeName:_bottomLabel.font, NSForegroundColorAttributeName:H4COLOR,}];
}
- (NSAttributedString *)fixtime:(NSString *)time {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.M.dd"];
    NSString * datestring2 = [formatter stringFromDate:date];
    NSString *year = [datestring2 substringToIndex:4];
    
    if ([time isEqualToString:datestring2] || [time containsString:@":"]) {
        return [[NSAttributedString alloc] initWithString:[time containsString:@":"]?time:@"今天"
                                               attributes:@{NSFontAttributeName:_bottomLabel.font, NSForegroundColorAttributeName:BLUE_TITLE_COLOR,}];
    }
    
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:-24*3600];
    datestring2 = [formatter stringFromDate:lastDate];
    if ([time isEqualToString:datestring2]) {
        return [[NSAttributedString alloc] initWithString:@"昨天"
                                               attributes:@{NSFontAttributeName:_bottomLabel.font, NSForegroundColorAttributeName:H4COLOR,}];
        
    }
    if ([time componentsSeparatedByString:@":"].count == 2) {
        return [[NSAttributedString alloc] initWithString:time
                                               attributes:@{NSFontAttributeName:_bottomLabel.font, NSForegroundColorAttributeName:H4COLOR,}];
        
    }
    time = [time stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    time = [time stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@.", year] withString:@""];
    return [[NSAttributedString alloc] initWithString:time
                                           attributes:@{NSFontAttributeName:_bottomLabel.font, NSForegroundColorAttributeName:H4COLOR,}];
    
}


- (void)setIconColor:(UIColor *)iconColor{
    NSString *icon = self.newsModel ? self.newsModel.icon:self.companyM.icon;
    NSString *product = self.newsModel ? self.newsModel.product:self.companyM.product;
    if ([PublicTool isNull:icon]) {
        _iconLabel.hidden = NO;
        _iconLabel.backgroundColor = iconColor;
        if (product.length > 1) {
            _iconLabel.text = [product substringToIndex:1];
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
