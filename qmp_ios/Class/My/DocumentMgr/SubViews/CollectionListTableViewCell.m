//
//  CollectionListTableViewCell.m
//  QimingpianSearch
//
//  Created by Molly on 16/8/6.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "CollectionListTableViewCell.h"

#import "GetSizeWithText.h"
@interface CollectionListTableViewCell()

@property (strong, nonatomic) GetSizeWithText *getSizeTool;
@property (strong, nonatomic) UIView *lineView;

@end
@implementation CollectionListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.readBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 12, 15, 15)];
        [self.readBtn setImage:[UIImage imageNamed:@"read-normal"] forState:UIControlStateNormal];
        [self.readBtn setImage:[UIImage imageNamed:@"read-selected"] forState:UIControlStateSelected];
        [self.contentView addSubview:self.readBtn];
        
        self.titleLbl = [[UILabel alloc] init];
        self.titleLbl.font = [UIFont systemFontOfSize:15.f];
        self.titleLbl.textColor = [UIColor blackColor];
        self.titleLbl.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLbl];
        
        self.timeLbl = [[UILabel alloc] init];
        self.timeLbl.textColor = [UIColor blackColor];
        self.timeLbl.textAlignment = NSTextAlignmentRight;
        self.timeLbl.font = [UIFont systemFontOfSize:12.f];
        [self.contentView addSubview:self.timeLbl];
        
        self.urlLbl = [[UILabel alloc] init];
        self.urlLbl.textColor = [UIColor lightGrayColor];
        self.urlLbl.font = [UIFont systemFontOfSize:13.f];
        self.urlLbl.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.urlLbl];
        
        self.lineView =[[UIView alloc] init];
        self.lineView.backgroundColor = LIST_LINE_COLOR;
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

- (void)initData:(URLModel *)urlModel{
    
    self.urlId = urlModel.urlId;
    self.readBtn.selected = [urlModel.isRead isEqualToString:@"1"]?YES:NO;
    
    CGFloat margin = 17.f;
    
    NSString *title = [NSString stringWithFormat:@"    %@",urlModel.title];
    CGFloat titleH = [self.getSizeTool calculateSize:title withFont:[UIFont systemFontOfSize:15.f] withWidth:SCREENW - 16].height;
    self.titleLbl.frame = CGRectMake(margin, 10, SCREENW - 34, titleH);
    self.titleLbl.numberOfLines = 0;
    self.titleLbl.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLbl.text = title;
    
    CGFloat timeW = 100;
    self.timeLbl.text = urlModel.collect_time;
    self.timeLbl.frame = CGRectMake(SCREENW - timeW - margin, self.titleLbl.frame.origin.y + self.titleLbl.frame.size.height + 5, timeW, 20.f);
    
    self.urlLbl.frame = CGRectMake(margin, self.timeLbl.frame.size.height + self.timeLbl.frame.origin.y + 5, SCREENW - 34, 20.f);
    self.urlLbl.text = urlModel.url;

    self.lineView.frame =  self.lineView.frame = CGRectMake(17,self.urlLbl.frame.origin.y + self.urlLbl.frame.size.height + 7.5 , SCREENW-34, 0.5);
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    self.lineView.frame =  self.lineView.frame = CGRectMake(17,self.height-0.5 , SCREENW-34, 0.5);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (GetSizeWithText *)getSizeTool{
    
    if (!_getSizeTool) {
        _getSizeTool = [[GetSizeWithText alloc] init];
    }
    return _getSizeTool;
}

@end
