//
//  EducationCell.m
//  qmp_ios
//
//  Created by QMP on 2017/11/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "EducationCell.h"

@interface EducationCell()
{
    UIImageView *_iconImg;
    UILabel *_categoryLabel;
    UILabel *_schoolLabel;
    UILabel *_degreeLabel;
    UILabel *_majorLab;
    UILabel *_timeLab;
    UIImageView *_lineVertical;
    UIImageView *_lineVertical2;

    UIView *_line;

}
@end


@implementation EducationCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    
    return self;
}

- (void)buildUI{
    CGFloat imgW = 55;
    
    _iconImg = [[UIImageView alloc]initWithFrame:CGRectZero];
    _iconImg.layer.cornerRadius = 4;
    _iconImg.layer.masksToBounds = YES;
    _iconImg.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImg.layer.borderWidth = 0.5;
    [self.contentView addSubview:_iconImg];

    _categoryLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [_categoryLabel labelWithFontSize:18 textColor:[UIColor whiteColor]];
    _categoryLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_categoryLabel];
    _categoryLabel.layer.cornerRadius = 4;
    _categoryLabel.layer.masksToBounds = YES;
    
    
    CGFloat nameX = _categoryLabel.right + 15.f;
    
    _schoolLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _schoolLabel.textColor = NV_TITLE_COLOR;
    _schoolLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_schoolLabel];
    
    _timeLab = [[UILabel alloc]initWithFrame:CGRectZero];
    _timeLab.textColor = H9COLOR;
    _timeLab.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_timeLab];
    
    _majorLab = [[UILabel alloc]initWithFrame:CGRectZero];
    _majorLab.textColor = H9COLOR;
    _majorLab.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_majorLab];
    
    _lineVertical = [[UIImageView alloc]initWithFrame:CGRectZero];
    _lineVertical.image = [UIImage imageNamed:@"line_shu"];
    [self.contentView addSubview:_lineVertical];
    
    _lineVertical2 = [[UIImageView alloc]initWithFrame:CGRectZero];
    _lineVertical2.image = [UIImage imageNamed:@"line_shu"];
    [self.contentView addSubview:_lineVertical2];
    
    _degreeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _degreeLabel.textColor = H9COLOR;
    _degreeLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_degreeLabel];
    
    
    self.editBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    [self.editBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [self.editBtn setImage:[UIImage imageNamed:@"cell_arrow"] forState:UIControlStateNormal];
    [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    self.editBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.editBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:5];
    [self.contentView addSubview:self.editBtn];
    
    _line = [[UIView alloc]initWithFrame:CGRectZero];
    _line.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:_line];
    
    
    [self maksContraints];
    
}

- (void)maksContraints{
    
    [_categoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.top.equalTo(self.contentView).offset(21);
        make.width.equalTo(@(55));
        make.height.equalTo(@(55));
    }];
    
    [_iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.top.equalTo(self.contentView).offset(21);
        make.width.equalTo(@(55));
        make.height.equalTo(@(55));    }];
    
    [_schoolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_categoryLabel.mas_right).offset(15);
        make.top.equalTo(self.contentView).offset(24);
        make.height.equalTo(@(18));
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_schoolLabel.mas_leading);
        make.top.equalTo(_schoolLabel.mas_bottom).offset(13);
        make.height.equalTo(@(15));
    }];
   
    [_lineVertical mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_timeLab.mas_right);
        make.height.equalTo(@(20));
        make.width.equalTo(@(10));
        make.centerY.equalTo(_timeLab.mas_centerY);
    }];
    
    [_majorLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_lineVertical.mas_right);
//        make.right.equalTo(self.contentView).offset(-17);
        make.height.equalTo(@(15));
        make.centerY.equalTo(_timeLab.mas_centerY);

    }];
    
    [_lineVertical2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_majorLab.mas_right);
        make.height.equalTo(@(20));
        make.width.equalTo(@(10));
        make.centerY.equalTo(_timeLab.mas_centerY);
    }];
    
    
    [_degreeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_lineVertical2.mas_right);
//        make.right.equalTo(self.contentView).offset(-17);
        make.height.equalTo(@(15));
        make.centerY.equalTo(_timeLab.mas_centerY);
        
    }];
    
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@(55));
        make.height.equalTo(@(90));
    }];
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView);
        make.left.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.height.equalTo(@(0.5));
    }];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.editBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:5];
}

- (void)setEducationM:(EducationExpModel *)educationM{
    
    _educationM = educationM;
    _schoolLabel.text = educationM.school;
    _categoryLabel.hidden = NO;
    if (_schoolLabel.text.length) {
        _categoryLabel.text = [educationM.school substringWithRange:NSMakeRange(0, 1)];
    }else{
        _categoryLabel.text = @"";
    }
    
    //设置专业 major
    _majorLab.text = educationM.major;
    
    _degreeLabel.text = educationM.xueli;
    
 
    
    if (![PublicTool isNull:educationM.start_time] || ![PublicTool isNull:educationM.end_time] ) {
        
        _lineVertical.hidden = NO;
        _timeLab.text = [NSString stringWithFormat:@"%@-%@",[PublicTool nilStringReturn:educationM.start_time],[PublicTool nilStringReturn:educationM.end_time]];
        [_lineVertical mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_timeLab.mas_right);
            make.height.equalTo(@(20));
            make.width.equalTo(@(10));
            make.centerY.equalTo(_timeLab.mas_centerY);
        }];
        
    }else{
        
        _timeLab.text = @"";
        _lineVertical.hidden = YES;
        [_lineVertical mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_timeLab.mas_right).offset(-10);
            make.height.equalTo(@(20));
            make.width.equalTo(@(10));
            make.centerY.equalTo(_timeLab.mas_centerY);
        }];
    }
    
    if (![PublicTool isNull:educationM.major]) {
        
        _lineVertical2.hidden = NO;
        _majorLab.text = educationM.major;
        [_lineVertical2 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_majorLab.mas_right);
            make.height.equalTo(@(20));
            make.width.equalTo(@(10));
            make.centerY.equalTo(_timeLab.mas_centerY);
        }];
        
    }else{
        
        _majorLab.text = @"";
        _lineVertical2.hidden = YES;
        [_lineVertical2 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_majorLab.mas_right).offset(-10);
            make.height.equalTo(@(20));
            make.width.equalTo(@(10));
            make.centerY.equalTo(_timeLab.mas_centerY);
        }];
    }

    [self setNeedsUpdateConstraints];
    
    self.editBtn.hidden = YES;
}

- (void)setDegreeColor:(UIColor *)degreeColor{
    _categoryLabel.backgroundColor = degreeColor;
    _iconImg.hidden = YES;
}


//工作
- (void)setExprienceM:(ZhiWeiModel *)exprienceM{
    _exprienceM = exprienceM;
    _iconImg.hidden = NO;
    [_iconImg sd_setImageWithURL:[NSURL URLWithString:exprienceM.icon] placeholderImage:[UIImage imageNamed:PROICON_DEFAULT]];
    _schoolLabel.text = [PublicTool nilStringReturn:exprienceM.name];
    _timeLab.text = exprienceM.zhiwu;
    _lineVertical.hidden = YES;
    _lineVertical2.hidden = YES;
    self.editBtn.hidden = YES;
}


- (void)setIconColor:(UIColor *)iconColor{
    
    if ([PublicTool isNull:_exprienceM.icon] || [_exprienceM.icon containsString:@"product_default.png"]) {
        _categoryLabel.hidden = NO;
        _categoryLabel.backgroundColor = iconColor;
        if (![PublicTool isNull:_exprienceM.name] && _exprienceM.name.length > 0) {
            _categoryLabel.text = [_exprienceM.name substringWithRange:NSMakeRange(0, 1)];
        }else{
            _categoryLabel.text = @"-";
        }
        
    }else{
        _categoryLabel.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
