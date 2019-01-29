//
//  SearchPersonCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MySearchPersonCellByXib.h"

@implementation MySearchPersonCellByXib

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _iconImgV.layer.cornerRadius = 21.5;
    _iconImgV.layer.masksToBounds = YES;
    _iconImgV.layer.borderWidth = 0.5;
    _iconImgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImgV.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.renlingTagLbl labelWithFontSize:12 textColor:BLUE_TITLE_COLOR cornerRadius:1.5 borderWdith:0.5 borderColor:BLUE_BG_COLOR];
    
    self.claimLab.layer.cornerRadius = 11;
    self.claimLab.layer.masksToBounds = YES;
    self.claimLab.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
    self.claimLab.layer.borderWidth = 0.5;
    self.claimLab.backgroundColor  = BLUE_TITLE_COLOR;
    self.claimLab.textColor = [UIColor whiteColor];
    
    
    _firstNaLab.layer.cornerRadius = 21.5;
    _firstNaLab.layer.masksToBounds = YES;
}

-(void)setSearchPerson:(SearchPerson *)searchPerson{
    _searchPerson = searchPerson;
    
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:searchPerson.icon] placeholderImage:[UIImage imageNamed:@"heading"]];
    _nameLab.text = searchPerson.name;
    
    NSString *company;
    
    NSString *str;
    if (searchPerson.zhiwei.count) {
        ZhiWeiModel *zhiwei = searchPerson.zhiwei[0];
        company = zhiwei.name;
        str = zhiwei.zhiwu;
    }
    if (searchPerson.claim_type.integerValue == 2) {
        self.renlingTagLbl.hidden = NO;
        self.claimBtn.hidden = NO;
    }else{
        self.renlingTagLbl.hidden = YES;
        self.claimBtn.hidden = YES;
    }
    
    _companyLab.text = [PublicTool isNull:company] ? @"-":company;
    _zhiwuLab.text = [PublicTool isNull:str] ? @"-":str;
}

- (void)setPerson:(PersonModel *)person{
    
    _person = person;
    
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:person.icon] placeholderImage:[UIImage imageNamed:@"heading"]];
    _nameLab.text = person.name;
    
    NSString *company;
    
    NSString *str;
    if (person.work_exp.count) {
        ZhiWeiModel *zhiwei = person.work_exp[0];
        company = zhiwei.name;
        str = zhiwei.zhiwu;
    }
    if (person.claim_type.integerValue == 2) {
        self.renlingTagLbl.hidden = NO;
        self.claimBtn.hidden = NO;
    }else{
        self.renlingTagLbl.hidden = YES;
        self.claimBtn.hidden = YES;
    }
    
    _companyLab.text = [PublicTool isNull:company] ? @"-":company;
    _zhiwuLab.text = [PublicTool isNull:str] ? @"-":str;
}


- (void)setNametitColor:(UIColor *)nametitColor{
    
    if ([PublicTool isNull:self.person.icon] || [self.person.icon isEqualToString:@"http://img.798youxi.com/product/upload/5a265f11811c9.png"]) {
        self.firstNaLab.hidden = NO;
        self.firstNaLab.backgroundColor = nametitColor;
        if (![PublicTool isNull:self.person.name]) {
            self.firstNaLab.text = [self.person.name substringToIndex:1];
        }
    }else{
        self.firstNaLab.hidden = YES;
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
