//
//  SearchOrganizeCell.m
//  qmp_ios
//
//  Created by QMP on 2018/8/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SearchOrganizeCell.h"
#import "SearchOrganize.h"
#import "SearchHighlightMedia.h"
@implementation SearchOrganizeCell

+ (instancetype)searchOrganizeCellWithTableView:(UITableView *)tableView {
    SearchOrganizeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchOrganizeCellID"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchOrganizeCell" owner:nil options:nil] firstObject];
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
    
    self.badgeLabel.backgroundColor = LABEL_BG_COLOR;
    self.badgeLabel.layer.cornerRadius = 2;
    self.badgeLabel.clipsToBounds = YES;
    self.badgeLabel.text = [NSString stringWithFormat:@" 投资部门 "];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setOrganize:(SearchOrganize *)organize {
    _organize = organize;
    
    if (![PublicTool isNull:organize.icon]) {
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:organize.icon]];
    } else {
        
    }
    
    self.nameLabel.text = organize.jigou_name;
    
    self.descLabel.text = organize.jianjie;
    
    
    self.badgeLabel.hidden = YES;
    if ([organize.jg_type containsString:@"知名企业"] && ![organize.jigou_name containsString:@"基金"] && ![organize.jigou_name containsString:@"投资"]) {
        self.badgeLabel.hidden = NO;
    }
    
    self.reasonLabel.hidden = YES;
    if ([organize needShowReason]) {
        self.reasonLabel.hidden = NO;
        [self showMatchReason];
    }
    
    
    self.nameLabel.textColor = COLOR2D343A;
    if (organize.highlightMedia && [organize.highlightMedia.displayText isEqualToString:organize.jigou_name]) {
        NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc] initWithString:organize.highlightMedia.displayText
                                                                                 attributes:@{
                                                                                              NSFontAttributeName:self.nameLabel.font,
                                                                                              NSForegroundColorAttributeName: COLOR2D343A
                                                                                              }];
        for (SearchHighlightMediaItem *item in organize.highlightMedia.items) {
            [mstr addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:item.range];
        }
        self.nameLabel.attributedText = mstr;
    } else {
        self.nameLabel.text = organize.jigou_name;
    }
}

- (void)showMatchReason {
    id s = self.organize.match_reason;
    NSString *str = (NSString *)s;
    if (str.length == 0) {
        return;
    }
    //匹配了名字
    if (_organize.highlightMedia && [_organize.highlightMedia.displayText isEqualToString:_organize.jigou_name]) {
        if (self.organize.match_reason && [s isKindOfClass:[NSString class]]) {
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
            
        }
    }else{
        for (SearchHighlightMediaItem *item in _organize.highlightMedia.items) {
            
            NSInteger index = [str rangeOfString:@":"].location + 1;
            NSArray *ranges = [PublicTool rangeOfSubString:item.displayText inString:str];
            if (ranges.count == 0) {
                return;
            }
            NSRange rangeValue = [ranges[0] rangeValue];
            if (rangeValue.location < index || (rangeValue.location+rangeValue.length > str.length)) {
                return;
            }
            NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc] initWithString:str
                                                                                     attributes:@{
                                                                                                  NSFontAttributeName: self.reasonLabel.font,
                                                                                                  NSForegroundColorAttributeName: COLOR737782,
                                                                                                  }];
            [mstr addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:rangeValue];
            self.reasonLabel.attributedText = mstr;
        }
    }
    
}

@end
