//
//  ProInvestorCell.m
//  qmp_ios
//
//  Created by QMP on 2017/12/29.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "ProInvestorCell.h"

@interface ProInvestorCell()
{
    PersonModel *_person;
    __weak IBOutlet UIImageView *_imgV; //HT注： 投资人头像
    __weak IBOutlet UIImageView *_imV; //HT注：V 标识
    
    __weak IBOutlet UILabel *_nameLab;
    __weak IBOutlet UILabel *_companyLab;
    __weak IBOutlet UILabel *_zhiweiLab;
    __weak IBOutlet UILabel *_hangyeLab;
    
    __weak IBOutlet UILabel *_iconLabel;
    
    __weak IBOutlet NSLayoutConstraint *_hangyeRightEdge;
}
@end


@implementation ProInvestorCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    ProInvestorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProInvestorCellID"];
    if (!cell) {
        cell = [[BundleTool commonBundle]loadNibNamed:@"ProInvestorCell" owner:nil options:nil].lastObject;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    
    _imgV.layer.cornerRadius = 22;
    _imgV.layer.masksToBounds = YES;
    _imgV.layer.borderWidth = 0.5;
    _imgV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    
    _iconLabel.layer.cornerRadius = 22;
    _iconLabel.layer.masksToBounds = YES;
    
    _nameLab.textColor = COLOR2D343A;
    _companyLab.textColor = COLOR737782;
    _zhiweiLab.textColor = COLOR737782;
    _hangyeLab.textColor = COLOR737782;
}


- (void)setPerson:(PersonModel *)person{
    _person = person;
    
    [_imgV sd_setImageWithURL:[NSURL URLWithString:person.icon] placeholderImage:[BundleTool imageNamed:@"heading"]];
    NSString *name = [PublicTool isNull:person.name] ? person.person_name:person.name;
    if ([PublicTool isNull:name] && ![PublicTool isNull:person.ename]) {
        name = person.ename;
    }
    _nameLab.text = [PublicTool nilStringReturn:name];
    
    NSString *company;
    NSString *str;
    if (person.work_exp.count) {
        ZhiWeiModel *zhiwei = person.work_exp[0];
        company = zhiwei.name;
        str = zhiwei.zhiwu;
    }else{
        company = person.company?[PublicTool nilStringReturn:person.company]:[PublicTool nilStringReturn:person.agency];
        str = person.zhiwu ? [PublicTool nilStringReturn:person.zhiwu]:[PublicTool nilStringReturn:person.zhiwei];
    }

    NSString *ly = person.lingyu;
    if ([ly isKindOfClass:[NSString class]]) {
        _hangyeLab.text = [PublicTool isNull:((NSString*)person.lingyu)] ? @"":(NSString*)person.lingyu;
    }else{
        NSMutableString *lingyu = [NSMutableString string];
        
        for (NSString *string in (NSArray*)person.lingyu) {
            [lingyu appendString:[NSString stringWithFormat:@"%@、",string]];
        }
        if (lingyu.length > 1) {
            [lingyu deleteCharactersInRange:NSMakeRange(lingyu.length-1, 1)];
        }
        _hangyeLab.text = [PublicTool isNull:lingyu] ? @"":lingyu;
    }
    _companyLab.text = [PublicTool isNull:company] ? @"-":company;

    _zhiweiLab.text = [PublicTool isNull:str] ? @"-":str;
    
//    角色role cyz => 创业者 ；investor => 投资人；FA => FA ；specialist =>专家 ；media =>媒体 ; other => 其他
//    claim_type 2 是否加入（认领），1 审核中（不显示），0 不显示
}

- (void)setIconColor:(UIColor *)iconColor{
    if ([PublicTool isNull:_person.icon] || [_person.icon containsString:@"5a265f11811c9.png"]) {
        _iconLabel.hidden = NO;
        _iconLabel.backgroundColor = iconColor;
        if (_person.name.length > 1) {
            _iconLabel.text = [_person.name substringToIndex:1];
        }else{
            _iconLabel.text = @"-";
        }
    }else{
        _iconLabel.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
