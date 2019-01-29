//
//  LeadCardCell.m
//  qmp_ios
//
//  Created by QMP on 2018/4/11.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "LeadCardCell.h"

@interface LeadCardCell()
@property(nonatomic,strong)UILabel *nameLab;

@end

@implementation LeadCardCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor whiteColor];
        [self addView];
    }
    return self;
}

- (void)addView{
    self.nameLab =  [[UILabel alloc]initWithFrame:CGRectMake(17, 0, SCREENW - 17 - 55, 50)];
    [_nameLab labelWithFontSize:16 textColor:NV_TITLE_COLOR];
    [self.contentView addSubview:_nameLab];
    
    self.line = [[UIView alloc]initWithFrame:CGRectMake(17, 49, SCREENW - 34, 1)];
    self.line.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:self.line];
    
    _selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 50, 0, 55, 50)];
    [self.contentView addSubview:_selectBtn];
    [_selectBtn setImage:[UIImage imageNamed:@"noselect_workFlow"] forState:UIControlStateNormal];
    [_selectBtn setImage:[UIImage imageNamed:@"select_workFlow"] forState:UIControlStateSelected];

}

-(void)setCardItem:(CardItem *)cardItem{
    
    _cardItem = cardItem;
    if ([PublicTool isNull:cardItem.cardName]) {
        self.nameLab.text = [PublicTool isNull:cardItem.phone] ? @"-":cardItem.phone;
    }else{
        self.nameLab.text = [NSString stringWithFormat:@"%@  %@",cardItem.cardName,cardItem.company];
    }
    self.selectBtn.selected = cardItem.selected;
}

- (void)refreshContactInfo:(CardItem*)cardItem{
    
    _cardItem = cardItem;
    if ([PublicTool isNull:cardItem.contacts]) {
        self.nameLab.text = [PublicTool isNull:cardItem.telephone] ? @"-":cardItem.telephone;
    }else{
        self.nameLab.text = [NSString stringWithFormat:@"%@  %@",cardItem.contacts,![PublicTool isNull:cardItem.product]?cardItem.product:@""];
    }
    self.selectBtn.selected = cardItem.selected;
    
}

- (void)refreshFriendInfo:(FriendModel*)friendM{
    if ([PublicTool isNull:friendM.nickname]) {
        self.nameLab.text = [PublicTool isNull:friendM.bind_phone] ? @"-":friendM.bind_phone;
    }else{
        self.nameLab.text = [NSString stringWithFormat:@"%@  %@",![PublicTool isNull:friendM.nickname]?friendM.nickname:@"",![PublicTool isNull:friendM.company]?friendM.company:@""];
    }
    self.selectBtn.selected = [friendM.selected boolValue];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
