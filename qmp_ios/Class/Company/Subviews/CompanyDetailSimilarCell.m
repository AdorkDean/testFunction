//
//  CompanyDetailSimilarCell.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/5.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "CompanyDetailSimilarCell.h"
#import <UIImageView+WebCache.h>
#import "FactoryUI.h"
#import "GetSizeWithText.h"
#import "InsetsLabel.h"

@interface CompanyDetailSimilarCell ()
{
    SearchCompanyModel *_company;
}
@property (nonatomic,strong)UIImageView *iconImageV;
@property (nonatomic,strong)UILabel *iconLabel;

@property (nonatomic,strong)UILabel * productLab;
@property (nonatomic,strong)UILabel * yewuLab;
@property (nonatomic,strong)InsetsLabel * curlunciLab;
@property (strong, nonatomic) UILabel *infoLbl;
@property (strong, nonatomic) UIImageView *firstLineV;
@property (strong, nonatomic) UILabel *positionLbl;
@property (strong, nonatomic) UIImageView *secondLineV;

@property (strong, nonatomic) UILabel *timeLbl;


@property (nonatomic,strong)UIImageView *starImgV;
@property (strong, nonatomic) UILabel *statusLbl;
@property (strong, nonatomic) UIButton *followBtn;
@property (strong, nonatomic) GetSizeWithText *sizeTool;

@end

@implementation CompanyDetailSimilarCell

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
    
    _iconImageV = [[UIImageView alloc] initWithFrame:CGRectMake(margin, 25, 70, 70)];
    _iconImageV.layer.cornerRadius = 5;
    _iconImageV.layer.masksToBounds = YES;
    _iconImageV.layer.borderWidth = 0.5;
    _iconImageV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconImageV];
    
    self.iconLabel = [[UILabel alloc]initWithFrame:CGRectMake(margin, 25, 70, 70)];
    self.iconLabel.layer.cornerRadius = 5;
    self.iconLabel.layer.masksToBounds = YES;
    [self.iconLabel labelWithFontSize:16 textColor:[UIColor whiteColor]];
    self.iconLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.iconLabel];
    

    
    _starImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_iconImageV.right + 10, 25, 20, 20)];
    _starImgV.image = [BundleTool imageNamed:@"star"];
    [self.contentView addSubview:_starImgV];
    
    _statusLbl = [[UILabel alloc]initWithFrame:CGRectMake( 0, _iconImageV.frame.size.height - 20, _iconImageV.frame.size.width, 20)];
    _statusLbl.text = @"融资中";
    _statusLbl.textAlignment = NSTextAlignmentCenter;
    _statusLbl.textColor = [UIColor whiteColor];
    _statusLbl.font = [UIFont systemFontOfSize:13.f];
    _statusLbl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_iconImageV addSubview:_statusLbl];
    
    //产品名字
    UILabel *productLbl = [[UILabel alloc] init];
    productLbl.font = [UIFont systemFontOfSize:16];
    productLbl.textColor = HTColorFromRGB(0x1d1d1d);
    [self.contentView addSubview:productLbl];
    _productLab = productLbl;
    
    //当前轮次
    InsetsLabel *curLcLbl = [[InsetsLabel alloc] init];
    [curLcLbl labelWithFontSize:10 textColor:BLUE_TITLE_COLOR cornerRadius:2];
    curLcLbl.backgroundColor = LABEL_BG_COLOR;

    curLcLbl.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:curLcLbl];
    _curlunciLab = curLcLbl;
    
    //业务
    UILabel *ywLbl = [[UILabel alloc] init];
    ywLbl.font = [UIFont systemFontOfSize:13.f];
    ywLbl.numberOfLines = 1;
    ywLbl.textColor = H9COLOR;
    [self.contentView addSubview:ywLbl];
    _yewuLab = ywLbl;
    
//    //行业/地区/时间
//    UILabel *infoLbl = [[UILabel alloc] init];
//    infoLbl.font = [UIFont systemFontOfSize:14.f];
//    infoLbl.textColor = HTColorFromRGB(0x555555);;
//    [self.contentView addSubview:infoLbl];
//    _infoLbl = infoLbl;
//
//
//    _positionLbl = [[UILabel alloc] init];
//    _positionLbl.font = [UIFont systemFontOfSize:14.f];
//    _positionLbl.textColor = HTColorFromRGB(0x555555);;
//    [self.contentView addSubview:_positionLbl];
//    _timeLbl = [[UILabel alloc] init];
//    _timeLbl.font = [UIFont systemFontOfSize:14.f];
//    _timeLbl.textColor = HTColorFromRGB(0x555555);;
//    [self.contentView addSubview:_timeLbl];
//
//    _firstLineV = [[UIImageView alloc]initWithImage:[BundleTool imageNamed:@"line_xie"]];
//    [self.contentView addSubview:_firstLineV];
//
//    _secondLineV = [[UIImageView alloc]initWithImage:[BundleTool imageNamed:@"line_xie"]];
//    [self.contentView addSubview:_secondLineV];
    
    //    self.timeLabel = [[UILabel alloc]init];
    //    [self.timeLabel labelWithFontSize:12 textColor:H9COLOR];
    //    self.timeLabel.textAlignment = NSTextAlignmentRight;
    //    [self.contentView addSubview:self.timeLabel];
    
    
    self.bottomLine = [[UIView alloc]initWithFrame:CGRectMake(17, 119, SCREENW - 34, 0.5)];
    self.bottomLine.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:self.bottomLine];
    
    [self makeConsraints];
    
}

- (void)makeConsraints{
    
    [_iconImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.top.equalTo(self.contentView).offset(18);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    
    [_iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.top.equalTo(self.contentView).offset(18);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    
    [_statusLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_left);
        make.bottom.equalTo(_iconImageV.mas_bottom);
        make.right.equalTo(_iconImageV.mas_right);
        make.height.equalTo(@(20));
    }];
    
    [_starImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_right).offset(10);
        make.top.equalTo(self.contentView).offset(18);
        make.width.equalTo(@(16));
        make.height.equalTo(@(16));
    }];
    
    [_productLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_right).offset(14);
        make.top.equalTo(self.contentView).offset(18);
        make.height.equalTo(@(16));
    }];
    
    
    
    [_curlunciLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_productLab.mas_right).offset(6).priorityHigh();
        make.centerY.equalTo(_productLab.mas_centerY);
        make.height.equalTo(@(16));
        make.right.lessThanOrEqualTo(self.contentView).offset(-17).priorityLow();
    }];
  
    [_yewuLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_right).offset(14);
        make.top.equalTo(_productLab.mas_bottom).offset(9);
        make.height.equalTo(@(14));
        make.right.equalTo(self.contentView).offset(-17);
    }];

    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.right.equalTo(self.contentView).offset(-17);
        make.bottom.equalTo(self.contentView);
        make.height.equalTo(@(1));
    }];
    
    [_productLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_productLab setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
    
    [_curlunciLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_curlunciLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}


- (void)refreshUI:(SearchCompanyModel *)model{
    _company = model;
    CGFloat margin = 10.f;
    
    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[BundleTool imageNamed:@"product_default"]];
//    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[BundleTool imageNamed:@"product_default"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        _iconImageV.image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(80, 80)];
//    }];
    BOOL isStar = NO;
    _starImgV.hidden = !isStar;
    _statusLbl.hidden = model.need_flag.integerValue == 0;
    
    //产品
    NSString *productName = @"";
    if (model.product&&![model.product isEqualToString:@""]) {
        productName = model.product;
    }else{
        productName = @"";
    }
    productName = [productName isEqualToString:@""]? @"-" :productName;
    _productLab.text = productName;
    
    //轮次
    NSString *jieduan = nil;
    if (model.lunci&&![model.lunci isEqualToString:@""]) {
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
            }
    
    _curlunciLab.centerY = _productLab.centerY;

    //业务
    NSString *yewu = (model.yewu && ![model.yewu isEqualToString:@""])? model.yewu:@"";
    yewu = yewu&&![yewu isEqualToString:@""] ? yewu:@"-";
    _yewuLab.text = yewu;

}

- (void)setIconColor:(UIColor *)iconColor{
    if ([PublicTool isNull:_company.icon] || [_company.icon containsString:@"product_default.png"]) {
        self.iconLabel.hidden = NO;
        self.iconLabel.backgroundColor = iconColor;
        if (_productLab.text.length > 1) {
            self.iconLabel.text = [_productLab.text substringToIndex:1];
        }else{
            self.iconLabel.text = @"-";
        }
    }else{
        self.iconLabel.hidden = YES;
    }
}

- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}

@end
