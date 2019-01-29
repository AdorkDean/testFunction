//
//  CompanysDetailRegisterTouziCell.m
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/12.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CompanysDetailRegisterTouziCell.h"
#import "CompanysDetailRegisterTouziModel.h"
#import "CopyButton.h"
#import "FactoryUI.h"
#import <UIImageView+WebCache.h>
@interface CompanysDetailRegisterTouziCell()

@property (strong, nonatomic) NSDictionary *urlDict;

@end

@implementation CompanysDetailRegisterTouziCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    CompanysDetailRegisterTouziCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompanysDetailRegisterTouziCellID"];
    if (!cell) {
        cell = [[CompanysDetailRegisterTouziCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CompanysDetailRegisterTouziCellID"];
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
    
    _iconImg = [FactoryUI createImageViewWithFrame:CGRectMake(17, 0, 40, 40) imageName:@""];
    _iconImg.layer.cornerRadius = 5;
    _iconImg.layer.masksToBounds = YES;
    //给图层添加一个有色边框
    _iconImg.layer.borderWidth = 0.5;
    _iconImg.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconImg];
    _iconImg.userInteractionEnabled = YES;

    _imgBtn = [FactoryUI createButtonWithFrame:_iconImg.bounds title:@"" titleColor:[UIColor clearColor] imageName:@"" backgroundImageName:@"" target:nil selector:nil];
    [_iconImg addSubview:_imgBtn];
    _imgBtn.hidden = YES;
    
    _nameBtn = [[CopyButton alloc]initWithFrame:CGRectMake(_iconImg.right+15, 0, SCREENW-20,60)];
    //设置标题颜色
    [_nameBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
    [_nameBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];

    
    _nameBtn.titleLabel .font = [UIFont systemFontOfSize:15];
    _nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.contentView addSubview:_nameBtn];
    _nameBtn.centerY = _iconImg.centerY;
    [_nameBtn setFrame:CGRectMake(_iconImg.right+15, 0, SCREENW-_iconImg.right - 32, 45)];
    _nameBtn.userInteractionEnabled = NO;

}

-(void)refreshUI:(CompanysDetailRegisterTouziModel *)model{
    
    _imgBtn.hidden = YES;
    
    //
    NSString *icon = model.icon;
    NSString *detail;
    if (![PublicTool isNull:model.product]) { //说明是项目库的项目
        icon = model.icon;
        detail = model.detail;
    }else if (![PublicTool isNull:model.agency_name]) { //说明是机构库的机构
        icon = model.agency_icon;
        detail = model.agency_detail;
    }
    
    if (![PublicTool isNull:icon]) {
        
        [_iconImg sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"logo_default"]];
  
    }else{
        [_iconImg setImage:[UIImage imageNamed:@"logo_default"]];
    }
//    
//    if (![PublicTool isNull:detail]){
//        _imgBtn.hidden = NO;
//    }else{
//        _imgBtn.hidden = YES;
//    }
    
    NSString *nameStr = model.tz_name&&![model.tz_name isEqualToString:@""]?model.tz_name:@"";
    [_nameBtn setTitle:nameStr forState:UIControlStateNormal];
    _nameBtn.centerY = _iconImg.centerY;

}

- (NSDictionary *)urlDict{

    if (!_urlDict) {
        _urlDict = @{JGICON_DEFAULTURL:JGICON_DEFAULT,PROICON_DEFAULTURL:PROICON_DEFAULT,COMICON_DEFAULTURL:COMICON_DEFAULT};
    }
    return _urlDict;
}
@end
