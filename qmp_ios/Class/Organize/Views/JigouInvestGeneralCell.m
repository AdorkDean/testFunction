//
//  JigouInvestGeneralCell.m
//  qmp_ios
//
//  Created by QMP on 2017/9/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "JigouInvestGeneralCell.h"

@interface JigouInvestGeneralCell()
@property(nonatomic,strong)NSMutableArray *topLabelArr;
@property(nonatomic,strong)UIImageView *preferenceImgV;


@end
@implementation JigouInvestGeneralCell
+ (JigouInvestGeneralCell *)cellWithTableView:(UITableView *)tableView {
    JigouInvestGeneralCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JigouInvestGeneralCellID"];
    if (cell == nil) {
        cell = [[JigouInvestGeneralCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JigouInvestGeneralCellID"];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
         self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setUI{
    
    self.topLabelArr = [NSMutableArray array];

    NSString *nextRound = _organizeItem.score?:@"0";
    if (![nextRound isEqualToString:@"0"] && nextRound.length) {
        nextRound = [nextRound stringByAppendingString:@"%"];
    }
    NSArray *titleArr = @[@"投资团队",@"投资案例",@"战绩",@"投资偏好"];
    NSString *tzTitle = [PublicTool isNull:_organizeItem.tzcount]?(self.secondRequestFinish?@"":@"加载中"):_organizeItem.tzcount;
    NSMutableArray *textArr = [NSMutableArray arrayWithArray: @[ [PublicTool isNull:self.memberCount]?@"":self.memberCount,tzTitle,nextRound,@"",@""]];


    if (_organizeItem.jg_type && [_organizeItem.jg_type containsString:@"FA"]) {
        titleArr = @[@"FA案例",@"投资案例",@"战绩",@"投资偏好"];
        NSString *faTitle = [PublicTool isNull:_organizeItem.faCasecount]?(self.secondRequestFinish?@"":@"加载中"):_organizeItem.faCasecount;
        textArr = [NSMutableArray arrayWithArray: @[faTitle ,tzTitle,nextRound,@""]];
    }
    
    for (int i=0;i<textArr.count;i++) {
        NSString *str = textArr[i];
        if ([str isEqualToString:@"0"] || str.length == 0) {
            [textArr replaceObjectAtIndex:i withObject:@"暂无"];
        }
    }
    
    NSInteger count = titleArr.count;
    CGFloat leftEdge = 22;
    CGFloat width = 50;
    CGFloat top = 14;
    CGFloat verticalEdge = 8;
    CGFloat horizentalEdge = (SCREENW - leftEdge*2 - width * count)/(count-1);
    for (int i=0; i<count; i++) {
        UIView *roundView = [[UIView alloc]initWithFrame:CGRectMake(leftEdge+i*(width+horizentalEdge), top, width, width)];
        roundView.layer.masksToBounds = YES;
        roundView.layer.cornerRadius = width/2.0;
        roundView.layer.borderColor = LIST_LINE_COLOR.CGColor;
        roundView.layer.borderWidth = 1;
        [self.contentView addSubview:roundView];

        if (i == count-1){ //最后一个
            self.preferenceImgV = [[UIImageView alloc]initWithFrame:roundView.bounds];
            self.preferenceImgV.image = [UIImage imageNamed:@"jigou_fenbu"];
            self.preferenceImgV.contentMode = UIViewContentModeCenter;
            [roundView addSubview:self.preferenceImgV];
         }else{
             UILabel *topLabel = [[UILabel alloc] initWithFrame:roundView.bounds];
             topLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
             topLabel.textColor = BLUE_TITLE_COLOR;
             topLabel.text = @"";
             topLabel.backgroundColor = [UIColor clearColor];
             topLabel.textAlignment = NSTextAlignmentCenter;
             
             [roundView addSubview:topLabel];
             topLabel.text = textArr[i];
             if ([topLabel.text isEqualToString:@"暂无"]||[topLabel.text containsString:@"加载"]) {
                 topLabel.font = [topLabel.text containsString:@"加载"]?[UIFont systemFontOfSize:10]:[UIFont systemFontOfSize:12];
                 topLabel.textColor = H9COLOR;
             }
             if (i == count-2) { //战绩
                 if ([nextRound containsString:@"%"]) {
                     NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:nextRound];
                     [attText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]} range:NSMakeRange(nextRound.length-1, 1)];
                     topLabel.attributedText = attText;
                 }
             }
             
             [self.topLabelArr addObject:topLabel];
         }
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(roundView.left, roundView.bottom + verticalEdge, 70, 20)];
        label.text = titleArr[i];
        [label labelWithFontSize:13 textColor:COLOR2D343A];
        [self.contentView addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.centerX = roundView.centerX;
    }
}


-(void)setOrganizeItem:(OrganizeItem *)organizeItem{
    _organizeItem = organizeItem;

    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setUI];
 
   
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGFloat pointX = [touch locationInView:self].x;
    
    NSString *nextRound = _organizeItem.score?:@"0";
    NSArray *titleArr = @[@"投资团队",@"投资案例",@"战绩",@"投资偏好"];
    
    NSString *tzTitle = [PublicTool isNull:_organizeItem.tzcount]?(self.secondRequestFinish?@"":@"加载中"):_organizeItem.tzcount;
    NSMutableArray *textArr = [NSMutableArray arrayWithArray: @[ [PublicTool isNull:self.memberCount]?@"":self.memberCount,tzTitle,nextRound,@"",@""]];
    
    if (_organizeItem.jg_type && [_organizeItem.jg_type containsString:@"FA"]) {
        titleArr = @[@"FA案例",@"投资案例",@"战绩",@"投资偏好"];
        NSString *faTitle = [PublicTool isNull:_organizeItem.faCasecount]?(self.secondRequestFinish?@"":@"加载中"):_organizeItem.faCasecount;
        textArr = [NSMutableArray arrayWithArray: @[faTitle ,tzTitle,nextRound,@""]];
    }

    for (int i=0;i<textArr.count;i++) {
        NSString *str = textArr[i];
        if ([str isEqualToString:@"0"] || str.length == 0) {
            [textArr replaceObjectAtIndex:i withObject:@"暂无"];
        }
    }
    
    NSInteger count = titleArr.count;
    
    CGFloat everyWidth = (SCREENW-22*2) / count;

    for (int i=0; i<count; i++) {
        CGFloat left = 22 + everyWidth * i;
        CGFloat right = 22 + everyWidth * (i+1);
        if (pointX >= left && pointX < right) {
            if (([textArr[i] isEqualToString:@"暂无"]||[textArr[i] containsString:@"加载"]) && (i != count-1)) {
                return;
            }
            self.clickIndex(titleArr[i]);
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
