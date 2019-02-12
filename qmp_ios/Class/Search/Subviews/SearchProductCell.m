//
//  SearchProductCell.m
//  qmp_ios
//
//  Created by QMP on 2018/8/8.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SearchProductCell.h"
#import "SearchProduct.h"
#import "SearchHighlightMedia.h"

@implementation SearchProductCell
+ (instancetype)searchProductCellWithTableView:(UITableView *)tableView {
    SearchProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchProductCellID"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchProductCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code


    self.iconView.layer.cornerRadius = 4.0;
    self.iconView.layer.borderWidth = 1.0;
    self.iconView.layer.borderColor = [BORDER_LINE_COLOR CGColor];
    self.iconView.clipsToBounds = YES;
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.iconLabel.layer.cornerRadius = 4.0;
    self.iconLabel.clipsToBounds = YES;
    self.iconLabel.hidden = YES;
    
    self.roundLabel.backgroundColor = LABEL_BG_COLOR;
    self.roundLabel.layer.cornerRadius = 2;
    self.roundLabel.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setProduct:(SearchProduct *)product {
    _product = product;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:product.icon] placeholderImage:[UIImage imageNamed:@"product_default"]];
    
    
    // 产品
    NSString *productName = @"";
    if (![PublicTool isNull:product.product]) {
        productName = product.product;
    }else{
        productName = @"-";
    }
    self.nameLabel.text = productName;
    
    self.iconLabel.hidden = YES;
    if ([PublicTool isNull:product.icon]) {
        self.iconLabel.hidden = NO;
        if (productName.length > 0) {
            self.iconLabel.text = [productName substringToIndex:1];
        } else {
            self.iconLabel.text = @"企";
        }
    }
    
    // 轮次
    NSString *jieduan = nil;
    self.roundLabel.hidden = NO;
    if (![PublicTool isNull:product.lunci]) {
        jieduan = product.lunci;
    }else if(![PublicTool isNull:product.curlunci]){
        jieduan = product.curlunci;
    }else{
        self.roundLabel.hidden = YES;
        jieduan = @"";
    }
    self.roundLabel.text = [NSString stringWithFormat:@" %@ ", jieduan];
    
    NSString *yewu = (![PublicTool isNull:product.yewu])? product.yewu:@"";
    if ([PublicTool isNull:yewu]&&![PublicTool isNull:product.desc]) {
        yewu = product.desc;
    }
    yewu = ![PublicTool isNull:product.yewu] ? yewu:@"-";
    self.descLabel.text = yewu;

    self.reasonLabel.hidden = YES;
    if ([product needShowReason]) {
        
        [self showMatchReason];
    }
    
    self.nameLabel.textColor = COLOR2D343A;
    if (product.highlightMedia && [product.highlightMedia.displayText isEqualToString:productName]) {
        NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc] initWithString:product.highlightMedia.displayText
                                                                                 attributes:@{
                                                                                              NSFontAttributeName:self.nameLabel.font,
                                                                                              NSForegroundColorAttributeName: COLOR2D343A
                                                                                              }];
        for (SearchHighlightMediaItem *item in product.highlightMedia.items) {
            [mstr addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:item.range];
        }
        self.nameLabel.attributedText = mstr;
    } else {
        self.nameLabel.text = productName;
    }

}
- (void)showMatchReason {
    id s = self.product.match_reason;
    if (self.product.match_reason && [s isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)s;
        if (str.length == 0) {
            return;
        }
        
        NSInteger index = [str rangeOfString:@":"].location + 1;
        NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc] initWithString:str
                                                                                 attributes:@{
                                                                                              NSFontAttributeName: self.reasonLabel.font,
                                                                                              NSForegroundColorAttributeName: COLOR737782,
                                                                                              }];
        [mstr addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:NSMakeRange(index, str.length-index)];
        self.reasonLabel.attributedText = mstr;
        self.reasonLabel.hidden = NO;
    }

}
@end




