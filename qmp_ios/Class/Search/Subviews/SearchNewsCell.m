//
//  SearchNewsCell.m
//  CommonLibrary
//
//  Created by QMP on 2018/12/17.
//  Copyright © 2018 WSS. All rights reserved.
//

#import "SearchNewsCell.h"
#import "GetSizeWithText.h"
#import "CopyLabel.h"
#import <UIImageView+WebCache.h>

@interface SearchNewsCell()

@property (strong, nonatomic) GetSizeWithText *getSizeTool;

@property (strong, nonatomic) UILabel *timeLbl;
@property (strong, nonatomic) UILabel *sourceLbl;

@end

@implementation SearchNewsCell

+ (SearchNewsCell *)cellWithTableView:(UITableView *)tableView {
    SearchNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchNewsCellID"];
    if (cell == nil) {
        cell = [[SearchNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchNewsCellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.titleLbl = [[UILabel alloc] init];
        self.titleLbl.textColor = H3COLOR;
        self.titleLbl.font = [UIFont systemFontOfSize:15];
        self.titleLbl.userInteractionEnabled = YES;
        self.titleLbl.numberOfLines = 0;
        [self.contentView addSubview:self.titleLbl];
        
        self.sourceLbl = [[UILabel alloc] init];
        self.sourceLbl.font = [UIFont systemFontOfSize:12.f];
        self.sourceLbl.textColor = H9COLOR;
        [self.contentView addSubview:self.sourceLbl];
        
        self.timeLbl = [[UILabel alloc] init];
        self.timeLbl.font = [UIFont systemFontOfSize:12.f];
        self.timeLbl.textColor = H9COLOR;
        [self.contentView addSubview:self.timeLbl];
        
        self.bottomLine = [[UIView alloc]init];
        self.bottomLine.backgroundColor = LIST_LINE_COLOR;
        [self.contentView addSubview:self.bottomLine];
        [self maskConstraint];
    }
    return self;
}

- (void)maskConstraint{
    
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(15);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-15);
    }];
        
    [self.sourceLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLbl.mas_left);
        make.top.equalTo(_titleLbl.mas_bottom).offset(10);
        make.width.greaterThanOrEqualTo(@(20));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-15);
    }];
    [self.sourceLbl setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.sourceLbl setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    
    [self.timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sourceLbl.mas_right).offset(10);
        make.top.equalTo(_titleLbl.mas_bottom).offset(10);
        make.width.equalTo(@(120));
        make.centerY.equalTo(self.sourceLbl.mas_centerY);

    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(15);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@(1));
    }];

}

- (void)setNewsModel:(NewsModel *)newsModel{
    
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithAttributedString:[newsModel.title stringWithParagraphlineSpeace:4 textColor:H3COLOR textFont:_titleLbl.font]];
    if (![PublicTool isNull:self.keyword]) {
        NSArray *rangs = [PublicTool noDifferenceUporLowRangeOfSubString:self.keyword inString:newsModel.title];
        for (NSValue *rangStr in rangs) {
            NSRange range = rangStr.rangeValue;
            [attText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:range];
        }
    }
    self.titleLbl.attributedText = attText;
    NSString *time = ![PublicTool isNull:newsModel.post_time] ? newsModel.post_time : (![PublicTool isNull:newsModel.date] ? newsModel.date:newsModel.news_date);
    if (![PublicTool isNull:time]) {
        NSString *date = [time stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        NSArray *arr = [date componentsSeparatedByString:@"."];
        if (arr.count == 3) {
            NSMutableString *timeStr = [NSMutableString string];
            for (NSString *str in arr) {
                NSString *dateString = str;
                if (dateString.length == 1) {
                    dateString = [NSString stringWithFormat:@"0%@",dateString];
                }
                [timeStr appendFormat:@"%@.",dateString];
            }
            [timeStr deleteCharactersInRange:NSMakeRange(timeStr.length - 1, 1)];
            self.timeLbl.text = timeStr;
            
        }else{
            self.timeLbl.text = date;
        }
    }
    
    self.sourceLbl.text = newsModel.source;
    [self.titleLbl sizeToFit];
}


- (GetSizeWithText *)getSizeTool{
    
    if (!_getSizeTool) {
        _getSizeTool = [[GetSizeWithText alloc] init];
    }
    return _getSizeTool;
}


@end
