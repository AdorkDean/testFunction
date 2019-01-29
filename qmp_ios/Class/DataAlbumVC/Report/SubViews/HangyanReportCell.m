//
//  HangyanReportCell.m
//  qmp_ios
//
//  Created by QMP on 2018/7/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "HangyanReportCell.h"
@interface HangyanReportCell()

{
    UILabel *_titleLabel;
    UILabel *_timeLabel;
    UILabel *_sizeLabel;
    UIView *_line;
    UIButton *_scanCountBtn;
    
    
}
@end

@implementation HangyanReportCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    
    _titleLabel = [[UILabel alloc]init];
    [_titleLabel labelWithFontSize:15 textColor:HTColorFromRGB(0x272727)];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentJustified;
    [self.contentView addSubview:_titleLabel];
    
    _downIcon = [[UIImageView alloc]init];
    _downIcon.image = [BundleTool imageNamed:@"report_downIcon"];
    [self.contentView addSubview:_downIcon];
    
    _sourceLabel = [[UILabel alloc]init];
    _sourceLabel.backgroundColor = [UIColor whiteColor];
    [_sourceLabel labelWithFontSize:13 textColor:H9COLOR];
    [self.contentView addSubview:_sourceLabel];
    
//    _sizeLabel = [[UILabel alloc]init];
//    _sizeLabel.backgroundColor = [UIColor whiteColor];
//    [_sizeLabel labelWithFontSize:13 textColor:HTColorFromRGB(0x9d9fa3)];
//    _sizeLabel.textAlignment = NSTextAlignmentRight;
//    [self.contentView addSubview:_sizeLabel];
    
//    _timeLabel =  [[UILabel alloc]init];
//    [_timeLabel labelWithFontSize:13 textColor:H9COLOR];
//    [self.contentView addSubview:_timeLabel];
//    _timeLabel.textAlignment = NSTextAlignmentRight;
    
    _scanCountBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    [_scanCountBtn setImage:[BundleTool imageNamed:@"hangyanreport_yan"] forState:UIControlStateNormal];
    [_scanCountBtn setTitle:@"300" forState:UIControlStateNormal];
    _scanCountBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_scanCountBtn setTitleColor:H9COLOR forState:UIControlStateNormal];
    
    [_scanCountBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:3];
    [self.contentView addSubview:_scanCountBtn];
    
    _line = [[UIView alloc]init];
    _line.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:_line];
    //约束
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.contentView).offset(15);
        make.bottom.equalTo(self.contentView).offset(-48);
    }];
    
    [_sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_left);
        make.bottom.equalTo(self.contentView).offset(-12);
        make.right.equalTo(_scanCountBtn.mas_left).offset(-10);
        make.height.equalTo(@(24));
    }];
    
//    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(_sourceLabel.mas_centerY);
//        make.right.equalTo(_scanCountBtn.mas_left).offset(-10);
//        make.height.equalTo(@(18));
//    }];
    
    [_downIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_left);
        make.height.equalTo(@(15));
        make.width.equalTo(@(15));
        make.centerY.equalTo(_sourceLabel);
    }];
    
    [_scanCountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_sourceLabel.mas_centerY);
        make.left.equalTo(_sourceLabel.mas_right);
        make.width.greaterThanOrEqualTo(@(50));
        make.height.equalTo(_sourceLabel.mas_height);
    }];
    
//    [_sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(_sourceLabel.mas_centerY);
//        make.right.equalTo(self.contentView).offset(-15);
//        make.width.greaterThanOrEqualTo(@(50));
//        make.height.equalTo(_sourceLabel.mas_height);
//    }];
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.height.equalTo(@(1));
        make.bottom.equalTo(self.contentView);
    }];
    
   
    _scanCountBtn.hidden = YES;
}

//已下载中的 cell
- (void)refreshUI:(ReportModel*)report{
    
    _report = report;
    
    NSString *title = [report.name containsString:@".pdf"]?[report.name substringToIndex:report.name.length - 4]:report.name;
    if (![PublicTool isNull:report.size]) {
        NSString *trailString = [NSString stringWithFormat:@" (%@)",report.size];
        title = [title stringByAppendingString:trailString];
    }
    _titleLabel.preferredMaxLayoutWidth = SCREENW - 30;
    
    CGRect rect = [title boundingRectWithSize:CGSizeMake((SCREENW - 33), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
    CGFloat height = _titleLabel.font.lineHeight;
    CGFloat rows = rect.size.height / height;
    
    
    NSMutableAttributedString *mutableAttText;
    
    if (rows >= 2.0) {
        NSAttributedString *attText = [title stringWithParagraphlineSpeace:8  textColor:HTColorFromRGB(0x272727) textFont:_titleLabel.font];
        
        mutableAttText =[[NSMutableAttributedString alloc]initWithAttributedString:attText];
        
        
    }else{
        
        mutableAttText = [[NSMutableAttributedString alloc]initWithString:title];
    }
    if (![PublicTool isNull:report.size]) {
        
        [mutableAttText addAttributes:@{NSForegroundColorAttributeName:H9COLOR,NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(title.length - report.size.length - 2, report.size.length+2)];
    }
    
    _titleLabel.attributedText = mutableAttText;
    if (report.read_count.integerValue > 0) {
        _scanCountBtn.hidden = NO;
        [_scanCountBtn setTitle:[PublicTool strConverterFloatK:[NSString stringWithFormat:@"%@", report.read_count]] forState:UIControlStateNormal];
//        [_timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(_sourceLabel.mas_centerY);
//            make.left.equalTo(_scanCountBtn.mas_right).offset(10);
//            make.width.greaterThanOrEqualTo(@(50));
//            make.height.equalTo(_sourceLabel.mas_height);
//        }];
    }else{
//        [_timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(_sourceLabel.mas_centerY);
//            make.left.equalTo(_scanCountBtn.mas_right).offset(-80);
//            make.width.greaterThanOrEqualTo(@(50));
//            make.height.equalTo(_sourceLabel.mas_height);
//        }];
        [_scanCountBtn setTitle:@"" forState:UIControlStateNormal];
        _scanCountBtn.hidden = YES;
    }
    
    
    if (report.isDownload) {
        [_sourceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(33);
        }];
        _downIcon.hidden = NO;
    }else{
        [_sourceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
        }];
        _downIcon.hidden = YES;
    }
    NSString *time ;
    if (report.report_date) {
        time = [report.report_date stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    }else{
        time = @"";
        
    }
    _sourceLabel.text = [report.report_source stringByAppendingFormat:@"·%@",time];
    
    [_line mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@(1));
        make.bottom.equalTo(self.contentView);
    }];
    
    [self setNeedsUpdateConstraints];
}


- (void)setReport:(ReportModel *)report{
    
    [self refreshUI:report];
    
}

@end
