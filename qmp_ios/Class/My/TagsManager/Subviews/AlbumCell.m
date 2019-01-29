//
//  AlbumCell.m
//  qmp_ios
//
//  Created by QMP on 2017/11/2.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "AlbumCell.h"

@implementation AlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.line.backgroundColor = LIST_LINE_COLOR;
//    self.lineHeight.constant = 1;
    
    self.nameLabel.textColor = NV_TITLE_COLOR;
    
    self.chooseBtn.userInteractionEnabled = NO;
    [self.chooseBtn setImage:nil forState:UIControlStateNormal];
    [self.chooseBtn setImage:[UIImage imageNamed:@"selected_album"] forState:UIControlStateSelected];
}

-(void)setItem:(TagsItem *)item{
    _item = item;

    NSString *title = [NSString stringWithFormat:@"%@ (%@)",item.tag,item.product_num];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:title];
    [attText addAttributes:@{NSForegroundColorAttributeName:H5COLOR,NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(title.length-item.product_num.length-2, item.product_num.length+2)];
    
    self.nameLabel.attributedText = attText;
    self.chooseBtn.selected = item.choosed.integerValue == 1 ? YES:NO;
    if (item.choosed.integerValue == 1) {
        self.contentView.backgroundColor = H568COLOR;
    }else{
        self.contentView.backgroundColor = [UIColor whiteColor];

    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
