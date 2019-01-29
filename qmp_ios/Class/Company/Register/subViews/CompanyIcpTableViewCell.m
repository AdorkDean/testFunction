//
//  CompanyIcpTableViewCell.m
//  qmp_ios
//
//  Created by molly on 2017/4/18.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "CompanyIcpTableViewCell.h"
#import "GetSizeWithText.h"
@interface CompanyIcpTableViewCell()

@property (strong, nonatomic) UILabel *lunciLab;
@property (strong, nonatomic) UILabel *timeLab;
@property (strong, nonatomic) UILabel *tzrLab;

@property (strong, nonatomic) GetSizeWithText *sizeTool;

@end
@implementation CompanyIcpTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    CompanyIcpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompanyIcpTableViewCellID"];
    if (!cell) {
        cell = [[CompanyIcpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CompanyIcpTableViewCellID"];
    }
    return cell;
}
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
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildUI];
    }
    return self;
}

- (void)buildUI
{
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    CGFloat margin = 17.f;
    CGFloat lblH = 30.f;
    CGFloat lblW = SCREENW - margin * 2;
    UIFont *lblFont = [UIFont systemFontOfSize:15];
    
    _lunciLab = [[UILabel alloc] initWithFrame:CGRectMake(margin, 10, lblW, lblH)];
    [_lunciLab setFont:[UIFont systemFontOfSize:15]];//加粗
    _lunciLab.textColor = H9COLOR;
    [self.contentView addSubview:_lunciLab];
    
    _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(margin, _lunciLab.bottom, lblW, lblH)];
    _timeLab.font = lblFont;
    _timeLab.textColor = COLOR2D343A;
    [self.contentView addSubview:_timeLab];
    
    _moneyLab = [[UILabel alloc] initWithFrame:CGRectMake(_timeLab.left, _timeLab.bottom, lblW, lblH)];
    _moneyLab.font = lblFont;
    _moneyLab.textColor = COLOR2D343A;
    [self.contentView addSubview:_moneyLab];
    
    _tzrLab = [[UILabel alloc] initWithFrame:CGRectMake(_moneyLab.left, _moneyLab.bottom, lblW, lblH)];
    _tzrLab.font = lblFont;
    _tzrLab.textColor = COLOR2D343A;
    [self.contentView addSubview:_tzrLab];
    
}

- (void)initData:(CompanyIcpModel *)model{
    
    _lunciLab.text = model.examine_date;
    if (![model.company_type isEqualToString:@""]) {
       _lunciLab.text = [NSString stringWithFormat:@"%@（%@）",model.examine_date,model.company_type];
    }
    _timeLab.text = [NSString stringWithFormat:@"网站名称：%@",model.web_name];
    NSString *headerStr = [NSString stringWithFormat:@"网站首页：%@",model.web_site];
    NSRange range = {5,model.web_site.length};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:headerStr];
    [str addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:range];
    _moneyLab.attributedText = str;

    NSString *number = [NSString stringWithFormat:@"备案号码：%@",model.liscense];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:number];
    [attText addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(3, 1)];
    _tzrLab.attributedText = attText;
}

- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}
@end
