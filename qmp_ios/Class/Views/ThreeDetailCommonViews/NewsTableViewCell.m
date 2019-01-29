//
//  NewsTableViewCell.m
//  qmp_ios
//
//  Created by Molly on 2016/11/9.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "NewsTableViewCell.h"
#import "GetSizeWithText.h"
#import "CopyLabel.h"
#import <UIImageView+WebCache.h>

@interface NewsTableViewCell()

@property (strong, nonatomic) GetSizeWithText *getSizeTool;

@property (strong, nonatomic) UILabel *timeLbl;
@property (strong, nonatomic) UILabel *sourceLbl;

@end

@implementation NewsTableViewCell

+ (NewsTableViewCell *)cellWithTableView:(UITableView *)tableView {
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsTableViewCellID"];
    if (cell == nil) {
        cell = [[NewsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewsTableViewCellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.titleLbl = [[UILabel alloc] init];
        self.titleLbl.textColor = COLOR2D343A;
        self.titleLbl.font = [UIFont systemFontOfSize:14];
        self.titleLbl.userInteractionEnabled = YES;
        [self.contentView addSubview:self.titleLbl];
        
        self.sourceLbl = [[UILabel alloc] init];
        self.sourceLbl.font = [UIFont systemFontOfSize:12.f];
        self.sourceLbl.textColor = H9COLOR;
        [self.contentView addSubview:self.sourceLbl];
        
        self.timeLbl = [[UILabel alloc] init];
        self.timeLbl.textAlignment = NSTextAlignmentRight;
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
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView).offset(-33);
    }];
    
    [self.titleLbl setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
   
    [self.sourceLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLbl.mas_left);
        make.top.equalTo(_titleLbl.mas_bottom).offset(10);
        make.width.greaterThanOrEqualTo(@(90));
        make.height.equalTo(@(16));
    }];
    
    [self.timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_titleLbl.mas_right);
        make.top.equalTo(_titleLbl.mas_bottom).offset(10);
        make.width.equalTo(@(120));
        make.height.equalTo(@(16));
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(15);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@(1));
    }];
    
}

- (void)setFirstRow:(BOOL)firstRow{
    
    if (firstRow) {
        [self.titleLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.bottom.equalTo(self.contentView).offset(-33);
        }];
    }else{
        [self.titleLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.bottom.equalTo(self.contentView).offset(-33);
        }];
    }
}
- (void)setNewsModel:(NewsModel *)newsModel{
   
    self.titleLbl.text = newsModel.title;
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
}


- (GetSizeWithText *)getSizeTool{
    
    if (!_getSizeTool) {
        _getSizeTool = [[GetSizeWithText alloc] init];
    }
    return _getSizeTool;
}

@end
