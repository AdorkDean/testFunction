//
//  ActiveJigouCell.m
//  qmp_ios
//
//  Created by QMP on 2017/11/9.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "ActiveJigouCell.h"

@interface ActiveJigouCell(){
    
    __weak IBOutlet UIImageView *iconImgV;
    __weak IBOutlet UILabel *_jigouNameLabel;
    __weak IBOutlet UILabel *_recentTZL;
    __weak IBOutlet UILabel *_tzCountL;
    __weak IBOutlet UILabel *_iconLabel;
}
@end

@implementation ActiveJigouCell

- (void)awakeFromNib {
    [super awakeFromNib];
    iconImgV.layer.cornerRadius = 2;
    iconImgV.layer.masksToBounds = YES;
    iconImgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    iconImgV.layer.borderWidth = 0.5;
    
    _iconLabel.layer.cornerRadius = 2;
    _iconLabel.layer.masksToBounds = YES;
    
    _jigouNameLabel.textColor = NV_TITLE_COLOR;
    
    if (@available(iOS 8.2, *)) {
        _jigouNameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    } else {
        _jigouNameLabel.font = [UIFont systemFontOfSize:15];
    }
    _recentTZL.textColor = H5COLOR;
    _tzCountL.textColor = BLUE_TITLE_COLOR;
    
}


- (void)setJigouModel:(ActiveJigouModel *)jigouModel{
    _jigouModel = jigouModel;
    [iconImgV sd_setImageWithURL:[NSURL URLWithString:jigouModel.icon] placeholderImage:[BundleTool imageNamed:@"product_default"]];
   
//    [iconImgV sd_setImageWithURL:[NSURL URLWithString:jigouModel.icon] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        iconImgV.image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(80, 80)];
//    }];
    
    

    if (_isFa) {
        NSMutableString *touziStr = [NSMutableString string];
        if (jigouModel.product) {
            _recentTZL.text = [NSString stringWithFormat:@"最近服务: %@",jigouModel.product.product];
        }
        
        _jigouNameLabel.text = jigouModel.agency_name;
        _tzCountL.text = [NSString stringWithFormat:@"%@",jigouModel.count];
    }else{
        NSMutableString *touziStr = [NSMutableString string];
        if (jigouModel.product) {
            _recentTZL.text = [NSString stringWithFormat:@"最近投资: %@",jigouModel.product.product];
        }
        _jigouNameLabel.text = jigouModel.name;
        _tzCountL.text = [NSString stringWithFormat:@"%@",jigouModel.num];
    }
    
    
}
- (void)setIsFa:(BOOL)isFa{
    _isFa = isFa;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
