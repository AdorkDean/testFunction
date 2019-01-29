//
//  SearchPersonCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SearchPersonCell.h"
#import "SearchPerson.h"
#import "SearchHighlightMedia.h"
@implementation SearchPersonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _iconImgV.layer.cornerRadius = 21.5;
    _iconImgV.layer.masksToBounds = YES;
    _iconImgV.layer.borderWidth = 0.5;
    _iconImgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
//    _iconImgV.contentMode = UIViewContentModeScaleAspectFit;

    self.claimBtn.layer.cornerRadius = 11;
    self.claimBtn.layer.masksToBounds = YES;
    self.claimBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
    self.claimBtn.layer.borderWidth = 0.5;
    
    _firstNaLab.layer.cornerRadius = 21.5;
    _firstNaLab.layer.masksToBounds = YES;
    
    _companyLab.textColor = COLOR737782;
    _zhiwuLab.textColor = COLOR737782;
    
    self.searchReasonLabel.hidden = YES;
}


- (void)setPerson:(PersonModel *)person{
    
    _person = person;
    
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:person.icon] placeholderImage:[BundleTool imageNamed:@"heading"]];
    _nameLab.text = person.name;
    
    NSString *company;
    
    NSString *str;
    if (person.work_exp.count) {
        ZhiWeiModel *zhiwei = person.work_exp[0];
        company = zhiwei.name;
        str = zhiwei.zhiwu;
    }
        
    _companyLab.text = [PublicTool isNull:company] ? @"-":company;
    
    _zhiwuLab.text = [PublicTool isNull:str] ? @"-":str;
    
    _companyLab.textColor = H9COLOR;
    _nameLab.textColor = COLOR2D343A;
    self.searchReasonLabel.hidden = YES;
    }
- (void)showMatchReason {
    id s = self.person.match_reason;
    if (self.person.match_reason && [s isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)s;

        if (str.length == 0) {
            return;
        }

        NSInteger index = [str rangeOfString:@":"].location + 1;
    NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc] initWithString:str
                                                                             attributes:@{
                                                                                          NSFontAttributeName: self.searchReasonLabel.font,
                                                                                          NSForegroundColorAttributeName: COLOR737782,
                                                                                          }];
    [mstr addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:NSMakeRange(index, str.length-index)];
    self.searchReasonLabel.attributedText = mstr;
    self.searchReasonLabel.hidden = NO;
    }
}

- (void)setNametitColor:(UIColor *)nametitColor{
    _nametitColor = nametitColor;
    if ([PublicTool isNull:self.person?self.person.icon:self.person2.icon]) {
        self.firstNaLab.hidden = NO;
        self.firstNaLab.backgroundColor = nametitColor;
        if (![PublicTool isNull:self.person?self.person.name:self.person2.name]) {
            self.firstNaLab.text = [self.person?self.person.name:self.person2.name substringToIndex:1];
        }
    }else{
        self.firstNaLab.hidden = YES;
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setPerson2:(SearchPerson *)person2 {
    _person2 = person2;
    
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:person2.icon] placeholderImage:[BundleTool imageNamed:@"heading"]];
    
    self.nameLab.text = person2.name;
    
    if ([PublicTool isNull:person2.icon]) {
        self.firstNaLab.hidden = NO;
        self.firstNaLab.backgroundColor = self.nametitColor;
        if (![PublicTool isNull:self.person2.name]) {
            self.firstNaLab.text = [self.person2.name substringToIndex:1];
        }
    }else{
        self.firstNaLab.hidden = YES;
    }
    
    
    NSString *company;
    
    NSString *str;
    if (person2.zhiwei.count) {
        ZhiWeiModel *zhiwei = person2.zhiwei[0];
        company = zhiwei.name;
        str = zhiwei.zhiwu;
    }
    
    _companyLab.text = [PublicTool isNull:company] ? @"-":company;
    
    _zhiwuLab.text = [PublicTool isNull:str] ? @"-":str;
    
    _companyLab.textColor = COLOR737782;
    _nameLab.textColor = COLOR2D343A;
    self.searchReasonLabel.hidden = YES;
    if ([person2 needShowReason]) {
        self.searchReasonLabel.hidden = NO;
        [self showMatchReason2];
    }
    
    if (person2.highlightMedia && [person2.highlightMedia.displayText isEqualToString:person2.name]) {
        NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc] initWithString:person2.highlightMedia.displayText
                                                                                 attributes:@{
                                                                                              NSFontAttributeName:self.nameLab.font,
                                                                                              NSForegroundColorAttributeName: COLOR2D343A
                                                                                              }];
        for (SearchHighlightMediaItem *item in person2.highlightMedia.items) {
            [mstr addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:item.range];
        }
        self.nameLab.attributedText = mstr;
    }
    
    if (person2.highlightMedia2 && ![PublicTool isNull:company] && [company isEqualToString:person2.highlightMedia2.displayText]) {
        NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc] initWithString:person2.highlightMedia2.displayText
                                                                                 attributes:@{
                                                                                              NSFontAttributeName:self.companyLab.font,
                                                                                              NSForegroundColorAttributeName: COLOR737782
                                                                                              }];
        for (SearchHighlightMediaItem *item in person2.highlightMedia2.items) {
            [mstr addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:item.range];
        }
        self.companyLab.attributedText = mstr;
    }
    
}
- (void)showMatchReason2 {
    id s = self.person2.match_reason;
    if (self.person2.match_reason && [s isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)s;
        if (str.length == 0) {
            return;
        }
        
        NSInteger index = [str rangeOfString:@":"].location + 1;
        NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc] initWithString:str
                                                                                 attributes:@{
                                                                                              NSFontAttributeName: self.searchReasonLabel.font,
                                                                                              NSForegroundColorAttributeName: COLOR737782,
                                                                                              }];
        [mstr addAttribute:NSForegroundColorAttributeName value:BLUE_TITLE_COLOR range:NSMakeRange(index, str.length-index)];
        self.searchReasonLabel.attributedText = mstr;
        
    }
    
}
@end
