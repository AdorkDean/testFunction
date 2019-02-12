//
//  BPDeliverStatueCell.m
//  qmp_ios
//
//  Created by QMP on 2018/7/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BPDeliverStatusCell.h"

@interface BPDeliverStatusCell()
@property (weak, nonatomic) IBOutlet UIImageView *headImgVw;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic) IBOutlet UILabel *zhiweiLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *iconPlaceLbl;

@end
@implementation BPDeliverStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.iconPlaceLbl.layer.cornerRadius = 30;
    self.iconPlaceLbl.layer.masksToBounds = YES;
    self.iconPlaceLbl.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    self.iconPlaceLbl.layer.borderWidth = 0.5;
    
    self.headImgVw.layer.cornerRadius = 30;
    self.headImgVw.layer.masksToBounds = YES;
    self.headImgVw.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    self.headImgVw.layer.borderWidth = 0.5;
}

+ (instancetype)defaultInitCellWithTableView:(UITableView *)tableview{
    BPDeliverStatusCell * cell =  [tableview dequeueReusableCellWithIdentifier:@"BPDeliverStatusCellID"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"BPDeliverStatusCell" owner:self options:nil].lastObject;
    }
    return cell;
}

// 已投递、被查看、投递失败、被标记为感兴趣
- (IBAction)deliverTarget:(UIButton *)sender {
    
}

- (void)setBpstatusModel:(BPDeliverStatusModel *)bpstatusModel{
    _bpstatusModel = bpstatusModel;
    
    [self.headImgVw sd_setImageWithURL:[NSURL URLWithString:_bpstatusModel.icon] placeholderImage:[UIImage imageNamed:@"heading"]];
    self.nameLbl.text = _bpstatusModel.name;
    self.statusLbl.text = [_bpstatusModel.claim_type isEqualToString:@"2"]?@"":@" 未入驻 ";
    if ([PublicTool isNull:_bpstatusModel.company]) {
        self.zhiweiLbl.text = [NSString stringWithFormat:@"%@",_bpstatusModel.zhiwei]; // 真格基金 | 执行总裁
    }else{
        self.zhiweiLbl.text = [NSString stringWithFormat:@"%@  %@", _bpstatusModel.company, _bpstatusModel.zhiwei]; // 真格基金 | 执行总裁
    }
    NSString * bpNameStr = [_bpstatusModel.bp_name stringByReplacingOccurrencesOfString:@".pdf" withString:@""];
    self.dateLbl.text = [NSString stringWithFormat:@"%@  %@", _bpstatusModel.create_time, bpNameStr]; // 07-02 | 商业信息化平台BP

    if([_bpstatusModel.browse_status integerValue] == 1){
        [self.deliverBtn setTitle:@"被查看" forState:UIControlStateNormal];
    }else if ([_bpstatusModel.browse_status integerValue] == 0){
        [self.deliverBtn setTitle:@"已投递" forState:UIControlStateNormal];
    }else{
        
    }
    
    if ([_bpstatusModel.interest_flag integerValue] == 2) {
        [self.deliverBtn setTitle:@"被标记为感兴趣" forState:UIControlStateNormal];
    }else if ([_bpstatusModel.interest_flag integerValue] == 0){
        [self.deliverBtn setTitle:@"被查看" forState:UIControlStateNormal];
//        [self.deliverBtn setTitle:@"被标记为不感兴趣" forState:UIControlStateNormal];
    }else{
        
    }
    [self setHeadImgHoldTxt];
}
- (void)setHeadImgHoldTxt{
    if ([PublicTool isNull:_bpstatusModel.icon] || [_bpstatusModel.icon containsString:@"5a265f11811c9.png"]) {
        self.iconPlaceLbl.hidden = NO;
        self.iconPlaceLbl.backgroundColor = RANDOM_COLORARR[arc4random()%6];
        if (_nameLbl.text.length > 1) {
            self.iconPlaceLbl.text = [_nameLbl.text substringToIndex:1];
        }else{
            self.iconPlaceLbl.text = @"-";
        }
    }else{
        self.iconPlaceLbl.hidden = YES;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (void)layoutSubviews{
    self.headImgVw.layer.cornerRadius = (self.contentView.bounds.size.height - (20 + 25)) / 2.0;
    self.headImgVw.clipsToBounds = YES;
    self.statusLbl.layer.cornerRadius = 2;
    self.statusLbl.layer.borderColor = H9COLOR.CGColor;
    self.statusLbl.layer.borderWidth = 0.5;
    self.statusLbl.clipsToBounds = YES;
}

@end
