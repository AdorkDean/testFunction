//
//  ProductHomeCell.m
//  qmp_ios
//
//  Created by QMP on 2018/3/21.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductHomeCell.h"
#import "InsetsLabel.h"

@interface ProductHomeCell()
{
    __weak IBOutlet UIImageView *_iconImgV;
    __weak IBOutlet UILabel *_nameLab;
    
    __weak IBOutlet UILabel *_hangyeLab;
    __weak IBOutlet UILabel *_yewuLab;
    __weak IBOutlet UILabel *_iconLab;
    __weak IBOutlet UILabel *_lunciLab;
    __weak IBOutlet UILabel *_moneyLab;
    __weak IBOutlet InsetsLabel *_currentLunLab;
    
    __weak IBOutlet UILabel *bpLabel;
}
@end

@implementation ProductHomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _iconImgV.layer.cornerRadius = 4;
    _iconImgV.layer.masksToBounds = YES;
    _iconImgV.layer.borderWidth = 0.5;
    _iconImgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImgV.contentMode = UIViewContentModeScaleAspectFit;
    
    [_currentLunLab labelWithFontSize:10 textColor:BLUE_TITLE_COLOR cornerRadius:1.5 borderWdith:0.5 borderColor:RGBBlueColor];
    
    _iconLab.layer.cornerRadius = 4;
    _iconLab.layer.masksToBounds = YES;

    bpLabel.layer.cornerRadius = 2.0;
    bpLabel.clipsToBounds = YES;
}


-(void)setProductM:(StarProductsModel *)productM{
    
    _productM = productM;
    
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:productM.icon] placeholderImage:[UIImage imageNamed:PROICON_DEFAULT]];
    
    
    //产品
    NSString *productName =  [PublicTool isNull:productM.name] ? ([PublicTool isNull:productM.product] ? @"":productM.product) :productM.name;
    _nameLab.text = productName;
    
    //轮次
    NSString *jieduan = [PublicTool isNull:productM.jieduan] ? ([PublicTool isNull:productM.curlunci] ? @"-":productM.curlunci) :productM.jieduan;
    
    if([jieduan isEqualToString:@"-"]){
        _currentLunLab.text = @"";
        _currentLunLab.hidden = YES;
    }
    else{
        _currentLunLab.hidden = NO;
        _currentLunLab.text = jieduan;
    }
    
    NSString *unitStr = [productM.unit isEqualToString:@"人民币"] ? @"￥":([productM.unit isEqualToString:@"美元"]?@"$":@"");
    unitStr = [self fixMoneyType:productM.unit];
    if ([PublicTool isNull:productM.need_lunci]) {
        _lunciLab.text = @"";
    }else{
         _lunciLab.text = [NSString stringWithFormat:@"融资需求：%@",[PublicTool isNull:productM.need_lunci] ? @"暂无":productM.need_lunci];
    }
    if (![PublicTool isNull:productM.need_money]) {
        _moneyLab.text = [NSString stringWithFormat:@"%@%@",unitStr,productM.need_money];
    }else{
        _moneyLab.text = @"";
    }

    //业务
    NSString *yewu = [PublicTool isNull:productM.yewu] ? @"-":productM.yewu;
    _yewuLab.text = yewu;
    
    
    //行业
    NSString *hangye = [PublicTool isNull:productM.hangye] ?  ([PublicTool isNull:productM.hangye1] ? @"":productM.hangye1):productM.hangye;
    _hangyeLab.text = hangye;
    
    // BP
    bpLabel.hidden = [PublicTool isNull:productM.bp_file_id] || [PublicTool isNull:productM.bp_name];
    
    
}
- (NSString *)fixMoneyType:(NSString *)type {
    NSDictionary *dict = @{@"人民币":@"￥",@"欧元":@"€",@"美元":@"$",@"英镑":@"£",@"日元":@"J￥",@"新台币":@"NT",@"港币":@"HKD"};
    return dict[type]?dict[type]:type;
}
- (void)setIconColor:(UIColor *)iconColor{
    
    if ([PublicTool isNull:_productM.icon] || [_productM.icon containsString:@"product_default.png"]) {
        _iconLab.hidden = NO;
        _iconLab.backgroundColor = iconColor;
        if (_nameLab.text.length > 1) {
            _iconLab.text = [_nameLab.text substringToIndex:1];
        }else{
            _iconLab.text = @"-";
        }
    }else{
        _iconLab.hidden = YES;
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
