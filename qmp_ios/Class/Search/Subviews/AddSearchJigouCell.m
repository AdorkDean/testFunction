//
//  AddSearchJigouCell.m
//  qmp_ios
//
//  Created by QMP on 2017/11/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "AddSearchJigouCell.h"

#import <UIImageView+WebCache.h>
#import "FactoryUI.h"
#import "GetSizeWithText.h"

@interface AddSearchJigouCell()

@property (strong, nonatomic) UIImageView *iconImageV;//icon
@property (strong, nonatomic) UIButton *productBtn;//产品名字
//@property (strong, nonatomic) UILabel *provinceLab;//地区
//@property (strong, nonatomic) UILabel *yewuLab;//业务
@property (strong, nonatomic) UILabel *jianjieLab;//简介


@property (strong, nonatomic) GetSizeWithText *sizeTool;

@end

@implementation AddSearchJigouCell

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
    CGFloat margin = 10.f;
    
    //icon
    _iconImageV = [[UIImageView alloc] initWithFrame:CGRectMake(margin, margin, 60, 60)];
    _iconImageV.layer.cornerRadius = 5;
    _iconImageV.layer.masksToBounds = YES;
    _iconImageV.layer.borderWidth = 0.5;
    _iconImageV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconImageV];
 
   
    
    //产品名字
    _productBtn = [[UIButton alloc] init];
    [_productBtn setTitle:zwStr forState:UIControlStateNormal];
    [_productBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _productBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _productBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_productBtn];
    _productBtn.userInteractionEnabled = NO;
    
    
    //地区
    _jianjieLab = [FactoryUI createLabelWithFrame:CGRectZero text:zwStr font:[UIFont systemFontOfSize:12]];
    _jianjieLab.textAlignment = NSTextAlignmentLeft;
    _jianjieLab.textColor = RGB(70, 69, 75, 1);
    [self.contentView addSubview:_jianjieLab];

    
    CGFloat btnW = 64.f;
    CGFloat btnH = 40.f;
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - btnW - 8 , 0, btnW, btnH)];
    [addBtn setTitleColor:RGBa(100,99,105,1) forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [addBtn setTitle:@"添加" forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"add-yellow"] forState:UIControlStateNormal];
    [addBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    [self.contentView addSubview:addBtn];
    _addBtn = addBtn;
    
    UIButton *hasAddedBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - btnW - 8 , 0, btnW, btnH)];
    [hasAddedBtn setTitle:@"已添加" forState:UIControlStateNormal];
    [hasAddedBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.contentView addSubview:hasAddedBtn];
    hasAddedBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    _hasAddedBtn = hasAddedBtn;
    
}

-(void)refreshUI:(OrganizeItem *)model
{
    CGFloat margin = 10.f;
    CGFloat lblH =20.f;
    
    self.model = model;
    
    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"product_default"]];
    
//    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"product_default"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        _iconImageV.image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(80, 80)];
//    }];
    
    //产品
    NSString *productName = @"";
    if (model.jigou_name&&![PublicTool isNull:model.jigou_name]) {
        productName = model.jigou_name;
    }else{
        productName = @"";
    }
    productName = [PublicTool isNull:productName]? @"-" :productName;
    [_productBtn setTitle:productName forState:UIControlStateNormal];
    
    CGFloat productX =  _iconImageV.right + margin;
    CGFloat productW =  SCREENW-productX-10;
    _productBtn.frame = CGRectMake(productX, _iconImageV.top + 5, productW-65, lblH);
    
    _jianjieLab.text = model.miaoshu;
    _jianjieLab.frame = CGRectMake(productX, _productBtn.bottom+10, productW, lblH);
    
   
}

- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}


@end
