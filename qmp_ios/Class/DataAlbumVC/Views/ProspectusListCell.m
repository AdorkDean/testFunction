//
//  ProspectusListCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/8.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProspectusListCell.h"
#import "InsetsLabel.h"

@interface ProspectusListCell()
{
    UILabel *_titleLabel;
    UIImageView *_iconV;
    UILabel *_productLab;
    UIView *_line;
    
}
@property(nonatomic,strong)InsetsLabel *yewuLabel;
@property(nonatomic,strong)UILabel *jieduanLabel;

@end

@implementation ProspectusListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    
    _titleLabel = [[UILabel alloc]init];
    [_titleLabel labelWithFontSize:15 textColor:HTColorFromRGB(0x1d1d1d)];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentJustified;
    [self.contentView addSubview:_titleLabel];
    
    _yewuLabel = [[InsetsLabel alloc]init];
    [_yewuLabel labelWithFontSize:12 textColor:H9COLOR];
    [self.contentView addSubview:_yewuLabel];
    _yewuLabel.textAlignment = NSTextAlignmentRight;
    
    _jieduanLabel = [[UILabel alloc]init];
    _jieduanLabel.backgroundColor = [UIColor whiteColor];
    [_jieduanLabel labelWithFontSize:12 textColor:H9COLOR];
    [self.contentView addSubview:_jieduanLabel];
    
    
    _iconV = [[UIImageView alloc]init];
    _iconV.layer.cornerRadius = 2;
    _iconV.layer.masksToBounds = YES;
    _iconV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconV.layer.borderWidth = 0.5;
    _iconV.userInteractionEnabled = YES;
    [_iconV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterProduct)]];
    [self.contentView addSubview:_iconV];
    
    _productLab =  [[UILabel alloc]init];
    [_productLab labelWithFontSize:13 textColor:BLUE_TITLE_COLOR];
    _productLab.userInteractionEnabled = YES;
    [_productLab addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterProduct)]];
    [self.contentView addSubview:_productLab];
    
    _line = [[UIView alloc]init];
    _line.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:_line];
    
    //约束
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.right.equalTo(self.contentView).offset(-17);
        make.top.equalTo(self.contentView).offset(15);
        make.bottom.equalTo(self.contentView).offset(-43);
    }];
    
    [_iconV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.bottom.equalTo(self.contentView).offset(-15);
        make.height.equalTo(@(16));
        make.width.equalTo(@(16));
    }];
    
    [_productLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_iconV.mas_centerY);
        make.left.equalTo(_iconV.mas_right).offset(10);
        make.width.greaterThanOrEqualTo(@(40));
        make.height.equalTo(@(35));
    }];

    
    [_jieduanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_productLab.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-16);
        make.height.equalTo(@(16));
        make.width.greaterThanOrEqualTo(@(10));
    }];
    
    [_yewuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_jieduanLabel.mas_left).offset(-14);
        make.centerY.equalTo(_productLab.mas_centerY);
        make.width.greaterThanOrEqualTo(@(10));
        make.height.equalTo(@(16));
    }];
   
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_left);
        make.right.equalTo(_titleLabel.mas_right);
        make.height.equalTo(@(1));
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)setReport:(ReportModel *)report{
    
    _report = report;
    
    [_iconV sd_setImageWithURL:[NSURL URLWithString:report.icon] placeholderImage:[BundleTool imageNamed:PROICON_DEFAULT]];
    _productLab.text = report.product;
    
    NSString *title = [report.name containsString:@".pdf"]?[report.name substringToIndex:report.name.length - 4]:report.name;
    NSString *trailString;
    if ([PublicTool isNull:report.size]) {
       trailString = [NSString stringWithFormat:@" (%@)",[report.report_date stringByReplacingOccurrencesOfString:@"-" withString:@"."]];
    }else{
       trailString = [NSString stringWithFormat:@" (%@/%@)",report.size,[report.report_date stringByReplacingOccurrencesOfString:@"-" withString:@"."]];
    }
    if (report.isDownload) {
        trailString = [NSString stringWithFormat:@" (已下载/%@)",[report.report_date stringByReplacingOccurrencesOfString:@"-" withString:@"."]];
    }
    title = [title stringByAppendingString:trailString];
    
    _titleLabel.preferredMaxLayoutWidth = SCREENW - 33;
    
    CGRect rect = [title boundingRectWithSize:CGSizeMake((SCREENW - 33), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
    CGFloat height = _titleLabel.font.lineHeight;
    CGFloat rows = rect.size.height / height;
    
    
    NSMutableAttributedString *mutableAttText;
    
    if (rows >= 2.0) {
        NSAttributedString *attText = [title stringWithParagraphlineSpeace:8  textColor:H3COLOR textFont:_titleLabel.font];
        
        mutableAttText =[[NSMutableAttributedString alloc]initWithAttributedString:attText];
        
    }else{
        
        mutableAttText = [[NSMutableAttributedString alloc]initWithString:title];
    }
    
    [mutableAttText addAttributes:@{NSForegroundColorAttributeName:H9COLOR,NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(title.length - trailString.length, trailString.length)];
    
    
    _titleLabel.attributedText = mutableAttText;
    
    _yewuLabel.text = report.hangye1;
    
    if ([PublicTool isNull:report.shangshididian]) {
        
        _jieduanLabel.text = @"";
        [_jieduanLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_productLab.mas_centerY);
            make.right.equalTo(self.contentView.mas_right).offset(0);
            make.height.equalTo(_yewuLabel.mas_height);
            make.width.greaterThanOrEqualTo(@(0));
        }];
        
    }else{
        
        _jieduanLabel.text = report.shangshididian;
        [_jieduanLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_productLab.mas_centerY);
            make.right.equalTo(self.contentView.mas_right).offset(-16);
            make.height.equalTo(_yewuLabel.mas_height);
            make.width.greaterThanOrEqualTo(@(20));
        }];
    }
    
    [_line mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_left);
        make.right.equalTo(_titleLabel.mas_right);
        make.height.equalTo(@(0.5));
        make.bottom.equalTo(self.contentView);
    }];
    
}


- (void)enterProduct{
    if ([PublicTool isNull:_report.detail]) {
        return;
    }
    [[AppPageSkipTool shared] appPageSkipToDetail:_report.detail];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
