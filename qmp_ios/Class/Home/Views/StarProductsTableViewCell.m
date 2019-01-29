//
//  StarProductsTableViewCell.m
//  qmp_ios
//
//  Created by qimingpian08 on 16/10/17.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "StarProductsTableViewCell.h"

#import <UIImageView+WebCache.h>
#import "StarProductsModel.h"
#import "GetSizeWithText.h"
#import "InsetsLabel.h"
@interface StarProductsTableViewCell ()

@property (strong, nonatomic) UIView *bgView;

@property (nonatomic,strong)UIImageView *iconImageV;
@property (nonatomic,strong)UILabel * productLab;
@property (nonatomic,strong)UILabel * yewuLab;
@property (nonatomic,strong)InsetsLabel * curlunciLab;

//@property (strong, nonatomic) UILabel *infoLbl;
//@property (strong, nonatomic) UIImageView *firstLineV;
//@property (strong, nonatomic) UILabel *positionLbl;
//@property (strong, nonatomic) UIImageView *secondLineV;
//
//@property (strong, nonatomic) UILabel *timeLbl;

@property (nonatomic,strong)UIImageView *starImgV;
@property (strong, nonatomic) UIButton *followBtn;
@property (strong, nonatomic) GetSizeWithText *sizeTool;

@end

@implementation StarProductsTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    
    return self;
}

-(void)buildUI
{
    
    self.bgView = [[UIView alloc]initWithFrame:self.contentView.bounds];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.bgView];
    
    CGFloat margin = 17.f;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _iconImageV = [[UIImageView alloc] initWithFrame:CGRectMake(margin, 25, 70, 70)];
    _iconImageV.layer.cornerRadius = 5;
    _iconImageV.layer.masksToBounds = YES;
    _iconImageV.layer.borderWidth = 0.5;
    _iconImageV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.bgView addSubview:_iconImageV];
    
    _starImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_iconImageV.right + 10, 25, 20, 20)];
    _starImgV.image = [BundleTool imageNamed:@"star"];
    [self.bgView addSubview:_starImgV];
    
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
    productLbl.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:productLbl];
    _productLab = productLbl;
    
    
    //当前轮次
    InsetsLabel *curLcLbl = [[InsetsLabel alloc] init];
    [curLcLbl labelWithFontSize:10 textColor:BLUE_TITLE_COLOR cornerRadius:2];
    curLcLbl.backgroundColor = LABEL_BG_COLOR;
    [self.bgView addSubview:curLcLbl];
    _curlunciLab = curLcLbl;

    
    //业务
    UILabel *ywLbl = [[UILabel alloc] init];
    ywLbl.font = [UIFont systemFontOfSize:13.f];
    ywLbl.numberOfLines = 1;
    ywLbl.textColor = HTColorFromRGB(0x555555);
    [self.bgView addSubview:ywLbl];
    _yewuLab = ywLbl;
    
//    //行业/地区/时间
//    UILabel *infoLbl = [[UILabel alloc] init];
//    infoLbl.font = [UIFont systemFontOfSize:13.f];
//    infoLbl.textColor = H9COLOR;
//    [self.bgView addSubview:infoLbl];
//    _infoLbl = infoLbl;
//
//
//    _positionLbl = [[UILabel alloc] init];
//    _positionLbl.font = [UIFont systemFontOfSize:13.f];
//    _positionLbl.textColor = H9COLOR;
//    [self.bgView addSubview:_positionLbl];
//    _timeLbl = [[UILabel alloc] init];
//    _timeLbl.font = [UIFont systemFontOfSize:13.f];
//    _timeLbl.textColor = H9COLOR;
//    [self.bgView addSubview:_timeLbl];
//
//    _firstLineV = [[UIImageView alloc]initWithImage:[BundleTool imageNamed:@"line_xie"]];
//    [self.bgView addSubview:_firstLineV];
//
//    _secondLineV = [[UIImageView alloc]initWithImage:[BundleTool imageNamed:@"line_xie"]];
//    [self.bgView addSubview:_secondLineV];
//
////    self.timeLabel = [[UILabel alloc]init];
////    [self.timeLabel labelWithFontSize:12 textColor:H9COLOR];
////    self.timeLabel.textAlignment = NSTextAlignmentRight;
////    [self.bgView addSubview:self.timeLabel];
    
    _contactBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 60 - 17, _productLab.top, 60, 44)];
    [_contactBtn setTitle:@"委托联系" forState:UIControlStateNormal];
    [_contactBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    _contactBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _contactBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    [self.bgView addSubview:_contactBtn];
    
    _contactBtn.centerY = _productLab.centerY;
    self.bottomLine = [[UIView alloc]initWithFrame:CGRectMake(17, 119, SCREENW - 34, 1)];
    self.bottomLine.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:self.bottomLine];
    
    self.chooseBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, self.contentView.height)];
    [self.chooseBtn setImage:[BundleTool imageNamed:@"noselect_workFlow"] forState:UIControlStateNormal];
    [self.chooseBtn setImage:[BundleTool imageNamed:@"select_workFlow"] forState:UIControlStateSelected];
    [self.contentView addSubview:self.chooseBtn];
    self.chooseBtn.userInteractionEnabled = NO;
    [self.chooseBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.chooseBtn.hidden = YES;
    [self makeConsraints];
    
}

- (void)makeConsraints{
    
    [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.top.equalTo(self.contentView).offset(10);
        make.width.equalTo(@(60));
        make.height.equalTo(@(60));
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_iconImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(18);
        make.top.equalTo(self.contentView).offset(20);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    
    [_statusLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_left);
        make.bottom.equalTo(_iconImageV.mas_bottom);
        make.right.equalTo(_iconImageV.mas_right);
        make.height.equalTo(@(18));
    }];
    
    [_starImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_right).offset(10);
        make.top.equalTo(self.bgView).offset(20);
        make.width.equalTo(@(16));
        make.height.equalTo(@(16));
    }];
    
    [_productLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_right).offset(10);
        make.top.equalTo(self.bgView).offset(20);
        make.height.equalTo(@(16));
    }];
    
   

    [_curlunciLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_productLab.mas_right).offset(10).priorityHigh();
        make.centerY.equalTo(_productLab.mas_centerY);
        make.height.equalTo(@(18));
        make.right.lessThanOrEqualTo(self.bgView).offset(-17).priorityLow();
    }];

    
    [_yewuLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_right).offset(10);
        make.top.equalTo(_productLab.mas_bottom).offset(9);
        make.height.equalTo(@(14));
        make.right.equalTo(self.bgView).offset(-17);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(17);
        make.right.equalTo(self.bgView).offset(-17);
        make.bottom.equalTo(self.bgView);
        make.height.equalTo(@(0.5));
    }];

    [_productLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_productLab setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];

    [_curlunciLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_curlunciLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}


-(void)refreshUI:(StarProductsModel *)model{

    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[BundleTool imageNamed:@"product_default"]];
    
//    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        _iconImageV.image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(80, 80)];
//    }];
    
    BOOL isStar = NO;
    _starImgV.hidden = !isStar;
    _statusLbl.hidden = model.need_flag.integerValue == 0;
//
//    if (model.create_time && model.create_time.length) {
//        self.timeLabel.text = model.create_time;
//    }
    
    //产品
    NSString *productName = @"";
    if (![PublicTool isNull:model.name]) {
        productName = model.name;
    }else{
        if (![PublicTool isNull:model.product]) {
            productName = model.product;
        }else{
            productName = @"-";
        }
        
    }

    //轮次
    NSString *jieduan = nil;
    if (![PublicTool isNull:model.jieduan]) {
        jieduan = model.jieduan;
    }else{
        if (![PublicTool isNull:model.lunci]) {
            jieduan = model.lunci;
        }else{
            jieduan = @"";
        }
    }
    
    _productLab.text = productName;
  
     if([PublicTool isNull:jieduan]){
         _curlunciLab.text = @"";

//         _curlunciLab.backgroundColor = [UIColor whiteColor];
        _curlunciLab.hidden = YES;
    }
    else{
        _curlunciLab.hidden = NO;
//        _curlunciLab.backgroundColor = RGBBlueColor;
        _curlunciLab.text = jieduan;
    }
    
    //业务
    NSString *yewu = (![PublicTool isNull:model.yewu])? model.yewu:@"";
    if ([PublicTool isNull:yewu]&&![PublicTool isNull:model.desc]) {
        yewu = model.desc;
    }
    yewu = ![PublicTool isNull:yewu] ? yewu:@"-";
    _yewuLab.text = yewu;
    
    
//    //行业
//    NSString *hangye = nil;
//    if (model.hangye&&![model.hangye isEqualToString:@""]) {
//        hangye = model.hangye;
//    }else{
//        if (model.hangye1&&![model.hangye1 isEqualToString:@""]) {
//            hangye = model.hangye1;
//        }else{
//            hangye = @"";
//        }
//    }
//    hangye = [hangye isEqualToString:@""] ? @"-": hangye;
//    //地区
//    NSString *provience = [model.province isEqualToString:@""] ? @"-" : model.province;
//    
//    //成立日期
//    NSString *opentime = nil;
//    if (model.opentime&&![model.opentime isEqualToString:@""]) {
//        opentime = model.opentime;
//    }else{
//        if (model.open_time&&![model.open_time isEqualToString:@""]) {
//            opentime = model.open_time;
//        }else{
//            opentime = @"";
//        }
//    }
//    opentime = [opentime stringByReplacingOccurrencesOfString:@"-" withString:@"."];
//
//    opentime = opentime&&![opentime isEqualToString:@""] ? opentime : @"-";
//    
//
////    _infoLbl.attributedText = attText;
//    _infoLbl.text = hangye;
//    _positionLbl.text = provience;
//    _timeLbl.text = opentime;
    
    
    if (self.isEditting) {
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(36);
            make.top.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
        }];
        self.chooseBtn.hidden = NO;
        self.chooseBtn.selected = model.selected.integerValue;
        

    }else{
        
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.top.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
        }];
        self.chooseBtn.hidden = YES;
        
    }
    
    [self setNeedsUpdateConstraints];

}

- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}

@end
