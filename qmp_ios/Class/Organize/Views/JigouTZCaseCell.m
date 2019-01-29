//
//  JigouTZCaseCell.m
//  qmp_ios
//
//  Created by QMP on 2017/9/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "JigouTZCaseCell.h"
#import "InsetsLabel.h"

@interface JigouTZCaseCell()
{
        __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UIImageView *_iconImageV;
    __weak IBOutlet InsetsLabel *_currentLunci;
    
    __weak IBOutlet UILabel *_briefLabel;
    __weak IBOutlet UILabel *_hangyeLab;
    
    __weak IBOutlet UIView *_lunciView;
    
    __weak IBOutlet UILabel *_iconLabel;
    
    __weak IBOutlet UIImageView *topImageView;
    __weak IBOutlet NSLayoutConstraint *nameLeftConstraint;
    
    __weak IBOutlet NSLayoutConstraint *_lunciviewTopEdge;
}

@property(nonatomic,strong) JigouInvestmentsCaseModel *model;

@end

@implementation JigouTZCaseCell

+ (JigouTZCaseCell *)cellWithTableView:(UITableView *)tableView {
    JigouTZCaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JigouTZCaseCellID"];
    if (cell == nil) {
        cell = (JigouTZCaseCell *)[[[BundleTool commonBundle] loadNibNamed:@"JigouTZCaseCell" owner:self options:nil] lastObject];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _iconImageV.layer.masksToBounds = YES;
    _iconImageV.layer.cornerRadius = 5;
    _iconImageV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImageV.layer.borderWidth = 0.5;
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    
    _iconLabel.layer.masksToBounds = YES;
    _iconLabel.layer.cornerRadius = 5;
    
    [_currentLunci labelWithFontSize:10 textColor:BLUE_TITLE_COLOR cornerRadius:2];
    _currentLunci.backgroundColor = LABEL_BG_COLOR;
    
    _hangyeLab.textColor = H999999;
    _nameLabel.textColor = H3COLOR;
    _briefLabel.textColor = H6COLOR;
}

/**参投 赋值*/
- (void)layoutWithCaseModel:(JigouInvestmentsCaseModel*)model{
    _model = model;
    [_lunciView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[BundleTool imageNamed:@"product_default"]];
    
    _nameLabel.text = [PublicTool nilStringReturn:model.product];
    _hangyeLab.text = [PublicTool nilStringReturn:model.hangye1];
    _briefLabel.text = [PublicTool nilStringReturn:model.yewu];
    _currentLunci.text = model.lunci ? model.lunci:model.jieduan;
    if (![PublicTool isNull:_currentLunci.text]) {
        _currentLunci.hidden = NO;
    }else{
        _currentLunci.hidden = YES;
    }
    _currentLunci.hidden = YES;
    
    nameLeftConstraint.constant = 15;
    topImageView.hidden = YES;
    _lunciView.height = 0;
    _lunciviewTopEdge.constant = 0;
    [self updateConstraints];
}

// 投资 FA 案例，合投项目, 战绩
- (CGFloat)setCaseModel:(JigouInvestmentsCaseModel*)model {
    _model = model;
    [_lunciView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[BundleTool imageNamed:@"product_default"]];

    _nameLabel.text = [PublicTool nilStringReturn:model.product];
    _hangyeLab.text = [PublicTool nilStringReturn:model.hangye1];
    _briefLabel.text = [PublicTool nilStringReturn:model.yewu];
    _currentLunci.text = model.jieduan?model.jieduan:model.lunci;
    if (![PublicTool isNull:_currentLunci.text]) {
        _currentLunci.hidden = NO;
    }else{
        _currentLunci.hidden = YES;
    }    
    
    nameLeftConstraint.constant = 15;
    topImageView.hidden = YES;

    //添加轮次
    CGFloat rowEdge = 12;
    CGFloat height = 15;
    CGFloat top = 0;
   
    for (int i=0; i<model.lunciStringArr.count; i++) {
        NSDictionary *currentDic;
        if (model.luncis) {
            currentDic = model.luncis[i];
        }else if(model.finance_history){
            currentDic = model.finance_history[i];
        }
        BOOL isInvest = [currentDic[@"invest_flag"] integerValue] == 1;
        UIImage *pointImg = isInvest ? [BundleTool imageNamed:@"lunci_point"]:[BundleTool imageNamed:@"lunci_point_gray"];
        UIColor *textColor = isInvest ? YELLOW_COLOR : H999999;
        
        NSArray *textArr = [model.lunciStringArr[i] componentsSeparatedByString:@"  "];
        
        top = i*(height+rowEdge);
        //点 线
        UIImageView *point = [[UIImageView alloc]initWithFrame:CGRectMake(0, top, height, height)];
        point.image = pointImg;
        point.contentMode = UIViewContentModeCenter;
        [_lunciView addSubview:point];
        if (i != model.lunciStringArr.count-1) {
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(point.left+height/2.0, point.bottom-10, 1, rowEdge+15)];
            line.backgroundColor = F5COLOR;
            [_lunciView addSubview:line];
            line.centerX = point.centerX;
        }
        [_lunciView bringSubviewToFront:point];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(point.right+5, top, 70, height)];
        [label labelWithFontSize:14 textColor:textColor];
        label.text = textArr[0];
        [_lunciView addSubview:label];
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(label.right, top, 60, height)];
        [label2 labelWithFontSize:14 textColor:textColor];
        label2.text = textArr[1];
        [_lunciView addSubview:label2];
        
        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(label2.right+15, top, 150, height)];
        [label3 labelWithFontSize:14 textColor:textColor];
        label3.text = textArr[2];
        [_lunciView addSubview:label3];
    }
    if (model.lunciStringArr.count) {
        _lunciView.height = height * model.lunciStringArr.count + rowEdge*(model.lunciStringArr.count-1);

    }else{
        _lunciView.height = 0;
    }

    return 70 + _lunciView.height + 15;
}


- (void)setIconColor:(UIColor *)iconColor{
    if ([PublicTool isNull:_model.icon] || [_model.icon containsString:@"product_default.png"]) {
        _iconLabel.hidden = NO;
        _iconLabel.backgroundColor = iconColor;
        if (_nameLabel.text.length > 1) {
            _iconLabel.text = [_nameLabel.text substringToIndex:1];
        }else{
            _iconLabel.text = @"-";
        }
    }else{
        _iconLabel.hidden = YES;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    self.height = 92 + _lunciView.height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
