//
//  ProductValueActivityCell.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/8/7.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductValueActivityCell.h"

@implementation ProductValueActivityCell

+ (instancetype)productValueActivityCellWithTableView:(UITableView *)tableView {
    ProductValueActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductValueActivityCellID"];
    if (!cell) {
        cell = [[[BundleTool commonBundle] loadNibNamed:@"ProductValueActivityCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _contentLabel.textColor = COLOR2D343A;
    _dateLabel.textColor = H9COLOR;
    _contentLabel.hidden = YES;
    [self.contentView addSubview:self.label];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (YYLabel *)label {
    if (!_label) {
        _label = [YYLabel new];
        _label.font = [UIFont systemFontOfSize:14];
        _label.numberOfLines = 2;
    }
    return _label;
}
@end
