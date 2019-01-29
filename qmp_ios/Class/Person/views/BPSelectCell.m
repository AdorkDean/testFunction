//
//  BPSelectCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BPSelectCell.h"

@interface BPSelectCell()
{
    UILabel *_titleLabel;
    UILabel *_tipLab; //3日内不可重复投递
    UIView *_line;
}
@end

@implementation BPSelectCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}


- (void)setUI{
    _selecctBtn  = [[UIButton alloc]init];
    [_selecctBtn setImage:[UIImage imageNamed:@"bp_unSelected"] forState:UIControlStateNormal];
    [_selecctBtn setImage:[UIImage imageNamed:@"bp_selected"] forState:UIControlStateSelected];
    [self.contentView addSubview:_selecctBtn];
    
    _titleLabel = [[UILabel alloc]init];
    [_titleLabel labelWithFontSize:15 textColor:NV_TITLE_COLOR];
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];
    
    _tipLab = [[UILabel alloc]init];
    [_tipLab labelWithFontSize:12 textColor:H9COLOR];
    _tipLab.text = @"3日内已投递过";
    [self.contentView addSubview:_tipLab];
    
    _line = [[UIView alloc]init];
    _line.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:_line];
    
    //约束
    [_selecctBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(0);
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@(44));
        make.height.equalTo(@(44));
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(49);
        make.top.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.bottom.equalTo(self.contentView).offset(-20);
    }];
    
    [_tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_titleLabel.mas_centerY);
        make.right.equalTo(self.contentView).offset(-15);
        make.width.equalTo(@(110));
    }];
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.right.equalTo(self.contentView).offset(-17);
        make.bottom.equalTo(self.contentView);
        make.height.equalTo(@(0.5));
    }];
    
}

-(void)setReport:(ReportModel *)report{
    _report = report;
    NSString *title;
    if (!_isMyBP) {
        title = report.name;
    }else{
        title = [NSString stringWithFormat:@"%@ %@", report.name, [PublicTool isNull:report.product]?@"":[NSString stringWithFormat:@"-%@", report.product]];
    }

    _titleLabel.preferredMaxLayoutWidth = SCREENW - 69;
    
    CGRect rect = [title boundingRectWithSize:CGSizeMake((SCREENW - 69), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
    CGFloat height = _titleLabel.font.lineHeight;
    CGFloat rows = rect.size.height / height;
    
    NSMutableAttributedString *mutableAttText;
    
    if (rows >= 2.0) {
        NSAttributedString *attText = [title stringWithParagraphlineSpeace:6  textColor:H9COLOR textFont:_titleLabel.font];
        
        mutableAttText =[[NSMutableAttributedString alloc]initWithAttributedString:attText];
        
    }else{
        
        mutableAttText = [[NSMutableAttributedString alloc]initWithString:title];
    }
        
    if (_keyWord && [title containsString:_keyWord]) {
        NSArray *rangeArr = [PublicTool noDifferenceUporLowRangeOfSubString:_keyWord inString:title];
        for (NSValue *rangeV in rangeArr) {
            NSRange range = rangeV.rangeValue;
            [mutableAttText addAttributes:@{NSForegroundColorAttributeName:RED_TEXTCOLOR} range:range];
        }
    }
    if (_isMyBP) {
        NSArray *productArr = [PublicTool noDifferenceUporLowRangeOfSubString:_report.product inString:title];
        for (NSValue *rangeV in productArr) {
            NSRange range = rangeV.rangeValue;
            [mutableAttText addAttributes:@{NSForegroundColorAttributeName:RED_TEXTCOLOR} range:range];
        }
    }
    
    _titleLabel.attributedText = mutableAttText;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    _titleLabel.textColor = NV_TITLE_COLOR;
    _selecctBtn.hidden = NO;
    _tipLab.hidden = YES;
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(49);
        make.top.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.bottom.equalTo(self.contentView).offset(-20);
    }];
//    
//    if (report.send_status.integerValue != 2) { //可投递
//        _titleLabel.textColor = NV_TITLE_COLOR;
//        _selecctBtn.hidden = NO;
//        _tipLab.hidden = YES;
//        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.contentView).offset(49);
//            make.top.equalTo(self.contentView).offset(20);
//            make.right.equalTo(self.contentView).offset(-20);
//            make.bottom.equalTo(self.contentView).offset(-20);
//        }];
//    }else{
//        
//        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.contentView).offset(17);
//            make.top.equalTo(self.contentView).offset(20);
//            make.right.equalTo(self.contentView).offset(-120);
//            make.bottom.equalTo(self.contentView).offset(-20);
//        }];
//        _tipLab.hidden = NO;
//        _selecctBtn.hidden = YES;
//        _titleLabel.textColor = H9COLOR;
//    }
    _selecctBtn.selected = report.selected;
}

- (void)setIsMyBP:(BOOL)isMyBP{
    _isMyBP = isMyBP;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
