//
//  OrganizerInvestProjectCell.m
//  qmp_ios
//
//  Created by QMP on 2017/8/22.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "OrganizerInvestProjectCell.h"

@interface OrganizerInvestProjectCell ()
{
    UIImageView *_iconImageV;
    UILabel * _nameLabel;
    UILabel * _briefLabel;
    UILabel * _hangyeLab;
    UIImageView *_starImgV;
    
    UIView *_currentLunciView;
    UIView *_pastLunciView;
}
@end

@implementation OrganizerInvestProjectCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setUI{
    //icon
    _iconImageV = [[UIImageView alloc]init];
    _iconImageV.layer.masksToBounds = YES;
    _iconImageV.layer.cornerRadius = 4;
    _iconImageV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    _iconImageV.layer.borderWidth = 0.5;
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconImageV];
    
    //当前状态标签
    UILabel *currentStateLabel = [[UILabel alloc]init];
    currentStateLabel.text = @"当前状态";
    [currentStateLabel labelWithFontSize:11 textColor:RED_TEXTCOLOR cornerRadius:2 borderWdith:0.5 borderColor:RED_TEXTCOLOR];
    currentStateLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:currentStateLabel];
    
    //曾经轮次标签
    UILabel *pastStateLabel = [[UILabel alloc]init];
    pastStateLabel.text = @"曾投轮次";
    [pastStateLabel labelWithFontSize:11 textColor:H9COLOR cornerRadius:2 borderWdith:0.5 borderColor:H9COLOR];
    pastStateLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:pastStateLabel];
    pastStateLabel.tag = 999;
    
    //企业名称
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.textColor = HTColorFromRGB(0x1c1c1c);
    [self.contentView addSubview:_nameLabel];
    _nameLabel.font = [UIFont systemFontOfSize:16];
    
    //简介
    _briefLabel = [[UILabel alloc]init];
    [_briefLabel labelWithFontSize:14 textColor:H9COLOR];
    [self.contentView addSubview:_briefLabel];

    
    //行业类型
    _hangyeLab = [[UILabel alloc]init];
    [_hangyeLab labelWithFontSize:13 textColor:H9COLOR];
    _hangyeLab.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_hangyeLab];

    _currentLunciView = [[UIView alloc]init];
    [self.contentView addSubview:_currentLunciView];
 
    _pastLunciView = [[UIView alloc]init];
    [self.contentView addSubview:_pastLunciView];
    
    
    //line
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:line];

    /**
      约束
     */
    [_iconImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(20);
        make.left.equalTo(self.contentView).with.offset(17);
        make.width.equalTo(@(55));
        make.height.equalTo(@(55));
    }];
    [currentStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconImageV.mas_bottom).with.offset(10);
        make.centerX.equalTo(_iconImageV.mas_centerX);
        make.width.equalTo(_iconImageV.mas_width);
        make.height.equalTo(@(20));
    }];
    [pastStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(currentStateLabel.mas_bottom).with.offset(12);
        make.centerX.equalTo(_iconImageV.mas_centerX);
        make.width.equalTo(_iconImageV.mas_width);
        make.height.equalTo(@(20));
    }];
    
    [_hangyeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-16);
        make.centerY.equalTo(_nameLabel.mas_centerY);
        make.width.greaterThanOrEqualTo(@(40)).priorityHigh();
        make.height.equalTo(@(20));
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageV.mas_right).with.offset(15);
        make.top.equalTo(self.contentView).with.offset(23);
        make.right.equalTo(_hangyeLab.mas_left).offset(-10).priorityLow();
        make.height.equalTo(@(22));
    }];
    
    [_briefLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel.mas_left);
        make.top.equalTo(_nameLabel.mas_bottom).with.offset(9);
        make.height.equalTo(@(20));
        make.right.equalTo(self.contentView.mas_right).with.offset(-15);
    }];
    
    [_currentLunciView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel.mas_left);
        make.centerY.equalTo(currentStateLabel.mas_centerY);
        make.height.equalTo(currentStateLabel.mas_height);
        make.right.equalTo(self.contentView.mas_right).with.offset(-10);
        
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.width.equalTo(@(SCREENW-34));
        make.height.equalTo(@(0.5));
        
    }];


    [_pastLunciView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel.mas_left);
        make.top.equalTo(_currentLunciView.mas_bottom).offset(12);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.equalTo(@(20));
    }];
  
}

-(void)setInvestmentModel:(JigouInvestmentsCaseModel *)investmentModel{
    
    [_pastLunciView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_currentLunciView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    _investmentModel = investmentModel;
   
    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:investmentModel.icon] placeholderImage:[BundleTool imageNamed:@"product_default"]];
    
//    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:investmentModel.icon] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        _iconImageV.image = [PublicTool OriginImage:image scaleToSize:CGSizeMake(80, 80)];
//    }];
//
    _nameLabel.text = [PublicTool nilStringReturn:investmentModel.product];
    _hangyeLab.text = [PublicTool nilStringReturn:investmentModel.hangye1];
    _briefLabel.text = [PublicTool nilStringReturn:investmentModel.yewu];
    
    NSString *curlunciTime = investmentModel.time;
    if (curlunciTime && [curlunciTime containsString:@"."]) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[investmentModel.time componentsSeparatedByString:@"."]];
        if (arr.count == 3) {
            [arr removeLastObject];
        }
        for (NSString *str in arr) {
            if ([arr indexOfObject:str] == 1 && str.length == 1) {
                NSString *fullStr;
                fullStr = [NSString stringWithFormat:@"0%@",str];
                [arr replaceObjectAtIndex:1 withObject:fullStr];
            }
        }
        curlunciTime = [arr componentsJoinedByString:@"."];
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,71, 20)];
    [label labelWithFontSize:14 textColor:HTColorFromRGB(0x555555)];
    label.text = curlunciTime;
    [_currentLunciView addSubview:label];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(label.right, label.top, 150, 20)];
    [label2 labelWithFontSize:14 textColor:HTColorFromRGB(0x555555)];
    label2.text = investmentModel.jieduan;
    [_currentLunciView addSubview:label2];
//    
//    _currentLunci.text = [NSString stringWithFormat:@"%@     %@",curlunciTime,investmentModel.curlunci];

    
    //添加轮次
    CGFloat rowHeight = 20;
    CGFloat rowEdge = 4;
    
    for (int i=0; i<investmentModel.lunciStringArr.count; i++) {
        NSArray *textArr = [investmentModel.lunciStringArr[i] componentsSeparatedByString:@"  "];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, i*(rowHeight+rowEdge),71, rowHeight)];
        [label labelWithFontSize:14 textColor:HTColorFromRGB(0x555555)];
        label.text = textArr[0];
        [_pastLunciView addSubview:label];
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(label.right, label.top, 60, rowHeight)];
        [label2 labelWithFontSize:14 textColor:HTColorFromRGB(0x555555)];
        label2.text = textArr[1];
        [_pastLunciView addSubview:label2];
        
        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(label2.right+15, label.top,150, rowHeight)];
        [label3 labelWithFontSize:14 textColor:HTColorFromRGB(0x555555)];
        label3.text = textArr[2];
        [_pastLunciView addSubview:label3];
    }
    if (investmentModel.lunciStringArr.count) {
        [[self.contentView viewWithTag:999] setHidden:NO];
        [_pastLunciView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameLabel.mas_left);
            make.top.equalTo(_currentLunciView.mas_bottom).offset(12);
            make.right.equalTo(self.contentView).offset(-10);
            make.height.equalTo(@( rowHeight * investmentModel.lunciStringArr.count + rowEdge*(investmentModel.lunciStringArr.count-1)));
        }];
        
    }else{
        [[self.contentView viewWithTag:999] setHidden:YES];
        [_pastLunciView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameLabel.mas_left);
            make.top.equalTo(_currentLunciView.mas_bottom).offset(12);
            make.right.equalTo(self.contentView).offset(-10);
            make.height.equalTo(@(20));
        }];
    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
