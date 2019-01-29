//
//  CompanyZhaopinCell.m
//  qmp_ios
//
//  Created by QMP on 2018/2/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CompanyZhaopinCell.h"

@interface CompanyZhaopinCell()
{
    __weak IBOutlet UILabel *_dateLab;
    __weak IBOutlet UILabel *_zhiweiLab;
    __weak IBOutlet UILabel *_salaryLab;
    __weak IBOutlet UILabel *_cityLab;
    __weak IBOutlet UILabel *_experienceLab;
    
}
@end

@implementation CompanyZhaopinCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(ZhaopinModel *)model{
    _model = model;
    _zhiweiLab.text = model.title;
    _dateLab.text = [PublicTool isNull:model.zhiwei_updatetime]?model.start_date:model.zhiwei_updatetime;
    
//    _salaryLab.text = [NSString stringWithFormat:@"薪资：%@", model.ori_salary];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"薪资：%@",model.ori_salary]
                                                                            attributes:@{NSFontAttributeName: _salaryLab.font,
                                                                                         NSForegroundColorAttributeName: COLOR737782,
                                                                                         }];
//    [str addAttributes:@{NSForegroundColorAttributeName: COLOR737782,} range:NSMakeRange(0, 3)];
    
    _salaryLab.attributedText = str;
    _cityLab.text = model.city;
    _experienceLab.text = model.experience;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
