//
//  PersonInvestCaseCollectionViewCell.m
//  qmp_ios
//
//  Created by QMP on 2018/9/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonInvestCaseCollectionViewCell.h"


#import "PersonTouziModel.h"

@implementation PersonInvestCaseCollectionViewCell
+ (instancetype)cellWithCollectionView:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath{
    PersonInvestCaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PersonInvestCaseCollectionViewCellID" forIndexPath:indexPath];
    //    cell.iconLabel.hidden = YES;
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.iconView.layer.cornerRadius = 4;
    self.iconView.layer.borderColor = [BORDER_LINE_COLOR CGColor];
    self.iconView.layer.borderWidth = 0.5;
    self.iconView.clipsToBounds = YES;
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.iconLabel.layer.cornerRadius = 4;
    self.iconLabel.clipsToBounds = YES;
    
    [_roundLabel labelWithFontSize:10 textColor:BLUE_TITLE_COLOR cornerRadius:2];
    _roundLabel.backgroundColor = LABEL_BG_COLOR;
    
    _nameLabel.textColor = COLOR2D343A;
    _industryLabel.textColor = H9COLOR;
    _businessLabel.textColor = COLOR737782;
    
}

- (void)setPersonTzM:(PersonTouziModel *)personTzM{
    _personTzM = personTzM;
    
    self.iconLabel.hidden = YES;
    if (![PublicTool isNull:personTzM.icon]) {
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:personTzM.icon]];
    } else {
        self.iconLabel.hidden = NO;
    }
    self.nameLabel.text = personTzM.product;
    
    self.roundLabel.text = personTzM.lunci;
    self.roundLabel.hidden = [PublicTool isNull:personTzM.lunci];
    
    self.industryLabel.text = personTzM.hangye;
    self.businessLabel.text = personTzM.yewu;
    
    self.investInfoLabel.text = @"";
    if (![PublicTool isNull:personTzM.lunci]) {
        //时间处理
        NSMutableArray *arr;
        if ([personTzM.valuations_time containsString:@"."]) {
            arr = [NSMutableArray arrayWithArray:[personTzM.valuations_time componentsSeparatedByString:@"."]];
            [arr removeLastObject]; //删除日期中的日
            
        }else if([personTzM.valuations_time length] > 0){
            arr = [NSMutableArray arrayWithObjects:personTzM.valuations_time, nil];
        }else{
            arr = [NSMutableArray array];
        }
        NSMutableString *timeStr = [NSMutableString string];
        for (NSString *str in arr) {
            if (str.length == 1) {
                [timeStr appendString:[NSString stringWithFormat:@".%@%@",@"0",str]];
            }else{
                [timeStr appendString:[NSString stringWithFormat:@".%@",str]];
            }
        }
        if (timeStr.length) {
            [timeStr deleteCharactersInRange:NSMakeRange(0, 1)];
        }
        
        NSString *rowStr;
        
        if ([PublicTool isNull:personTzM.valuations_money] && [PublicTool isNull:personTzM.valuations_time]) {
            rowStr = @"";
        }else if (![PublicTool isNull:personTzM.valuations_time]) {
            rowStr = [NSString stringWithFormat:@"%@  %@  %@",timeStr,personTzM.lunci,personTzM.valuations_money];
            
        }else{
            rowStr = [NSString stringWithFormat:@"%@  %@",personTzM.lunci,personTzM.valuations_money];
        }
        
        self.investInfoLabel.text = rowStr;
    }
    
}
@end

