//
//  PersonRoleCell.m
//  CommonLibrary
//
//  Created by QMP on 2019/1/7.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "PersonRoleCell.h"
#import "InsetsLabel.h"

@interface PersonRoleCell()
@property (weak, nonatomic) IBOutlet UILabel *relateProjectLab;
@property (weak, nonatomic) IBOutlet UIImageView *iconV;
@property (weak, nonatomic) IBOutlet UILabel *moneyLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIView *firstLine;
@property (weak, nonatomic) IBOutlet UIView *secondLine;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet InsetsLabel *statusLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *relateLabTopedge;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstLineLeading;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondLineLeading;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidth;

@end


@implementation PersonRoleCell

+ (instancetype)cellWithTableView:(UITableView*)tableView{
    PersonRoleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonRoleCellID"];
    if (!cell) {
        cell = [nilloadNibNamed:@"PersonRoleCell" owner:nil options:nil].lastObject;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.iconV.hidden = YES;
    
    [self.statusLab labelWithFontSize:12 textColor:HCCOLOR cornerRadius:2 borderWdith:1 borderColor:HCCOLOR];
    
    self.iconLabel.layer.cornerRadius = 4.0;
    self.iconLabel.clipsToBounds = YES;
    _relateProjectLab.userInteractionEnabled = YES;
    [_relateProjectLab addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterProDetail)]];
    _relateProjectLab.text = @"";

}


- (void)setRoleModel:(PersonRoleModel *)roleModel{
    _roleModel = roleModel;
    self.nameLab.text = roleModel.company;
    NSString *money = [PublicTool nilStringReturn:roleModel.qy_ziben];
    [money stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([money containsString:@"万"]) {
        NSArray *arr = [money componentsSeparatedByString:@"万"];
        money = arr.firstObject;
        NSString *notNumStr = [money stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        [notNumStr stringByReplacingOccurrencesOfString:@"." withString:@""];
        if (![notNumStr isEqualToString:@"."]) {
            money = [money stringByReplacingOccurrencesOfString:notNumStr withString:@""];
        }
        money = [NSString stringWithFormat:@"%.1f万",money.floatValue];

        if (arr.count == 2) {
            money = [money stringByAppendingString:arr[1]];
        }
    }
    money = [money stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([money containsString:@"人民币"]) {
        money = [money stringByReplacingOccurrencesOfString:@"人民币" withString:@""];
    }
    if ([money containsString:@"(人民币)"]) {
        money = [money stringByReplacingOccurrencesOfString:@"(人民币)" withString:@""];
    }
    if ([money containsString:@".0"]) {
        money = [money stringByReplacingOccurrencesOfString:@".0" withString:@""];
    }
    if ([money containsString:@"万元"]) {
        money = [money stringByReplacingOccurrencesOfString:@"万元" withString:@"万"];
    }
    
    self.moneyLab.text = money;
    self.timeLab.text = [roleModel.qy_start_date stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    [self.statusLab setText:(roleModel.qy_status.length > 2 ? [roleModel.qy_status substringToIndex:2]:roleModel.qy_status)];
    self.statusLab.hidden = !(roleModel.qy_status.length > 0);
    self.iconLabel.hidden = NO;
    self.iconLabel.text = roleModel.company.length > 1? [roleModel.company substringToIndex:1]:@"";
    _relateProjectLab.hidden = YES;
    _relateProjectLab.attributedText = nil;
    if (roleModel.rel_project.allKeys.count) {
        _relateProjectLab.hidden = NO;
        _relateLabTopedge.constant = 9;
        NSString *proOrJigou = [roleModel.rel_project[@"detail"] containsString:@"org"]?@"关联机构: ":@"关联项目: ";
        NSString *relateStr = [NSString stringWithFormat:@"%@%@",proOrJigou,roleModel.rel_project[@"name"]];
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:relateStr];
        [attText addAttributes:@{NSForegroundColorAttributeName:H9COLOR} range:NSMakeRange(0, proOrJigou.length)];
        [attText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:NSMakeRange(proOrJigou.length, relateStr.length-proOrJigou.length)];
        _relateProjectLab.attributedText = attText;

    }else{
        _relateLabTopedge.constant = -17;
    }
}


- (void)enterProDetail{
    if (self.roleModel.rel_project) {
        NSString *detail = self.roleModel.rel_project[@"detail"];
        [[AppPageSkipTool shared] appPageSkipToDetail:detail];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
