//
//  SettingTableViewCell.m
//  QimingpianSearch
//
//  Created by Molly on 16/8/3.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "SettingTableViewCell.h"

@implementation SettingTableViewCell
+ (instancetype)cellWithTableView:(UITableView*)tableView{
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setCellID"];
    if (!cell) {
        cell = [[SettingTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"setCellID"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    
    return self;
}

-(void)buildUI
{
    
    CGFloat w = 25.f;
    _leftImageV = [[UIImageView alloc]initWithFrame:CGRectMake((46/320.f*SCREENW-w)/2, (self.frame.size.height-w)/2, w, w)];
//    _leftImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_leftImageV];
    
//    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(_leftImageV.frame.origin.x+46/320.f*SCREENW, 0, 207/320.f*SCREENW, self.frame.size.height)];
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(21, 0, 207/320.f*SCREENW, self.frame.size.height)];
    _titleLab.textColor = COLOR2D343A;
    _titleLab.font = [UIFont systemFontOfSize:15.f];
    [self.contentView addSubview:_titleLab];
    
    _rightImageV = [[UIImageView alloc]initWithFrame:CGRectMake(SCREENW - 44, (self.frame.size.height-44)/2, 44, 44)];
    [self.contentView addSubview:_rightImageV];
    _rightImageV.image = [BundleTool imageNamed:@"me_headRightArrow"];
    _rightImageV.contentMode = UIViewContentModeCenter;
    
    CGFloat wdith = 20.f;
    UILabel *redPointView = [[UILabel alloc] initWithFrame:CGRectMake(190, 11.f, wdith, wdith)];
    redPointView.backgroundColor = RED_TEXTCOLOR;
    redPointView.textAlignment = NSTextAlignmentCenter;
    redPointView.layer.cornerRadius = 10;
    redPointView.layer.masksToBounds = YES;
    [self.contentView addSubview:redPointView];
    [redPointView labelWithFontSize:12 textColor:[UIColor whiteColor]];
    _redPointView = redPointView;
    
    _keyRedView = [[UIView alloc]init];
    _keyRedView.backgroundColor = RED_TEXTCOLOR;
    _keyRedView.layer.masksToBounds = YES;
    _keyRedView.layer.cornerRadius = 2.5;
    [self.contentView addSubview:_keyRedView];
    _keyRedView.hidden = YES;
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height - 1, SCREENW, 1)];
    _lineView.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:_lineView];
    
    [self.contentView addSubview:self.hotView];
    
    [_leftImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.width.equalTo(@(22));
        make.height.equalTo(@(22));
        make.centerY.equalTo(self.contentView);
    }];

    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(48);
        make.top.equalTo(self.contentView).offset(0);
        make.bottom.equalTo(self.contentView).offset(0);
        make.width.greaterThanOrEqualTo(@(30));
    }];
    
    [_keyRedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLab.mas_right).offset(3);
        make.top.equalTo(_titleLab.mas_top).offset(12);
        make.width.equalTo(@(5));
        make.height.equalTo(@(5));
    }];
    
    [_rightImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-11);
        make.width.equalTo(@(21));
        make.height.equalTo(@(21));
        make.centerY.equalTo(self.contentView);
    }];
    
    [_redPointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_rightImageV.mas_left).offset(0);
        make.width.equalTo(@(20));
        make.height.equalTo(@(20));
        make.centerY.equalTo(self.contentView);
    }];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.right.equalTo(self.contentView).offset(-17);
        make.bottom.equalTo(self.contentView);
        make.height.equalTo(@(1));
    }];
    
    [self.hotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(14, 14));
        make.left.equalTo(self.titleLab.mas_right).offset(6);
        make.centerY.equalTo(self.contentView);
    }];
}

-(void)setCommentNum:(NSString *)commentNum{
    
    _redPointView.text = commentNum;
    CGFloat width = [PublicTool widthOfString:commentNum height:CGFLOAT_MAX fontSize:_redPointView.font.pointSize];
    if (width < 18) {
        return;
    }
    [_redPointView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_rightImageV.mas_left).offset(0);
        make.height.equalTo(@(20));
        make.width.equalTo(@(width+15));
        make.centerY.equalTo(self.contentView);
    }];

}
- (UIImageView *)hotView {
    if (!_hotView) {
        _hotView = [[UIImageView alloc] init];
        _hotView.frame = CGRectMake(0, 0, 14, 14);
        _hotView.hidden = YES;
        _hotView.image = [BundleTool imageNamed:@"hot_text_icon"];
    }
    return _hotView;
}

@end
