//
//  IPOCompanyCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "IPOCompanyCell.h"
#import "InsetsLabel.h"

@interface IPOCompanyCell()

@property (nonatomic,strong)UIImageView *iconImageV;
@property (nonatomic,strong)UILabel *iconNameLab;

@property (nonatomic,strong)UILabel * yewuLab;
@property (nonatomic,strong)InsetsLabel * curlunciLab;
@property (strong, nonatomic) UILabel *infoLbl;
@property (strong, nonatomic) UIImageView *firstLineV;
@property (strong, nonatomic) UILabel *positionLbl;
@property (strong, nonatomic) UIImageView *secondLineV;


@property (strong, nonatomic) UILabel *statusLbl;
@property (strong, nonatomic) UIButton *followBtn;
@property (strong, nonatomic) GetSizeWithText *sizeTool;

@property (strong, nonatomic) SearchCompanyModel *companyModel;

@end


@implementation IPOCompanyCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    
    return self;
}

-(void)buildUI
{
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _iconImageV = [[UIImageView alloc] init];
    _iconImageV.layer.cornerRadius = 5;
    _iconImageV.layer.masksToBounds = YES;
    _iconImageV.layer.borderWidth = 0.5;
    _iconImageV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconImageV];
    
    self.iconNameLab = [[UILabel alloc]init];
    [self.iconNameLab labelWithFontSize:16 textColor:[UIColor whiteColor]];
    _iconNameLab.layer.cornerRadius = 5;
    _iconNameLab.layer.masksToBounds = YES;
    _iconNameLab.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.iconNameLab];
    
//    _starImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_iconImageV.right + 10, 25, 20, 20)];
//    _starImgV.image = [UIImage imageNamed:@"star"];
//    [self.contentView addSubview:_starImgV];
    
    _statusLbl = [[UILabel alloc]initWithFrame:CGRectMake( 0, _iconImageV.frame.size.height - 20, _iconImageV.frame.size.width, 20)];
    _statusLbl.text = @"融资中";
    _statusLbl.textAlignment = NSTextAlignmentCenter;
    _statusLbl.textColor = [UIColor whiteColor];
    _statusLbl.font = [UIFont systemFontOfSize:11.f];
    _statusLbl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_iconImageV addSubview:_statusLbl];
    
    //产品名字
    UILabel *productLbl = [[UILabel alloc] init];
    productLbl.font = [UIFont systemFontOfSize:15 ];
    productLbl.textColor = COLOR2D343A;
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
    ywLbl.textColor = COLOR737782;
    [self.contentView addSubview:ywLbl];
    _yewuLab = ywLbl;

    
    self.bottomLine = [[UIView alloc]initWithFrame:CGRectMake(17, 119, SCREENW - 34, 0.5)];
    self.bottomLine.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:self.bottomLine];
    [self makeConsraints];
    
}

- (void)makeConsraints{
    
    [_iconImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.top.equalTo(self.contentView).offset(15);
        make.width.equalTo(@(45));
        make.height.equalTo(@(45));
    }];
    
    [_iconNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_left);
        make.top.equalTo(_iconImageV.mas_top);
        make.width.equalTo(@(45));
        make.height.equalTo(@(45));
        
    }];
    
    [_statusLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_left);
        make.bottom.equalTo(_iconImageV.mas_bottom);
        make.right.equalTo(_iconImageV.mas_right);
        make.height.equalTo(@(16));
    }];

    
    [_productLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_right).offset(15);
        make.top.equalTo(self.contentView).offset(18);
//        make.height.equalTo(@(16));
        make.height.equalTo(@(18));
    }];
    
    [_curlunciLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_productLab.mas_right).offset(6).priorityHigh();
        make.centerY.equalTo(_productLab.mas_centerY);
        make.height.equalTo(@(14));
        make.right.lessThanOrEqualTo(self.contentView).offset(-17).priorityLow();
    }];
    
    
    [_yewuLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_right).offset(15);
        make.top.equalTo(_productLab.mas_bottom).offset(6);
        make.height.equalTo(@(14));
        make.right.equalTo(self.contentView).offset(-17);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.right.equalTo(self.contentView).offset(-17);
        make.bottom.equalTo(self.contentView);
        make.height.equalTo(@(0.5));
    }];
    
    [_productLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_productLab setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
    
    [_curlunciLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_curlunciLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}


- (void)refreshUI:(SearchCompanyModel *)model{
    
    _companyModel = model;
    
    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"product_default"]];

    _statusLbl.hidden = model.need_flag.integerValue == 0;
    
    //产品
    NSString *productName = @"";
    if (![PublicTool isNull:model.product]) {
        productName = model.product;
    }else{
        productName = @"-";
    }
    _productLab.text = productName;
    
    //轮次
    NSString *jieduan = nil;
    if (![PublicTool isNull:model.lunci]) {
        jieduan = model.lunci;
    }else if(![PublicTool isNull:model.curlunci]){
        
        jieduan = model.lunci;
    }else{
        jieduan = @"";
    }
    
    if([PublicTool isNull:jieduan]){
        
        _curlunciLab.hidden = YES;
        
    }else{
        _curlunciLab.hidden = NO;
        _curlunciLab.text = jieduan;
    }
    
    //业务
    NSString *yewu = (![PublicTool isNull:model.yewu])? model.yewu:@"";
    if ([PublicTool isNull:yewu]&&![PublicTool isNull:model.desc]) {
        yewu = model.desc;
    }
    yewu = ![PublicTool isNull:model.yewu] ? yewu:@"-";
    _yewuLab.text = yewu;
    
    
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
    
    _infoLbl.text = hangye;
    _positionLbl.text = provience;
}


- (void)setIconBgColor:(UIColor *)iconBgColor{
    
    if ([PublicTool isNull:self.companyModel.icon] || [self.companyModel.icon isEqualToString:@"http://ios1.api.qimingpian.com/Public/images/product_default.png"]) {
        self.iconNameLab.hidden = NO;
        self.iconNameLab.backgroundColor = iconBgColor;
        if (_productLab.text.length > 1) {
            self.iconNameLab.text = [_productLab.text substringToIndex:1];
        }else{
            self.iconNameLab.text = @"-";
        }
    }else{
        self.iconNameLab.hidden = YES;
    }
}
@end
