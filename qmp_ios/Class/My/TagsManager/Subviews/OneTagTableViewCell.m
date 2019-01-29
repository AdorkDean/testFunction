//
//  OneTagTableViewCell.m
//  qmp_ios
//
//  Created by molly on 2017/5/19.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "OneTagTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "GetSizeWithText.h"

@interface OneTagTableViewCell()

@property (nonatomic,strong)UIImageView *iconImageV;
@property (nonatomic,strong)UIImageView *starImgV;
@property (nonatomic,strong)UILabel * productLab;
@property (nonatomic,strong)UILabel * yewuLab;
@property (nonatomic,strong)UILabel * curlunciLab;
@property (nonatomic,strong)UILabel * hangyeLab;
@property (nonatomic,strong)UILabel * provinceLab;
@property (nonatomic,strong)UILabel * dateLab;
@property (strong, nonatomic) UILabel *infoLbl;
@property (strong, nonatomic) UILabel *statusLbl;

@end
@implementation OneTagTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    
    return self;
}

- (void)buildUI
{
    
    CGFloat margin = 10.f;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _iconImageV = [[UIImageView alloc] initWithFrame:CGRectMake(margin, margin, 60, 60)];
    _iconImageV.layer.cornerRadius = 5;
    _iconImageV.layer.masksToBounds = YES;
    _iconImageV.layer.borderWidth = 0.5;
    _iconImageV.layer.borderColor = RGBLineGray.CGColor;
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconImageV];
    
    _starImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_iconImageV.frame.origin.x + _iconImageV.frame.size.width + margin, _iconImageV.frame.origin.y - 2, 20, 20)];
    _starImgV.image = [BundleTool imageNamed:@"star"];
    [self.contentView addSubview:_starImgV];
    
    _statusLbl = [[UILabel alloc]initWithFrame:CGRectMake( 0, _iconImageV.frame.size.height - 18, _iconImageV.frame.size.width, 18)];
    _statusLbl.text = @"融资中";
    _statusLbl.textAlignment = NSTextAlignmentCenter;
    _statusLbl.textColor = [UIColor whiteColor];
    _statusLbl.font = [UIFont systemFontOfSize:13.f];
    _statusLbl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_iconImageV addSubview:_statusLbl];
    
    //产品名字
    UILabel *productLbl = [[UILabel alloc] init];
    productLbl.font = [UIFont systemFontOfSize:16.f];
    productLbl.textColor = [UIColor blackColor];
    productLbl.numberOfLines = 1;
    productLbl.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:productLbl];
    _productLab = productLbl;
    
    //当前轮次
    UILabel *curLcLbl = [[UILabel alloc] init];
    curLcLbl.font = [UIFont systemFontOfSize:11];
    curLcLbl.numberOfLines = 1;
    curLcLbl.textColor = RGBa(255,134,13,1);
    curLcLbl.layer.borderWidth = 0.5f;
    curLcLbl.layer.borderColor = RGBa(255,134,13,1).CGColor;
    curLcLbl.backgroundColor = [UIColor whiteColor];
    curLcLbl.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:curLcLbl];
    _curlunciLab = curLcLbl;
    
    //业务
    UILabel *ywLbl = [[UILabel alloc] init];
    ywLbl.font = [UIFont systemFontOfSize:14.f];
    ywLbl.numberOfLines = 1;
    ywLbl.textColor = RGBblackColor;
    [self.contentView addSubview:ywLbl];
    _yewuLab = ywLbl;
    
    //行业/地区/时间
    UILabel *infoLbl = [[UILabel alloc] init];
    infoLbl.numberOfLines = 1;
    infoLbl.font = [UIFont systemFontOfSize:12.f];
    infoLbl.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:infoLbl];
    _infoLbl = infoLbl;
    
}


- (void)initData:(SearchCompanyModel *)model{
    CGFloat margin = 10.f;
    CGFloat lblH =20.f;
    
    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[BundleTool imageNamed:@"product_default"]];
    
    BOOL isStar = NO;
    _starImgV.hidden = !isStar;
    _statusLbl.hidden = [model.need_flag isEqualToString:@"0"];
    
    //产品
    NSString *productName = @"";
    if (![PublicTool isNull:model.product]) {
        productName = model.product;
    }else{
        productName = @"-";
    }
    _productLab.text = productName;
    CGFloat productX = isStar ?_starImgV.frame.origin.x + _starImgV.frame.size.width : _iconImageV.frame.origin.x + _iconImageV.frame.size.width + margin;
    CGFloat productW = SCREENW - productX - margin ;
    CGFloat pW = [GetSizeWithText calculateSize:productName withFont:_productLab.font withWidth:productW].width;
    [_productLab setFrame:CGRectMake(productX, _iconImageV.frame.origin.y - 2, pW > productW ? productW :pW, lblH)];
    
    //轮次
    NSString *jieduan = nil;
    if (![PublicTool isNull:model.lunci]) {
        jieduan = model.lunci;
    }else{
        jieduan = @"";
    }

    if([jieduan isEqualToString:@""]){
        _curlunciLab.hidden = YES;
    }
    else{
        _curlunciLab.hidden = NO;
        _curlunciLab.text = jieduan;
        CGSize lcSize = [GetSizeWithText calculateSize:jieduan withFont:_curlunciLab.font withWidth:100];
        [_curlunciLab setFrame:CGRectMake(_productLab.frame.origin.x+_productLab.frame.size.width+5, _productLab.frame.origin.y+2, ceil(lcSize.width) + 4, lblH - 4)];
    }
    
    CGFloat lblX = _iconImageV.frame.origin.x + _iconImageV.frame.size.width + margin;
    CGFloat lblW = SCREENW - lblX - margin;
    
    //业务
    NSString *yewu = ![PublicTool isNull:model.yewu]? model.yewu:@"";
    if ([PublicTool isNull:yewu]&&![PublicTool isNull:model.desc]) {
        yewu = model.desc;
    }
    yewu = ![PublicTool isNull:yewu] ? yewu:@"-";
    _yewuLab.text = yewu;
    _yewuLab.frame = CGRectMake(lblX, _productLab.frame.origin.y+_productLab.frame.size.height + 4,  lblW, lblH);
    
    UIColor *textColor = RGBa(95,95,95,1);
    
    //行业
    NSString *hangye = nil;
    if (![PublicTool isNull:model.hangye1]) {
        hangye = model.hangye1;
    }else{
        hangye = @"-";
    }
    //地区
    NSString *provience = [PublicTool isNull:model.province] ? @"-" : model.province;
    //成立日期
    NSString *opentime = nil;
    if (![PublicTool isNull:model.open_time]) {
        opentime = model.open_time;
    }else{
        opentime = @"-";
    }    
    _infoLbl.text = [NSString stringWithFormat:@"%@ / %@ / %@",hangye,provience,opentime];
    _infoLbl.textColor = textColor;
    _infoLbl.frame = CGRectMake(lblX, _yewuLab.frame.origin.y+_yewuLab.frame.size.height+4, lblW, lblH);
}
@end
