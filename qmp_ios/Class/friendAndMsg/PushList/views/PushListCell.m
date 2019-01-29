//
//  PushListCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PushListCell.h"

@implementation PushListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(void)setDic:(NSDictionary *)dic{
    _dic = dic;
    NSString *title = [PublicTool isNull:dic[@"title"]] ? dic[@"content"]:dic[@"title"];
    NSAttributedString *attText = [title stringWithParagraphlineSpeace:0 wordSpace:0.3 textColor:NV_TITLE_COLOR textFont:[UIFont systemFontOfSize:15]];
    _titleLab.attributedText = attText;
    _titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
    NSString *content = dic[@"content"];
    NSAttributedString *contentStr = [content stringWithParagraphlineSpeace:6 wordSpace:0.2 textColor:H5COLOR textFont:[UIFont systemFontOfSize:13 weight:UIFontWeightLight]];
    _contentLab.attributedText = contentStr;
    _contentLab.lineBreakMode = NSLineBreakByTruncatingTail;

    NSString *time = [PublicTool dateString:dic[@"send_time"]];
    if ([time isEqualToString:@"今日"]) {
        time = [[[dic[@"send_time"] componentsSeparatedByString:@" "] lastObject] substringToIndex:5];
    }
    _timeLab.text = time;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
