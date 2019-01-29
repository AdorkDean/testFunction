//
//  MeDocumentCell.m
//  qmp_ios
//
//  Created by QMP on 2018/7/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MeDocumentCell.h"

@interface MeDocumentCell()

{
    UILabel *_titleLabel;
    UILabel *_timeLabel;
//    UILabel *_sizeLabel;
    UIView *_line;
    
}
@end

@implementation MeDocumentCell

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
    
    _sourceLabel = [[UILabel alloc]init];
    _sourceLabel.backgroundColor = [UIColor whiteColor];
    [_sourceLabel labelWithFontSize:13 textColor:HTColorFromRGB(0x9d9fa3)];
    [self.contentView addSubview:_sourceLabel];
    
//    _sizeLabel = [[UILabel alloc]init];
//    _sizeLabel.backgroundColor = [UIColor whiteColor];
//    [_sizeLabel labelWithFontSize:13 textColor:HTColorFromRGB(0x9d9fa3)];
//    _sizeLabel.textAlignment = NSTextAlignmentRight;
//    [self.contentView addSubview:_sizeLabel];
    
    _timeLabel =  [[UILabel alloc]init];
    [_timeLabel labelWithFontSize:13 textColor:HTColorFromRGB(0x9d9fa3)];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    
    
    _line = [[UIView alloc]init];
    _line.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:_line];
    //约束
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.contentView).offset(17);
        make.bottom.equalTo(self.contentView).offset(-48);
    }];
    
    [_sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_left);
        make.bottom.equalTo(self.contentView).offset(-12);
        make.right.equalTo(_timeLabel.mas_left).offset(-10);
        make.height.equalTo(@(24));
    }];
    
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_sourceLabel.mas_centerY);
        make.left.equalTo(_sourceLabel.mas_right).offset(10);
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
        
        mutableAttText = [[NSMutableAttributedString alloc]initWithString:title?:@""];
    }
    if (![PublicTool isNull:report.name] && ![PublicTool isNull:report.size]) {
      
        [mutableAttText addAttributes:@{NSForegroundColorAttributeName:H9COLOR,NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(title.length - report.size.length - 2, report.size.length+2)];
    }
    
    _titleLabel.attributedText = mutableAttText;

    _sourceLabel.text = report.report_source;
    
    if ([PublicTool isNull:report.report_date]) {
        _timeLabel.text = @"";
        
    }else{
        if (report.report_date && report.report_date.length == 8) {
            NSString *date = [NSString stringWithFormat:@"%@-%@-%@",[report.report_date substringToIndex:4],[report.report_date substringWithRange:NSMakeRange(4, 2)],[report.report_date substringFromIndex:6]];
            _timeLabel.text = date;
        }else{
            _timeLabel.text = @"";
            
        }
        
    }
    
//    _sizeLabel.text = report.size;
    
    if (self.showSource) {
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.top.equalTo(self.contentView).offset(17);
            make.bottom.equalTo(self.contentView).offset(-48);
        }];
        _sourceLabel.hidden = NO;
        _timeLabel.hidden = NO;
    }else{
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.top.equalTo(self.contentView).offset(17);
            make.bottom.equalTo(self.contentView).offset(-15);
        }];
        _sourceLabel.hidden = YES;
        _timeLabel.hidden = YES;
    }
    
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
