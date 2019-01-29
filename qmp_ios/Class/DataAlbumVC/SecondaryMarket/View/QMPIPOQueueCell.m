//
//  QMPIPOQueueCell.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/9/5.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPIPOQueueCell.h"
#import "IPOModel.h"
@interface QMPIPOQueueCell ()
@property (nonatomic, strong) UILabel *companyLabel;
@property (nonatomic, strong) UILabel *boardLabel;
@property (nonatomic, strong) UILabel *fieldLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIImageView *lineView;
@end

@implementation QMPIPOQueueCell
+ (instancetype)ipoQueueCellWithTableView:(UITableView *)tableView {
    QMPIPOQueueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMPIPOQueueCellID"];
    if (!cell) {
        cell = [[QMPIPOQueueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QMPIPOQueueCellID"];
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
    [self.contentView addSubview:self.companyLabel];
    [self.contentView addSubview:self.boardLabel];
    [self.contentView addSubview:self.fieldLabel];
    [self.contentView addSubview:self.stateLabel];
    [self.contentView addSubview:self.lineView];
    

    CGFloat headerItemW = 55;
    CGFloat margin = (SCREENW - 34 - headerItemW * 4) / 3.0;

    CGFloat fixW = headerItemW+margin;
    self.companyLabel.frame = CGRectMake(17, 0, fixW-29, 78);
    self.boardLabel.frame = CGRectMake(17+fixW, 0, fixW-29, 78);
    self.fieldLabel.frame = CGRectMake(17+fixW*2, 0, fixW-29, 78);
    self.stateLabel.frame = CGRectMake(17+fixW*3, 0, headerItemW+3, 78);
}
- (void)setIpoModel:(IPOModel *)ipoModel {
    _ipoModel = ipoModel;
    
    self.companyLabel.text = ipoModel.company;
    self.boardLabel.text = [self boardWithPlace:ipoModel.shangshididian];
    self.fieldLabel.text = ipoModel.hangye1;
    self.stateLabel.text = ipoModel.now_status;

}
- (NSString *)boardWithPlace:(NSString *)place {
    NSDictionary *dict = @{@"上交所":@"主板", @"深交所中小板":@"中小板", @"深交所创业板":@"创业板"};
    return dict[place]?:place;
}
#pragma mark - Getter
- (UILabel *)companyLabel {
    if (!_companyLabel) {
        _companyLabel = [[UILabel alloc] init];
        _companyLabel.font = [UIFont systemFontOfSize:13];
        _companyLabel.textColor = COLOR2D343A;
        _companyLabel.numberOfLines = 3;
    }
    return _companyLabel;
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
        _fieldLabel.numberOfLines = 2;
    }
    return _fieldLabel;
}
- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = [UIFont systemFontOfSize:13];
        _stateLabel.textColor = COLOR2D343A;
        _stateLabel.numberOfLines = 2;
    }
    return _stateLabel;
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






const CGFloat IPOQueueHeaderViewTextWidth = 55;
@interface QMPIPOQueueTableHeaderView ()
@property (nonatomic, strong) UILabel *companyLabel;
@property (nonatomic, strong) UILabel *boardLabel;
@property (nonatomic, strong) UILabel *fieldLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@end
@implementation QMPIPOQueueTableHeaderView
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
    
    [self addSubview:self.companyLabel];
    [self addSubview:self.boardLabel];
    [self addSubview:self.fieldLabel];
    [self addSubview:self.stateLabel];
    
    CGFloat margin = 40;
    CGFloat w = IPOQueueHeaderViewTextWidth;
    margin = (SCREENW - 34 - w * 4) / 3.0;
    
    self.companyLabel.frame = CGRectMake(17, 0, w, 40);
    self.boardLabel.frame = CGRectMake(17+(w+margin), 0, w, 40);
    self.fieldLabel.frame = CGRectMake(17+(w+margin)*2, 0, w, 40);
    self.stateLabel.frame = CGRectMake(17+(w+margin)*3, 0, w, 40);
}
- (UILabel *)companyLabel {
    if (!_companyLabel) {
        _companyLabel = [[UILabel alloc] init];
        _companyLabel.font = [UIFont systemFontOfSize:13];
        _companyLabel.textColor = H9COLOR;
        _companyLabel.text = @"申报企业";
    }
    return _companyLabel;
}
- (UILabel *)boardLabel {
    if (!_boardLabel) {
        _boardLabel = [[UILabel alloc] init];
        _boardLabel.font = [UIFont systemFontOfSize:13];
        _boardLabel.textColor = H9COLOR;
        _boardLabel.text = @"申报板块";
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
- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = [UIFont systemFontOfSize:13];
        _stateLabel.textColor = H9COLOR;
        _stateLabel.text = @"审核状态";
    }
    return _stateLabel;
}
@end
