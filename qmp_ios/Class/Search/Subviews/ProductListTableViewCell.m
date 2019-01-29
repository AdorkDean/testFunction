//
//  ProductListTableViewCell.m
//  qmp_ios
//
//  Created by Molly on 16/8/23.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "ProductListTableViewCell.h"
#import "FactoryUI.h"
#import <UIImageView+WebCache.h>
 
#import "GetSizeWithText.h"
@interface ProductListTableViewCell()

@property (strong, nonatomic) UIImageView *iconImageV;//icon
@property (strong, nonatomic) UIButton *productBtn;//产品名字
@property (strong, nonatomic) UILabel *yewuLab;//业务
@property (strong, nonatomic) UILabel *statusLbl;
@property (strong, nonatomic) UILabel *curlunciLab;//当前轮次

@property (strong, nonatomic) GetSizeWithText *sizeTool;

@end

@implementation ProductListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    
    return self;
}

-(void)buildUI
{
    NSString *zwStr = @"";
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    CGFloat margin = 16.f;
    
    //icon
    _iconImageV = [[UIImageView alloc] initWithFrame:CGRectMake(margin, 10, 45, 45)];
    _iconImageV.layer.cornerRadius = 5;
    _iconImageV.layer.masksToBounds = YES;
    _iconImageV.layer.borderWidth = 0.5;
    _iconImageV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconImageV];
    
    _statusLbl = [[UILabel alloc]initWithFrame:CGRectMake( 0, _iconImageV.frame.size.height - 18, _iconImageV.frame.size.width, 18)];
    _statusLbl.text = @"融资中";
    _statusLbl.textAlignment = NSTextAlignmentCenter;
    _statusLbl.textColor = [UIColor whiteColor];
    _statusLbl.font = [UIFont systemFontOfSize:11.f];
    _statusLbl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_iconImageV addSubview:_statusLbl];
    
    //产品名字
    _productBtn = [[UIButton alloc] init];
    [_productBtn setTitle:zwStr forState:UIControlStateNormal];
    [_productBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _productBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _productBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_productBtn];
    _productBtn.userInteractionEnabled = NO;
    
    //当前轮次
    _curlunciLab = [FactoryUI createLabelWithFrame:CGRectMake(_productBtn.right+5, 0, 20, 16) text:zwStr font:[UIFont systemFontOfSize:10]];
    _curlunciLab.textAlignment = NSTextAlignmentCenter;
    _curlunciLab.layer.cornerRadius = 2;
    _curlunciLab.layer.masksToBounds = YES;
    _curlunciLab.textColor = BLUE_TITLE_COLOR;
    _curlunciLab.backgroundColor = BLUE_LIGHT_COLOR;
    [self.contentView addSubview:_curlunciLab];
    
    //业务
    _yewuLab = [FactoryUI createLabelWithFrame:CGRectMake(_productBtn.left, _productBtn.bottom+10, SCREENW-10*2-56-20, 20) text:zwStr font:[UIFont systemFontOfSize:14]];
    _yewuLab.textColor = RGB(70, 69, 75, 1);
    [self.contentView addSubview:_yewuLab];
    
    CGFloat btnW = 64.f;
    CGFloat btnH = 40.f;
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - btnW - 8 , 10, btnW, btnH)];
    [addBtn setTitleColor:RGBa(100,99,105,1) forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [addBtn setTitle:@"添加" forState:UIControlStateNormal];
    [addBtn setImage:[BundleTool imageNamed:@"add-yellow"] forState:UIControlStateNormal];
    [addBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    [self.contentView addSubview:addBtn];
    _addBtn = addBtn;
    
    UIButton *hasAddedBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - btnW - 8 , 0, btnW, btnH)];
    [hasAddedBtn setTitle:@"已添加" forState:UIControlStateNormal];
    [hasAddedBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.contentView addSubview:hasAddedBtn];
    hasAddedBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    _hasAddedBtn = hasAddedBtn;

}

-(void)refreshUI:(SearchCompanyModel *)model
{
    CGFloat margin = 10.f;
    CGFloat lblH =20.f;

    self.model = model;
    
    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[BundleTool imageNamed:@"product_default"]];

    //轮次size
    
    CGSize lcSize = [self.sizeTool calculateSize:model.lunci withFont:_curlunciLab.font withWidth:100];

    //产品
    NSString *productName = @"";
    if (model.product&&![PublicTool isNull:model.product]) {
        productName = model.product;
    }else{
        productName = @"";
    }
    productName = [PublicTool isNull:productName]? @"-" :productName;
    [_productBtn setTitle:productName forState:UIControlStateNormal];

    CGFloat productX = _iconImageV.right + margin;
    CGFloat productW = [PublicTool widthOfString:productName height:CGFLOAT_MAX fontSize:16];
    productW = productW > (SCREENW - productX - lcSize.width-10 - 5 - 80) ? (SCREENW - productX - lcSize.width-10 - 5 - 80) : productW;
    _productBtn.frame = CGRectMake(productX, _iconImageV.top + 2, productW, lblH);
    
    CGFloat lunciX = _productBtn.right + margin;
    
    lunciX = _productBtn.right + 5;

    
    //轮次
    if([PublicTool isNull:model.lunci]){
        
        _curlunciLab.hidden = YES;
    }
    else{
        _curlunciLab.hidden = NO;
        _curlunciLab.text = model.lunci;
        [_curlunciLab setFrame:CGRectMake(lunciX, 0, ceil(lcSize.width)+8, 16)];
        _curlunciLab.centerY = _productBtn.centerY;
    }
    
    //业务
    NSString *yewu = (![PublicTool isNull:model.yewu])? model.yewu:@"";
    if ([PublicTool isNull:yewu]&&![PublicTool isNull:model.desc]) {
        yewu = model.desc;
    }
    yewu = ![PublicTool isNull:yewu] ? yewu:@"-";
    _yewuLab.text = yewu;
    [_yewuLab setFrame:CGRectMake( _productBtn.left, _productBtn.bottom + 3, SCREENW-10*2-56-20, 20)];
}

- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}

@end
