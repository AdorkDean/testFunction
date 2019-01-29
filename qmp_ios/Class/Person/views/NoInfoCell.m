//
//  NoInfoCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "NoInfoCell.h"

@interface NoInfoCell()
{
    UIView *_bottomGrayV;
}

@end


@implementation NoInfoCell

+ (instancetype)cellWithTableView:(UITableView*)tableView reuseIndentifier:(NSString*)identifier{
    NoInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NoInfoCell alloc]initWithStyle:UITableViewStylePlain reuseIdentifier:identifier];
    }
    return cell;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
   
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addView];
    }
    return self;
}

- (void)addView{
    
    self.tipLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 300, 15)];
    [self.tipLab labelWithFontSize:14 textColor:H9COLOR];
    [self.contentView addSubview:self.tipLab];
    self.tipLab.hidden = YES;
    
    self.addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 116, 34)];
    [self.contentView addSubview:self.addBtn];
    self.addBtn.center = CGPointMake(SCREENW/2.0, self.contentView.height/2.0);
//    _bottomGrayV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 10)];
//    _bottomGrayV.backgroundColor = TABLEVIEW_COLOR;
//    [self addSubview:_bottomGrayV];
}
-(void)layoutSubviews{
    
    self.addBtn.center = CGPointMake(SCREENW/2.0, self.contentView.height/2.0);
//    _bottomGrayV.bottom = self.height;
}

-(void)setBtnText:(NSString *)btnText{
   
    [self.addBtn setTitle:btnText forState:UIControlStateNormal];

    if (self.isMy) {
        self.addBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.addBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [self.addBtn setImage:[BundleTool imageNamed:@"homePage_add"] forState:UIControlStateNormal];
        self.addBtn.layer.masksToBounds = YES;
        self.addBtn.layer.cornerRadius = 17.0;
        self.addBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
        self.addBtn.layer.borderWidth = 0.5;
        [self.addBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        self.addBtn.userInteractionEnabled = YES;

    }else{
        
        self.addBtn.layer.borderWidth = 0.0;
        self.addBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.addBtn setTitleColor:H9COLOR forState:UIControlStateNormal];
        [self.addBtn setTitle:@"暂未填写任何经历" forState:UIControlStateNormal];
        self.addBtn.userInteractionEnabled = NO;
    }
    
    self.addBtn.center = self.contentView.center;
}
- (void)unAuthCellMsg{
    if (self.isMy) {
        self.btnText = @"认证后可添加";
        self.addBtn.layer.cornerRadius = 0;
        self.addBtn.layer.borderWidth = 0.001;
        [self.addBtn setTitleColor:RGBLineGray forState:UIControlStateNormal];
        [self.addBtn setImage:nil forState:UIControlStateNormal];
    }
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
