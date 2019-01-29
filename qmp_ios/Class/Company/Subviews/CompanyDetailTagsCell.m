
//
//  CompanyDetailTagsCell.m
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/11.
//  Copyright © 2016年 qimingpian. All rights reserved.
//企业画像 (标签)

#import "CompanyDetailTagsCell.h"

@interface CompanyDetailTagsCell()
@property(nonatomic,copy)void(^clickTagEvent)(NSString *tag);
@end


@implementation CompanyDetailTagsCell

+(id)cellWithTableView:(UITableView *)tableView clickTag:(void (^)(NSString *))clickTagEvent{
    static NSString *identifier = @"tags";
    CompanyDetailTagsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CompanyDetailTagsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.clickTagEvent = clickTagEvent;
    return cell;
}
+ (id)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"tags";
    CompanyDetailTagsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CompanyDetailTagsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}


-(void)refreshUI:(NSArray *)tagArr andTagsFrame:(TagsFrame *)tagsFrame{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.contentView.backgroundColor = RGB(255, 255, 255, 1);//cell背景
    self.contentView.layer.cornerRadius = 3;
    self.contentView.layer.masksToBounds = YES;
    
    for (NSInteger i=0; i<tagArr.count; i++) {
        UIButton *tagsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tagsBtn.tag = 400 + i;
        tagsBtn.userInteractionEnabled = YES;//用户交互
        [tagsBtn setTitle:tagArr[i] forState:UIControlStateNormal];
        [tagsBtn setTitleColor:COLOR737782 forState:UIControlStateNormal];
        tagsBtn.titleLabel.font = TagsTitleFont;
        tagsBtn.layer.borderColor = COLOR737782.CGColor;
        tagsBtn.layer.borderWidth = 0.5f;
        tagsBtn.layer.cornerRadius = 2;
        tagsBtn.layer.masksToBounds = YES;
        
        tagsBtn.frame = CGRectFromString(tagsFrame.tagsFrames[i]);
        if ([tagArr[i] isEqualToString:@"加画像"]) {
            [tagsBtn setTitle:@"画像" forState:UIControlStateNormal];
            [tagsBtn setImage:[UIImage imageNamed:@"company_addTag"] forState:UIControlStateNormal];
            [tagsBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:2];
            tagsBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
            [tagsBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        }
        [self.contentView addSubview:tagsBtn];
        [tagsBtn addTarget:self action:@selector(tagClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}


- (void)tagClick:(UIButton*)tagBtn{
    
    if (self.clickTagEvent) {
        self.clickTagEvent(tagBtn.titleLabel.text);
    }
}


-(void)refreshPersonUI:(NSArray *)tagArr andTagsFrame:(TagsFrame *)tagsFrame{
    self.contentView.backgroundColor = RGB(255, 255, 255, 1);//cell背景
    self.contentView.layer.cornerRadius = 3;
    self.contentView.layer.masksToBounds = YES;
    
    for (NSInteger i=0; i<tagArr.count; i++) {
        UIButton *tagsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tagsBtn.tag = 400 + i;
        tagsBtn.userInteractionEnabled = YES;//用户交互
        [tagsBtn setTitle:tagArr[i] forState:UIControlStateNormal];
        [tagsBtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
        tagsBtn.titleLabel.font = TagsTitleFont;
        tagsBtn.backgroundColor = HTColorFromRGB(0xf5f5f5);
        tagsBtn.layer.cornerRadius = 2;
        tagsBtn.layer.masksToBounds = YES;
        
        tagsBtn.frame = CGRectFromString(tagsFrame.tagsFrames[i]);
        if ([tagArr[i] isEqualToString:@"加画像"]) {
            [tagsBtn setTitle:@"画像" forState:UIControlStateNormal];
            [tagsBtn setImage:[UIImage imageNamed:@"company_addTag"] forState:UIControlStateNormal];
            [tagsBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:2];
            tagsBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
            [tagsBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        }
        [self.contentView addSubview:tagsBtn];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
