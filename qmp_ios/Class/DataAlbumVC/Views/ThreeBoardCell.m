//
//  ThreeBoardCell.m
//  qmp_ios
//
//  Created by QMP on 2018/4/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ThreeBoardCell.h"

@interface ThreeBoardCell()
{
    __weak IBOutlet UILabel *_codeLab;
    __weak IBOutlet UILabel *_jianchengLab;
    __weak IBOutlet UILabel *_hangyeLab;
    
    __weak IBOutlet UILabel *_guzhiLab;
    __weak IBOutlet UILabel *_shizhiLab;
    __weak IBOutlet UILabel *_timeLab;
}
@end
@implementation ThreeBoardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _jianchengLab.textColor = BLUE_TITLE_COLOR;
    _jianchengLab.userInteractionEnabled = YES;
    [_jianchengLab addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterDetailVC)]];
    _jianchengLab.textColor = BLUE_TITLE_COLOR;
}

- (void)setSmarketModel:(SmarketEventModel *)smarketModel{
    
    _smarketModel = smarketModel;
    _codeLab.text = smarketModel.ipo_code;
    _jianchengLab.text = smarketModel.ipo_short;
    if ([PublicTool isNull:smarketModel.gujia] || [smarketModel.gujia isEqualToString:@"0.0"]) {
        _guzhiLab.text = @"-";
    }else{
        _guzhiLab.text = smarketModel.gujia;
    }
    _hangyeLab.text = smarketModel.hangye1;
    _shizhiLab.text = [PublicTool nilStringReturn:smarketModel.valuations_money];
    _timeLab.text = [smarketModel.listing_time stringByReplacingOccurrencesOfString:@"-" withString:@"."];
}

- (void)enterDetailVC{
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    NSDictionary *param = [PublicTool toGetDictFromStr:_smarketModel.detail];
    [[AppPageSkipTool shared] appPageSkipToProductDetail:param];
    [QMPEvent event:@"home_threeBoard_cellClick"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
