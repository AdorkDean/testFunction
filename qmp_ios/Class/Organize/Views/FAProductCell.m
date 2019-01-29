//
//  FAProductCell.m
//  qmp_ios
//
//  Created by QMP on 2018/4/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "FAProductCell.h"

@interface FAProductCell()
{
    
    __weak IBOutlet UIImageView *_iconImgV;
    __weak IBOutlet UILabel *_nameLab;
    __weak IBOutlet UILabel *_hangyeLab;
    __weak IBOutlet UILabel *_yewuLab;
    __weak IBOutlet UILabel *_needLunciLab;
    __weak IBOutlet UILabel *_needMoneyLab;
}

@end

@implementation FAProductCell
+ (FAProductCell *)cellWithTableView:(UITableView *)tableView {
    FAProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FAProductCellID"];
    if (cell == nil) {
        cell = (FAProductCell *)[[[BundleTool commonBundle] loadNibNamed:@"FAProductCell" owner:self options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];

    _iconImgV.layer.cornerRadius = 5.0;
    _iconImgV.layer.masksToBounds = YES;
    _iconImgV.userInteractionEnabled = YES;
    [_iconImgV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterDetail)]];
    _needMoneyLab.textColor = BLUE_TITLE_COLOR;
    
    _nameLab.textColor = H3COLOR;
    _hangyeLab.textColor = H999999;
    _yewuLab.textColor = H6COLOR;
    _needLunciLab.textColor = H4COLOR;
}


- (void)setFaProductM:(OrgFaProductModel *)faProductM{

    _faProductM = faProductM;
    
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:faProductM.icon] placeholderImage:[BundleTool imageNamed:PROICON_DEFAULT]];
    _nameLab.text = faProductM.product;
    _hangyeLab.text = faProductM.hangye1;
    _yewuLab.text = faProductM.yewu;
    _needLunciLab.text = [NSString stringWithFormat:@"融资需求：%@",[PublicTool nilStringReturn:faProductM.need_lunci]];
    _needMoneyLab.text = [PublicTool isNull:faProductM.need_money]?@"":faProductM.need_money;

}

- (void)enterDetail{
    
    if ([PublicTool isNull:_faProductM.detail]) {
        return;
    }
    [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:_faProductM.detail]];

    [QMPEvent event:@"jgou_faproductClick"];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
