//
//  CompanyProductTableViewCell.m
//  qmp_ios
//
//  Created by molly on 2017/6/9.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "CompanyProductTableViewCell.h"
#import <UIImageView+WebCache.h>
@interface CompanyProductTableViewCell()
{
    SearchCompanyModel *_company;
}
@property (nonatomic,strong)UIImageView *iconImageV;
@property (nonatomic,strong)UILabel *iconLabel;

@property (nonatomic,strong)UILabel * productLab;
@property (nonatomic,strong)UILabel * yewuLab;

@end

@implementation CompanyProductTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI{
    
    CGFloat margin = 17.f;
    CGFloat top = 17;
    CGFloat iconW = 40.f;
    _iconImageV = [[UIImageView alloc] initWithFrame:CGRectMake(margin, top, iconW, iconW)];
    _iconImageV.layer.cornerRadius = 5;
    _iconImageV.layer.masksToBounds = YES;
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconImageV];
    
    self.iconLabel = [[UILabel alloc]initWithFrame:CGRectMake(margin, top, iconW, iconW)];
    self.iconLabel.layer.cornerRadius = 5;
    self.iconLabel.layer.masksToBounds = YES;
    [self.iconLabel labelWithFontSize:16 textColor:[UIColor whiteColor]];
    self.iconLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.iconLabel];

    
    //产品名字
    CGFloat productX = _iconImageV.right + 14;
    CGFloat productW = SCREENW - productX - margin;
    UILabel *productLbl = [[UILabel alloc] initWithFrame:CGRectMake(productX, 17,productW , 17.f)];
    productLbl.font = [UIFont systemFontOfSize:15];
    productLbl.textColor = HTColorFromRGB(0x1d1d1d);
    productLbl.numberOfLines = 1;
    productLbl.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:productLbl];
    _productLab = productLbl;
    
    //业务
    UILabel *ywLbl = [[UILabel alloc] initWithFrame:CGRectMake(productX, 42, productW, 14.f)];
    ywLbl.font = [UIFont systemFontOfSize:13.f];
    ywLbl.textColor = H9COLOR;
    [self.contentView addSubview:ywLbl];
    _yewuLab = ywLbl;
    
    self.bottomLine = [[UIView alloc]initWithFrame:CGRectMake(17, 74.5, SCREENW - 34, 0.5)];
    self.bottomLine.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:self.bottomLine];
}

- (void)initData:(SearchCompanyModel *)model{
    _company = model;
    
    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[BundleTool imageNamed:@"product_default"]];
    _productLab.text = model.product;
    _yewuLab.text = [PublicTool isNull:model.yewu] ? model.desc : model.yewu;

}

- (void)setIconColor:(UIColor *)iconColor{
    
    if ([PublicTool isNull:_company.icon] || [_company.icon containsString:@"product_default.png"]) {
        self.iconLabel.hidden = NO;
        self.iconLabel.backgroundColor = iconColor;
        if (_company.product.length > 1) {
            self.iconLabel.text = [_company.product substringToIndex:1];
        }else{
            self.iconLabel.text = @"-";
        }
    }else{
        self.iconLabel.hidden = YES;
    }
}
@end
