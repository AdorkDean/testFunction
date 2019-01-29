//
//  ProductRongziCell.m
//  qmp_ios
//
//  Created by QMP on 2018/7/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductRongziCell.h"
#import "GetSizeWithText.h"
#import "CopyLabel.h"
#import "NewsWebViewController.h"
#import <YYTextLayout.h>

#define RGBblueColor RGBa(102,153,255, 1)

@interface ProductRongziCell()<TTTAttributedLabelDelegate>
@property (strong, nonatomic) UIImageView *iconV;
@property (strong, nonatomic) UIView *verticalLine;
@property (strong, nonatomic) UILabel *lunciLab;
@property (strong, nonatomic) UILabel *moneyLab;
@property (strong, nonatomic) UILabel *timeLab;


@property (strong, nonatomic) GetSizeWithText *sizeTool;
@property (strong, nonatomic) CompanyDetailRongziModel *model;

@end

@implementation ProductRongziCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    CGFloat margin = 17.f;
    CGFloat lblH = 25.f;
    CGFloat lblW = SCREENW - margin * 2;
    UIFont *lblFont = [UIFont systemFontOfSize:14];
    
   
    
    _verticalLine = [[UIView alloc]initWithFrame:CGRectZero];
    _verticalLine.backgroundColor = HTColorFromRGB(0xe3e3e3);
    [self.contentView addSubview:_verticalLine];
    
    _iconV = [[UIImageView alloc]initWithFrame:CGRectZero];
    _iconV.image = [UIImage imageNamed:@"blue_point"];
    _iconV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconV];
    
    _lunciLab = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, lblW, lblH)];
    _lunciLab.textAlignment = NSTextAlignmentRight;
    if (@available(iOS 8.2, *)) {
        [_lunciLab setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium]];//加粗
    }else{
        [_lunciLab setFont:[UIFont systemFontOfSize:14]];//加粗
    }
    _lunciLab.textColor = COLOR2D343A;
    _lunciLab.numberOfLines = 2;
    [self.contentView addSubview:_lunciLab];
    
    
    _moneyLab = [[UILabel alloc] initWithFrame:CGRectMake(margin, _lunciLab.frame.origin.y+_lunciLab.frame.size.height, lblW, lblH)];
    [_moneyLab labelWithFontSize:14 textColor:COLOR2D343A];
    [self.contentView addSubview:_moneyLab];
    
    
    _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(margin, _lunciLab.frame.origin.y+_lunciLab.frame.size.height, lblW, lblH)];
    [_timeLab labelWithFontSize:14 textColor:COLOR737782];
    _timeLab.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_timeLab];
    
    _tzrLab = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(15, 0, lblW, lblH)];
    _tzrLab.font = lblFont;
    _tzrLab.numberOfLines = 0;
    _tzrLab.textColor = COLOR2D343A;
    _tzrLab.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    [self.contentView addSubview:_tzrLab];
    _tzrLab.delegate = self;
    
    
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
    [linkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];//网址没有下划线
    [linkAttributes setValue:BLUE_TITLE_COLOR forKey:(NSString *)kCTForegroundColorAttributeName];
    _tzrLab.linkAttributes = linkAttributes;
    
    
    _faLbl = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _faLbl.font = lblFont;
    _faLbl.numberOfLines = 0;
    _faLbl.lineBreakMode = NSLineBreakByCharWrapping;
    _faLbl.textAlignment = NSTextAlignmentLeft;
    _faLbl.textColor = HTColorFromRGB(0x555555);
    [self.contentView addSubview:_faLbl];
    _faLbl.delegate = self;
    
    NSMutableDictionary *linkAttributes1 = [NSMutableDictionary dictionary];
    [linkAttributes1 setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];//网址没有下划线
    [linkAttributes1 setValue:BLUE_TITLE_COLOR forKey:(NSString *)kCTForegroundColorAttributeName];
    _faLbl.linkAttributes = linkAttributes;
    
    
    _sourceBtn = [[UIButton alloc] init];
    _sourceBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    _sourceBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_sourceBtn setTitle:@"来源" forState:UIControlStateNormal];
    [_sourceBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [self.contentView addSubview:_sourceBtn];
    [_sourceBtn addTarget:self action:@selector(sourceBtnClick) forControlEvents:UIControlEventTouchUpInside];
    

    //约束
    [_iconV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(98);
        make.top.equalTo(self.contentView).offset(15);
        make.width.equalTo(@(13));
        make.height.equalTo(@(13));
    }];
    
    [_verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.centerX.equalTo(_iconV.mas_centerX);
        make.width.equalTo(@(1));
        make.bottom.equalTo(self.contentView);
    }];
    
    [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.centerY.equalTo(_iconV.mas_centerY);
        make.right.equalTo(_iconV.mas_left).offset(-9);
        make.height.equalTo(@(_timeLab.font.lineHeight));
    }];
    
    [_moneyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconV.mas_right).offset(9);
        make.centerY.equalTo(_iconV.mas_centerY);
        make.right.equalTo(self.sourceBtn.mas_left).offset(-10);
        make.height.equalTo(@(_moneyLab.font.lineHeight));
    }];
    
    [_lunciLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.top.equalTo(_timeLab.mas_bottom).offset(10);
        make.right.equalTo(_timeLab.mas_right);
//        make.height.equalTo(@(_lunciLab.font.lineHeight));
        make.height.greaterThanOrEqualTo(@(13));

    }];
    
    
    [_tzrLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_moneyLab.mas_left);
        make.top.equalTo(_lunciLab.mas_top).offset(10);
        make.right.equalTo(self.contentView).offset(-15);
        
    }];
    
    [_tzrLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_tzrLab setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    
   
    [_faLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_tzrLab.mas_left);
        make.top.equalTo(_tzrLab.mas_bottom).offset(10);
        make.right.equalTo(_tzrLab.mas_right);
        make.bottom.equalTo(self.contentView).offset(-20);
    }];
    
    
    [_sourceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-17);
        make.width.equalTo(@(50));
        make.height.equalTo(@(50));
        make.centerY.equalTo(self.moneyLab.mas_centerY);
    }];
    
//    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(16);
//        make.right.equalTo(self.contentView).offset(-16);
//        make.height.equalTo(@(1));
//        make.bottom.equalTo(self.contentView.mas_bottom);
//    }];
    
    _tzrLab.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    _faLbl.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    
}

- (void)initData:(CompanyDetailRongziModel *)model{
    
    _model = model;
    
    _sourceBtn.hidden = [PublicTool isNull:model.source];
    model.lunci = [model.jieduan stringByReplacingOccurrencesOfString:@"（" withString:@""];
    model.lunci = [model.jieduan stringByReplacingOccurrencesOfString:@"）" withString:@""];

    _lunciLab.text = model.jieduan;
    if (![PublicTool isNull:model.time]) {
        
        self.timeLab.text = [PublicTool fullDateStringWithYMRString:model.time];
      
    }

    _moneyLab.text = model.money;
    if (![PublicTool isNull:model.fa]) {
        
        NSString *faStr = [NSString stringWithFormat:@"%@",model.fa];
        _faLbl.textColor = COLOR2D343A;
        _faLbl.text = faStr;
        
        [_faLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_tzrLab.mas_left);
            make.top.equalTo(_tzrLab.mas_bottom).offset(10);
            make.right.equalTo(_tzrLab.mas_right);
            make.bottom.equalTo(self.contentView).offset(-20);
        }];
        
    }else{
        
        _faLbl.text = @"测试";
        _faLbl.textColor = [UIColor clearColor];
        
        [_faLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_tzrLab.mas_left);
            make.top.equalTo(_tzrLab.mas_bottom).offset(10);
            make.right.equalTo(_tzrLab.mas_right);
            make.bottom.equalTo(self.contentView).offset(-10);
        }];
        
    }
    
    NSString *tzrStr = [model.tzr_all stringByReplacingOccurrencesOfString:@"|" withString:@"  "];
    
    self.tzrLab.text = tzrStr;
    
    //计算多少行
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:tzrStr];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    [style setLineSpacing:8.f];
    [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attStr.length)];
    [attStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(0, attStr.length)];
    
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(SCREENW - 135, MAXFLOAT) text:attStr];
    
    if (textLayout.rowCount > 1) {
        [_tzrLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_moneyLab.mas_left);
            make.top.equalTo(_lunciLab.mas_top).offset(-1);
            make.right.equalTo(self.contentView).offset(-15);
            make.height.equalTo(@(textLayout.textBoundingSize.height));
        }];
    }else{
        [_tzrLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_moneyLab.mas_left);
            make.top.equalTo(_lunciLab.mas_top);
            make.right.equalTo(self.contentView).offset(-15);
            make.height.equalTo(@(textLayout.textBoundingSize.height));
        }];
    }
   
    [_tzrLab setText:tzrStr afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        if (textLayout.rowCount > 1) {
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            [style setLineBreakMode:NSLineBreakByWordWrapping];
            [style setLineSpacing:8.f];
            [mutableAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, mutableAttributedString.length)];
        }
        return mutableAttributedString;
    }];
    [_tzrLab sizeToFit];
    
    if (_model.investor_info && [_model.investor_info isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in _model.investor_info) {
            if ([PublicTool isNull:dic[@"detail"]]) {
                continue;
            }
            NSRange range = [tzrStr rangeOfString:dic[@"investor"]];
            [_tzrLab addLinkToURL:[NSURL URLWithString:dic[@"detail"]] withRange:range];
        }
    }
    
    //为了显示正常
    NSString *faStr = ![PublicTool isNull:_model.fa] ? [NSString stringWithFormat:@"FA：%@",[_model.fa stringByReplacingOccurrencesOfString:@"|" withString:@" "]]:@"";
    _faLbl.text = faStr;
    [_faLbl setText:faStr afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        return mutableAttributedString;
    }];
    
    if (_model.fa_info && [_model.fa_info isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in _model.fa_info) {
            if ([PublicTool isNull:dic[@"detail"]]) {
                continue;
            }
            NSRange range = [faStr rangeOfString:dic[@"fa_name"]];
            [_faLbl addLinkToURL:[NSURL URLWithString:dic[@"detail"]] withRange:range];
        }
    }
    
    if (self.firstRow) {
        if(self.firstRow == self.lastRow){
            [_verticalLine mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.mas_top).offset(15);
                make.centerX.equalTo(_iconV.mas_centerX);
                make.width.equalTo(@(1));
                make.bottom.equalTo(self.contentView).offset(-20);
            }];
        }else{
            [_verticalLine mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.mas_top).offset(15);
                make.centerX.equalTo(_iconV.mas_centerX);
                make.width.equalTo(@(1));
                make.bottom.equalTo(self.contentView);
            }];
        }
        
    }else if (self.lastRow) {
        [_verticalLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.centerX.equalTo(_iconV.mas_centerX);
            make.width.equalTo(@(1));
            make.bottom.equalTo(self.contentView).offset(-20);
        }];
    }else{
        [_verticalLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.centerX.equalTo(_iconV.mas_centerX);
            make.width.equalTo(@(1));
            make.bottom.equalTo(self.contentView);
        }];
    }
}


#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    
    if (url) {
        [self enterDetail:url.absoluteString];
    }
}

- (void)enterDetail:(NSString*)urlStr{
    
    [[AppPageSkipTool shared] appPageSkipToDetail:urlStr];

}

/**
 点击融资新闻的来源按钮
 
 @param sender
 */
- (void)sourceBtnClick{
    
    NSString *url = _model.source;;
    
    if (![PublicTool isNull:url]) {
        
        URLModel *urlModel = [[URLModel alloc] init];
        urlModel.url = url;
        NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@"Homes"];
        webView.fromVC = @"融资历史披露事件";
        [[PublicTool topViewController].navigationController pushViewController:webView animated:YES];
        
        webView.feedbackFlag = @"项目";
    }
}


- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}

@end
