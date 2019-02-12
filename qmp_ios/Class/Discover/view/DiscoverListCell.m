//
//  DiscoverListCell.m
//  qmp_ios
//
//  Created by QMP on 2018/8/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DiscoverListCell.h"

@interface DiscoverListCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconV;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UILabel *centerYLab;
@property (weak, nonatomic) IBOutlet UILabel *iconLab;

@property(nonatomic,strong) NSDictionary *dataDic;
@property(nonatomic,assign) AttentType attentType;

@end


@implementation DiscoverListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.iconV.layer.cornerRadius = 4;
    self.iconV.layer.masksToBounds = YES;
    self.iconV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    self.iconV.layer.borderWidth = 0.5;
    self.iconV.contentMode = UIViewContentModeScaleAspectFit;
    
    self.iconLab.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    self.iconLab.layer.borderWidth = 0.5;
    self.iconLab.layer.cornerRadius = 4;
    self.iconLab.layer.masksToBounds = YES;
    
    self.centerYLab.hidden = YES;
    
    self.attentBtn.layer.cornerRadius = 14;
    self.attentBtn.layer.masksToBounds = YES;
    
    self.iconLab.text = @"";
    self.iconLab.hidden = YES;
    
}

+ (DiscoverListCell*)cellWithTableView:(UITableView*)tableView recommendType:(AttentType)recommendType dataDic:(NSDictionary*)dataDic{
    DiscoverListCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"RecommendCell_%ld",recommendType]];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"DiscoverListCell" owner:nil options:nil].lastObject;
    }

    cell.iconV.hidden = NO;
    cell.nameLab.hidden = NO;
    cell.detailLab.hidden = NO;
    cell.centerYLab.hidden = YES;
    cell.attentType = recommendType;
    if (dataDic) {
        cell.dataDic = dataDic;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)setDataDic:(NSDictionary *)dataDic{
    _dataDic = dataDic;
    self.centerYLab.hidden = YES;
    
    [self.iconV sd_setImageWithURL:[NSURL URLWithString:dataDic[@"icon"]] placeholderImage:[UIImage imageNamed:PROICON_DEFAULT]];
    self.nameLab.text = dataDic[@"name"];
    
    if ([dataDic[@"project_type"] containsString:@"person"]) {
        self.detailLab.text = [NSString stringWithFormat:@"%@  %@",[PublicTool isNull:dataDic[@"company"]]?@"":dataDic[@"company"],[PublicTool isNull:dataDic[@"zhiwu"]]?@"":dataDic[@"zhiwu"]];
    }else{
        self.detailLab.text = dataDic[@"miaoshu"];
    }
    
    if ([dataDic[@"work_flow"] integerValue] == 1) { //已关注
        //        self.attentBtn.layer.borderColor = HTColorFromRGB(0xBBBBBB).CGColor;
        [self.attentBtn setTitleColor:H999999 forState:UIControlStateNormal];
        [self.attentBtn setTitle:@"已关注" forState:UIControlStateNormal];
        self.attentBtn.backgroundColor = [H999999 colorWithAlphaComponent:0.08];
    }else{
        //        self.attentBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
        [self.attentBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [self.attentBtn setTitle:@"关注" forState:UIControlStateNormal];
        self.attentBtn.backgroundColor = [BLUE_TITLE_COLOR colorWithAlphaComponent:0.08];
    }
    
    if ([dataDic[@"project_type"] containsString:@"person"] || [dataDic[@"project_type"] containsString:@"theme"]) {
        self.iconV.layer.cornerRadius = 22.5;
        self.iconLab.layer.cornerRadius = 22.5;
        self.iconV.contentMode = UIViewContentModeScaleAspectFill;
        
    }else{
        self.iconV.contentMode = UIViewContentModeScaleAspectFit;
        self.iconV.layer.cornerRadius = 4;
        self.iconLab.layer.cornerRadius = 4;
    }
}

+ (DiscoverListCell*)cellWithTableView:(UITableView*)tableView recommendType:(AttentType)recommendType attentionModel:(MeTopItemModel*)attentionM{
    DiscoverListCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"RecommendCell_%ld",recommendType]];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"DiscoverListCell" owner:nil options:nil].lastObject;
    }
    
    cell.iconV.hidden = NO;
    cell.nameLab.hidden = NO;
    cell.detailLab.hidden = NO;
    cell.centerYLab.hidden = YES;
    cell.attentType = recommendType;
    if (attentionM) {
        cell.attentionM = attentionM;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)setAttentionM:(MeTopItemModel *)attentionM{
    _attentionM = attentionM;
    self.centerYLab.hidden = YES;
    
    NSString *defaultImg = PROICON_DEFAULT;
    if (self.attentType == AttentType_Person) {
        defaultImg = @"heading";
        self.detailLab.text = [NSString stringWithFormat:@"%@  %@",[PublicTool isNull:attentionM.company]?@"":attentionM.company,[PublicTool isNull:attentionM.position]?@"":attentionM.position];
    }else if (self.attentType == AttentType_Product) {
        self.detailLab.text = attentionM.yewu;
    }else{
        self.detailLab.text = attentionM.miaoshu;
    }
    [self.iconV sd_setImageWithURL:[NSURL URLWithString:attentionM.icon] placeholderImage:[UIImage imageNamed:defaultImg]];
    self.nameLab.text = [PublicTool isNull:attentionM.project]?attentionM.nickname:attentionM.project;
    
   
    if (attentionM.display_flag.integerValue == 1) { //已关注
        //        self.attentBtn.layer.borderColor = HTColorFromRGB(0xBBBBBB).CGColor;
        [self.attentBtn setTitleColor:H999999 forState:UIControlStateNormal];
        [self.attentBtn setTitle:@"已关注" forState:UIControlStateNormal];
        self.attentBtn.backgroundColor = [H999999 colorWithAlphaComponent:0.08];
    }else{
        //        self.attentBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
        [self.attentBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [self.attentBtn setTitle:@"关注" forState:UIControlStateNormal];
        self.attentBtn.backgroundColor = [BLUE_TITLE_COLOR colorWithAlphaComponent:0.08];
    }
    
    if (self.attentType == AttentType_Person || self.attentType == AttentType_Subject) {
        self.iconV.layer.cornerRadius = 22.5;
        self.iconLab.layer.cornerRadius = 22.5;
        self.iconV.contentMode = UIViewContentModeScaleAspectFill;
    }else{
        self.iconV.layer.cornerRadius = 4;
        self.iconLab.layer.cornerRadius = 4;
        self.iconV.contentMode = UIViewContentModeScaleAspectFit;
    }
}



- (void)setIconColor:(UIColor *)iconColor{
    
    _iconLab.backgroundColor = iconColor;
    
    if (self.attentionM) {
        if ([PublicTool isNull:self.attentionM.icon]) {
            _iconLab.hidden = NO;
            if (![PublicTool isNull:self.attentionM.project]) {
                NSString *firstN = [self.attentionM.project substringWithRange:NSMakeRange(0, 1)];
                _iconLab.text = firstN;
            }else if (![PublicTool isNull:self.attentionM.nickname]) {
                NSString *firstN = [self.attentionM.nickname substringWithRange:NSMakeRange(0, 1)];
                _iconLab.text = firstN;
            }
        }else{
            _iconLab.hidden = YES;
        }
        return;
    }
    
    if ([PublicTool isNull:self.dataDic[@"icon"]]) {
        _iconLab.hidden = NO;
        
        if (![PublicTool isNull:self.dataDic[@"name"]]) {
            NSString *firstN = [self.dataDic[@"name"] substringWithRange:NSMakeRange(0, 1)];
            _iconLab.text = firstN;
        }
    }else{
        _iconLab.hidden = YES;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
