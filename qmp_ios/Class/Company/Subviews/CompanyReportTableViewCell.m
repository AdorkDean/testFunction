//
//  CompanyReportTableViewCell.m
//  qmp_ios
//
//  Created by Molly on 2016/12/15.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CompanyReportTableViewCell.h"
#import "GetSizeWithText.h"
@interface CompanyReportTableViewCell()

@property (strong, nonatomic) GetSizeWithText *sizeTool;
@property (strong, nonatomic)  UILabel *nameLbl;
@property (strong, nonatomic)  UILabel *sizeLbl;
@property (strong, nonatomic)  UILabel *timeLbl;
@property (strong, nonatomic)  UILabel  *downStatusL;

@end

@implementation CompanyReportTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.nameLbl = [[UILabel alloc] init];
        self.nameLbl.textColor = HTColorFromRGB(0x1d1d1d);
        self.nameLbl.font = [UIFont systemFontOfSize:15];
        self.nameLbl.numberOfLines = 1;
        [self.contentView addSubview:self.nameLbl];
        
        self.sizeLbl = [[UILabel alloc] init];
        self.sizeLbl.backgroundColor = [UIColor whiteColor];
        self.sizeLbl.font = [UIFont systemFontOfSize:13.f];
        self.sizeLbl.textColor = H9COLOR;
        [self.contentView addSubview:self.sizeLbl];
        
        self.timeLbl = [[UILabel alloc] init];
        self.timeLbl.textAlignment = NSTextAlignmentRight;
        self.timeLbl.font = [UIFont systemFontOfSize:13.f];
        self.timeLbl.textColor = H9COLOR;
        [self.contentView addSubview:self.timeLbl];
        
        self.downStatusL = [[UILabel alloc]init];
        self.downStatusL.font = [UIFont systemFontOfSize:13.f];
        self.downStatusL.text = @"已下载";
        self.downStatusL.backgroundColor = [UIColor whiteColor];
        self.downStatusL.textColor = H9COLOR;
        [self.contentView addSubview:self.downStatusL];
        
        
        self.bottomLine = [[UIView alloc]init];
        self.bottomLine.backgroundColor = LIST_LINE_COLOR;
        [self.contentView addSubview:self.bottomLine];
        [self maskConstraint];
    }
    return self;
}

- (void)maskConstraint{
    
    [self.nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(25);
        make.left.equalTo(self.contentView).offset(17);
        make.right.equalTo(self.contentView).offset(-17);
        make.bottom.equalTo(self.contentView).offset(-46);
    }];
    
    [self.nameLbl setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.nameLbl setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    
   
    
    [self.sizeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLbl.mas_left);
        make.top.equalTo(_nameLbl.mas_bottom).offset(10);
        make.width.greaterThanOrEqualTo(@(90));
        make.height.equalTo(@(16));
    }];
    
    [self.downStatusL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLbl.mas_left);
        make.top.equalTo(_nameLbl.mas_bottom).offset(10);
        make.width.equalTo(@(50));
        make.height.equalTo(@(16));
    }];
    
    [self.timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_nameLbl.mas_right);
        make.top.equalTo(_nameLbl.mas_bottom).offset(10);
        make.width.equalTo(@(120));
        make.height.equalTo(@(16));
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.right.equalTo(self.contentView).offset(17);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@(0.5));
    }];
    
}

- (void)initData:(ReportModel *)pdfModel{
    
    if (pdfModel.isDownload) {
        self.downStatusL.hidden = NO;
        self.sizeLbl.hidden = YES;
        
    }else{
        
        self.sizeLbl.hidden = NO;
        self.downStatusL.hidden =YES;

    }
    
    
    NSMutableAttributedString *muAttText = [[NSMutableAttributedString alloc]initWithString:pdfModel.name];
    if ([pdfModel.name hasSuffix:@".pdf"]) {
        [muAttText addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(pdfModel.name.length-4, 4)];
    }
    if (pdfModel.isNewThird) {
        self.nameLbl.textColor = RED_TEXTCOLOR;
    }
    else{
        self.nameLbl.textColor = HTColorFromRGB(0x1d1d1d);
    }
    
    CGFloat height = [self.sizeTool calculateSize:pdfModel.name withFont:[UIFont systemFontOfSize:15.f] withWidth:SCREENW - 17*2].height;
    NSInteger row = height/self.nameLbl.font.lineHeight;
    if (row == 1) {
        
        self.nameLbl.numberOfLines = 1;
        self.nameLbl.attributedText = muAttText;

    }else{
        self.nameLbl.numberOfLines = 2;

        NSAttributedString *attText = [pdfModel.name stringWithParagraphlineSpeace:6  textColor:self.nameLbl.textColor textFont:self.nameLbl.font];
        muAttText = [[NSMutableAttributedString alloc]initWithAttributedString:attText];
        if ([pdfModel.name hasSuffix:@".pdf"]) {
            [muAttText addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(pdfModel.name.length-4, 4)];
        }
        self.nameLbl.attributedText = muAttText;
        self.nameLbl.lineBreakMode = NSLineBreakByTruncatingTail;

    }

    if (pdfModel.datetime && [pdfModel.datetime isKindOfClass:[NSString class]] && [pdfModel.datetime containsString:@"-"]) {
        self.timeLbl.text = [[pdfModel.datetime componentsSeparatedByString:@"-"] componentsJoinedByString:@"."];
    }else{
        self.timeLbl.text = pdfModel.datetime.length > 3 ? pdfModel.datetime:@"";
    }
    
    if (pdfModel.size) {
        self.sizeLbl.text = [NSString stringWithFormat:@"%@",pdfModel.size];

    }else{
        self.sizeLbl.text = @"";

    }
    
}

- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}
@end
