//
//  NoCommontInfoCell.m
//  qmp_ios
//
//  Created by QMP on 2018/7/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "NoCommontInfoCell.h"


@interface NoCommontInfoCell()

@property(nonatomic,copy)void(^clickAddEvent)(void);
@property(nonatomic,strong)UIButton *addBtn;

@end


@implementation NoCommontInfoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addView];
    }
    return self;
}

+(instancetype)cellWithTableView:(UITableView*)tableView clickAddBtn:(void(^)(void))clickAddEvent{

    NoCommontInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoCommontInfoCellID"];
   
    if (!cell) {
        cell = [[NoCommontInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoCommontInfoCellID"];
    }
    cell.clickAddEvent = clickAddEvent;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)addView{
    self.addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 45)];
    self.addBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.addBtn setTitleColor:H9COLOR forState:UIControlStateNormal];
    [self.addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.addBtn];
    self.addBtn.bottom = self.height;
}

- (void)setTitle:(NSString *)title{
    
    NSRange range = [title rangeOfString:@"点击发表"];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:H9COLOR}];
    [attText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:NSMakeRange(range.location, title.length - range.location)];
    [self.addBtn setAttributedTitle:attText forState:UIControlStateNormal];
}

- (void)addBtnClick{
    if (self.clickAddEvent) {
        self.clickAddEvent();
    }
}
@end
