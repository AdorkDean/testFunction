//
//  QMPIPOLibraryCell.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/9/5.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPIPOLibraryCell.h"
#import "SmarketEventModel.h"

@interface QMPIPOLibraryCell ()
@property (nonatomic, strong) UILabel *stockNameLabel;
@property (nonatomic, strong) UILabel *stockCodeLabel;
@property (nonatomic, strong) UILabel *boardLabel;
@property (nonatomic, strong) UILabel *fieldLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *lineView;
@end

@implementation QMPIPOLibraryCell
+ (instancetype)ipoLibraryCellWithTableView:(UITableView *)tableView {
    QMPIPOLibraryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMPIPOLibraryCellID"];
    if (!cell) {
        cell = [[QMPIPOLibraryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QMPIPOLibraryCellID"];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    [self.contentView addSubview:self.stockNameLabel];
    [self.contentView addSubview:self.stockCodeLabel];
    [self.contentView addSubview:self.boardLabel];
    [self.contentView addSubview:self.fieldLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.lineView];
    
    CGFloat margin = (SCREENW - 34 - 55 * 4) / 3.0;
    CGFloat w = 55 + margin;
    
    [self.stockNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(17);
        make.top.mas_equalTo(self.contentView.mas_top).offset(12);
        make.width.mas_equalTo(w-29);
        make.height.mas_greaterThanOrEqualTo(16);
    }];
    
    [self.stockCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.stockNameLabel.mas_bottom).offset(4);
        make.left.mas_equalTo(self.stockNameLabel);
        make.height.mas_equalTo(13);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(17);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-17);
        make.top.mas_equalTo(self.stockCodeLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    CGFloat left = 17;
    left = left + w;
    [self.boardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left);
        make.top.mas_equalTo(self.stockNameLabel.mas_top);
        make.width.mas_equalTo(w-29);
        make.height.mas_greaterThanOrEqualTo(16);
    }];
    
    left = left + w;
    [self.fieldLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left);
        make.top.mas_equalTo(self.stockNameLabel.mas_top);
        make.width.mas_equalTo(w-29);
        make.height.mas_greaterThanOrEqualTo(16);
    }];
    
    left = left + w - 12;
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left);
        make.top.mas_equalTo(self.stockNameLabel.mas_top);
        make.width.mas_equalTo(w-29);
        make.height.mas_greaterThanOrEqualTo(16);
    }];
}
- (void)setIpoModel:(SmarketEventModel *)ipoModel {
    _ipoModel = ipoModel;
    
    self.stockNameLabel.text = ipoModel.ipo_short;
    self.stockCodeLabel.text = ipoModel.ipo_code;
    
    self.boardLabel.text = ipoModel.shangshididian;
    self.fieldLabel.text = ipoModel.hangye1;
    
    NSMutableString *str = [[NSMutableString alloc] initWithString:ipoModel.listing_time];
    
//    [str replaceCharactersInRange:NSMakeRange(4, 1) withString:@"\n"];
    self.timeLabel.text = [str stringByReplacingOccurrencesOfString:@"-" withString:@"."];;
}
#pragma mark - Getter
- (UILabel *)stockNameLabel {
    if (!_stockNameLabel) {
        _stockNameLabel = [[UILabel alloc] init];
        _stockNameLabel.font = [UIFont systemFontOfSize:13];
        _stockNameLabel.textColor = BLUE_TITLE_COLOR;
        _stockNameLabel.numberOfLines = 0;
    }
    return _stockNameLabel;
}
- (UILabel *)stockCodeLabel {
    if (!_stockCodeLabel) {
        _stockCodeLabel = [[UILabel alloc] init];
        _stockCodeLabel.font = [UIFont systemFontOfSize:13];
        _stockCodeLabel.textColor = COLOR2D343A;
    }
    return _stockCodeLabel;
}
- (UILabel *)boardLabel {
    if (!_boardLabel) {
        _boardLabel = [[UILabel alloc] init];
        _boardLabel.font = [UIFont systemFontOfSize:13];
        _boardLabel.textColor = COLOR2D343A;
        _boardLabel.numberOfLines = 2;
    }
    return _boardLabel;
}
- (UILabel *)fieldLabel {
    if (!_fieldLabel) {
        _fieldLabel = [[UILabel alloc] init];
        _fieldLabel.font = [UIFont systemFontOfSize:13];
        _fieldLabel.textColor = COLOR2D343A;
    }
    return _fieldLabel;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = COLOR2D343A;
        _timeLabel.numberOfLines = 2;
    }
    return _timeLabel;
}
- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] init];
        _lineView.backgroundColor = F5COLOR;
        _lineView.frame = CGRectMake(17, 78, SCREENW-34, 1);
    }
    return _lineView;
}
@end

@interface QMPIPOLibraryTableHeaderView ()
@property (nonatomic, strong) UILabel *stockCodeLabel;
@property (nonatomic, strong) UILabel *boardLabel;
@property (nonatomic, strong) UILabel *fieldLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@end
@implementation QMPIPOLibraryTableHeaderView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    self.backgroundColor = TABLEVIEW_COLOR;
    
    [self addSubview:self.stockCodeLabel];
    [self addSubview:self.boardLabel];
    [self addSubview:self.fieldLabel];
    [self addSubview:self.timeLabel];
    
    CGFloat margin = 40;
    CGFloat w = 55;
    margin = (SCREENW - 34 - w * 4) / 3.0;
    
    self.stockCodeLabel.frame = CGRectMake(17, 0, w, 40);
    self.boardLabel.frame = CGRectMake(17+(w+margin), 0, w, 40);
    self.fieldLabel.frame = CGRectMake(17+(w+margin)*2, 0, w, 40);
    self.timeLabel.frame = CGRectMake(17+(w+margin)*3-12, 0, w, 40);
}
- (UILabel *)stockCodeLabel {
    if (!_stockCodeLabel) {
        _stockCodeLabel = [[UILabel alloc] init];
        _stockCodeLabel.font = [UIFont systemFontOfSize:13];
        _stockCodeLabel.textColor = H9COLOR;
        _stockCodeLabel.text = @"股票代码";
    }
    return _stockCodeLabel;
}
- (UILabel *)boardLabel {
    if (!_boardLabel) {
        _boardLabel = [[UILabel alloc] init];
        _boardLabel.font = [UIFont systemFontOfSize:13];
        _boardLabel.textColor = H9COLOR;
        _boardLabel.text = @"交易板块";
    }
    return _boardLabel;
}
- (UILabel *)fieldLabel {
    if (!_fieldLabel) {
        _fieldLabel = [[UILabel alloc] init];
        _fieldLabel.font = [UIFont systemFontOfSize:13];
        _fieldLabel.textColor = H9COLOR;
        _fieldLabel.text = @"行业领域";
    }
    return _fieldLabel;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = H9COLOR;
        _timeLabel.text = @"上市时间";
    }
    return _timeLabel;
}
@end
