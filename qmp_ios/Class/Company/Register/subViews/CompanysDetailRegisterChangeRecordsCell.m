//
//  CompanysDetailRegisterChangeRecordsCell.m
//  qmp_ios
//
//  Created by qimingpian10 on 2017/2/20.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "CompanysDetailRegisterChangeRecordsCell.h"
#import "CompanysDetailRegisterChangeRecordsModel.h"
#import "FactoryUI.h"
#import "GetSizeWithText.h"
#import "VerticalToplabel.h"

@implementation CompanysDetailRegisterChangeRecordsCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    CompanysDetailRegisterChangeRecordsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompanysDetailRegisterChangeRecordsCellID"];
    if (!cell) {
        cell = [[CompanysDetailRegisterChangeRecordsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CompanysDetailRegisterChangeRecordsCellID"];
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
    
    _timeLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 20, 180, 14)];
    _timeLab.font = [UIFont systemFontOfSize:15];
    _timeLab.textColor = H9COLOR;
    [self.contentView addSubview:_timeLab];
    
    _nameLab = [[CopyLabel alloc]initWithFrame:CGRectMake(_timeLab.left, _timeLab.bottom + 10, SCREENW-_timeLab.left- 17, 15)];
    _nameLab.textColor = COLOR2D343A;
    _nameLab.font = [UIFont systemFontOfSize:15];
    _nameLab.numberOfLines = -1;
    [self.contentView addSubview:_nameLab];
    
    _beforeLab = [FactoryUI createLabelWithFrame:CGRectMake(_nameLab.left, _nameLab.bottom + 15.f, 70, 14) text:@"变更前" font:[UIFont systemFontOfSize:14]];
    _beforeLab.textColor = H9COLOR;
    [self.contentView addSubview:_beforeLab];
    
    _beforeCopyLab = [[VerticalToplabel alloc]initWithFrame:CGRectMake(_beforeLab.left, _beforeLab.bottom + 15, SCREENW/2-34, 15)];
    _beforeCopyLab.verticalAlignment = VerticalAlignmentTop;
    _beforeCopyLab.font = [UIFont systemFontOfSize:13];
    _beforeCopyLab.numberOfLines = 0;
    _beforeCopyLab.lineBreakMode = NSLineBreakByWordWrapping;
    _beforeCopyLab.textColor = COLOR2D343A;
    [self.contentView addSubview:_beforeCopyLab];
    
    
    _afterLab = [FactoryUI createLabelWithFrame:CGRectMake(SCREENW/2.0 + 17.f, _beforeLab.top , 70, 14) text:@"变更后" font:[UIFont systemFontOfSize:14]];
    _afterLab.textColor = H9COLOR;
    [self.contentView addSubview:_afterLab];
    
    _afterCopyLab = [[VerticalToplabel alloc]initWithFrame:CGRectMake(_afterLab.left, _afterLab.bottom + 15, SCREENW/2-34, 15)];
    _afterCopyLab.verticalAlignment = VerticalAlignmentTop;
    _afterCopyLab.font = [UIFont systemFontOfSize:13];
    _afterCopyLab.textColor = _beforeCopyLab.textColor;
    _afterCopyLab.numberOfLines = 0;
    _afterCopyLab.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_afterCopyLab];
    
    _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(17, _afterCopyLab.bottom + 10, SCREENW - 34, 1)];
    _bottomLine.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:_bottomLine];

    [self maskConstraints];
}

- (void)maskConstraints{
    
    [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.top.equalTo(self.contentView).offset(20);
        make.width.equalTo(@(180));
        make.height.equalTo(@(14));
    }];
    
    [_nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLab.mas_left);
        make.top.equalTo(self.timeLab.mas_bottom).offset(10);
        make.right.equalTo(self.contentView).offset(-17);
    }];
    
    [_beforeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLab.mas_left);
        make.top.equalTo(self.nameLab.mas_bottom).offset(15);
        make.width.equalTo(@(70));
        make.height.equalTo(@(14));
    }];
    
    [_beforeCopyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLab.mas_left);
        make.top.equalTo(_beforeLab.mas_bottom).offset(15);
        make.width.equalTo(@(SCREENW/2-34));
        make.bottom.equalTo(self.contentView).offset(-15);

    }];
    
    [_afterLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(SCREENW/2.0 + 17.f));
        make.top.equalTo(_beforeLab.mas_top);
        make.width.equalTo(@(70));
        make.height.equalTo(@(14));
    }];
    
    [_afterCopyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_afterLab.mas_left);
        make.top.equalTo(_afterLab.mas_bottom).offset(15);
        make.width.equalTo(@(SCREENW/2-34));
        make.bottom.equalTo(self.contentView).offset(-15);
        
    }];
    
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLab.mas_left);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@(0.5));
    }];
    
}

-(void)refreshUI:(CompanysDetailRegisterChangeRecordsModel *)model{
   
    self.nameLab.text = model.change_name;
    self.timeLab.text = model.change_time;

    self.beforeCopyLab.attributedText = model.beforeAtt;
    self.afterCopyLab.attributedText = model.afterAtt;

//    if ([model.name containsString:@"注册资本"]) {
//        _afterCopyLab.textColor = RED_TEXTCOLOR;
//    }else{
//        _afterCopyLab.textColor = HTColorFromRGB(0x555555);
//    }

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
