//
//  SearchJigouCell.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/3.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "SearchJigouCell.h"
#import "SearchJigouModel.h"
#import <UIImageView+WebCache.h>
#import "FactoryUI.h"
#import "GetSizeWithText.h" 

@implementation SearchJigouCell

+ (SearchJigouCell *)searchJigouCellWithTableView:(UITableView *)tableView {
    SearchJigouCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchJigouCellID"];
    if (!cell) {
        cell = [[SearchJigouCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchJigouCellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
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
    NSString *zwStr = [NSString stringWithFormat:@""];
    
    //icon
    _iconImageV = [FactoryUI createImageViewWithFrame:CGRectMake(17, 19, 45, 45) imageName:nil];
    _iconImageV.layer.cornerRadius = 5;
    _iconImageV.layer.masksToBounds = YES;
    _iconImageV.layer.borderWidth = 0.5;
    _iconImageV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconImageV];
    
    
    _iconLabel = [[UILabel alloc]initWithFrame:CGRectMake(17, 18, 45, 45)];
    _iconLabel.layer.cornerRadius = 2;
    _iconLabel.layer.masksToBounds = YES;
    [_iconLabel labelWithFontSize:16 textColor:[UIColor whiteColor]];
    _iconLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_iconLabel];

    
    //机构名字
    _jigou_nameLab = [FactoryUI createLabelWithFrame:CGRectMake(_iconImageV.right+15, 20, SCREENW-_iconImageV.right - 17- 55, 18) text:zwStr font:[UIFont systemFontOfSize:15]];
    _jigou_nameLab.textColor = COLOR2D343A;
    [self.contentView addSubview:_jigou_nameLab];
    
    self.zaifuLab = [[InsetsLabel alloc]initWithFrame:CGRectMake(17, 18, 68, 40)];
    self.zaifuLab.textAlignment = NSTextAlignmentCenter;
    [self.zaifuLab labelWithFontSize:10 textColor:BLUE_TITLE_COLOR cornerRadius:2];
    self.zaifuLab.backgroundColor = LABEL_BG_COLOR;
    self.zaifuLab.text = @"投资部门";
    self.zaifuLab.hidden = YES;
    [self.contentView addSubview:self.zaifuLab];
    
    
    [_iconLabel labelWithFontSize:16 textColor:[UIColor whiteColor]];
    _iconLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_iconLabel];
    
    
    //"投资机构"
    _touzijigouLab = [FactoryUI createLabelWithFrame:CGRectMake(_jigou_nameLab.left,_jigou_nameLab.bottom + 7, SCREENW - _jigou_nameLab.left-17, 13) text:@" 投资机构 " font:[UIFont systemFontOfSize:13]];
    _touzijigouLab.textColor = COLOR737782;
    [self.contentView addSubview:_touzijigouLab];

    _lineV = [[UIView alloc]initWithFrame:CGRectMake(17,76.5, SCREENW-34, 0.5)];
    _lineV.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:_lineV];
}

-(void)refreshUI:(SearchJigouModel *)model
{
    _model = model;
    _jieduanLab.text = @"";
    
    if (![PublicTool isNull:model.icon]) {
        [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"product_default"]];//loudou
        
    }
    if (model.jigou_name&&[model.jigou_name isKindOfClass:[NSString class]]&&![PublicTool isNull:model.jigou_name]) {
        _jigou_nameLab.text = model.jigou_name;
    }
    
    //"投资机构"
    NSString *txt = @" 投资机构 ";
    _touzijigouLab.text = txt;
    

    _touzijigouLab.text = model.jianjie;
    
    _jigou_nameLab.frame = CGRectMake(_iconImageV.right+15, 18, SCREENW-_iconImageV.right - 17- 55, 18);
    self.zaifuLab.hidden = YES;
    if ([model.jg_type containsString:@"知名企业"] && ![model.jigou_name containsString:@"基金"] && ![model.jigou_name containsString:@"投资"]) {
        self.zaifuLab.hidden = NO;
        [_jigou_nameLab sizeToFit];
        _jigou_nameLab.frame = CGRectMake(_iconImageV.right+15, 20, MIN(SCREENW-_iconImageV.right - 17- 72-8, _jigou_nameLab.width), 18);
        [self.zaifuLab sizeToFit];
        self.zaifuLab.frame = CGRectMake(_jigou_nameLab.right+6, 0, self.zaifuLab.width, 14);
        self.zaifuLab.centerY = _jigou_nameLab.centerY;
    }

}


-(void)refreshTzJigouUI:(NSDictionary *)dic{
    _modelDic = dic;
    _jieduanLab.text = @"";
    
    if (![PublicTool isNull:dic[@"icon"]]) {
        [_iconImageV sd_setImageWithURL:[NSURL URLWithString:dic[@"icon"]] placeholderImage:[UIImage imageNamed:@"product_default"]];//loudou
    }
    if (dic[@"name"]&&[dic[@"name"] isKindOfClass:[NSString class]]&&![PublicTool isNull:dic[@"name"]]) {
        _jigou_nameLab.text = dic[@"name"];
    }
    NSArray *lunciArr = dic[@"linci"];
    if (lunciArr.count) {
        _touzijigouLab.text = [NSString stringWithFormat:@"所投轮次：%@",[lunciArr componentsJoinedByString:@"、"]];
    }else{
        _touzijigouLab.text = @"--";
    }
}

- (void)setIconColor:(UIColor *)iconColor{
    
    if ([PublicTool isNull:_model.icon] || [_model.icon containsString:@"jigou_default.png"]) {
        _iconLabel.hidden = NO;
        _iconLabel.backgroundColor = iconColor;
        if (_model.jigou_name.length > 1) {
            _iconLabel.text = [_model.jigou_name substringToIndex:1];
        }else{
            _iconLabel.text = @"-";
        }
    }else{
        _iconLabel.hidden = YES;
    }
}


-(void)refreshIconColor:(UIColor *)color{
    if ([PublicTool isNull:_modelDic[@"icon"]] || [_modelDic[@"icon"] containsString:@"jigou_default.png"]) {
        _iconLabel.hidden = NO;
        _iconLabel.backgroundColor = color;
        if ([_modelDic[@"name"] length] > 1) {
            _iconLabel.text = [_modelDic[@"name"] substringToIndex:1];
        }else{
            _iconLabel.text = @"-";
        }
    }else{
        _iconLabel.hidden = YES;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
