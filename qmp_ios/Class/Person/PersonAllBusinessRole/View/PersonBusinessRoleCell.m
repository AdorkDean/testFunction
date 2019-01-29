//
//  PersonBusinessRoleCell.m
//  qmp_ios
//
//  Created by QMP on 2018/4/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonBusinessRoleCell.h"
#import "PersonRoleModel.h"
@implementation PersonBusinessRoleCell

+ (instancetype)cellWithTableView:(UITableView*)tableView{
    PersonBusinessRoleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonBusinessRoleCellID"];
    if (!cell) {
        cell = [[BundleTool commonBundle] loadNibNamed:@"PersonBusinessRoleCell" owner:nil options:nil].lastObject;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    self.lineView.backgroundColor = LIST_LINE_COLOR;
    
    self.statusButton.layer.borderColor = [LINE_COLOR CGColor];
    self.statusButton.layer.cornerRadius = 3.0;
    self.statusButton.layer.borderWidth = 0.5;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.avatarView.layer.cornerRadius = 4.0;
    self.avatarView.clipsToBounds = YES;
    self.avatarLabel.layer.cornerRadius = 4.0;
    self.avatarLabel.clipsToBounds = YES;
    
    self.avatarLabel.userInteractionEnabled = YES;
    self.avatarView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewClick)];
    [self.avatarView addGestureRecognizer:tapGest];
    UITapGestureRecognizer *tapGest2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewClick)];
    [self.avatarLabel addGestureRecognizer:tapGest2];

}
- (void)avatarViewClick {
    if ([self.delegate respondsToSelector:@selector(personBusinessRoleCellAvatarClick:)]) {
        [self.delegate personBusinessRoleCellAvatarClick:self.model];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(PersonRoleModel *)model {
    _model = model;

    self.avatarView.userInteractionEnabled = (model.pro_detail.length > 0 || model.jg_detail.length);
    self.avatarLabel.userInteractionEnabled = (model.pro_detail.length > 0|| model.jg_detail.length);
    
    NSString *desc = @"";
    if (![PublicTool isNull:model.percent]) {
        desc = model.percent.length > 0 ?[NSString stringWithFormat:@"投资比例 %@", model.percent] :@"";
    }
    
    self.companyNameLabel.text = model.company;
    self.descLabel.text = desc;
    self.registerCapitalLabel.text = model.qy_ziben.length > 0 ?[NSString stringWithFormat:@"注册资本 %@", model.qy_ziben] :@"  ";
    self.tiemLabel.text = [model.qy_start_date stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    [self.statusButton setTitle:(model.qy_status.length > 2 ? [model.qy_status substringToIndex:2]:model.qy_status) forState:UIControlStateNormal];
    self.statusButton.hidden = !(model.qy_status.length > 0);
    
    self.avatarLabel.hidden = YES;
    self.avatarView.hidden = YES;
    if (![PublicTool isNull:model.pro_icon] && ![model.pro_icon containsString:@"product_default"]) {
        self.avatarView.hidden = NO;
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.pro_icon] placeholderImage:[BundleTool imageNamed:PROICON_DEFAULT]];
    }else if (![PublicTool isNull:model.jg_icon] && ![model.jg_icon containsString:@"product_default"]) {
        self.avatarView.hidden = NO;
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.pro_icon] placeholderImage:[BundleTool imageNamed:PROICON_DEFAULT]];
    } else {
        self.avatarLabel.hidden = NO;
        self.avatarLabel.text = model.company.length > 0 ? [model.company substringToIndex:1]:@"";
    }
    
}
@end
