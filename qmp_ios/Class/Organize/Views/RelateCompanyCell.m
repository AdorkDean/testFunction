//
//  RelateCompanyCell.m
//  qmp_ios
//
//  Created by QMP on 2018/2/8.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "RelateCompanyCell.h"

@implementation RelateCompanyCell
+ (RelateCompanyCell *)cellWithTableView:(UITableView *)tableView {
    RelateCompanyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RelateCompanyCellID"];
    if (cell == nil) {
        cell = (RelateCompanyCell *)[[[NSBundle mainBundle] loadNibNamed:@"RelateCompanyCell" owner:self options:nil] lastObject];
    }
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.titleLab.layer.masksToBounds = YES;
    self.titleLab.layer.cornerRadius = 5;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _contentLab.textColor = COLOR2D343A;
}

- (void)setCompanyName:(NSString*)name titleBgColor:(UIColor*)titleBgColor{
    
    self.titleLab.backgroundColor = titleBgColor;
    
    NSAttributedString *attText = [name stringWithParagraphlineSpeace:4 textColor:NV_TITLE_COLOR textFont:[UIFont systemFontOfSize:14]];
    self.contentLab.attributedText = attText;
    self.contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
    if (![PublicTool isNull:name]) {
        self.titleLab.text = [name substringToIndex:1];
        
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
