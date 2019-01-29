//
//  SearchCompanyTableViewCell.m
//  qmp_ios
//
//  Created by qimingpian08 on 16/11/1.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "SearchCompanyTableViewCell.h"
#import "SearchCompanyModel.h"
#import "GetSizeWithText.h"

@interface SearchCompanyTableViewCell ()
@property (nonatomic,strong)UIImageView *iconImageV;
@property (nonatomic,strong)UILabel * productLab;
@property (nonatomic,strong)UILabel * yewuLab;
//@property (nonatomic,strong)UILabel * curlunciLab;
//@property (strong, nonatomic) UILabel *infoLbl;
@property (nonatomic,strong)UIImageView *starImgV;
@property (strong, nonatomic) UILabel *statusLbl;
@property (strong, nonatomic) GetSizeWithText *sizeTool;

@end
@implementation SearchCompanyTableViewCell



-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    
    return self;
}

-(void)buildUI
{
    CGFloat margin = 17.f;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _iconImageV = [[UIImageView alloc] initWithFrame:CGRectMake(margin, 20, 44, 44)];
    _iconImageV.layer.cornerRadius = 5;
    _iconImageV.layer.masksToBounds = YES;
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconImageV];
    
    _starImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_iconImageV.right + 10, _iconImageV.frame.origin.y - 2, 18, 18)];
    _starImgV.image = [UIImage imageNamed:@"star"];
    [self.contentView addSubview:_starImgV];
    
    _statusLbl = [[UILabel alloc]initWithFrame:CGRectMake( 0, _iconImageV.frame.size.height - 18, _iconImageV.frame.size.width, 18)];
    _statusLbl.text = @"融资中";
    _statusLbl.textAlignment = NSTextAlignmentCenter;
    _statusLbl.textColor = [UIColor whiteColor];
    _statusLbl.font = [UIFont systemFontOfSize:13.f];
    _statusLbl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    _statusLbl.alpha = 0.8;
    [_iconImageV addSubview:_statusLbl];
    
    //产品名字
    UILabel *productLbl = [[UILabel alloc] init];
    productLbl.font = [UIFont systemFontOfSize:16.f];
    productLbl.textColor = HTColorFromRGB(0x1d1d1d);
    productLbl.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:productLbl];
    _productLab = productLbl;
    

    //业务
    UILabel *ywLbl = [[UILabel alloc] init];
    ywLbl.font = [UIFont systemFontOfSize:14.f];
    ywLbl.numberOfLines = 1;
    ywLbl.textColor = HTColorFromRGB(0x555555);
    [self.contentView addSubview:ywLbl];
    _yewuLab = ywLbl;
   
    _lineV = [[UIView alloc]initWithFrame:CGRectMake(0,74, SCREENW, 0.5)];
    _lineV.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:_lineV];
}

-(void)refreshUI:(SearchCompanyModel *)model
{
    CGFloat margin = 14.f;
    CGFloat lblH =18.f;
    
    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"product_default"]];

    
    BOOL isStar = model.renzheng.integerValue == 1 ? YES:NO;
    isStar = NO;
    _starImgV.hidden = !isStar;
    _statusLbl.hidden = model.need_flag.integerValue == 0;
    
    //轮次
//    NSString *jieduan = nil;
//    if (![PublicTool isNull:model.curlunci]) {
//        jieduan = model.curlunci;
//    }else if (![PublicTool isNull:model.lunci]) {
//        jieduan = model.lunci;
//    }else{
//        jieduan = @"";
//    }
//    CGSize lcSize = [self.sizeTool calculateSize:jieduan withFont:_curlunciLab.font withWidth: (SCREENW - margin)];

    
    //产品
    NSString *productName = @"";
    if (![PublicTool isNull:model.product]) {
        productName = model.product;
    }else{
        productName = @"-";
    }
    _productLab.text = productName;
    CGFloat productX = isStar ?_starImgV.right : _iconImageV.right + margin;
    CGFloat productW = SCREENW - productX - margin*2 - 17;
    CGFloat pW = [self.sizeTool calculateSize:productName withFont:_productLab.font withWidth:productW].width;
    [_productLab setFrame:CGRectMake(productX, _iconImageV.frame.origin.y - 2, pW > productW ? productW :pW, lblH)];
    
    
    CGFloat lcX = _productLab.right + 10;

//
//    if([PublicTool isNull:jieduan]){
//
//        _curlunciLab.hidden = YES;
//    }
//    else{
//        _curlunciLab.hidden = NO;
//        _curlunciLab.text = jieduan;
//        [_curlunciLab setFrame:CGRectMake(lcX, _productLab.top, ceil(lcSize.width) + 12, lblH)];
//    }
    
    CGFloat lblX = _iconImageV.frame.origin.x + _iconImageV.frame.size.width + margin;
    CGFloat lblW = SCREENW - lblX - margin;
    
    //业务
    NSString *yewu = (![PublicTool isNull:model.yewu])? model.yewu:@"";
    if ([PublicTool isNull:yewu]&&![PublicTool isNull:model.desc]) {
        yewu = model.desc;
    }
    yewu = ![PublicTool isNull:yewu] ? yewu:@"-";
    _yewuLab.text = yewu;
    _yewuLab.frame = CGRectMake(lblX, _productLab.bottom + 7,  lblW, lblH);
    
//    UIColor *textColor = RGBa(95,95,95,1);
    
//    //行业
//    NSString *hangye = nil;
//    if (![PublicTool isNull:model.hangye1]) {
//        hangye = model.hangye1;
//    }else{
//        hangye = @"-";
//    }
//    //地区
//    NSString *provience = [PublicTool isNull:model.province] ? @"-" : model.province;
//    //成立日期
//    NSString *opentime = nil;
//    if (![PublicTool isNull:model.open_time]) {
//        opentime = model.open_time;
//    }else{
//        opentime = @"-";
//    }
//
//    _infoLbl.text = [NSString stringWithFormat:@"%@ / %@ / %@",hangye,provience,opentime];
//    _infoLbl.textColor = textColor;
//    _infoLbl.frame = CGRectMake(lblX, _yewuLab.bottom+4, lblW, lblH);

}


- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}


@end
