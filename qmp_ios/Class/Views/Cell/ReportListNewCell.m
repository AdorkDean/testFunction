//
//  ReportListNewCell.m
//  qmp_ios
//
//  Created by QMP on 2017/9/28.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "ReportListNewCell.h"

@interface ReportListNewCell()
{
    UILabel *_titleLabel;
    UILabel *_timeLabel;
    UILabel *_sizeLabel;
    UIView *_line;
    UIButton *_scanCountBtn;
    
}
@end

@implementation ReportListNewCell

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
    [_sourceLabel labelWithFontSize:13 textColor:HTColorFromRGB(0x9d9fa3)];
    [self.contentView addSubview:_sourceLabel];
    
    _sizeLabel = [[UILabel alloc]init];
    _sizeLabel.backgroundColor = [UIColor whiteColor];
    [_sizeLabel labelWithFontSize:13 textColor:HTColorFromRGB(0x9d9fa3)];
    _sizeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_sizeLabel];
    
    _timeLabel =  [[UILabel alloc]init];
    [_timeLabel labelWithFontSize:13 textColor:HTColorFromRGB(0x9d9fa3)];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.textAlignment = NSTextAlignmentRight;

    _scanCountBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    [_scanCountBtn setImage:[BundleTool imageNamed:@"blue_point"] forState:UIControlStateNormal];
    [_scanCountBtn setTitle:@"300" forState:UIControlStateNormal];
    _scanCountBtn.titleLabel.font = [UIFont systemFontOfSize:14];
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
        make.right.equalTo(_timeLabel.mas_left).offset(-10);
        make.height.equalTo(@(24));
    }];
    
    
    [_downIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_left);
        make.height.equalTo(@(15));
        make.width.equalTo(@(15));
        make.centerY.equalTo(_sourceLabel);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_sourceLabel.mas_centerY);
        make.left.equalTo(_sourceLabel.mas_right).offset(10);
        make.width.greaterThanOrEqualTo(@(50));
        make.height.equalTo(_sourceLabel.mas_height);
    }];
    
    [_sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_sourceLabel.mas_centerY);
        make.right.equalTo(self.contentView).offset(-15);
        make.width.greaterThanOrEqualTo(@(50));
        make.height.equalTo(_sourceLabel.mas_height);
    }];
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.height.equalTo(@(1));
        make.bottom.equalTo(self.contentView);
    }];
    
    [_scanCountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.width.greaterThanOrEqualTo(@(50));
        make.height.equalTo(@(18));
    }];
    _scanCountBtn.hidden = YES;
}

//已下载中的 cell
- (void)refreshUI:(ReportModel*)report{
    
    _report = report;

    NSString *title = [report.name containsString:@".pdf"]?[report.name substringToIndex:report.name.length - 4]:report.name;
//    NSString *trailString = [NSString stringWithFormat:@"  %@",report.report_date];
//    title = [title stringByAppendingString:trailString];
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
    
    if (self.keyWord && [title containsString:self.keyWord]) {
        for (NSValue *rangeV in [PublicTool noDifferenceUporLowRangeOfSubString:self.keyWord inString:title]) {
            NSRange range = rangeV.rangeValue;
            [mutableAttText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:range];
        }
    }
    
    _titleLabel.attributedText = mutableAttText;
    
    
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
    
    _sourceLabel.text = report.report_source;

    if ([PublicTool isNull:report.report_date]) {
        _timeLabel.text = @"";
    }else{
        _timeLabel.text = [report.report_date stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    }
    
    _sizeLabel.text = report.size;
    
    [_line mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@(1));
        make.bottom.equalTo(self.contentView);
    }];
    
    if (self.showScanCount && (report.read_count.integerValue > 0)) {
        //约束
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-70);
            make.top.equalTo(self.contentView).offset(15);
            make.bottom.equalTo(self.contentView).offset(-48);
        }];
        _scanCountBtn.hidden = NO;
        [_scanCountBtn setTitle:report.read_count forState:UIControlStateNormal];
        
    }else{
        
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.top.equalTo(self.contentView).offset(15);
            make.bottom.equalTo(self.contentView).offset(-48);
        }];
        _scanCountBtn.hidden = YES;
    }
    [self setNeedsUpdateConstraints];
}

//2018-9-1 12:32:32
- (NSString*)dateString:(NSString*)originStr{
    
    if ([PublicTool isNull:originStr]) {
        return @"";
    }
    
    NSArray *arr = [[[originStr componentsSeparatedByString:@" "] firstObject] componentsSeparatedByString:@"-"];
    
    NSString *year ;
    NSString *month ;
    NSString *day ;
    if (arr.count == 3) { //年月日
        year = arr[0];
        month = arr[1];
        day = arr[2];
    }else{
        return arr[0];
    }
    
    
    BOOL isCurrentYear = [year isEqualToString:[PublicTool currentYear]];
    NSString *today = [PublicTool currentDay]; //09-10
    BOOL isCurrentDay = NO;
    if ((month.intValue == [[today substringToIndex:2]intValue]) && (day.intValue == [[today substringFromIndex:3]intValue])) {
        isCurrentDay = YES;
    }
    
    NSString *yesToday = [[PublicTool yesToday] substringFromIndex:3];
    
    BOOL isYestoday = NO;
    if ((day.intValue == yesToday.intValue) && (month.intValue == [[today substringToIndex:2]intValue])) {
        isYestoday = YES;
    }
    
    if (isCurrentYear) {
        if (isCurrentDay) {
            return @"今日下载";
        }else if(isYestoday){
            return @"昨日下载";
        }else{
            return [NSString stringWithFormat:@"%@-%@",month,day];
        }
    }else{
        return [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    }
}



- (void)setReport:(ReportModel *)report{
    
    [self refreshUI:report];
        
}
- (NSString*)showReportTime{
   
    if (_report.report_date.length < 6) {
        NSArray *arr = [_report.datetime componentsSeparatedByString:@" "];
        if (arr.count>1) {
            NSString *time = [arr[0] stringByReplacingOccurrencesOfString:@"-" withString:@"."];
            return time;
        }
        return @"";

    }else{
        NSString *year;
        
        if (_report.report_date.length > 4) {
            year = [_report.report_date substringToIndex:4];
        }else{
            year = _report.report_date;
        }
        
        NSString *month;
        if (_report.report_date.length > 6) {
            month = [_report.report_date substringWithRange:NSMakeRange(4, 2)];
        }else{
            month = @"";
        }
        NSString *day;
        if (_report.report_date.length == 8) {
            day = [_report.report_date substringWithRange:NSMakeRange(6, 2)];
        }else{
            day = @"";
        }
        
        return [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    }
    
    return @"";
}


- (NSString*)dealDate{
    if (_report.report_date.length < 6) {
        return @"";
    }
    
    NSString *year;

    if (_report.report_date.length > 4) {
        year = [_report.report_date substringToIndex:4];
    }else{
        year = _report.report_date;
    }
    
    NSString *month;
    if (_report.report_date.length > 6) {
        month = [_report.report_date substringWithRange:NSMakeRange(4, 2)];
    }else{
        month = @"";
    }
    return [NSString stringWithFormat:@"%@.%@",year,month];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
