//
//  ProductListCell.m
//  qmp_ios
//
//  Created by QMP on 2017/12/29.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "ProductListCell.h"
#import "InsetsLabel.h"

@interface ProductListCell()
{
    
    __weak IBOutlet UIImageView *_imgV;
    __weak IBOutlet UILabel *_productLab;
    __weak IBOutlet InsetsLabel *_lunciLab;
    
    __weak IBOutlet UILabel *_hangeyeLab;
    __weak IBOutlet UILabel *_descLab;
    __weak IBOutlet UILabel *_iconLabel;
}
@end
@implementation ProductListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _imgV.layer.cornerRadius = 5;
    _imgV.layer.masksToBounds = YES;
    _imgV.layer.borderWidth = 0.5;
    _imgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _imgV.contentMode = UIViewContentModeScaleAspectFit;

    [_lunciLab labelWithFontSize:10 textColor:BLUE_TITLE_COLOR cornerRadius:2];
    _lunciLab.backgroundColor = LABEL_BG_COLOR;
    
    _iconLabel.layer.cornerRadius = 5;
    _iconLabel.layer.masksToBounds = YES;
    
    _hangeyeLab.textColor = H9COLOR;
}


-(void)setProductM:(StarProductsModel *)productM{
    
    _productM = productM;
    [_imgV sd_setImageWithURL:[NSURL URLWithString:productM.icon] placeholderImage:[BundleTool imageNamed:PROICON_DEFAULT]];
    
//    [_imgV sd_setImageWithURL:[NSURL URLWithString:productM.icon] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        _imgV.image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(80, 80)];
//    }];
    
    //产品
    NSString *productName =  [PublicTool isNull:productM.name] ? ([PublicTool isNull:productM.product] ? @"":productM.product) :productM.name;
    _productLab.text = productName;

    //轮次
    NSString *jieduan = [PublicTool isNull:productM.jieduan] ? ([PublicTool isNull:productM.curlunci] ? @"-":productM.curlunci) :productM.jieduan;
    
    if([jieduan isEqualToString:@"-"]){
        _lunciLab.text = @"";
        _lunciLab.hidden = YES;
    }
    else{
        _lunciLab.hidden = NO;
        _lunciLab.text = jieduan;
    }
    
    //业务
    NSString *yewu = [PublicTool isNull:productM.yewu] ? @"-":productM.yewu;
    _descLab.text = yewu;
    
    
    //行业
    NSString *hangye = [PublicTool isNull:productM.hangye] ?  ([PublicTool isNull:productM.hangye1] ? @"":productM.hangye1):productM.hangye;    
    _hangeyeLab.text = hangye;
    
    
}

- (void)setIconColor:(UIColor *)iconColor{
    
    if ([PublicTool isNull:_productM.icon] || [_productM.icon containsString:@"product_default.png"]) {
        _iconLabel.hidden = NO;
        _iconLabel.backgroundColor = iconColor;
        if (_productLab.text.length > 1) {
            _iconLabel.text = [_productLab.text substringToIndex:1];
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
