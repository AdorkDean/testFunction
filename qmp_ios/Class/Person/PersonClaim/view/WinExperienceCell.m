//
//  WinExperienceCell.m
//  qmp_ios
//
//  Created by QMP on 2018/4/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "WinExperienceCell.h"
@interface WinExperienceCell()
{
    __weak IBOutlet UILabel *_winNameLab;
    
    __weak IBOutlet UILabel *_winTimeLab;

}
@end


@implementation WinExperienceCell

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.editBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:5];
    [self.editBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
}

- (void)setExperienceM:(WinExperienceModel *)experienceM{
 
    _experienceM = experienceM;
    
    if (![PublicTool isNull:_experienceM.winning]) {
        UIFont *font;
        if (@available(iOS 8.2, *)) {
            font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        }else{
            font = [UIFont systemFontOfSize:13];
        }
        
        NSAttributedString * winAttStr = [_experienceM.winning stringWithParagraphlineSpeace:6 textColor:H27COLOR textFont:font];
        _winNameLab.attributedText = winAttStr;
    }else{
        _winNameLab.text = experienceM.winning;
    }
    
    _winTimeLab.text = [NSString stringWithFormat:@"%@ %@",![PublicTool isNull:experienceM.awards]?experienceM.awards:@"-",experienceM.time];
    
    self.editBtn.hidden = YES;
}


@end
