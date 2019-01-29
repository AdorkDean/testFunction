//
//  CompanysDetailRegisterGudongCell.m
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/12.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CompanysDetailRegisterGudongCell.h"
#import "CompanysDetailRegisterGudongModel.h"
#import "copyLabel.h"
#import "FactoryUI.h"
#import "GetSizeWithText.h"
#import <UIImageView+WebCache.h>
@interface CompanysDetailRegisterGudongCell()

@property (strong, nonatomic) NSDictionary *urlDict;

@end
@implementation CompanysDetailRegisterGudongCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    CompanysDetailRegisterGudongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompanysDetailRegisterGudongCellID"];
    if (!cell) {
        cell = [[CompanysDetailRegisterGudongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CompanysDetailRegisterGudongCellID"];
    }
    return cell;
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildUI];
    }
    
    return self;
}

- (void)buildUI{
    
    CGFloat searchW = 70.f;
    
    self.percentLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREENW-searchW, 0, searchW-17, 20)];
    [self.percentLab labelWithFontSize:15 textColor:H9COLOR];
    self.percentLab.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.percentLab];
    

    _iconImg = [FactoryUI createImageViewWithFrame:CGRectMake(17, 0, 40, 40) imageName:@""];
    _iconImg.layer.cornerRadius = 5;
    _iconImg.layer.masksToBounds = YES;
    _iconImg.layer.borderWidth = 0.5;
    _iconImg.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImg.userInteractionEnabled = YES;
    [self.contentView addSubview:_iconImg];
    
    _imgBtn = [FactoryUI createButtonWithFrame:_iconImg.bounds title:@"" titleColor:[UIColor clearColor] imageName:@"" backgroundImageName:@"" target:nil selector:nil];
    [_iconImg addSubview:_imgBtn];
    
    _nameLbl = [[CopyLabel alloc]initWithFrame:CGRectMake(_iconImg.right+15, 0, SCREENW-(_iconImg.right+15+17)-searchW, 60)];
    [self.contentView addSubview:_nameLbl];
    _nameLbl.textColor = COLOR2D343A;
    _nameLbl.textAlignment = NSTextAlignmentLeft;
    _nameLbl.numberOfLines = 2;
    _nameLbl.lineBreakMode = NSLineBreakByWordWrapping;
    _nameLbl.userInteractionEnabled = YES;
    UIFont *font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    _nameLbl.font = font;

}

-(void)refreshUI:(CompanysDetailRegisterGudongModel *)model{

    NSString *icon;
    NSArray *personArr = @[@"自然人股东",@"自然人"];
    if ([personArr containsObject:model.gd_type]) {
        icon = model.person_icon;
    }else{
        if (![PublicTool isNull:model.product]) {
            icon = model.icon;
        }else if (![PublicTool isNull:model.agency_name]) {
            icon = model.agency_icon;
        }
    }
    [_iconImg sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[personArr containsObject:model.gd_type]?[UIImage imageNamed:@"heading"]:[UIImage imageNamed:@"logo_default"]];

    _imgBtn.hidden = YES;
//    if (![PublicTool isNull:model.agency_name] && ![PublicTool isNull:model.agency_detail]) {
//        _imgBtn.hidden = NO;
//
//    }else if (![PublicTool isNull:model.product] && ![PublicTool isNull:model.detail]) {
//        _imgBtn.hidden = NO;
//    }else if (![PublicTool isNull:model.detail]) { //工商
//        _imgBtn.hidden = YES;
//    }
    
    _nameLbl.text = model.gd_name;
  
    _nameLbl.centerY = _iconImg.centerY;
    self.percentLab.centerY = _iconImg.centerY;
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:model.percent];
    if (![PublicTool isNull:model.percent] && [model.percent containsString:@"%"]) {
        [attText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]} range:NSMakeRange(attText.length-1, 1)];

    }
    self.percentLab.attributedText = attText;
    
}

- (NSDictionary *)urlDict{
    
    if (!_urlDict) {
        _urlDict = @{JGICON_DEFAULTURL:JGICON_DEFAULT,PROICON_DEFAULTURL:PROICON_DEFAULT,COMICON_DEFAULTURL:COMICON_DEFAULT};
    }
    return _urlDict;
}

@end
