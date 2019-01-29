//
//  CompanyFinancialHeaderView.m
//  qmp_ios
//
//  Created by QMP on 2018/5/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CompanyFinancialHeaderView.h"
#import "FinanicalNeedModel.h"
@implementation CompanyFinancialHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
}
- (void)setNeedModel:(FinanicalNeedModel *)needModel {
    _needModel = needModel;
    self.lunciLabel.text = [PublicTool nilStringReturn:_needModel.need_lunci];
    
    NSMutableString *mStr = [NSMutableString string];
    if (![PublicTool isNull:_needModel.need_money]) {
        if (![PublicTool isNull:_needModel.unit]) {
            [mStr appendString:[self fixMoneyType:_needModel.unit]];
        }
        [mStr appendString:_needModel.need_money];
    }
    self.moneyLabel.text = mStr;
    
    self.userLabel.text = _needModel.sponsor;//[PublicTool nilStringReturn:_needModel.sponsor];
    
    self.scaleLabel.text = _needModel.bili;//[PublicTool nilStringReturn:_needModel.bili];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:(_needModel.bright_spot.length>0?_needModel.bright_spot:@"")
                                                                            attributes:@{NSFontAttributeName:self.advantageLabel.font,
                                                                                         NSParagraphStyleAttributeName:style,
                                                                                         NSForegroundColorAttributeName: NV_TITLE_COLOR,
                                                                                         }];
    self.advantageLabel.attributedText = str;
    
//    self.contactButton.hidden = (needModel.sponsor_phone.length <= 0);
    if (needModel.sponsor_phone.length > 0) {
        [self.contactButton setTitle:needModel.sponsor_phone forState:UIControlStateNormal];
    } else {
        [self.contactButton setTitle:@"" forState:UIControlStateNormal];
    }
    self.zhiweiLabel.text = needModel.sponsor_position;

    [self.bpButton setTitle:_needModel.bp_name forState:UIControlStateNormal];
    
}
- (NSString *)fixMoneyType:(NSString *)type {
    NSDictionary *dict = @{@"人民币":@"￥",@"欧元":@"€",@"美元":@"$",@"英镑":@"£",@"日元":@"J￥",@"新台币":@"NT",@"港币":@"HKD"};
    return dict[type]?dict[type]:type;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
}

@end
