  //
//  CombineTableViewCell.m
//  qmp_ios
//
//  Created by Molly on 2016/11/29.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CombineTableViewCell.h"
#import <UIImageView+WebCache.h>

@interface CombineTableViewCell()
{
    OrganizeCombineItem *_model;
}
@property (strong, nonatomic) UIImageView *iconImg;
@property (strong, nonatomic) UILabel *iconLabel;

@property (strong, nonatomic) UILabel *nameLbl;

@end

@implementation CombineTableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    CombineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CombineTableViewCellID"];
    if (cell == nil) {
        cell = [[CombineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CombineTableViewCellID"];
    }
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGFloat margin = 16.f;
        CGFloat top = 10;
        CGFloat height = 40;
        _iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(margin, top, 40, 40)];
        _iconImg.layer.masksToBounds = YES;
        _iconImg.layer.cornerRadius = 5;
        _iconImg.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        _iconImg.layer.borderWidth = 0.5;
        _iconImg.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView addSubview:_iconImg];
        
        _iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, top, 40, 40)];
        _iconLabel.layer.masksToBounds = YES;
        _iconLabel.layer.cornerRadius = 5;
        [self.iconLabel labelWithFontSize:16 textColor:[UIColor whiteColor]];
        self.iconLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_iconLabel];
        
        CGFloat countW = 84.f;
        _countLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREENW - countW-16, top, countW, height)];
        _countLbl.textAlignment = NSTextAlignmentRight;
        if (@available(iOS 8.2, *)) {
            _countLbl.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
        } else {
            _countLbl.font = [UIFont systemFontOfSize:16.f];
        }
        _countLbl.textColor = BLUE_TITLE_COLOR;
        [self.contentView addSubview:_countLbl];
        
        CGFloat nameX = 68;
        _nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(nameX, top, SCREENW - countW - margin - nameX, height)];
        _nameLbl.textAlignment = NSTextAlignmentLeft;
        if (@available(iOS 8.2, *)) {
            _nameLbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        } else {
            _nameLbl.font = [UIFont systemFontOfSize:15];
        }
        _nameLbl.textColor = HTColorFromRGB(0x1d1d1d);
        [self.contentView addSubview:_nameLbl];
        
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(nameX, 0, SCREENW-nameX-16, 1)];
        _lineView.backgroundColor = LIST_LINE_COLOR;
        [self.contentView addSubview:_lineView];
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    _lineView.bottom = self.height;
}

- (void)initData:(OrganizeCombineItem *)item{
    _model = item;
    
    _iconImg.contentMode = UIViewContentModeScaleAspectFit;
    [_iconImg sd_setImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:[UIImage imageNamed:@"product_default"]];
    _countLbl.text = item.count;
    _nameLbl.text = item.name;
    
}

- (void)setIconColor:(UIColor *)iconColor{
    
    if ([PublicTool isNull:_model.icon] || [_model.icon containsString:@"jigou_default.png"]) {
        self.iconLabel.hidden = NO;
        self.iconLabel.backgroundColor = iconColor;
        if (_model.name.length > 1) {
            self.iconLabel.text = [_model.name substringToIndex:1];
        }else{
            self.iconLabel.text = @"-";
        }
    }else{
        self.iconLabel.hidden = YES;
    }
}
@end
