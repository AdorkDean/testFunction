//
//  IPOEventCell.m
//  qmp_ios
//
//  Created by QMP on 2018/3/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "IPOEventCell.h"

@interface IPOEventCell()
{
    
    __weak IBOutlet UILabel *_codeLab;
    __weak IBOutlet UILabel *_companyLab;
    __weak IBOutlet UILabel *_hangyeLab;
    __weak IBOutlet UILabel *_jiaoyisuoLab;
    __weak IBOutlet UILabel *_timeLab;
}
@end


@implementation IPOEventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _companyLab.userInteractionEnabled = YES;
    _companyLab.textColor = BLUE_TITLE_COLOR;
}


- (void)setSmarketModel:(SmarketEventModel *)smarketModel{
    _smarketModel = smarketModel;
    _codeLab.text = smarketModel.ipo_code;
    _companyLab.text = smarketModel.ipo_short;
    _jiaoyisuoLab.text = smarketModel.shangshididian;
    _timeLab.text = [smarketModel.listing_time stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    _hangyeLab.text = smarketModel.hangye1;
    [_companyLab addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterCompany)]];

}

- (void)enterCompany{
    
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    NSDictionary *param = [PublicTool toGetDictFromStr:_smarketModel.detail];
    [[AppPageSkipTool shared] appPageSkipToProductDetail:param];
    [QMPEvent event:@"home_ssk_cellClick"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
