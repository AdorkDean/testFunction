//
//  EventCell.m
//  qmp_ios
//
//  Created by QMP on 2017/12/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "EventCell.h"

@interface EventCell()
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

@implementation EventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _iconImgV.layer.cornerRadius = 5;
    _iconImgV.layer.masksToBounds = YES;
    _iconImgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImgV.layer.borderWidth = 0.5;
    
    _iconLabel.layer.cornerRadius = 5;
    _iconLabel.layer.masksToBounds = YES;
}

-(void)setNewsModel:(RZNewsModel *)newsModel{
    _newsModel = newsModel;
    
//    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:newsModel.icon] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        _iconImgV.image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(80, 80)];
//    }];
    
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:newsModel.icon] placeholderImage:[BundleTool imageNamed:PROICON_DEFAULT]];
    
    _productName.text = newsModel.product;
//    NSString *time = newsModel.time;
//    if ([time containsString:@"."]) {
//        time = [time stringByReplacingOccurrencesOfString:@"." withString:@"-"];
//    }
   
//    _timeLab.text = [PublicTool nilStringReturn:newsModel.time];
    
    _hangyeLab.text =  newsModel.hangye1;
    _tzJigouLab.text = newsModel.yewu;//newsModel.tzr;
    
    
//    _timeLab.attributedText = [self fixtime:newsModel.time];
//    _lunciLab.text = [PublicTool nilStringReturn:newsModel.lunci];
//    _moneyLab.text =  [PublicTool nilStringReturn:newsModel.money];
    _timeLab.hidden = YES;
    _lunciLab.hidden = YES;
    _moneyLab.hidden = YES;
    
    NSMutableAttributedString *m = [[NSMutableAttributedString alloc] init];
    [m appendAttributedString:[self fixtime:newsModel.time]];
    [m appendAttributedString:[self fixtime:@" "]];
    [m appendAttributedString:[self fixSoso:newsModel.lunci]];
    [m appendAttributedString:[self fixtime:@" "]];
    [m appendAttributedString:[self fixSoso:newsModel.money]];
    [m appendAttributedString:[self fixtime:@" "]];
    [m appendAttributedString:[self fixSoso:newsModel.tzr]];
    
    self.bottomLabel.attributedText = m;
}

- (NSAttributedString *)fixSoso:(NSString *)soso {
    return [[NSAttributedString alloc] initWithString:soso?:@""
                                    attributes:@{NSFontAttributeName:_timeLab.font, NSForegroundColorAttributeName:HTColorFromRGB(0x63656A)}];
}

- (NSAttributedString *)fixtime:(NSString *)time {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.M.dd"];
    NSString * datestring2 = [formatter stringFromDate:date];
    
    if ([time isEqualToString:datestring2]) {
        return [[NSAttributedString alloc] initWithString:@"今天"
                                               attributes:@{NSFontAttributeName:_timeLab.font, NSForegroundColorAttributeName:BLUE_TITLE_COLOR,}];
    }
    
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:-24*3600];
    datestring2 = [formatter stringFromDate:lastDate];
    if ([time isEqualToString:datestring2]) {
        return [[NSAttributedString alloc] initWithString:@"昨天"
                                               attributes:@{NSFontAttributeName:_timeLab.font, NSForegroundColorAttributeName:HTColorFromRGB(0x63656A),}];
        
    }
    if ([time componentsSeparatedByString:@":"].count == 2) {
        return [[NSAttributedString alloc] initWithString:time
                                               attributes:@{NSFontAttributeName:_timeLab.font, NSForegroundColorAttributeName:BLUE_TITLE_COLOR,}];
        
    }
    return [[NSAttributedString alloc] initWithString:time
                                           attributes:@{NSFontAttributeName:_timeLab.font, NSForegroundColorAttributeName:HTColorFromRGB(0x63656A),}];
    
}

- (void)setIconColor:(UIColor *)iconColor{
    if ([PublicTool isNull:_newsModel.icon] || [_newsModel.icon containsString:@"product_default.png"]) {
        _iconLabel.hidden = NO;
        _iconLabel.backgroundColor = iconColor;
        if (_newsModel.product.length > 1) {
            _iconLabel.text = [_newsModel.product substringToIndex:1];
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
