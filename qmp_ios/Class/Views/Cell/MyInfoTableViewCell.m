//
//  MyInfoTableViewCell.m
//  qmp_ios
//
//  Created by molly on 2017/3/20.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "MyInfoTableViewCell.h"
@interface MyInfoTableViewCell()

@end
@implementation MyInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.keyLbl.textColor = NV_TITLE_COLOR;
    self.valueLbl.textColor = COLOR737782;
    self.rightImgV.image = [BundleTool imageNamed:@"me_headRightArrow"];
    [self.contentView addSubview:self.lineV];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initDataWithKey:(NSString *)key withValue:(NSString *)value{

    _keyLbl.text = key;
    if (![PublicTool isNull:value]) {
        _valueLbl.text = value;

    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.lineV.frame = CGRectMake(17, self.contentView.height-0.5, SCREENW-17, 0.5);
}

- (UIView *)lineV {
    if (!_lineV) {
        _lineV = [[UIView alloc] init];
        _lineV.backgroundColor = LIST_LINE_COLOR;
    }
    return _lineV;
}
@end
